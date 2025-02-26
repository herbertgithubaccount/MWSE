--- @meta

-- This file is autogenerated. Do not edit this file manually. Your changes will be ignored.
-- More information: https://github.com/MWSE/MWSE/tree/master/docs

--- This event is used when calculating an actor's magic effect resistance, and allows Lua scripts to override the behavior of magic effect resistance by changing the `resistedPercent` value. This can be used to enable willpower-based resistance checks, provide specific resistances to specific spells, spells that heal instead of harm, and a variety of new mechanics.
--- @class spellResistEventData
--- @field claim boolean If set to `true`, any lower-priority event callbacks will be skipped. Returning `false` will set this to `true`.
--- @field caster tes3reference *Read-only*. The caster of the spell.
--- @field effect tes3effect *Read-only*. The specific effect that triggered the event. This is equal to accessing `e.source.effects[effectIndex]`. This field may not always be available.
--- @field effectIndex number *Read-only*. The index of the effect in source's effects list.
--- @field effectInstance tes3magicEffectInstance *Read-only*. The unique instance data of the magic effect.
--- @field resistAttribute number *Read-only*. The attribute resisted. This is an index into a `tes3mobileActor.effectAttributes`. Note that the index here is 0-based, while Lua is 1-based.
--- @field resistedPercent number The percent of the spell that has been resisted. This can be modified, but a value outside the range of 0 to 100 does not have consistent effects. For fire damage, for example, a value over 100 causes the spell to heal the target instead of harming them.
--- @field source tes3alchemy|tes3enchantment|tes3spell *Read-only*. The magic source.
--- @field sourceInstance tes3magicSourceInstance *Read-only*. The unique instance data of the magic source.
--- @field spellCastChance number *Read-only*. The cast chance of the magic source. This is only available if the `source` is a spell or an enchantment.
--- @field target tes3reference *Read-only*. The target of the spell. For self-targeted spells, this matches caster.
