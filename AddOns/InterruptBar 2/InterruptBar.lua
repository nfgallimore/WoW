--[[
------------------------------
Originally made by Kollektiv @ http://www.curse.com/users/kollektiv
Modified by Wardz
------------------------------

You can add your own spells to InterruptBar down below. Just follow this form:
{spellid = spell to track,
	duration = spell's cooldown},

"spellid" is the id of the spell you want to track. You can find a spell's id by searching for it on wowhead.com.
The numbers you see at the end of the URL will be the spell's id.
http://wowhead.com/spell=103135 <----- example

"duration" is the spell's cooldown in seconds.
]]

local abilities = {

	-- Wind Shear
	{spellid = 57994,
		duration = 12},

	-- Pummel
	{spellid = 6552,
		duration = 15},

	-- Mind Freeze
	{spellid = 47528,	
		duration = 15},

	-- Kick
	{spellid = 1766,
		duration = 15},

	-- Rebuke
	{spellid = 96231,
		duration = 15},

	-- Spear Hand Strike
	{spellid = 116705,
		duration = 15},

	-- Skull Bash
	{spellid = 80965,
		duration = 15},

	-- Death Grip
	{spellid = 49576,
		duration = 25},

	-- Grounding Totem
	{spellid = 8177,
		duration = 22}, -- 25 if not a resto shaman

	-- Silencing Shot
	{spellid = 34490,
		duration = 24},

	-- Counterspell
	{spellid = 2139,
		duration = 24},

	-- Spell Lock
	{spellid = 19647,
		duration = 24},

	-- Leap
	{spellid = 47482,
		duration = 30},

	--[[ Pummel (Hunter Pet Ability)
	{spellid = 26090,
		duration = 30},
	]]

	--[[ Nether Shock (Hunter Pet Ability)
	{spellid = 50318,
		duration = 40},
	]]

	-- Silence
	{spellid = 15487,
		duration = 45},

	-- Solar Beam
	{spellid = 78675,
		duration = 60},

	-- Strangulate
	{spellid = 47476,
		duration = 60},

	--[[ Serenity Dust (Hunter Pet Ability)
	{spellid = 50318,
		duration = 60},
	]]
}

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
InterruptBarDB = InterruptBarDB or { scale = 1, hidden = false, lock = false, rows = 1, texthide = false, textsize = 18, textpos = 1, border = false, offset = 30, alpha = false, --[[nobg = false]] }
for _,ability in ipairs(abilities) do local _,_,spellicon = GetSpellInfo(ability.spellid);ability.icon = spellicon end

local frame
local bar
local btns = {}
local cmdtbl = {}
local band = bit.band
local ceil = math.ceil
--local inInstance, instanceType = IsInInstance()

local function InterruptBar_OnUpdate(self)
	local cooldown = self.start + self.duration - GetTime()
	if cooldown <= 0 then
		self.deactivate()
	else 
		self.settimeleft(ceil(cooldown))
	end
end

local function InterruptBar_CreateIcon(ability)
	local btn = CreateFrame("Frame",nil,bar)

	if InterruptBarDB.border then
		-- Need's a lot of position tweaking
		local addArtW = btn:CreateTexture(nil,"ARTWORK")
		addArtW:SetAllPoints(btn)
		addArtW:SetTexture("Interface\\AddOns\\InterruptBar\\media\\Normal.tga")
		addArtW:SetTexCoord(.08, .92, .08, .92)

		local addBack = btn:CreateTexture(nil,"BACKGROUND")
		addBack:SetAllPoints(btn)
		addBack:SetTexture("Interface\\AddOns\\InterruptBar\\media\\Backdrop.tga")
		addBack:SetTexCoord(.08, .92, .08, .92)
		addBack:SetAlpha(0)

		local addLay = btn:CreateTexture(nil,"OVERLAY")
		addLay:SetAllPoints(btn)
		addLay:SetTexture("Interface\\AddOns\\InterruptBar\\media\\Gloss.tga")
		addLay:SetTexCoord(.08, .92, .08, .92)
		addLay:SetAlpha(.7)
	end

	btn:SetWidth(30)
	btn:SetHeight(30)
	btn:SetFrameStrata("LOW")

	local cd = CreateFrame("Cooldown",nil,btn)
	cd.noomnicc = true
	cd.noCooldownCount = true
	cd.noOCC = true
	cd:SetAllPoints(true)
	cd:SetFrameStrata("MEDIUM")
	cd:Hide()

	local texture = btn:CreateTexture(nil,"BORDER")
	texture:SetAllPoints(true)
	texture:SetTexture(ability.icon)
	texture:SetTexCoord(0.07,0.9,0.07,0.90)
	local size = InterruptBarDB.textsize
	local size2 = InterruptBarDB.textsize - 4

	local text = cd:CreateFontString(nil,"ARTWORK")
	text:SetFont(STANDARD_TEXT_FONT, size,"OUTLINE") --

	if not InterruptBarDB.texthide then
		text:SetTextColor(1,1,0,1)
	else
		text:SetTextColor(0,0,0,0)
	end


	local textposition
	-- Temporary method only lol
	if InterruptBarDB.textpos == 1 then
		textposition = "LEFT"
	elseif InterruptBarDB.textpos == 2 then
		textposition = "RIGHT"
	elseif InterruptBarDB.textpos == 3 then
		textposition = "TOP"
	elseif InterruptBarDB.textpos == 4 then
		textposition = "BOTTOM"
	elseif InterruptBarDB.textpos == 5 then
		textposition = "TOPLEFT"
	elseif InterruptBarDB.textpos == 6 then
		textposition = "TOPRIGHT"
	elseif InterruptBarDB.textpos == 7 then
		textposition = "BOTTOMLEFT"
	elseif InterruptBarDB.textpos == 8 then
		textposition = "BOTTOMRIGHT"
	end

	text:SetPoint(textposition,btn,textposition,2,0)
	btn.texture = texture
	btn.text = text

	if COUNTERSPELLONCAST then
		btn.duration = ability.duration - 4
	elseif ASPTOSTRANG then
		btn.duration = ability.duration - 30
	elseif resetGROUNDING then
		btn.duration = 0
	else
		btn.duration = ability.duration
	end

	btn.cd = cd

	btn.activate = function()
		if btn.active then return end
		if InterruptBarDB.hidden then btn:Show() end
		btn:SetAlpha(1)

		btn.start = GetTime()
		btn.cd:Show()
		btn.cd:SetCooldown(GetTime()-0.40,btn.duration)
		btn.start = GetTime()
		btn.settimeleft(btn.duration)
		btn:SetScript("OnUpdate", InterruptBar_OnUpdate)
		btn.active = true
	end

	btn.deactivate = function()
		if not InterruptBarDB.alpha then
			if InterruptBarDB.hidden then 
				btn:Hide() 
			end
		end
		if InterruptBarDB.alpha then btn:SetAlpha(0.30) end
		btn.text:SetText("")
		btn.cd:Hide()
		btn:SetScript("OnUpdate", nil)
		btn.active = false
	end

	btn.settimeleft = function(timeleft)
		if timeleft < 10 then
			if timeleft <= 0.5 then
				btn.text:SetText("")
			else
				btn.text:SetFormattedText(" %d",timeleft)
			end
		else
			btn.text:SetFormattedText("%d",timeleft)
		end

		if timeleft < 6 then
			if not InterruptBarDB.texthide then
				btn.text:SetTextColor(1,0,0,1)
			else
				btn.text:SetTextColor(0,0,0,0)
			end
		else
			if not InterruptBarDB.texthide then
				btn.text:SetTextColor(1,1,0,1)
			else
				btn.text:SetTextColor(0,0,0,0)
			end
		end

		if timeleft > 60 then
			btn.text:SetFont(STANDARD_TEXT_FONT, size2,"OUTLINE")
		else
			btn.text:SetFont(STANDARD_TEXT_FONT, size,"OUTLINE")
		end
	end

	return btn
end

local function InterruptBar_AddIcons()
	local y = -45
	local x = 0
	local offset = InterruptBarDB.offset
	local height = InterruptBarDB.rows
	local count = 0

	for _,ability in ipairs(abilities) do
		if count > height then
			y = -45
			x = x + offset
			count = 0
		end

		local btn = InterruptBar_CreateIcon(ability)
		btn:SetPoint("CENTER", bar, "CENTER", x, y)
		btns[ability.spellid] = btn
		y = y + InterruptBarDB.offset
		count = count + 1
	end
end

local function InterruptBar_SavePosition()
	local point, _, relativePoint, xOfs, yOfs = bar:GetPoint()
	if not InterruptBarDB.Position then 
		InterruptBarDB.Position = {}
	end

	InterruptBarDB.Position.point = point
	InterruptBarDB.Position.relativePoint = relativePoint
	InterruptBarDB.Position.xOfs = xOfs
	InterruptBarDB.Position.yOfs = yOfs
end

local function InterruptBar_LoadPosition()
	if InterruptBarDB.Position then
		bar:SetPoint(InterruptBarDB.Position.point,UIParent,InterruptBarDB.Position.relativePoint,InterruptBarDB.Position.xOfs,InterruptBarDB.Position.yOfs)
	else
		bar:SetPoint("CENTER", UIParent, "CENTER")
	end
end

local function InterruptBar_UpdateBar()
	bar:SetScale(InterruptBarDB.scale)

	if InterruptBarDB.hidden then
		for _,btn in pairs(btns) do btn.deactivate(); btn:Hide() end
	else
		for _,btn in pairs(btns) do btn:Show() end
	end

	if InterruptBarDB.lock then
		bar:EnableMouse(false)
	else
		bar:EnableMouse(true)
	end
end

local function InterruptBar_CreateBar()
	bar = CreateFrame("Frame", nil, UIParent)
	bar:SetMovable(true)
	bar:SetWidth(500) -- Change on amount of rows in the future
	bar:SetHeight(200) --
	bar:SetClampedToScreen(true) 
	bar:SetScript("OnMouseDown",function(self,button) if button == "LeftButton" then self:StartMoving() end end)
	bar:SetScript("OnMouseUp",function(self,button) if button == "LeftButton" then self:StopMovingOrSizing() InterruptBar_SavePosition() end end)
	bar:Show()
	
	InterruptBar_AddIcons()
	InterruptBar_UpdateBar()
	InterruptBar_LoadPosition()
end

local function InterruptBar_COMBAT_LOG_EVENT_UNFILTERED(_, eventtype, _, srcGUID, srcName, srcFlags, _, _, dstName, dstFlags, _, spellid)
	if band(srcFlags, 0x00000040) == 0x00000040 and eventtype == "SPELL_CAST_SUCCESS" then 
		-- Redirect warlock interrupts to spell lock
		if (spellid == 115781 or spellid == 132409 or spellid == 103135) and btns[19647] then
			spellid = 19647
		end

		-- Show CD on pummel when Disrupting Shout is used, since they now share CD
		if (spellid == 102060) and btns[6552] then
			spellid = 6552
		end

		-- Redirect Counter shot to silencing shot
		if (spellid == 147362) and btns[34490] then
			spellid = 34490
		end

		-- Redirect Skull bashes
		if (spellid == 80964 or spellid == 106839) and btns[80965] then
			spellid = 80965
		end

		-- UNTESTED!
		-- Reduce cooldown on counterspell by 4 seconds when interrupted on cast (pvp setbonus)
		-- To do: Include party12345 and not just player.
		if (spellid == 2139) and btns[2139] then
			if eventtype == "SPELL_INTERRUPT" and srcGUID == UnitName("player") then
				local COUNTERSPELLONCAST = true
			end
		end

		-- Redirect Symbiosis: Solar Beam to Solar Beam
		if (spellid == 113286) and btns[78675] then
			spellid = 78675
		end

		-- UNTESTED!
		-- Show 30 sec CD on strangulate when Asphyxiate is used
		if (spellid == 108194) and btns[47476] then
			local ASPTOSTRANG = true
		end

		-- UNTESTED!
		-- Reset CD on Grounding Totem if Call of the Elements is used.
		if (spellid == 108285) and btns[8177] then
			local resetGROUNDING = true
		end

		local btn = btns[spellid]
		if btn then btn.activate() end
	end
end

local function InterruptBar_PLAYER_ENTERING_WORLD(self)
	for _,btn in pairs(btns) do btn.deactivate() end
end

local function InterruptBar_Reset()
	InterruptBarDB = { scale = 1, hidden = false, lock = false, rows = 1, texthide = false, textsize = 18, textpos = 1, border = false, offset = 30, alpha = false, --[[nobg = false]] } 
	InterruptBar_UpdateBar()
	InterruptBar_LoadPosition()
end

local cmdfuncs = {
	scale = function(v) InterruptBarDB.scale = v; InterruptBar_UpdateBar() end,
	rows = function(v) InterruptBarDB.rows = v; ReloadUI() end,
	border = function() InterruptBarDB.border = not InterruptBarDB.border; ReloadUI() end,
	texthide = function() InterruptBarDB.texthide = not InterruptBarDB.texthide; ReloadUI() end,
	textsize = function(v) InterruptBarDB.textsize = v; ReloadUI() end,
	textpos = function(v) InterruptBarDB.textpos = v; ReloadUI() end,
	offset = function(v) InterruptBarDB.offset = v; ReloadUI() end,
	alpha = function() InterruptBarDB.alpha = not InterruptBarDB.alpha; ReloadUI() end,
	--nobg = function() InterruptBarDB_nobg = not InterruptBarDB_nobg end,
	hidden = function() InterruptBarDB.hidden = not InterruptBarDB.hidden; InterruptBar_UpdateBar() end,
	lock = function() InterruptBarDB.lock = not InterruptBarDB.lock; InterruptBar_UpdateBar() end,
	reset = function() InterruptBar_Reset(); ReloadUI() end,
	test = function() for _,btn in pairs(btns) do btn.activate() end end,
}

function InterruptBar_Command(cmd)
	for k in ipairs(cmdtbl) do
		cmdtbl[k] = nil
	end

	for v in gmatch(cmd, "[^ ]+") do
		tinsert(cmdtbl, v)
	end

	local cb = cmdfuncs[cmdtbl[1]]
	if cb then
		local s = tonumber(cmdtbl[2])
		cb(s)
	else
		StaticPopup_Show ("InterruptBar_Settings")
	end
end

local function InterruptBar_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	if not InterruptBarDB.scale then InterruptBarDB.scale = 1 end
	if not InterruptBarDB.rows then InterruptBarDB.rows = 1 end
	if not InterruptBarDB.border then InterruptBarDB.border = false end
	if not InterruptBarDB.texthide then InterruptBarDB.texthide = false end
	if not InterruptBarDB.textsize then InterruptBarDB.textsize = 18 end
	if not InterruptBarDB.textpos then InterruptBarDB.textpos = 1 end
	if not InterruptBarDB.hidden then InterruptBarDB.hidden = false end
	if not InterruptBarDB.lock then InterruptBarDB.lock = false end
	if not InterruptBarDB.alpha then InterruptBarDB.alpha = false end
	if not InterruptBarDB.offset then InterruptBarDB.offset = 30 end
	--if not InterruptBarDB_nobg then InterruptBarDB_nobg = false end
	InterruptBar_CreateBar()

	StaticPopupDialogs["InterruptBar_Settings"] = {
	text = ("Current InterruptBar Settings:\n" .."Scale: " .. InterruptBarDB.scale .. "\nRows: " .. InterruptBarDB.rows .."\nBorder: " .. tostring(InterruptBarDB.border) .."\nText Hidden: " .. tostring(InterruptBarDB.texthide) .."\nText Size: " .. InterruptBarDB.textsize .."\nText Position: " .. InterruptBarDB.textpos .."\nHidden: " .. tostring(InterruptBarDB.hidden) .."\nLocked: " .. tostring(InterruptBarDB.lock) .."\nOffset: " .. InterruptBarDB.offset .."\nTransparent: " .. tostring(InterruptBarDB.alpha).."\n\n/ib option <value>\n\nSee WoWInterface thread for commands."),
	button1 = "Exit",
	--button2 = "Configure",
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	}
	
	SlashCmdList["InterruptBar"] = InterruptBar_Command
	SLASH_InterruptBar1 = "/ib"
end

local eventhandler = {
	["VARIABLES_LOADED"] = function(self) InterruptBar_OnLoad(self) end,
	["PLAYER_ENTERING_WORLD"] = function(self) InterruptBar_PLAYER_ENTERING_WORLD(self) end,
	["COMBAT_LOG_EVENT_UNFILTERED"] = function(self,...) InterruptBar_COMBAT_LOG_EVENT_UNFILTERED(...) end,
}

local function InterruptBar_OnEvent(self,event,...)
	eventhandler[event](self,...)
end

frame = CreateFrame("Frame",nil,UIParent)
frame:SetScript("OnEvent",InterruptBar_OnEvent)
frame:RegisterEvent("VARIABLES_LOADED")