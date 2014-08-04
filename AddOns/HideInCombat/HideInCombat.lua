HideInCombat = {Locals = {}}

local L = HideInCombat.Locals

HideInCombat.version = '0.1.0'
HideInCombat.tempConfig = {}

-- Our sneaky frame to watch for events ... checks HideInCombat.events[] for the function.  Passes all args.
HideInCombat.eventFrame = CreateFrame("Frame")
HideInCombat.eventFrame:SetScript("OnEvent", function(this, event, ...)
  HideInCombat.events[event](...)
end)

HideInCombat.eventFrame:RegisterEvent("PLAYER_LOGIN")

-- Define our Event Handlers here
HideInCombat.events = {}

function HideInCombat.events.PLAYER_LOGIN()
	HideInCombat:OnLoad()
	HideInCombat.eventFrame:UnregisterEvent("PLAYER_LOGIN")
end

function HideInCombat:OnLoad()
	-- load defaults, if first start
	HideInCombat:InitSettings()
	
	-- register events
	HideInCombat.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	HideInCombat.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
end

function HideInCombat:PlayerInParty()
	if (IsInRaid()) then
		return 2,"RAID"
	elseif (GetNumGroupMembers()>0) then
		return 1,"PARTY"
	else
		return 0,"SAY"
	end
end

function HideInCombat.events.PLAYER_REGEN_ENABLED(...)
	local i,docked,locked,uninteractable,_,windowName

	GeneralDockManager:Show()
	-- show all chat frames
	for i=1,NUM_CHAT_WINDOWS do
		_,_,_,_,_,_,_,locked,docked = GetChatWindowInfo(i);
		if (docked == nil) or (i==1) and (locked~=nil) then
			if (HideInCombatDB["hideChat" .. i]) then
				local chatFrame = _G["ChatFrame"..i]
				chatFrame:Show()
			end
		end
	end

	FriendsMicroButton:Show()
	ChatFrameMenuButton:Show()

	GameTooltip:SetScript("OnShow", nil)
	
	MinimapCluster:Show()

	if (HideInCombatDB.announce) and (HideInCombatDB.hideChat) then
		local party, chat = HideInCombat:PlayerInParty()
		SendChatMessage(L.CONFIG_ANNOUNCEMENT_OFF, chat, nil, nil)
	end
end

function HideInCombat.events.PLAYER_REGEN_DISABLED(...)
	local i,shown,_
	local party, chat = HideInCombat:PlayerInParty()
	if ( (HideInCombatDB.enabled) and
		(
			( (party == 2) and HideInCombatDB.inRaid) or
			( (party == 1) and HideInCombatDB.inParty) or
			( (party == 0) and HideInCombatDB.inSolo)
		)
	) then
		if (HideInCombatDB.hideChat) then
			GeneralDockManager:Hide()
			-- hide all chat frames
			for i=1,NUM_CHAT_WINDOWS do
				_,_,_,_,_,_,shown = GetChatWindowInfo(i);
				if (shown ~= nil) then
					if (HideInCombatDB["hideChat" .. i]) then
						local chatFrame = _G["ChatFrame"..i]
						chatFrame:Hide()
					end
				end
			end

			FriendsMicroButton:Hide()
			ChatFrameMenuButton:Hide()

			if (HideInCombatDB.announce) then
				SendChatMessage(L.CONFIG_ANNOUNCEMENT_ON, chat, nil, nil)
			end
		end
		if (HideInCombatDB.hideTooltip) then
			GameTooltip:Hide()
			GameTooltip:SetScript("OnShow", GameTooltip.Hide)
		end
		if (HideInCombatDB.hideMinimap) then
			MinimapCluster:Hide()
		end
	end
end

function HideInCombat:DefaultSettings()
	HideInCombatDB = {
		enabled = true,
		inSolo = false,
		inParty	= false,
		inRaid = true,
		hideChat = true,
		hideTooltip = true,
		hideMinimap = true,
		announce = false,
	} -- fresh start
end

function HideInCombat:InitSettings()
	if not HideInCombatDB then 
		HideInCombat:DefaultSettings()
	end

	SlashCmdList["HideInCombat"] = HideInCombat.Options
	SLASH_HideInCombat1 = "/hideincombat"
	SLASH_HideInCombat2 = "/hic"
	HideInCombat:CreateConfig()
	
	DEFAULT_CHAT_FRAME:AddMessage("HideInCombat " .. HideInCombat.version .. " loaded")
end

