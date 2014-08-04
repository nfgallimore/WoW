local SettingsFrame, Parent
local AnnounceRaidOption, AnnounceSelfOption, AchievementOption, PrimarySpecOption, SecondarySpecOption, GearTrackOption
local ShowZeroOption, ShowMetaOption
local EvalMode = 0
local AboutText, VersionText, TitleText
local command
local announceRaid, announceSelf, achievement, primaryspec, secondaryspec, geartrack, showzero, showmeta
local Language
if GetLocale() == "enUS" then 
	Language = Localization
elseif GetLocale() == "esMX" then 
	Language = LocalizationES
else
	DEFAULT_CHAT_FRAME:AddMessage("<PvP Helper> PvP Helper will now match items for ALL locales.  However, we need people to translate the mod itself.  If you have time, copy the localization file in the PvP Helper directory and fill in the blanks for your own language.")
	Language = Localization
end
local seconds, faction, AFKPlayers, reportTime, playerIndex, inBattle = 0, 2, 0, 2, 0, false
local LastUpdate, SystemTime, LastData, LastPlayerCheck = GetTime(), GetTime(), GetTime() - 10, GetTime()
local UpdateData = GetTime() - 5
local version, verCheck, patch, lastVerCheck = "1.31", false, "4.1.0", 0
local players = {}
local Queued = 0

DEFAULT_CHAT_FRAME:AddMessage(Language.Avatar .. " " .. Language.Loaded);
DEFAULT_CHAT_FRAME:AddMessage(Language.Avatar .. " " .. Language.HelpUs);

local function Debug(text)
	DEFAULT_CHAT_FRAME:AddMessage("<PvP Helper> Debug: " .. text)
end

local function createFrame(parent, width, height, title)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetFrameStrata("HIGH")
	frame:SetWidth(width)
	frame:SetHeight(height)
	frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
	})
	frame:SetBackdropBorderColor(1, 1, 0)
	frame:SetBackdropColor(24/255, 24/255, 24/255)

	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetScript("OnMouseDown",
		function(frame)
			frame:StartMoving()
		end)
	frame:SetScript("OnMouseUp",
		function(frame)
			frame:StopMovingOrSizing()
		end)

	local CloseButton = CreateFrame("Button", nil, frame)
	CloseButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up.blp")
	CloseButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down.blp")
	CloseButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight.blp")
	CloseButton:SetWidth(20)
	CloseButton:SetHeight(20)
	CloseButton:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-2,-2)
	CloseButton:SetScript("OnClick", function(CloseButton) frame:Hide() end)

	local Title = frame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Title:SetPoint("TOPLEFT",frame,"TOPLEFT",6,-6)
	Title:SetTextColor(1.0,1.0,1.0,1.0)
	Title:SetText(title)

	frame:SetPoint("CENTER",0,0)
	frame:Hide()
	return frame
end

local function DisplayAchievement(id, TrackBool, HordeId)
	strFaction = "Alliance";
	if (UnitRace("player") == "Orc" or UnitRace("player") == "Troll" or UnitRace("player") == "Undead") then strFaction="Horde"; end
	if (UnitRace("player") == "Tauren" or UnitRace("player") == "Blood Elf" or UnitRace("player") == "Goblin") then strFaction="Horde"; end
	if (strFaction == "Horde" and HordeId ~= 0) then
		id = HordeId
	end
	IDNumber, Name, Points, Completed, Month, Day, Year, Description, Flags, Image, RewardText = GetAchievementInfo(id)
	if (Completed == false and TrackBool == 1) then
		local id1, id2, id3, id4, id5, id6, id7, id8, id9, id10 = GetTrackedAchievements()
		if (id10 ~= nil) then
			return
		end
		AddTrackedAchievement(id)
		return
	end
	RemoveTrackedAchievement(id)
end

