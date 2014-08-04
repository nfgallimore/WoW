--
-- Utility Library
--
-- Simple tools library, used across multiple addons.
--

-- Namespace
FitzUtils = {
   _DEBUG = true,
}

-- Toggle debug on/off
function FitzUtils:Debug(enable)
   self._DEBUG = enable
end


-- Simple string join, based on versions found around the web
function FitzUtils:Join (sep,...)
   s = {...}
   if type(s[1]) == "table" then s = s[1] end
   return table.concat(s,sep)
end


-- Debug printout
function FitzUtils:Print(...)
   if self._DEBUG then print(...) end
end


-- Number of keys in a non-list table.  Is there a better way to do this?
function FitzUtils:NumKeys(tbl)
   local n = 0
   if not tbl then return n end
   for _,_ in pairs(tbl) do n = n + 1 end
   return n
end


-- Recursively output most lua types, with an optional
-- function input to do something other than print.
-- Optional argument depth forces a depth limit on the dump to
-- allow this function to be used on structures with cycles.
function FitzUtils:Dump(this, s, func, depth)
   if depth == nil then depth = 99 
   elseif depth == 0 then return end

   if not func then
      func = function(...) self:Print(...) end
   end
   if s == nil then s = "" end

   if this == nil then
      func("NIL")
      return
   end
   if type(this) == "table" then
      for k,v in pairs(this) do
         if type(k) == "function" or type(k) == "table" or type(k) == "function" then
            self:Dump(k, s.." ", func, depth - 1)
            func(s.."  -> ")
         else
            func(s..k..":")
         end
         self:Dump(v, s.." ", func, depth - 1)
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


-- Recursively dump a table to a string with "delim" between fields.
-- Takes an optional depth to handle circular references.
function FitzUtils:TableToString(tbl, delim, depth)
   if not delim then delim = " " end
   local str = ""
   self:Dump(tbl, "", function (out)
                       str = str..out..delim
                      end,
             depth)
   return str
end


-- Based on lua wiki--compare across most types of values
function FitzUtils:IsEqual(op1, op2)
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


-- Print out expected and actual
function FitzUtils:Dcomp(exp, act, depth)
   self:Print("Diff keysets found in input:")
   self:Print("\n  >> EXPECTED >> ");
   self:Dump(exp, nil, nil, depth)
   self:Print("  << ACTUAL << ");
   self:Dump(act, nil, nil, depth)
end


-- Compare two tables via intersection.  Handles nested
-- subtables to "depth" (def: 99)
function FitzUtils:TableEqual(a, b, depth)
   if depth == nil then depth = 99 
   elseif depth == 0 then
      -- Interesting problem: at this point, we don't
      -- know of the tables are equal--we've run out
      -- of stack space to check.
      -- Return false because we don't know if true is the
      -- right answer.
      self:Print("OUT OF STACK SPACE!")
      return false
   end

   if type(a) ~= "table" or type(b) ~= "table" then return false end
   local res = {}
   for k,v in pairs(a) do res[k] = v end
   for k,v in pairs(b) do
      if res[k] then
         if type(v) == type(res[k]) then
            if type(v) == "table" and self:TableEqual(res[k], v, depth - 1) then
               res[k] = nil
            elseif self:IsEqual(res[k], v) then
               res[k] = nil
            end
         end
      else
         self:Dcomp(a,b,depth)
         return false -- key in b not in a, no need to contine
      end
   end
   -- if there are keys left in res, false.  Else true.
   for k in pairs(res) do 
      self:Dcomp(a,b,depth)
      return false
   end
   return true
end


-- Deep copy a table, excepting metatables (refs copied for metatables).
-- Taken from the lua wiki.
-- NOTE: does not handle circular tables.
function FitzUtils:DeepCopy(object)
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
end
