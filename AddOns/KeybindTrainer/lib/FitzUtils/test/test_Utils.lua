-- Unit tests for Util.lua, part of the FitzUtils library.
-- Run from the Binds directory

-- Load up libs required for testing.
require('test/luaunit/luaunit')
require("Util")

-- Upvalue
local U = FitzUtils;

TestFitzUtils = {} 
    function TestFitzUtils:setUp()
       -- Turn off prints
       U:Debug(false)
    end

    -- Tests -->
    function TestFitzUtils:test_Join()
       assert(U:Join("", "a", "b") == "ab")
       assert(U:Join("--", "a", "b") == "a--b")
       assert(U:Join("--", "a") == "a")
       assert(U:Join("") == "")
    end

    function TestFitzUtils:test_TableToString()
       local t = { a = 1, b = 2 }
       assert(U:TableToString(t) == "a:  1 b:  2 ")
       assert(U:TableToString(t, "-") == "a:- 1-b:- 2-")
       t.c = t -- Add circular ref, test depth limit works
       assert(U:TableToString(t, " ", 3) == "a:  1 c:  a:   1  c:   a:   c:   b:  b:   2 b:  2 ")
    end

    -- Bare bones testing for TableEqual--TODO: add more
    function TestFitzUtils:test_TableEqual()
       local t1 = { a = 1, b = 2 }
       local t2 = { a = 1, b = 2 }
       assert(U:TableEqual(t1, t2))
       t2.c = 3
       assert(not U:TableEqual(t1, t2))
       t1.c = 4
       assert(not U:TableEqual(t1, t2))
       t1.c = 3
       assert(U:TableEqual(t1, t2))
       t1.d = t1 -- add circular reference, test handling
       assert(not U:TableEqual(t1, t2, 4))
       t2.d = t1 -- add circular reference, test handling
       assert(U:TableEqual(t1, t2, 4))
       t2.d = t2 -- add circular reference, test handling
       assert(not U:TableEqual(t1, t2, 2)) -- runs out of stack!
    end

    -- Bare bones testing for DeepCopy--TODO: add more
    function TestFitzUtils:test_DeepCopy()
       local t1 = { a = 1, b = 2 }
       t2 = U:DeepCopy(t1)
       assert(U:TableEqual(t1, t2))
       -- Test nested tables
       t1.c = { g = 3, h = { 1,2,3,4 } }
       t2 = U:DeepCopy(t1)
       assert(U:TableEqual(t1, t2))       
    end

-- Run all tests unless overriden on the command line.
LuaUnit:run("TestFitzUtils")



