-- Author: Yottabyte
-- Create Date : 10/19/2010 2:13:18 PM
--Slash Command--
SLASH_GUILDRECRUITER1, SLASH_GUILDRECRUITER2, SLASH_GUILDRECRUITER3 = '/gr', '/grecruiter', '/guildrecruiter';
function SlashCmdList.GUILDRECRUITER(msg, editbox)
 GRAttunement();
end

--Load Functions--
function GRLoader()
 GRInvite:SetScript("OnEscapePressed", function(self) GRMain:Hide() GRDNI:Hide() end)
 GRInvite:SetScript("OnTabPressed", function(self) GRlvlrange:SetFocus() end)
 GRInvite:SetScript("OnEnterPressed", function(self) GRSearch() end)
 GRlvlrange:SetScript("OnEscapePressed", function(self) GRMain:Hide() GRDNI:Hide() end)
 GRlvlrange:SetScript("OnTabPressed", function(self) GRInvite:SetFocus() end)
 GRlvlrange:SetScript("OnEnterPressed", function(self) GRSearch() end)
 GRAddNameEditBox:SetScript("OnEscapePressed", function(self) GRDNI:Hide() end)
 GRAddNameEditBox:SetScript("OnTabPressed", function(self) GRRemoveNameEditBox:SetFocus() end)
 GRAddNameEditBox:SetScript("OnEnterPressed", function(self) DNIAddNamefunc() end)
 GRRemoveNameEditBox:SetScript("OnEscapePressed", function(self) GRDNI:Hide() end)
 GRRemoveNameEditBox:SetScript("OnTabPressed", function(self) GRAddNameEditBox:SetFocus() end)
 GRRemoveNameEditBox:SetScript("OnEnterPressed", function(self) DNIRemoveNamefunc() end)
print('Guild Recruiter 3.0 is loaded and fully operational! Use "/gr" "/grecruiter" or "/guildrecruiter" to access the menu. A button is also available on the Who Frame.')
end

--Show Functions--
function GRAttunement()
if IsInGuild()==1 and CanGuildInvite()==1 then
GRMain:Show()
else
print('ERROR! Guild Recruiter was UNLOADED because you are not in a guild, or you do not have Guild Invite permission!')
end
end

--Start Search Function--
function GRSearch()
GRAllRaceControl()
end

--Race Functions--
function GRAllRaceControl()
if GRAllRace:GetChecked()==1 then
grrace = ""
GRAllClassControl()
else
GRDraenei_Check()
end
end

function GRDraenei_Check()
if GRDraenei:GetChecked()==1 then
grrace = 'r-\"Draenei\" '
GRAllClassControl()
else
GRDwarf_Check()
end
end

function GRDwarf_Check()
if GRDwarf:GetChecked()==1 then
grrace = 'r-\"Dwarf\" '
GRAllClassControl()
else
GRGnome_Check()
end
end

function GRGnome_Check()
if GRGnome:GetChecked()==1 then
grrace = 'r-\"Gnome\" '
GRAllClassControl()
else
GRHuman_Check()
end
end

function GRHuman_Check()
if GRHuman:GetChecked()==1 then
grrace = 'r-\"Human\" '
GRAllClassControl()
else
GRNightelf_Check()
end
end

function GRNightelf_Check()
if GRNightelf:GetChecked()==1 then
grrace = 'r-\"Night elf\" '
GRAllClassControl()
else
GRWorgen_Check()
end
end

function GRWorgen_Check()
if GRWorgen:GetChecked()==1 then
grrace = 'r-\"Worgen\" '
GRAllClassControl()
else
GRBloodelf_Check()
end
end

function GRBloodelf_Check()
if GRBloodelf:GetChecked()==1 then
grrace = 'r-\"Blood elf\" '
GRAllClassControl()
else
GRGoblin_Check()
end
end

function GRGoblin_Check()
if GRGoblin:GetChecked()==1 then
grrace = 'r-\"Goblin\" '
GRAllClassControl()
else
GROrc_Check()
end
end

function GROrc_Check()
if GROrc:GetChecked()==1 then
grrace = 'r-\"Orc\" '
GRAllClassControl()
else
GRTauren_Check()
end
end

function GRTauren_Check()
if GRTauren:GetChecked()==1 then
grrace = 'r-\"Tauren\" '
GRAllClassControl()
else
GRTroll_Check()
end
end

function GRTroll_Check()
if GRTroll:GetChecked()==1 then
grrace = 'r-\"Troll\" '
GRAllClassControl()
else
GRUndead_Check()
end
end

function GRUndead_Check()
if GRUndead:GetChecked()==1 then
grrace = 'r-\"Undead\" '
GRAllClassControl()
else
print('ERROR! You must select a race!')
end
end

--Class Functions--
function GRAllClassControl()
if GRAllClass:GetChecked()==1 then
grclass = ""
GRLevelControl()
else
GRDeathknight_Check()
end
end

function GRDeathknight_Check()
if GRDeathknight:GetChecked()==1 then
grclass = 'c-\"Death Knight\" '
GRLevelControl()
else
GRDruid_Check()
end
end

function GRDruid_Check()
if GRDruid:GetChecked()==1 then
grclass = 'c-\"Druid\" '
GRLevelControl()
else
GRMage_Check()
end
end

function GRMage_Check()
if GRMage:GetChecked()==1 then
grclass = 'c-\"Mage\" '
GRLevelControl()
else
GRHunter_Check()
end
end

function GRHunter_Check()
if GRHunter:GetChecked()==1 then
grclass = 'c-\"Hunter\" '
GRLevelControl()
else
GRPaladin_Check()
end
end

function GRPaladin_Check()
if GRPaladin:GetChecked()==1 then
grclass = 'c-\"Paladin\" '
GRLevelControl()
else
GRPriest_Check()
end
end

function GRPriest_Check()
if GRPriest:GetChecked()==1 then
grclass = 'c-\"Priest\" '
GRLevelControl()
else
GRRogue_Check()
end
end

function GRRogue_Check()
if GRRogue:GetChecked()==1 then
grclass = 'c-\"Rogue\" '
GRLevelControl()
else
GRShaman_Check()
end
end

function GRShaman_Check()
if GRShaman:GetChecked()==1 then
grclass = 'c-\"Shaman\" '
GRLevelControl()
else
GRWarlock_Check()
end
end

function GRWarlock_Check()
if GRWarlock:GetChecked()==1 then
grclass = 'c-\"Warlock\" '
GRLevelControl()
else
GRWarrior_Check()
end
end

function GRWarrior_Check()
if GRWarrior:GetChecked()==1 then
grclass = 'c-\"Warrior\" '
GRLevelControl()
else
print("ERROR! You must select a class!")
end
end

--Level Functions--
function GRLevelControl()
grrange = GRlvlrange:GetText()
GRSearchControl()
end

--Search Functions--
function GRSearchControl()
SetWhoToUI(1)
SendWho(strjoin(grrace,grclass,grrange))
print('Search Executed! If the results do not match what you searched for, wait a few seconds and try agian.')
end

--Invite Functions--
function GRInviteControl()
if GRDNIBypass:GetChecked()~=1 and GRIG:GetChecked()~=1 then
GRNormalMode()
end
if GRDNIBypass:GetChecked()==1 and GRIG:GetChecked()~=1 then
GRDNIBypassMode()
end
if GRDNIBypass:GetChecked()~=1 and GRIG:GetChecked()==1 then
GRInviteGuildedMode()
end
if GRDNIBypass:GetChecked()==1 and GRIG:GetChecked()==1 then
GRDNIBypassANDInviteGuildedMode()
end
end

function GRNormalMode()
n=GetNumWhoResults();
i=1;
invitees=0
onlist=0
while(i<n+1) do c,g=GetWhoInfo(i);
if tContains(DNIt, c)~=1 then if(g=="") then SendChatMessage(GRInvite:GetText(),"WHISPER",nil,c);
if GRSend:GetChecked()==1 then GuildInvite(c);
end;
tinsert(DNIt, c);
invitees=invitees+1;
end;
else
onlist=onlist+1;
end;
i=i+1;
end;
guilded=GetNumWhoResults()-(invitees+onlist)
print(invitees,'players were invited and added to the Do Not Invite List!')
print(guilded,'players were NOT invited because they are already in a guild!')
print(onlist,'players were NOT invited because they are on the Do Not Invite List!')
end

function GRDNIBypassMode()
n=GetNumWhoResults();
i=1;
invitees=0
guilded=0
onlist=0
while(i<n+1) do c,g=GetWhoInfo(i);
if(g=="") then 
SendChatMessage(GRInvite:GetText(),"WHISPER",nil,c);
if GRSend:GetChecked()==1 then GuildInvite(c);
end;
if tContains(DNIt, c)~=1 then
tinsert(DNIt, c);
invitees=invitees+1;
else
onlist=onlist+1;
end
else
guilded=guilded+1;
end;
i=i+1;
end;
print(invitees,'players were invited and added to the Do Not Invite List!')
print(onlist,'players were invited who ARE on the Do Not Invite List!')
print(guilded,'players were NOT invited because they are already in a guild!')
end

