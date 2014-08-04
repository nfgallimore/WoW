    -- Configuration
    local whispCommand = "inv" -- The whisper command to trigger the invite.
     
    function aTableInvitez0rz(self, event, msg, name, ...)
                    if msg == whispCommand then
                                                    InviteUnit(name)
                    else
                                    return
                    end
    end
     
    local f = CreateFrame("Frame")
    f:RegisterEvent("CHAT_MSG_WHISPER")
    f:SetScript("OnEvent", aTableInvitez0rz)
