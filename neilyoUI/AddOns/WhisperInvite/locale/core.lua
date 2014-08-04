--[[
    Author: Areko @Alleria-EU
]]



local _, L = ...;

local function defaultFunc(L, key)
    return key;
end


setmetatable(L, {
    __index=defaultFunc, 
    __newindex = function(self, key, value)
		rawset(L, key, value == true and key or value) 
    end
} );
