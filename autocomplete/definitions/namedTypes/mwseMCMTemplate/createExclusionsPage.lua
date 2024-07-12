return {
	type = "method",
	description = [[Creates a new Exclusions Page in this Template.]],
	arguments = {{
		name = "data",
		type = "table",
		tableParams = {
			{ name = "showHeader", type = "boolean", optional = true, default = false, description = "The page's label will only be created if set to true." },
			{ name = "label", type = "string", description = "The label field is displayed in the tab for that page at the top of the menu. Defaults to: \"Page {number}\"." },
			{ name = "variable", type = "mwseMCMVariable|mwseMCMSettingNewVariable", optional = true, 
					description = "A variable for this setting. If not provided, this setting will try to create a variable using the `config` and `configKey` parameters, if possible."
			},
			{ name = "config", type = "table", optional = true,  default = "`parentComponent.config`",
				description = "The config to use when creating a [`mwseMCMTableVariable`](../types/mwseMCMTableVariable.md) for this `Setting`. \z
					If provided, it will override the config stored in `parentComponent`. \z
					Otherwise, the value in `parentComponent` will be used."
			},
			{ name = "defaultConfig", type = "table", optional = true, default = "`parentComponent.defaultConfig`",
				description = "The `defaultConfig` to use when creating a [`mwseMCMTableVariable`](../types/mwseMCMTableVariable.md) for this `Setting`. \z
					If provided, it will override the `defaultConfig` stored in `parentComponent`. \z
					Otherwise, the value in `parentComponent` will be used."
			},
			{ name = "configKey", type = "string|number", optional = true, 
				description = "The `configKey` used to create a new [`mwseMCMTableVariable`s](../types/mwseMCMTableVariable.md). \z
					If this is provided, along with a `config` (which may be inherited from the `parentComponent`), then a new \z
					[`mwseMCMTableVariable`s](../types/mwseMCMTableVariable.md) variable will be created for this setting."
			},
			{ name = "converter", type = "fun(newValue: unknown): unknown", optional = true, 
				description = "A converter to use for this component's `variable`."
			},
			{ name = "defaultSetting", type = "unknown", optional = true, 
				description = "If `defaultSetting` wasn't passed in the `variable` table, can be passed here. \z
					The new variable will be initialized to this value. If not provided, then the value in `defaultConfig` will be used, if possible." 
			},
			{ name = "showDefaultSetting", type = "boolean", optional = true, default = "`parentComponent.showDefaultSetting`",
				description = "If `true`, and in a [Sidebar Page](../types/mwseMCMSideBarPage.md), then the `defaultSetting` of this setting's `variable` will be shown below its `description`. \z
					The `defaultSetting` will be formatted in accordance with the `convertToLabelValue` function. \z
					**Note:** This parameter does not update the `description` field.",
			},
			{ name = "filters", type = "mwseMCMExclusionsPageFilter[]", description = "A list of filters. Filters control which items will appear in the lists of the Exclusions Page. At least one filter is required. See the [filter page](./mwseMCMExclusionsPageFilter.md) for description." },
			{ name = "description", type = "string", optional = true, description = "Displayed at the top of the page above the lists." },
			{ name = "toggleText", type = "string", optional = true, description = "The text for the button that toggles filtered items from one list to another. The default is a localised version of \"Toggle Filtered\"." },
			{ name = "leftListLabel ", type = "string", optional = true, description = "The label on the left list. The default is a localised version of \"Blocked\"." },
			{ name = "rightListLabel ", type = "string", optional = true, description = "The label on the right list. The default is a localised version of \"Allowed\"." },
			{ name = "showAllBlocked ", type = "boolean", optional = true, default = false, description = "When set to true, the left list shows all items in the blocked table, regardless of the filter being used." },
			{ name = "indent", type = "integer", optional = true, default = 6, description = "The left padding size in pixels. Only used if the `childIndent` isn't set on the parent component." },
			{ name = "childIndent", type = "integer", optional = true, description = "The left padding size in pixels. Used on all the child components." },
			{ name = "paddingBottom", type = "integer", optional = true, default = 4, description = "The bottom border size in pixels. Only used if the `childSpacing` is unset on the parent component." },
			{ name = "childSpacing", type = "integer", optional = true, description = "The bottom border size in pixels. Used on all the child components." },
			{ name = "inGameOnly", type = "boolean", optional = true, default = false },
		}
	}},
	returns = {{
		name = "page", type = "mwseMCMExclusionsPage"
	}}
}