function GRInviteGuildedMode()
n=GetNumWhoResults();
i=1;
invitees=0
onlist=0
while(i<n+1) do c,g=GetWhoInfo(i);
if tContains(DNIt, c)~=1 then SendChatMessage(GRInvite:GetText(),"WHISPER",nil,c);
if GRSend:GetChecked()==1 and (g=="") then GuildInvite(c);
end;
tinsert(DNIt, c);
invitees=invitees+1;
else
onlist=onlist+1;
end;
i=i+1;
end;
print(invitees,'players were invited and added to the Do Not Invite List!')
print(onlist,'players were NOT invited because they are on the Do Not Invite List!')
end

function GRDNIBypassANDInviteGuildedMode()
n=GetNumWhoResults();
i=1;
invitees=0
onlist=0
while(i<n+1) do c,g=GetWhoInfo(i);
SendChatMessage(GRInvite:GetText(),"WHISPER",nil,c);
if GRSend:GetChecked()==1 and (g=="") then GuildInvite(c);
end;
if tContains(DNIt, c)~=1 then
tinsert(DNIt, c);
invitees=invitees+1;
else
onlist=onlist+1;
end
i=i+1;
end;
print(invitees,'players were invited and added to the Do Not Invite List!')
print(onlist,'players were invited who ARE on the Do Not Invite List!')
end

--Checkbox Functions--
function GRAllRaceCheckControl()
if GRAllRace:GetChecked()==1 then
GRDraenei:SetChecked(0)
GRDwarf:SetChecked(0)
GRGnome:SetChecked(0)
GRHuman:SetChecked(0)
GRNightelf:SetChecked(0)
GRWorgen:SetChecked(0)
GRBloodelf:SetChecked(0)
GRGoblin:SetChecked(0)
GROrc:SetChecked(0)
GRTauren:SetChecked(0)
GRTroll:SetChecked(0)
GRUndead:SetChecked(0)
GRDruid:Enable()
GRHunter:Enable()
GRMage:Enable()
GRPaladin:Enable()
GRPriest:Enable()
GRRogue:Enable()
GRShaman:Enable()
GRWarlock:Enable()
end
end

function GRDraeneiCheckControl()
if GRDraenei:GetChecked()==1 then
GRAllRace:SetChecked(0)
GRDwarf:SetChecked(0)
GRGnome:SetChecked(0)
GRHuman:SetChecked(0)
GRNightelf:SetChecked(0)
GRWorgen:SetChecked(0)
GRBloodelf:SetChecked(0)
GRGoblin:SetChecked(0)
GROrc:SetChecked(0)
GRTauren:SetChecked(0)
GRTroll:SetChecked(0)
GRUndead:SetChecked(0)
GRDruid:SetChecked(0)
GRDruid:Disable()
GRHunter:Enable()
GRMage:Enable()
GRPaladin:Enable()
GRPriest:Enable()
GRRogue:SetChecked(0)
GRRogue:Disable()
GRShaman:Enable()
GRWarlock:SetChecked(0)
GRWarlock:Disable()
end
end

function GRDwarfCheckControl()
if GRDwarf:GetChecked()==1 then
GRAllRace:SetChecked(0)
GRDraenei:SetChecked(0)
GRGnome:SetChecked(0)
GRHuman:SetChecked(0)
GRNightelf:SetChecked(0)
GRWorgen:SetChecked(0)
GRBloodelf:SetChecked(0)
GRGoblin:SetChecked(0)
GROrc:SetChecked(0)
GRTauren:SetChecked(0)
GRTroll:SetChecked(0)
GRUndead:SetChecked(0)
GRDruid:SetChecked(0)
GRDruid:Disable()
GRHunter:Enable()
GRMage:Enable()
GRPaladin:Enable()
GRPriest:Enable()
GRRogue:Enable()
GRShaman:Enable()
GRWarlock:Enable()


end
end

