--- @meta

-- This file is autogenerated. Do not edit this file manually. Your changes will be ignored.
-- More information: https://github.com/MWSE/MWSE/tree/master/docs

--- A game object which holds information about an active body part, it's associated item and scene node.
--- @class tes3bodyPartManagerActiveBodyPart
--- @field bodyPart tes3bodyPart Access to the body part object.
--- @field flags number The raw flags.
--- @field item tes3alchemy|tes3apparatus|tes3armor|tes3book|tes3clothing|tes3ingredient|tes3item|tes3light|tes3lockpick|tes3misc|tes3probe|tes3repairTool|tes3weapon The raw item object this active body part pertains to.
--- @field node niBSAnimationNode|niBSParticleNode|niBillboardNode|niCollisionSwitch|niNode|niSortAdjustNode|niSwitchNode The NiNode-derived object for the object's loaded mesh.
