-- Hide's errors when spamming abilities
UIErrorsFrame:SetAlpha(0)

-- bars
  MainMenuBar:Hide()

  MainMenuBar:SetPoint('BOTTOM','UIParent','BOTTOM', 260, 0) 
  MultiBarBottomRight:ClearAllPoints() 
  MultiBarBottomRight:Hide()
  MultiBarBottomLeft:ClearAllPoints() 
  MultiBarBottomLeft:SetPoint("BOTTOM", 0,0)


-- Class colors in HP bars
  local function colour(statusbar, unit)
          local _, class, c
          if UnitIsPlayer(unit) and UnitIsConnected(unit) and unit == statusbar.unit and UnitClass(unit) then
                  _, class = UnitClass(unit)
                  c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
                  statusbar:SetStatusBarColor(c.r, c.g, c.b)
                  PlayerFrameHealthBar:SetStatusBarColor(0,1,0)
          end
  end

  hooksecurefunc("UnitFrameHealthBar_Update", colour)
  hooksecurefunc("HealthBar_OnValueChanged", function(self)
          colour(self, self.unit)
  end)

-- Class colors behind names
  local frame = CreateFrame("FRAME")
  frame:RegisterEvent("GROUP_ROSTER_UPDATE")
  frame:RegisterEvent("PLAYER_TARGET_CHANGED")
  frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
  frame:RegisterEvent("UNIT_FACTION")

  local function eventHandler(self, event, ...)
          if UnitIsPlayer("target") then
                  c = RAID_CLASS_COLORS[select(2, UnitClass("target"))]
                  TargetFrameNameBackground:SetVertexColor(c.r, c.g, c.b)
          end
          if UnitIsPlayer("focus") then
                  c = RAID_CLASS_COLORS[select(2, UnitClass("focus"))]
                  FocusFrameNameBackground:SetVertexColor(c.r, c.g, c.b)
          end
  end

  frame:SetScript("OnEvent", eventHandler)

  for _, BarTextures in pairs({TargetFrameNameBackground, FocusFrameNameBackground}) do
          BarTextures:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
  end

--Change the format of hp/mana text to absolute values ("140k"):
  hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", function()
          PlayerFrameHealthBar.TextString:SetText(AbbreviateLargeNumbers(UnitHealth("player")))
          PlayerFrameManaBar.TextString:SetText(AbbreviateLargeNumbers(UnitMana("player")))

          TargetFrameHealthBar.TextString:SetText(AbbreviateLargeNumbers(UnitHealth("target")))
          TargetFrameManaBar.TextString:SetText(AbbreviateLargeNumbers(UnitMana("target")))

          FocusFrameHealthBar.TextString:SetText(AbbreviateLargeNumbers(UnitHealth("focus")))
          FocusFrameManaBar.TextString:SetText(AbbreviateLargeNumbers(UnitMana("focus")))
  end)

-- arena frames
  LoadAddOn("Blizzard_ArenaUI") -- You only need to run this once. You can safely delete any copies of this line.

  ArenaEnemyFrame1:ClearAllPoints()
  ArenaEnemyFrame2:ClearAllPoints()
  ArenaEnemyFrame3:ClearAllPoints()
  ArenaEnemyFrame4:ClearAllPoints()
  ArenaEnemyFrame5:ClearAllPoints()

  ArenaEnemyFrame1:SetPoint("CENTER",UIParent,"CENTER",370,50)
  ArenaEnemyFrame2:SetPoint("CENTER",UIParent,"CENTER",370,0)
  ArenaEnemyFrame3:SetPoint("CENTER",UIParent,"CENTER",370,-50)
  ArenaEnemyFrame4:SetPoint("CENTER",UIParent,"CENTER",370,-100)
  ArenaEnemyFrame5:SetPoint("CENTER",UIParent,"CENTER",370,-150)

  ArenaEnemyFrame1.SetPoint = function() end
  ArenaEnemyFrame2.SetPoint = function() end
  ArenaEnemyFrame3.SetPoint = function() end
  ArenaEnemyFrame4.SetPoint = function() end
  ArenaEnemyFrame5.SetPoint = function() end

  for i=1, 5 do
          _G["ArenaEnemyFrame"..i]:SetScale(1.5)
          _G["ArenaEnemyFrame"..i.."CastingBar"]:SetScale(1.1)
          --_G["ArenaEnemyFrame"..i.."CastingBar"]:SetPoint("RIGHT", 95, 0)
  end


