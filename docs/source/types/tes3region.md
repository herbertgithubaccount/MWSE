# tes3region
<div class="search_terms" style="display: none">tes3region, region</div>

<!---
	This file is autogenerated. Do not edit this file manually. Your changes will be ignored.
	More information: https://github.com/MWSE/MWSE/tree/master/docs
-->

A structure that contains region information.

This type inherits the following: [tes3baseObject](../types/tes3baseObject.md).
## Properties

### `blocked`
<div class="search_terms" style="display: none">blocked</div>

The blocked state of the object.

**Returns**:

* `result` (boolean)

***

### `deleted`
<div class="search_terms" style="display: none">deleted</div>

*Read-only*. The deleted state of the object.

**Returns**:

* `result` (boolean)

***

### `disabled`
<div class="search_terms" style="display: none">disabled</div>

*Read-only*. The disabled state of the object.

**Returns**:

* `result` (boolean)

***

### `id`
<div class="search_terms" style="display: none">id</div>

*Read-only*. The unique identifier for the object.

**Returns**:

* `result` (string)

***

### `modified`
<div class="search_terms" style="display: none">modified, ified</div>

The modification state of the object since the last save.

**Returns**:

* `result` (boolean)

***

### `name`
<div class="search_terms" style="display: none">name</div>

The region's name. It must be a string less than 32 characters long.

**Returns**:

* `result` (string)

***

### `objectFlags`
<div class="search_terms" style="display: none">objectflags</div>

*Read-only*. The raw flags of the object.

**Returns**:

* `result` (number)

***

### `objectType`
<div class="search_terms" style="display: none">objecttype</div>

*Read-only*. The type of object. Maps to values in [`tes3.objectType`](https://mwse.github.io/MWSE/references/object-types/).

**Returns**:

* `result` ([tes3.objectType](../references/object-types.md))

***

### `persistent`
<div class="search_terms" style="display: none">persistent</div>

The persistent flag of the object.

**Returns**:

* `result` (boolean)

***

### `sleepCreature`
<div class="search_terms" style="display: none">sleepcreature</div>

*Read-only*. The region's leveled creature that can be spawned while the player is sleeping.

**Returns**:

* `result` ([tes3leveledCreature](../types/tes3leveledCreature.md))

***

### `sounds`
<div class="search_terms" style="display: none">sounds</div>

*Read-only*. Array-style table for the different region sounds. Each object in the table is a [`tes3regionSound`](https://mwse.github.io/MWSE/types/tes3regionSound/).

**Returns**:

* `result` ([tes3regionSound](../types/tes3regionSound.md)[])

***

### `sourceless`
<div class="search_terms" style="display: none">sourceless</div>

The sourceless flag of the object.

**Returns**:

* `result` (boolean)

***

### `sourceMod`
<div class="search_terms" style="display: none">sourcemod</div>

*Read-only*. The filename (including the extension) of the mod that owns this object. It has `nil` value if the object was anything other than loaded from an ESP or ESM file.

**Returns**:

* `result` (string)

***

### `supportsActivate`
<div class="search_terms" style="display: none">supportsactivate</div>

If true, the object supports activation. This includes all the items (excluding non-carriable lights), actors outside combat, activators, containers and doors.

However, the activation of such an object may still be blocked via mwscript or a Lua script.

**Returns**:

* `result` (boolean)

***

### `supportsLuaData`
<div class="search_terms" style="display: none">supportsluadata</div>

If true, references of this object can store temporary or persistent lua data.

**Returns**:

* `result` (boolean)

***

### `weather`
<div class="search_terms" style="display: none">weather</div>

The region's current weather.

**Returns**:

* `result` ([tes3weather](../types/tes3weather.md))

***

### `weatherChanceAsh`
<div class="search_terms" style="display: none">weatherchanceash</div>

The chance the Ash weather-type will be used. Must be an integer between `0` and `100`.

**Returns**:

* `result` (integer)

***

### `weatherChanceBlight`
<div class="search_terms" style="display: none">weatherchanceblight</div>

The chance the Blight weather-type will be used. Must be an integer between `0` and `100`.

**Returns**:

* `result` (integer)

***

### `weatherChanceBlizzard`
<div class="search_terms" style="display: none">weatherchanceblizzard</div>

The chance the Blizzard weather-type will be used. Must be an integer between `0` and `100`.

**Returns**:

* `result` (integer)

***

### `weatherChanceClear`
<div class="search_terms" style="display: none">weatherchanceclear</div>

The chance the Clear weather-type will be used. Must be an integer between `0` and `100`.

**Returns**:

* `result` (integer)

***

### `weatherChanceCloudy`
<div class="search_terms" style="display: none">weatherchancecloudy</div>

The chance the Cloudy weather-type will be used. Must be an integer between `0` and `100`.

**Returns**:

* `result` (integer)

***

### `weatherChanceFoggy`
<div class="search_terms" style="display: none">weatherchancefoggy</div>

The chance the Foggy weather-type will be used. Must be an integer between `0` and `100`.

**Returns**:

* `result` (integer)

***

### `weatherChanceOvercast`
<div class="search_terms" style="display: none">weatherchanceovercast</div>

The chance the Overcast weather-type will be used. Must be an integer between `0` and `100`.

**Returns**:

* `result` (integer)

***

### `weatherChanceRain`
<div class="search_terms" style="display: none">weatherchancerain</div>

The chance the Rain weather-type will be used. Must be an integer between `0` and `100`.

**Returns**:

* `result` (integer)

***

### `weatherChances`
<div class="search_terms" style="display: none">weatherchances</div>

*Read-only*. Array-style table for the different weather chances. Each object in the table is a number, between 1 - 100. The index of the table is the weather type.

**Returns**:

* `result` (number[])

***

### `weatherChanceSnow`
<div class="search_terms" style="display: none">weatherchancesnow</div>

The chance the Snow weather-type will be used. Must be an integer between `0` and `100`.

**Returns**:

* `result` (integer)

***

### `weatherChanceThunder`
<div class="search_terms" style="display: none">weatherchancethunder</div>

The chance the Thunder weather-type will be used. Must be an integer between `0` and `100`.

**Returns**:

* `result` (integer)

***

## Methods

### `__tojson`
<div class="search_terms" style="display: none">__tojson</div>

Serializes the object to json.

```lua
local string = myObject:__tojson()
```

**Returns**:

* `string` (string)

***

### `changeWeather`
<div class="search_terms" style="display: none">changeweather</div>

Changes the current weather for the region to the provided weather-type parameter.

```lua
myObject:changeWeather(weatherId)
```

**Parameters**:

* `weatherId` ([tes3.weather](../references/weather-types.md)): Maps to values in the [`tes3.weather`](https://mwse.github.io/MWSE/references/weather-types/) table.

***

### `randomizeWeather`
<div class="search_terms" style="display: none">randomizeweather</div>

Changes the weather to a random weather type.

```lua
myObject:randomizeWeather()
```

**Parameters**:


