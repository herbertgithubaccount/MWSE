return {
	type = "function",
	description = [[Creates a `string` by concatenating all the elements of a given array-style `table`.

You should use this function to build up strings, as it is *much* more efficient than repeatedly concatenating strings.

You can additionally specify a `sep`arator to use between successive elements.


!!! note
    Everything in `t` should be either a `string` or a `number`. If you would like to include something that is not a `string` or `number`, you must call `tostring` on it before adding it to `t`.

??? example "Examples of basic usage"
    The string `a b c d` can be obtained via `table.concat({"a", "b", "c", "d"}, " ")`

    If you merely want to combine strings together, you can write
    ```lua
    table.concat{"string1", "string2", "string3"} --> "string1string2string3"
    ```
    Calling `table.concat({"printing strings:", "string1", "string2", "string3"}, "\n\t")` will return:
    ```
    printing strings:
        string1
        string2
        string3
    ```

]],
	arguments = {
		{ name = "t", type = "(string|number)[]", description = "A array-style `table` of strings (and/or numbers) to concatenate." },
		{ name = "sep", type = "string", optional = true,  default = "\"\"", description = "The separator to use when concatenating successive elements of `t`."},
		{ name = "startindex", type = "integer", optional = true,  default = "`1`", description = "The index of the first element of `t` to concatenate."},
		{ name = "endindex", type = "integer", optional = true,  default = "`#t`", description = "The index of the last element of `t` to concatenate."},
	},
    returns = {
        {name = "result", type = "string", description = "The string obtained from concatenating all the elements of `t`."}
    },
}