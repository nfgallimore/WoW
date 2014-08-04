if not Recount then return end
local Recount = Recount

RecountCC = LibStub("AceAddon-3.0"):NewAddon("RecountCC", "AceEvent-3.0")
local mod = RecountCC

local RL = LibStub("AceLocale-3.0"):GetLocale("Recount")
local math_floor = math.floor

-------------------------------------------------------------------------
-- LOCALES
-------------------------------------------------------------------------

local DetailTitles={}
DetailTitles.CCHow= {
	TopNames = RL["Ability Name"],
	TopCount = "",
	TopAmount = RL["Count"],
	BotNames = RL["Player/Mob Name"],
	BotMin = "",
	BotAvg = "",
	BotMax = "",
	BotAmount = RL["Count"]
}

DetailTitles.CCWho = {
	TopNames = RL["Player/Mob Name"],
	TopCount = "",
	TopAmount = RL["Count"],
	BotNames = RL["Ability Name"],
	BotMin = "",
	BotAvg = "",
	BotMax = "",
	BotAmount = RL["Count"]
}

local SN = setmetatable({}, {__index = function(t, k)
	local n = GetSpellInfo(k)
	rawset(t, k, n)
	return n
end})

local cc = {
	-- Death Knight
	47476, -- Strangulate
	49203, -- Hungering Cold
	96294, -- Chains of Ice
	108194, -- Asphyxiate
	91800, -- Gnaw
	91797, -- Monstrous Blow
	108200, -- Remorseless Winter
	-- Druid
	339, -- Entangling Roots
	102359, -- Mass Entanglement
	5211, -- Mighty Bash
	2637, -- Hibernate
	33786, -- Cyclone
	22570, -- Maim
	9005, -- Pounce
	102546, -- Pounce
	102795, -- Bear Hug
	99, -- Disorienting Roar
	113801, -- Bash (Treants in feral spec)
	16689, -- Nature's Grasp\
	-- Possibly missing Entangling Roots Treants (Balance)
	-- Missing Wild Charge's Immobilize in Bear Form
	-- Hunter
	19503, -- Scatter Shot
	19386, -- Wyvern Sting
	-- Looks wrong 1499, -- Freezing Trap
	3355, -- Freezing Trap
	128405, -- Narrow Escape
	50245, -- Pin (Crab)
	4167, -- Web (Spider)
	90327, -- Lock Jaw (Dog)
	54706, -- Venom Web Spray (Silithid)
	117526, -- Binding Shot  
	24394, -- Intimidation
	90337, -- Bad Manner (Monkey)
	50519, -- Sonic Blast (Bat)
	91644, -- Snatch (Bird of Prey)
	50541, -- Clench (Scorpid)
	1513, -- Scare Beast
	34490, -- Silencing Shot
	64803, -- Entrapment
	-- Mage
	118, -- Polymorph
	61305, -- Polymorph Black Cat
	28272, -- Polymorph Pig
	61721, -- Polymorph Rabbit
	61780, -- Polymorph Turkey
	28271, -- Polymorph Turtle
	82691, -- Ring of Frost
	31661, -- Dragon's Breath
	44572, -- Deep Freeze
	122, -- Frost Nova
	33395, -- Freeze (Frost Water Elemental)
	118271,-- Combustion
	102051, -- Frostjaw
	55021, -- Silenced Improved Counterspell
	111340, -- Ice Ward
	-- Monk
	116706, -- Disable
	119392, -- Charging Ox Wave
	119381, -- Leg Sweep
	122242, -- Clash
	120086, -- Fists of Fury
	117368, -- Grapple Weapon
	115078, -- Paralysis
	116709, -- Spear Hand Strike
	-- Paladin
	853, -- Hammer of Justice
	105593, -- Fist of Justice
	10326, -- Turn Evil
	20066, -- Repentance
	119072, -- Holy Wrath
	31935, -- Avengers Shield
	105421, -- Blinding Light
	-- Missing Glyph of Blinding Light Stun
	-- Priest
	8122, -- Psychic Scream
	9484, -- Shackle Undead
	605, -- Dominate Mind (Mind Control)
	15487, -- Silence
	64044, -- Psychic Horror
	114404, -- Void Tendril's Grasp
	113792, -- Psychic Terror
	131556, -- Sin and Punishment
	-- Rogue
	6770, -- Sap
	408, -- Kidney Shot
	2094, -- Blind
	51722, -- Dismantle
	1833, -- Cheap Shot
	115197, -- Partial Paralysis (Paralytic Poison Shiv effect)
	113953, -- Paralysis
	51722, -- Dismantle
	1776, -- Gouge
	703, -- Garrote
	-- Shaman
	76780, -- Bind Elemental
	51514, -- Hex
	63685, -- Freeze (Frost Shock)
	118905, -- Static Charge (Capacitor Totem)
	64695, -- Earthgrab
	77505, -- Earthquake
	-- Warlock
	118699, -- Fear
	5484, -- Howl of Terror
	30283, -- Shadowfury
	103131, -- Felguard: Axe Toss
	118093, -- Voidwalker: Disarm
	6358, -- Seduction
	115268, -- Mesmerize
	22703, -- Infernal Awakening
	6789, -- Mortal Coil
	24259, -- Spell Lock
	115782, -- Optical Blast
	710, -- Banish
	-- 85387, -- Aftermath (RoF Stun) (removed due to too many stuns)
	-- Warrior
	676, -- Disarm
	5246, -- Initmidating Shout
	85388, -- Throwdown
	12809, -- Concussion Blow
	107566, -- Staggering Shout
	132168, -- Shockwave
	105771, -- Warbringer (Charge Stun)
	107570, -- Storm Bolt
	118895, -- Dragon Roar
	6552, -- Pummel
	57755, -- Heroic Throw
	100, -- Charge
	-- Racials
	20549, -- War Stomp
	129597, -- Arcane Torrent
	107079, -- Quaking Palm
	-- Symbiosis
	113506, -- Cyclone
	127361, -- Bear Hug
	110693, -- Frost Nova
	126458, -- Grapple Weapon
	126449, -- Clash
	110698, -- Hammer of Justice
	113004, -- Intimidating Roar
}

