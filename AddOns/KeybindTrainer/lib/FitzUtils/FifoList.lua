--
-- Simple bounded list class that implements a queue API.
-- Based loosely on/enhanced from code from lua.org.
--

-- Namespace
FitzUtilsFifoList = { }

-- Reserved key names for tracking the 
-- front and back of the list.
local g_front = "_F"
local g_last  = "_L"
local g_limit = "_S"


-- Constructor.  Returns a FifoList table.
-- Args:
--  limit (opt): Limit the size of the list.
function FitzUtilsFifoList:New(limit)
   if limit ~= nil then assert(type(limit) == "number" and limit > 0) end
   return { [g_front] = 1, [g_last] = 0, [g_limit] = limit}
end

-- Returns list size.
-- Args:
--  list (req): List ref.
function FitzUtilsFifoList:Size(list)
   assert(list and type(list) == "table")
   return (list[g_last] - list[g_front]) + 1
end

-- Returns the last element inserted, or nil
function FitzUtilsFifoList:Tail(list)
   return list[list[g_last]]
end

-- Push a value onto the list.  If there is a limit,
-- returns evicted element if over limit, else nil.
-- Will not push nil values on the list.
-- Args:
--  list  (req): List ref.
--  value (req): Value to push
function FitzUtilsFifoList:Push(list, value)
   assert(list and type(list) == "table")
   if value == nil then return end -- Nothing to add to list.

   local L = list[g_last] + 1
   list[g_last] = L
   list[L] = value
   
   if list[g_limit] and self:Size(list) > list[g_limit] then
      return self:Evict(list)
   end
end
    
-- Returns evicted element, else nil
-- Args:
--  list  (req): List ref.
function FitzUtilsFifoList:Evict(list)
   assert(list and type(list) == "table")
   local F = list[g_front]
   if F > list[g_last] then return nil end
   local value = list[F]
   list[F] = nil        -- to allow garbage collection
   list[g_front] = F + 1
   return value
end

-- Get a lua iterator over the queue, returning elements in-order
-- Args:
--  list  (req): List ref.
function FitzUtilsFifoList:Iter(list)
   assert(list and type(list) == "table")
   local i = list[g_front]
   return function()
             if i > list[g_last] then return nil end
             local v = list[i]
             i = i + 1
             return v
          end
end

