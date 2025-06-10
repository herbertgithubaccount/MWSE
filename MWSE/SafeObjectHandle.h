#pragma once
#include "TES3Object.h"
namespace TES3 {
class SafeObjectHandle
{
public:

	static std::unordered_map<TES3::Object*, SafeObjectHandle*> safeObjectHandles;

	TES3::Object* object;

	SafeObjectHandle(TES3::Object*) : object(object) {};

	SafeObjectHandle* create(TES3::Object* object);

	bool isValid();

	std::optional<TES3::Object*> get();
	sol::optional<TES3::Object*> getLua();
};

}