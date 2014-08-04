-- Unit tests for SlotPool.lua, part of the Binds library.
-- Run from the Binds directory

-- Load unit test library
require('test/TestTools')

-- Turn on/off debug output
DEBUG = true

TestSlotPool = {} 
    function TestSlotPool:setUp()
    end

    -- Shortcut for dump/tequal that will prevent an infinite loop/stack overflow
    function TestSlotPool:dump(this, d)
       if not d then d = 6 end
       dump(this, nil, nil, d)
    end
    function TestSlotPool:tequal(a, b)
       tequal(a, b, 6)
    end

    -- Tests -->
    function TestSlotPool:test_AddSlot()
       local sp = SlotPool:New()
       local s  = nil

       -- Add 3 slots, test num.
       sp:AddSlot(1, "a")
       sp:AddSlot(1, "b")
       sp:AddSlot(1, "c")
       assert(sp:Num() == 3)

       -- Test adding duplicate slots.
       assertError(sp.AddSlot, sp, 1, "c")

       -- Clear, test num
       sp:Clear()
       assert(sp:Num() == 0)

       -- Add slot, test Get behavior
       sp:AddSlot(2, "d"):SetData()
       s = sp:Get(1)
       assert(s:GetSlotNum() == 2)
       assert(s:GetSrcTag() == "d")
       assert(s:IsBlank() == nil)
       s = sp:Get(2, true) -- Get blank slot left over in the slot pool
       assert(s:IsBlank() == 1)
       s = sp:Get(2)
       assert(s == nil)
       assertError(sp.Get, sp, 200)

       -- Test GetFor behavior
       s = sp:GetFor(2, "d")
       s:SetData()
       assert(s:GetSlotNum() == 2)
       assert(s:GetSrcTag() == "d")
       assert(s:IsBlank() == nil)   
       assert(sp:GetFor(2, "XXXX") == nil)

       -- Remove slot
       assert(sp:RemoveSlot(2, "d") == 1)

       -- Try to add duplicate slots.
       sp:AddSlot(1, "a")
       assertError(sp.AddSlot, sp, 1, "a")
    end

    function TestSlotPool:test_AddSlotRange()
       local sp = SlotPool:New()
       local s  = nil
       local s_n, e_n
       
       -- Add a range of slots from 3-9 for a/b
       s_n, e_n = sp:AddSlotRange(3, 9, "a")
       assert(s_n == 1 and e_n == 7)
       s_n, e_n = sp:AddSlotRange(3, 9, "b")
       assert(s_n == 8 and e_n == 14)
       assert(sp:Num() == 14)
       
       -- Remove non-existant slot
       assert(sp:RemoveSlot(2, "d") == nil)

       -- Remove slot
       assert(sp:RemoveSlot(3, "a") == 1)
       assert(sp:Get(1) == nil)
       
       -- Test Get behavior--2nd slot is 4a, 10 is 5b
       s = sp:Get(2, true)
       s:SetData()
       assert(s:GetSlotNum() == 4)
       assert(s:GetSrcTag() == "a")
       assert(s:IsBlank() == nil)
       s = sp:Get(10, true)
       s:SetData()
       assert(s:GetSlotNum() == 5)
       assert(s:GetSrcTag() == "b")
       assert(s:IsBlank() == nil)

       -- Clear, test num
       sp:Clear()
       assert(sp:Num() == 0)
    end

    function TestSlotPool:test_Slot()
       local sp = SlotPool:New()
       local s  = nil

       -- Create and Get a slot
       s = sp:AddSlot(2, "d")
       s:SetData()
       assert(s:GetSlotNum() == 2)
       assert(s:GetSrcTag() == "d")
       assert(s:IsBlank() == nil)

       -- Test Clear and Recycle
       s:Clear()
       assert(s:GetSlotNum() == nil)
       assert(s:GetSrcTag() == nil)
       assert(s:IsBlank() == 1) 
       s:Recycle(1, "a")
       s:SetData()
       assert(s:GetSlotNum() == 1)
       assert(s:GetSrcTag() == "a")
       assert(s:IsBlank() == nil)

       -- Set data and test accessor behavior
       s:SetData("action", "action_id", "test", "texture", 1)
       assert(s:GetActionName() == "action")
       assert(s:GetActionId() == "action_id")
       assert(s:GetType() == "test")
       assert(s:GetTexture() == "texture")
       assert(s:IsVisible() == 1)
       s:SetData("action2", "action_id2", "test2", "texture2")
       assert(s:GetActionName() == "action2")
       assert(s:GetActionId() == "action_id2")
       assert(s:GetType() == "test2")
       assert(s:GetTexture() == "texture2")
       assert(s:IsVisible() == nil)

       -- Set/fetch cmd
       s:SetCmd("TEST")
       assert(s:GetCmd() == "TEST")
       s:SetCmd("TEST2")
       assert(s:GetCmd() == "TEST2")

       -- Mark as dup and check
       assert(s:IsDup() == nil)
       s:MarkDup()
       assert(s:IsDup() == 1)
       
       -- Binds
       local b1 = {"1", "2"}
       local b2 = {"a", "2"}
       assert(s:HasBind() == nil)
       s:UpdateBinds(b1)
       assert(s:HasBind() == 1)
       assert(t_equal(s:GetBindMap(), {["1"] = 1, ["2"] = 1}))
       s:UpdateBinds(b2)
       assert(t_equal(s:GetBindMap(), {["1"] = 1, ["2"] = 1, ["a"] = 1}))
       assert(s:CheckBind("a") == 1)
       assert(s:CheckBind("1") == 1)
       assert(s:CheckBind("2") == 1)
       assert(s:CheckBind("xx") == nil)
    end

    function TestSlotPool:test_Lookups()
       local sp = SlotPool:New()
       local s  = nil

       local _r = table.remove
       local _t = function(ret, id_list)
                     local f
                     for _, s in ipairs(ret) do
                        f = false
                        for i,id in ipairs(id_list) do
                           if id == s:GetId() then
                              if f then return false end
                              f = true
                              _r(id_list, i)
                           end
                        end
                     end
                     return (#id_list == 0)
                  end

       -- Create slots and add data to them.
       s = sp:AddSlot(2, "a")       
       s:SetData("action", "action_id", "test", "texture", 1)
       s:UpdateBinds({"1", "a"})
       s:SetCmd("TEST")
       s = sp:AddSlot(2, "b")       
       s:SetData("action2", "action_id2", "test2", "texture2")
       s:UpdateBinds({"a", "2"})
       s:SetCmd("TEST2")
       s = sp:AddSlot(1, "a")       
       s:SetData("action2", "action_id2", "test2", "texture2")
       s:UpdateBinds({"x", "y"})
       s:SetCmd("TEST3")

       -- Test lookups by bind.
       assert(sp:GetSlotForBind("x"):GetId() == "1a")
       assert(sp:GetSlotForBind("1"):GetId() == "2a")
       assert(sp:GetSlotForBind("a"):GetId() == "2b")
       assert(sp:GetSlotForBind("y"):GetId() == "1a")
       assert(sp:GetSlotForBind("xx") == nil)
       
       -- Test lookups by cmd
       assert(sp:GetSlotForCmd("TEST"):GetId() == "2a")
       assert(sp:GetSlotForCmd("TEST2"):GetId() == "2b")
       assert(sp:GetSlotForCmd("TEST3"):GetId() == "1a")
       assert(sp:GetSlotForCmd("TESTSAREFUN") == nil)

       -- Test lookups by action_id
       assert(_t(sp:GetSlotsWithActionId("action_id"), {"2a"}))
       assert(_t(sp:GetSlotsWithActionId("action_id2"), {"1a", "2b"}))
       assert(_t(sp:GetSlotsWithActionId("action_id4"), {}))

       -- Test lookups by action name
       assert(_t(sp:GetSlotsWithActionName("action"), {"2a"}))
       assert(_t(sp:GetSlotsWithActionName("action2"), {"1a", "2b"}))
       assert(_t(sp:GetSlotsWithActionName("actionsarecool"), {}))

       -- Clear an action and test behavior.
       s = sp:Get(3)
       assert(s:GetId() == "1a")
       s:Clear()
       assert(sp:GetSlotForBind("x") == nil)
       assert(sp:GetSlotForBind("1"):GetId() == "2a")
       assert(sp:GetSlotForBind("a"):GetId() == "2b")
       assert(sp:GetSlotForBind("y") == nil) 
       assert(sp:GetSlotForCmd("TEST"):GetId() == "2a")
       assert(sp:GetSlotForCmd("TEST2"):GetId() == "2b")
       assert(sp:GetSlotForCmd("TEST3") == nil)
       assert(_t(sp:GetSlotsWithActionId("action_id"), {"2a"}))
       assert(_t(sp:GetSlotsWithActionId("action_id2"), {"2b"}))
       assert(_t(sp:GetSlotsWithActionName("action"), {"2a"}))
       assert(_t(sp:GetSlotsWithActionName("action2"), {"2b"}))

       -- Add more actions and test behavior
       s = sp:AddSlot(3, "a")       
       s:SetData("action2", "action_id2", "test2", "texture2")
       s:UpdateBinds({"x", "y"})
       s:SetCmd("TEST4")
       s = sp:AddSlot(4, "a")       
       s:SetData("action2", "action_id2", "test2", "texture2")
       s:UpdateBinds({"x", "y"})
       s:SetCmd("TEST5")
       assert(sp:GetSlotForBind("x"):GetId() == "4a")
       assert(sp:GetSlotForBind("y"):GetId() == "4a")
       assert(sp:GetSlotForCmd("TEST4"):GetId() == "3a")
       assert(sp:GetSlotForCmd("TEST5"):GetId() == "4a")
       assert(_t(sp:GetSlotsWithActionId("action_id"), {"2a"}))
       assert(_t(sp:GetSlotsWithActionId("action_id2"), {"2b", "3a", "4a"}))
       assert(_t(sp:GetSlotsWithActionName("action"), {"2a"}))
       assert(_t(sp:GetSlotsWithActionName("action2"), {"2b", "3a", "4a"}))
    end

    function TestSlotPool:test_Iter()
       local sp = SlotPool:New()
       local s  = nil

       local _r = table.remove
       local _t = function(iter, id_list)
                     for s in iter do
                        if s:GetId() ~= id_list[1] then return false end
                        _r(id_list, 1)
                     end
                     return (#id_list == 0)
                  end

       -- Create slots and add data to them.
       s = sp:AddSlot(1, "a")       
       s:SetData("action", "action_id", "test", "texture", 1)
       s:UpdateBinds({"1", "a"})
       s:SetCmd("TEST")
       s = sp:AddSlot(1, "b")       
       s:SetData("action2", "action_id2", "test2", "texture2")
       s:UpdateBinds({"a", "2"})
       s:SetCmd("TEST2")
       s = sp:AddSlot(2, "a")       
       s:SetData("action3", "action_id3", "test3", "texture3")
       s:UpdateBinds({"x", "y"})
       s:SetCmd("TEST3")       
       s = sp:AddSlot(2, "b")       
       s:SetData("action4", "action_id4", "test4", "texture4")
       s:UpdateBinds({"x", "y"})
       s:SetCmd("TEST4")       
       s = sp:AddSlot(3, "a")       
       s:SetData("action", "action_id", "test", "texture")
       s:UpdateBinds({"x", "y"})
       s:SetCmd("TEST5")

       -- Iterate over ALL slots
       assert(_t(sp:Iter(), { "1a", "1b", "2a", "2b", "3a"}))
       
       -- Iterate over slots for src
       assert(_t(sp:Iter("a"), { "1a", "2a", "3a" }))
       assert(_t(sp:Iter("b"), { "1b", "2b" }))
       assert(_t(sp:Iter("c"), { }))

       -- Mark 3a as a dup, and test iteration
       s = sp:Get(5)
       assert(s:GetId() == "3a")
       s:MarkDup()
       assert(_t(sp:Iter("a"), { "1a", "2a" }))
       assert(_t(sp:Iter("a", nil, 1), { "1a", "2a", "3a" }))
       assert(not _t(sp:Iter("a", nil, 1), { "1a", "2a" }))

       -- Delete 3a, and test iteration
       sp:RemoveSlot(3, "a")
       assert(_t(sp:Iter("a"), { "1a", "2a" }))
       assert(_t(sp:Iter(), { "1a", "1b", "2a", "2b"}))
       assert(_t(sp:Iter(nil, 1), { "1a", "1b", "2a", "2b", ""}))
       assert(_t(sp:Iter("c"), { }))
    end



-- Run all tests unless overriden on the command line.
LuaUnit:run("TestSlotPool")



