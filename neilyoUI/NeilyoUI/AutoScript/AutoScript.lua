local trinkets = {}
local events = CreateFrame("Frame")

function events:ADDON_LOADED(addonName)
    if addonName ~= "Blizzard_ArenaUI" then
        return
    end
     --ArenaEnemyFrame1:ClearAllPoints()
     --ArenaEnemyFrame1:SetPoint("TOPRIGHT", UIParent, -571, -37)
     --ArenaEnemyFrames:SetScale(1.1)
    local arenaFrame, trinket
    for i = 1, MAX_ARENA_ENEMIES do
        arenaFrame = "ArenaEnemyFrame"..i
        trinket = CreateFrame("Cooldown", arenaFrame.."Trinket", ArenaEnemyFrames)
        trinket:SetPoint("TOPRIGHT", arenaFrame, 32, -6)
        trinket:SetSize(24, 24)
        trinket.icon = trinket:CreateTexture(nil, "BACKGROUND")
        trinket.icon:SetAllPoints()
        trinket.icon:SetTexture("Interface\\Icons\\inv_jewelry_trinketpvp_01")
        trinket:Hide()
        trinkets["arena"..i] = trinket
    end
    self:UnregisterEvent("ADDON_LOADED")
end

function events:UNIT_SPELLCAST_SUCCEEDED(unitID, spell, rank, lineID, spellID)
    if not trinkets[unitID] then
        return
    end
    if spellID == 59752 or spellID == 42292 then
        CooldownFrame_SetTimer(trinkets[unitID], GetTime(), 120, 1)
    elseif spellID == 7744 then
        CooldownFrame_SetTimer(trinkets[unitID], GetTime(), 45, 1)
    end
end

function events:PLAYER_ENTERING_WORLD()
    local _, instanceType = IsInInstance()
    if instanceType == "arena" then
        self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    elseif self:IsEventRegistered("UNIT_SPELLCAST_SUCCEEDED") then
        self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
        for _, trinket in pairs(trinkets) do
            trinket:SetCooldown(0, 0)
            trinket:Hide()
        end
    end
end

SLASH_TESTAEF1 = "/testaef"
SlashCmdList["TESTAEF"] = function(msg, editBox)
    if not IsAddOnLoaded("Blizzard_ArenaUI") then
        LoadAddOn("Blizzard_ArenaUI")
    end
    ArenaEnemyFrames:Show()
    local arenaFrame
    for i = 1, MAX_ARENA_ENEMIES do
        arenaFrame = _G["ArenaEnemyFrame"..i]
        arenaFrame.classPortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
        arenaFrame.classPortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS["WARRIOR"]))
        arenaFrame.name:SetText("Dispelme")
        arenaFrame:Show()
        CooldownFrame_SetTimer(trinkets["arena"..i], GetTime(), 120, 1)
    end
end

events:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")

USS="UNIT_SPELLCAST_SUCCEEDED";OE="OnEvent";PvP="Interface\\Icons\\inv_jewelry_trinketpvp_01";F="Frame";CF=CreateFrame;BO="Border";PvPT="PvP Trinket";EMFH="Every Man For Himself";UC=UnitClass;SCM=SendChatMessage;RW="RAID_WARNING"
function TrS(f,x,y,cd,T,s,h) f:SetPoint("BOTTOMLEFT",x,y)f:SetSize(s,s)f.c=CF("Cooldown",cd)f.c:SetAllPoints(f)f.t=f:CreateTexture(nil,BO)f.t:SetAllPoints()f.t:SetTexture(T);if not h then f:Hide(); end f:RegisterEvent(USS) end
function Ts(f,cd,U,N,S,TI)if CPz(N,S,U) then f:Show();CooldownFrame_SetTimer(cd,GetTime(),TI,1) end end
function CPz(N,S,U) if(N==S and (U=="arena1" or U=="arena2" or U=="arena3" or U=="arenapet1" or U=="arenapet2" or U=="arenapet3"))then return true else return false end end

