--- @type tes3uiElement, table
local myPage, myConfig
mwse.mcm.createSlider{
	parent = myPage,
	label = "My skill slider",
	variable = mwse.mcm.createTableVariable{ id = "skillId", table = myConfig },
	convertToLabelValue = function(self, variableValue)
		local skillName = tes3.getSkillName(math.round(variableValue))
		if skillName then
			return skillName
		end
		return "N/A"
	end,

	max = 26 -- there are 27 skills and indexing starts at 0
}
