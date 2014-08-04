-- -- class icons in portrait
--   hooksecurefunc("UnitFramePortrait_Update",function(self)
--           if self.portrait then
--                   if UnitIsPlayer(self.unit) then                         
--                           local t = CLASS_ICON_TCOORDS[select(2, UnitClass(self.unit))]
--                           if t then
--                                   self.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
--                                   self.portrait:SetTexCoord(unpack(t))
--                           end
--                   else
--                           self.portrait:SetTexCoord(0,1,0,1)
--                   end
--           end
--   end)


-- Hide's errors when spamming abilities
  UIErrorsFrame:SetAlpha(0)


-- hide factions / pvp icon
  PlayerPVPIcon:SetAlpha(0)
  TargetFrameTextureFramePVPIcon:SetAlpha(0)
  FocusFrameTextureFramePVPIcon:SetAlpha(0)


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


-- disable portrait damage spam
  PlayerHitIndicator:SetText(nil)
  PlayerHitIndicator.SetText = function() end

  PetHitIndicator:SetText(nil)
  PetHitIndicator.SetText = function() end


-- disable group number frame
  PlayerFrameGroupIndicator.Show = function() return end