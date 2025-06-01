#include "CrashLogger.hpp"
#include "CrashLogExceptionHandler.hpp"

#include "StringUtil.h"

namespace CrashLogger::Version {
	std::stringstream output;

	extern void Process(EXCEPTION_POINTERS* info) {
		try {
#ifdef APPVEYOR_BUILD_NUMBER
			output << fmt::format("Appveyor Build: {}\n", APPVEYOR_BUILD_NUMBER);
#else
			output << "Appveyor Build: <unavailable>\n";
#endif
			output << fmt::format("Build Date: {}\n", MWSE_BUILD_DATE);
		}
		catch (...) {
			output << "Failed to log version." << '\n';
		}
	}

	extern std::stringstream& Get() {
		output.flush();
		return output;
	}
}

namespace CrashLogger::Playtime {
	std::stringstream output;

	std::chrono::time_point<std::chrono::system_clock> gameStart;
	std::chrono::time_point<std::chrono::system_clock> gameEnd;

	extern void Init() { gameStart = std::chrono::system_clock::now(); }

	extern void Process(EXCEPTION_POINTERS* info) {
		try {
			gameEnd = std::chrono::system_clock::now();
			auto playtime = gameEnd - gameStart;
			output << "Playtime: " << playtime.count() << "\n";
		}
		catch (...) {
			output << "Failed to log playtime." << '\n';
		}
	}

	extern std::stringstream& Get() {
		output.flush();
		return output;
	}
}

namespace CrashLogger::Exception {
	std::stringstream output;

	extern void Process(EXCEPTION_POINTERS* info) {
		try {
			const auto exceptionAsString = GetExceptionAsString(info->ExceptionRecord->ExceptionCode);
			output << fmt::format("Exception: {} ({:08X})\n", exceptionAsString, info->ExceptionRecord->ExceptionCode);

			const auto lastError = GetLastError();
			if (lastError) {
				const auto asString = SanitizeString(GetErrorAsString(lastError));
				output << fmt::format("Last Error: {} ({:08X})\n", asString, lastError);
			}
		}
		catch (...) {
			output << "Failed to log exception." << '\n';
		}
	}

	extern std::stringstream& Get() {
		output.flush();
		return output;
	}
}

namespace CrashLogger::Thread {
	std::stringstream output;

	static std::wstring GetCurrentThreadDescription() {
		wchar_t* pThreadName = nullptr;
		const auto hr = GetThreadDescription(GetCurrentThread(), &pThreadName);
		if (!SUCCEEDED(hr)) {
			return L"<unknown thread>";
		}
		const std::wstring name = pThreadName;
		LocalFree(pThreadName);
		return pThreadName;
	}

	static std::string GetThreadName() {
		return mwse::string::from_wstring(GetCurrentThreadDescription());
	}

	extern void Process(EXCEPTION_POINTERS* info) {
		try { output << "Thread: " << GetThreadName() << '\n'; }
		catch (...) { output << "Failed to log thread name." << '\n'; }
	}

	extern std::stringstream& Get() {
		output.flush();
		return output;
	}
}

namespace CrashLogger::Calltrace {
	std::stringstream output;

	std::string GetCalltraceFunction(UINT32 eip, UINT32 ebp, HANDLE process) {
		/*if (GetModuleFileName((HMODULE)frame.AddrPC.Offset, path, MAX_PATH)) {  //Do this work on non base addresses even on  Windows? Cal directly the LDR function?
		if (!SymLoadModule(process, NULL, path, NULL, 0, 0)) Log() << FormatString("Porcoddio %0X", GetLastError());
		}*/

		const auto moduleBase = PDB::GetModuleBase(eip, process);

		std::string begin = fmt::format("0x{:08X} | ", ebp);

		std::string middle;

		const auto moduleOffset = (moduleBase != 0x00400000) ? eip - moduleBase + 0x10000000 : eip;

		if (const auto module = PDB::GetModule(eip, process); module.empty())
			middle = fmt::format("{:>28s} (0x{:08X}) | {:<40s} |", "???", moduleOffset, "(Corrupt stack or heap?)");
		else if (const auto symbol = PDB::GetSymbol(eip, process); symbol.empty())
			middle = fmt::format("{:>28s} (0x{:08X}) | {:<40s} |", module, moduleOffset, "");
		else
			middle = fmt::format("{:>28s} (0x{:08X}) | {:<40s} |", module, moduleOffset, symbol);

		std::string end;

		if (const auto line = PDB::GetLine(eip, process); !line.empty()) {
			end = " " + line;
		}

		return begin + middle + end;
	}