CTT=CreateFrame("Frame")CTT:SetParent(TargetFrame)CTT:SetPoint("Right",TargetFrame,-3,7)CTT:SetSize(25,25)CTT.t=CTT:CreateTexture(nil,BORDER)CTT.t:SetAllPoints()CTT.t:SetTexture("Interface\\Icons\\ABILITY_DUALWIELD")CTT:Hide()
		local function FrameOnUpdate(self) if UnitAffectingCombat("target") then self:Show() else self:Hide() end end local g = CreateFrame("Frame") g:SetScript("OnUpdate", function(self) FrameOnUpdate(CTT) end)
		CFT=CreateFrame("Frame")CFT:SetParent(FocusFrame)CFT:SetPoint("Left",FocusFrame,-22,7)CFT:SetSize(25,25)CFT.t=CFT:CreateTexture(nil,BORDER)CFT.t:SetAllPoints()CFT.t:SetTexture("Interface\\Icons\\ABILITY_DUALWIELD")CFT:Hide()
		local function FrameOnUpdate(self) if UnitAffectingCombat("focus") then self:Show() else self:Hide() end end local g = CreateFrame("Frame") g:SetScript("OnUpdate", function(self) FrameOnUpdate(CFT) end)
		
ShapeshiftBarFrame:ClearAllPoints()
ShapeshiftBarFrame:SetPoint ("CENTER", -29.5, 64.5)
ShapeshiftBarFrame:SetScale (1.254)
ShapeshiftBarFrame.SetPoint = function() end

USD="UNIT_SPELLCAST_SUCCEEDED";OT="OnEvent";FR="Frame";RF=CreateFrame;RD="Border";UE=UnitName
CS=RF(FR) CS.c=RF("Cooldown","CST",CS.t) CS:RegisterEvent(USD) 
CS.c:SetAllPoints(CS) CS:SetPoint("TOPRIGHT",PlayerFrame,-3,5)CS:SetSize(22,22)CS.t=CS:CreateTexture(nil,RD)CS.t:SetAllPoints()CS.t:SetTexture("Interface\\Icons\\ability_cheapshot")
CS:SetScript(OT,function(self,event,...) if UE(select(1,...))==UE("player") and select(5,...)==1833 then CST:SetCooldown(GetTime(), 23)end if UE(select(1,...))==UE("player") and select(5,...)==408 then CST:SetCooldown(GetTime(), 25) end end)
SP=RF(FR) SP.c=RF("Cooldown","SAP",SP.t) SP:RegisterEvent(USD) 
SP.c:SetAllPoints(SP) SP:SetPoint("TOPRIGHT",PlayerFrame,-25,5)SP:SetSize(22,22)SP.t=SP:CreateTexture(nil,RD)SP.t:SetAllPoints()SP.t:SetTexture("Interface\\Icons\\ability_gouge")
SP:SetScript(OT,function(self,event,...) if UE(select(1,...))==UE("player") and select(5,...)==6770 then SAP:SetCooldown(GetTime(), 25)end if UE(select(1,...))==UE("player") and select(5,...)==1776 then SAP:SetCooldown(GetTime(), 23) end end)
SL=RF(FR) SL.c=RF("Cooldown","SILENCE",SL.t) SL:RegisterEvent(USD) 
SL.c:SetAllPoints(SL) SL:SetPoint("TOPRIGHT",PlayerFrame,-47,5)SL:SetSize(22,22)SL.t=SL:CreateTexture(nil,RD)SL.t:SetAllPoints()SL.t:SetTexture("Interface\\Icons\\ability_priest_silence")
SL:SetScript(OT,function(self,event,...) if UE(select(1,...))==UE("player") and select(5,...)==703 then SILENCE:SetCooldown(GetTime(), 23) end end)

