local frame = CreateFrame("FRAME", "BGAutoRelease");
frame:RegisterEvent("PLAYER_DEAD");

local function eventHandler(self, event, ...)
    local inInstance, instanceType = IsInInstance()
    if inInstance and (instanceType == "pvp") then
        RepopMe();
    end
end

frame:SetScript("OnEvent", eventHandler);
