--
-- Module to handle working with binds/action bars/action mods
-- 
-- Offers a simple API for getting maps of binds -> cmds ->
-- actions via the SlotPool module (see SlotPool.lua)
--

-- Make sure the app has also loaded SlotPool and Localization
assert(SlotPool and ActionBindManagerText)

-- Main table for Binds methods.
ActionBindManager = {}

-- Table for support bind types; see end of file.
local SupportedBindTypes = {};

-- Uprefs
local ABM  = ActionBindManager
local SP   = SlotPool
local L    = ActionBindManagerText


--
-- Local Functions
-- 

-- For speed
local _insert = table.insert
local _format = string.format
local _find   = string.find
local _sub    = string.sub
local _len    = string.len

-- Local function to convert a slot into bar, slot (on [1,12])
local function GetBarAndSlot(s)
   local bar = ceil(s / 12)
   s = s - ((bar - 1) * 12)
   return bar, s
end

-- Get a localized source string for an action.  Args are src_string 
-- (unlocalized) and a slot number.
local function GetSlotSrcString(src_string, slot)
   local _, class = UnitClass("player")
   local bar, bar_slot = GetBarAndSlot(slot)

   if src_string == "Dominos" or src_string == "Bartender4" then
      -- Action
      if slot < 133     then return _format(L["%s Bar %i, Slot %i"],
                                            src_string,
                                            bar, bar_slot)
      -- Pet
      elseif slot < 143 then return _format(L["%s Pet Bar, Slot %i"],
                                            src_string,
                                            slot - 132)
      -- Stance
      else                   return _format(L["%s Stance Bar, Slot %i"],
                                            src_string,
                                            slot - 142)
      end

   elseif src_string == "BindPad" then
      return _format(L["BindPad Slot %i"], slot)

   elseif src_string == "Stance Bar" or src_string == "Pet Bar" or src_string == "Totem Bar" then
      return _format(L["%s, Slot %i"], src_string, slot)

   else -- Blizzard action bars
      if     class == "DRUID"   and slot > 72 and slot <= 84 then
         return _format(L["Cat Bar, Slot %i"], bar_slot)     
      elseif class == "DRUID"   and slot > 84 and slot <= 96 then
         return _format(L["Prowl Bar, Slot %i"], bar_slot)     
      elseif class == "DRUID"   and slot > 96 and slot <= 108 then
         return _format(L["Bear Bar, Slot %i"], bar_slot)     
      elseif class == "DRUID"   and slot > 108 and slot <= 120 then
         return _format(L["Moonkin Bar, Slot %i"], bar_slot)   
         
      elseif class == "WARRIOR" and slot > 72 and slot <= 84 then
         return _format(L["Battle Stance Bar, Slot %i"], bar_slot)   
      elseif class == "WARRIOR" and slot > 84 and slot <= 96 then
         return _format(L["Defensive Stance Bar, Slot %i"], bar_slot)   
      elseif class == "WARRIOR" and slot > 96 and slot <= 108 then
         return _format(L["Berserker Stance Bar, Slot %i"], bar_slot)   
         
      elseif class == "ROGUE"   and slot > 72 and slot <= 84  then
         return _format(L["Stealth Bar, Slot %i"], bar_slot)   
         
      elseif class == "PRIEST"  and slot > 72 and slot <= 84  then
         return _format(L["Shadowform Bar, Slot %i"], bar_slot)   
         
      else -- other classes, bars
         return _format(L["Bar %i, Slot %i"], bar, bar_slot)               
      end
   end
end


-- Create a bind table for a WoW UI command string.  Ex: { "1", "2", ... }
-- Can return an empty table if there are no binds for this command.
local function GetBindTableForCmd(cmd)
   local b_table = {}
   for _,b in ipairs({ GetBindingKey(cmd) }) do b_table[b] = 1 end
   return b_table
end


