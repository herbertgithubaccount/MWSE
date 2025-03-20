#include "TES3CellLua.h"

#include "LuaManager.h"
#include "TES3ObjectLua.h"

#include "TES3Cell.h"
#include "TES3Land.h"
#include "TES3Region.h"

#include "NIColor.h"

namespace mwse::lua {
	auto iterateReferencesFiltered(const TES3::Cell* cell, const std::unordered_set<unsigned int> desiredTypes, bool iterateDisabled) {
		// Prepare the lists we care about.
		std::queue<const TES3::ReferenceList*> referenceListQueue;
		if (!cell->actors.empty()) {
			referenceListQueue.push(&cell->actors);
		}
		if (!cell->persistentRefs.empty()) {
			referenceListQueue.push(&cell->persistentRefs);
		}
		if (!cell->temporaryRefs.empty()) {
			referenceListQueue.push(&cell->temporaryRefs);
		}

		// Get the first reference we care about.
		TES3::Reference* reference = nullptr;
		if (!referenceListQueue.empty()) {
			reference = referenceListQueue.front()->front();
			referenceListQueue.pop();
		}

		return [cell, reference, referenceListQueue, desiredTypes, iterateDisabled]() mutable -> TES3::Reference* {
			// Skip filtered out references.
			while (reference && (reference->getDeleted() || (!desiredTypes.empty() && !desiredTypes.count(reference->baseObject->objectType)) || (!iterateDisabled && reference->getDisabled()))) {
				reference = reinterpret_cast<TES3::Reference*>(reference->nextInCollection);

				// If we hit the end of the list, check for the next list.
				if (reference == nullptr && !referenceListQueue.empty()) {
					reference = referenceListQueue.front()->front();
					referenceListQueue.pop();
				}
			}

			if (reference == nullptr) {
				return nullptr;
			}

			// Get the object we want to return.
			TES3::Reference* ret = reference;

			// Get the next reference. If we're at the end of the list, go to the next one
			reference = reinterpret_cast<TES3::Reference*>(reference->nextInCollection);
			if (reference == nullptr && !referenceListQueue.empty()) {
				reference = referenceListQueue.front()->front();
				referenceListQueue.pop();
			}

			return ret;
		};
	}

	auto iterateReferences(const TES3::Cell* self, sol::optional<sol::object> param, sol::optional<bool> iterateDisabled) {
		std::unordered_set<unsigned int> filters;

		if (param) {
			if (param.value().is<unsigned int>()) {
				filters.insert(param.value().as<unsigned int>());
			}
			else if (param.value().is<sol::table>()) {
				sol::table filterTable = param.value().as<sol::table>();
				for (const auto& kv : filterTable) {
					if (kv.second.is<unsigned int>()) {
						filters.insert(kv.second.as<unsigned int>());
					}
				}
			}
			else {
				throw std::invalid_argument("Iteration can only be filtered by object type, a table of object types, or must not have any filter.");
			}
		}

		return iterateReferencesFiltered(self, std::move(filters), iterateDisabled.value_or(true));
	}

	sol::optional<std::vector<TES3::Cell*>>
	pathToCell(TES3::Cell* self, sol::table params) {

		bool toClosestExterior = getOptionalParam(params, "toClosestExterior", false);

		TES3::Cell* dest = getOptionalParam(params, "destination", nullptr);

		if (!dest && !toClosestExterior) {
			return {};
		}

		// Stores depth and the cell in question.
		std::vector<std::tuple<int, TES3::Cell*>> unvisitedCells;

		std::vector<TES3::Cell*> path;

		std::unordered_set<TES3::Cell*> knownCells;
		unvisitedCells.push_back({-1, self});

		knownCells.insert(self);

		while (unvisitedCells.size() > 0) {
			int depth = 1 + std::get<0>(unvisitedCells.back());
			TES3::Cell* cell = std::get<1>(unvisitedCells.back());

			unvisitedCells.pop_back();

			if (path.size() <= depth) {
				path.push_back(cell);
			} else {
				path[depth] = cell;
			}

			for (auto refr : cell->persistentRefs) {
				if (refr->baseObject->objectType == TES3::ObjectType::Door) {
					auto destination = refr->getAttachedTravelDestination();
					if (destination) {
						auto destinationCell = destination->cell;
						if (toClosestExterior) {
							if (!destinationCell->getIsInterior()) {
								path.push_back(destinationCell);
								return { path };
							
							}
						}
						else if (dest != 0 && destinationCell->getObjectID() == dest->getObjectID()) {
							path.push_back(destinationCell);
							return { path };
						}
						

						// Queue up new unseen interior cells.
						if (knownCells.count(destinationCell) == 0) {
							knownCells.insert(destinationCell);
							unvisitedCells.push_back({ depth, destinationCell });
						} 
					}
				}
			}




		}

		return {};
	}