UFP = "UnitFramePortrait_Update"
UICC = "Interface\\TargetingFrame\\UI-Classes-Circles"
CIT = CLASS_ICON_TCOORDS
hooksecurefunc(UFP,function(self) if self.portrait then if UnitIsPlayer(self.unit) and UnitIsVisible(self.unit) then self.portrait:SetTexture(UICC) self.portrait:SetTexCoord(unpack(CIT[select(2,UnitClass(self.unit))])) else self.portrait:SetTexCoord(0,1,0,1) end end end)


		
t1p="Interface\\Icons\\ability_rogue_shadowdance";t1=CF(F);TrS(t1,1060,500,"cd1",t1p,22,false);t1:SetScript(OE,function(_,_,U,N)Ts(t1,cd1,U,N,"Shadow Dance",60)end);
t2p="Interface\\Icons\\ability_rogue_kidneyshot";t2=CF(F);TrS(t2,1082,500,"cd2",t2p,22,false);t2:SetScript(OE,function(_,_,U,N)Ts(t2,cd2,U,N,"Kidney Shot",20)end);
t3p="Interface\\Icons\\spell_shadow_nethercloak";t3=CF(F);TrS(t3,1104,500,"cd3",t3p,22,false);t3:SetScript(OE,function(_,_,U,N)Ts(t3,cd3,U,N,"Cloak of Shadows",90)end);
t4p="Interface\\Icons\\ability_rogue_combatreadiness";t4=CF(F);TrS(t4,1104,500,"cd4",t4p,22,false);t4:SetScript(OE,function(_,_,U,N)Ts(t4,cd4,U,N,"Combat Readiness",90)end);
t5p="Interface\\Icons\\ability_vanish";t5=CF(F);TrS(t5,1126,500,"cd5",t5p,22,false);t5:SetScript(OE,function(_,_,U,N)Ts(t5,cd5,U,N,"Vanish",120)end);
t6p="Interface\\Icons\\ability_rogue_dismantle";t6=CF(F);TrS(t6,1148,500,"cd6",t6p,22,false);t6:SetScript(OE,function(_,_,U,N)Ts(t6,cd6,U,N,"Dismantle",60)end);
t7p="Interface\\Icons\\ability_rogue_shadowstep";t7=CF(F);TrS(t7,1170,500,"cd7",t7p,22,false);t7:SetScript(OE,function(_,_,U,N)Ts(t7,cd7,U,N,"Shadowstep",24)end);
t8p="Interface\\Icons\\spell_shadow_mindsteal";t8=CF(F);TrS(t8,1192,500,"cd8",t8p,22,false);t8:SetScript(OE,function(_,_,U,N)Ts(t8,cd8,U,N,"Blind",120)end);
t9p="Interface\\Icons\\ability_rogue_smoke";t9=CF(F);TrS(t9,1214,500,"cd9",t9p,22,false);t9:SetScript(OE,function(_,_,U,N)Ts(t9,cd9,U,N,"Smoke Bomb",180)end);
t10p="Interface\\Icons\\ability_rogue_preparation";t10=CF(F);TrS(t10,1236,500,"cd10",t10p,22,false);t10:SetScript(OE,function(_,_,U,N)Ts(t10,cd10,U,N,"Preparation",300)end);

t11p="Interface\\Icons\\spell_shadow_deathscream";t11=CF(F);TrS(t11,1060,470,"cd11",t11p,22,false);t11:SetScript(OE,function(_,_,U,N)Ts(t11,cd11,U,N,"Howl of Terror",32)end);
t12p="Interface\\Icons\\spell_shadow_deathcoil";t12=CF(F);TrS(t12,1104,470,"cd12",t12p,22,false);t12:SetScript(OE,function(_,_,U,N)Ts(t12,cd12,U,N,"Death Coil",90)end);
t13p="Interface\\Icons\\spell_shadow_demoniccircleteleport";t13=CF(F);TrS(t13,1082,470,"cd13",t13p,22,false);t13:SetScript(OE,function(_,_,U,N)Ts(t13,cd13,U,N,"Demonic Portal: Teleport",25)end);
t14p="Interface\\Icons\\spell_shadow_mindrot";t14=CF(F);TrS(t14,1126,470,"cd14",t14p,22,false);t14:SetScript(OE,function(_,_,U,N)Ts(t14,cd14,U,N,"Spell Lock",24)end);

