local DOTMonitor = getglobal("DOTMonitor") or {}
if not DOTMonitor.library then DOTMonitor.library = {} end

-- @ Player Methods Implementation
-- ================================================================================
local Player = {}; DOTMonitor.library.Player = Player;

Player.Synchronize = function(self)

	if not self.info.class then
		self.info = DOTMonitor.inspector.getPlayerInfo()
	else
		local newInfo = DOTMonitor.inspector.getPlayerInfo()
		if (self.info.spec.name ~= newInfo.spec.name) or (self.info.level ~= newInfo.level) then
			self.info = newInfo
		else
			return false
		end
	end
	
	if not self.info.spec then 
		DOTMonitor.logMessage("Player not ready!")
		return nil;
	end-- Player can't be tracked -> Don't Initialize
	
	local allDebuffs = DOTMonitor.utility.getAbilitiesForPlayer("debuffs", self)
	self.spec = {debuff = DOTMonitor.inspector.getPossibleAbilities(allDebuffs)}
	
	self:ShowMonitoringInfo()
	if self:Ready() and self.delegate then self.delegate:SynchronizeWithPlayer(self) end
end

Player.Delegate = function(self, ...)
	if ... then
		self.delegate = (select(1,...))
	else
		return self.delegate
	end
end

Player.Ready = function(self)
	return self.info.spec.name and self.spec and true or false
end

Player.GetAbilities = function(self, abilityType)
	return self.spec[abilityType]
end

Player.GetAbility = function(self, abilityType, position)
	local playerAbilities = self:GetAbilities(abilityType) 
	return playerAbilities.spell[position], playerAbilities.effect[position]
end

Player.InBattle = function(self, ...)
	if type((select(1,...))) == "boolean" then
		self.info.battling = (select(1,...))
	end
	return self.info.battling
end

Player.ShowMonitoringInfo = function(self)
	DOTMonitor.printMessage(("adjusted for "..self.info.spec.name.." "..self.info.class), "info")
	for aPos, aSpell in ipairs(self.spec.debuff.spell) do
		DOTMonitor.printMessage(("Tracking: "..aSpell))
	end
end

Player.New = function(self)
	return { -- Player Instance
		info = {
			class			= nil,
			spec			= nil,
			level 			= nil,
			healthMax 		= nil,
			battling		= nil
		},
		spec = {
			debuff = nil
		},
		delegate = nil,
		
		-- Methods
		Synchronize 		= self.Synchronize,
		Delegate			= self.Delegate,
		Ready				= self.Ready,
		GetAbilities		= self.GetAbilities,
		GetAbility			= self.GetAbility,
		InBattle			= self.InBattle,
		ShowMonitoringInfo	= self.ShowMonitoringInfo
	}
end