-- Attempt to determine if an action slot is actually visible
-- to the user.  Returns 1/nil.
-- Note that Dominos/Bartender can make this very inaccurate; it should
-- be considered valid for Blizzard Bars only.
local function IsBlizzardActionBarSlotVisible(slot)
   -- Convienience local function
   local t_f = function(s, e)
                  if slot >= s and slot <= e then return true end
               end
                     
   -- Decide what is shown on main actionbar.
   -- Are we on action page 2? If so, show those regardless of
   -- stance, etc. TODO: test this with action bar addons that allow
   -- all bars to be moved, shown at once, etc!
   if GetActionBarPage() == 2 then
      if t_f(13, 24) then return 1 end
   else
      -- Because overlays are used and there is a many-to-one relationship
      -- between ActionSlots and actual buttons on the bar, need to use
      -- BonusBarOffset to determine what to show.
      local bonus_offset = GetBonusBarOffset()
      if bonus_offset == 0 then
         if t_f(1, 12) then return 1 end         
      elseif bonus_offset == 1 then
         if t_f(73, 84) then return 1 end
      elseif bonus_offset == 2 then
         if t_f(85, 96) then return 1 end
      elseif bonus_offset == 3 then
         if t_f(97, 108) then return 1 end
      elseif bonus_offset == 4 then
         if t_f(109, 120) then return 1 end
      end
   end

   -- Action slots 25-72 are toggled visible/not in the interface menu.
   -- Save the bind if the bars are visible.
   local BL,BR,RB,RB2 = GetActionBarToggles()
   if RB  then 
      if t_f(25, 36) then return 1 end 
   end
   if RB2 then
      if t_f(37, 48) then return 1 end 
   end
   if BR  then
      if t_f(49, 60) then return 1 end
   end
   if BL  then 
      if t_f(61, 72) then return 1 end
   end

   -- Is possession bar visible?
   if IsPossessBarVisible() then
      if t_f(121, 132) then return 1 end
   end
end


-- Local function to ranslate an action slot to it's action command.
local function TranslateBlizzardActionBarSlotToBind(slot)
   local b, bind, b_name, b_type
   local adj_slot   = slot

   if slot <= 12 then
      b_type = 'ACTIONBUTTON' 
      b_name = 'ActionButton'
   elseif slot <= 24 then -- Action bar page 2
      adj_slot = slot - 12
      b_type  = 'ACTIONBUTTON'
      b_name = 'ActionButton'
   elseif slot <= 36 then
      b_name = 'MultiBarRightButton'
      adj_slot = slot - 24
   elseif slot <= 48 then
      b_name = 'MultiBarLeftButton'
      adj_slot = slot - 36
   elseif slot <= 60 then
      b_name = 'MultiBarBottomRightButton'
      adj_slot = slot - 48
   elseif slot <= 72 then
      b_name = 'MultiBarBottomLeftButton'
      adj_slot = slot - 60

   -- For most classes, new bars pop up that take the keybindings
   -- assigned to ACTIONBUTTON1-12.  This includes the possession bar.
   elseif slot <= 120 then
      local base = 0
      if     slot <= 84  then base = 72
      elseif slot <= 96  then base = 84
      elseif slot <= 108 then base = 96
      elseif slot <= 120 then base = 108
      else                    base = 120 end
      b_type = 'ACTIONBUTTON' 
      b_name = 'BonusActionButton'
      adj_slot = slot - base
   end

   -- Grab button and bind.
   b = _G[b_name .. adj_slot]
   if not b_type then b_type = b.buttonType end

   return b_type .. adj_slot
end


-- Local helper to query the client to get information
-- on an action in a particular bar slot.
-- Takes in a Slot object reference and fills it.
-- Returns 1/nil.
local function GetBlizzardActionSlotAction(s_ref, visible)
   assert(s_ref) -- Check required arg
   local slot     = s_ref:GetSlotNum()
   local name,cmd = "", nil
   
   -- Better be a texture, otherwise empty slot.
   local texture = GetActionTexture(slot);
   if not texture then
      s_ref:Clear()
      return 
   end

   -- Unless overridden, ask WoW if this slot is visible
   visible = visible or IsBlizzardActionBarSlotVisible(slot)

   -- Determine name, id, etc.
   -- [4.0.1] This now returns type, id, sub_type instead of 
   -- type, id, sub_type, spell_id
   local type, id, sub_type = GetActionInfo(slot)
   if type == "spell" then
      name = select(1, GetSpellInfo(id))
      id   = type..":"..id
   elseif type == "item" then
      name = select(1, GetItemInfo(id))
      id   = type..":"..id
   elseif type == "macro" then
      name = select(1, GetMacroInfo(id))
      id   = type..":"..id
   elseif type == "equipmentset" then
      name = id
      id   = type..":"..id                          
   elseif type == "companion" then
      name = select(1, GetSpellInfo(id))
      id = type..":"..id
   else
      name,id = slot,slot -- Should never get here
   end
   
   -- Fill in object
   s_ref:SetData(name, id, type, texture, visible)
   return 1
end