function GRGnomeCheckControl()
if GRGnome:GetChecked()==1 then
GRAllRace:SetChecked(0)
GRDraenei:SetChecked(0)
GRDwarf:SetChecked(0)
GRHuman:SetChecked(0)
GRNightelf:SetChecked(0)
GRWorgen:SetChecked(0)
GRBloodelf:SetChecked(0)
GRGoblin:SetChecked(0)
GROrc:SetChecked(0)
GRTauren:SetChecked(0)
GRTroll:SetChecked(0)
GRUndead:SetChecked(0)
GRDruid:SetChecked(0)
GRDruid:Disable()
GRHunter:SetChecked(0)
GRHunter:Disable()
GRMage:Enable()
GRPaladin:SetChecked(0)
GRPaladin:Disable()
GRPriest:Enable()
GRRogue:Enable()
GRShaman:SetChecked(0)
GRShaman:Disable()
GRWarlock:Enable()
end
end

function GRHumanCheckControl()
if GRHuman:GetChecked()==1 then
GRAllRace:SetChecked(0)
GRDraenei:SetChecked(0)
GRDwarf:SetChecked(0)
GRGnome:SetChecked(0)
GRNightelf:SetChecked(0)
GRWorgen:SetChecked(0)
GRBloodelf:SetChecked(0)
GRGoblin:SetChecked(0)
GROrc:SetChecked(0)
GRTauren:SetChecked(0)
GRTroll:SetChecked(0)
GRUndead:SetChecked(0)
GRDruid:SetChecked(0)
GRDruid:Disable()
GRHunter:Enable()
GRMage:Enable()
GRPaladin:Enable()
GRPriest:Enable()
GRRogue:Enable()
GRShaman:SetChecked(0)
GRShaman:Disable()
GRWarlock:Enable()
end
end

function GRNightelfCheckControl()
if GRNightelf:GetChecked()==1 then
GRAllRace:SetChecked(0)
GRDraenei:SetChecked(0)
GRDwarf:SetChecked(0)
GRGnome:SetChecked(0)
GRHuman:SetChecked(0)
GRWorgen:SetChecked(0)
GRBloodelf:SetChecked(0)
GRGoblin:SetChecked(0)
GROrc:SetChecked(0)
GRTauren:SetChecked(0)
GRTroll:SetChecked(0)
GRUndead:SetChecked(0)
GRDruid:Enable()
GRHunter:Enable()
GRMage:Enable()
GRPaladin:SetChecked(0)
GRPaladin:Disable()
GRPriest:Enable()
GRRogue:Enable()
GRShaman:SetChecked(0)
GRShaman:Disable()
GRWarlock:SetChecked(0)
GRWarlock:Disable()
end
end

function GRWorgenCheckControl()
if GRWorgen:GetChecked()==1 then
GRAllRace:SetChecked(0)
GRDraenei:SetChecked(0)
GRDwarf:SetChecked(0)
GRGnome:SetChecked(0)
GRHuman:SetChecked(0)
GRNightelf:SetChecked(0)
GRBloodelf:SetChecked(0)
GRGoblin:SetChecked(0)
GROrc:SetChecked(0)
GRTauren:SetChecked(0)
GRTroll:SetChecked(0)
GRUndead:SetChecked(0)
GRDruid:Enable()
GRHunter:Enable()
GRMage:Enable()
GRPaladin:SetChecked(0)
GRPaladin:Disable()
GRPriest:Enable()
GRRogue:Enable()
GRShaman:SetChecked(0)
GRShaman:Disable()
GRWarlock:Enable()
end
end

function GRBloodelfCheckControl()
if GRBloodelf:GetChecked()==1 then
GRAllRace:SetChecked(0)
GRDraenei:SetChecked(0)
GRDwarf:SetChecked(0)
GRGnome:SetChecked(0)
GRHuman:SetChecked(0)
GRNightelf:SetChecked(0)
GRWorgen:SetChecked(0)
GRGoblin:SetChecked(0)
GROrc:SetChecked(0)
GRTauren:SetChecked(0)
GRTroll:SetChecked(0)
GRUndead:SetChecked(0)
GRDruid:SetChecked(0)
GRDruid:Disable()
GRHunter:Enable()
GRMage:Enable()
GRPaladin:Enable()
GRPriest:Enable()
GRRogue:Enable()
GRShaman:SetChecked(0)
GRShaman:Disable()
GRWarlock:Enable()
end
end

