-- Name: KeybindTrainer
-- Revision: $Rev$
-- Author(s): Fitzcairn (fitz.wowaddon@gmail.com)
-- Description: Addon for testing user knowledge of action bar keybinds.
-- Dependencies: LibStub, LibDataBroker-1.1, LibDBIcon-1.0, CallbackHandler-1.0, UTF8, json4lua
-- License: GPL v2 or later.
--
--
-- Copyright (C) 2010-2011 Fitzcairn of Cenarion Circle US  
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--


-- Upvalues
local Main       = KeybindTrainer;
local ABM        = ActionBindManager;
local U          = FitzUtils;

-- For convenience
local L          = Main.Text;
local C          = Main.Constants;
local Trials     = Main.Trials;
local Handlers   = Main.SlashCmdHandlers;
local IconText   = Main.UI.KT_MinimapIcon;

-- Local binds for speed.
local _insert    = table.insert
local _remove    = table.remove

-- Local storage for custom trials
local g_c_trials = {}


-- 
-- DEBUG
--

-- Disable/enable debug output
U:Debug(false)


--
-- Minimap Icon + Context Menu
--

-- Use LibDBIcon from Ace3 to create a minimap show/hide button.
local g_minimap_icon = LibStub("LibDataBroker-1.1"):NewDataObject("KT_MinimapIcon",
 {
	type = "data source",
	text = IconText.text,
	icon = "Interface\\Addons\\KeybindTrainer\\img\\icon",
    OnTooltipShow = function(tt)
                       if _G["KT_Frame"]:IsShown() then
                          tt:SetText(IconText.tt_on)
                       else
                          tt:SetText(IconText.tt_off)
                       end
                    end,
	OnClick       = function(frame, button)
                       if _G["KT_Frame"]:IsShown() then
                          _G["KT_Frame"]:Hide() 
                       else
                          _G["KT_Frame"]:Show() 
                       end
                    end
})
local icon = LibStub("LibDBIcon-1.0")


--
-- Slash Commands
--

-- Helper to color help text
local function ColorCmdTxt(txt)
   return "|cFF3D64FF"..txt.."|r"
end

-- Helper to create help output from the command table.
local function HelpCmdHelper(cmd_tbl, s, prefix) 
   prefix = prefix or ""
   for cmd,v in pairs(cmd_tbl) do
      if v.help then
         print(table.concat( { s..ColorCmdTxt(prefix..cmd),
                               s.." "..v.help },
                            "\n"))
      else
         print(HelpCmdHelper(v, s, cmd.." "))
      end
   end
end

-- Handlers for all slash command functionality.
Handlers = {
   [L["show"]] = {
      help = "Show the KeybindTrainer window.",
      run  = function() _G["KT_Frame"]:Show() end,
   },
   [L["hide"]] = {
      help = L["Hide the KeybindTrainer window."],
      run  = function() _G["KT_Frame"]:Hide() end,
   },
   [L["help"]] = {
      help = L["Show the KeybindTrainer help window."],
      run  = function() Main:ShowDialog(_G["KT_HelpDialog"]) end,
   },
   [L["options"]] = {
      help = L["Show the KeybindTrainer options window."],
      run  = function() Main:ShowDialog(_G["KT_OptionsDialog"]) end,
   },
   [L["stats"]] = {
      help = L["Show the KeybindTrainer statistics window."],
      run  = function() Main:ShowDialog(_G["KT_StatisticsDialog"]) end,
   },
   [L["trial"]] = {
      [L["create"]] = {
         help = L["Shows a window to create a new custom trial."],
         run  = function() Main:ShowDialog(_G["KT_CustomInputDialog"]) end,
      },
      [L["edit"]] = {
         help = L["Requires argument <name>.  Shows window to edit custom trial <name>."],
         run  = function(trial)
                   -- Did we get good input?
                   if not (trial and Trials[trial] and not Trials[trial]:IsDefault()) then 
                      print(L["Argument is not an editable trial."])
                      return
                   end
                   -- Populate box and show.
                   _G["KT_CustomTrialEditInput"]:SetText(Trials[trial]:GetStr())
                   Main:ShowDialog(_G["KT_CustomEditDialog"])
                end,
      },
   },
}

-- Dispatch, based off of ideas in "World of Warcraft Programmng 2nd Ed"
SLASH_KEYBINDTRAINER1 = L["/keybindtrainer"]
SLASH_KEYBINDTRAINER2 = L["/kbt"]