-- Local helper to query the client to get information
-- on an pet action in a particular pet bar slot.
-- Takes in a Slot object reference and fills it.
-- The slot_override arg overrides the number in the slot ref.
-- Returns 1/nil.
local function GetBlizzardPetSlotAction(s_ref, slot_override)
   assert(s_ref) -- Check required arg
   local slot     = slot_override or s_ref:GetSlotNum()

   -- Call the API to get action data.
   local name, subtext, texture, is_tok, _, _, _ = GetPetActionInfo(slot)

   -- Didn't get anything?  Clear the slot and done. 
   if not name or not texture then
      s_ref:Clear()
      return nil
   end

   -- If is_tok is not nil, need to get the actual name and texture from
   -- WoW global variables
   if is_tok then
      name    = _G[name]
      texture = _G[texture]
   end
   
   -- Fill in object
   s_ref:SetData(name, name, "spell", texture, PetHasActionBar())
   return 1
end


-- Local helper to query the client to get information
-- on an a stance action.
-- The slot_override arg overrides the number in the slot ref.
-- Takes in a Slot object reference and fills it.
-- Returns 1/nil.
local function GetBlizzardStanceSlotAction(s_ref, slot_override)
   assert(s_ref) -- Check required arg
   local slot     = slot_override or s_ref:GetSlotNum()
   local texture, name, _, _ = GetShapeshiftFormInfo(slot)

   -- Didn't get anything?  Clear the slot and done. 
   if not name or not texture then
      s_ref:Clear()
      return nil
   end

   -- Fill in object
   s_ref:SetData(name, name, "spell", texture, 1)
   return 1
end


-- TODO: Totem bar!
local function GetBlizzardTotemSlotAction(s_ref)
   return
end


--
-- ActionBindManager Functions
--

-- Check if addon src_name is loaded.
-- Note: assumes src_name matches SupportedBindTypes above.
function ABM:Loaded(src_name) 
   return SupportedBindTypes[src_name] and SupportedBindTypes[src_name].c()
end


-- Get the localized name of a supported action bar manager, or nil
-- Note: assumes src_name matches SupportedBindTypes above.
function ABM:GetLocalizedName(src_name)
   return L[src_name]
end