function GRGoblinCheckControl()
if GRGoblin:GetChecked()==1 then
GRAllRace:SetChecked(0)
GRDraenei:SetChecked(0)
GRDwarf:SetChecked(0)
GRGnome:SetChecked(0)
GRHuman:SetChecked(0)
GRNightelf:SetChecked(0)
GRWorgen:SetChecked(0)
GRBloodelf:SetChecked(0)
GROrc:SetChecked(0)
GRTauren:SetChecked(0)
GRTroll:SetChecked(0)
GRUndead:SetChecked(0)
GRDruid:SetChecked(0)
GRDruid:Disable()
GRHunter:Enable()
GRMage:Enable()
GRPaladin:SetChecked(0)
GRPaladin:Disable()
GRPriest:Enable()
GRRogue:Enable()
GRShaman:Enable()
GRWarlock:Enable()
end
end

function GROrcCheckControl()
if GROrc:GetChecked()==1 then
GRAllRace:SetChecked(0)
GRDraenei:SetChecked(0)
GRDwarf:SetChecked(0)
GRGnome:SetChecked(0)
GRHuman:SetChecked(0)
GRNightelf:SetChecked(0)
GRWorgen:SetChecked(0)
GRBloodelf:SetChecked(0)
GRGoblin:SetChecked(0)
GRTauren:SetChecked(0)
GRTroll:SetChecked(0)
GRUndead:SetChecked(0)
GRDruid:SetChecked(0)
GRDruid:Disable()
GRHunter:Enable()
GRMage:Enable()
GRPaladin:SetChecked(0)
GRPaladin:Disable()
GRPriest:SetChecked(0)
GRPriest:Disable()
GRRogue:Enable()
GRShaman:Enable()
GRWarlock:Enable()
end
end

function GRTaurenCheckControl()
if GRTauren:GetChecked()==1 then
GRAllRace:SetChecked(0)
GRDraenei:SetChecked(0)
GRDwarf:SetChecked(0)
GRGnome:SetChecked(0)
GRHuman:SetChecked(0)
GRNightelf:SetChecked(0)
GRWorgen:SetChecked(0)
GRBloodelf:SetChecked(0)
GRGoblin:SetChecked(0)
GROrc:SetChecked(0)
GRTroll:SetChecked(0)
GRUndead:SetChecked(0)
GRDruid:Enable()
GRHunter:Enable()
GRMage:SetChecked(0)
GRMage:Disable()
GRPaladin:Enable()
GRPriest:Enable()
GRRogue:SetChecked(0)
GRRogue:Disable()
GRShaman:Enable()
GRWarlock:SetChecked(0)
GRWarlock:Disable()
end
end

function GRTrollCheckControl()
if GRTroll:GetChecked()==1 then
GRAllRace:SetChecked(0)
GRDraenei:SetChecked(0)
GRDwarf:SetChecked(0)
GRGnome:SetChecked(0)
GRHuman:SetChecked(0)
GRNightelf:SetChecked(0)
GRWorgen:SetChecked(0)
GRBloodelf:SetChecked(0)
GRGoblin:SetChecked(0)
GROrc:SetChecked(0)
GRTauren:SetChecked(0)
GRUndead:SetChecked(0)
GRDruid:Enable()
GRHunter:Enable()
GRMage:Enable()
GRPaladin:SetChecked(0)
GRPaladin:Disable()
GRPriest:Enable()
GRRogue:Enable()
GRShaman:Enable()
GRWarlock:Enable()
end
end

function GRUndeadCheckControl()
if GRUndead:GetChecked()==1 then
GRAllRace:SetChecked(0)
GRDraenei:SetChecked(0)
GRDwarf:SetChecked(0)
GRGnome:SetChecked(0)
GRHuman:SetChecked(0)
GRNightelf:SetChecked(0)
GRWorgen:SetChecked(0)
GRBloodelf:SetChecked(0)
GRGoblin:SetChecked(0)
GROrc:SetChecked(0)
GRTauren:SetChecked(0)
GRTroll:SetChecked(0)
GRDruid:SetChecked(0)
GRDruid:Disable()
GRHunter:Enable()
GRMage:Enable()
GRPaladin:SetChecked(0)
GRPaladin:Disable()
GRPriest:Enable()
GRRogue:Enable()
GRShaman:SetChecked(0)
GRShaman:Disable()
GRWarlock:Enable()
end
end

