--- @meta

-- This file is autogenerated. Do not edit this file manually. Your changes will be ignored.
-- More information: https://github.com/MWSE/MWSE/tree/master/docs

--- A body part game object.
--- @class tes3bodyPart : tes3physicalObject, tes3object, tes3baseObject
--- @field female boolean A flag that marks this body part as used for female actors.
--- @field mesh string The path to the object's mesh.
--- @field part tes3.partIndex The part of the body occupied. Maps to values in [`tes3.partIndex`](https://mwse.github.io/MWSE/references/part-indices/) namespace.
--- @field partType tes3.activeBodyPartLayer The layer the body part occupies. Maps to values in [`tes3.activeBodyPartLayer`](https://mwse.github.io/MWSE/references/active-body-part-layers/) namespace.
--- @field playable boolean A flag that marks this body part as selectable during character generation.
--- @field raceName string *Read-only*. The name of the race associated with this body part.
--- @field sceneNode niBSAnimationNode|niBSParticleNode|niBillboardNode|niCollisionSwitch|niNode|niSortAdjustNode|niSwitchNode The base mesh for the body part. New parts are cloned from this mesh, and may be accessed through the reference's `tes3bodyPartManager`.
--- @field vampiric boolean A flag that marks this body part as used for vampires.