t15p="Interface\\Icons\\ability_mage_deepfreeze";t15=CF(F);TrS(t15,1060,440,"cd15",t15p,22,false);t15:SetScript(OE,function(_,_,U,N)Ts(t15,cd15,U,N,"Deep Freeze",30)end);
t16p="Interface\\Icons\\spell_frost_wizardmark";t16=CF(F);TrS(t16,1082,440,"cd16",t16p,22,false);t16:SetScript(OE,function(_,_,U,N)Ts(t16,cd16,U,N,"Cold Snap",480)end);
t17p="Interface\\Icons\\spell_arcane_blink";t17=CF(F);TrS(t17,1104,440,"cd17",t17p,22,false);t17:SetScript(OE,function(_,_,U,N)Ts(t17,cd17,U,N,"Blink",15)end);


t18p="Interface\\Icons\\spell_shadow_soulleech_3";t18=CF(F);TrS(t18,1148,410,"cd18",t18p,22,false);t18:SetScript(OE,function(_,_,U,N)Ts(t18,cd18,U,N,"Strangulate",120)end);
t19p="Interface\\Icons\\spell_shadow_antimagicshell";t19=CF(F);TrS(t19,1082,410,"cd19",t19p,22,false);t19:SetScript(OE,function(_,_,U,N)Ts(t19,cd19,U,N,"Anti-Magic Shell",45)end);
t20p="Interface\\Icons\\spell_deathknight_iceboundfortitude";t20=CF(F);TrS(t20,1104,410,"cd20",t20p,22,false);t20:SetScript(OE,function(_,_,U,N)Ts(t20,cd20,U,N,"Icebound Fortitude",180)end);
t21p="Interface\\Icons\\inv_sword_62";t21=CF(F);TrS(t21,1192,410,"cd21",t21p,22,false);t21:SetScript(OE,function(_,_,U,N)Ts(t21,cd21,U,N,"Empowered Rune Weapon",300)end);
t22p="Interface\\Icons\\spell_shadow_raisedead";t22=CF(F);TrS(t22,1126,410,"cd22",t22p,22,false);t22:SetScript(OE,function(_,_,U,N)Ts(t22,cd22,U,N,"Lichborne",120)end);
t23p="Interface\\Icons\\spell_deathknight_strangulate";t23=CF(F);TrS(t23,1060,410,"cd23",t23p,22,false);t23:SetScript(OE,function(_,_,U,N)Ts(t23,cd23,U,N,"Death Grip",25)end);
t24p="Interface\\Icons\\spell_deathknight_antimagiczone";t24=CF(F);TrS(t24,1148,410,"cd24",t24p,22,false);t24:SetScript(OE,function(_,_,U,N)Ts(t24,cd24,U,N,"Anti-Magic Zone",120)end);
t25p="Interface\\Icons\\ability_deathknight_summongargoyle";t25=CF(F);TrS(t25,1170,410,"cd25",t25p,22,false);t25:SetScript(OE,function(_,_,U,N)Ts(t25,cd25,U,N,"Summon Gargoyle",180)end);