	extern void Process(EXCEPTION_POINTERS* info) {
		try {
			HANDLE process = GetCurrentProcess();
			HANDLE thread = GetCurrentThread();

			DWORD machine = IMAGE_FILE_MACHINE_I386;
			CONTEXT context = {};
			memcpy(&context, info->ContextRecord, sizeof(CONTEXT));

			SymSetOptions(SYMOPT_LOAD_LINES | SYMOPT_DEFERRED_LOADS | SYMOPT_UNDNAME | SYMOPT_ALLOW_ABSOLUTE_SYMBOLS);

			char workingDirectory[MAX_PATH];
			char symbolPath[MAX_PATH];
			char altSymbolPath[MAX_PATH];
			GetCurrentDirectory(MAX_PATH, workingDirectory);
			GetEnvironmentVariable("_NT_SYMBOL_PATH", symbolPath, MAX_PATH);
			GetEnvironmentVariable("_NT_ALTERNATE_SYMBOL_PATH ", altSymbolPath, MAX_PATH);
			std::string lookPath = fmt::format("{};{}\\Data\\OBSE\\plugins;{};{}", workingDirectory, workingDirectory, symbolPath, altSymbolPath);

			//	SymSetExtendedOption((IMAGEHLP_EXTENDED_OPTIONS)SYMOPT_EX_WINE_NATIVE_MODULES, TRUE);
			if (!SymInitialize(process, lookPath.c_str(), true)) {
				output << "Error initializing symbol store" << '\n';
			}

			//	SymSetExtendedOption((IMAGEHLP_EXTENDED_OPTIONS)SYMOPT_EX_WINE_NATIVE_MODULES, TRUE);

			STACKFRAME frame = {};
			frame.AddrPC.Offset = info->ContextRecord->Eip;
			frame.AddrPC.Mode = AddrModeFlat;
			frame.AddrFrame.Offset = info->ContextRecord->Ebp;
			frame.AddrFrame.Mode = AddrModeFlat;
			frame.AddrStack.Offset = info->ContextRecord->Esp;
			frame.AddrStack.Mode = AddrModeFlat;
			DWORD eip = 0;

			// crutch to try to copy dbghelp before.
			output << fmt::format("{:^10} |  {:^40} | {:^40} | Source", "ebp", "Function Address", "Function Name") << '\n';

			while (StackWalk(machine, process, thread, &frame, &context, NULL, SymFunctionTableAccess, SymGetModuleBase, NULL)) {
				/*
				Using  a PDB for OBSE from VS2019 is causing the frame to repeat, but apparently only if WINEDEBUG=+dbghelp isn't setted. Is this a wine issue?
				When this happen winedbg show only the first line (this happens with the first frame only probably, even if there are more frames shown when using WINEDEBUG=+dbghelp )
				*/
				if (frame.AddrPC.Offset == eip) break;
				eip = frame.AddrPC.Offset;
				output << GetCalltraceFunction(frame.AddrPC.Offset, frame.AddrFrame.Offset, process) << '\n';
			}
		}
		catch (...) {
			output << "Failed to log callstack." << '\n';
		}
	}

	extern std::stringstream& Get() { output.flush(); return output; }
}

namespace CrashLogger::LuaTraceback {
	std::stringstream output;

	extern void Process(EXCEPTION_POINTERS* info) {
		try {
			output << mwse::lua::getStackTrace(true) << '\n';
		}
		catch (...) {
			output << "Failed to log lua traceback." << '\n';
		}
	}

	extern std::stringstream& Get() {
		output.flush();
		return output;
	}
}

namespace CrashLogger::Warnings {
	std::stringstream output;

	extern void Process(EXCEPTION_POINTERS* info) {
		try {
			// Dump Warnings.txt.
			if (!std::filesystem::exists("Warnings.txt")) {
				return;
			}

			std::ifstream warnings("Warnings.txt");
			if (!warnings.is_open()) {
				return;
			}

			std::unordered_set<std::string> seenLines;
			std::string line;
			while (std::getline(warnings, line)) {
				if (line.empty()) continue;
				if (seenLines.find(line) == seenLines.end()) {
					output << line << std::endl;
					seenLines.insert(line);
				}
			}

			warnings.close();
		}
		catch (...) {
			output << "Failed to log warnings." << '\n';
		}
	}

	extern std::stringstream& Get() {
		output.flush();
		return output;
	}
}
