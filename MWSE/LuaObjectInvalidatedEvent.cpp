#include "LuaObjectInvalidatedEvent.h"

#include "LuaManager.h"
#include "SafeObjectHandle.h"

namespace mwse::lua::event {
	ObjectInvalidatedEvent::ObjectInvalidatedEvent(sol::object object) :
		GenericEvent("objectInvalidated"),
		m_Object(object)
	{
		
		const auto itt = TES3::SafeObjectHandle::safeObjectHandles.find(object.as<TES3::Object*>());
		if (itt != TES3::SafeObjectHandle::safeObjectHandles.end()) {
			itt->second->object = nullptr;
		}
	}

	sol::table ObjectInvalidatedEvent::createEventTable() {
		const auto stateHandle = LuaManager::getInstance().getThreadSafeStateHandle();
		auto& state = stateHandle.getState();
		auto eventData = state.create_table();

		eventData["object"] = m_Object;

		return eventData;
	}
}