local function HandleSlashCmd(msg, tbl)
   local cmd, param = string.match(msg, "^(%w+)%s*(.*)$")
   cmd = cmd or ""
   local e = tbl[cmd:lower()]
   if not e then
      -- Not recognized, output slash command help
      print(ColorCmdTxt(SLASH_KEYBINDTRAINER1))
      print(ColorCmdTxt(SLASH_KEYBINDTRAINER2))
      HelpCmdHelper(Handlers, "      ")
   elseif e.run then e.run(param)
   else              HandleSlashCmd(param or "", e) end
end
   
-- Register commands.
SlashCmdList["KEYBINDTRAINER"] = function (msg)
                                    HandleSlashCmd(msg, Handlers)
                                 end

--
-- Load Trials
--

-- Helper for trials to make switching things around easier.
function Main:AddNewTrial(t)
   Trials[t:GetID()] = t
   _insert(self.TrialDisplayList, t)
end
function Main:RemoveTrial(id)
   -- Remove from the trials display list.
   local i = 0
   for p,t in ipairs(self.TrialDisplayList) do
      if (t:GetID() == id) then i = p end
   end
   _remove(self.TrialDisplayList, i)

   -- Remove from trial tables.
   Trials[id]                = nil
   KT_CustomTrials[id]       = nil
end


-- Load a Custom Trial from an input string.
-- Returns exception string on error.
function Main:LoadCustom(input, id)
   if string.len(input) == 0 then return L["No input to parse!"] end
   local t = self:NewCustomTrialFromInput(input)
   if not t then 
      return string.format(L["Error: %s\nInput: %s"],
                           KT_Parser.GetErr()) end

   -- If a name is passed in, then we are overwriting a custom
   -- trial.
   local save_edit_to_profile = false
   if id ~= nil and Trials[id] then
      if not Trials[id]:IsDefault() then
         if KT_CustomTrials[id] then
            save_edit_to_profile = true
         end
         self:RemoveTrial(id)
      else
         return L["A non-replaceable default trial with that name already exists."]
      end
   -- Check for id collision on new trial.
   elseif Trials[t:GetID()] then
      return L["A custom trial with that name already exists."]
   end
   self:AddNewTrial(t)
   _insert(g_c_trials, t)

   -- If requested, save input string to profile for all characters.
   if save_edit_to_profile or self:GetVar("KT_SaveToProfile") then
      KT_CustomTrials[t:GetID()] = input
   end
end


-- Refresh Trial display list by showing/hiding trials.
function Main:RefreshTrialDisplayList()
   local t, cname
   if not self:IsInitialized() then return end

   -- Hide all trials to start.
   for _, t in ipairs(self.TrialDisplayList) do
      if t:IsDefault() then t:Hide() end
   end

   -- If no Dominos/Bartender, don't show it.  Otherwise, show only it.
   if self:GetVar("KT_Dominos")   then Trials["trial_dominos"]:Show()   end
   if self:GetVar("KT_Bartender") then Trials["trial_bartender"]:Show() end
  
   -- Class bars.  Only offer with blizzard.
   if not self:GetVar("KT_Dominos") and not self:GetVar("KT_Bartender") then
      Trials["trial_all"]:Show()
      Trials["trial_visible"]:Show()

      _, cname = UnitClass("player")
      if     cname == "WARRIOR" then
         Trials["trial_battle"]:Show()
         Trials["trial_defensive"]:Show()
         Trials["trial_berserker"]:Show()
      elseif cname == "DRUID"   then
         Trials["trial_cat"]:Show()
         --Trials["trial_prowl"]:Show()
         Trials["trial_bear"]:Show()
         Trials["trial_moonkin"]:Show()
      elseif cname == "ROGUE"   then
         Trials["trial_rogue"]:Show()
      elseif cname == "PRIEST"  then
         Trials["trial_priest"]:Show()
      end
   end

   -- Clear the menu
   self:ClearDropDownMenu(_G["KT_SelectTrial"])
end


