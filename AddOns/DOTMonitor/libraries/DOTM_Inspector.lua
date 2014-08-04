local DOTMonitor = getglobal("DOTMonitor") or {}

-- @ Inspector Library Implementation
-- ================================================================================
DOTMonitor.inspector = {} -- Inspector Library

DOTMonitor.inspector.canMonitorPlayer = function()
	return UnitLevel("player") >= 10 and GetSpecialization() and true
end

DOTMonitor.inspector.getClassName = function()
	return DOTMonitor.utility.capitalize(string.lower(select(2,UnitClass("player")))):gsub(" ", "_")
end

DOTMonitor.inspector.getSpecInfo = function()
	local specInfo = {id = nil, name = nil, description = nil}
	
	if not DOTMonitor.inspector.canMonitorPlayer() then return false end
	specInfo.id, specInfo.name, specInfo.description = select(1,GetSpecializationInfo(GetSpecialization()))
	specInfo.name = specInfo.name:gsub(" ", "_") -- Death Knights -> Death_Knights
	return specInfo
end

DOTMonitor.inspector.getPossibleAbilities = function(allAbilities)
	local availableAbilities = {spell = {}, effect = {}}
	
	for atIndex, anAbility in ipairs(allAbilities.spell) do
		DOTMonitor.logMessage("Testing "..anAbility)
		if DOTMonitor.utility.getSpellID(anAbility) then
			table.insert(availableAbilities.spell, anAbility)
			table.insert(availableAbilities.effect, allAbilities.effect[atIndex])
		else
			DOTMonitor.logMessage("Not Supported: "..anAbility) 
		end
	end
	return availableAbilities
end

DOTMonitor.inspector.unitIsAlive = function(aUnit)
	return (UnitExists(aUnit) and (not UnitIsDead(aUnit))) or false
end

DOTMonitor.inspector.playerTargetingEnemy = function()
	return UnitIsEnemy("player", "target") or UnitCanAttack("player", "target")
end

DOTMonitor.inspector.playerTargetingLivingEnemy = function()
	local targetExists 	= UnitName("target") or false
	local targetIsAlive = DOTMonitor.inspector.unitIsAlive("player")
	local targetIsEnemy = DOTMonitor.inspector.playerTargetingEnemy()
	return (targetExists and targetIsAlive and targetIsEnemy)
end

DOTMonitor.inspector.checkUnitForDebuff = function(aUnit, debuff)
	local duration, expiration, caster = nil, nil, nil;
	local singleDebuff = type(debuff) == "string"
	if singleDebuff then 
		duration, expiration, caster = select(6, UnitDebuff(aUnit, debuff))
	else
		for aPosition, aDebuff in ipairs(debuff) do
			if UnitDebuff(aUnit, aDebuff) then
				duration, expiration, caster = select(6, UnitDebuff(aUnit, aDebuff))
				break
			end
		end
	end
	return duration, expiration, caster
end

DOTMonitor.inspector.getPlayerInfo = function()
	return {
		class 		= DOTMonitor.inspector.getClassName(),
		spec		= DOTMonitor.inspector.getSpecInfo(),
		level 		= UnitLevel("player"),
		healthMax 	= UnitHealthMax("player")
	}
end