t26p="Interface\\Icons\\spell_shadow_psychicscream";t26=CF(F);TrS(t26,1060,385,"cd26",t26p,22,false);t26:SetScript(OE,function(_,_,U,N)Ts(t26,cd26,U,N,"Psychic Scream",26)end);
t27p="Interface\\Icons\\spell_shadow_psychicscream";t27=CF(F);TrS(t27,1082,385,"cd27",t27p,22,false);t27:SetScript(OE,function(_,_,U,N)Ts(t27,cd27,U,N,"Psychic Scream",30)end);
t28p="Interface\\Icons\\spell_frost_windwalkon";t28=CF(F);TrS(t28,1104,385,"cd28",t28p,22,false);t28:SetScript(OE,function(_,_,U,N)Ts(t28,cd28,U,N,"Inner Focus",45)end);
t29p="Interface\\Icons\\spell_holy_painsupression";t29=CF(F);TrS(t29,1126,385,"cd29",t29p,22,false);t29:SetScript(OE,function(_,_,U,N)Ts(t29,cd29,U,N,"Pain Suppression",45)end);
t30p="Interface\\Icons\\spell_shadow_dispersion";t30=CF(F);TrS(t30,1148,385,"cd30",t30p,22,false);t30:SetScript(OE,function(_,_,U,N)Ts(t30,cd30,U,N,"Dispersion",115)end);
t31p="Interface\\Icons\\spell_shadow_psychichorrors";t31=CF(F);TrS(t31,1170,385,"cd31",t31p,22,false);t31:SetScript(OE,function(_,_,U,N)Ts(t31,cd31,U,N,"Psychic Horror",90)end);
t32p="Interface\\Icons\\ability_priest_silence";t32=CF(F);TrS(t32,1192,385,"cd32",t32p,22,false);t32:SetScript(OE,function(_,_,U,N)Ts(t32,cd32,U,N,"Silence",45)end);

t33p="Interface\\Icons\\spell_holy_sealofvalor";t33=CF(F);TrS(t33,1060,350,"cd33",t33p,22,false);t33:SetScript(OE,function(_,_,U,N)Ts(t33,cd33,U,N,"Hand of Freedom",25)end);
t34p="Interface\\Icons\\spell_holy_sealofmight";t34=CF(F);TrS(t34,1082,350,"cd34",t34p,22,false);t34:SetScript(OE,function(_,_,U,N)Ts(t34,cd34,U,N,"Hammer of Justice",40)end);
t58p="Interface\\Icons\\spell_holy_sealofmight";t58=CF(F);TrS(t58,1104,350,"cd58",t58p,22,false);t58:SetScript(OE,function(_,_,U,N)Ts(t58,cd58,U,N,"Hammer of Justice",60)end);
t35p="Interface\\Icons\\spell_holy_sealofsacrifice";t35=CF(F);TrS(t35,1126,350,"cd35",t35p,22,false);t35:SetScript(OE,function(_,_,U,N)Ts(t35,cd35,U,N,"Hand of Sacrifice",90)end);
t36p="Interface\\Icons\\spell_holy_sealofprotection";t36=CF(F);TrS(t36,1148,350,"cd36",t36p,22,false);t36:SetScript(OE,function(_,_,U,N)Ts(t36,cd36,U,N,"Hand of Protection",180)end);
t37p="Interface\\Icons\\spell_holy_divineshield";t37=CF(F);TrS(t37,1170,350,"cd37",t37p,22,false);t37:SetScript(OE,function(_,_,U,N)Ts(t37,cd37,U,N,"Divine Shield",300)end);
t38p="Interface\\Icons\\spell_holy_auramastery";t38=CF(F);TrS(t38,1192,350,"cd38",t38p,22,false);t38:SetScript(OE,function(_,_,U,N)Ts(t38,cd38,U,N,"Aura Mastery",120)end);

t39p="Interface\\Icons\\ability_warrior_charge";t39=CF(F);TrS(t39,1060,320,"cd39",t39p,22,false);t39:SetScript(OE,function(_,_,U,N)Ts(t39,cd39,U,N,"Charge",13)end);
t40p="Interface\\Icons\\inv_mace_62";t40=CF(F);TrS(t40,1082,320,"cd40",t40p,22,false);t40:SetScript(OE,function(_,_,U,N)Ts(t40,cd40,U,N,"Throwdown",45)end);
t41p="Interface\\Icons\\ability_heroicleap";t41=CF(F);TrS(t41,1104,320,"cd41",t41p,22,false);t41:SetScript(OE,function(_,_,U,N)Ts(t41,cd41,U,N,"Heroic Leap",60)end);
t42p="Interface\\Icons\\spell_nature_ancestralguardian";t42=CF(F);TrS(t42,1126,320,"cd42",t42p,22,false);t42:SetScript(OE,function(_,_,U,N)Ts(t42,cd42,U,N,"Berserker Rage",30)end);
t43p="Interface\\Icons\\ability_criticalstrike";t43=CF(F);TrS(t43,1148,320,"cd43",t43p,22,false);t43:SetScript(OE,function(_,_,U,N)Ts(t43,cd43,U,N,"Recklessness",300)end);
t44p="Interface\\Icons\\ability_warrior_shieldwall";t44=CF(F);TrS(t44,1170,320,"cd44",t44p,22,false);t44:SetScript(OE,function(_,_,U,N)Ts(t44,cd44,U,N,"Shield Wall",300)end);

