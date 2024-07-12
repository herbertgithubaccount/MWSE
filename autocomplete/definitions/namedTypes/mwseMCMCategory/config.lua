return {
	type = "value",
	description = "If provided, this `config` will be used to generate [`mwseMCMTableVariable`s](./mwseMCMTableVariable.md) for any \z
		[`mwseMCMSetting`s](./mwseMCMSetting.md) made inside this `Category`/`Page`. \z
		i.e., this parameter provides an alternative to explicitly constructing new variables. \z
		Subtables of this `config` can be accessed by passing a `configKey` to any `Category` that is nested inside this one.",
	valuetype = "table",
}
