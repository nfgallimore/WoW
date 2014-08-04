--
-- Code for creating Trial, ActionTuple, and Action objects.
-- 

-- Upvalues
local Main       = KeybindTrainer;
local ABM        = ActionBindManager;
local U          = FitzUtils;

-- For convenience
local SP         = Main.UserSlots;
local C          = Main.Constants;

-- Local binds for speed
local _lower     = string.utf8lower
local _insert    = table.insert


--
-- Slot Pool Callbacks
--

-- Refresh all supported binds.
local function RefreshAllBinds()
   SP:Clear()

   -- Dominos/Bartender/Blizz are mutually exclusive
   if Main:GetVar("KT_Dominos") and ABM:Loaded("Dominos") then 
      SP:AddSlotRange(ABM:GetSlotRangeFor("Dominos"))
   elseif Main:GetVar("KT_Bartender") and ABM:Loaded("Bartender4") then 
      SP:AddSlotRange(ABM:GetSlotRangeFor("Bartender4"))
   else
      SP:AddSlotRange(ABM:GetSlotRangeFor("Action Bar"))
      if Main:GetVar("KT_PetBar")    then
         SP:AddSlotRange(ABM:GetSlotRangeFor("Pet Bar"))
      end
      if Main:GetVar("KT_StanceBar") then
         SP:AddSlotRange(ABM:GetSlotRangeFor("Stance Bar"))
      end
      -- (Coming soon)
      --if Main:GetVar("KT_TotemBar")  then
      --   SP:AddSlotRange(ABM:GetSlotRangeFor("Totem Bar"))
      --end
   end

   -- Bindpad?
   if Main:GetVar("KT_BindPad") and ABM:Loaded("BindPad") then 
      SP:AddSlotRange(ABM:GetSlotRangeFor("BindPad"))
   end

   -- Refresh the user state.
   ABM:GetFilledSlotPool(SP)
end 

-- Refresh visible blizzard bars.
local function RefreshVisibleBinds()
   SP:Clear()
   SP:AddSlotRange(ABM:GetSlotRangeFor("Action Bar"))

   -- By default these are all visible
   if Main:GetVar("KT_PetBar")    then
      SP:AddSlotRange(ABM:GetSlotRangeFor("Pet Bar"))
   end
   if Main:GetVar("KT_StanceBar") then
      SP:AddSlotRange(ABM:GetSlotRangeFor("Stance Bar"))
   end
   -- (Coming soon)
   --if Main:GetVar("KT_TotemBar")  then
   --   SP:AddSlotRange(ABM:GetSlotRangeFor("Totem Bar"))
   --end

   -- Bindpad?
   if Main:GetVar("KT_BindPad") and ABM:Loaded("BindPad") then 
      SP:AddSlotRange(ABM:GetSlotRangeFor("BindPad"))
   end

   -- Refresh the user state.
   ABM:GetFilledSlotPool(SP)

   -- Go through the slots in the SlotPool and clear the 
   -- slots that aren't visible.
   for s in SP:Iter() do 
      if not s:IsVisible() then s:Clear() end
   end
end 

-- Refresh specific actions only.
local function RefreshSomeBinds(s, e, src_name)
   SP:Clear()
   SP:AddSlotRange(s, e, src_name)

   -- Refresh the user state.
   ABM:GetFilledSlotPool(SP)
end 


--
-- Action Object Definiton
--

local Action = {}

-- Create a blank new action.
function Action:New(id, name, type, i, c)
   if c    == nil then c = C.GCD end
   if i    == nil then i = 1         end
   local o = {
      _id       = id,
      _type     = type,
      _name     = name,
      _i        = i,
      _c        = c,
      _m        = 0,
      _t        = 0,
      _b        = nil,
      _tex      = nil,
      _slot_ref = nil,
   }
   setmetatable(o, self)
   self.__index = self
   return o
end

