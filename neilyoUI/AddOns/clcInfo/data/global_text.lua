local mod = clcInfo.env

local lsVengeance = GetSpellInfo(93099)
local GetAuraTooltipString = clcInfo.datautil.GetAuraTooltipString
function mod.TextVengeance(unit)
	unit = unit or "player"
	local tt = GetAuraTooltipString("player", lsVengeance, "HELPFUL|PLAYER")
	if tt then
		return tonumber(string.match(tt, "%d+"))
	end
	return 0
end