function GRAllClassCheckControl()
if GRAllClass:GetChecked()==1 then
GRDeathknight:SetChecked(0)
GRDruid:SetChecked(0)
GRHunter:SetChecked(0)
GRMage:SetChecked(0)
GRPaladin:SetChecked(0)
GRPriest:SetChecked(0)
GRRogue:SetChecked(0)
GRShaman:SetChecked(0)
GRWarlock:SetChecked(0)
GRWarrior:SetChecked(0)
end
end

function GRDeathknightCheckControl()
if GRDeathknight:GetChecked()==1 then
GRAllClass:SetChecked(0)
GRDruid:SetChecked(0)
GRHunter:SetChecked(0)
GRMage:SetChecked(0)
GRPaladin:SetChecked(0)
GRPriest:SetChecked(0)
GRRogue:SetChecked(0)
GRShaman:SetChecked(0)
GRWarlock:SetChecked(0)
GRWarrior:SetChecked(0)
end
end

function GRDruidCheckControl()
if GRDruid:GetChecked()==1 then
GRAllClass:SetChecked(0)
GRDeathknight:SetChecked(0)
GRHunter:SetChecked(0)
GRMage:SetChecked(0)
GRPaladin:SetChecked(0)
GRPriest:SetChecked(0)
GRRogue:SetChecked(0)
GRShaman:SetChecked(0)
GRWarlock:SetChecked(0)
GRWarrior:SetChecked(0)
end
end

function GRHunterCheckControl()
if GRHunter:GetChecked()==1 then
GRAllClass:SetChecked(0)
GRDeathknight:SetChecked(0)
GRDruid:SetChecked(0)
GRMage:SetChecked(0)
GRPaladin:SetChecked(0)
GRPriest:SetChecked(0)
GRRogue:SetChecked(0)
GRShaman:SetChecked(0)
GRWarlock:SetChecked(0)
GRWarrior:SetChecked(0)
end
end

function GRMageCheckControl()
if GRMage:GetChecked()==1 then
GRAllClass:SetChecked(0)
GRDeathknight:SetChecked(0)
GRDruid:SetChecked(0)
GRHunter:SetChecked(0)
GRPaladin:SetChecked(0)
GRPriest:SetChecked(0)
GRRogue:SetChecked(0)
GRShaman:SetChecked(0)
GRWarlock:SetChecked(0)
GRWarrior:SetChecked(0)
end
end

function GRPaladinCheckControl()
if GRPaladin:GetChecked()==1 then
GRAllClass:SetChecked(0)
GRDeathknight:SetChecked(0)
GRDruid:SetChecked(0)
GRHunter:SetChecked(0)
GRMage:SetChecked(0)
GRPriest:SetChecked(0)
GRRogue:SetChecked(0)
GRShaman:SetChecked(0)
GRWarlock:SetChecked(0)
GRWarrior:SetChecked(0)
end
end

function GRPriestCheckControl()
if GRPriest:GetChecked()==1 then
GRAllClass:SetChecked(0)
GRDeathknight:SetChecked(0)
GRDruid:SetChecked(0)
GRHunter:SetChecked(0)
GRMage:SetChecked(0)
GRPaladin:SetChecked(0)
GRRogue:SetChecked(0)
GRShaman:SetChecked(0)
GRWarlock:SetChecked(0)
GRWarrior:SetChecked(0)
end
end

function GRRogueCheckControl()
if GRRogue:GetChecked()==1 then
GRAllClass:SetChecked(0)
GRDeathknight:SetChecked(0)
GRDruid:SetChecked(0)
GRHunter:SetChecked(0)
GRMage:SetChecked(0)
GRPaladin:SetChecked(0)
GRPriest:SetChecked(0)
GRShaman:SetChecked(0)
GRWarlock:SetChecked(0)
GRWarrior:SetChecked(0)
end
end

function GRShamanCheckControl()
if GRShaman:GetChecked()==1 then
GRAllClass:SetChecked(0)
GRDeathknight:SetChecked(0)
GRDruid:SetChecked(0)
GRHunter:SetChecked(0)
GRMage:SetChecked(0)
GRPaladin:SetChecked(0)
GRPriest:SetChecked(0)
GRRogue:SetChecked(0)
GRWarlock:SetChecked(0)
GRWarrior:SetChecked(0)
end
end

function GRWarlockCheckControl()
if GRWarlock:GetChecked()==1 then
GRAllClass:SetChecked(0)
GRDeathknight:SetChecked(0)
GRDruid:SetChecked(0)
GRHunter:SetChecked(0)
GRMage:SetChecked(0)
GRPaladin:SetChecked(0)
GRPriest:SetChecked(0)
GRRogue:SetChecked(0)
GRShaman:SetChecked(0)
GRWarrior:SetChecked(0)
end
end