	void bindTES3Cell() {
		// Get our lua state.
		auto stateHandle = LuaManager::getInstance().getThreadSafeStateHandle();
		auto& state = stateHandle.state;

		// Binding for TES3::Cell
		{
			// Start our usertype.
			auto usertypeDefinition = state.new_usertype<TES3::Cell>("tes3cell");
			usertypeDefinition["new"] = sol::no_constructor;

			// Define inheritance structures. These must be defined in order from top to bottom. The complete chain must be defined.
			usertypeDefinition[sol::base_classes] = sol::bases<TES3::BaseObject>();
			setUserdataForTES3BaseObject(usertypeDefinition);

			// Basic property binding.
			usertypeDefinition["actors"] = sol::readonly_property(&TES3::Cell::actors);
			usertypeDefinition["activators"] = sol::readonly_property(&TES3::Cell::persistentRefs);
			usertypeDefinition["cellFlags"] = &TES3::Cell::cellFlags;
			usertypeDefinition["pathGrid"] = sol::readonly_property(&TES3::Cell::pathGrid);
			usertypeDefinition["statics"] = sol::readonly_property(&TES3::Cell::temporaryRefs);

			// Functions exposed as properties.
			usertypeDefinition["ambientColor"] = sol::readonly_property(&TES3::Cell::getAmbientColor);
			usertypeDefinition["behavesAsExterior"] = sol::property(&TES3::Cell::getBehavesAsExterior, &TES3::Cell::setBehavesAsExterior);
			usertypeDefinition["displayName"] = sol::readonly_property(&TES3::Cell::getDisplayName);
			usertypeDefinition["editorName"] = sol::readonly_property(&TES3::Cell::getEditorName);
			usertypeDefinition["fogColor"] = sol::readonly_property(&TES3::Cell::getFogColor);
			usertypeDefinition["fogDensity"] = sol::property(&TES3::Cell::getFogDensity, &TES3::Cell::setFogDensity);
			usertypeDefinition["gridX"] = sol::property(&TES3::Cell::getGridX, &TES3::Cell::setGridX);
			usertypeDefinition["gridY"] = sol::property(&TES3::Cell::getGridY, &TES3::Cell::setGridY);
			usertypeDefinition["hasWater"] = sol::property(&TES3::Cell::getHasWater, &TES3::Cell::setHasWater);
			usertypeDefinition["hasMapMarker"] = sol::readonly_property(&TES3::Cell::getHasCellMarker);
			usertypeDefinition["isInterior"] = sol::property(&TES3::Cell::getIsInterior, &TES3::Cell::setIsInterior);
			usertypeDefinition["isOrBehavesAsExterior"] = sol::readonly_property(&TES3::Cell::getIsOrBehavesAsExterior);
			usertypeDefinition["landscape"] = sol::readonly_property(&TES3::Cell::getLandscape);
			usertypeDefinition["name"] = sol::property(&TES3::Cell::getName, &TES3::Cell::setName);
			usertypeDefinition["pickObjectsRoot"] = sol::readonly_property(&TES3::Cell::pickObjectsRoot);
			usertypeDefinition["region"] = sol::readonly_property(&TES3::Cell::getRegion);
			usertypeDefinition["restingIsIllegal"] = sol::property(&TES3::Cell::getSleepingIsIllegal, &TES3::Cell::setSleepingIsIllegal);
			usertypeDefinition["staticObjectsRoot"] = sol::readonly_property(&TES3::Cell::staticObjectsRoot);
			usertypeDefinition["sunColor"] = sol::readonly_property(&TES3::Cell::getSunColor);
			usertypeDefinition["waterLevel"] = sol::property(&TES3::Cell::getWaterLevel, &TES3::Cell::setWaterLevel);

			// Basic function binding.
			usertypeDefinition["isPointInCell"] = &TES3::Cell::isPointInCell;
			usertypeDefinition["iterateReferences"] = iterateReferences;
			usertypeDefinition["pathToCell"] = pathToCell;
		}

		// Binding for TES3::PathGrid	
		{
			// Start our usertype.
			auto usertypeDefinition = state.new_usertype<TES3::PathGrid>("tes3pathGrid");
			usertypeDefinition["new"] = sol::no_constructor;

			// Define inheritance structures. These must be defined in order from top to bottom. The complete chain must be defined.
			usertypeDefinition[sol::base_classes] = sol::bases<TES3::BaseObject>();
			setUserdataForTES3BaseObject(usertypeDefinition);

			// Basic property binding.
			usertypeDefinition["granularity"] = sol::readonly_property(&TES3::PathGrid::granularity);
			usertypeDefinition["isLoaded"] = sol::readonly_property(&TES3::PathGrid::isLoaded);
			usertypeDefinition["nodeCount"] = sol::readonly_property(&TES3::PathGrid::nodeCount);
			usertypeDefinition["nodes"] = sol::readonly_property(&TES3::PathGrid::nodes);
			usertypeDefinition["parentCell"] = sol::readonly_property(&TES3::PathGrid::parentCell);
		}

		// Binding for TES3::PathGrid::Node
		{
			// Start our usertype.
			auto usertypeDefinition = state.new_usertype<TES3::PathGrid::Node>("tes3pathGridNode");
			usertypeDefinition["new"] = sol::no_constructor;

			// Basic property binding.
			usertypeDefinition["connectedNodes"] = sol::readonly_property(&TES3::PathGrid::Node::getConnectedNodes_lua);
			usertypeDefinition["grid"] = sol::readonly_property(&TES3::PathGrid::Node::parentGrid);

			// Functions exposed as properties.
			usertypeDefinition["position"] = sol::readonly_property(&TES3::PathGrid::Node::getPosition);
		}
	}
	
}
