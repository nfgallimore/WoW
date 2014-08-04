--
-- Create and manage SlotPool and Slot objects.
-- 

-- Main table for SlotPool methods.
SlotPool = {}

-- Local binds for speed
local _insert = table.insert


--
-- Local Helpers
--

-- (Internal) Get an id for a src_tag and slot number.
local function _GetSlotId(slot_num, src_tag)
   if slot_num == nil then slot_num = "" end
   if src_tag  == nil then src_tag  = "" end
   return slot_num..src_tag
end


--
-- Slot Object Definiton
--

-- Local definition, only creatable by SlotPools.
local Slot = {}

-- Create a blank new slot.
-- All args required, pool_ref is a reference back to the
-- pool containing this slot.  Slot created has a slot num
-- and src_tag, and is no longer blank.
function Slot:New(slot_num, src_tag, pool_ref)
   local o = {
      _pool_ref = pool_ref,
      _action   = {
         name    = nil,
         id      = nil,
         type    = nil,
         texture = nil,
         visible = nil,
      },
      _bind_map = {},
      _src_tag  = src_tag,
      _cmd      = nil,
      _slot_num = slot_num,
      _is_dup   = nil,
      _is_blank = 1,
      _src_str  = nil,
   }
   setmetatable(o, self)
   self.__index = self
   return o
end

-- Clear slot data.
function Slot:Clear()
   wipe(self._action)
   wipe(self._bind_map)
   self._is_dup   = nil
   self._src_tag  = nil
   self._cmd      = nil
   self._slot_num = nil
   self._src_str  = nil
   self._is_blank = 1
end

-- Repurpose a slot
function Slot:Recycle(slot_num, src_tag)
   assert(self:IsBlank()) -- Otherwise, error.
   self._slot_num = slot_num
   self._src_tag  = src_tag
end

-- Set the action data.
function Slot:SetData(name, id, type, texture, visible)
   self._action.name    = name
   self._action.id      = id
   self._action.type    = type
   self._action.texture = texture
   self._action.visible = visible
   self._is_blank       = nil
end

-- Copy action data from another slot
function Slot:CopyDataFrom(other)
   assert(other ~= nil and other._action ~= nil)
   self._action.name    = other._action.name
   self._action.id      = other._action.id
   self._action.type    = other._action.type
   self._action.texture = other._action.texture
   self._action.visible = other._action.visible
   self._is_blank       = other._is_blank
end



-- Set the command for this slot, and also update the 
-- SlotPool containing this slot.
-- The arg cmd is a string corr. to a UI command ("ACTIONBUTTON1")
function Slot:SetCmd(cmd)
   self._cmd = cmd
   -- Now update the slot pool object containing this slot.
   -- A command can only refer to one slot.
   self._pool_ref._cmd_to_slot[cmd] = self
end

-- Set an arbitrary string to describe the source of this slot,
-- i.e. "Dominos Pet Bar".  
-- Note: the src_str is assumed to be already localized.
function Slot:SetSrcStr(src_str)
   self._src_str = src_str
end

-- Update the binds for this slot from the table reference,
-- and also update the Slot Pool containing this bind.
-- The arg binds is a list table of strings.
function Slot:UpdateBinds(binds)
   for _,b in ipairs(binds) do self._bind_map[b] = 1 end

   -- Now update the slot pool object containing this slot.
   -- There can only be one slot for each bind.
   -- First remove all mappings from the parameter table.
   for _,b in ipairs(binds) do self._pool_ref._bind_to_slot[b] = nil end

   -- Register this slot for all binds in the updated table.
   for b,_ in pairs(self._bind_map) do
      self._pool_ref._bind_to_slot[b] = self
   end
end

-- Same as above, but accepts a map of bind => 1/nil.
-- For convenience.
function Slot:UpdateBindsFromMap(bind_map)
   local b_list = {}
   for b,_ in pairs(bind_map) do _insert(b_list, b) end
   return self:UpdateBinds(b_list)
end

-- Check if this slot has a bind or not.  Returns 1/nil
function Slot:HasBind()
   for b,_ in pairs(self._bind_map) do return 1 end
end

-- Convienience method: check if the input key seq is bound to 
-- this slot.  Returns 1/nil
function Slot:CheckBind(bind)
   if self._bind_map[bind] then return 1 end
end

-- Mark this slot as containing the same action as another 
-- slot.
function Slot:MarkDup()       self._is_dup = 1             end

-- Mark this slot as visible/not visible.
function Slot:Visible(v)
   if v then self._action.visible = 1
   else      self._action.visible = nil end
end

-- Accessors
function Slot:GetActionId()   return self._action.id              end
function Slot:GetActionName() return self._action.name            end
function Slot:GetType()       return self._action.type            end
function Slot:GetTexture()    return self._action.texture         end
function Slot:IsVisible()     return self._action.visible         end

function Slot:GetBindMap()    return self._bind_map                end
function Slot:GetSrcTag()     return self._src_tag                 end
function Slot:GetSlotNum()    return self._slot_num                end
function Slot:GetCmd()        return self._cmd                     end
function Slot:GetSrcStr()     return self._src_str                 end

function Slot:IsDup()         return self._is_dup                  end
function Slot:IsBlank()       return self._is_blank                end
function Slot:GetId()         return _GetSlotId(self._slot_num,
                                                self._src_tag)     end

--
-- SlotPool Object Definiton
--

-- Create a new slot pool.  These are heavy; ideally create
-- one and manage it throughout your app.
function SlotPool:New()
   local o = {
      _slots           = {},
      _slot_id_to_slot = {},
      _bind_to_slot    = {},
      _cmd_to_slot     = {},
      _n               = 1,
   }
   setmetatable(o, self)
   self.__index = self
   return o
