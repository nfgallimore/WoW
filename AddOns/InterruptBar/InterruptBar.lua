----------------------------------------------------
-- Interrupt Bar by Kollektiv
----------------------------------------------------

-- Add new abilities here. Order is determined as shown.
local abilities = {
	{spellid = 2139,   duration = 20},   -- Counterspell
	{spellid = 19647,  duration = 24},   -- Spell Lock
	{spellid = 57994,  duration = 12},   -- Wind Shear
	{spellid = 6552,   duration = 15},   -- Pummel
	{spellid = 47528,  duration = 15},   -- Mind Freeze
	{spellid = 1766,   duration = 15},   -- Kick
	{spellid = 80965,  duration = 15},   -- Skull Bash
	{spellid = 96231,  duration = 15},   -- Rebuke
	{spellid = 116705, duration = 15},   -- Spear Hand Strike
	{spellid = 78675,  duration = 60},   -- Solar Beam
}

-----------------------------------------------------
-----------------------------------------------------

InterruptBarDB = InterruptBarDB or { scale = 1, hidden = false, lock = false, }

for _,ability in ipairs(abilities) do
	local _,_,spellicon = GetSpellInfo(ability.spellid)
	ability.icon = spellicon
end

local SPELLLOCK = 19647
local OPTICALBLAST = 115781
local OPTICALBLASTSAC = 132409

local order
local frame
local bar
local btns = {}

local band = bit.band
local GetTime = GetTime
local ipairs = ipairs
local pairs = pairs
local select = select
local floor = floor
local ceil = math.ceil
local band = bit.band
local GetSpellInfo = GetSpellInfo

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
	btn:SetWidth(30)
	btn:SetHeight(30)
	btn:SetFrameStrata("LOW")

	local cd = CreateFrame("Cooldown",nil,btn)
	cd.noomnicc = true
	cd.noCooldownCount = true
	cd:SetAllPoints(true)
	cd:SetFrameStrata("MEDIUM")
	cd:Hide()

	local texture = btn:CreateTexture(nil,"BACKGROUND")
	texture:SetAllPoints(true)
	texture:SetTexture(ability.icon)
	texture:SetTexCoord(0.07,0.9,0.07,0.90)

	local text = cd:CreateFontString(nil,"ARTWORK")
	text:SetFont(STANDARD_TEXT_FONT,18,"OUTLINE")
	text:SetTextColor(1,1,0,1)
	text:SetPoint("LEFT",btn,"LEFT",2,0)

	btn.texture = texture
	btn.text = text
	btn.duration = ability.duration
	btn.cd = cd

	btn.activate = function()
		if btn.active then return end
		if InterruptBarDB.hidden then btn:Show() end
		btn.start = GetTime()
		btn.cd:Show()
		btn.cd:SetCooldown(GetTime()-0.40,btn.duration)
		btn.start = GetTime()
		btn.settimeleft(btn.duration)
		btn:SetScript("OnUpdate", InterruptBar_OnUpdate)
		btn.active = true
	end

	btn.deactivate = function()
		if InterruptBarDB.hidden then btn:Hide() end
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
			btn.text:SetTextColor(1,0,0,1)
		else 
			btn.text:SetTextColor(1,1,0,1) 
		end
		if timeleft > 60 then
			btn.text:SetFont(STANDARD_TEXT_FONT,14,"OUTLINE")
		else
			btn.text:SetFont(STANDARD_TEXT_FONT,18,"OUTLINE")
		end
	end

	return btn
end

local function InterruptBar_AddIcons()
	local x = -45
	for _,ability in ipairs(abilities) do
		local btn = InterruptBar_CreateIcon(ability)
		btn:SetPoint("CENTER", bar, "CENTER", x, 0)
		btns[ability.spellid] = btn
		x = x + 30
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
		for _,btn in pairs(btns) do btn:Hide() end
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
	bar:SetWidth(120)
	bar:SetHeight(30)
	bar:SetClampedToScreen(true) 
	bar:SetScript("OnMouseDown",function(self,button) if button == "LeftButton" then self:StartMoving() end end)
	bar:SetScript("OnMouseUp",function(self,button) if button == "LeftButton" then self:StopMovingOrSizing() InterruptBar_SavePosition() end end)
	bar:Show()
	
	InterruptBar_AddIcons()
	InterruptBar_UpdateBar()
	InterruptBar_LoadPosition()
end

local function InterruptBar_COMBAT_LOG_EVENT_UNFILTERED(_, eventtype, _, _, srcName, srcFlags, _, _, dstName, dstFlags, _, spellid)
	if band(srcFlags, 0x00000040) == 0x00000040 and eventtype == "SPELL_CAST_SUCCESS" then 
		-- Redirect Optical Blast to Spell Lock
		if (spellid == OPTICALBLAST or spellid == OPTICALBLASTSAC) and btns[SPELLLOCK] then
			spellid = SPELLLOCK
		end
		local btn = btns[spellid]
		if btn then btn.activate() end
	end
end

local function InterruptBar_ResetAllTimers()
	for _,btn in pairs(btns) do
		btn.deactivate()
	end
end

local function InterruptBar_PLAYER_ENTERING_WORLD(self)
	InterruptBar_ResetAllTimers()
end

local function InterruptBar_Reset()
	InterruptBarDB = { scale = 1, hidden = false, lock = false }
	InterruptBar_UpdateBar()
	InterruptBar_LoadPosition()
end

local function InterruptBar_Test()
	for _,btn in pairs(btns) do
		btn.activate()
	end
end

local cmdfuncs = {
	scale = function(v) InterruptBarDB.scale = v; InterruptBar_UpdateBar() end,
	hidden = function() InterruptBarDB.hidden = not InterruptBarDB.hidden; InterruptBar_UpdateBar() end,
	lock = function() InterruptBarDB.lock = not InterruptBarDB.lock; InterruptBar_UpdateBar() end,
	reset = function() InterruptBar_Reset() end,
	test = function() InterruptBar_Test() end,
}

local cmdtbl = {}
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
  	ChatFrame1:AddMessage("InterruptBar Options | /ib <option>",0,1,0)  	
  	ChatFrame1:AddMessage("-- scale <number> | value: " .. InterruptBarDB.scale,0,1,0)
  	ChatFrame1:AddMessage("-- hidden (toggle) | value: " .. tostring(InterruptBarDB.hidden),0,1,0)
  	ChatFrame1:AddMessage("-- lock (toggle) | value: " .. tostring(InterruptBarDB.lock),0,1,0)
  	ChatFrame1:AddMessage("-- test (execute)",0,1,0)
  	ChatFrame1:AddMessage("-- reset (execute)",0,1,0)
  end
end

local function InterruptBar_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	if not InterruptBarDB.scale then InterruptBarDB.scale = 1 end
	if not InterruptBarDB.hidden then InterruptBarDB.hidden = false end
	if not InterruptBarDB.lock then InterruptBarDB.lock = false end
	InterruptBar_CreateBar()
	
	SlashCmdList["InterruptBar"] = InterruptBar_Command
	SLASH_InterruptBar1 = "/ib"
	
	ChatFrame1:AddMessage("Interrupt Bar by Kollektiv. Type /ib for options.",0,1,0)
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