-- Get a tuple of (1, #max, src_name) suitable for using with
-- SlotPool:AddSlotRange().
-- Note: assumes src_name matches SupportedBindTypes above.
function ABM:GetSlotRangeFor(src_name)
   if not SupportedBindTypes[src_name] then return end
   return 1, SupportedBindTypes[src_name].n, src_name
end


-- Creates a SlotPool object with slots for all binds.
-- Note: SlotPool objects are very heavy!  Do not go crazy with this.
-- Instead, create ONE, save a ref to it, and call pool:Clear() on it 
-- to re-use memory efficiently.
function ABM:GetSlotPool()
   local sp = SlotPool:New()
   for src, tbl in pairs(SupportedBindTypes) do
      sp:AddSlotRange(1, tbl.n, src)
   end
   return sp
end


-- Get a map of all keybinds -> actions for all actions
-- belonging to the Blizzard UI.  Returns a ref to the filled
-- table.  Table looks like: { [CMD] = { key1, key2...} }
--
-- Args:
--  bind_map  (Optional): ref to a map to fill in with this
--                        information.  On missing a new table
--                        is created and filled.
--  whitelist (Optional): ref to a table with a whitelist of what
--                        commands to include in the map.
function ABM:GetBindMap(bind_map, whitelist)
   bind_map  = bind_map  or {}
   whitelist = whitelist or {}
   for i = 1, GetNumBindings(), 1 do
      local cmd     = select(1, GetBinding(i))
      bind_map[cmd] = { GetBindingKey(cmd) } 
   end
   return bind_map
end


-- Given a SlotPool instance (sp, required), fill all slots
-- in the SlotPool that are from Blizzard Bars.
function ABM:GetBlizzardActionBarSlotInfo(sp_ref)
   assert(sp_ref) -- Check required arg
   local src = "Action Bar"
   local cmd
   for s_ref in sp_ref:Iter(src, true) do
      if GetBlizzardActionSlotAction(s_ref) then
         -- Get the command for this slot and update binds.
         cmd = TranslateBlizzardActionBarSlotToBind(s_ref:GetSlotNum())
         s_ref:SetCmd(cmd)
         s_ref:UpdateBinds( { GetBindingKey(cmd) } )
         s_ref:SetSrcStr(GetSlotSrcString(src, s_ref:GetSlotNum()))
      end
   end
end
function ABM:GetBlizzardPetBarSlotInfo(sp_ref)
   assert(sp_ref) -- Check required arg
   local src = "Pet Bar"
   local cmd
   for s_ref in sp_ref:Iter(src, true) do
      if GetBlizzardPetSlotAction(s_ref) then
         -- Get the command for this slot and update binds.
         cmd = "BONUSACTIONBUTTON"..s_ref:GetSlotNum()
         s_ref:SetCmd(cmd)
         s_ref:UpdateBinds( { GetBindingKey(cmd) } )
         s_ref:SetSrcStr(GetSlotSrcString(src, s_ref:GetSlotNum()))
      end
   end
end
function ABM:GetBlizzardStanceBarSlotInfo(sp_ref)
   assert(sp_ref) -- Check required arg
   local src = "Stance Bar"
   local cmd
   for s_ref in sp_ref:Iter(src, true) do
      if GetBlizzardStanceSlotAction(s_ref) then
         -- Get the command for this slot and update binds.
         cmd = "SHAPESHIFTBUTTON"..s_ref:GetSlotNum()
         s_ref:SetCmd(cmd)
         s_ref:UpdateBinds( { GetBindingKey(cmd) } )
         s_ref:SetSrcStr(GetSlotSrcString(src, s_ref:GetSlotNum()))
      end
   end
end
-- TODO: Totem Bar
function ABM:GetBlizzardTotemBarSlotInfo(sp_ref)
   assert(sp_ref) -- Check required arg
   local src = "Totem Bar"
   local cmd
end

-- Given a SlotPool instance (sp, required), fill all slots
-- with keybinds set via Bartender4.
function ABM:GetBartender4SlotInfo(sp_ref)
   assert(sp_ref) -- Check required arg
   local slot, cmd, button, action, o_ref
   local slot_to_ref = {}

   -- Build a slot -> s_ref map.
   for s_ref in sp_ref:Iter("Bartender4", true) do slot_to_ref[s_ref:GetSlotNum()] = s_ref end

   -- Fill in the data for all slots.
   -- Slots 1-132 are action, 133-142 are pet, and 143-146 are stance.
   for s_ref in sp_ref:Iter("Bartender4", true) do
      slot = s_ref:GetSlotNum()
      cmd = nil
      
      -- Action Bar Binds
      if slot < 133 then
         button = _G["BT4Button"..slot]
         if button then
            GetBlizzardActionSlotAction(s_ref, 1)

            -- Get Blizzard binds
            cmd = TranslateBlizzardActionBarSlotToBind(slot)
            s_ref:UpdateBinds( { GetBindingKey(cmd) } )

            -- Reset command for Bartender binds.
            cmd  = "CLICK BT4Button"..slot..":LeftButton"
         else s_ref:Clear() end

      -- Pet Bar Binds
      elseif slot < 143 then
         button = _G["BT4PetButton"..(slot - 132)]
         if button then
            GetBlizzardPetSlotAction(s_ref, (slot - 132))

            -- Get Blizzard binds
            cmd = "BONUSACTIONBUTTON"..(slot - 132)
            s_ref:UpdateBinds( { GetBindingKey(cmd) } )

            -- Reset command for Bartender binds.
            cmd  = "CLICK BT4PetButton"..(slot - 132)..":LeftButton"
         else s_ref:Clear() end

      -- Stance Bar Binds
      else
         button = _G["BT4StanceButton"..(slot - 142)]
         if button then
            GetBlizzardStanceSlotAction(s_ref, (slot - 142))

            -- Get Blizzard binds
            cmd = "SHAPESHIFTBUTTON"..(slot - 142)
            s_ref:UpdateBinds( { GetBindingKey(cmd) } )

            -- Reset command for Bartender binds.
            cmd  = "CLICK BT4StanceButton"..(slot - 142)..":LeftButton"
         else s_ref:Clear() end
      end

      -- Update the slot with cmd, src, and binds.
      if cmd then
         s_ref:SetCmd(cmd)
         -- Add to the Blizzard binds with Bartender-specific binds.
         s_ref:UpdateBinds( { GetBindingKey(cmd) } )
         s_ref:SetSrcStr(GetSlotSrcString("Bartender4", slot))
      end
   end

   -- Now, correct for overlays based on button "action" attributes.
   for s_ref in sp_ref:Iter("Bartender4", true) do
      slot = s_ref:GetSlotNum()

      -- Overlays happen for action bar slots only.
      if slot < 133 then
         button = _G["BT4Button"..slot]
         if button then
            -- VISIBILITY CHECK: If this button's action (the action slot
            -- activated when the button is clicked) is not the same as 
            -- it's slot, then it issues a command for a action in a
            -- different slot.  Ex: this happens on stealth bar overlays.
            -- Make sure to get the correct action for the slot.
            if button:GetAttribute("action")
               and slot ~= button:GetAttribute("action")
               and slot_to_ref[button:GetAttribute("action")] then

               -- Copy binds from hidden slot to overlay, and mark hidden
               -- slot as not visible.
               o_ref = slot_to_ref[button:GetAttribute("action")]
               o_ref:UpdateBindsFromMap(s_ref:GetBindMap())
               s_ref:Visible(false)
            end
         end
      end
   end

