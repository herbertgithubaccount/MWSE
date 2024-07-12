return {
	type = "value",
	description = [[The config to use when creating a [`mwseMCMTableVariable`](../types/mwseMCMTableVariable.md) for this `Setting`.
If provided, it will override the config stored in `parentComponent`.
Otherwise, the value in `parentComponent` will be used."

!!! note
	This value is only utilized when constructing a new [`mwseMCMTableVariable`s](../types/mwseMCMTableVariable.md). 
	Nothing will happen if it gets altered after object creation.
]],
	valuetype = "table",
}