-- tracks trinkets
  trinkets = {}
  local arenaFrame, trinket
  for i = 1, 5 do
          arenaFrame = "ArenaEnemyFrame"..i
          trinket = CreateFrame("Cooldown", arenaFrame.."Trinket", ArenaEnemyFrames)
          trinket:SetPoint("TOPRIGHT", arenaFrame, 30, -6)
          trinket:SetSize(24, 24)
          trinket.icon = trinket:CreateTexture(nil, "BACKGROUND")
          trinket.icon:SetAllPoints()
          trinket.icon:SetTexture("Interface\\Icons\\inv_jewelry_trinketpvp_01")
          trinket:Hide()
          trinkets["arena"..i] = trinket
  end

  local events = CreateFrame("Frame")
  function events:UNIT_SPELLCAST_SUCCEEDED(unitID, spell, rank, lineID, spellID)
          if not trinkets[unitID] then
                  return
          end
          if spellID == 59752 or spellID == 42292 then
                  CooldownFrame_SetTimer(trinkets[unitID], GetTime(), 120, 1)
                  SendChatMessage("Trinket used by: "..GetUnitName(unitID, true), "PARTY")
          end
  end

  function events:PLAYER_ENTERING_WORLD()
          local _, instanceType = IsInInstance()
          if instanceType == "arena" then
                  self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
          elseif self:IsEventRegistered("UNIT_SPELLCAST_SUCCEEDED") then
                  self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
                  for _, trinket in pairs(trinkets) do
                          trinket:SetCooldown(0, 0)
                          trinket:Hide()
                  end
          end
  end
  events:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)
  events:RegisterEvent("PLAYER_ENTERING_WORLD")


-- minimap
  MinimapZoomIn:Hide()
  MinimapZoomOut:Hide()
  Minimap:EnableMouseWheel(true)
  Minimap:SetScript('OnMouseWheel', function(self, delta)
          if delta > 0 then
                  Minimap_ZoomIn()
          else
                  Minimap_ZoomOut()
          end
  end)
  MiniMapTracking:ClearAllPoints()
  MiniMapTracking:SetPoint("TOPRIGHT", -26, 7)


-- Focusframe inverter
  local Script = CreateFrame("Frame")

  -- xInvert()
  -- Inverts the anchor points of a frame horizontally.
  -- > Frame: Frame reference
  local InvertPoint = {
    ["TOPLEFT"] = "TOPRIGHT",
    ["TOPRIGHT"] = "TOPLEFT",
    ["BOTTOMLEFT"] = "BOTTOMRIGHT",
    ["BOTTOMRIGHT"] = "BOTTOMLEFT",
    ["TOP"] = "TOP",
    ["BOTTOM"] = "BOTTOM",
    ["LEFT"] = "RIGHT",
    ["RIGHT"] = "LEFT",
    ["CENTER"] = "CENTER"
  }
  local function xInvert(Frame)
    local AnchorData = {}
    for i = 1, Frame:GetNumPoints() do AnchorData[i] = { Frame:GetPoint(i) } end
    Frame:ClearAllPoints()
    for _, A in pairs(AnchorData) do Frame:SetPoint(InvertPoint[A[1]], A[2], InvertPoint[A[3]], A[4] * -1, A[5]) end
  end

  -- FocusCastRepos()
  -- Corrects the X-offset of the FocusFrame castbar, to adapt it to the inverted focus.
  local function FocusCastRepos()
    local FocusRight = FocusFrameManaBar:GetRight() * FocusFrameManaBar:GetEffectiveScale() / FocusFrameSpellBar:GetEffectiveScale()
    local CastRight = FocusFrameSpellBar:GetRight()
    local P = { FocusFrameSpellBar:GetPoint() }
    FocusFrameSpellBar:SetPoint(P[1], P[2], P[3], P[4] + FocusRight - CastRight + 2, P[5])
    Script:SetScript("OnUpdate", nil)
  end

  -- Inverting FocusFrame textures and frames
  FocusFrame.borderTexture:SetTexCoord(1.0, 0.09375, 0, 0.78125)
  FocusFrameFlash:SetTexCoord(0.9453125, 0, 0, 0.181640625)
  FocusFrameFlash.SetTexCoord = function() end
  FocusFrame.pvpIcon:SetPoint("TOPRIGHT", -149, -20)
  for _, v in pairs({FocusFrameFlash, FocusFrameTextureFrameHealthBarText, FocusFrameTextureFrameManaBarText}) do xInvert(v) end
  for _, v in pairs({"name", "deadText", "threatNumericIndicator", "portrait", "levelText", "Background", "healthbar", "manabar", "nameBackground", "questIcon", "petBattleIcon", "leaderIcon", "raidTargetIcon"}) do xInvert(FocusFrame[v]) end
  FocusFrameFlash.SetPoint = function() end
  FocusFrame.Background.SetPoint = function() end

  -- Inverting Focus-target
  FocusFrameToTTextureFrameTexture:SetTexCoord(0.7265625, 0.015625, 0, 0.703125)
  FocusFrameToT:ClearAllPoints()
  FocusFrameToT:SetPoint("BOTTOMRIGHT", FocusFrame, "BOTTOMRIGHT", -135, -18)
  FocusFrameToT.name:SetPoint("BOTTOMLEFT", 1, 2)
  for _, v in pairs({"portrait", "healthbar", "manabar", "deadText", "background"}) do xInvert(FocusFrameToT[v]) end
  for i = 1, 4 do xInvert(_G["FocusFrameToTDebuff"..i]) end -- Mini debuffs

  -- Correcting castbar position in the next frame (when the anchor changes will be updated)
  hooksecurefunc(FocusFrameSpellBar, "SetPoint", function() Script:SetScript("OnUpdate", FocusCastRepos) end)

  -- Adjusting buff/debuff positions
  hooksecurefunc("TargetFrame_UpdateAuras", function(s)
    if s ~= FocusFrame then return end
    for _, Aura in pairs({ FocusFrameBuff1, FocusFrameDebuff1 }) do
          if Aura then
            local P = { Aura:GetPoint() } -- Anchor point data
            if P[2] == FocusFrame then Aura:SetPoint(P[1], P[2], P[3], 105, P[5]) end
          end
    end
  end)

