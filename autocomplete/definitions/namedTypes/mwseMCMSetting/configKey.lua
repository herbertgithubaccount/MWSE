return {
	type = "value",
	description = [[The `configKey` used to create a new [`mwseMCMTableVariable`s](../types/mwseMCMTableVariable.md).
If this is provided, along with a `config` (which may be inherited from the `parentComponent`), then a new
[`mwseMCMTableVariable`s](../types/mwseMCMTableVariable.md) variable will be created for this setting.

!!! note
	This value is only utilized when constructing a new [`mwseMCMTableVariable`s](../types/mwseMCMTableVariable.md). 
	Nothing will happen if it gets altered after object creation.
]],
	valuetype = "string|number",
}
