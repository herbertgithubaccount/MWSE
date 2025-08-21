return {
	type = "method",
	description = [[Performs searching routine for given `searchText`.]],
	arguments = {
		{ name = "searchText", type = "string", description = "The text to search for. This will be lowercased if `caseSensitive` is `false`." },
		{ name = "caseSensitive", type = "boolean", description = "Whether case-sensitive searching should be performed." },
	},
	returns = {
		{ name = "result", type = "boolean", description = "True if given `searchText` matches this MCM template." }
	}
}