-- Update this action from the current state on the bar.  If
-- "slot_ref" is passed in, this is an action in a default trial, and
-- we need to update all pertinent fields from bar slot state.
--
-- Otherwise, this action is from a custom trial.  In that case, we
-- need to update all pertinent fields using the sum total of bar state,
-- including aggregate binds from all slots.
--
-- Returns self for use with iterators.
function Action:UpdateFromBarState(slot_ref)
   local slots, v_slots, v_binds

   -- CUSTOM TRIAL: Figure out which action bar slot(s) we're referring to,
   -- and assign it or an aggregate of them to slot_ref.
   if not slot_ref then 
      -- Get a list of all candidate slots based on id/name
      if self:GetId() then 
         slots = SP:GetSlotsWithActionId(self:GetId())
      else
         slots = SP:GetSlotsWithActionName(self:GetName())
      end

   -- DEFAULT TRIAL: We know what slot this refers to.  However, other slots
   -- might have the same spell.  Need to gather those binds together.
   else
      slots = SP:GetSlotsWithActionId(slot_ref:GetActionId())
   end

   -- If we got more than one, check to see if more than one is visible.
   if     #slots == 1 then slot_ref = slots[1]
   elseif #slots > 1  then
      v_slots = {}
      for _,s in ipairs(slots) do
         if s:IsVisible() then _insert(v_slots, s) end
      end

      -- Nothing visible?  Then we can't differentiate.  Otherwise...
      if     #v_slots == 1 then slot_ref = v_slots[1]
      elseif #v_slots >  1 then
         -- Ensure that all the visible actions have the same ID.
         -- If not, then set slot_ref to nil.
         slot_ref = v_slots[1]
         U:Dump(slot_ref:GetBindMap())
         for i = 2,#v_slots do
            U:Print("  ALSO SEEN ON: "..v_slots[i]:GetSlotNum())
            if slot_ref and slot_ref:GetActionId() ~= v_slots[i]:GetActionId() then slot_ref = nil
            else slot_ref:UpdateBindsFromMap(v_slots[i]:GetBindMap()) end
         end
      end
   end

   -- If we were unable to map this to an actual action bind, then really not much
   -- we can do.
   if not slot_ref then
      self:SetTex(C.NOTEX)
      return self
   end

   -- Otherwise, update the action with the slot contents and return.
   U:Print("SLOT: "..slot_ref:GetSlotNum())
   U:Print("SOURCE: "..slot_ref:GetSrcStr())
   U:Print("CMD: "..slot_ref:GetCmd())
   U:Dump(slot_ref:GetBindMap())

   self:SetId(slot_ref:GetActionId())
   self:SetName(slot_ref:GetActionName())
   self:SetType(slot_ref:GetType())
   self:SetBind(slot_ref:GetBindMap())
   self:SetTex(slot_ref:GetTexture())
   return self
end

-- Prep the action for display. 
function Action:ResetForDisplay()
   self._m   = 0 -- reset misses
   self._t   = 0 -- reset time
end

-- Increment miss count
function Action:IncMiss() self._m = self._m + 1            end

-- Accessors
function Action:SetId(i)        self._id     = i           end
function Action:SetName(n)      self._name   = n           end
function Action:SetType(t)      self._type   = t           end
function Action:SetTime(t)      self._t      = t           end
function Action:SetCd(c)        self._c      = c           end
function Action:SetTex(t)       self._tex    = t           end
function Action:SetBind(b)      self._b      = b           end

function Action:GetId()         return self._id            end
function Action:GetIdx()        return self._i             end
function Action:GetCD()         return self._c             end
function Action:GetBind()       return self._b             end
function Action:GetTex()        return self._tex           end
function Action:GetMiss()       return self._m             end
function Action:GetTime()       return self._t             end
function Action:GetStatType()   return "action"            end

-- Return  action name, or nil
function Action:GetName()       return self._name          end

-- Return the type of the stat if we know it, else nil
function Action:GetType()       return self._type          end

-- Return the label for a macro, else ""
function Action:GetMacroDisplayName() 
   if self:GetType() == "macro" then return self:GetName() end
   return ""
end

-- Convienience method: return a label for macros and unrecognized spells; else "".
function Action:GetDisplayLabel()
   if not self:GetId() then return self:GetName() end
   return self:GetMacroDisplayName()
end   


--
-- Action Tuple Object Definiton
--

local ActionTuple = {}

-- Create a blank new tuple.
function ActionTuple:New()
   local o = {
      _tuples   = {},
      _i        = 1,
      _slot_ref = nil,
   }
   setmetatable(o, self)
   self.__index = self
   return o
end

-- Simple accessor
function ActionTuple:GetNumActions()   return #self._tuples       end

-- Set a ref to a Slot object for this action tuple, which will be
-- used to update the Action.
function ActionTuple:SetSlot(slot_ref) self._slot_ref = slot_ref  end

