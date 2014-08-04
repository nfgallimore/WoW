BINDING_HEADER_CYCLEARENA = "Cycle Arena"
_G["BINDING_NAME_CLICK CycleArenaTarget:LeftButton"] = "Cycle Target Forward"
_G["BINDING_NAME_CLICK CycleArenaTarget:RightButton"] = "Cycle Target Backward"
_G["BINDING_NAME_CLICK CycleArenaFocus:LeftButton"] = "Cycle Focus Forward"
_G["BINDING_NAME_CLICK CycleArenaFocus:RightButton"] = "Cycle Focus Backward"

-- creating a parent frame so both target and focus can rotate from common unit
local parent = CreateFrame("Button", nil, nil, "SecureActionButtonTemplate")
parent:SetAttribute("arenaUnit",0)

-- setup target cycle
local target = CreateFrame("Button", "CycleArenaTarget", parent, "SecureActionButtonTemplate")
target:SetAttribute("type1","target")
target:SetAttribute("type2","target")
SecureHandlerWrapScript(target, "OnClick", target, [[
  local unit
	local index = self:GetParent():GetAttribute("arenaUnit")
	local direction = button=="RightButton" and -1 or 1
  for i=1,5 do
	  index = (index+direction)%5
		unit = "arena"..index+1
		if UnitExists(unit) then
			self:GetParent():SetAttribute("arenaUnit",index)
			self:SetAttribute("unit",unit)
			return
		end
	end
	self:SetAttribute("unit",nil) -- if no arena enemy, don't target
]])

-- setup focus cycle
local focus = CreateFrame("Button", "CycleArenaFocus", parent, "SecureActionButtonTemplate")
focus:SetAttribute("type1","focus")
focus:SetAttribute("type2","focus")
SecureHandlerWrapScript(focus, "OnClick", focus, [[
  local unit
	local index = self:GetParent():GetAttribute("arenaUnit")
	local direction = button=="RightButton" and -1 or 1
  for i=1,5 do
	  index = (index+direction)%5
		unit = "arena"..index+1
		if UnitExists(unit) then
			self:GetParent():SetAttribute("arenaUnit",index)
			self:SetAttribute("unit",unit)
			return
		end
	end
	self:SetAttribute("unit",nil) -- if no arena enemy, don't focus
]])