function HideInCombat:CreateLabel(name, parent)
	local label = parent:CreateFontString(nil)
	label:SetFontObject(GameFontNormal)
	label:SetTextColor(1, 1, 1, 1)
	label:SetText(name)
	
	return label
end

function HideInCombat:CreateCheckButton(name, parent, table, field, radio)
	local button
	if radio then
		button = CreateFrame('CheckButton', parent:GetName() .. name, parent, 'SendMailRadioButtonTemplate')
	else
		button = CreateFrame('CheckButton', parent:GetName() .. name, parent, 'OptionsCheckButtonTemplate')
	end
	local frame = _G[button:GetName() .. 'Text']
	frame:SetText(name)
	frame:SetTextColor(1, 1, 1, 1)
	frame:SetFontObject(GameFontNormal)
	button:SetScript("OnShow", 
		function (self) 
			self:SetChecked(table[field]) 
			self.origValue = table[field] or self.origValue
		end 
	)
	if radio then
		button:SetScript("OnClick", 
			function (self, button, down)
				this:SetChecked(1)
				table[field] = not table[field]
			end 
		)
	else
		button:SetScript("OnClick", 
			function (self, button, down) 
				table[field] = not table[field]
			end
		)
	end

	function button:Restore() 
		table[field] = self.origValue 
	end 
	return button 
end

function HideInCombat.Options()
	InterfaceOptionsFrame_OpenToCategory(getglobal("HideInCombatConfigPanel"))
end

function HideInCombat:CreateConfig()
	local _,i,windowName,docked,shown,chatWinCount
	
	HideInCombat.configPanel = CreateFrame( "Frame", "HideInCombatConfigPanel", UIParent )
	HideInCombat.configPanel.name = "Hide In Combat"

	HideInCombat:CreateCheckButton(L.CONFIG_ENABLED, HideInCombat.configPanel, HideInCombatDB, "enabled", false):SetPoint('TOPLEFT', 10, -8)
	HideInCombat:CreateCheckButton(L.CONFIG_HIDE_IN_SOLO, HideInCombat.configPanel, HideInCombatDB, "inSolo", false):SetPoint('TOPLEFT', 10, -38)
	HideInCombat:CreateCheckButton(L.CONFIG_HIDE_IN_PARTY, HideInCombat.configPanel, HideInCombatDB, "inParty", false):SetPoint('TOPLEFT', 10, -58)
	HideInCombat:CreateCheckButton(L.CONFIG_HIDE_IN_RAID, HideInCombat.configPanel, HideInCombatDB, "inRaid", false):SetPoint('TOPLEFT', 10, -78)
	HideInCombat:CreateCheckButton(L.CONFIG_HIDE_CHATWINDOW, HideInCombat.configPanel, HideInCombatDB, "hideChat", false):SetPoint('TOPLEFT', 10, -108)

	chatWinCount = 0
	for i=1,NUM_CHAT_WINDOWS do
		windowName,_,_,_,_,_,shown = GetChatWindowInfo(i);
		if (shown ~= nil) and (windowName ~= "") then
			HideInCombat:CreateCheckButton(windowName, HideInCombat.configPanel, HideInCombatDB, "hideChat" .. i, false):SetPoint('TOPLEFT', 30, -128 - chatWinCount*30)
			chatWinCount = chatWinCount + 1
		end
	end

	HideInCombat:CreateCheckButton(L.CONFIG_HIDE_TOOLTIP, HideInCombat.configPanel, HideInCombatDB, "hideTooltip", false):SetPoint('TOPLEFT', 10, -128 - chatWinCount*30)
	HideInCombat:CreateCheckButton(L.CONFIG_HIDE_MINIMAP, HideInCombat.configPanel, HideInCombatDB, "hideMinimap", false):SetPoint('TOPLEFT', 10, -158 - chatWinCount*30)
	HideInCombat:CreateCheckButton(L.CONFIG_ANNOUNCE, HideInCombat.configPanel, HideInCombatDB, "announce", false):SetPoint('TOPLEFT', 10, -188 - chatWinCount*30)

	HideInCombat.configPanel.okay = function()
	end
	HideInCombat.configPanel.cancel = function()
		-- cancel button pressed, revert changes
		for i,v in pairs(HideInCombat.tempConfig) do
			HideInCombatDB[i]=v
		end
	end
	HideInCombat.configPanel.default = function()
		HideInCombat:DefaultSettings()
	end
	HideInCombat.configPanel:SetScript('OnShow', function(self)
		for i,v in pairs(HideInCombatDB) do
			HideInCombat.tempConfig[i]=v
		end
	end)
	InterfaceOptions_AddCategory(HideInCombat.configPanel)
end