-- Whether or not we're a multi-tuple.
function ActionTuple:IsMulti()         return (#self._tuples > 1) end

-- Insert a recognized action, recording the index in the Action
function ActionTuple:AddAction(id, name, cooldown)
   table.insert(self._tuples, Action:New(id,
                                         name,
                                         nil,
                                         self:GetNumActions() + 1,
                                         cooldown))
end

-- Get the action at index i, updating it to reflect the current
-- state of user actions before returning.  Returns nil if i is
-- out of range.
function ActionTuple:Get(i)
   if i > self:GetNumActions() then return nil end
   local a = self._tuples[i]

   -- Need to update this action to reflect global
   -- action bar state before we can return it.
   a:UpdateFromBarState(self._slot_ref)
   return a
end

-- Define a java-style interator over actions in this tuple; does
-- not return a closure.
function ActionTuple:Next()
   self._i = self._i + 1
   return self:CurrAction()
end
function ActionTuple:Peek() 
   return self:CurrAction() ~= nil 
end
function ActionTuple:CurrAction()
   return self:Get(self._i)
end
function ActionTuple:Reset()
   self._i = 1
end

-- Get a lua iterator over the Actions in this ActionTuple in order of 
-- insertion, with each iteration returning an Action object.
function ActionTuple:Iter()
   local i = 0
   return function()
             i = i + 1
             return self:Get(i)
          end
end


--
-- Trial Object Definiton
--

local Trial = {}

-- Common init.
-- The ... args are sent to the refresh function.
function Trial:_init(id, refresh_func, ...)
   local o = {
      _r_func      = refresh_func, -- Callback to get slots for this trial.
      _r_func_args = {...},        -- Callback args, if any
      _id          = id,
      _trial_set   = {},
      _text        = {},
      _delay       = 0,
      _i           = 1,
      _is_default  = false,
      _idxs        = {},
      _m           = 0,
      _name        = "",
      _t           = 0,
      _hide        = false,
   }
   setmetatable(o, self)
   self.__index = self
   return o
end

-- Create a blank new default trial.
-- These trials are built from an array of action bar slots.
-- The ... args are for the refresh function.
function Trial:NewDefault(id, refresh_func, ...)
   local o = self:_init(id, refresh_func, ...)
   o._is_default = true

   -- Set the name from localization
   --o._name = GetLocalizedNameForId(id)

   -- Create a blank ActionTuple and Action to wrap actionbar
   -- slot data in.  This way we only need to create one object,
   -- which we can recycle by resetting it to represent different
   -- action slots.
   o._atuple = ActionTuple:New()
   o._atuple:AddAction()
   return o
end

-- Create a new custom trial.
function Trial:NewCustom(id, tt_txt, str)
   -- By default, custom trials need to know about all slots.
   local o    = self:_init(id, RefreshAllBinds)
   --o._name    = id
   o._str     = str
   
   -- Used to construct tooltips
   o._text.text         = id
   -- Only populate a tooltip if there's text to display
   if tt_txt then
      o._text.tooltipTitle = id
      o._text.tooltipText  = tt_txt
   end

   -- Set the display name of this trial
   o._name = id
   return o
end

-- Reset the data structures for default trials that require
-- knowledge of action bar binds.
function Trial:RefreshTrialActions() 
   -- Call the refresh callback to determine what slots to use.
   -- This refreshes the SpellPool object to the current user state
   -- via the ActionBindManager library.
   self._r_func(unpack(self._r_func_args))

   -- Default trials do not have actions specified in advance.
   -- These rely on the list of binds to drive the trial.
   if self:IsDefault() then
      -- Reset the index set to the number of slots we have.
      wipe(self._idxs)
      for i = 1, SP:Num() do _insert(self._idxs, i) end
   end
end

-- Simple accessors
function Trial:GetSlots()           return self._trial_set  end
function Trial:GetNumTuples()       return #self._idxs      end
function Trial:GetMenuText()        return self._text       end
function Trial:GetID()              return self._id         end
function Trial:GetStr()             return self._str        end
function Trial:GetTime()            return self._t          end
function Trial:GetMiss()            return self._m          end
function Trial:GetName()            return self._name       end
function Trial:GetStatType()        return "trial"          end
function Trial:IsDefault()          return self._is_default end
function Trial:IsRandomDelay()      return (self._delay == C.RANDOM) end

function Trial:SetDelay(delay)      self._delay = delay     end
function Trial:SetName(n)           self._name  = n         end

function Trial:Hide()               self._hide  = true      end
function Trial:Show()               self._hide  = false     end
function Trial:Hidden()             return self._hide       end


-- Increment counters
function Trial:IncMiss()            self._m = self._m + 1   end

-- Start/end trial
function Trial:StartTrial()
   self._m = 0
   self._t = 0
end
function Trial:EndTrial(duration)
   self._t = duration
end

-- Get the delay between action tuples in this trial.
function Trial:GetDelay()
   -- For default trials the delay is the current config value.
   -- For custom trials, if there is a delay given use it, else
   -- use the config value.
   local delay = Main:GetVar("KT_DurationInput")
   if self:IsDefault() or self._delay == nil then 
      if Main:GetVar("KT_RandomTime") then delay = C.RANDOM end
   else delay = self._delay end

   -- If delay is set to random, generate a random delay.
   if delay == C.RANDOM then return random(0, 10 * C.GCD) / 10
   else                      return delay end -- default is 0 
end

-- Add a tuple or multi-tuple to the trial set.
-- Only viable for custom trials.
function Trial:AddActionTuple(tuple)
   if self:IsDefault() then return end
   table.insert(self._trial_set, tuple)
   table.insert(self._idxs, #self._trial_set)
   return
end

-- Get the ActionTuple i, or (default trials only) nil if the slot is empty.
-- Note that for default trials, empty slots will mean that "i" may return nil
-- even if there are slots with Actions bound at higher slot numbers.
function Trial:Get(i)
   if i > #self._idxs then return nil end

   -- Note: SP:Get(i) returns the slot at i--REGARDLESS of whether or not it is
   -- empty!  This is handled in Next().
   if self:IsDefault() then
      local slot = SP:Get(self._idxs[i])

      -- If we're at a slot with something in it, wrap the slot in a the
      -- saved Action and ActionTuple objects.  Re-uses a single ActionTuple
      -- instance to prevent excess memory thrash.
      if slot then
         self._atuple:SetSlot(slot)
         return self._atuple
      end
      -- Found nothing, return nil.
   else
      return self._trial_set[self._idxs[i]]
   end
end

-- Get a reference to the current ActionTuple during iteration.
function Trial:CurrTuple()
   -- Corner case: if we've not called Next() first, then we could
   -- get back an empty tuple.  Advance to the first full one.
   local t = self:Get(self._i)
   if not t then t = self:Next() end
   return t
end

-- Define Java-style iterator over the trial set.
-- Not a Lua iterator--doesn't return closure.  
-- A Reset* function must be called to reset iteration.
-- Returns either an ActionTuple or a nil to signal done iterating.
function Trial:Next()
   local ret_tuple = nil

   -- Default trials iterate over all slots, including empty ones.
   -- To make upstream logic simpler, advance on empty until either
   -- done or a full slot is found.
   -- Custom trials do not have empty slots.  If this is a Custom
   -- trial, then Trial:Get() always returns the next ActionTuple.
   self._i = self._i + 1
   while self._i <= SP:Num() do
      ret_tuple = self:Get(self._i)
      if ret_tuple then return ret_tuple end
      self._i = self._i +1
   end
   return ret_tuple
end

-- Java-style look ahead--are there items remaining to iterate over?
-- Returns 1/nil.  See comments on Trial:Next().
function Trial:Peek()
   local i = self._i + 1
   while i <= #self._idxs do
      if self:Get(i) then return 1 end
      i = i +1
   end
end

-- Reset for sequential iteration.
function Trial:Reset()
   self:RefreshTrialActions()
   table.sort(self._idxs)
   self._i = 1
end

-- Reset for random iteration--basic in-place table permutation.
function Trial:ResetRandom()
   self:RefreshTrialActions()
   local n = #self._idxs
   for i = 1, n do
      local j = math.random(i, n)
      self._idxs[i], self._idxs[j] = self._idxs[j], self._idxs[i]
   end
   self._i = 1
end


--
-- Trial Factory Methods
--

-- Create a custom trial data structure from string input
function Main:NewCustomTrialFromInput(input)
   KT_Parser.Init()
   return KT_Parser.Parse(input)
end

-- Create a new custom trial for filling by the parser
function Main:NewCustomTrial(name, desc, str)
   return Trial:NewCustom(name, desc, str)
end

-- Create a default trial from visible blizzard action slots
function Main:NewVisibleBlizzardTrial(id)
   return Trial:NewDefault(id, RefreshVisibleBinds)
end

-- Create a default trial from some  blizzard action slots
function Main:NewSomeSlotsTrial(id, s, e, src_name)
   return Trial:NewDefault(id, RefreshSomeBinds, s, e, src_name)
end

-- Create a default trial from all visible action slots
function Main:NewDefaultTrial(id)
   return Trial:NewDefault(id, RefreshAllBinds)
end

-- Create a new action tuple.  Used by the custom trial parser.
function Main:NewActionTuple(...)
   return ActionTuple:New(...)
end


--
-- Test Methods -- used only in unit tests
--

-- Create an blank action for testing.
function Main:_NewTestAction(...)
   return Action:New(...)
end

-- Create an action tuple for an actionbar bind.
function Main:_NewTestActionTuple()
   return ActionTuple:New()
end



