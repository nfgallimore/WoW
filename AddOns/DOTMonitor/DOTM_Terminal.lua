SLASH_DOTMonitor_COMMAND1, SLASH_DOTMonitor_COMMAND2 = "/dotmonitor", "/dmon"

local DOTMonitor = getglobal("DOTMonitor") or {}




-- @ Terminal Functions Implementation
-- ================================================================================
local DOTMonitorCommand_getHelp = (function()
	DOTMonitorTerminal:GetCommandHelp()
	return DOTMonitorTerminal.separator
end)

local DOTMonitorCommand_setDraggable = (function(canMove)
	local shouldMove = (canMove == "on") or (canMove == "yes")
	DOTMonitor.interface:Unlock(shouldMove)
	return "HUD "..(shouldMove and "Unlocked" or "Locked")
end)

local DOTMonitorCommand_setPreferences = (function(shouldReset)
	local HUD = DOTMonitor.interface
	HUD:ResetSettings((shouldReset ~= nil) and (shouldReset == "clear" or shouldReset == "reset") or false)
	return "Preferences will be "..(HUD.settings.persist and "kept" or "reset")
end)

-- @ Terminal Methods Implementation
-- ================================================================================
DOTMonitorTerminal = {	-- Main
	separator 	= "============================================",
	command 	= nil	-- The Command
}
DOTMonitorTerminal.executables = {
	["help"] = DOTMonitorCommand_getHelp,
	["move"] = DOTMonitorCommand_setDraggable,
	["pref"] = DOTMonitorCommand_setPreferences
}

DOTMonitorTerminal.commandHelp = {
	["help"] = "This help message",
	["move"] = "Lock/Unlock the HUD (on/yes)",
	["pref"] = "Reset HUD preferences (clear/reset)",
}


DOTMonitorTerminal.HasValidCommand = (function(self)
	return (string.len(self.command) >= 4)
end)

DOTMonitorTerminal.GetCommand = (function(self)
	return self:HasValidCommand() and string.sub(self.command, 1, 4) or false
end)

DOTMonitorTerminal.GetCommandHelp = (function(self)
	DOTMonitor.printMessage(self.separator)
	DOTMonitor.printMessage("The following commands are recognized:")
	for aPos, aCommand in pairs(self.executables) do
		DOTMonitor.printMessage(aPos .. " ->"..self.commandHelp[aPos])
	end
	return self.separator;
end)

DOTMonitorTerminal.HasFunction = (function(self, aFunction)
	return (type(self.executables[aFunction]) == "function")
end)

DOTMonitorTerminal.HasArguments = (function(self)
	return (string.len(self.command) >= 6)
end)

DOTMonitorTerminal.GetArguments = (function(self)
	return (self:HasArguments() and string.sub(self.command, 6)) or nil
end)


DOTMonitorTerminal.Execute = (function(self, aCommand)
	DOTMonitorTerminal.command = aCommand;
	local aFunction 	= DOTMonitorTerminal:GetCommand()
	local result		= nil
	local executable 	= DOTMonitorTerminal:HasFunction(aFunction)
	
	if executable then
		result = self.executables[aFunction](self:GetArguments())
		DOTMonitor.logMessage("Called: "..aFunction.."("..(self:HasArguments() and self:GetArguments() or "")..")")
	else
		result = self:GetCommandHelp()
	end
	
	DOTMonitor.printMessage(result, "info")
end)



-- Registration:
SlashCmdList["DOTMonitor_COMMAND"] = (function(aCommand, origin)
	DOTMonitorTerminal:Execute(aCommand);
end)