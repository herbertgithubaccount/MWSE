--- @meta

-- This file is autogenerated. Do not edit this file manually. Your changes will be ignored.
-- More information: https://github.com/MWSE/MWSE/tree/master/docs

--- A mobile object for a spell projectile.
--- @class tes3mobileSpellProjectile : tes3mobileProjectile, tes3mobileObject
--- @field rotationSpeed number The angular speed that the projectile rotates around its local Y axis.
--- @field spellInstance tes3magicSourceInstance Access to the magic source instance of the object.
--- @field spellInstanceSerial number Unique indentifier for just this magic source.
tes3mobileSpellProjectile = {}

--- Detonates the projectile, as if it hit a static object. The effects of detonation are not applied immediately, but later in the frame, at the same time as projectile collisions. This ensures consistent behaviour of the magic system.
function tes3mobileSpellProjectile:explode() end

