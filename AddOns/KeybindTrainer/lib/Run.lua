--
-- Functions controlling the actual simulation.
--

-- Upvalues: get refs to the global tables.
local Main   = KeybindTrainer;
local U      = FitzUtils;

-- For convenience
local L      = Main.Text;
local C      = Main.Constants;
local Trials = Main.Trials;

-- Local binds for speed
local upper                   = string.utf8upper

-- Local globals
local g_curr_trial            = nil;
local g_action_tuple_timer    = nil
local g_action_cooldown_timer = nil
local g_trial_on              = false
local g_cd_on                 = false


--
-- Util Functions
--

-- Trial running?
function Main:IsTrialOn()
   return g_trial_on
end


--
-- Trial Helpers
--

-- Create an action button with associated Cooldown object and 
-- and add it to the pool.
function Main:AddActionButton()
   --U:Print("  Adding button ".."KT_Button"..#self.buttons)
   local b = CreateFrame("Button", "KT_Button"..#self.buttons,
                         self.frame, "ActionButtonTemplate");
   b:SetHeight(C.DEFAULT_ACTION_SIZE)
   b:SetWidth(C.DEFAULT_ACTION_SIZE)
   b:SetPoint("CENTER", 0, 0)
   b:SetFrameLevel(self.frame:GetFrameLevel())
   b:Hide()
   table.insert(self.buttons, b)
   
   -- Get reference to the cooldown from the button
   local c = _G[b:GetName().."Cooldown"]
   table.insert(self.cooldowns, c)

   -- Create overlay to show when the bind is missed.
   local o = b:CreateTexture("KT_Overlay"..#self.buttons, "OVERLAY");
   o:SetAlpha(1)
   o:SetAllPoints(b)
   o:Hide()
   table.insert(self.overlays, o)
end

-- Get a reference to a button from the pool for Action a
-- Each Action has it's position in the ActionTuple list, so
-- there should be a button for each index.
-- Returns button, cooldown, overlay
function Main:GetButtonForAction(a)
   -- Make sure we have enough buttons for this action.
   while a:GetIdx() > #self.buttons do self:AddActionButton() end
   return self.buttons[a:GetIdx()], self.cooldowns[a:GetIdx()], self.overlays[a:GetIdx()]
end

-- Clear positions and hide all buttons
function Main:HideAllActions()
   for i = 1,#self.buttons,1 do
      self.buttons[i]:Hide()
      self.overlays[i]:Hide()
      self.cooldowns[i]:SetCooldown(0,0) -- clear long cooldown animations
   end
end

-- Show n buttons, or the first if n (opt) is undefined.
function Main:ShowActions(n)
   if not n then n = 1 end
   for i = 1,n,1 do
      self.buttons[i]:Show()
   end
end

-- Add a macro name to a button
function Main:SetActionButtonMacroName(b, name)
   local text = _G[b:GetName().."Name"]
   if name then
      local fn, _, fl = text:GetFont()
      text:SetText(name)
      text:SetWidth(b:GetWidth())
      text:SetFont(fn, C.DEFAULT_TEXT_SIZE * (b:GetWidth() / C.DEFAULT_ACTION_SIZE))
   else
      text:SetText("")
   end
end

-- Get a button for Action a, and set it up with Texture tex
function Main:SetActionTexture(a)
   local w = floor(C.DEFAULT_ACTION_SIZE * self:GetVar("KT_IconSizeSlider"))
   local b,c,o = self:GetButtonForAction(a)

   U:Dump(a)

   -- Set the texture
   b:SetNormalTexture(a:GetTex())
   t = b:GetNormalTexture()
   t:SetVertexColor(1,1,1,1)
   
   -- Set dimensions
   b:SetWidth(w)
   b:SetHeight(w)

   -- [4.0.1] For some reason, cooldowns are now on avg 40% smaller than
   -- their resized button parents. ???
   c:ClearAllPoints();
   c:SetWidth(b:GetWidth() + 0.6 * C.DEFAULT_ACTION_SIZE)
   c:SetHeight(b:GetHeight() + 0.6 * C.DEFAULT_ACTION_SIZE)
   c:SetPoint("CENTER", b, "CENTER")

   -- Resize overlays
   o:SetWidth(b:GetWidth())
   o:SetHeight(b:GetHeight())

   -- If this action is a macro and has macro text, add it.
   self:SetActionButtonMacroName(b, a:GetDisplayLabel())
end

-- Set the action button[s] position[s] for the first n buttons
-- in the button pool.  Default n = 1.
-- Takes in an optional pad around buttons for multi-actions.
function Main:SetActionPositions(n, pad)
   if not n   then n   = 1  end
   if not pad then pad = C.DEFAULT_PAD_SIZE end
   local bw            = self.buttons[1]:GetWidth()
   local bh            = self.buttons[1]:GetHeight()
   local fw            = self.frame:GetWidth()
   local fh            = self.frame:GetHeight()
   
   -- Determine position of leftmost button
   if self:GetVar("KT_RandomPosition") then
      -- Get position bounds for center of leftmost button
      local y_min = -fh / 2 + (bh / 2) + pad
      local y_max = -y_min

      -- Min x-cord is left side + pad and half button width
      local x_min = ( - fw  / 2 ) + ( bw / 2 ) + pad

      -- Max x-cord is width of window minus width of button/pad sequence,
      -- offset by one pad and half button width to set center
      local x_max = ( fw / 2 ) - ( ( (n + 1) * pad ) + ( n * bw ) ) + pad + ( bw / 2)
      -- U:Print(x_min .. " " .. x_max .. " " .. y_min .. " " .. y_max)

      -- If we can't fit, center the icons.
      local off_x, off_y = 0, 0
      if (x_min < x_max) and (y_min < y_max) then
         off_x = random(x_min, x_max)
         off_y = random(y_min, y_max)
      end
      self.buttons[1]:SetPoint("CENTER", self.frame, "CENTER", off_x, off_y)
   else
      -- Get the center of the leftmost button such that the buttons 
      -- will be centered.  Example for n = 4--n buttons, n+1 pads:
      -- |pad|button|pad|button|pad|button|pad|button|pad|
      --        ^                ^
      --      x_pos              0
      -- Start w/ far left position and adjust rightward for pad and button width
      local x_pos = ( - ( ( (n + 1) * pad ) + ( n * bw ) ) / 2 ) + pad + ( bw / 2)

      --U:Print("WIDTH: "..bw)
      --U:Print("PAD: "..pad)
      --U:Print("X: "..x_pos)
      self.buttons[1]:SetPoint("CENTER", self.frame, "CENTER", x_pos, 0)
   end

   -- Set position of all buttons based off of the leftmost one.
   for i = 2,n,1 do
      self.buttons[i]:SetPoint("CENTER", self.buttons[i-1], "CENTER",
                               (bw + pad), 0)
   end
end


--
-- Trial Execution
--

-- Cancel all cooldowns and advance to the next action tuple.
function Main:CancelCooldownsAndAdvanceTuple()
   -- If we're in the midst of a global cooldown and get a skip,
   -- finish the cooldown early.
   if g_cd_on and not g_action_cooldown_timer then
      -- Fire registered tuple advance callback early
      return self:FireTimerCallback(g_action_tuple_timer)
   end

   -- Advance
   self:AdvanceActionTuple()
end

-- Advance to the next action in a tuple
function Main:AdvanceAction()
   g_cd_on = false
   g_action_cooldown_timer = nil -- clear timer
   self:StartActionTimer()
end

-- Advance to the next tuple in a trial, or finish trial if no
-- more tuples.
function Main:AdvanceActionTuple(delay)
   local continue  = false
   if not delay then delay = 0 end

   -- Clear the action cooldown timer.
   Main:RemoveTimerCallback(g_action_cooldown_timer)
   g_action_cooldown_timer = nil
   
   -- Save the last tuple seen
   local last_tuple = g_curr_trial:CurrTuple()

   -- Advance to next ActionTuple
   U:Print("      Advancing...")
   g_curr_trial:Next()
   
   -- If there's another action in the trial, register a timer
   -- callback to show the next action tuple.
   if g_curr_trial:CurrTuple() then
      continue = true

   -- Current trial has completed.  Continue?
   elseif self:GetVar("KT_Continuous") then
      -- Save stats for last runthrough
      if self:GetVar("KT_SaveStats") then
         g_curr_trial:EndTrial(self:ReadTrialTimer())
         self:RecordStats(g_curr_trial)
      end
      
      -- Randomize?
      if self:GetVar("KT_RandomOrder") then g_curr_trial:ResetRandom()
      else                                  g_curr_trial:Reset() end
      
      continue = true
   end

   -- If we're continuing, register timer and show next tuple.
   if continue then
      g_cd_on = true

      -- Trigger cooldown animation on last button for delay secs
      -- NOTE: there is a bug in OmniCC that is triggered with cooldowns of 0
      -- Since 99% of the WoW playerbase uses OmniCC, add a small pad to prevent
      -- the bug from triggering.
      self.cooldowns[last_tuple:GetNumActions()]:SetCooldown(GetTime(),
                                                             delay + 0.01)
      -- Register callback to advance after delay secs
      U:Print("  Registering callback to display next tuple.")
      g_action_tuple_timer = self:RegisterTimerCallback(function()
                                                           self:DisplayNextTuple()
                                                        end,
                                                        delay)
   else
      -- Done with trial completely.  Run endtrial handler.
      return self:EndTrial(self.frame)
   end
end


-- Advance to the next action tuple
function Main:DisplayNextTuple()
   local bind, tex, b, info
   U:Print("       NEXT TUPLE")

   -- Hide any previous actions.
   self:HideAllActions()

   -- Get the tuple of Actions to show.
   local curr_action_tuple = g_curr_trial:CurrTuple()
   curr_action_tuple:Reset()

   -- Set up icons.
   for a in curr_action_tuple:Iter() do
      --U:Dump(a)

      -- Reset action, clearing stats.
      a:ResetForDisplay()

      -- Set texture/button size for this action.
      self:SetActionTexture(a)

      -- Overlay "?" for actions that do not have a bind.
      if U:NumKeys(a:GetBind()) == 0 and a:GetTex() ~= C.NOTEX then
         self.overlays[a:GetIdx()]:SetTexture(C.NOBIND)
         self.overlays[a:GetIdx()]:Show()
         U:Print("   NO BIND for action!")
      end
   end

   -- Set positions for icons in tuple
   self:SetActionPositions(curr_action_tuple:GetNumActions())

   -- Show actions in tuple
   self:ShowActions(curr_action_tuple:GetNumActions())

   -- Ok, ready to listen for keybinds.  Turn off
   -- cooldown flag.
   g_cd_on = false

   U:Print("Starting timer.")

   -- Start the timer for the first action
   self:StartActionTimer()
end

-- Handle mousewheel binds.
function Main:OnMouseWheel(frame, dir)
   if dir > 0 then
      Main:OnKeyDown(frame, "MOUSEWHEELUP");
   else
      Main:OnKeyDown(frame, "MOUSEWHEELDOWN");
   end
end

-- Simple key handler
function Main:OnKeyDown(frame, key)
   -- Only worry about this if a trial is on
   if not g_trial_on then return end

   -- Let escape exit the trial completely
   if key == "ESCAPE" then
      self:OnLeave(frame)
      return
   end

   -- If we're still in the cooldown mode between actions,
   -- ignore the input.
   if g_cd_on then return end

   -- Translate the mouse buttons into bind keys
   if (key == "LeftButton")   then key = "BUTTON1" end
   if (key == "RightButton")  then key = "BUTTON2" end
   if (key == "MiddleButton") then key = "BUTTON3" end
   key = upper(key)
   
   -- Can't have a keybind with just mods.
   if (key == "LSHIFT" or
       key == "RSHIFT" or
       key == "LCTRL"  or
       key == "RCTRL"  or
       key == "LALT"   or
       key == "RALT") then
      return;
   end
   -- Note: if they're holding multiple mod keys down, this
   -- sequence should be a miss.
   if (IsShiftKeyDown())   then key = "SHIFT-"..key end
   if (IsControlKeyDown()) then key = "CTRL-"..key  end
   if (IsAltKeyDown())     then key = "ALT-"..key   end
   
   -- If here, we have a full keysequence.  Check against
   -- currently shown action.
   local curr_action = g_curr_trial:CurrTuple():CurrAction()
   U:Print("BINDS =")
   U:Dump(curr_action:GetBind())
   U:Print("-----")
   

   -- Did we miss?
   local has_binds = (U:NumKeys(curr_action:GetBind()) > 0)
   if has_binds and (not curr_action:GetBind()[key]) then
      -- Set "wrong" overlay
      self.overlays[curr_action:GetIdx()]:SetTexture(C.WRONG)
      self.overlays[curr_action:GetIdx()]:Show()

      -- Increment miss counts for this action.
      curr_action:IncMiss()
      g_curr_trial:IncMiss()

      -- Debug
      U:Print("Your entry: ".. key .. " -- WRONG!")
      U:Print("  Miss number: "..curr_action:GetMiss())
      return
   end

   -- Time from action shown until correct keybind entered.
   curr_action:SetTime(self:StopActionTimer())

   -- If there is no bind for this action, do not save success.
   -- Also don't allow saving of trial statistics
   if has_binds then
      -- Turn on overlay that we got it.
      self.overlays[curr_action:GetIdx()]:SetTexture(C.RIGHT)
      self.overlays[curr_action:GetIdx()]:Show()
      
      -- Save the value for the action if called for by config.
      if self:GetVar("KT_SaveStats") then
         self:RecordStats(curr_action)
      end
      
      -- Debug
      U:Print("Your entry: ".. key .. " -- RIGHT!")
      U:Print("You took "..curr_action:GetTime().." seconds to get your last bind right.")
   else
      U:Print("No bind found for action, skipping.")
   end

   -- If there is another action to test for a bind in the tuple, do
   -- not advance to the next ActionTuple after showing the cooldown
   -- for this one.  Do not accept user input until cooldown is complete.
   if g_curr_trial:CurrTuple():Next() then
      U:Print("        Next Action...")
      -- Show action disabled to show it's been done
      self.buttons[curr_action:GetIdx()]:GetNormalTexture():SetVertexColor(0.4,0.4,0.4)
      
      -- Trigger cooldown animation on all remaining buttons.
      -- The duration is the value of the current Action (a)'s cd
      for i = curr_action:GetIdx() + 1, g_curr_trial:CurrTuple():GetNumActions(), 1 do
         -- NOTE: there is a bug in OmniCC that is triggered with cooldowns of 0
         -- Since 99% of the WoW playerbase uses OmniCC, add a small pad to prevent
         -- the bug from triggering.
         self.cooldowns[i]:SetCooldown(GetTime(), curr_action:GetCD() + 0.01)
      end
      
      -- Register a timer callback to show the next action tuple
      -- using the action cooldown.
      g_cd_on = true
      g_action_cooldown_timer = self:RegisterTimerCallback(function() self:AdvanceAction() end,
                                                           curr_action:GetCD())
      return
   end

   -- No more actions.  Advance to the next ActionTuple, or finish trial.
   U:Print("  About to advance!")
   self:AdvanceActionTuple(g_curr_trial:GetDelay())
end



--
-- Begin Current Trial
--

function Main:BeginTrial()
   local frame = self.frame

   -- Only do this if we're ready.
   if not self._initialized then return end

   -- Don't allow this to happen if we have a dialog up.
   if self:GetVar("DialogShown") and next(self:GetVar("DialogShown")) then
      return
   end

   -- Save reference to current trial object.
   -- Exit if there is no trial selected
   local trial = self:GetVar("KT_SelectTrial")
   g_curr_trial = Trials[trial]
   if not g_curr_trial then return end

   -- Reset the trial.  Randomize?
   if self:GetVar("KT_RandomOrder") then
      g_curr_trial:ResetRandom()
   else
      g_curr_trial:Reset()
   end

   -- Make sure we have binds to iterate over.
   if g_curr_trial:GetNumTuples() == 0 or
      not g_curr_trial:CurrTuple() then
      _G[self.frame:GetName().."Stats"]:SetText(string.format(L["No keybinds found for trial '%s'!"],
                                                              g_curr_trial:GetName()))
      _G[self.frame:GetName().."Stats"]:Show()
      -- Show the button to restart
      _G["KT_StartTrial"]:Show()
      return
   end

   -- DEBUG
   U:Print("About to run trial: " .. trial)

   -- Disable all config widgets.
   self:EnableAllConfig(false)

   -- Init
   frame:EnableKeyboard(true);
   frame:EnableMouseWheel(true);
   self.curr_slot    = 0

   -- Enable timing, clear trial status.
   self:EnableTimers()
   _G[self.frame:GetName().."Stats"]:Hide()
   
   U:Print("Trial init'd, starting")

   -- Enable skip button
   _G["KT_Skip"]:Show()

   -- Advance to first action tuple in the trial.
   g_curr_trial:StartTrial()
   self:StartTrialTimer()
   self:DisplayNextTuple()
   g_trial_on = true
end

--
-- End Current Trial
--

function Main:EndTrial()
   local frame = self.frame

   -- If no trial runninng, nothing to do.
   if not g_trial_on then return end

   -- Halt timers
   local t_t = self:StopTrialTimer()
   local a_t = self:StopActionTimer()
   g_curr_trial:EndTrial(t_t)
   U:Print("End Trial!")
   U:Print("Total trial time: "..t_t)
   _G[self.frame:GetName().."Stats"]:SetText(self:GetTrialStatText(g_curr_trial))
   _G[self.frame:GetName().."Stats"]:Show()

   -- Save trial stats iff we finished a trial.
   if self:GetVar("KT_SaveStats") and not g_curr_trial:Peek() then
      self:RecordStats(g_curr_trial)
   end

   -- Enable all config widgets.
   self:EnableAllConfig(true)

   -- Teardown
   frame:EnableKeyboard(false);
   frame:EnableMouseWheel(false);
   self.curr_slot = 0
   self:RemoveTimerCallback(g_action_cooldown_timer)
   self:RemoveTimerCallback(g_action_tuple_timer)

   -- Hide all buttons
   self:HideAllActions()

   -- Done timing
   self:DisableTimers()
   g_trial_on = false

   -- Hide skip button
   _G["KT_Skip"]:Hide()

   -- Show the button to restart
   _G["KT_StartTrial"]:Show()
end