local function AchievementTrack()
	if (achievement == true) then
		
		TrackBool = 0;
		if GetRealZoneText() == Language.AlteracValley then 
			TrackBool = 1
		end
		DisplayAchievement(218, TrackBool, 0) --[[ Alterac Valley Victory ]]--
		DisplayAchievement(219, TrackBool, 0) --[[ Alterac Valley Veteran ]]--
		DisplayAchievement(224, TrackBool, 0) --[[ Loyal Defender ]]--
		DisplayAchievement(1164, TrackBool, 0) --[[ Everything Counts ]]--
		DisplayAchievement(223, TrackBool, 0) --[[ The Sickly Gazelle ]]--
		DisplayAchievement(221, TrackBool, 0) --[[ Alterac Grave Robber ]]--
		DisplayAchievement(222, TrackBool, 0) --[[ Tower Defense ]]--
		DisplayAchievement(226, TrackBool, 0) --[[ The Alterac Blitz ]]--
		DisplayAchievement(220, TrackBool, 873) --[[ Frostwolf/Stormpike Perfection ]]--
		DisplayAchievement(582, TrackBool, 0) --[[ Alterac Valley All-Star ]]--
		DisplayAchievement(707, TrackBool, 706) --[[ Frostwolf Howler/Stormpike Battle Charger ]]--
		DisplayAchievement(709, TrackBool, 708) --[[ Hero of the Frostwolf Clan/Stormpike Guard ]]--
		DisplayAchievement(1166, TrackBool, 0) --[[ To the Looter go the Spoils ]]--
		if (showmeta == true) then
			DisplayAchievement(1169, TrackBool, 1168) --[[ Master of Alterac Valley ]]--
		end
		TrackBool = 0;
		if GetRealZoneText() == Language.ArathiBasin then 
			TrackBool = 1
		end
		DisplayAchievement(154, TrackBool, 0) --[[ Arathi Basin Victory ]]--
		DisplayAchievement(155, TrackBool, 0) --[[ Arathi Basin Veteran ]]--
		DisplayAchievement(159, TrackBool, 0) --[[ Let's Get This Done ]]--
		DisplayAchievement(165, TrackBool, 0) --[[ Arathi Basin Perfection ]]--
		DisplayAchievement(158, TrackBool, 0) --[[ Me and the Cappin Make It Happen ]]--
		DisplayAchievement(73, TrackBool, 0) --[[ Disgracin the Basin ]]--
		DisplayAchievement(1153, TrackBool, 0) --[[ Overly Offensive ]]--
		DisplayAchievement(157, TrackBool, 0) --[[ To the Rescue! ]]--
		DisplayAchievement(161, TrackBool, 0) --[[ Resilient Victory ]]--
		DisplayAchievement(156, TrackBool, 0) --[[ Territorial Dominance ]]--
		DisplayAchievement(162, TrackBool, 0) --[[ We Had It All Along ]]--
		DisplayAchievement(711, TrackBool, 710) --[[ Knight of Arathor/The Defiler ]]--
		DisplayAchievement(583, TrackBool, 0) --[[ Arathi Basin All Star ]]--
		DisplayAchievement(584, TrackBool, 0) --[[ Arathi Basin Assassin ]]--
		if (showmeta == true) then
			DisplayAchievement(1169, TrackBool, 1170) --[[ Master of Arathi Basin ]]--
		end

		TrackBool = 0;
		if GetRealZoneText() == Language.EyeOfTheStorm then 
			TrackBool = 1
		end
		DisplayAchievement(208, TrackBool, 0) --[[ Eye of the Storm Victory ]]--
		DisplayAchievement(209, TrackBool, 0) --[[ Eye of the Storm Veteran ]]--
		DisplayAchievement(212, TrackBool, 0) --[[ Storm Capper ]]--
		DisplayAchievement(587, TrackBool, 0) --[[ Stormy Assassin ]]--
		DisplayAchievement(213, TrackBool, 0) --[[ Stormtrooper ]]--
		DisplayAchievement(1258, TrackBool, 0) --[[ Take a Chill Pill ]]--
		DisplayAchievement(783, TrackBool, 0) --[[ The Perfect Storm ]]--
		DisplayAchievement(784, TrackBool, 0) --[[ Eye of the Storm Domination ]]--
		DisplayAchievement(214, TrackBool, 0) --[[ Flurry ]]--
		DisplayAchievement(216, TrackBool, 0) --[[ Bound for Glory ]]--
		DisplayAchievement(233, TrackBool, 0) --[[ Bloodthirsty Berserker ]]--
		DisplayAchievement(211, TrackBool, 0) --[[ Storm Glory ]]--
		if (showmeta == true) then
			DisplayAchievement(1171, TrackBool, 0) --[[ Master of Eye of the Storm ]]--
		end

		TrackBool = 0;
		if GetRealZoneText() == Language.StrandOfTheAncients then 
			TrackBool = 1
		end
		DisplayAchievement(1308, TrackBool, 0) --[[ Strand of the Ancients Victory ]]--
		DisplayAchievement(1309, TrackBool, 0) --[[ Strand of the Ancients Veteran ]]--
		DisplayAchievement(2192, TrackBool, 0) --[[ Not Even a Scratch ]]--
		DisplayAchievement(1757, TrackBool, 0) --[[ Defense of the Ancients ]]--
		DisplayAchievement(1764, TrackBool, 0) --[[ Drop it! ]]--
		DisplayAchievement(2191, TrackBool, 0) --[[ Ancient Courtyard Protector ]]--
		DisplayAchievement(1310, TrackBool, 0) --[[ Storm the Beach ]]--
		DisplayAchievement(1766, TrackBool, 0) --[[ Ancient Protector ]]--
		DisplayAchievement(2190, TrackBool, 0) --[[ Drop it now! ]]--
		DisplayAchievement(1765, TrackBool, 0) --[[ Steady Hands ]]--
		DisplayAchievement(1761, TrackBool, 0) --[[ The Dapper Sapper ]]--
		DisplayAchievement(2193, TrackBool, 0) --[[ Explosives Expert ]]--
		DisplayAchievement(1763, TrackBool, 0) --[[ Artillery Veteran ]]--
		DisplayAchievement(2189, TrackBool, 0) --[[ Artillery Expert ]]--
		if (showmeta == true) then
			DisplayAchievement(2194, TrackBool, 2195) --[[ Master of Strand of the Ancients ]]--
		end

		TrackBool = 0
		if GetRealZoneText() == Language.IsleOfConquest then 
			TrackBool = 1
		end
		DisplayAchievement(3776, TrackBool, 0) --[[ Isle of Conquest Victory ]]--
		DisplayAchievement(3777, TrackBool, 0) --[[ Isle of Conquest Veteran ]]--
		DisplayAchievement(4177, TrackBool, 3851) --[[ Mine! ]]--
		DisplayAchievement(3854, TrackBool, 0) --[[ Back Door Man ]]--
		DisplayAchievement(3845, TrackBool, 0) --[[ Isle of Conquest All-Star ]]--
		DisplayAchievement(3847, TrackBool, 0) --[[ Four Car Garage ]]--
		DisplayAchievement(3848, TrackBool, 0) --[[ A-Bomb-Inable ]]--
		DisplayAchievement(3849, TrackBool, 0) --[[ A-Bomb-Ination ]]--
		DisplayAchievement(3850, TrackBool, 0) --[[ Mowed Down ]]--
		DisplayAchievement(3852, TrackBool, 0) --[[ Cut the Blue Wire No the Red One! ]]--
		DisplayAchievement(3853, TrackBool, 0) --[[ All Over the Isle ]]--
		DisplayAchievement(3856, TrackBool, 4256) --[[ Demolition Derby ]]--
		DisplayAchievement(3855, TrackBool, 0) --[[ Glaive Grave ]]--
		if (showmeta == true) then
			DisplayAchievement(3957, TrackBool, 3857) --[[ Master of Isle of Conquest ]]--
		end

		TrackBool = 0;
		if GetRealZoneText() == Language.WarsongGulch then 
			TrackBool = 1
		end
		DisplayAchievement(166, TrackBool, 0) --[[ Warsong Gulch Victory ]]--
		DisplayAchievement(167, TrackBool, 0) --[[ Warsong Gulch Veteran ]]--
		DisplayAchievement(199, TrackBool, 0) --[[ Capture the Flag ]]--
		DisplayAchievement(200, TrackBool, 0) --[[ Persistent Defender ]]--
		DisplayAchievement(872, TrackBool, 0) --[[ Frenzied Defender ]]--
		DisplayAchievement(206, TrackBool, 1252) --[[ Supreme Defender ]]--
		DisplayAchievement(168, TrackBool, 0) --[[ Warsong Gulch Perfection ]]--
		DisplayAchievement(201, TrackBool, 0) --[[ Warsong Expedience ]]--
		DisplayAchievement(204, TrackBool, 0) --[[ Ironman ]]--
		DisplayAchievement(713, TrackBool, 712) --[[ Warsong Outrider, Silverwing Sentinel ]]--
		DisplayAchievement(1259, TrackBool, 0) --[[ Not So Fast ]]--
		DisplayAchievement(203, TrackBool, 1251) --[[ Not In My House ]]--
		DisplayAchievement(1502, TrackBool, 0) --[[ Quick Cap ]]--
		DisplayAchievement(207, TrackBool, 0) --[[ Save the Day ]]--
		if (showmeta == true) then
			DisplayAchievement(1173, TrackBool, 1172) --[[ Master of Warsong Gulch ]]--
		end

		TrackBool = 0;
		if GetRealZoneText() == Language.BattleForGilneas then 
			TrackBool = 1
		end
		DisplayAchievement(5245, TrackBool, 0)	--[[ Battle for Gilneas Victory ]]--
		DisplayAchievement(5246, TrackBool, 0)	--[[ Battle for Gilneas Veteran ]]--
		DisplayAchievement(5247, TrackBool, 0)	--[[ Battle for Gilneas Perfection ]]--
		DisplayAchievement(5248, TrackBool, 0)	--[[ Bustin' Caps to Make It Haps ]]--
		DisplayAchievement(5249, TrackBool, 0)	--[[ Battle for Gilneas Victory ]]--
		DisplayAchievement(5250, TrackBool, 0)	--[[ Out of the Fog ]]--
		DisplayAchievement(5251, TrackBool, 0)	--[[ Not Your Average PUG'er ]]--
		DisplayAchievement(5252, TrackBool, 0)	--[[ Don't Get Cocky Kid ]]--
		DisplayAchievement(5253, TrackBool, 0)	--[[ Full Coverage ]]--
		DisplayAchievement(5254, TrackBool, 0)	--[[ Newbs to Plowshares ]]--
		DisplayAchievement(5255, TrackBool, 0)	--[[ Jugger Not ]]--
		DisplayAchievement(5262, TrackBool, 0)	--[[ Double Rainbow ]]--
		DisplayAchievement(5256, TrackBool, 0)	--[[ Battle for Gilneas All-Star ]]--
		DisplayAchievement(5257, TrackBool, 0)	--[[ Battle for Gilneas Assassin ]]--
		if (showmeta == true) then
			DisplayAchievement(5258, TrackBool, 0)	--[[ Master of the Battle for Gilneas ]]--
		end
		
		TrackBool = 0;
		if GetRealZoneText() == Language.TwinPeaks then 
			TrackBool = 1
		end
		DisplayAchievement(5208, TrackBool, 0)	--[[ Twin Peaking ]]--
		DisplayAchievement(5209, TrackBool, 0)	--[[ Twin Peaks Veteran ]]--
		DisplayAchievement(5210, TrackBool, 0)	--[[ Two Timer ]]--
		DisplayAchievement(5211, TrackBool, 0)	--[[ Top Defender ]]--
		DisplayAchievement(5213, TrackBool, 5214)	--[[ Soaring Spirits ]]--
		DisplayAchievement(5215, TrackBool, 0)	--[[ Twin Peaks Perfection ]]--
		DisplayAchievement(5216, TrackBool, 0)	--[[ Peak Speed ]]--
		DisplayAchievement(5226, TrackBool, 5227)	--[[ Cloud Nine ]]--
		DisplayAchievement(5229, TrackBool, 5228)	--[[ Wild Hammering / Drag a Maw ]]--
		DisplayAchievement(5219, TrackBool, 5220)	--[[ I'm In The White/Black Lodge ]]--
		DisplayAchievement(5221, TrackBool, 5222)	--[[ Fire. Walk With Me ]]--
		DisplayAchievement(5231, TrackBool, 5552)	--[[ Double Jeopardy ]]--
		if (showmeta == true) then
			DisplayAchievement(5223, TrackBool, 5259)	--[[ Master of Twin Peaks ]]--
		end

	end
end

local function UpdateSettings()
	if AnnounceRaidOption:GetChecked() then
		announceRaid = true
	else
		announceRaid = false
	end

	if AnnounceSelfOption:GetChecked() then
		announceSelf = true
	else
		announceSelf = false
	end
	if AchievementOption:GetChecked() then
		achievement = true
		AchievementTrack()
	else
		achievement = false
	end
	if PrimarySpecOption:GetChecked() then
		primaryspec = true
	else
		primaryspec = false
	end
	if SecondarySpecOption:GetChecked() then
		secondaryspec = true
	else
		secondaryspec = false
	end
	if GearTrackOption:GetChecked() then
		geartrack = true
	else
		geartrack = false
	end
	if ShowMetaOption:GetChecked() then
		showmeta = true
	else
		showmeta = false
	end
	if ShowZeroOption:GetChecked() then
		showzero = true
	else
		showzero = false
	end


	AnnounceRaid = announceRaid
	AnnounceSelf = announceSelf
	Achievement = achievement
	PrimarySpec = primaryspec
	SecondarySpec = secondaryspec
	GearTrack = geartrack
	ShowMeta = showmeta
	ShowZero = showzero
end

local function createCheckBox(parent, x, y, text)
	local checkBox = CreateFrame("CheckButton", nil, parent)
	checkBox:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up.blp")
	checkBox:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	checkBox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
	checkBox:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
	checkBox:SetWidth(20)
	checkBox:SetHeight(20)
	checkBox:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
	})
	checkBox:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	checkBox:SetScript("OnClick", function()
		if checkBox:GetChecked() then
			checkBox:SetChecked(true)
		else
			checkBox:SetChecked(false)
		end
		UpdateSettings()
	end)

	local checkBoxText = checkBox:CreateFontString(nil,"OVERLAY","GameFontNormal")
	checkBoxText:SetPoint("TOPLEFT", checkBox, "TOPLEFT", 26, -4)
	checkBoxText:SetTextColor(1, 1, 1, 1)
	checkBoxText:SetText(text)

	return checkBox
end

local function createButton(parent, x, y, text)
	local Button = CreateFrame("Button", nil, parent)
	Button:SetWidth(140)
	Button:SetHeight(24)
	Button:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up.blp")
	Button:GetNormalTexture():SetTexCoord(0, .625, 0, .7)
	Button:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	Button:GetPushedTexture():SetTexCoord(0, .625, 0, .7)
	Button:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
	Button:GetHighlightTexture():SetTexCoord(0, .625, 0, .7)
	Button:SetPoint("TOP", parent, "TOP", x, y)
	Button:SetScript("OnClick", function()
		phase1()
	end)
	local ButtonText = Button:CreateFontString(nil,"OVERLAY","GameFontNormal")
	ButtonText:SetPoint("CENTER", Button, "CENTER", 0, 0)
	ButtonText:SetTextColor(1, 1, 1, 1)
	ButtonText:SetText(text)
	
	return Button
end


function Player(name, x, y, damage, healing, warning, raidAnnounced)        										-- Player object
	return {name = name, x = x, y = y, damage = damage, healing = healing, warning = warning, raidAnnounced = raidAnnounced}
end

local function checkPlayer(target)
	if not (GetBattlefieldScore(target) == nil) then
		local Name, v2, v3, v4, v5, playerFaction, v7, v8, v9, v10, playerDamage, playerHealing = GetBattlefieldScore(target)
		local X, Y = GetPlayerMapPosition(Name)

		X = floor(X * 100)
		Y = floor(Y * 100)

		local newPlayer = true
		local report = true
		for k = 1, #players do
			LastPlayerUpdate = SystemTime
			if UnitIsConnected(Name) == nil then											-- Unit is disconnected, do nothing
				newPlayer = false
			elseif Name == players[k].name then	
				-- Update existing player data
				newPlayer = false
				if players[k].x == X and players[k].y == Y then							-- Player in same location
					if GetRealZoneText() == Language.WarsongGulch then
						local factionIndex = 1
						if faction == 0 then
							factionIndex = 2
						end

						local v1, flagStatus = GetWorldStateUIInfo(factionIndex)
						if flagStatus == 1 then											-- Faction flag at base
							if faction == 1 and X > 46 and Y > 10 and X < 60 and Y < 20 then		-- Alliance defending flag
								report = false
							elseif faction == 0 and X > 45 and Y > 82 and X < 56 and Y < 94 then	-- Horde defending flag
								report = false
							end
						elseif flagStatus == 2 then										-- Faction flag taken
							for i=1, GetNumBattlefieldFlagPositions() do
								local flagX, flagY, flagName = GetBattlefieldFlagPosition(i)
								flagX = floor(flagX * 100)
								flagY = floor(flagY * 100)

								if X > flagX - 3 and Y > flagY - 4 and X < flagX + 3 and Y < flagY + 4 then		-- Player is nearby a flag
									report = false
								end
							end
						end
					elseif GetRealZoneText() == Language.TwinPeaks then
						local factionIndex = 1
						if faction == 0 then
							factionIndex = 2
						end

						local v1, flagStatus = GetWorldStateUIInfo(factionIndex)
						if flagStatus == 1 then											-- Faction flag at base
							if faction == 1 and X > 56 and Y > 12 and X < 65 and Y < 25 then		-- Alliance defending flag
								report = false
							elseif faction == 0 and X > 45 and Y > 80 and X < 50 and Y < 89 then	-- Horde defending flag
								report = false
							end
						elseif flagStatus == 2 then										-- Faction flag taken
							for i=1, GetNumBattlefieldFlagPositions() do
								local flagX, flagY, flagName = GetBattlefieldFlagPosition(i)
								flagX = floor(flagX * 100)
								flagY = floor(flagY * 100)

								if X > flagX - 3 and Y > flagY - 4 and X < flagX + 3 and Y < flagY + 4 then		-- Player is nearby a flag
									report = false
								end
							end
						end
					elseif GetRealZoneText() == Language.ArathiBasin then
						for i=1, GetNumMapLandmarks(), 1 do
							local textureIndex, iconX, iconY = select(3, GetMapLandmarkInfo(i))
							iconX = floor(iconX * 100)
							iconY = floor(iconY * 100)

							if faction == 1 then																													-- Alliance Bases
								if (textureIndex == 37 or textureIndex == 38) and X > iconX - 5 and Y > iconY - 7 and X < iconX + 5 and Y < iconY + 7 then		-- Player is nearby assaulted/controlled Stables
									report = false
								elseif (textureIndex == 17 or textureIndex == 18) and X > iconX - 5 and Y > iconY - 7 and X < iconX + 5 and Y < iconY + 7 then	-- Player is nearby assaulted/controlled Mine
									report = false
								elseif (textureIndex == 22 or textureIndex == 23) and X > iconX - 5 and Y > iconY - 7 and X < iconX + 5 and Y < iconY + 7 then	-- Player is nearby assaulted/controlled Lumber Mill
									report = false
								elseif (textureIndex == 27 or textureIndex == 28) and X > iconX - 5 and Y > iconY - 7 and X < iconX + 5 and Y < iconY + 7 then	-- Player is nearby assaulted/controlled Blacksmith
									report = false
								elseif (textureIndex == 32 or textureIndex == 33) and X > iconX - 5 and Y > iconY - 7 and X < iconX + 5 and Y < iconY + 7 then	-- Player is nearby assaulted/controlled Farm
									report = false
								end
							elseif faction == 0 then																												-- Horde Bases
								if (textureIndex == 39 or textureIndex == 40) and X > iconX - 5 and Y > iconY - 7 and X < iconX + 5 and Y < iconY + 7 then		-- Player is nearby assaulted/controlled Stables
									report = false
								elseif (textureIndex == 19 or textureIndex == 20) and X > iconX - 5 and Y > iconY - 7 and X < iconX + 5 and Y < iconY + 7 then	-- Player is nearby assaulted/controlled Mine
									report = false
								elseif (textureIndex == 24 or textureIndex == 25) and X > iconX - 5 and Y > iconY - 7 and X < iconX + 5 and Y < iconY + 7 then	-- Player is nearby assaulted/controlled Lumber Mill
									report = false
								elseif (textureIndex == 29 or textureIndex == 30) and X > iconX - 5 and Y > iconY - 7 and X < iconX + 5 and Y < iconY + 7 then	-- Player is nearby assaulted/controlled Blacksmith
									report = false
								elseif (textureIndex == 34 or textureIndex == 35) and X > iconX - 5 and Y > iconY - 7 and X < iconX + 5 and Y < iconY + 7 then	-- Player is nearby assaulted/controlled Farm
									report = false
								end
							end
						end
					elseif GetRealZoneText() == Language.AlteracValley then
						for i=1, GetNumMapLandmarks(), 1 do
							local textureIndex, iconX, iconY = select(3, GetMapLandmarkInfo(i))
							iconX = floor(iconX * 100)
							iconY = floor(iconY * 100)
							if faction == 1 then																													-- Alliance Bases
								if (textureIndex == 9 or textureIndex == 11) and X > iconX - 2 and Y > iconY - 3 and X < iconX + 2 and Y < iconY + 3 then			-- Player is nearby assaulted/controlled Tower
									report = false
								elseif (textureIndex == 4 or textureIndex == 15) and X > iconX - 2 and Y > iconY - 3 and X < iconX + 2 and Y < iconY + 3 then	-- Player is nearby assaulted/controlled Graveyard
									report = false
								elseif textureIndex == 3 and X > iconX - 3 and Y > iconY - 5 and X < iconX + 3 and Y < iconY + 5 then							-- Player is nearby controlled Mine
									report = false
								end
							elseif faction == 0 then																												-- Horde Bases
								if (textureIndex == 10 or textureIndex == 12) and X > iconX - 2 and Y > iconY - 3 and X < iconX + 2 and Y < iconY + 3 then		-- Player is nearby assaulted/controlled Tower
									report = false
								elseif (textureIndex == 13 or textureIndex == 14) and X > iconX - 2 and Y > iconY - 3 and X < iconX + 2 and Y < iconY + 3 then	-- Player is nearby assaulted/controlled Graveyard
									report = false
								elseif textureIndex == 3 and X > iconX - 3 and Y > iconY - 5 and X < iconX + 3 and Y < iconY + 5 then							-- Player is nearby controlled Mine
									report = false
								end
							end
						end
					elseif GetRealZoneText() == Language.BattleForGilneas then
						local textureIndex, iconX, iconY = select(3, GetMapLandmarkInfo(1))
						if X > 31 and X < 38 and Y > 59 and Y < 66 then
							if faction == 1 and (textureIndex == 9 or textureIndex == 11) then report = false; end
							if faction == 2 and (textureIndex == 10 or textureIndex == 12) then report = false; end
						end
						local textureIndex, iconX, iconY = select(3, GetMapLandmarkInfo(2))
						if X > 56 and X < 63 and Y > 36 and Y < 43 then
							if faction == 1 and (textureIndex == 17 or textureIndex == 18) then report = false; end
							if faction == 2 and (textureIndex == 19 or textureIndex == 20) then report = false; end
						end
						local textureIndex, iconX, iconY = select(3, GetMapLandmarkInfo(3))
						if X > 57 and X < 64 and Y > 68 and Y < 75 then
							if faction == 1 and (textureIndex == 27 or textureIndex == 28) then report = false; end
							if faction == 2 and (textureIndex == 29 or textureIndex == 30) then report = false; end
						end
					elseif GetRealZoneText() == Language.EyeOfTheStorm then
						local factionIndex = 1
						if faction == 0 then
							factionIndex = 2
						end

						local v1, flagStatus = GetWorldStateUIInfo(factionIndex)
						if flagStatus == 1 then											-- Flag at center
							if X > 43 and Y > 41 and X < 53 and Y < 55 then
								report = false
							end
						elseif flagStatus == 2 then
							for i=1, GetNumBattlefieldFlagPositions() do
								local flagX, flagY, flagName = GetBattlefieldFlagPosition(i)
								flagX = floor(flagX * 100)
								flagY = floor(flagY * 100)
								if X > flagX - 3 and Y > flagY - 4 and X < flagX + 3 and Y < flagY + 4 then		-- Player is nearby a flag
									report = false
								end
							end
						end
						for i=1, GetNumMapLandmarks(), 1 do
							local iconName, v2, textureIndex, iconX, iconY = GetMapLandmarkInfo(i)
							iconX = floor(iconX * 100)
							iconY = floor(iconY * 100)

							if faction == 1 then																													-- Alliance Towers
								if (textureIndex == 6 or textureIndex == 11) and X > iconX - 5 and Y > iconY - 7 and X < iconX + 5 and Y < iconY + 7 then			-- Player is nearby assaulted/controlled Tower
									report = false
								end
							elseif faction == 0 then																												-- Horde Towers
								if (textureIndex == 6 or textureIndex == 10) and X > iconX - 5 and Y > iconY - 7 and X < iconX + 5 and Y < iconY + 7 then			-- Player is nearby assaulted/controlled Tower
									report = false
								end
							end
						end
					elseif GetRealZoneText() == Language.StrandOfTheAncients then
						for i=1, GetNumMapLandmarks(), 1 do
							local textureIndex, iconX, iconY = select(3, GetMapLandmarkInfo(i))
							iconX = floor(iconX * 100)
							iconY = floor(iconY * 100)

							if X > iconX - 3 and Y > iconY - 4 and X < iconX + 3 and Y < iconY + 4 then															-- Player is nearby Gate
								report = false
							end
						end
					elseif GetRealZoneText() == Language.IsleOfConquest then
						if UnitInVehicle(Name) == 1 then
							report = false
						end
						for i=1, GetNumMapLandmarks(), 1 do
							local textureIndex, iconX, iconY = select(3, GetMapLandmarkInfo(i))
							iconX = floor(iconX * 100)
							iconY = floor(iconY * 100)

							if (textureIndex == 77 or textureIndex == 78) and X > iconX - 2 and Y > iconY - 3 and X < iconX + 2 and Y < iconY + 3 then			-- Player is nearby healthy/damaged Red Gate
								report = false
							elseif (textureIndex == 80 or textureIndex == 81) and X > iconX - 2 and Y > iconY - 3 and X < iconX + 2 and Y < iconY + 3 then		-- Player is nearby healthy/damaged Blue Gate
								report = false
							end

							if faction == 1 then																													-- Alliance Bases
								if (textureIndex == 136 or textureIndex == 137) and X > 45 and Y > 46 and X < 55 and Y < 60 then		-- Player is nearby assaulted/controlled Workshop
									report = false
								elseif (textureIndex == 141 or textureIndex == 142) and X > 53 and Y > 44 and X < 63 and Y < 58 then	-- Player is nearby assaulted/controlled Hangar
									report = false
								elseif (textureIndex == 146 or textureIndex == 147) and X > 28 and Y > 49 and X < 38 and Y < 63 then	-- Player is nearby assaulted/controlled Docks
									report = false
								elseif (textureIndex == 151 or textureIndex == 152) and X > 30 and Y > 18 and X < 40 and Y < 32 then	-- Player is nearby assaulted/controlled Refinery
									report = false
								elseif (textureIndex == 17 or textureIndex == 18) and X > 59 and Y > 76 and X < 69 and Y < 90 then	-- Player is nearby assaulted/controlled Quarry
									report = false
								elseif X > 46 and Y > 70 and X < 52 and Y < 78 then																				-- Player is nearby West Turret Tower
									report = false
								elseif X > 50 and Y > 70 and X < 56 and Y < 78 then																				-- Player is nearby East Turret Tower
									report = false
								end
							elseif faction == 0 then																												-- Horde Bases
								if (textureIndex == 138 or textureIndex == 139) and X > 45 and Y > 46 and X < 55 and Y < 60 then		-- Player is nearby assaulted/controlled Workshop
									report = false
								elseif (textureIndex == 143 or textureIndex == 144) and X > 53 and Y > 44 and X < 63 and Y < 58 then	-- Player is nearby assaulted/controlled Hangar
									report = false
								elseif (textureIndex == 148 or textureIndex == 149) and X > 28 and Y > 49 and X < 38 and Y < 63 then	-- Player is nearby assaulted/controlled Docks
									report = false
								elseif (textureIndex == 153 or textureIndex == 154) and X > 30 and Y > 18 and X < 40 and Y < 32 then	-- Player is nearby assaulted/controlled Refinery
									report = false
								elseif (textureIndex == 19 or textureIndex == 20) and X > 59 and Y > 76 and X < 69 and Y < 90 then	-- Player is nearby assaulted/controlled Quarry
									report = false
								elseif X > 42 and Y > 27 and X < 48 and Y < 35 then																				-- Player is nearby West Turret Tower
									report = false
								elseif X > 48 and Y > 27 and X < 54 and Y < 35 then																				-- Player is nearby East Turret Tower
									report = false
								end
							end
						end
					end
				else																		-- Player is not in same location
					players[k].x = X
					players[k].y = Y
					report = false
				end
				if players[k].name == Name then											-- Check Damage and Healing
					if playerDamage > players[k].damage then
						players[k].damage = playerDamage
						report = false
					end
					if playerHealing > players[k].healing then
						players[k].healing = playerHealing
						report = false
					end
				end

				if report == true then														-- Report a player
					if players[k].warning == reportTime then										-- Report only if previously marked suspicious
						ReportPlayerIsPVPAFK(Name)
						if announceRaid == true and players[k].raidAnnounced < SystemTime - 600 then		-- Announce to raid chat only if not recently announced
							SendChatMessage(Language.Avatar .. Name .. Language.Report, "BATTLEGROUND", nil, nil)
							players[k].raidAnnounced = GetTime()
						end
						players[k].warning = 0
						AFKPlayers = AFKPlayers + 1
					else
						players[k].warning = players[k].warning + 1							-- Mark a player as suspicious first
					end
				else																		-- if previously marked suspicious, clear it
					players[k].warning = 0
				end
			end
		end
		if newPlayer == true and playerFaction == faction then									-- New Player
			players[#players + 1] = Player(Name, X, Y, 0, 0, 0, 0)
		end
	end
end

function zcna()
	SetMapToCurrentZone()
	if select(2, IsInInstance()) == "pvp" then
		LastUpdate = SystemTime
		LastData = SystemTime - 10
		if (inBattle == false) then
			AchievementTrack()
		end
		inBattle = true
	else
		wipe(players)
		playerIndex = 0
		if (inBattle == true) then
			AchievementTrack()
		end
		inBattle = false
	end
end

local function UpdateFrame(elapsed)
	if inBattle == false then
		if GetBattlefieldTimeWaited(1) + GetBattlefieldTimeWaited(2) + GetBattlefieldTimeWaited(3) > 0 then
			if Queued == 0 then
				Queued = 1
				if GetCombatRating(16) == 0 and GearTrack == true then
					PlaySoundFile("Sound\\interface\\RaidWarning.wav")
					RaidNotice_AddMessage(RaidWarningFrame, Language.WrongGear, { r = 1, g = 0, b = 0 })
				end
				if (GetActiveTalentGroup() == 1 and primaryspec == true) or (GetActiveTalentGroup() == 2 and secondaryspec == true) then
					PlaySoundFile("Sound\\interface\\RaidWarning.wav")
					RaidNotice_AddMessage(RaidWarningFrame, Language.WrongSpec, { r = 1, g = 0, b = 0 })
				end
			end
		else
			if Queued == 1 then
				Queued = 0
			end		
		end
	end
	if (playerIndex > 0 and SystemTime > LastPlayerCheck + .2 and inBattle == true) then					-- check a player every so often to reduce lag
		checkPlayer(playerIndex)
		playerIndex = playerIndex + 1
		if (playerIndex == GetNumBattlefieldScores()) then
			playerIndex = 0
			if announceSelf == true then
				if (showzero == true or AFKPlayers > 0) then
					DEFAULT_CHAT_FRAME:AddMessage(Language.Avatar .. Language.Check .. AFKPlayers .. Language.Reported)
				end
			end
		end
		LastPlayerCheck = SystemTime
	end
	if (SystemTime > LastUpdate + 60 and inBattle == true) then
		if faction == 2 then						-- Determine faction
			for m = 1, GetNumBattlefieldScores() do
				local Name, v2, v3, v4, v5, playerFaction = GetBattlefieldScore(m)
				if UnitName("player") == Name then
					faction = playerFaction
				end
			end
		end
		AFKPlayers = 0
		playerIndex = 1
		LastUpdate = SystemTime
	elseif (SystemTime > LastData + 60 and inBattle == true) then				-- update Battleground stats
		RequestBattlefieldScoreData()
		LastData = SystemTime
	end

	--[[ Speedy's Spec Tracker ]]--
	timeInQueue = GetBattlefieldTimeWaited(1);
	if GetBattlefieldTimeWaited(2) > timeInQueue then
		timeInQueue = GetBattlefieldTimeWaited(2);
	end		
	if GetBattlefieldTimeWaited(3) > timeInQueue then
		timeInQueue = GetBattlefieldTimeWaited(3);
	end
	if (timeInQueue == 0) then
		Queued = 0
	end
	if (timeInQueue > 0 and Queued == 0) then
		Queued = 1
		if (GetActiveTalentGroup() == 1 and PrimarySpec == true) then
			PlaySoundFile("Sound\\interface\\RaidWarning.wav")
			RaidNotice_AddMessage(RaidWarningFrame, Language.WrongSpec, { r = 1, g = 0, b = 0 })
		end
		if (GetActiveTalentGroup() == 2 and SecondarySpec == true) then
			PlaySoundFile("Sound\\interface\\RaidWarning.wav")
			RaidNotice_AddMessage(RaidWarningFrame, Language.WrongSpec, { r = 1, g = 0, b = 0 })
		end
	end

	--[[ End Speedy's Spec Tracker ]]--


	SystemTime = GetTime()
end

do
	local Patch = GetBuildInfo()
	if patch == Patch then
		-- Main Frame

		Parent = CreateFrame("Frame", "PvPHelperFrame", UIParent)
		Parent:Show()

		-- Settings Frame

		SettingsFrame = createFrame(UIParent, 900, 389, nil)
		SettingsFrame:SetToplevel(true)

		AnnounceSelfOption = createCheckBox(SettingsFrame, 30, -92, Language.AnnounceSelf)
		AnnounceRaidOption = createCheckBox(SettingsFrame, 30, -114, Language.AnnounceRaid)
		ShowZeroOption = createCheckBox(SettingsFrame, 30, -136, Language.ShowZero)
		AchievementOption = createCheckBox(SettingsFrame, 30, -158, Language.Achievement)
		ShowMetaOption = createCheckBox(SettingsFrame, 30, -180, Language.ShowMeta)
		PrimarySpecOption = createCheckBox(SettingsFrame, 30, -202, Language.PrimarySpec)
		SecondarySpecOption = createCheckBox(SettingsFrame, 30, -224, Language.SecondarySpec)
		GearTrackOption = createCheckBox(SettingsFrame, 30, -246, Language.GearTrack)

		TitleText = SettingsFrame:CreateFontString(nil,"OVERLAY")
		TitleText:SetFont("Fonts\\FRIZQT__.TTF", 128, "NORMAL")
		TitleText:SetPoint("TOP", SettingsFrame, "TOP", 0, -20)
		TitleText:SetTextColor(1, 1, 0, 1)
		TitleText:SetText(Language.SettingsTitle)

		ErrorText = SettingsFrame:CreateFontString(nil, "OVERLAY")
		ErrorText:SetFont("Fonts\\FRIZQT__.TTF", 14, "NORMAL")
		ErrorText:SetPoint("TOP", SettingsFrame, "TOP", 0, -100)
		ErrorText:SetTextColor(1, 0, 0, 1)
		ErrorText:SetText("")

		EvalButton = createButton(SettingsFrame, 0, -310, " " .. Language.GearEvaluation)
		EvalOffButton = createButton(SettingsFrame, 0, -310, " " .. Language.Options)
		EvalOffButton:Hide()
	
		AboutText = SettingsFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
		AboutText:SetPoint("BOTTOM", SettingsFrame, "BOTTOM", 0, 10)
		AboutText:SetTextColor(1, 1, 0, 1)
		AboutText:SetText(Language.DesignedBy)

		Text011 = SettingsFrame:CreateFontString(nil, "OVERLAY")
		Text011:SetFont("Fonts\\FRIZQT__.TTF", 11, "NORMAL")
		Text011:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 32, -132)
		Text011:SetTextColor(1, 1, 0, 1)
		Text012 = SettingsFrame:CreateFontString(nil, "OVERLAY")
		Text012:SetFont("Fonts\\FRIZQT__.TTF", 11, "NORMAL")
		Text012:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 32, -148)
		Text012:SetTextColor(1, 1, 0, 1)
		Text013 = SettingsFrame:CreateFontString(nil, "OVERLAY")
		Text013:SetFont("Fonts\\FRIZQT__.TTF", 11, "NORMAL")
		Text013:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 32, -164)
		Text013:SetTextColor(1, 1, 0, 1)
		
		Text021 = SettingsFrame:CreateFontString(nil, "OVERLAY")
		Text021:SetFont("Fonts\\FRIZQT__.TTF", 11, "NORMAL")
		Text021:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 32, -198)
		Text021:SetTextColor(1, 1, 0, 1)
		Text022 = SettingsFrame:CreateFontString(nil, "OVERLAY")
		Text022:SetFont("Fonts\\FRIZQT__.TTF", 11, "NORMAL")
		Text022:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 32, -214)
		Text022:SetTextColor(1, 1, 0, 1)
		Text023 = SettingsFrame:CreateFontString(nil, "OVERLAY")
		Text023:SetFont("Fonts\\FRIZQT__.TTF", 11, "NORMAL")
		Text023:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 32, -230)
		Text023:SetTextColor(1, 1, 0, 1)
		
		Text031 = SettingsFrame:CreateFontString(nil, "OVERLAY")
		Text031:SetFont("Fonts\\FRIZQT__.TTF", 11, "NORMAL")
		Text031:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 32, -262)
		Text031:SetTextColor(1, 1, 0, 1)
		Text032 = SettingsFrame:CreateFontString(nil, "OVERLAY")
		Text032:SetFont("Fonts\\FRIZQT__.TTF", 11, "NORMAL")
		Text032:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 32, -278)
		Text032:SetTextColor(1, 1, 0, 1)
		Text033 = SettingsFrame:CreateFontString(nil, "OVERLAY")
		Text033:SetFont("Fonts\\FRIZQT__.TTF", 11, "NORMAL")
		Text033:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 32, -294)
		Text033:SetTextColor(1, 1, 0, 1)

		Text041 = SettingsFrame:CreateFontString(nil, "OVERLAY")
		Text041:SetFont("Fonts\\FRIZQT__.TTF", 11, "NORMAL")
		Text041:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 482, -132)
		Text041:SetTextColor(1, 1, 0, 1)
		Text042 = SettingsFrame:CreateFontString(nil, "OVERLAY")
		Text042:SetFont("Fonts\\FRIZQT__.TTF", 11, "NORMAL")
		Text042:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 482, -148)
		Text042:SetTextColor(1, 1, 0, 1)
		Text043 = SettingsFrame:CreateFontString(nil, "OVERLAY")
		Text043:SetFont("Fonts\\FRIZQT__.TTF", 11, "NORMAL")
		Text043:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 482, -164)
		Text043:SetTextColor(1, 1, 0, 1)
		
		Text051 = SettingsFrame:CreateFontString(nil, "OVERLAY")
		Text051:SetFont("Fonts\\FRIZQT__.TTF", 11, "NORMAL")
		Text051:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 482, -198)
		Text051:SetTextColor(1, 1, 0, 1)
		Text052 = SettingsFrame:CreateFontString(nil, "OVERLAY")
		Text052:SetFont("Fonts\\FRIZQT__.TTF", 11, "NORMAL")
		Text052:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 482, -214)
		Text052:SetTextColor(1, 1, 0, 1)
		Text053 = SettingsFrame:CreateFontString(nil, "OVERLAY")
		Text053:SetFont("Fonts\\FRIZQT__.TTF", 11, "NORMAL")
		Text053:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 482, -230)
		Text053:SetTextColor(1, 1, 0, 1)
		
		Text061 = SettingsFrame:CreateFontString(nil, "OVERLAY")
		Text061:SetFont("Fonts\\FRIZQT__.TTF", 11, "NORMAL")
		Text061:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 482, -262)
		Text061:SetTextColor(1, 1, 0, 1)
		Text062 = SettingsFrame:CreateFontString(nil, "OVERLAY")
		Text062:SetFont("Fonts\\FRIZQT__.TTF", 11, "NORMAL")
		Text062:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 482, -278)
		Text062:SetTextColor(1, 1, 0, 1)
		Text063 = SettingsFrame:CreateFontString(nil, "OVERLAY")
		Text063:SetFont("Fonts\\FRIZQT__.TTF", 11, "NORMAL")
		Text063:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 482, -294)
		Text063:SetTextColor(1, 1, 0, 1)

		-- Slash Commands

		SLASH_PH1 = Language.SlashCommand
		local function handler(command, editbox)
			SettingsFrame:Show()
			if (EvalMode == 1) then 
				EvalMode = 0
				phase1()
			end
		end
		SlashCmdList["PH"] = handler;

		-- Check to see if we're loaded while in battle
		zcna()

		-- Event Handler

		local events = {};
		function events:CHAT_MSG_BG_SYSTEM_NEUTRAL(msg)							-- Skip an AFK Check if during the preparation period
			if msg == Language.WarsongGulchMinuteWarning or msg == Language.ArathiBasinMinuteWarning or msg == Language.AlteracValleyMinuteWarning or msg == Language.EyeOfTheStormMinuteWarning or msg == Language.StrandOfTheAncientsMinuteWarning or msg == Language.IsleOfConquestMinuteWarning or msg == Language.TwinPeaksMinuteWarning or msg == Language.BattleForGilneasMinuteWarning then
				LastUpdate = LastUpdate + 60
			end
		end
		function events:ZONE_CHANGED_NEW_AREA()
			zcna()
		end
		function events:ADDON_LOADED(...)
			if ShowZero == nil then											-- Load Default Settings
				announceRaid = false
				announceSelf = true
				AnnounceRaid = false
				AnnounceSelf = true
				achievement = false
				Achievement = false
				primaryspec = false
				PrimarySpec = false
				secondaryspec = false
				SecondarySpec = false
				geartrack = false
				GearTrack = false
				showmeta = true
				ShowMeta = true
				showzero = true
				ShowZero = true
				SettingsFrame:Show()
			else															-- Load Saved Settings
				announceRaid = AnnounceRaid
				announceSelf = AnnounceSelf
				achievement = Achievement
				primaryspec = PrimarySpec
				secondaryspec = SecondarySpec
				geartrack = GearTrack
				showzero = ShowZero
				showmeta = ShowMeta

				AnnounceRaidOption:SetChecked(announceRaid)
				AnnounceSelfOption:SetChecked(announceSelf)
				AchievementOption:SetChecked(achievement)
				PrimarySpecOption:SetChecked(primaryspec)
				SecondarySpecOption:SetChecked(secondaryspec)
				GearTrackOption:SetChecked(geartrack)
				ShowMetaOption:SetChecked(showmeta)
				ShowZeroOption:SetChecked(showzero)
			end
		end
		Parent:SetScript("OnEvent", function(self, event, ...)
			events[event](self, ...); 										-- call one of the functions above
		end);
		for k, v in pairs(events) do
			Parent:RegisterEvent(k); 							-- Register all events for which handlers have been defined
		end

		Parent:SetScript("OnUpdate", function(self, elapsed) UpdateFrame(elapsed) end)						-- Update

	else
		DEFAULT_CHAT_FRAME:AddMessage(Language.Avatar .. Language.OldVersion)
		DEFAULT_CHAT_FRAME:AddMessage(Language.Avatar .. Language.Help)
	end