-- Load the trials.
function Main:LoadTrials()
   local t, cname
   local sp = Main.UserSlots

   -- Create DEFAULT TRIALS --
   self:AddNewTrial(self:NewDefaultTrial("trial_dominos"))
   self:AddNewTrial(self:NewDefaultTrial("trial_bartender"))
   self:AddNewTrial(self:NewDefaultTrial("trial_all"))

   self:AddNewTrial(self:NewVisibleBlizzardTrial("trial_visible"))

   self:AddNewTrial(self:NewSomeSlotsTrial("trial_battle", 73, 84, "Action Bar"))
   self:AddNewTrial(self:NewSomeSlotsTrial("trial_defensive", 85, 96, "Action Bar"))
   self:AddNewTrial(self:NewSomeSlotsTrial("trial_berserker", 97, 108, "Action Bar"))
   self:AddNewTrial(self:NewSomeSlotsTrial("trial_cat", 73, 84, "Action Bar"))
   --self:AddNewTrial(self:NewSomeSlotsTrial("trial_prowl", 85, 96, "Action Bar"))
   self:AddNewTrial(self:NewSomeSlotsTrial("trial_bear", 97, 108, "Action Bar"))
   self:AddNewTrial(self:NewSomeSlotsTrial("trial_moonkin", 109, 120, "Action Bar"))
   self:AddNewTrial(self:NewSomeSlotsTrial("trial_rogue", 73, 84, "Action Bar"))
   self:AddNewTrial(self:NewSomeSlotsTrial("trial_priest", 73, 84, "Action Bar"))

   -- Create CUSTOM TRIALS --
   U:Print("Processing saved trials!")
   if KT_CustomTrials then
      for _,t_str in pairs(KT_CustomTrials) do self:LoadCustom(t_str) end
   end

   -- Refresh which trials to show.
   self:RefreshTrialDisplayList()
end


--
-- Saved Vars -- Called only after "ADDON_LOADED" event fires
--

-- Assign references to saved data to be used throughout the addon.
function Main:InitSavedVars()
   local first_run = false

   -- Init if nothing was loaded
   -- If this is the first time the addon has been run, add
   -- an example trial later.
   if KT_SavedCustomTrials then
      for s,t in pairs(KT_SavedCustomTrials) do
         KT_CustomTrials[s] = t
      end
   else
      -- Populate an example trial
      first_run = true
   end
   if KT_SavedStats        then 
      for s,t in pairs(KT_SavedStats) do
         KT_Stats[s] = t
      end
   end
   if KT_SavedUIConfigVals then 
      -- Update addon config with saved state.
      self:RestoreConfigState(KT_SavedUIConfigVals)
   end

   -- Reset the *Saved refs to reflect any updates from user
   -- interacction.
   KT_SavedStats        = KT_Stats
   KT_SavedCustomTrials = KT_CustomTrials
   KT_SavedUIConfigVals = KT_UIConfigVals

   -- For the first time this is run, populate with an
   -- example Custom Trial.
   if first_run then
      KT_CustomTrials["Rogue: Cloak and Vanish"] = '{"desc":"An example custom KeybindTrainer trial.", "name":"Rogue: Cloak and Vanish", "gcd":1.5, "binds":[{"action":"Stealth"}, [{"action":"Cloak of Shadows", "cd":0}, {"action":"Vanish"}]]}'
   end
end


--
-- Init -- Called only after "ADDON_LOADED" event fires
--

-- [4.0.1] Updated to reflect new arg format for ADDON_LOADED
function KT_OnEvent(self, event, arg1, name)
   if event == "ADDON_LOADED" and name == "KeybindTrainer" then
      Main:Init(self)
   end
end

function Main:IsInitialized() return self._initialized end

function Main:Init(frame)
   U:Print("Initing. . . ")
   self.frame = frame
   
   -- Set localized title.
   local version = GetAddOnMetadata("KeybindTrainer","Version")
   local title   =  L["KeybindTrainer"].." v"..version
   _G["KT_Title"]:SetText(title)

   -- Set the about string
   local about   = title.. L[", by Fitzcairn of Cenarion Circle US"]
   _G["KT_About"]:SetText(about)

   -- Init saved vairs--should be loaded by now.
   self:InitSavedVars()

   -- Load trials--both basic and custom.
   self:LoadTrials()

   -- Create trial timer fontstring and hide it.
   self.trial_timer = self:CreateTimer("Total Time")
   self.trial_timer:SetPoint("BOTTOMLEFT", 15, 12)

   -- Create a per-action timer and hide it
   self.action_timer = self:CreateTimer("Bind")
   self.action_timer:SetPoint("BOTTOMRIGHT", -15, 12)

   -- Load up the minimap icon
   icon:Register("KT_MinimapIcon", g_minimap_icon, Main.Vals)
   self.minimap_icon = icon
   if not self:GetVar("KT_ShowMinimapIcon", true) then
      icon:Hide("KT_MinimapIcon")
   end

   -- Done
   self._initialized = true
   U:Print("Initialized!")
   if self:GetVar("KT_ShowStartupMsg", true) then
      print(ColorCmdTxt(L["KeybindTrainer loaded successfully!  Type /kbt for options."]))
   end
end