function GRWarriorCheckControl()
if GRWarrior:GetChecked()==1 then
GRAllClass:SetChecked(0)
GRDeathknight:SetChecked(0)
GRDruid:SetChecked(0)
GRHunter:SetChecked(0)
GRMage:SetChecked(0)
GRPaladin:SetChecked(0)
GRPriest:SetChecked(0)
GRRogue:SetChecked(0)
GRShaman:SetChecked(0)
GRWarlock:SetChecked(0)
end
end

--Saved Variable Functions--
function GRSaveSettings()
if GRInvite:GetText()~=nil then
GRInviteSave = GRInvite:GetText()
else
GRInviteSave = 0
end
if GRSend:GetChecked()==1 then
GRSendSave = 1
else
GRSendSave = 0
end
if GRlvlrange:GetText()~=nil then
GRlvlrangeSave = GRlvlrange:GetText()
else
GRlvlrangeSave = 0
end
if GRAllRace:GetChecked()==1 then
GRAllRaceSave = 1
else
GRAllRaceSave = 0
end
if GRDraenei:GetChecked()==1 then
GRDraeneiSave = 1
else
GRDraeneiSave = 0
end
if GRDwarf:GetChecked()==1 then
GRDwarfSave = 1
else
GRDwarfSave = 0
end
if GRGnome:GetChecked()==1 then
GRGnomeSave = 1
else
GRGnomeSave = 0
end
if GRHuman:GetChecked()==1 then
GRHumanSave = 1
else
GRHumanSave = 0
end
if GRNightelf:GetChecked()==1 then
GRNightelfSave = 1
else
GRNightelfSave = 0
end
if GRWorgen:GetChecked()==1 then
GRWorgenSave = 1
else
GRWorgenSave = 0
end
if GRBloodelf:GetChecked()==1 then
GRBloodelfSave = 1
else
GRBloodelfSave = 0
end
if GRGoblin:GetChecked()==1 then
GRGoblinSave = 1
else
GRGoblinSave = 0
end
if GROrc:GetChecked()==1 then
GROrcSave = 1
else
GROrcSave = 0
end
if GRTauren:GetChecked()==1 then
GRTaurenSave = 1
else
GRTaurenSave = 0
end
if GRTroll:GetChecked()==1 then
GRTrollSave = 1
else
GRTrollSave = 0
end
if GRUndead:GetChecked()==1 then
GRUndeadSave = 1
else
GRUndeadSave = 0
end
if GRAllClass:GetChecked()==1 then
GRAllClassSave = 1
else
GRAllClassSave = 0
end
if GRDeathknight:GetChecked()==1 then
GRDeathknightSave = 1
else
GRDeathknightSave = 0
end
if GRDruid:GetChecked()==1 then
GRDruidSave = 1
else
GRDruidSave = 0
end
if GRHunter:GetChecked()==1 then
GRHunterSave = 1
else
GRHunterSave = 0
end
if GRMage:GetChecked()==1 then
GRMageSave = 1
else
GRMageSave = 0
end
if GRPaladin:GetChecked()==1 then
GRPaladinSave = 1
else
GRPaladinSave = 0
end
if GRPriest:GetChecked()==1 then
GRPriestSave = 1
else
GRPriestSave = 0
end
if GRRogue:GetChecked()==1 then
GRRogueSave = 1
else
GRRogueSave = 0
end
if GRShaman:GetChecked()==1 then
GRShamanSave = 1
else
GRShamanSave = 0
end
if GRWarlock:GetChecked()==1 then
GRWarlockSave = 1
else
GRWarlockSave = 0
end
if GRWarrior:GetChecked()==1 then
GRWarriorSave = 1
else
GRWarriorSave = 0
end
if DNIt~=nil then
DNItSave = DNIt 
else
DNItSave = {} --Default Table--
end
end

