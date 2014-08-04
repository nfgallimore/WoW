-- don't load if class is wrong
local _, class = UnitClass("player")
if class ~= "MONK" then return end

local emod = clcInfo.env -- functions visible to exec should be attached to this

-- stagger icon
---[[
do
	local GetAuraTooltipString = clcInfo.datautil.GetAuraTooltipString
	local lsLightStagger = GetSpellInfo(124275)
	local lsModerateStagger = GetSpellInfo(124274)
	local lsHeavyStagger = GetSpellInfo(124273)
	local staggers = {
		[lsLightStagger] = true,
		[lsModerateStagger] = true,
		[lsHeavyStagger] = true,
	}
	function emod.IconStagger()
		local i = 1
		local name, rank, icon, count, debuffType, duration, expires = UnitAura("player", i, "HARMFUL|PLAYER")
		while name do
			if staggers[name] then
				-- found stagger
				count = floor(tonumber(string.match(GetAuraTooltipString("player", name, "HARMFUL|PLAYER"), "%d+")) / 1000)
				return true, icon, expires - duration, duration, 0, true, count
			end
			i = i + 1
			name, rank, icon, count, debuffType, duration, expires = UnitAura("player", i, "HARMFUL|PLAYER")
		end
	end
end
--]]

function emod.DumbBrew(z)
	local cd, gcd, start, duration, ctime, chi

	start, duration = GetSpellCooldown("Tiger Palm") -- gcd
	ctime = GetTime()
	gcd = start + duration - ctime
	start, duration = GetSpellCooldown("Keg Smash")
	cd = start + duration - ctime - gcd
	local chi = UnitPower("player", SPELL_POWER_LIGHT_FORCE)

	if chi >= 2 then return emod.IconSpell("Blackout Kick") end
	
	if cd > 0.5 then
		if UnitPower("player") > z then
			return emod.IconSpell("Jab")
		end
	else
		return emod.IconSpell("Keg Smash")
	end

	return emod.IconSpell("Tiger Palm")
end