#include "stdafx.h"
#include "SafeObjectHandle.h"

namespace TES3 {


class SafeObjectHandle
{
public:
	static std::unordered_map<TES3::Object*, SafeObjectHandle*> safeObjectHandles;

	TES3::Object* object;

	SafeObjectHandle(TES3::Object*) : object(object) {};

	static SafeObjectHandle* create(TES3::Object* object) {
		const auto itt = safeObjectHandles.find(object);

		// if it doesnt exist
		if (itt == safeObjectHandles.end()) {
			auto handle = new SafeObjectHandle(object);
			safeObjectHandles.insert({ object, handle });
			return handle;
		}
		else { // it exists
			return itt->second;
		}
	}


	bool isValid() {
		return object == nullptr;
	}

	std::optional<TES3::Object*> get() {
		if (object) {
			return { object };
		}
		return {};
	}

	sol::optional<TES3::Object*> getLua() {
		if (object) {
			return { object };
		}
		return {};
	}
};
}