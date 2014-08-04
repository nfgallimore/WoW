--
-- Very basic timer functionality using OnUpdate.
--

-- Scope upvalue
local Main  = KeybindTrainer;

-- Local globals
local g_callbacks     = {} -- Callbacks for the timer
local g_time_total    = 0  -- For callbacks.
local g_time_elapsed  = 0
local g_timer_enabled = false


-- OnUpdate handler, used as a timer.
local function KT_OnUpdate(_, elapsed) 
   g_time_elapsed = g_time_elapsed + elapsed
   
   -- Update timer.
   if g_time_elapsed > .01 then -- update every hundreth of a second
      g_time_total = g_time_total + g_time_elapsed
      Main.trial_timer:UpdateTime(g_time_elapsed)
      Main.action_timer:UpdateTime(g_time_elapsed)
      g_time_elapsed = 0;
   end
   
   -- Any callbacks scheduled?
   for _, cb in ipairs(g_callbacks) do
      if g_time_total > cb.t and not cb.fired then
         Main:FireTimerCallback(cb)
      end
   end
end


-- Start/end the timers
function Main:EnableTimers()
   g_time_elapsed = 0
   g_time_total   = 0 -- For callbacks
   self.trial_timer:UpdateTime(0)
   self.action_timer:UpdateTime(0)

   -- Show timer display if called for.
   if self:GetVar("KT_ShowTimer") then
      self.trial_timer:Show()
      self.action_timer:Show()
   end

   -- Enable OnUpdate handler
   self.frame:SetScript("OnUpdate", KT_OnUpdate);
   g_timer_enabled = true
end
function Main:DisableTimers()
   self.trial_timer:Hide()
   self.action_timer:Hide()
   
   -- Disable OnUpdate handler
   self.frame:SetScript("OnUpdate", nil);
   g_timer_enabled = false

   -- Clear all timer callbacks for garbage collection.
   g_callbacks = {}
end


-- Helpers for timer control
local function TimerStart(timer)
   timer.val = 0
   if Main:GetVar("KT_ShowTimer") then
      timer:UpdateTime(0)
      timer:Show()
   end
end
local function TimerStop(timer) -- Returns timer value
   local t = timer.val
   timer:Hide()
   timer.val = 0
   return t
end


-- Simple timer control
function Main:StartTrialTimer()
   TimerStart(self.trial_timer)
   end
function Main:StartActionTimer()
   TimerStart(self.action_timer)
end
function Main:ReadTrialTimer()
   return self.trial_timer.val
end
function Main:StopTrialTimer()
   return TimerStop(self.trial_timer)
end
function Main:StopActionTimer()
   return TimerStop(self.action_timer)
end


-- Register a timer callback to occur t (float) seconds in the
-- future.  Returns a reference to that callback frame.
function Main:RegisterTimerCallback(func, t)
   if not g_timer_enabled then return nil end -- can't do this without timer

   -- Set time to be t seconds from the current time
   t = t + g_time_total

   -- Recycle callback table entries where possible 
   -- to avoid creating a lot of junk.
   local i
   for i = 1, #g_callbacks do
      if g_callbacks[i].fired then
         g_callbacks[i].f     = func
         g_callbacks[i].t     = t
         g_callbacks[i].fired = false
         return g_callbacks[i]
      end
   end
   table.insert(g_callbacks,
                {  fired = false,
                   f     = func,
                   t     = t  })
   return g_callbacks[#g_callbacks]
end


-- Tear down a callback.
function Main:RemoveTimerCallback(cb)
   if cb then cb.fired = true end
end


-- Fire a timer callback.
function Main:FireTimerCallback(cb)
   if cb and not cb.fired then
      cb.f() 
      cb.fired = true
   end
end

-- Create a "timer", which is really just a FontString with 
-- a few extra fields.
function Main:CreateTimer(label)
   local timer = self.frame:CreateFontString(label, "ARTWORK", "GameFontNormal")
   timer.val = 0
   timer.txt = label
   timer.UpdateTime = function(s, t)
                         s.val = s.val + t                         
                         s:SetText(string.format("%s: %.2f s", s.txt, s.val))
                      end
   timer:Hide()
   return timer
end
