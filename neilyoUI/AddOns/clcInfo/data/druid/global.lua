-- don't load if class is wrong
local _, class = UnitClass("player")
if class ~= "DRUID" then return end

local emod = clcInfo.env -- functions visible to exec should be attached to this

-- get combo points
-- returns 2 values:
-- value1: return of GetComboPoints("player") or leftover combo points
-- value2: 1 if value1 is leftover points, nil otherwise
-- needs at least savage roar
do
	local prevCP = 0
	local roar = GetSpellInfo(52610)
	function emod.GetCP()
		local cp = GetComboPoints("player")
		local isUsable, notEnoughMana = IsUsableSpell(roar)
		if cp > 0 or (isUsable == nil and notEnoughMana == nil) then
			prevCP = cp
			return cp
		end
		return prevCP, 1
	end
end