-- Hides shit

  -- disable portrait damage spam
  PlayerHitIndicator:SetText(nil)
  PlayerHitIndicator.SetText = function() end

  PetHitIndicator:SetText(nil)
  PetHitIndicator.SetText = function() end
  MainMenuBarLeftEndCap:Hide()
  MainMenuBarRightEndCap:Hide() -- hide the gryphons

  MainMenuExpBar:Hide()
  MainMenuBarMaxLevelBar:SetAlpha(0) -- hide the xp bar

  MainMenuBarTexture0:Hide() -- hide all the background textures.
  MainMenuBarTexture1:Hide() -- leaving them on looks better,
  MainMenuBarTexture2:Hide() -- unless you are going to hide the
  MainMenuBarTexture3:Hide() -- micromenu and bag buttons too.

  BonusActionBarFrameTexture1:SetAlpha(0)
  BonusActionBarFrameTexture2:SetAlpha(0) -- this is for druids/rogues/warriors.
  BonusActionBarFrameTexture3:SetAlpha(0) -- their stances cause this to show up
  BonusActionBarFrameTexture4:SetAlpha(0) -- over the normal bar.

  SlidingActionBarTexture0:SetAlpha(0)
  SlidingActionBarTexture1:SetAlpha(0) -- hide pet bar background

  -- These hide individual elements of the menu bar. Its easy to figure out what is what.
  ActionBarUpButton:Hide()
  ActionBarDownButton:Hide()
  MainMenuBarPageNumber:SetAlpha(0)

  CharacterMicroButton:Hide()
  SpellbookMicroButton:Hide()
  TalentMicroButton:Hide()
  AchievementMicroButton:Hide()
  QuestLogMicroButton:Hide()
  GuildMicroButton:Hide()
  PVPMicroButton:Hide()
  LFDMicroButton:Hide()
  CompanionsMicroButton:Hide()
  EJMicroButton:Hide()
  MainMenuMicroButton:Hide()
  HelpMicroButton:Hide()

  CharacterBag3Slot:Hide()
  CharacterBag2Slot:Hide()
  CharacterBag1Slot:Hide()
  CharacterBag0Slot:Hide()
  MainMenuBarBackpackButton:Hide()



  --disable damage spam?
  LoadAddOn("Blizzard_CombatText")

  COMBAT_TEXT_TYPE_INFO["PERIODIC_HEAL"] = {var = nil, show = nil}
  COMBAT_TEXT_TYPE_INFO["HEAL_CRIT"] = {var = nil, show = nil}
  COMBAT_TEXT_TYPE_INFO["HEAL"] = {var = nil, show = nil}
  COMBAT_TEXT_TYPE_INFO["PERIODIC_HEAL_ABSORB"] = {var = nil, show = nil}
  COMBAT_TEXT_TYPE_INFO["HEAL_CRIT_ABSORB"] = {var = nil, show = nil}
  COMBAT_TEXT_TYPE_INFO["HEAL_ABSORB"] = {var = nil, show = nil}

  COMBAT_TEXT_TYPE_INFO["DAMAGE_CRIT"] = {var = nil, show = nil}
  COMBAT_TEXT_TYPE_INFO["DAMAGE"] = {var = nil, show = nil}
  COMBAT_TEXT_TYPE_INFO["SPELL_DAMAGE_CRIT"] = {var = nil, show = nil}
  COMBAT_TEXT_TYPE_INFO["SPELL_DAMAGE"] = {var = nil, show = nil}



  -- disable group number frame
  PlayerFrameGroupIndicator.Show = function() return end

-- casting bar colors
SetStatusBarColor (0,0.45,0.9); CastingBarFrame.SetStatusBarColor = function () end 
FocusFrameSpellBar: SetStatusBarColor (0,0.45,0.9); FocusFrameSpellBar.SetStatusBarColor = function () end

hooksecurefunc("UnitFramePortrait_Update",function(self)
        if self.portrait then
                if UnitIsPlayer(self.unit) then                         
                        local t = CLASS_ICON_TCOORDS[select(2, UnitClass(self.unit))]
                        if t then
                                self.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
                                self.portrait:SetTexCoord(unpack(t))
                        end
                else
                        self.portrait:SetTexCoord(0,1,0,1)
                end
        end
end)