function GRLoadSettings()
if GRInviteSave~=nil then
GRInvite:SetText(GRInviteSave)
end
if GRSendSave==1 then
GRSend:SetChecked(1)
end
if GRlvlrangeSave~=nil then
GRlvlrange:SetText(GRlvlrangeSave)
end
if GRAllRaceSave==1 then
GRAllRace:SetChecked(1)
end
if GRDraeneiSave==1 then
GRDraenei:SetChecked(1)
end
if GRDwarfSave==1 then
GRDwarf:SetChecked(1)
end
if GRGnomeSave==1 then
GRGnome:SetChecked(1)
end
if GRHumanSave==1 then
GRHuman:SetChecked(1)
end
if GRNightelfSave==1 then
GRNightelf:SetChecked(1)
end
if GRWorgenSave==1 then
GRWorgen:SetChecked(1)
end
if GRBloodelfSave==1 then
GRBloodelf:SetChecked(1)
end
if GRGoblinSave==1 then
GRGoblin:SetChecked(1)
end
if GROrcSave==1 then
GROrc:SetChecked(1)
end
if GRTaurenSave==1 then
GRTauren:SetChecked(1)
end
if GRTrollSave==1 then
GRTroll:SetChecked(1)
end
if GRUndeadSave==1 then
GRUndead:SetChecked(1)
end
if GRAllClassSave==1 then
GRAllClass:SetChecked(1)
end
if GRDeathknightSave==1 then
GRDeathknight:SetChecked(1)
end
if GRDruidSave==1 then
GRDruid:SetChecked(1)
end
if GRHunterSave==1 then
GRHunter:SetChecked(1)
end
if GRMageSave==1 then
GRMage:SetChecked(1)
end
if GRPaladinSave==1 then
GRPaladin:SetChecked(1)
end
if GRPriestSave==1 then
GRPriest:SetChecked(1)
end
if GRRogueSave==1 then
GRRogue:SetChecked(1)
end
if GRShamanSave==1 then
GRShaman:SetChecked(1)
end
if GRWarlockSave==1 then
GRWarlock:SetChecked(1)
end
if GRWarriorSave==1 then
GRWarrior:SetChecked(1)
end
if DNItSave~=nil then
DNIt = DNItSave
else
DNIt = {} --Default Table--
end
end

--DNIL Functions--
function DNIAddNamefunc()
if tContains(DNIt, GRAddNameEditBox:GetText())~=1 and GRAddNameEditBox:GetText()~="" then
tinsert(DNIt, GRAddNameEditBox:GetText())
print(GRAddNameEditBox:GetText(),'was added to the Do Not Invite List!')
else
if GRAddNameEditBox:GetText()~="" then
print('ERROR!',GRAddNameEditBox:GetText(),'was not added to the Do Not Invite List because they are already on it!')
else
print('ERROR! You need to specify a name in order to add it to the Do Not Invite List!')
end
end
end

function DNIRemoveNamefunc()
if GRRemoveNameEditBox:GetNumber()~=0 then
BeforeSize = table.getn(DNIt)
table.remove(DNIt,GRRemoveNameEditBox:GetNumber())
AfterSize = table.getn(DNIt)
if BeforeSize==AfterSize then
print('ERROR! Invalid number! Nobody has been removed! Check the name and try agian!')
else
print('Name successfully removed from list!')
end
else
print('ERROR! You must specify an index number in order to remove a name from the list!')
end
end

function DNIShow()
if table.getn(DNIt)==0 then
print('The Do Not Invite List is empty!')
else
print('# Name')
table.foreach(DNIt, print)
end
end

function DNIPurge()
if GRAddNameEditBox:GetText()=="Delete" and GRRemoveNameEditBox:GetNumber()==666 then
wipe(DNIt)
print('The Do Not Invite List had been purged!')
else
print('ERROR! Do Not Invite List was not purged because you did not type in the confirmation code. See the documentation for the code and how to use it!')
end
end

function DNIFrameShow()
if GRDNI:IsVisible()~=1 then
print('WARNING! Modifying the Do Not Invite List is something that should be done ONLY by people that have read the documentation! Please read the documentation before using these controls!')
GRDNI:Show()
else
GRDNI:Hide()
end
end


--Bypass Warning Functions--
function DNIBypassWarning()
if GRDNIBypass:GetChecked()==1 then
print('WARNING! The Anti-Spam Engine has been deactivated! Invites may go out to players who are on the Do Not Invite List! This may cause players to become angry toward you and/or report you for spamming! Players will still be added to the list if they are not on it! Operating in this mode is NOT recommended!')
else
print('The Anti-Spam Engine has been enabled!')
end
end

function GRIGWarning()
if GRIG:GetChecked()==1 then
print('WARNING! Invites may go out to players who are in a guild! This may cause players to become angry toward you! Operating in this mode is NOT recommended!')
else
print('Players who are in a guild will not be invited!')
end
end