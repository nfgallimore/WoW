local DOTMonitor = getglobal("DOTMonitor") or {}

-- ///////////////////////////////////////////////////////////////////////////////////////
-- Print Functions
-- printMessage( messageText [, (red, green, blue | info | epic)]) -> prints messageText to DEFAULT_CHAT_FRAME
DOTMonitor.printMessage = (function(aMessage, ...)
	local colorScheme = {
		["none"] 	= {r = 0,	g = 1,	b = 1},
		["info"] 	= {r = 0,	g = 1,	b = 1},
		["epic"] 	= {r = .8,	g = .2,	b = 1},
		["alert"] 	= {r = 1,	g = 0,	b = 0},
		["custom"] 	= {r = 1,	g = 1,	b = 1}
	}
	local colorType = "info";
	
	if (...) then
		local r, g, b = ...
		if type(r) == "number" and type(g) == "number" and type(b) == "number" then
			colorType = "custom";
			colorScheme[colorType] 	= {r=r,g=g,b=b}; 
		elseif type(r) == "string" then
			colorType = r
		end
	end
	
	local color 	= colorScheme[colorType]
	local output 	= (type((select(1,...))) == "string") and ("\[DOTMonitor "..aMessage.."]") or ("\[DOTMonitor] "..aMessage)
	
	DEFAULT_CHAT_FRAME:AddMessage(output, color.r, color.g, color.b)
end)

DOTMonitor.logMessage = (function(aMessage)
	if DOTMonitor.debugMode then
		DEFAULT_CHAT_FRAME:AddMessage("\[DOTMonitor DEBUG\] "..aMessage, 1, 0, 0)
	end
end)
-- ///////////////////////////////////////////////////////////////////////////////////////


-- @ Utility Library Implementation
-- ================================================================================
DOTMonitor.utility = {} -- Utility Library

DOTMonitor.utility.capitalize = function(aString)
	return (aString:gsub("^%l", string.upper))
end

DOTMonitor.utility.getSpellID = function(aSpell)
	local spellInfo = GetSpellLink(aSpell)
	return spellInfo and string.match(spellInfo, "spell:(%d+)") or false
end

DOTMonitor.utility.getSpellName = function(aDebuff)
	return (type(aDebuff) == "string") and aDebuff or aDebuff[1]
end

DOTMonitor.utility.getAbilityTexture = function(anAblity)
	return (select(3, GetSpellInfo(anAblity)))
end

DOTMonitor.utility.getAbilitiesForPlayer = function(abilityType, aPlayer)
	local pClass, pSpec = aPlayer.info.class, aPlayer.info.spec.name
	abilityType = abilityType:gsub("^%l", string.upper)
	DOTMonitor.logMessage("Retriving "..abilityType.." for "..pSpec.." "..pClass)
	local abilityData = getglobal("DOTMonitor"..abilityType.."_"..GetLocale()) 
					 or getglobal("DOTMonitor"..abilityType.."_enUS")
	
	local abilities, effects = {}, {};
	
	for anAbility, anEffect in pairs(abilityData[pClass][pSpec]) do
		table.insert(abilities, anAbility); table.insert(effects, anEffect);
	end
	
	return {spell = abilities, effect = effects}
end

DOTMonitor.utility.frameEnabled = function(aFrame, enabled)
	if enabled 
	then aFrame:Show()
	else aFrame:Hide()
	end
end

DOTMonitor.utility.iconIntensity = function(magnitude)
	BorderTheme = {"Interface\\AddOns\\DOTMonitor\\graphics\\icon_border_white", "Interface\\AddOns\\DOTMonitor\\graphics\\icon_border_effect_over"}
	return BorderTheme[((magnitude >= 0.95 and 2) or 1)]
end