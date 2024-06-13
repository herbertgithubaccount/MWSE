local Parent = require("mcm.components.infos.MouseOverInfo")

--- @class mwseMCMActiveInfo
local ActiveInfo = Herbert_Class.new{parents={Parent}}
ActiveInfo.triggerOn = "MCM:refresh"
ActiveInfo.triggerOff = "--unused--"

return ActiveInfo