t45p="Interface\\Icons\\ability_hunter_pet_bear";t45=CF(F);TrS(t45,1060,290,"cd45",t45p,22,false);t45:SetScript(OE,function(_,_,U,N)Ts(t54,cd54,U,N,"Feral Charge",14)end);
t46p="Interface\\Icons\\spell_druid_feralchargecat";t46=CF(F);TrS(t46,1082,290,"cd46",t46p,22,false);t46:SetScript(OE,function(_,_,U,N)Ts(t46,cd46,U,N,"Feral Charge",28)end);
t47p="Interface\\Icons\\spell_nature_stoneclawtotem";t47=CF(F);TrS(t47,1104,290,"cd47",t47p,22,false);t47:SetScript(OE,function(_,_,U,N)Ts(t47,cd47,U,N,"Barkskin",60)end);
t48p="Interface\\Icons\\ability_druid_bash";t48=CF(F);TrS(t48,1126,290,"cd48",t48p,22,false);t48:SetScript(OE,function(_,_,U,N)Ts(t48,cd48,U,N,"Bash",60)end);
t49p="Interface\\Icons\\ability_druid_tigersroar";t49=CF(F);TrS(t49,1148,290,"cd49",t49p,22,false);t49:SetScript(OE,function(_,_,U,N)Ts(t49,cd49,U,N,"Survival Instincts",180)end);
t50p="Interface\\Icons\\ability_druid_berserk";t50=CF(F);TrS(t50,1170,290,"cd50",t50p,22,false);t50:SetScript(OE,function(_,_,U,N)Ts(t50,cd50,U,N,"Berserk",180)end);

t51p="Interface\\Icons\\ability_golemstormbolt";t51=CF(F);TrS(t51,1060,260,"cd51",t51p,22,false);t51:SetScript(OE,function(_,_,U,N)Ts(t51,cd51,U,N,"Scatter Shot",30)end);
t52p="Interface\\Icons\\spell_frost_chainsofice";t52=CF(F);TrS(t52,1082,260,"cd52",t52p,22,false);t52:SetScript(OE,function(_,_,U,N)Ts(t52,cd52,U,N,"Freezing Trap",30)end);
t53p="Interface\\Icons\\ability_whirlwind";t53=CF(F);TrS(t53,1104,260,"cd53",t53p,22,false);t53:SetScript(OE,function(_,_,U,N)Ts(t53,cd53,U,N,"Deterrence",120)end);
t54p="Interface\\Icons\\ability_rogue_feint";t54=CF(F);TrS(t54,1126,260,"cd54",t54p,22,false);t54:SetScript(OE,function(_,_,U,N)Ts(t54,cd54,U,N,"Disengage",16)end);

t55p="Interface\\Icons\\spell_shaman_hex";t55=CF(F);TrS(t55,1060,230,"cd55",t55p,22,false);t55:SetScript(OE,function(_,_,U,N)Ts(t55,cd55,U,N,"Hex",35)end);
t56p="Interface\\Icons\\spell_shaman_spiritlink";t56=CF(F);TrS(t56,1082,230,"cd56",t56p,22,false);t56:SetScript(OE,function(_,_,U,N)Ts(t56,cd56,U,N,"Spirit Link Totem",180)end);
t57p="Interface\\Icons\\spell_nature_tremortotem";t57=CF(F);TrS(t57,1104,230,"cd57",t57p,22,false);t57:SetScript(OE,function(_,_,U,N)Ts(t57,cd57,U,N,"Tremor Totem",60)end);









