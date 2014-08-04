--[[
  < Anticipation v0.1 Beta >
______________________________
 Author: Spyro
License: All Rights Reserved
Contact: Spyrö  @ ArenaJunkies
         Spyro  @ WowInterface
         Spyro_ @ Curse/WowAce
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
]]

local Addon = CreateFrame("Frame") -- Addon main frame
local ComboPoint = {} -- Store additional combo points frames

-- Event registration
Addon:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)
Addon:RegisterEvent("PLAYER_LOGIN")

-- Event PLAYER_LOGIN
-- Fires after PLAYER_ENTERING_WORLD after logging in and after /reloadui.
function Addon:PLAYER_LOGIN()
  if select(2, UnitClass("player")) ~= "ROGUE" then return end

  -- Make normal combo points appear instantly, without the default delay
  COMBOFRAME_FADE_IN = 0
  COMBOFRAME_FADE_OUT = 0
  COMBOFRAME_SHINE_FADE_IN = 0
  COMBOFRAME_SHINE_FADE_OUT = 0
  COMBOFRAME_HIGHLIGHT_FADE_IN = 0

  Addon:RegisterEvent("UNIT_AURA") -- To track Anticipation buff
  AnticipationPoints = CreateFrame("Frame", nil, UIParent) -- Parent frame for the additional combo points
  AnticipationPoints:SetScale(ComboFrame:GetScale()) -- Same scale as normal combo points
 
  -- Creating textures to see the Anticipation stacks as additional combo points
  for i = 6, 10 do
    ComboPoint[i] = CreateFrame("Frame", nil, AnticipationPoints, "ComboPointTemplate") -- Storing in a table to avoid creating globals
    ComboPoint[i]:SetPoint("LEFT", _G["ComboPoint"..i-5], "RIGHT", -1, 0) -- Anchoring to the side of the normal combo point
    ComboPoint[i]:GetRegions():SetAlpha(1) -- Showing the ball texture (1st region)
    ComboPoint[i]:Hide()
  end
  ComboPoint[10]:SetPoint("LEFT", ComboPoint5, "RIGHT", -4, 3) -- Last point's anchor needs its own adjustment

  -- Hiding when we have no target
  TargetFrame:HookScript("OnShow", function() AnticipationPoints:Show() end)
  TargetFrame:HookScript("OnHide", function() AnticipationPoints:Hide() end)
end

-- Event UNIT_AURA
-- Fires when a unit loses/gains a buff/debuff.
function Addon:UNIT_AURA(unit)
  if unit ~= "player" then return end

  for i = 6, 10 do ComboPoint[i]:Hide() end
  local AntiStacks = select(4, UnitBuff("player", GetSpellInfo(115189))) -- Anticipation stacks
  if AntiStacks then
    for i = 6, AntiStacks+5 do ComboPoint[i]:Show() end
  end
end