local aoecc = { -- aoe cc that applies a debuff without a duration such as smoke bomb and solar beam
				-- tracked differently so a rogue doesn't get tons of CCs if people move in and out of smoke bomb
	113286, -- Symbiosis solar beam
	78675, -- solar beam
	76577, -- smoke bomb
}

local function isCC(spellID)
	for k, v in ipairs(cc) do
		if spellID == v then
			return true
		end
	end
	return false
end

local function isAoeCC(spellID) 
	for k, v in ipairs(aoecc) do
		if spellID == v then
			return true
		end
	end
	return false
end

function mod:OnEnable()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function mod:AddCC(spellID, sourceName, destName, sourceGUID, sourceFlags, destGUID, destFlags)

	-- From recount's Tracker.lua
	if not Recount.InCombat and Recount.db.profile.RecordCombatOnly then
		if (not FriendlyFire) and (Recount:InGroup(sourceFlags)) then
			Recount:PutInCombat()
		else
			return
		end
	end

	local sourceowner
	local sourceownerID
	local destowner
	local destownerID
	
   	if sourceName == nil then
		sourceName = "No One"
	end
	sourceName, sourceowner, sourceownerID = Recount:DetectPet(sourceName, sourceGUID, sourceFlags)
	destName, destowner, destownerID = Recount:DetectPet(destName, destGUID, destFlags)
	
	local srcRetention = Recount.srcRetention
	if srcRetention then
		if not Recount.db2.combatants[sourceName] then
			Recount:AddCombatant(sourceName,sourceowner,sourceGUID,sourceFlags, sourceownerID)
		end
		
		local sourceData = Recount.db2.combatants[sourceName]
		if sourceData then
			Recount:SetActive(sourceData)
			sourceData.LastFightIn=Recount.db2.FightNum
			local sourceName = sourceData.Name
			Recount:AddAmount(sourceData, "CrowdControl", 1)
			Recount:AddOwnerPetLazySyncAmount(sourceData, "CrowdControl", 1)
			local spellName = SN[spellID] or ""
			Recount:AddTableDataSum(sourceData, "CCHow", spellName, destName, 1)
			Recount:AddTableDataSum(sourceData, "CCWho", destName, spellName, 1)
		end
	end
	
	local dstRetention = Recount.dstRetention
	if dstRetention then
		if not Recount.db2.combatants[destName] then
			Recount:AddCombatant(destName,destowner,destGUID,destFlags, destownerID)
		end
		
		local destData = Recount.db2.combatants[destName]
		if destData then
			Recount:SetActive(destData)
			destData.LastFightIn=Recount.db2.FightNum
			local destName = destData.Name
			Recount:AddAmount(destData, "CrowdControlTaken", 1)
			Recount:AddOwnerPetLazySyncAmount(destData, "CrowdControlTaken", 1)
			local spellName = SN[spellID] or ""
			Recount:AddTableDataSum(destData, "CCHowTaken", spellName, sourceName, 1)
			Recount:AddTableDataSum(destData, "CCWhoTaken", sourceName, spellName, 1)
		end
	end
end

function mod:COMBAT_LOG_EVENT_UNFILTERED(_,_, event, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID, ...)
	if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" then
		if isCC(spellID) then
			mod:AddCC(spellID, sourceName, destName, sourceGUID, sourceFlags, destGUID, destFlags)
		end
	end
	if event == "SPELL_CAST_SUCCESS" then
		if isAoeCC(spellID) then -- Aoe stuff that applies an aura
			mod:AddCC(spellID, sourceName, sourceName, sourceGUID, sourceFlags, destGUID, destFlags)
		end
	end