end

function phase1()
	Text011:SetText("")
	Text012:SetText("")
	Text013:SetText("")
	Text021:SetText("")
	Text022:SetText("")
	Text023:SetText("")
	Text031:SetText("")
	Text032:SetText("")
	Text033:SetText("")
	Text041:SetText("")
	Text042:SetText("")
	Text043:SetText("")
	Text051:SetText("")
	Text052:SetText("")
	Text053:SetText("")
	Text061:SetText("")
	Text062:SetText("")
	Text063:SetText("")
	ErrorText:SetText("")
	if (EvalMode == 1) then
		EvalMode = 0
		AnnounceSelfOption:Show()
		AnnounceRaidOption:Show()
		PrimarySpecOption:Show()
		SecondarySpecOption:Show()
		AchievementOption:Show()
		GearTrackOption:Show()
		ShowZeroOption:Show()
		ShowMetaOption:Show()
		EvalButton:Show()
		EvalOffButton:Hide()
		return 0;
	else
		EvalMode = 1
	end
	AnnounceSelfOption:Hide()
	AnnounceRaidOption:Hide()
	PrimarySpecOption:Hide()
	SecondarySpecOption:Hide()
	AchievementOption:Hide()
	GearTrackOption:Hide()
	ShowMetaOption:Hide()
	ShowZeroOption:Hide()
	EvalButton:Hide()
	EvalOffButton:Show()
	if (UnitLevel("player")) < 85 then
		ErrorText:SetText(Language.TooLow)
		return 0;
	end

	--[[ Step 1 - Our basic setup.  Get our class, and spec ]]--
	local playerClass, englishClass = UnitClass("player");
	local numTier = 0;

	local numTalents = GetNumTalents(1);
	local numScan = 0;
	local tier1 = 0;
	local tier2 = 0;
	local tier3 = 0;
	repeat
		numScan = numScan + 1;
		nameTalent, icon, tier, column, currRank, maxRank= GetTalentInfo(1, numScan);
		tier1 = tier1 + currRank;
	until (numScan == numTalents)

	numScan = 0; numTalents = GetNumTalents(2);
	repeat
		numScan = numScan + 1;
		nameTalent, icon, tier, column, currRank, maxRank= GetTalentInfo(2, numScan);
		tier2 = tier2 + currRank;
	until (numScan == numTalents)

	numScan = 0; numTalents = GetNumTalents(3);
	repeat
		numScan = numScan + 1;
		nameTalent, icon, tier, column, currRank, maxRank= GetTalentInfo(3, numScan);
		tier3 = tier3 + currRank;
	until (numScan == numTalents)

	numTier = 0;
	if (tier1 + tier2 + tier3 == 0) then
		ErrorText:SetText(Language.NoTalent);
		return 0;
	end

	numTier = 1;
	if (tier1 > tier2 and tier1 > tier3) then numTier = 1; end
	if (tier2 > tier1 and tier2 > tier3) then numTier = 2; end
	if (tier3 > tier1 and tier3 > tier2) then numTier = 3; end

	local bHealer = 0
	local bCaster = 0
	local numArmor = 1
	if (englishClass == "DEATHKNIGHT") then
		numArmor = 4;
	end
	if (englishClass == "DRUID") then
		numArmor = 2;
		if (numTier == 1) then
			bCaster = 1;
		end
		if (numTier == 3) then
			bHealer = 1;
		end
	end
	if (englishClass == "HUNTER") then
		numArmor = 3;
	end
	if (englishClass == "MAGE") then
		bCaster = 1
	end
	if (englishClass == "PRIEST") then
		if (numTier ~= 3) then
			bHealer = 1
		else
			bCaster = 1
		end
	end
	if (englishClass == "PALADIN") then
		numArmor = 4;
		if (numTier == 1) then
			bHealer = 1
		end
	end
	if (englishClass == "ROGUE") then
		numArmor = 2;
	end
	if (englishClass == "SHAMAN") then
		numArmor = 3;
		if (numTier == 3) then
			bHealer = 1
		end
		if (numTier == 1) then
			bCaster = 1
		end
	end
	if (englishClass == "WARLOCK") then
		bCaster = 1;
	end
	if (englishClass == "WARRIOR") then
		numArmor = 4;
	end

	local setName;
	if (numArmor == 4) then
		if (bHealer == 0) then
			setNameA = "Bloodied Pyrium ";
		else
			setNameA = "Ornate Pyrium ";
		end
	end
	if (numArmor == 3) then
		if (bCaster == 0 and bHealer == 0) then
			setNameA = "Bloodied Dragonscale ";
		else
			setNameA = "Bloodied Scale ";
		end
	end

	if (numArmor == 2) then
		if (bCaster == 0 and bHealer == 0) then
			setNameA = "Bloodied Leather ";
		else
			setNameA = "Bloodied Wyrmhide ";
		end
	end

	if (numArmor == 1) then
		setNameA = "Emberfire ";
	end
	setNameB = "Bloodthirsty Gladiator's "
	setNameC = "Vicious Gladiator's "

	local HitNeeded = 410
	local HitRating = 0
	local HitType = 1
	local SpenNeeded = 195
	local SpenRating = 0
	local ExpNeeded = 0
	local ExpRating = 0
	local DraeneiBonusMelee = 0
	local DraeneiBonusSpell = 0

	-- Draenei get 1% hit bonus
	if (UnitRace("player") == "Draenei") then
		DraeneiBonusMelee = 129
		DraeneiBonusSpell = 103
	end

	for i=1,3 do
		if englishClass == "DEATHKNIGHT" then
			--TODO: Dual wielding
			HitNeeded = 410 - DraeneiBonusSpell
			HitType = 2
			SpenNeeded = 0
			ExpNeeded = 600
			GearShift(17, i, "", "", setNameC, "Relic of Conquest", "(700 " .. Language.Conquest .. ")", "", "", "")
			GearShift(15, i, "", "", setNameC, "Greatsword", "(4,600 " .. Language.Conquest .. ")", "", "", "")
			GearShift(12, i, "", "", setNameB, "Signet of Cruelty", "(1,250 " .. Language.Honor .. ")", setNameC, "Signet of Cruelty", "(1,250 " .. Language.Conquest .. ")")
			GearShift(10, i, "", "", setNameB, "Emblem of Tenacity", "(1,650 " .. Language.Honor .. ")", setNameC, "Emblem of Tenacity", "(1,650 " .. Language.Conquest .. ")")
			GearShift(13, i, "", "", setNameB, "Cloak of Alacrity", "(1,250 " .. Language.Honor .. ")", setNameC, "Cloak of Alacrity", "(1,250 " .. Language.Conquest .. ")")
			GearShift(8,  i, "", "", setNameB, "Warboots of Alacrity", "(1,650 " .. Language.Honor .. ")", setNameC, "Warboots of Alacrity", "(1,650 " .. Language.Conquest .. ")")
			GearShift(7,  i, "", "", setNameB, "Girdle of Cruelty", "(1,650 " .. Language.Honor .. ")", setNameC, "Girdle of Cruelty", "(1,650 " .. Language.Conquest .. ")")
			-- 257 exp
			GearShift(6,  i, "", "", setNameB, "Armplates of Proficiency", "(1,250 " .. Language.Honor .. ")", setNameC, "Armplates of Proficiency", "(1,250 " .. Language.Conquest .. ")")
			-- 414 hit, 138 exp
			GearShift(14, i, "", "", setNameB, "Choker of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Choker of Accuracy", "(1,250 " .. Language.Conquest .. ")")
			-- 276 hit, 138 exp
			GearShift(11, i, "", "", setNameB, "Signet of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Signet of Accuracy", "(1,250 " .. Language.Conquest .. ")")
			GearShift(9,  i, "", "", setNameB, "Medallion of Tenacity", "(1,650 " .. Language.Honor .. ")",setNameC, "Medallion of Tenacity", "(1,650 " .. Language.Conquest .. ")")
			-- 138 hit, 138 exp
			GearShift(5,  i, setNameA .. "Helm", Language.Crafted, setNameB, "Dreadplate Helm", "(2,200 " .. Language.Honor .. ")", setNameC, "Dreadplate Helm", "(2,200 " .. Language.Conquest .. ")")
			GearShift(4,  i, setNameA .. "Legguards", Language.Crafted, setNameB, "Dreadplate Legguards", "(2,200 " .. Language.Honor .. ")", setNameC, "Dreadplate Legguards", "(2,200 " .. Language.Conquest .. ")")
			GearShift(3,  i, setNameA .. "Breastplate", Language.Crafted, setNameB, "Dreadplate Chestpiece", "(2,200 " .. Language.Honor .. ")", setNameC, "Dreadplate Chestpiece", "(2,200 " .. Language.Conquest .. ")")
			GearShift(2,  i, setNameA .. "Shoulders", Language.Crafted, setNameB, "Dreadplate Shoulders", "(1,650 " .. Language.Honor .. ")", setNameC, "Dreadplate Shoulders", "(1,650 " .. Language.Conquest .. ")")
			GearShift(1,  i, setNameA .. "Gauntlets", Language.Crafted, setNameB, "Dreadplate Gauntlets", "(1,650 " .. Language.Honor .. ")", setNameC, "Dreadplate Gauntlets", "(1,650 " .. Language.Conquest .. ")")
		end

		if englishClass == "DRUID" then
			if (bHealer == 0 and bCaster == 0) then
				HitNeeded = 601
				HitType = 2
				SpenNeeded = 0
				ExpNeeded = 600
				--601 hit
				GearShift(17, i, "", "", setNameC, "Relic of Triumph", "(700 " .. Language.Conquest .. ")", "", "", "")
				GearShift(15, i, "", "", setNameC, "Pike", "(4,600 " .. Language.Conquest .. ")", "", "", "")
				GearShift(12, i, "", "", setNameB, "Ring of Cruelty", "(1,250 " .. Language.Honor .. ")", setNameC, "Ring of Cruelty", "(1,250 " .. Language.Conquest .. ")")
				GearShift(10, i, "", "", setNameB, "Emblem of Tenacity", "(1,650 " .. Language.Honor .. ")", setNameC, "Emblem of Tenacity", "(1,650 " .. Language.Conquest .. ")")
				GearShift(14, i, "", "", setNameB, "Necklace of Proficiency", "(1,250 " .. Language.Honor .. ")", setNameC, "Necklace of Proficiency", "(1,250 " .. Language.Conquest .. ")")
				GearShift(13, i, "", "", setNameB, "Cape of Cruelty", "(1,250 " .. Language.Honor .. ")", setNameC, "Cape of Cruelty", "(1,250 " .. Language.Conquest .. ")")
				GearShift(8,  i, "", "", setNameB, "Boots of Cruelty", "(1,650 " .. Language.Honor .. ")", setNameC, "Boots of Cruelty", "(1,650 " .. Language.Conquest .. ")")
				--376 hit
				GearShift(7,  i, "", "", setNameB, "Waistband of Accuracy", "(1,650 " .. Language.Honor .. ")", setNameC, "Waistband of Accuracy", "(1,650 " .. Language.Conquest .. ")")
				--238 hit
				GearShift(6,  i, "", "", setNameB, "Armwraps of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Armwraps of Accuracy", "(1,250 " .. Language.Conquest .. ")")
				--119 hit
				GearShift(11, i, "", "", setNameB, "Ring of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Ring of Accuracy", "(1,250 " .. Language.Conquest .. ")")
				GearShift(9,  i, "", "", setNameB, "Medallion of Tenacity", "(1,650 " .. Language.Honor .. ")",setNameC, "Medallion of Tenacity", "(1,650 " .. Language.Conquest .. ")")
				GearShift(5,  i, setNameA .. "Helm", Language.Crafted, setNameB, "Dragonhide Hood", "(2,200 " .. Language.Honor .. ")", setNameC, "Dragonhide Hood", "(2,200 " .. Language.Conquest .. ")")
				GearShift(4,  i, setNameA .. "Legs", Language.Crafted, setNameB, "Dragonhide Legguards", "(2,200 " .. Language.Honor .. ")", setNameC, "Dragonhide Legguards", "(2,200 " .. Language.Conquest .. ")")
				GearShift(3,  i, setNameA .. "Chest", Language.Crafted, setNameB, "Dragonhide Robes", "(2,200 " .. Language.Honor .. ")", setNameC, "Dragonhide Robes", "(2,200 " .. Language.Conquest .. ")")
				GearShift(2,  i, setNameA .. "Shoulders", Language.Crafted, setNameB, "Dragonhide Spaulders", "(1,650 " .. Language.Honor .. ")", setNameC, "Dragonhide Spaulders", "(1,650 " .. Language.Conquest .. ")")
				GearShift(1,  i, setNameA .. "Gloves", Language.Crafted, setNameB, "Dragonhide Gloves", "(1,650 " .. Language.Honor .. ")", setNameC, "Dragonhide Gloves", "(1,650 " .. Language.Conquest .. ")")
			end
			if (bHealer == 1) then
				HitNeeded = 410 - DraeneiBonusSpell
				-- Hit 410, sp 195
				GearShift(17, i, "", "", setNameC, "Relic of Dominance", "(700 " .. Language.Conquest .. ")", "", "", "")
				GearShift(15, i, "", "", setNameC, "Battle Staff", "(4,600 " .. Language.Conquest .. ")", "", "", "")
				GearShift(12, i, "", "", setNameB, "Band of Cruelty", "(1,250 " .. Language.Honor .. ")", setNameC, "Band of Cruelty", "(1,250 " .. Language.Conquest .. ")")
				GearShift(10, i, "", "", setNameB, "Emblem of Tenacity", "(1,650 " .. Language.Honor .. ")", setNameC, "Emblem of Tenacity", "(1,650 " .. Language.Conquest .. ")")
				GearShift(14, i, "", "", setNameB, "Pendant of Alacrity", "(1,250 " .. Language.Honor .. ")", setNameC, "Pendant of Alacrity", "(1,250 " .. Language.Conquest .. ")")
				GearShift(7,  i, "", "", setNameB, "Belt of Cruelty", "(1,650 " .. Language.Honor .. ")", setNameC, "Belt of Cruelty", "(1,650 " .. Language.Conquest .. ")")
				GearShift(8,  i, "", "", setNameB, "Treads of Meditation", "(1,650 " .. Language.Honor .. ")", setNameC, "Treads of Mediation", "(1,650 " .. Language.Conquest .. ")")
				GearShift(6,  i, "", "", setNameB, "Bindings of Prowess", "(1,250 " .. Language.Honor .. ")", setNameC, "Bindings of Prowess", "(1,250 " .. Language.Conquest .. ")")
				-- 178 sp
				GearShift(13, i, "", "", setNameB, "Drape of Diffusion", "(1,250 " .. Language.Honor .. ")", setNameC, "Drape of Diffusion", "(1,250 " .. Language.Conquest .. ")")
				-- 420 hit (talented)
				GearShift(11, i, "", "", setNameB, "Band of Dominance", "(1,250 " .. Language.Honor .. ")", setNameC, "Band of Dominance", "(1,250 " .. Language.Conquest .. ")")
				GearShift(9,  i, "", "", setNameB, "Medallion of Meditation", "(1,650 " .. Language.Honor .. ")",setNameC, "Medallion of Meditation", "(1,650 " .. Language.Conquest .. ")")
				GearShift(5,  i, setNameA .. "Helm", Language.Crafted, setNameB, "Kodohide Helm", "(2,200 " .. Language.Honor .. ")", setNameC, "Kodohide Helm", "(2,200 " .. Language.Conquest .. ")")
				GearShift(4,  i, setNameA .. "Legs", Language.Crafted, setNameB, "Kodohide Legguards", "(2,200 " .. Language.Honor .. ")", setNameC, "Kodohide Legguards", "(2,200 " .. Language.Conquest .. ")")
				GearShift(3,  i, setNameA .. "Chest", Language.Crafted, setNameB, "Kodohide Robes", "(2,200 " .. Language.Honor .. ")", setNameC, "Kodohide Robes", "(2,200 " .. Language.Conquest .. ")")
				GearShift(2,  i, setNameA .. "Shoulders", Language.Crafted, setNameB, "Kodohide Spaulders", "(1,650 " .. Language.Honor .. ")", setNameC, "Kodohide Spaulders", "(1,650 " .. Language.Conquest .. ")")
				GearShift(1,  i, setNameA .. "Gloves", Language.Crafted, setNameB, "Kodohide Gloves", "(1,650 " .. Language.Honor .. ")", setNameC, "Kodohide Gloves", "(1,650 " .. Language.Conquest .. ")")
			end
			if (bCaster == 1) then
				HitNeeded = 410
				-- Hit 410, sp 195
				GearShift(17, i, "", "", setNameC, "Relic of Dominance", "(700 " .. Language.Conquest .. ")", "", "", "")
				GearShift(15, i, "", "", setNameC, "Battle Staff", "(4,600 " .. Language.Conquest .. ")", "", "", "")
				GearShift(12, i, "", "", setNameB, "Band of Cruelty", "(1,250 " .. Language.Honor .. ")", setNameC, "Band of Cruelty", "(1,250 " .. Language.Conquest .. ")")
				GearShift(10, i, "", "", setNameB, "Emblem of Tenacity", "(1,650 " .. Language.Honor .. ")", setNameC, "Emblem of Tenacity", "(1,650 " .. Language.Conquest .. ")")
				GearShift(14, i, "", "", setNameB, "Pendant of Alacrity", "(1,250 " .. Language.Honor .. ")", setNameC, "Pendant of Alacrity", "(1,250 " .. Language.Conquest .. ")")
				GearShift(7,  i, "", "", setNameB, "Footguards of Alacrity", "(1,650 " .. Language.Honor .. ")", setNameC, "Footguards of Alacrity", "(1,650 " .. Language.Conquest .. ")")
				GearShift(8,  i, "", "", setNameB, "Treads of Meditation", "(1,650 " .. Language.Honor .. ")", setNameC, "Treads of Mediation", "(1,650 " .. Language.Conquest .. ")")
				GearShift(6,  i, "", "", setNameB, "Bindings of Prowess", "(1,250 " .. Language.Honor .. ")", setNameC, "Bindings of Prowess", "(1,250 " .. Language.Conquest .. ")")
				-- 178 sp
				GearShift(13, i, "", "", setNameB, "Drape of Diffusion", "(1,250 " .. Language.Honor .. ")", setNameC, "Drape of Diffusion", "(1,250 " .. Language.Conquest .. ")")
				-- 420 hit
				GearShift(11, i, "", "", setNameB, "Band of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Band of Accuracy", "(1,250 " .. Language.Conquest .. ")")
				-- 301 hit, 
				GearShift(9,  i, "", "", setNameB, "Medallion of Meditation", "(1,650 " .. Language.Honor .. ")",setNameC, "Medallion of Meditation", "(1,650 " .. Language.Conquest .. ")")
				GearShift(5,  i, setNameA .. "Helm", Language.Crafted, setNameB, "Wyrmhide Helm", "(2,200 " .. Language.Honor .. ")", setNameC, "Wyrmhide Helm", "(2,200 " .. Language.Conquest .. ")")
				GearShift(4,  i, setNameA .. "Legs", Language.Crafted, setNameB, "Wyrmhide Legguards", "(2,200 " .. Language.Honor .. ")", setNameC, "Wyrmhide Legguards", "(2,200 " .. Language.Conquest .. ")")
				GearShift(3,  i, setNameA .. "Chest", Language.Crafted, setNameB, "Wyrmhide Robes", "(2,200 " .. Language.Honor .. ")", setNameC, "Wyrmhide Robes", "(2,200 " .. Language.Conquest .. ")")
				GearShift(2,  i, setNameA .. "Shoulders", Language.Crafted, setNameB, "Wyrmhide Spaulders", "(1,650 " .. Language.Honor .. ")", setNameC, "Wyrmhide Spaulders", "(1,650 " .. Language.Conquest .. ")")
				GearShift(1,  i, setNameA .. "Gloves", Language.Crafted, setNameB, "Wyrmhide Gloves", "(1,650 " .. Language.Honor .. ")", setNameC, "Wyrmhide Gloves", "(1,650 " .. Language.Conquest .. ")")
			end
		end

		if englishClass == "HUNTER" then
			HitNeeded = 410 - DraeneiBonusSpell
			HitType = 3
			SpenNeeded = 0
			ExpNeeded = 0

			GearShift(15, i, "", "", setNameC, "Pike", "(4,600 " .. Language.Conquest .. ")", "", "", "")

			-- Customize which weapon we need base on what's equipped
			SlotLink = GetInventoryItemLink("player",GetInventorySlotInfo("RangedSlot"));
			sName = "None";	
			if (SlotLink) then 
				sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(SlotLink)
			else
				sSubType="Bow"
			end
			if (sSubType == "Crossbow") then 
				GearShift(17, i, "", "", setNameC, "Heavy Crossbow", "(4,600 " .. Language.Conquest .. ")", "", "", "")
			elseif (sSubType == "Rifle") then 
				GearShift(17, i, "", "", setNameC, "Rifle", "(4,600 " .. Language.Conquest .. ")", "", "", "")
			else
				GearShift(17, i, "", "", setNameC, "Longbow", "(4,600 " .. Language.Conquest .. ")", "", "", "")
			end

			GearShift(12, i, "", "", setNameB, "Ring of Cruelty", "(1,250 " .. Language.Honor .. ")", setNameC, "Ring of Cruelty", "(1,250 " .. Language.Conquest .. ")")
			GearShift(10, i, "", "", setNameB, "Emblem of Tenacity", "(1,650 " .. Language.Honor .. ")", setNameC, "Emblem of Tenacity", "(1,650 " .. Language.Conquest .. ")")
			GearShift(14, i, "", "", setNameB, "Necklace of Prowess", "(1,250 " .. Language.Honor .. ")", setNameC, "Necklace of Prowess", "(1,250 " .. Language.Conquest .. ")")
			GearShift(13, i, "", "", setNameB, "Cape of Cruelty", "(1,250 " .. Language.Honor .. ")", setNameC, "Cape of Cruelty", "(1,250 " .. Language.Conquest .. ")")
			GearShift(8,  i, "", "", setNameB, "Sabatons of Alacrity", "(1,650 " .. Language.Honor .. ")", setNameC, "Sabatons of Alacrity", "(1,650 " .. Language.Conquest .. ")")
			-- The shift here is intentional
			GearShift(6,  i, "", "", setNameB, "Wristguards of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Wristguards of Alacrity", "(1,250 " .. Language.Conquest .. ")")
			--395 hit, different item if hit capped already
			HitRating = GetCombatRating(10)
			if (HitRating < 410) then
				GearShift(7,  i, "", "", setNameB, "Links of Accuracy", "(1,650 " .. Language.Honor .. ")", setNameC, "Links of Accuracy", "(1,650 " .. Language.Conquest .. ")")
			else
				GearShift(7,  i, "", "", setNameB, "Links of Cruelty", "(1,650 " .. Language.Honor .. ")", setNameC, "Links of Cruelty", "(1,650 " .. Language.Conquest .. ")")
			end
			--257 hit / 391 hit
			GearShift(11, i, "", "", setNameB, "Ring of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Ring of Accuracy", "(1,250 " .. Language.Conquest .. ")")
			GearShift(9,  i, "", "", setNameB, "Medallion of Tenacity", "(1,650 " .. Language.Honor .. ")",setNameC, "Medallion of Tenacity", "(1,650 " .. Language.Conquest .. ")")
			--138 hit / 159 hit
			GearShift(5,  i, setNameA .. "Helm", Language.Crafted, setNameB, "Chain Helm", "(2,200 " .. Language.Honor .. ")", setNameC, "Chain Helm", "(2,200 " .. Language.Conquest .. ")")
			GearShift(4,  i, setNameA .. "Legs", Language.Crafted, setNameB, "Chain Leggings", "(2,200 " .. Language.Honor .. ")", setNameC, "Chain Leggings", "(2,200 " .. Language.Conquest .. ")")
			GearShift(3,  i, setNameA .. "Chest", Language.Crafted, setNameB, "Chain Armor", "(2,200 " .. Language.Honor .. ")", setNameC, "Chain Armor", "(2,200 " .. Language.Conquest .. ")")
			GearShift(2,  i, setNameA .. "Shoulders", Language.Crafted, setNameB, "Chain Spaulders", "(1,650 " .. Language.Honor .. ")", setNameC, "Chain Spaulders", "(1,650 " .. Language.Conquest .. ")")
			GearShift(1,  i, setNameA .. "Gloves", Language.Crafted, setNameB, "Chain Gauntlets", "(1,650 " .. Language.Honor .. ")", setNameC, "Chain Gauntlets", "(1,650 " .. Language.Conquest .. ")")
		end

		if (englishClass == "MAGE") then
			HitNeeded = 410 - DraeneiBonusSpell
			GearShift(17, i, "", "", setNameC, "Touch of Defeat", "(700 " .. Language.Conquest .. ")", "", "", "")
			GearShift(15, i, "", "", setNameC, "Battle Staff", "(4,600 " .. Language.Conquest .. ")", "", "", "")
			GearShift(12, i, "", "", setNameB, "Band of Cruelty", "(1,250 " .. Language.Honor .. ")", setNameC, "Band of Cruelty", "(1,250 " .. Language.Conquest .. ")")
			GearShift(10, i, "", "", setNameB, "Emblem of Tenacity", "(1,650 " .. Language.Honor .. ")", setNameC, "Emblem of Tenacity", "(1,650 " .. Language.Conquest .. ")")
			GearShift(14, i, "", "", setNameB, "Pendant of Diffusion", "(1,250 " .. Language.Honor .. ")", setNameC, "Pendant of Diffusion", "(1,250 " .. Language.Conquest .. ")")
			GearShift(8,  i, "", "", setNameB, "Treads of Cruelty", "(1,650 " .. Language.Honor .. ")", setNameC, "Treads of Cruelty", "(1,650 " .. Language.Conquest .. ")")
			GearShift(7,  i, "", "", setNameB, "Cord of Accuracy", "(1,650 " .. Language.Honor .. ")", setNameC, "Cord of Cruelty", "(1,650 " .. Language.Conquest .. ")")
			GearShift(6,  i, "", "", setNameB, "Cuffs of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Cuffs of Prowess", "(1,250 " .. Language.Conquest .. ")")
			GearShift(13, i, "", "", setNameB, "Drape of Diffusion", "(1,250 " .. Language.Honor .. ")", setNameC, "Drape of Diffusion", "(1,250 " .. Language.Conquest .. ")")
			GearShift(11, i, "", "", setNameB, "Band of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Band of Dominance", "(1,250 " .. Language.Conquest .. ")")
			GearShift(9,  i, "", "", setNameB, "Medallion of Tenacity", "(1,650 " .. Language.Honor .. ")",setNameC, "Medallion of Tenacity", "(1,650 " .. Language.Conquest .. ")")
			GearShift(5,  i, setNameA .. "Cowl", Language.Crafted, setNameB, "Silk Cowl", "(2,200 " .. Language.Honor .. ")", setNameC, "Silk Cowl", "(2,200 " .. Language.Conquest .. ")")
			GearShift(4,  i, setNameA .. "Pants", Language.Crafted, setNameB, "Silk Trousers", "(2,200 " .. Language.Honor .. ")", setNameC, "Silk Trousers", "(2,200 " .. Language.Conquest .. ")")
			GearShift(3,  i, setNameA .. "Robe", Language.Crafted, setNameB, "Silk Robe", "(2,200 " .. Language.Honor .. ")", setNameC, "Silk Robe", "(2,200 " .. Language.Conquest .. ")")
			GearShift(2,  i, setNameA .. "Shoulders", Language.Crafted, setNameB, "Silk Amice", "(1,650 " .. Language.Honor .. ")", setNameC, "Silk Amice", "(1,650 " .. Language.Conquest .. ")")
			GearShift(1,  i, setNameA .. "Gloves", Language.Crafted, setNameB, "Silk Handguards", "(1,650 " .. Language.Honor .. ")", setNameC, "Silk Handguards", "(1,650 " .. Language.Conquest .. ")")
		end

		if englishClass == "PALADIN" then
			HitNeeded = 601 - DraeneiBonusMelee
			HitType = 2
			SpenNeeded = 0
			if (bHealer == 0) then
				ExpNeeded = 600
				GearShift(17, i, "", "", setNameC, "Relic of Conquest", "(700 " .. Language.Conquest .. ")", "", "", "")
				GearShift(15, i, "", "", setNameC, "Greatsword", "(4,600 " .. Language.Conquest .. ")", "", "", "")
				GearShift(12, i, "", "", setNameB, "Signet of Cruelty", "(1,250 " .. Language.Honor .. ")", setNameC, "Signet of Cruelty", "(1,250 " .. Language.Conquest .. ")")
				GearShift(10, i, "", "", setNameB, "Emblem of Tenacity", "(1,650 " .. Language.Honor .. ")", setNameC, "Emblem of Tenacity", "(1,650 " .. Language.Conquest .. ")")
				GearShift(13, i, "", "", setNameB, "Cloak of Alacrity", "(1,250 " .. Language.Honor .. ")", setNameC, "Cloak of Alacrity", "(1,250 " .. Language.Conquest .. ")")
				GearShift(8,  i, "", "", setNameB, "Warboots of Alacrity", "(1,650 " .. Language.Honor .. ")", setNameC, "Warboots of Alacrity", "(1,650 " .. Language.Conquest .. ")")
				GearShift(7,  i, "", "", setNameB, "Girdle of Cruelty", "(1,650 " .. Language.Honor .. ")", setNameC, "Girdle of Cruelty", "(1,650 " .. Language.Conquest .. ")")
				-- 257 exp
				GearShift(6,  i, "", "", setNameB, "Armplates of Profiency", "(1,250 " .. Language.Honor .. ")", setNameC, "Armplates of Proficiency", "(1,250 " .. Language.Conquest .. ")")
				-- 376 hit
				GearShift(14, i, "", "", setNameB, "Choker of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Choker of Accuracy", "(1,250 " .. Language.Conquest .. ")")
				-- 257 hit
				GearShift(11, i, "", "", setNameB, "Signet of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Signet of Accuracy", "(1,250 " .. Language.Conquest .. ")")
				GearShift(9,  i, "", "", setNameB, "Medallion of Tenacity", "(1,650 " .. Language.Honor .. ")",setNameC, "Medallion of Tenacity", "(1,650 " .. Language.Conquest .. ")")
				-- 138 hit, 138 exp
				GearShift(5,  i, setNameA .. "Helm", Language.Crafted, setNameB, "Scaled Helm", "(2,200 " .. Language.Honor .. ")", setNameC, "Scaled Helm", "(2,200 " .. Language.Conquest .. ")")
				GearShift(4,  i, setNameA .. "Legguards", Language.Crafted, setNameB, "Scaled Legguards", "(2,200 " .. Language.Honor .. ")", setNameC, "Scaled Legguards", "(2,200 " .. Language.Conquest .. ")")
				GearShift(3,  i, setNameA .. "BreastScaled", Language.Crafted, setNameB, "Scaled Chestpiece", "(2,200 " .. Language.Honor .. ")", setNameC, "Scaled Chestpiece", "(2,200 " .. Language.Conquest .. ")")
				GearShift(2,  i, setNameA .. "Shoulders", Language.Crafted, setNameB, "Scaled Shoulders", "(1,650 " .. Language.Honor .. ")", setNameC, "Scaled Shoulders", "(1,650 " .. Language.Conquest .. ")")
				GearShift(1,  i, setNameA .. "Gauntlets", Language.Crafted, setNameB, "Scaled Gauntlets", "(1,650 " .. Language.Honor .. ")", setNameC, "Scaled Gauntlets", "(1,650 " .. Language.Conquest .. ")")
			else
				GearShift(17, i, "", "", setNameC, "Relic of Salvation", "(700 " .. Language.Conquest .. ")", "", "", "")
				GearShift(16, i, "", "", setNameC, "Redoubt", "(950 " .. Language.Conquest .. ")", "", "", "")
				GearShift(15, i, "", "", setNameC, "Gavel", "(3,650 " .. Language.Conquest .. ")", "", "", "")
				GearShift(12, i, "", "", setNameB, "Band of Cruelty", "(1,250 " .. Language.Honor .. ")", setNameC, "Band of Cruelty", "(1,250 " .. Language.Conquest .. ")")
				GearShift(10, i, "", "", setNameB, "Emblem of Tenacity", "(1,650 " .. Language.Honor .. ")", setNameC, "Emblem of Tenacity", "(1,650 " .. Language.Conquest .. ")")
				GearShift(13, i, "", "", setNameB, "Cloak of Alacrity", "(1,250 " .. Language.Honor .. ")", setNameC, "Cloak of Alacrity", "(1,250 " .. Language.Conquest .. ")")
				GearShift(8,  i, "", "", setNameB, "Greaves of Alacrity", "(1,650 " .. Language.Honor .. ")", setNameC, "Greaves of Alacrity", "(1,650 " .. Language.Conquest .. ")")
				GearShift(7,  i, "", "", setNameB, "Clasp of Cruelty", "(1,650 " .. Language.Honor .. ")", setNameC, "Clasp of Cruelty", "(1,650 " .. Language.Conquest .. ")")
				-- 658 hit
				GearShift(14, i, "", "", setNameB, "Pendant of Meditation", "(1,250 " .. Language.Honor .. ")", setNameC, "Pendant of Meditation", "(1,250 " .. Language.Conquest .. ")")
				-- 549 hit
				GearShift(6,  i, "", "", setNameB, "Bracers of Meditation", "(1,250 " .. Language.Honor .. ")", setNameC, "Bracers of Meditation", "(1,250 " .. Language.Conquest .. ")")
				-- 430 hit			
				GearShift(11, i, "", "", setNameB, "Band of Dominance", "(1,250 " .. Language.Honor .. ")", setNameC, "Band of Dominance", "(1,250 " .. Language.Conquest .. ")")
				GearShift(9,  i, "", "", setNameB, "Medallion of Tenacity", "(1,650 " .. Language.Honor .. ")",setNameC, "Medallion of Tenacity", "(1,650 " .. Language.Conquest .. ")")
				-- 311 hit
				GearShift(5,  i, setNameA .. "Helm", Language.Crafted, setNameB, "Ornamented Helm", "(2,200 " .. Language.Honor .. ")", setNameC, "Ornamented Helm", "(2,200 " .. Language.Conquest .. ")")
				GearShift(4,  i, setNameA .. "Legguards", Language.Crafted, setNameB, "Ornamented Legguards", "(2,200 " .. Language.Honor .. ")", setNameC, "Ornamented Legguards", "(2,200 " .. Language.Conquest .. ")")
				GearShift(3,  i, setNameA .. "Breastplate", Language.Crafted, setNameB, "Ornamented Chestguard", "(2,200 " .. Language.Honor .. ")", setNameC, "Ornamented Chestguard", "(2,200 " .. Language.Conquest .. ")")
				GearShift(2,  i, setNameA .. "Shoulders", Language.Crafted, setNameB, "Ornamented Spaulders", "(1,650 " .. Language.Honor .. ")", setNameC, "Ornamented Spaulders", "(1,650 " .. Language.Conquest .. ")")
				GearShift(1,  i, setNameA .. "Gauntlets", Language.Crafted, setNameB, "Ornamented Gloves", "(1,650 " .. Language.Honor .. ")", setNameC, "Ornamented Gloves", "(1,650 " .. Language.Conquest .. ")")

			end
		end
		if englishClass == "PRIEST" then
			HitNeeded = 410 - DraeneiBonusSpell
			if bHealer == 0 then
				GearShift(17, i, "", "", setNameC, "Touch of Defeat", "(700 " .. Language.Conquest .. ")", "", "", "")
				GearShift(15, i, "", "", setNameC, "Battle Staff", "(4,600 " .. Language.Conquest .. ")", "", "", "")
				GearShift(12, i, "", "", setNameB, "Band of Cruelty", "(1,250 " .. Language.Honor .. ")", setNameC, "Band of Cruelty", "(1,250 " .. Language.Conquest .. ")")
				GearShift(10, i, "", "", setNameB, "Emblem of Tenacity", "(1,650 " .. Language.Honor .. ")", setNameC, "Emblem of Tenacity", "(1,650 " .. Language.Conquest .. ")")
				GearShift(14, i, "", "", setNameB, "Pendant of Diffusion", "(1,250 " .. Language.Honor .. ")", setNameC, "Pendant of Diffusion", "(1,250 " .. Language.Conquest .. ")")
				GearShift(7,  i, "", "", setNameB, "Cord of Cruelty", "(1,650 " .. Language.Honor .. ")", setNameC, "Cord of Cruelty", "(1,650 " .. Language.Conquest .. ")")
				GearShift(8,  i, "", "", setNameB, "Treads of Cruelty", "(1,650 " .. Language.Honor .. ")", setNameC, "Treads of Cruelty", "(1,650 " .. Language.Conquest .. ")")
				GearShift(6,  i, "", "", setNameB, "Cuffs of Prowess", "(1,250 " .. Language.Honor .. ")", setNameC, "Cuffs of Prowess", "(1,250 " .. Language.Conquest .. ")")
				GearShift(13, i, "", "", setNameB, "Drape of Diffusion", "(1,250 " .. Language.Honor .. ")", setNameC, "Drape of Diffusion", "(1,250 " .. Language.Conquest .. ")")
				GearShift(11, i, "", "", setNameB, "Band of Dominance", "(1,250 " .. Language.Honor .. ")", setNameC, "Band of Dominance", "(1,250 " .. Language.Conquest .. ")")
				GearShift(9,  i, "", "", setNameB, "Medallion of Meditation", "(1,650 " .. Language.Honor .. ")",setNameC, "Medallion of Meditation", "(1,650 " .. Language.Conquest .. ")")
				GearShift(5,  i, setNameA .. "Cowl", Language.Crafted, setNameB, "Satin Hood", "(2,200 " .. Language.Honor .. ")", setNameC, "Satin Hood", "(2,200 " .. Language.Conquest .. ")")
				GearShift(4,  i, setNameA .. "Pants", Language.Crafted, setNameB, "Satin Leggings", "(2,200 " .. Language.Honor .. ")", setNameC, "Satin Leggings", "(2,200 " .. Language.Conquest .. ")")
				GearShift(3,  i, setNameA .. "Robe", Language.Crafted, setNameB, "Satin Robe", "(2,200 " .. Language.Honor .. ")", setNameC, "Satin Robe", "(2,200 " .. Language.Conquest .. ")")
				GearShift(2,  i, setNameA .. "Shoulders", Language.Crafted, setNameB, "Satin Mantle", "(1,650 " .. Language.Honor .. ")", setNameC, "Satin Mantle", "(1,650 " .. Language.Conquest .. ")")
				GearShift(1,  i, setNameA .. "Gloves", Language.Crafted, setNameB, "Satin Gloves", "(1,650 " .. Language.Honor .. ")", setNameC, "Satin Gloves", "(1,650 " .. Language.Conquest .. ")")
			else
				-- Holy damage can't be resisted
				SpenNeeded = 0
				GearShift(17, i, "", "", setNameC, "Touch of Defeat", "(700 " .. Language.Conquest .. ")", "", "", "")
				GearShift(15, i, "", "", setNameC, "Battle Staff", "(4,600 " .. Language.Conquest .. ")", "", "", "")
				GearShift(12, i, "", "", setNameB, "Band of Cruelty", "(1,250 " .. Language.Honor .. ")", setNameC, "Band of Cruelty", "(1,250 " .. Language.Conquest .. ")")
				GearShift(10, i, "", "", setNameB, "Emblem of Tenacity", "(1,650 " .. Language.Honor .. ")", setNameC, "Emblem of Tenacity", "(1,650 " .. Language.Conquest .. ")")
				GearShift(14, i, "", "", setNameB, "Pendant of Diffusion", "(1,250 " .. Language.Honor .. ")", setNameC, "Pendant of Diffusion", "(1,250 " .. Language.Conquest .. ")")
				GearShift(7,  i, "", "", setNameB, "Cord of Accuracy", "(1,650 " .. Language.Honor .. ")", setNameC, "Cord of Cruelty", "(1,650 " .. Language.Conquest .. ")")
				GearShift(8,  i, "", "", setNameB, "Treads of Meditation", "(1,650 " .. Language.Honor .. ")", setNameC, "Treads of Mediation", "(1,650 " .. Language.Conquest .. ")")
				GearShift(6,  i, "", "", setNameB, "Cuffs of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Cuffs of Accuracy", "(1,250 " .. Language.Conquest .. ")")
				GearShift(13, i, "", "", setNameB, "Drape of Diffusion", "(1,250 " .. Language.Honor .. ")", setNameC, "Drape of Diffusion", "(1,250 " .. Language.Conquest .. ")")
				GearShift(11, i, "", "", setNameB, "Band of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Band of Accuracy", "(1,250 " .. Language.Conquest .. ")")
				GearShift(9,  i, "", "", setNameB, "Medallion of Tenacity", "(1,650 " .. Language.Honor .. ")",setNameC, "Medallion of Tenacity", "(1,650 " .. Language.Conquest .. ")")
				GearShift(5,  i, setNameA .. "Cowl", Language.Crafted, setNameB, "Mooncloth Helm", "(2,200 " .. Language.Honor .. ")", setNameC, "Mooncloth Helm", "(2,200 " .. Language.Conquest .. ")")
				GearShift(4,  i, setNameA .. "Pants", Language.Crafted, setNameB, "Mooncloth Leggings", "(2,200 " .. Language.Honor .. ")", setNameC, "Mooncloth Leggings", "(2,200 " .. Language.Conquest .. ")")
				GearShift(3,  i, setNameA .. "Robe", Language.Crafted, setNameB, "Mooncloth Robe", "(2,200 " .. Language.Honor .. ")", setNameC, "Mooncloth Robe", "(2,200 " .. Language.Conquest .. ")")
				GearShift(2,  i, setNameA .. "Shoulders", Language.Crafted, setNameB, "Mooncloth Mantle", "(1,650 " .. Language.Honor .. ")", setNameC, "Mooncloth Mantle", "(1,650 " .. Language.Conquest .. ")")
				GearShift(1,  i, setNameA .. "Gloves", Language.Crafted, setNameB, "Mooncloth Gloves", "(1,650 " .. Language.Honor .. ")", setNameC, "Mooncloth Gloves", "(1,650 " .. Language.Conquest .. ")")
			end
		end
		if englishClass == "ROGUE" then
			HitNeeded = 601
			HitType = 2
			SpenNeeded = 0
			ExpNeeded = 600
			--601 hit
			GearShift(17, i, "", "", setNameC, "Hatchet", "(700 " .. Language.Conquest .. ")", "", "", "")
			GearShift(16, i, "", "", setNameC, "Shiv", "(950 " .. Language.Conquest .. ")", "", "", "")
			GearShift(15, i, "", "", setNameC, "Shanker", "(3,650 " .. Language.Conquest .. ")", "", "", "")
			GearShift(12, i, "", "", setNameB, "Ring of Cruelty", "(1,250 " .. Language.Honor .. ")", setNameC, "Ring of Cruelty", "(1,250 " .. Language.Conquest .. ")")
			GearShift(10, i, "", "", setNameB, "Emblem of Tenacity", "(1,650 " .. Language.Honor .. ")", setNameC, "Emblem of Tenacity", "(1,650 " .. Language.Conquest .. ")")
			GearShift(14, i, "", "", setNameB, "Necklace of Proficiency", "(1,250 " .. Language.Honor .. ")", setNameC, "Necklace of Proficiency", "(1,250 " .. Language.Conquest .. ")")
			GearShift(13, i, "", "", setNameB, "Cape of Cruelty", "(1,250 " .. Language.Honor .. ")", setNameC, "Cape of Cruelty", "(1,250 " .. Language.Conquest .. ")")
			GearShift(8,  i, "", "", setNameB, "Boots of Alacrity", "(1,650 " .. Language.Honor .. ")", setNameC, "Boots of Alacrity", "(1,650 " .. Language.Conquest .. ")")
			--514 hit
			GearShift(7,  i, "", "", setNameB, "Waistband of Accuracy", "(1,650 " .. Language.Honor .. ")", setNameC, "Waistband of Accuracy", "(1,650 " .. Language.Conquest .. ")")
			--376 hit
			GearShift(6,  i, "", "", setNameB, "Armwraps of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Armwraps of Accuracy", "(1,250 " .. Language.Conquest .. ")")
			--257 hit
			GearShift(11, i, "", "", setNameB, "Ring of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Ring of Accuracy", "(1,250 " .. Language.Conquest .. ")")
			GearShift(9,  i, "", "", setNameB, "Medallion of Tenacity", "(1,650 " .. Language.Honor .. ")",setNameC, "Medallion of Tenacity", "(1,650 " .. Language.Conquest .. ")")
			--138 hit
			GearShift(5,  i, setNameA .. "Helm", Language.Crafted, setNameB, "Leather Helm", "(2,200 " .. Language.Honor .. ")", setNameC, "Leather Helm", "(2,200 " .. Language.Conquest .. ")")
			GearShift(4,  i, setNameA .. "Legs", Language.Crafted, setNameB, "Leather Legguards", "(2,200 " .. Language.Honor .. ")", setNameC, "Leather Legguards", "(2,200 " .. Language.Conquest .. ")")
			GearShift(3,  i, setNameA .. "Chest", Language.Crafted, setNameB, "Leather Tunic", "(2,200 " .. Language.Honor .. ")", setNameC, "Leather Tunic", "(2,200 " .. Language.Conquest .. ")")
			GearShift(2,  i, setNameA .. "Shoulders", Language.Crafted, setNameB, "Leather Spaulders", "(1,650 " .. Language.Honor .. ")", setNameC, "Leather Spaulders", "(1,650 " .. Language.Conquest .. ")")
			GearShift(1,  i, setNameA .. "Gloves", Language.Crafted, setNameB, "Leather Gloves", "(1,650 " .. Language.Honor .. ")", setNameC, "Leather Gloves", "(1,650 " .. Language.Conquest .. ")")
		end

		if englishClass == "SHAMAN" then
			if (bHealer == 0 and bCaster == 0) then
				HitNeeded = 601 - DraeneiBonusMelee
				HitType = 2
				SpenNeeded = 0
				ExpNeeded = 600
				--601 hit
				GearShift(17, i, "", "", setNameC, "Relic of Triumph", "(700 " .. Language.Conquest .. ")", "", "", "")
				GearShift(16, i, "", "", setNameC, "Pummeler", "(3,650 " .. Language.Conquest .. ")", "", "", "")
				GearShift(15, i, "", "", setNameC, "Pummeler", "(3,650 " .. Language.Conquest .. ")", "", "", "")
				GearShift(12, i, "", "", setNameB, "Ring of Cruelty", "(1,250 " .. Language.Honor .. ")", setNameC, "Ring of Cruelty", "(1,250 " .. Language.Conquest .. ")")
				GearShift(10, i, "", "", setNameB, "Emblem of Tenacity", "(1,650 " .. Language.Honor .. ")", setNameC, "Emblem of Tenacity", "(1,650 " .. Language.Conquest .. ")")
				--276 exp
				GearShift(14, i, "", "", setNameB, "Neckpiece of Proficiency", "(1,250 " .. Language.Honor .. ")", setNameC, "Neckpiece of Proficiency", "(1,250 " .. Language.Conquest .. ")")
				GearShift(13, i, "", "", setNameB, "Cape of Cruelty", "(1,250 " .. Language.Honor .. ")", setNameC, "Cape of Cruelty", "(1,250 " .. Language.Conquest .. ")")
				GearShift(8,  i, "", "", setNameB, "Sabatons of Cruelty", "(1,650 " .. Language.Honor .. ")", setNameC, "Sabatons of Cruelty", "(1,650 " .. Language.Conquest .. ")")
				GearShift(7,  i, "", "", setNameB, "Links of Cruelty", "(1,650 " .. Language.Honor .. ")", setNameC, "Links of Cruelty", "(1,650 " .. Language.Conquest .. ")")
				GearShift(6,  i, "", "", setNameB, "Wristguards of Alacrity", "(1,250 " .. Language.Honor .. ")", setNameC, "Wristguards of Alacrity", "(1,250 " .. Language.Conquest .. ")")
				--577 hit
				GearShift(11, i, "", "", setNameB, "Ring of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Ring of Accuracy", "(1,250 " .. Language.Conquest .. ")")
				--439 hit/138 exp
				GearShift(9,  i, "", "", setNameB, "Medallion of Meditation", "(1,650 " .. Language.Honor .. ")",setNameC, "Medallion of Meditation", "(1,650 " .. Language.Conquest .. ")")
				--138 hit/138 exp
				GearShift(5,  i, setNameA .. "Helm", Language.Crafted, setNameB, "Linked Helm", "(2,200 " .. Language.Honor .. ")", setNameC, "Linked Helm", "(2,200 " .. Language.Conquest .. ")")
				GearShift(4,  i, setNameA .. "Legs", Language.Crafted, setNameB, "Linked Leggings", "(2,200 " .. Language.Honor .. ")", setNameC, "Linked Leggings", "(2,200 " .. Language.Conquest .. ")")
				GearShift(3,  i, setNameA .. "Chest", Language.Crafted, setNameB, "Linked Armor", "(2,200 " .. Language.Honor .. ")", setNameC, "Linked Armor", "(2,200 " .. Language.Conquest .. ")")
				GearShift(2,  i, setNameA .. "Shoulders", Language.Crafted, setNameB, "Linked Spaulders", "(1,650 " .. Language.Honor .. ")", setNameC, "Linked Spaulders", "(1,650 " .. Language.Conquest .. ")")
				GearShift(1,  i, setNameA .. "Gloves", Language.Crafted, setNameB, "Linked Gauntlets", "(1,650 " .. Language.Honor .. ")", setNameC, "Linked Gauntlets", "(1,650 " .. Language.Conquest .. ")")
			end
			if (bHealer == 1) then
				HitNeeded = 410 - DraeneiBonusSpell
				-- Hit 410, sp 195
				setNameB = "Bloodthirsty Gladiator's "
				setNameC = "Vicious Gladiator's "
				GearShift(17, i, "", "", setNameC, "Relic of Salvation", "(700 " .. Language.Conquest .. ")", "", "", "")
				GearShift(15, i, "", "", setNameC, "Spellblade", "(3,650 " .. Language.Conquest .. ")", "", "", "")
				GearShift(16, i, "", "", setNameC, "Redoubt", "(950 " .. Language.Conquest .. ")", "", "", "")
				GearShift(12, i, "", "", setNameB, "Band of Cruelty", "(1,250 " .. Language.Honor .. ")", setNameC, "Band of Cruelty", "(1,250 " .. Language.Conquest .. ")")
				GearShift(10, i, "", "", setNameB, "Emblem of Tenacity", "(1,650 " .. Language.Honor .. ")", setNameC, "Emblem of Tenacity", "(1,650 " .. Language.Conquest .. ")")
				GearShift(14, i, "", "", setNameB, "Pendant of Alacrity", "(1,250 " .. Language.Honor .. ")", setNameC, "Pendant of Alacrity", "(1,250 " .. Language.Conquest .. ")")
				GearShift(7,  i, "", "", setNameB, "Waistguard of Meditation", "(1,650 " .. Language.Honor .. ")", setNameC, "Waistguard of Meditation", "(1,650 " .. Language.Conquest .. ")")
				GearShift(8,  i, "", "", setNameB, "Sabatons of Meditation", "(1,650 " .. Language.Honor .. ")", setNameC, "Sabatons of Meditation", "(1,650 " .. Language.Conquest .. ")")
				GearShift(6,  i, "", "", setNameB, "Armbands of Meditation", "(1,250 " .. Language.Honor .. ")", setNameC, "Armbands of Meditation", "(1,250 " .. Language.Conquest .. ")")
				-- 178 sp
				GearShift(13, i, "", "", setNameB, "Drape of Diffusion", "(1,250 " .. Language.Honor .. ")", setNameC, "Drape of Diffusion", "(1,250 " .. Language.Conquest .. ")")
				-- 119 hit
				GearShift(11, i, "", "", setNameB, "Band of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Band of Accuracy", "(1,250 " .. Language.Conquest .. ")")
				GearShift(9,  i, "", "", setNameB, "Medallion of Tenacity", "(1,650 " .. Language.Honor .. ")",setNameC, "Medallion of Tenacity", "(1,650 " .. Language.Conquest .. ")")
				GearShift(5,  i, setNameA .. "Helm", Language.Crafted, setNameB, "Ringmail Helm", "(2,200 " .. Language.Honor .. ")", setNameC, "Ringmail Helm", "(2,200 " .. Language.Conquest .. ")")
				GearShift(4,  i, setNameA .. "Legs", Language.Crafted, setNameB, "Ringmail Leggings", "(2,200 " .. Language.Honor .. ")", setNameC, "Ringmail Leggings", "(2,200 " .. Language.Conquest .. ")")
				GearShift(3,  i, setNameA .. "Chest", Language.Crafted, setNameB, "Ringmail Armor", "(2,200 " .. Language.Honor .. ")", setNameC, "Ringmail Armor", "(2,200 " .. Language.Conquest .. ")")
				GearShift(2,  i, setNameA .. "Shoulders", Language.Crafted, setNameB, "Ringmail Spaulders", "(1,650 " .. Language.Honor .. ")", setNameC, "Ringmail Spaulders", "(1,650 " .. Language.Conquest .. ")")
				GearShift(1,  i, setNameA .. "Gloves", Language.Crafted, setNameB, "Ringmail Gauntlets", "(1,650 " .. Language.Honor .. ")", setNameC, "Ringmail Gauntlets", "(1,650 " .. Language.Conquest .. ")")
			end
			if (bCaster == 1) then
				HitNeeded = 410 - DraeneiBonusSpell
				-- Hit 410, sp 195
				GearShift(17, i, "", "", setNameC, "Relic of Dominance", "(700 " .. Language.Conquest .. ")", "", "", "")
				GearShift(15, i, "", "", setNameC, "Spellblade", "(3,650 " .. Language.Conquest .. ")", "", "", "")
				GearShift(16, i, "", "", setNameC, "Redoubt", "(950 " .. Language.Conquest .. ")", "", "", "")
				GearShift(1, i, "", "", setNameB, "Band of Cruelty", "(1,250 " .. Language.Honor .. ")", setNameC, "Band of Cruelty", "(1,250 " .. Language.Conquest .. ")")
				GearShift(10, i, "", "", setNameB, "Emblem of Tenacity", "(1,650 " .. Language.Honor .. ")", setNameC, "Emblem of Tenacity", "(1,650 " .. Language.Conquest .. ")")
				GearShift(14, i, "", "", setNameB, "Pendant of Alacrity", "(1,250 " .. Language.Honor .. ")", setNameC, "Pendant of Alacrity", "(1,250 " .. Language.Conquest .. ")")
				GearShift(7,  i, "", "", setNameB, "Waistguard of Cruelty", "(1,650 " .. Language.Honor .. ")", setNameC, "Waistguard of Cruelty", "(1,650 " .. Language.Conquest .. ")")
				GearShift(8,  i, "", "", setNameB, "Sabatons of Alacrity", "(1,650 " .. Language.Honor .. ")", setNameC, "Sabatons of Alacrity", "(1,650 " .. Language.Conquest .. ")")
				GearShift(6,  i, "", "", setNameB, "Armbands of Prowess", "(1,250 " .. Language.Honor .. ")", setNameC, "Armbands of Prowess", "(1,250 " .. Language.Conquest .. ")")
				-- 178 sp
				GearShift(13, i, "", "", setNameB, "Drape of Diffusion", "(1,250 " .. Language.Honor .. ")", setNameC, "Drape of Diffusion", "(1,250 " .. Language.Conquest .. ")")
				-- 420 hit
				GearShift(11, i, "", "", setNameB, "Band of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Band of Accuracy", "(1,250 " .. Language.Conquest .. ")")
				-- 301 hit, 
				GearShift(9,  i, "", "", setNameB, "Medallion of Meditation", "(1,650 " .. Language.Honor .. ")",setNameC, "Medallion of Meditation", "(1,650 " .. Language.Conquest .. ")")
				GearShift(5,  i, setNameA .. "Helm", Language.Crafted, setNameB, "Mail Helm", "(2,200 " .. Language.Honor .. ")", setNameC, "Mail Helm", "(2,200 " .. Language.Conquest .. ")")
				GearShift(4,  i, setNameA .. "Legs", Language.Crafted, setNameB, "Mail Leggings", "(2,200 " .. Language.Honor .. ")", setNameC, "Mail Leggings", "(2,200 " .. Language.Conquest .. ")")
				GearShift(3,  i, setNameA .. "Chest", Language.Crafted, setNameB, "Mail Armor", "(2,200 " .. Language.Honor .. ")", setNameC, "Mail Armor", "(2,200 " .. Language.Conquest .. ")")
				GearShift(2,  i, setNameA .. "Shoulders", Language.Crafted, setNameB, "Mail Spaulders", "(1,650 " .. Language.Honor .. ")", setNameC, "Mail Spaulders", "(1,650 " .. Language.Conquest .. ")")
				GearShift(1,  i, setNameA .. "Gloves", Language.Crafted, setNameB, "Mail Gloves", "(1,650 " .. Language.Honor .. ")", setNameC, "Mail Gloves", "(1,650 " .. Language.Conquest .. ")")
			end
		end

		if (englishClass == "WARLOCK") then
			HitNeeded = 410 - DraeneiBonusSpell
			GearShift(17, i, "", "", setNameC, "Touch of Defeat", "(700 " .. Language.Conquest .. ")", "", "", "")
			GearShift(15, i, "", "", setNameC, "Battle Staff", "(4,600 " .. Language.Conquest .. ")", "", "", "")
			GearShift(12, i, "", "", setNameB, "Band of Cruelty", "(1,250 " .. Language.Honor .. ")", setNameC, "Band of Cruelty", "(1,250 " .. Language.Conquest .. ")")
			GearShift(10, i, "", "", setNameB, "Emblem of Tenacity", "(1,650 " .. Language.Honor .. ")", setNameC, "Emblem of Tenacity", "(1,650 " .. Language.Conquest .. ")")
			GearShift(14, i, "", "", setNameB, "Pendant of Diffusion", "(1,250 " .. Language.Honor .. ")", setNameC, "Pendant of Diffusion", "(1,250 " .. Language.Conquest .. ")")
			GearShift(8,  i, "", "", setNameB, "Treads of Cruelty", "(1,650 " .. Language.Honor .. ")", setNameC, "Treads of Cruelty", "(1,650 " .. Language.Conquest .. ")")
			GearShift(7,  i, "", "", setNameB, "Cord of Accuracy", "(1,650 " .. Language.Honor .. ")", setNameC, "Cord of Cruelty", "(1,650 " .. Language.Conquest .. ")")
			GearShift(6,  i, "", "", setNameB, "Cuffs of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Cuffs of Prowess", "(1,250 " .. Language.Conquest .. ")")
			GearShift(13, i, "", "", setNameB, "Drape of Diffusion", "(1,250 " .. Language.Honor .. ")", setNameC, "Drape of Diffusion", "(1,250 " .. Language.Conquest .. ")")
			GearShift(11, i, "", "", setNameB, "Band of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Band of Dominance", "(1,250 " .. Language.Conquest .. ")")
			GearShift(9,  i, "", "", setNameB, "Medallion of Tenacity", "(1,650 " .. Language.Honor .. ")",setNameC, "Medallion of Tenacity", "(1,650 " .. Language.Conquest .. ")")
			GearShift(5,  i, setNameA .. "Cowl", Language.Crafted, setNameB, "Felweave Cowl", "(2,200 " .. Language.Honor .. ")", setNameC, "Felweave Cowl", "(2,200 " .. Language.Conquest .. ")")
			GearShift(4,  i, setNameA .. "Pants", Language.Crafted, setNameB, "Felweave Trousers", "(2,200 " .. Language.Honor .. ")", setNameC, "Felweave Trousers", "(2,200 " .. Language.Conquest .. ")")
			GearShift(3,  i, setNameA .. "Robe", Language.Crafted, setNameB, "Felweave Raiment", "(2,200 " .. Language.Honor .. ")", setNameC, "Felweave Raiment", "(2,200 " .. Language.Conquest .. ")")
			GearShift(2,  i, setNameA .. "Shoulders", Language.Crafted, setNameB, "Felweave Amice", "(1,650 " .. Language.Honor .. ")", setNameC, "Felweave Amice", "(1,650 " .. Language.Conquest .. ")")
			GearShift(1,  i, setNameA .. "Gloves", Language.Crafted, setNameB, "Felweave Handguards", "(1,650 " .. Language.Honor .. ")", setNameC, "Felweave Handguards", "(1,650 " .. Language.Conquest .. ")")
		end

		if englishClass == "WARRIOR" then
			HitNeeded = 601 - DraeneiBonusMelee
			HitType = 2
			SpenNeeded = 0
			ExpNeeded = 600
			GearShift(17, i, "", "", setNameC, "War Edge", "(700 " .. Language.Conquest .. ")", "", "", "")
			if numTier == 2 then
				HitNeeded = 241
				GearShift(16, i, "", "", setNameC, "Greatsword", "(4,600 " .. Language.Conquest .. ")", "", "", "")
			end
			GearShift(15, i, "", "", setNameC, "Greatsword", "(4,600 " .. Language.Conquest .. ")", "", "", "")
			GearShift(12, i, "", "", setNameB, "Signet of Cruelty", "(1,250 " .. Language.Honor .. ")", setNameC, "Signet of Cruelty", "(1,250 " .. Language.Conquest .. ")")
			GearShift(10, i, "", "", setNameB, "Emblem of Tenacity", "(1,650 " .. Language.Honor .. ")", setNameC, "Emblem of Tenacity", "(1,650 " .. Language.Conquest .. ")")
			GearShift(13, i, "", "", setNameB, "Cloak of Alacrity", "(1,250 " .. Language.Honor .. ")", setNameC, "Cloak of Alacrity", "(1,250 " .. Language.Conquest .. ")")
			GearShift(8,  i, "", "", setNameB, "Warboots of Alacrity", "(1,650 " .. Language.Honor .. ")", setNameC, "Warboots of Alacrity", "(1,650 " .. Language.Conquest .. ")")
			GearShift(7,  i, "", "", setNameB, "Girdle of Cruelty", "(1,650 " .. Language.Honor .. ")", setNameC, "Girdle of Cruelty", "(1,650 " .. Language.Conquest .. ")")
			-- 376 hit, 257 exp
			GearShift(6,  i, "", "", setNameB, "Armplates of Proficiency", "(1,250 " .. Language.Honor .. ")", setNameC, "Armplates of Proficiency", "(1,250 " .. Language.Conquest .. ")")
			-- 376 hit, 138 exp
			GearShift(14, i, "", "", setNameB, "Choker of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Choker of Accuracy", "(1,250 " .. Language.Conquest .. ")")
			-- 257 hit, 138 exp
			GearShift(11, i, "", "", setNameB, "Signet of Accuracy", "(1,250 " .. Language.Honor .. ")", setNameC, "Signet of Accuracy", "(1,250 " .. Language.Conquest .. ")")
			GearShift(9,  i, "", "", setNameB, "Medallion of Tenacity", "(1,650 " .. Language.Honor .. ")",setNameC, "Medallion of Tenacity", "(1,650 " .. Language.Conquest .. ")")
			GearShift(5,  i, setNameA .. "Helm", Language.Crafted, setNameB, "Plate Helm", "(2,200 " .. Language.Honor .. ")", setNameC, "Plate Helm", "(2,200 " .. Language.Conquest .. ")")
			GearShift(4,  i, setNameA .. "Legguards", Language.Crafted, setNameB, "Plate Legguards", "(2,200 " .. Language.Honor .. ")", setNameC, "Plate Legguards", "(2,200 " .. Language.Conquest .. ")")
			GearShift(3,  i, setNameA .. "Breastplate", Language.Crafted, setNameB, "Plate Chestpiece", "(2,200 " .. Language.Honor .. ")", setNameC, "Plate Chestpiece", "(2,200 " .. Language.Conquest .. ")")
			-- 138 hit, 138 exp
			GearShift(2,  i, setNameA .. "Shoulders", Language.Crafted, setNameB, "Plate Shoulders", "(1,650 " .. Language.Honor .. ")", setNameC, "Plate Shoulders", "(1,650 " .. Language.Conquest .. ")")
			--138 hit
			GearShift(1,  i, setNameA .. "Gauntlets", Language.Crafted, setNameB, "Plate Gauntlets", "(1,650 " .. Language.Honor .. ")", setNameC, "Plate Gauntlets", "(1,650 " .. Language.Conquest .. ")")
		end
	end

	HitRating = GetCombatRating(7 + HitType)
	ExpRating = GetCombatRating(24)
	SpenRating = GetSpellPenetration()

	if (Text011:GetText() == nil) then
		ErrorText:SetText(Language.GoodJob);
	end

	if (SpenRating < SpenNeeded) then
		ErrorText:SetText(Language.YouAre .. (SpenNeeded - SpenRating) .. Language.LowSpen)
	end

	if (ExpRating < ExpNeeded) then
		ErrorText:SetText(Language.YouAre .. (ExpNeeded - ExpRating) .. Language.LowExp)
	end

	if (HitRating < HitNeeded) then
		ErrorText:SetText(Language.YouAre .. (HitNeeded - HitRating) .. Language.LowHit)
	end

	if (englishClass == "DRUID" and (bHealer == 1 or bCaster == 1)) then
		nameTalent, icon, tier, column, currRank, maxRank= GetTalentInfo(1, 6);
		if (currRank ~= 2) then
			ErrorText:SetText(Language.DruidHit)
		end
	end

	if (englishClass == "PALADIN" and bHealer == 1) then
		nameTalent, icon, tier, column, currRank, maxRank= GetTalentInfo(1, 11);
		if (currRank ~= 2) then
			ErrorText:SetText(Language.PaladinHit)
		end
	end

	if (englishClass == "PRIEST" and bHealer == 0) then
		nameTalent, icon, tier, column, currRank, maxRank= GetTalentInfo(3, 7);
		if (currRank ~= 2) then
			ErrorText:SetText(Language.PriestHit)
		end
	end

	if (englishClass == "SHAMAN" and HitRating < HitNeeded and (bCaster == 1 or bHealer == 1)) then
		nameTalent, icon, tier, column, currRank, maxRank= GetTalentInfo(3, 7);
		if (currRank ~= 2) then
			ErrorText:SetText(Language.ShamanHit .. " (" .. HitRating .. "/" .. HitNeeded .. ")")
		end
	end
