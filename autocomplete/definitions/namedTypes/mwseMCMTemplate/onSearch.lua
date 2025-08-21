return {
	type = "value",
	description = [[A custom search handler function. This function should return true if this mod Template should show up in search results for given `searchText`. Note that `searchText` will already be lowercased if `caseSensitive` is `false`.]],
	valuetype = "nil|fun(searchText: string, caseSensitive: boolean): boolean",
}
