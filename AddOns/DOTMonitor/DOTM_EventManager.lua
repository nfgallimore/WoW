local DOTMonitor = getglobal("DOTMonitor") or {}

local Player 	= DOTMonitor.library.Player:New()
local HUD		= DOTMonitor.library.HUD:New(nil)

DOTMonitor.user = {player = Player}
DOTMonitor.interface = HUD


local DOTMonitorEventCenter_StartResponding = function() -- initialization
	DOTMonitorEventCenter:RegisterEvent("PLAYER_REGEN_DISABLED")
	DOTMonitorEventCenter:RegisterEvent("PLAYER_REGEN_ENABLED")
	DOTMonitorEventCenter:RegisterEvent("PLAYER_TALENT_UPDATE")
	DOTMonitorEventCenter:RegisterEvent("PLAYER_LEVEL_UP")
	DOTMonitorEventCenter:RegisterEvent("PLAYER_LOGOUT")
	
	DOTMonitor.logMessage("initialized!")
end




-- @ Responder Functions Implementation
-- ================================================================================
local DOTMonitorReaction_playerStartedFighting 	= function()
	HUD:SetEnabled(true)
end

local DOTMonitorReaction_playerStoppedFighting 	= function()
	HUD:SetEnabled(false)
	HUD:Unlock(false)
end

local DOTMonitorReaction_playerAbilitiesPossiblyChanged = function()
	HUD:SetEnabled(false)
	Player:Synchronize();
end

local DOTMonitorReaction_playerEnteringWorld 	= function()
	DOTMonitorReaction_playerAbilitiesPossiblyChanged()
	DOTMonitorEventCenter_StartResponding()
	DOTMonitor.printMessage("Ready", "epic")
end

local DOTMonitorReaction_playerExiting = function()
	DOTMonitorPreferences = HUD:GetPreferences()
	HUD:Unlock(true)
end

local DOTMonitorReaction_restorePreferences = function(addon)
	if addon ~= "DOTMonitor" then return false end
	
	local pref = _G["DOTMonitorPreferences"]
	HUD:InitializeWithMonitors(pref);
	Player:Delegate(HUD)
end
-- ================================================================================




-- @ Responder Mapping Implementation
-- ================================================================================
local DOTMonitorEventResponder = { -- Main Response Handeler
	["PLAYER_REGEN_DISABLED"] 	= DOTMonitorReaction_playerStartedFighting,
	["PLAYER_REGEN_ENABLED"] 	= DOTMonitorReaction_playerStoppedFighting,
	
	["PLAYER_TALENT_UPDATE"] 	= DOTMonitorReaction_playerAbilitiesPossiblyChanged,
	["PLAYER_LEVEL_UP"] 		= DOTMonitorReaction_playerAbilitiesPossiblyChanged,
	
	["PLAYER_ENTERING_WORLD"] 	= DOTMonitorReaction_playerEnteringWorld,
	["PLAYER_LOGOUT"]			= DOTMonitorReaction_playerExiting,
	
	["ADDON_LOADED"]			= DOTMonitorReaction_restorePreferences
}


-- @ Event Center Preparation Implementation
-- ================================================================================
DOTMonitorEventCenter = CreateFrame("Frame");
DOTMonitorEventCenter:SetAlpha(0);

DOTMonitorEventCenter:SetScript("OnEvent", (function(self, event, ...)
	if DOTMonitorEventResponder[event] then
		DOTMonitorEventResponder[event](...)
	end
end))

DOTMonitorEventCenter:RegisterEvent("ADDON_LOADED")
DOTMonitorEventCenter:RegisterEvent("PLAYER_ENTERING_WORLD")