--- @meta

-- This file is autogenerated. Do not edit this file manually. Your changes will be ignored.
-- More information: https://github.com/MWSE/MWSE/tree/master/docs

--- This event is triggered when any spell or enchant is cast successfully, or when any alchemy item is used. This includes spells cast via scripts. For spells, this occurs at the end of the casting animation. For spells and enchants, it is just after the magic projectile has been constructed.
--- @class magicCastedEventData
--- @field claim boolean If set to `true`, any lower-priority event callbacks will be skipped. Returning `false` will set this to `true`.
--- @field caster tes3reference *Read-only*. The caster of the spell.
--- @field source tes3alchemy|tes3enchantment|tes3spell *Read-only*. The magic source.
--- @field sourceInstance tes3magicSourceInstance *Read-only*. The unique instance of the magic source.
--- @field target tes3reference *Read-only*. The target of the spell. For self-targeted spells, this matches the caster. Touch spells can also have `target` parameter. On target spells don't have `target` parameter during this event, since it can't have a target until it hits it. Which isn't known when the spell is casted.