end


-- Given a SlotPool instance (sp, required), fill all slots
-- with keybinds set via Dominos.
function ABM:GetDominosSlotInfo(sp_ref)
   assert(sp_ref) -- Check required arg
   local bar, slot, cmd, binds, b_start, b_end, max, d_end, b, action, o_ref
   local bind_map, slot_to_button, slot_to_ref  = {}, {}, {}
   
   -- For convienience
   local _process_bind = function(binds, b_start, b_end)
                            b = _sub(binds, b_start, b_end)
                            if not tContains(bind_map, b) then
                               _insert(bind_map, b)
                            end
                         end

   -- Dominos both re-uses Blizzard buttons + creates it own.
   -- Easiest way to handle this is to scan through the addon
   -- data structure and build a map of refs to all buttons it
   -- controls.  We can then ask Dominos for the bindings for
   -- each button.
   -- Slots 1-120 are action, 121-130 are pet, and 131-134 are stance.
   slot = 1
   for _,i in ipairs({1,2,3,4,5,6,7,8,9,10,"pet","class"}) do
      bar  = Dominos.Frame:Get(i)
      if     i == "pet"   then max  = 10
      elseif i == "class" then max  = 4
      else                     max  = 12        end
      
      if not bar or not bar:FrameIsShown() then
         slot = slot + max
      else
         for j = 1, max do
            if bar.buttons[j] then slot_to_button[slot] = bar.buttons[j] end
            slot = slot + 1
         end
      end
   end

   -- Iterate through the slots in the SlotPool ref and fill in data.
   for s_ref in sp_ref:Iter("Dominos", true) do
      slot = s_ref:GetSlotNum()
      
      -- Only decode this slot if Dominos has that bar enabled and showing,
      -- and there's a bind for the slot.
      if slot_to_button[slot] then
         -- Action
         if     slot < 121 then GetBlizzardActionSlotAction(s_ref, 1)
          -- Pet
         elseif slot < 131 then GetBlizzardPetSlotAction(s_ref, (slot - 120))
          -- Stance
         else                   GetBlizzardStanceSlotAction(s_ref, (slot - 130)) end

         -- Create the fake Dominos command: in Dominos, each
         -- button knows its own bindings (mix of Dominos and Blizz).
         cmd = "DOMINOS_"..slot
         
         -- Get the bindings from the button, and parse them into bind_map.
         binds = slot_to_button[slot]:GetBindings()
         if binds then
            wipe(bind_map)
            b_start = 1
            while(_find(binds, ", ", b_start, true)) do
               b_end, d_end = _find(binds, ", ", b_start, true)
               _process_bind(binds, b_start, b_end - 1)
               b_start = d_end + 1
            end
            _process_bind(binds, b_start, _len(binds))

            -- Update slot with finished product.
            s_ref:UpdateBinds(bind_map)
         end
         
         -- Set other slot data
         s_ref:SetCmd(cmd)
         s_ref:SetSrcStr(GetSlotSrcString("Dominos", slot))

         -- Add a slot -> slot object reference for use below.
         slot_to_ref[slot] = s_ref
      end
   end

   -- Now, correct for overlays based on button "action" attributes.
   for s_ref in sp_ref:Iter("Dominos", true) do
      slot = s_ref:GetSlotNum()
      if slot_to_button[slot] and -- Not all slots may be enabled
         slot_to_button[slot]:GetAttribute("action") then -- Pet/Stance buttons don't have this
         action = slot_to_button[slot]:GetAttribute("action")

         -- Does this button have an overlay?  If so, copy binds from hidden
         -- slot to overlay, and mark hidden slot as not visible.
         if action and slot_to_ref[action] and action ~= slot then
            slot_to_ref[action]:UpdateBindsFromMap(s_ref:GetBindMap())
            s_ref:Visible(false)
         end

      end
   end