end

function mod:DataModesCC(data, num)
	if not data then return 0 end
	if num==1 then
		return (data.Fights[Recount.db.profile.CurDataSet].CrowdControl or 0)
	else
		return (data.Fights[Recount.db.profile.CurDataSet].CrowdControl or 0), {{data.Fights[Recount.db.profile.CurDataSet].CCHow,"'s CCs",DetailTitles.CCHow}, {data.Fights[Recount.db.profile.CurDataSet].CCWho," CCed Who",DetailTitles.CCWho}}
	end
end

function mod:DataModesCCTaken(data, num)
	if not data then return 0 end
	if num==1 then
		return (data.Fights[Recount.db.profile.CurDataSet].CrowdControlTaken or 0)
	else
		return (data.Fights[Recount.db.profile.CurDataSet].CrowdControlTaken or 0), {{data.Fights[Recount.db.profile.CurDataSet].CCHowTaken,"'s CCs Taken",DetailTitles.CCHow}, {data.Fights[Recount.db.profile.CurDataSet].CCWhoTaken," CCed By",DetailTitles.CCWho}}
	end
end

function mod:TooltipFuncsCC(name, data)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	Recount:AddSortedTooltipData(RL["Top 3"].." ".."Crowd Controls",data and data.Fights[Recount.db.profile.CurDataSet] and data.Fights[Recount.db.profile.CurDataSet].CCHow,3)
	
	local dbCombatants = Recount.db2.combatants
	if Recount.db.profile.MergePets and data.Pet then
		local petindex = #data.Pet
		local cc
		while not cc and petindex > 0 do
			cc = data.Pet[petindex] and dbCombatants[data.Pet[petindex]] and dbCombatants[data.Pet[petindex]] and dbCombatants[data.Pet[petindex]].Fights and dbCombatants[data.Pet[petindex]].Fights[Recount.db.profile.CurDataSet] and dbCombatants[data.Pet[petindex]].Fights[Recount.db.profile.CurDataSet].CrowdControl
			petindex = petindex - 1
		end
			
		petindex = petindex + 1
			
		if cc and cc ~= 0 then
			cc=cc/(cc+(data.Fights[Recount.db.profile.CurDataSet].CrowdControl or 0))
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(RL["Pet"]..":",data.Pet[petindex].." ("..math_floor(cc*100+0.5).."%)",nil,nil,nil,1,1,1)
			Recount:AddSortedTooltipData(RL["Top 3"].." ".."Pet Crowd Controls",dbCombatants[data.Pet[petindex] ].Fights and dbCombatants[data.Pet[petindex] ].Fights[Recount.db.profile.CurDataSet].CCHow,3)
		end
	end
	
	GameTooltip:AddLine("<"..RL["Click for more Details"]..">",0,0.9,0)
end

function mod:TooltipFuncsCCTaken(name, data)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	Recount:AddSortedTooltipData(RL["Top 3"].." ".."Crowd Controls Taken",data and data.Fights[Recount.db.profile.CurDataSet] and data.Fights[Recount.db.profile.CurDataSet].CCHowTaken,3)
	
	local dbCombatants = Recount.db2.combatants
	if Recount.db.profile.MergePets and data.Pet then
		local petindex = #data.Pet
		local cc
		while not cc and petindex > 0 do
			cc = data.Pet[petindex] and dbCombatants[data.Pet[petindex]] and dbCombatants[data.Pet[petindex]] and dbCombatants[data.Pet[petindex]].Fights and dbCombatants[data.Pet[petindex]].Fights[Recount.db.profile.CurDataSet] and dbCombatants[data.Pet[petindex]].Fights[Recount.db.profile.CurDataSet].CrowdControlTaken
			petindex = petindex - 1
		end
			
		petindex = petindex + 1
			
		if cc and cc ~= 0 then
			cc=cc/(cc+(data.Fights[Recount.db.profile.CurDataSet].CrowdControlTaken or 0))
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(RL["Pet"]..":",data.Pet[petindex].." ("..math_floor(cc*100+0.5).."%)",nil,nil,nil,1,1,1)
			Recount:AddSortedTooltipData(RL["Top 3"].." ".."Pet Crowd Controls Taken",dbCombatants[data.Pet[petindex] ].Fights and dbCombatants[data.Pet[petindex] ].Fights[Recount.db.profile.CurDataSet].CCHowTaken,3)
		end
	end
	
	GameTooltip:AddLine("<"..RL["Click for more Details"]..">",0,0.9,0)
end

Recount:AddModeTooltip("Crowd Control",RecountCC.DataModesCC,RecountCC.TooltipFuncsCC,nil,nil,nil,nil)
Recount:AddModeTooltip("Crowd Control Taken",RecountCC.DataModesCCTaken,RecountCC.TooltipFuncsCCTaken,nil,nil,nil,nil)