end

-- Clear a SlotPool.  Note we don't delete the slots table; we'll
-- re-use slot objects in subsequent adds.
function SlotPool:Clear()
   -- Clear the lookup tables.
   wipe(self._slot_id_to_slot)
   wipe(self._bind_to_slot)
   wipe(self._cmd_to_slot)

   -- Clean up the slots.
   for _,s in ipairs(self._slots) do s:Clear() end
   self._n = 1
end

-- Functions for manipulating the slots in a set -->

-- Add a slot, returning a reference to the Slot object
-- for further modification.  Returns a reference to the
-- Slot object added.
function SlotPool:AddSlot(slot_num, src_tag)
   local i  = self._n
   local id = _GetSlotId(slot_num, src_tag)

   -- Ensure this slot id doesn't already exist--otherwise, error
   assert(self._slot_id_to_slot[id] == nil)

   -- Expand the pool if nec
   if not self._slots[i] then
      self._slots[i] = Slot:New(slot_num, src_tag, self)
   else
      assert(self._slots[i]:IsBlank()) -- major error otherwise
      self._slots[i]:Recycle(slot_num, src_tag)
   end
   self._n = i + 1

   -- Register in lookup table.
   self._slot_id_to_slot[id] = self._slots[i]
   return self._slots[i]
end

-- Add a range of slots from src_tag.  Returns start and end
-- index of slot range added, which can then be used with Get()
-- to get references to the Slot objects.
function SlotPool:AddSlotRange(s_num, e_num, src_tag)
   local s = self._n
   for i = s_num, e_num, 1 do self:AddSlot(i, src_tag) end
   local e = self._n - 1
   return s,e
end

-- Lazily delete a slot, returning 1 on success, nil on not found
function SlotPool:RemoveSlot(slot_num, src_tag)
   local s = self._slot_id_to_slot[_GetSlotId(slot_num, src_tag)]
   if not s then return nil end
   s:Clear()
   return 1
end


-- Lookup functions for slots -->

-- Return the slot associated with a key sequence, or nil.
-- This mapping is updated each time the binds for a slot in this
-- SlotPool are are updated.
-- Optional arg allow_blank allows blank slots to be returned (def: false)
function SlotPool:GetSlotForBind(bind, allow_blank)
   -- Can only have one bind per slot; otherwise, you could execute
   -- two cmds with a single keystroke.
   local s = self._bind_to_slot[bind]
   if s == nil or allow_blank then return s end
   if s and not s:IsBlank() then return s end
end

-- Return the slot associated with the UI command cmd, or nil
-- This mapping is updated each time the binds for a slot in this
-- SlotPool are are updated.
-- Optional arg allow_blank allows blank slots to be returned (def: false)
function SlotPool:GetSlotForCmd(cmd, allow_blank)
   -- Likewise, each command can only refer to a single action slot.
   local s = self._cmd_to_slot[cmd]
   if s == nil or allow_blank then return s end
   if s and not s:IsBlank() then return s end
end

-- Scan the slots and return a list (table) of refs to all slots
-- that contain action id.  An empty list is returned if no matching
-- slots are found.
function SlotPool:GetSlotsWithActionId(action_id)
   assert(action_id ~= nil)
   local ret_tab = {}
   for _,s in ipairs(self._slots) do
      if not s:IsBlank() and s:GetActionId() == action_id then
         _insert(ret_tab, s)
      end
   end
   return ret_tab
end

-- Scan the slots and return a list (table) of refs to all slots
-- that contain an action matching action_name, or nil. An empty list
-- is returned if no matching slots are found.
function SlotPool:GetSlotsWithActionName(action_name)
   assert(action_name ~= nil)
   local ret_tab = {}
   for _,s in ipairs(self._slots) do
      if not s:IsBlank() and s:GetActionName() == action_name then
         _insert(ret_tab, s)
      end
   end
   return ret_tab
end


-- Return number of slots in the pool
-- NOTE NOTE NOTE: this number also includes blank slots.
function SlotPool:Num()
   return self._n - 1
end

-- Get slot i in the slotset, or nil
-- If allow_blank is nil (def), this will return nil for blank slots
function SlotPool:Get(i, allow_blank)
   assert(i >= 1 and i <= self._n)
   local s = self._slots[i]
   if s and s:IsBlank() then
      if allow_blank then return s
      else return end
   end
   return s
end

-- Get slot for slot_num, src_tag, or nil
-- If allow_blank is nil (def), this will return nil for blank slots
function SlotPool:GetFor(slot_num, src_tag, allow_blank)
   local s = self._slot_id_to_slot[_GetSlotId(slot_num, src_tag)]
   if s and s:IsBlank() and not allow_blank then return end
   return s
end


-- Get an iterator over the slots in the pool
-- Optional arguments:
--    src_tag: Only iterate over slots tagged with src_tag (def: all)
--    allow_blank: Allow blank slots to be returned.  This can only 
--                 occur if the src_tag argument is not supplied.
--                 (def: false)
--    allow_dups: Allow slots containing duplicate actions to be
--                returned (def: false)
function SlotPool:Iter(src_tag, allow_blank, allow_dups)
   local i = 0
   return function()
             while(i < self:Num()) do
                i = i + 1
                local s = self:Get(i, allow_blank)
                if s then
                   if src_tag then
                      if src_tag == s:GetSrcTag() then
                         if (s:IsDup() and allow_dups) or not s:IsDup() then return s end
                      end
                   else
                      if (s:IsDup() and allow_dups) or not s:IsDup() then return s end
                   end
                end
             end
          end
end
