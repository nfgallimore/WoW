-- don't load if class is wrong
local _, class = UnitClass("player")
if class ~= "SHAMAN" then return end

local emod = clcInfo.env

function emod.IconTotem(slot)
	local haveTotem, name, startTime, duration, icon = GetTotemInfo(slot)
	if startTime > 0 then return true, icon, startTime, duration, 1 end
	return false
end

-- ---------------------------------------------------------------------------------------------------------------------
-- MULTIPLE TARGET FS TRACKING - Experimental
-- ---------------------------------------------------------------------------------------------------------------------
-- CLEU EVENTS TO TRACK
-- SPELL_AURA_APPLIED -> dot applied 
-- SPELL_AURA_REFRESH -> dot refresh
-- SPELL_AURA_REMOVED -> dot removed
-- ---------------------------------------------------------------------------------------------------------------------

do
	local ef, list, playerName, d, duration, glyph
	glyph = false
	playerName = UnitName("player")
	local fsName, fsId, fsSpellTexture
	fsId = 8050
	fsName, _, fsSpellTexture = GetSpellInfo(fsId)
	
	local function ExecCleanup()
		list = nil
		ef:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		ef.registered = false
	end
	
	-- starts to track the hot for that guid
	local function SPELL_AURA_APPLIED(guid, name)
		d = 1
		d = duration / (1 + UnitSpellHaste("player") / 100)
		list[guid] = { name, d, GetTime() + d }
	end
	
	local function SPELL_AURA_REFRESH(guid, name)
		d = duration / (1 + UnitSpellHaste("player") / 100)
		list[guid] = { name, d, GetTime() + d }
	end
	
	local function SPELL_AURA_REMOVED(guid)
		list[guid] = nil
	end
	
	local function CLEU(frame, event, timestamp, combatEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, spellType, dose, ...)
		if spellId == fsId and sourceName == playerName then
			if combatEvent == "SPELL_AURA_APPLIED" then
				SPELL_AURA_APPLIED(destGUID, destName)
			elseif combatEvent == "SPELL_AURA_REFRESH" then
				SPELL_AURA_REFRESH(destGUID, destName)
			elseif combatEvent == "SPELL_AURA_REMOVED" then
				SPELL_AURA_REMOVED(destGUID)
			end
		end
	end
	
	function emod.MBarFlameShock(a1, a2, timeRight, d)
		duration = d
		-- setup the table for fs data
		if not list then
			list = {}
			emod.___e.ExecCleanup = ExecCleanup
		end
	
		-- setup CLEU monitoring
		if not ef then
			ef = CreateFrame("Frame")
			ef:Hide()
			ef:SetScript("OnEvent", CLEU)
		end
		if not ef.registered then
			ef:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			ef.registered = true
		end
		
		-- go through the saved data
		-- delete the ones that expired
		-- display the rest
		local gt = GetTime()
		local value, tr, alpha
		for k, v in pairs(list) do
			-- 3 = expires
			if gt > v[3] then
				list[k] = nil
			else
				value = v[3] - gt
				if timeRight then
					tr = tostring(math.floor(value + 0.5))
				else
					tr = ""
				end
				if k == UnitGUID("target") then
					alpha = a1
				else
					alpha = a2
				end
				
				emod.___e:___AddBar(nil, alpha, nil, nil, nil, nil, fsSpellTexture, 0, v[2], value, "normal", v[1], "", tr)
			end
		end
	end
end
