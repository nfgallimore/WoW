-- Unit tests for FitzUtilsFifoList objects, part of the FitzUtils
-- library.
-- Note--needs to be run with the addon directory as the current
-- working directory.

-- Load up libs required for testing.
require('test/luaunit/luaunit')
require("Util")
require("FifoList")

-- Upvalues
local FL = FitzUtilsFifoList;
local U  = FitzUtils;


-- Focused tests on the bounded FIFO list
TestFifoList = {} 
    function TestFifoList:setUp()
    end

    -- Helper to compare stats lists deterministically
    function TestFifoList:compare(a, b)
       U:Print(U:TableToString(a))
       U:Print(U:TableToString(b))
       assertEquals(a._F, b._F)
       assertEquals(a._L, b._L)
       for i = a._F, a._L, 1 do
          assertEquals(a[i], b[i])
       end
    end

    -- Test size limiting functionality
    function TestFifoList:test_size()
       local t = FL:New(3)
       FL:Push(t, 1)
       assertEquals(FL:Size(t), 1)
       FL:Push(t, 2)
       assertEquals(FL:Size(t), 2)
       FL:Push(t, 3)
       assertEquals(FL:Size(t), 3)
       FL:Push(t, 4)
       assertEquals(FL:Size(t), 3)

       -- Test unlimited size
       local t = FL:New()
       FL:Push(t, 1)
       assertEquals(FL:Size(t), 1)
       FL:Push(t, 2)
       assertEquals(FL:Size(t), 2)
       FL:Push(t, 3)
       assertEquals(FL:Size(t), 3)
       FL:Push(t, 4)
       assertEquals(FL:Size(t), 4)    
    end

    -- Test tail functionality
    function TestFifoList:test_tail()
       local t = FL:New(3)

       FL:Push(t, 1)
       assertEquals(FL:Tail(t), 1)
       assertEquals(FL:Tail(t), 1)
       FL:Push(t, 4)
       assertEquals(FL:Tail(t), 4)
       FL:Push(t, 2)
       FL:Push(t, 3)
       assertEquals(FL:Tail(t), 3)
       FL:Evict(t) -- Evicts 1 (first in), last in is still 3
       assertEquals(FL:Tail(t), 3)
       FL:Push(t, 1)
       assertEquals(FL:Tail(t), 1)
    end

    -- Test push functionality
    function TestFifoList:test_push()
       local t = FL:New(3)
       local e = nil

       -- Simple case
       FL:Push(t, 1)
       FL:Push(t, 2)
       FL:Push(t, 3)
       e = {_L=3, _F=1}
       e[1] = 1
       e[2] = 2
       e[3] = 3
       self:compare(t, e)

       -- Evict one, add one.
       FL:Push(t, 4)
       e = {_L=4, _F=2}
       e[2] = 2
       e[3] = 3
       e[4] = 4
       self:compare(t, e)

       -- Evict all.
       FL:Push(t, 5)
       FL:Push(t, 6)
       FL:Push(t, 7)
       FL:Push(t, 8)
       e = {_L=8, _F=6}
       e[6] = 6
       e[7] = 7
       e[8] = 8
       self:compare(t, e)
    end

    -- Test evict functionality
    function TestFifoList:test_evict()
       local t = FL:New(3)
       local e = nil

       -- Create a test array.
       FL:Push(t, 1)
       FL:Push(t, 2)
       FL:Push(t, 3)
       e = {_L=3, _F=1}
       e[1] = 1
       e[2] = 2
       e[3] = 3
       self:compare(t, e)

       -- Now clean out entirely via evict
       assertEquals(FL:Evict(t), 1)
       assertEquals(FL:Evict(t), 2)
       assertEquals(FL:Evict(t), 3)
       e = {_L=3, _F=4}
       self:compare(t, e)
       
       -- Reinsert and test
       FL:Push(t, 4)
       FL:Push(t, 5)
       e = {_L=5, _F=4}
       e[4] = 4
       e[5] = 5
       self:compare(t, e)
    end
       
    -- Test iterator functionality
    function TestFifoList:test_iter()
       local t = FL:New(3)
       local e = nil

       -- Create a test array.
       FL:Push(t, 1)
       FL:Push(t, 2)
       FL:Push(t, 3)

       -- Iterate
       local i = 1
       for v in FL:Iter(t) do
          assertEquals(v, i)
          i = i + 1
       end

       -- Ensure ordering after evictions
       FL:Push(t, 6)
       FL:Push(t, 5)
       FL:Push(t, 4)
       -- Iterate
       local i = 6
       for v in FL:Iter(t) do
          assertEquals(v, i)
          i = i - 1
       end
    end


-- Run all tests unless overriden on the command line.
LuaUnit:run("TestFifoList")