end

function GearShift(slotno, phaseno, name1, cost1, set2, name2, cost2, set3, name3, cost3)

		-- Only retrive the first ring or trinket for now
		if slotno == 10 then slotno = 9; end
		if slotno == 12 then slotno = 11; end

		-- Get a slot code
		if (slotno==1) then slotName = "HandsSlot"; end
		if (slotno==2) then slotName = "ShoulderSlot"; end
		if (slotno==3) then slotName = "ChestSlot"; end
		if (slotno==4) then slotName = "LegsSlot"; end
		if (slotno==5) then slotName = "HeadSlot"; end
		if (slotno==6) then slotName = "WristSlot"; end
		if (slotno==7) then slotName = "WaistSlot"; end
		if (slotno==8) then slotName = "FeetSlot"; end
		if (slotno==9) then slotName = "Trinket0Slot"; end
		if (slotno==11) then slotName = "Finger0Slot"; end
		if (slotno==13) then slotName = "BackSlot"; end
		if (slotno==14) then slotName = "NeckSlot"; end
		if (slotno==15) then slotName = "MainHandSlot"; end
		if (slotno==16) then slotName = "SecondaryHandSlot"; end
		if (slotno==17) then slotName = "RangedSlot"; end

		-- Get the item name for that slot
		SlotLink = GetInventoryItemLink("player",GetInventorySlotInfo(slotName));
		sName = "None";	
		if (SlotLink) then sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(SlotLink); end

		-- If we have an item that can be in either slot, get the item in the 2nd slot as well
		if (slotno == 9) then
			SlotLink = GetInventoryItemLink("player",GetInventorySlotInfo("Trinket1Slot"));
			sName2 = "None";	
			if (SlotLink) then sName2, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(SlotLink); end
		end
		if (slotno == 11) then
			SlotLink = GetInventoryItemLink("player",GetInventorySlotInfo("Finger1Slot"));
			sName2 = "None";	
			if (SlotLink) then sName2, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(SlotLink); end
		end

		-- Nil values mess us up, switch any we find to ""
		if (set1 == nil) then set1 = ""; end
		if (set2 == nil) then set2 = ""; end
		if (set3 == nil) then set3 = ""; end
		if (cost1 == nil) then cost1 = ""; end
		if (cost2 == nil) then cost2 = ""; end
		if (cost3 == nil) then cost3 = ""; end
		if (name1 == nil) then name1 = ""; end
		if (name2 == nil) then name2 = ""; end
		if (name3 == nil) then name3 = ""; end

		-- Add the prefixes to all the name variables
		if (name2 ~= "") then
			name2 = set2 .. name2
		end
		if (name3 ~= "") then
			name3 = set3 .. name3
		end

		-- Now that we have the entire name, check to see if we need to translate it
		if GetLocale() ~= "enUS" then
			if name1 ~= "" then name1 = GetItemInfo(NameToID[name1]); end
			if name2 ~= "" then name2 = GetItemInfo(NameToID[name2]); end
			if name3 ~= "" then name3 = GetItemInfo(NameToID[name3]); end
			-- If we haven't seen the item before, it returns nil
			-- However, a second attempt WILL pull the item name
			if name1 == nil then name1 = GetItemInfo(NameToID[name1]); end
			if name2 == nil then name2 = GetItemInfo(NameToID[name2]); end
			if name3 == nil then name3 = GetItemInfo(NameToID[name3]); end
		end

		-- Switch to the 2nd trinket if the first has no match
		if slotno == 9 then
			if (sName ~= name1 and sName ~= name2 and sName ~= name3) or sName == "None" then
				sName = sName2
			end
		end

		-- Switch to the 2nd ring if the first has no match
		if slotno == 11 then
			if (sName ~= name1 and sName ~= name2 and sName ~= name3) or sName == "None" then
				sName = sName2
			end
		end

		-- Pick our items to scroll in
		item1 = ""
		item2 = ""
		item3 = ""			
		if (phaseno == 1) then
			if (name3 == "") then return; end
			if (name3 == sName) then return; end
			if (name3 ~= "") then
				item1 = name3 .. " " .. cost3
			end
		end

		if (phaseno == 2) then
			if (name2 == "") then return; end
			if (name3 == sName) then return; end
			if (name2 == sName) then return; end
			if (name1 == sName) then
				item1 = name2 .. " " .. cost2
				item2 = name3 .. " " .. cost3
			else
				--item1 = name1 .. " " .. cost1
				item1 = name2 .. " " .. cost2
				if (name3 ~= "") then
					item2 = name3 .. " " .. cost3
				else
					item2 = ""
				end
			end
		end

		if (phaseno == 3) then
			if (name1 == "") then return; end
			if (name3 == sName) then return; end
			if (name2 == sName) then return; end
			if (name1 == sName) then return; end
			item1 = name1 .. " " .. cost1
			item2 = name2 .. " " .. cost2
			item3 = name3 .. " " .. cost3
		end

		if (item3 ~= "") then
			item1 = Language.Good .. item1
			item2 = Language.Better .. item2
			item3 = Language.Best ..item3
		else
			if (item2 ~= "") then
				item1 = Language.Good .. item1
				item2 = Language.Best .. item2
			else
				item1 = Language.Best .. item1
			end 
		end

		-- Since we're adding to the list if we make it here,
		-- slide everything down
		Text061:SetText(Text051:GetText());
		Text062:SetText(Text052:GetText());
		Text063:SetText(Text053:GetText());
		Text051:SetText(Text041:GetText());
		Text052:SetText(Text042:GetText());
		Text053:SetText(Text043:GetText());
		Text041:SetText(Text031:GetText());
		Text042:SetText(Text032:GetText());
		Text043:SetText(Text033:GetText());
		Text031:SetText(Text021:GetText());
		Text032:SetText(Text022:GetText());
		Text033:SetText(Text023:GetText());
		Text021:SetText(Text011:GetText());
		Text022:SetText(Text012:GetText());
		Text023:SetText(Text013:GetText());
		Text011:SetText(item1);
		Text012:SetText(item2);
		Text013:SetText(item3);
end

