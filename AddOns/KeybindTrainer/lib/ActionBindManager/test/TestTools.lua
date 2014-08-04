-- Set up the unit test environment for addon code.
-- This file should be included in all unit tests.

DEBUG = false

--
-- Define Shared Test Helpers
--

-- Debug print to turn on/off with flag.
function dprint(input)
   if DEBUG then print(input) end
end

-- Recursively output table or value, with an optional
-- function input to do something other than print.
-- Optional argument depth forces a depth limit on the dump to
-- allow this function to be used on structures with cycles.
function dump(this, s, func, depth)
   if depth == nil then depth = 99 
   elseif depth == 0 then return end

   if not func then func = dprint end
   if s == nil then s = "" end

   if this == nil then
      func("NIL")
      return
   end
   if type(this) == "table" then
      for k,v in pairs(this) do
         if type(k) == "function" or type(k) == "table" or type(k) == "function" then
            dump(k, s.." ", func, depth - 1)
            func(s.."  -> ")
         else
            func(s..k..":")
         end
         dump(v, s.." ", func, depth - 1)
      end
   elseif type(this) == "function" then
      func(s.."< function >")
   elseif type(this) == "userdata" then
      func(s.."< userdata >")
   else
      if this == true then  this = "true"  end
      if this == false then this = "false" end
      func(s..this)
   end
end

-- Print out expected and actual
function dcomp(exp, act)
   dprint("\n  >> EXPECTED >> ");
   dump(exp, nil, dprint)
   dprint("  << ACTUAL << ");
   dump(act, nil, dprint)
end

-- Based on lua wiki--compare across most types of values
function equal(op1, op2)
   local type1, type2 = type(op1), type(op2)
   if type1 ~= type2 then --cmp by type
      return false
   elseif type1 == "number" and type2 == "number"
      or type1 == "string" and type2 == "string" then
      return op1 == op2 --comp by default
   elseif type1 == "boolean" and type2 == "boolean" then
      return op1 == op2
   else
      return tostring(op1) == tostring(op2) --cmp by address
   end
end

-- Compare two tables via intersection.  Handles nested
-- subtables to "depth" (def: 99)
function t_equal(a, b, depth)
   if depth == nil then depth = 99 
   elseif depth == 0 then return end

   if type(a) ~= "table" or type(b) ~= "table" then return false end
   local res = {}
   for k,v in pairs(a) do res[k] = v end
   for k,v in pairs(b) do
      if res[k] then
         if type(v) == type(res[k]) then
            if type(v) == "table" and t_equal(res[k], v, depth - 1) then
               res[k] = nil
            elseif equal(res[k], v) then
               res[k] = nil
            end
         end
      else
         dprint("Diff keysets found in input:")
         dcomp(a,b)
         return false -- key in b not in a, no need to contine
      end
   end
   -- if there are keys left in res, false.  Else true.
   for k in pairs(res) do 
      dprint("Diff keysets found in input:")
      dcomp(a,b)
      return false
   end
   return true
end

-- Deep copy a table, excepting metatables (refs copied for metatables).
-- Taken from the lua wiki.
function deepcopy(object)
   local lookup_table = {}
   local function _copy(object)
      if type(object) ~= "table" then
         return object
      elseif lookup_table[object] then
         return lookup_table[object]
      end  -- if
      local new_table = {}
      lookup_table[object] = new_table
      for index, value in pairs(object) do
         new_table[_copy(index)] = _copy(value)
      end  -- for
      return setmetatable(new_table, getmetatable(object))
   end  -- function _copy
   return _copy(object)
end  -- function deepcopy


-- Get current working directory for require path (from lua-users.org)
function getcwd()
   local pipe = io.popen('cd', 'r')
   local cdir = pipe:read('*l')
   pipe:close()
   return cdir
end

-- Debug t_equal that prints out expected and actual beforehand.
function dt_equal(exp, act)
   dcomp(exp, act)
   return t_equal(exp, actual)
end

         
-- Load unit test library
require('test/luaunit/luaunit')

-- Load SlotPool library
require('SlotPool')
