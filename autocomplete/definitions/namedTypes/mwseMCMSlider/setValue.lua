return {
	type = "method",
	description = [[Sets the new value of this slider to the given value. You should use this method to change the value stored in the slider, as it will also update the displayed text and the slider widget. This method will also call the `callback` method and display the "restart required" message, if appropriate.]],

	arguments = {
		{ name = "newVariableValue", type = "number" }
	},
}