end


-- Given a SlotPool instance (sp, required), fill all slots
-- with keybinds set via BindPad.
function ABM:GetBindPadSlotInfo(sp_ref)
   assert(sp_ref) -- Check required arg
   local bind_map = {}
   local slot, bindpad_slot

   -- Iterate through the keys bound to this profile in BindPad, and
   -- get the associated cmd strings into the bind_map.
   for a,k in pairs(BindPadCore.GetProfileData().keys) do
      if a ~= nil then bind_map[a] = { k } end
   end   

   -- Iterate through the slots
   for s_ref in sp_ref:Iter("BindPad", true) do
      slot = s_ref:GetSlotNum()
      bindpad_slot = BindPadCore.GetAllSlotInfo(slot)
      if not bindpad_slot or bindpad_slot.action == nil then
         s_ref:Clear()
      else
         -- Fill in slot object
         s_ref:SetData(bindpad_slot.name, bindpad_slot.name,
                       bindpad_slot.type, bindpad_slot.texture, 1)

         -- Set cmd/binds
         s_ref:SetCmd(bindpad_slot.action)
         s_ref:UpdateBinds(bind_map[bindpad_slot.action] or {})
         s_ref:SetSrcStr(GetSlotSrcString("BindPad", s_ref:GetSlotNum()))      
      end
   end
end


-- Given a SlotPool object, fill all slots in the pool with data
-- from user action binds.  All supported sources of binds are
-- queried.
--
-- Args:
--  slot_pool (required): SlotPool object to fill.  If no slot pool
--                        object passed in, a new one is created 
--                        and filled with info from all action binds
--                        supported by ActionBindManager.
function ABM:GetFilledSlotPool(slot_pool)
   assert(slot_pool) -- Check required arg

   -- Get all the bind info for the requested slots in the slot pool.
   for src_name, src_data in pairs(SupportedBindTypes) do
      if src_data and ABM:Loaded(src_name) then src_data.f(self, slot_pool) end
   end
end


--
-- Bind Support Alias Map
--

-- This is an internal structure tracking supported bind managers.
-- Each entry contains the function to read binds of that type, and
-- the maximum number of action slots supported.
--
-- To programatically check if a bind source/addon has been loaded by
-- the user, use:
--   ActionBindManager:Loaded("source name")
--
-- To get the max number of slots for a given bind manager, use:
--   ActionBindManager:GetMaxSlotNumFor("source name")
--
-- To get the localized name of an addon/bar manager, use:
--   ActionBindManager:GetLocalizedName("source name")
--
-- Structure:
--  ["src_name] = {
--                  f = callback for gather info from that source
--                  n = # of slots (max)
--                  c = callback to check if this source is loaded.
--                } 
SupportedBindTypes = {
   -- Blizzard --
   -- As of 4.0.6 there are 132 Blizz action slots, including poss. bar
   ["Action Bar"] = {
      f = ABM.GetBlizzardActionBarSlotInfo,
      n = 132,
      c = function() return true end
   },
   -- Value for n comes from a WoW API call
   ["Stance Bar"] = {
      f = ABM.GetBlizzardStanceBarSlotInfo,
      n = GetNumShapeshiftForms(),
      c = function() return true end
   }, 
   -- Value for n comes from a WoW global
   ["Pet Bar"]    = {
      f = ABM.GetBlizzardPetBarSlotInfo,
      n = NUM_PET_ACTION_SLOTS,
      c = function() return true end
   },
   -- Coming soon
   ["Totem Bar"]  = nil,

   -- Addons --
   -- For simplicity, assume both Bartender and Dominos have a max of 
   -- 132 (action) + 10 (pet) + 4 (stance) = 146 slots.
   ["Dominos"]    = {
      f = ABM.GetDominosSlotInfo,
      n = 146,
      c = function() return Dominos     ~= nil end
   },
   ["Bartender4"] = {
      f = ABM.GetBartender4SlotInfo,
      n = 146,
      c = function() return Bartender4  ~= nil end
   },
   -- 168 slots available as of BindPad 2.3.7
   ["BindPad"]    = {
      f = ABM.GetBindPadSlotInfo,
      n = 168,
      c = function() return BindPadCore ~= nil end
   },
   -- Coming soon
   ["Vuhdo"]      = nil,
   -- Coming soon
   ["Clique"]     = nil,
   -- Coming soon
   ["CT_BarMod"]  = nil,
}

