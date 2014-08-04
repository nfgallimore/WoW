local MainFrame = CreateFrame("Frame");
MainFrame:RegisterEvent("LOADING_SCREEN_DISABLED");
local L = NameplateCooldownsLocale;

local CDs = {
	[L["MISC"]] = {
		[28730] = 120,				--"Arcane Torrent",
		[50613] = 120,				--"Arcane Torrent",
		[80483] = 120,				--"Arcane Torrent",
		[25046] = 120,				--"Arcane Torrent",
		[69179] = 120,				--"Arcane Torrent",
		[20572] = 120,				--"Blood Fury",
		[33702] = 120,				--"Blood Fury",
		[33697] = 120,				--"Blood Fury",
		[59543] = 180,				--"Gift of the Naaru",
		[69070] = 120,				--"Rocket Jump",
		[26297] = 180,				--"Berserking",
		[20594] = 120,				--"Stoneform",
		[58984] = 120,				--"Shadowmeld",
		[20589] = 90,				--"Escape Artist",
		[59752] = 120,				--"Every Man for Himself",
		[7744] = 120,				--"Will of the Forsaken",
		[68992] = 120,				--"Darkflight",
		[50613] = 120,				--"Arcane Torrent",
		[11876] = 120,				--"War Stomp",
		[69041] = 120,				--"Rocket Barrage",
		[42292] = 120,				--"PvP Trinket",
	},
	[L["HUNTER"]] = {
		[19386] = 45,				--"Wyvern Sting",
		[19263] = 180,				--"Deterrence",
		[19503] = 30,				--"Scatter Shot",
		[34490] = 24,				--"Silencing Shot",
		[147362] = 24,				--"Counter Shot"
		[120697] = 90,				--"Lynx Rush",
		[120679] = 30,				--"Dire Beast",
		[109248] = 45,				--"Binding Shot",
		[1499] = 30,				--"Freezing Trap",
		[82726] = 30,				--"Fervor",
		[3045] = 180,				--"Rapid Fire",
		[53351] = 10,				--"Kill Shot",
		[53271] = 45, 				--"Master's Call",
		[51753] = 60,				--"Camouflage",
		[19574] = 60,				--"Bestial Wrath",
		[61685] = 25,				--"Charge",
		[50519] = 60,				--"Sonic Blast",
		[50245] = 40,				--"Pin",
		[50433] = 10,				--"Ankle Crack",
		[26090] = 30,				--"Pummel",
		[50541] = 60, 				--"Clench",
		[91644] = 60,				--"Snatch",
		[54706] = 40,				--"Vemom Web Spray",
		[4167] = 40,				--"Web",
		[50274] = 12,				--"Spore Cloud",
		[90355] = 360,				--"Ancient Hysteria",
		[90314] = 25,				--"Tailspin",
		[50318] = 60,				--"Serenity Dust",
		[90361] = 40,				--"Spirit Mend",
		[50285] = 40, 				--"Dust Cloud",
		[90327] = 40,				--"Lock Jaw",
		[90337] = 60,				--"Bad Manner",
		[55709] = 480,				--"Heart of the Phoenix",
		[53476] = 30,				--"Intervene",
		[53480] = 60,				--"Roar of Sacrifice",
		[53478] = 360,				--"Last Stand",
		[53517] = 180,				--"Roar of Recovery",
	},
	[L["WARLOCK"]] = {
		[6789] = 45,				--"Death Coil",
		[5484] = 40,				--"Howl of Terror",
		[111397] = 30,				--"Blood Horror",
		[110913] = 180,				--"Dark Bargain",
		[108482] = 60,				--"Unbound Will",
		[108359] = 120,				--"Dark Regeneration",
		[108416] = 60,				--"Sacrificial Pact",
		[30283] = 30,				--"Shadowfury",
		[6229] = 30,				--"Shadow Ward",
		[48020] = 30,				--"Demonic Circle: Teleport",
		[91711] = 30,				--"Nether Ward",
		[104773] = 120,				-- Unending Resolve
	
		[19647] = 24,				--"Spell Lock",
		[7812] = 60,				--"Sacrifice",
		[89766] = 30,				--"Axe Toss"
		[89751] = 45,				--"Felstorm",
		[115781] = 24,				-- Optical Blast
	},
	[L["MAGE"]] = {
		[2139] = 22,				--"Counterspell",
		[45438] = 300,				--"Ice Block",
		[110959] = 90,				--"Greater Invisibility",
		[102051] = 20,				--"Frostjaw",
		[44572] = 30,				--"Deep Freeze",
		[11958] = 180,				--"Cold Snap",	
		[12042] = 90,				--"Arcane Power",		
		[12051] = 120,				--"Evocation", 
		[122] = 25,					--"Frost Nova",	
		[11426] = 25,				--"Ice Barrier", 
		[12472] = 180,				--"Icy Veins",
		[55342] = 180,				--"Mirror Image", 
		[66] = 300,					--"Invisibility",
		[113724] = 45,				--"Ring of Frost",
		[80353] = 300, 				--"Time Warp",
		[12043] = 90,				--"Presence of Mind",
		[11129] = 45,				--"Combustion",
		[31661] = 20,				--"Dragon's Breath",
		[1953] = 15,				-- Blink
	
		[33395] = 25,				--"Freeze",
},
	[L["DEATHKNIGHT"]] = {
		[47476] = 60,				--"Strangulate",
		[108194] = 30,				-- Asphyxiate
		[48707] = 45,				--"Anti-Magic Shell",
		[49576] = 25,				--"Death Grip",	
		[47528] = 13,				--"Mind Freeze",
		[108200] = 60,				--"Remorseless Winter",
		[108201] = 120,				--"Desecrated Ground",
		[108199] = 60,				--"Gorefiend's Grasp",
		[49039] = 120,				--"Lichborne",
		[49222] = 60,				--"Bone Shield",
		[51271] = 60,				--"Pillar of Frost",
		[51052] = 120,				--"Anti-Magic Zone",
		[49206] = 180,				--"Summon Gargoyle",
		[48792] = 180,				--"Icebound Fortitude",
		[48743] = 120,				--"Death Pact",
	},
	[L["DRUID"]] = {
		[78675] = 60,				--"Solar Beam",
		[5211] = 50,				--"Bash",
		[80964] = 15,				--"Skull Bash",
		[80965] = 15,				--"Skull Bash",
		[132469] = 30,				-- Тайфун
		[124974] = 90,				--"Nature's Vigil",
		[102359] = 30,				--"Mass Entanglement",
		[99] = 30,					--"Disorienting Roar",
		[102280] = 30,				--"Displacer Beast",
		[22812] = 60,				--"Barkskin",
		[132158] = 60,				--"Nature's Swiftness",
		[33891] = 180,				--"Tree of Life",
		[16979] = 15,				--"Wild Charge - Bear",
		[49376] = 15,				--"Wild Charge - Cat",
		[61336] = 180,				--"Survival Instincts",
		[50334] = 180,				--"Berserk",
		[22570] = 10,				--"Maim",
		[18562] = 15,				--"Swiftmend",
		[48505] = 90,				--"Starfall",
		[16689] = 60, 				--"Nature's Grasp",
		[740] = 480,				--"Tranquility",
		[78674] = 15,				--"Starsurge",
		[29166] = 180,				--"Innervate",
	},
	[L["MONK"]] = {
		[116705] = 15, 				--Spear Hand Strike (interrupt)
		[115078] = 15, 				--Paralysis
		[119381] = 45, 				--Leg Sweep (mass stun)
		[123904] = 180,				--"Invoke Xuen, the White Tiger",
		[101643] = 45,				--"Transcendence",
		[119996] = 25,				--"Transcendence: Transfer",
		[115176] = 180,				--"Zen Meditation",
		[115310] = 180,				--"Revival",
		[122278] = 90, 				--"Dampen Harm",
		[122783] = 90,				--"Diffuse Magic",
		[117368] = 60,				--"Grapple Weapon",
		[116844] = 45,				--"Ring of Peace",
		[116849] = 120,				--"Life Cocoon",
		[137562] = 120,				--"Nimble Brew",
		[122470] = 90,				--"Touch of Karma",
		[101545] = 25,				--"Flying Serpent Kick",
		[116841] = 30,				--"Tiger's Lust",
		[113656] = 25,				--"Fists of Fury",
		[122057] = 35,				--"Clash",
	},
	[L["PALADIN"]] = {
		[853] = 60,					--"Hammer of Justice" (stun)
		[115750] = 120,				--Blinding Light (blind (sic!))
		[105593] = 30,				-- Fist of Justice
		[96231] = 15,				--"Rebuke",
		[642] = 300,				--"Divine Shield",
		[85499] = 45,				--"Speed of Light",
		[1044] = 25,				--"Hand of Freedom",
		[31884] = 180,				--"Avenging Wrath",
		[31935] = 15,				--"Avenger's Shield",
		[633] = 600,				--"Lay on Hands",
		[1022] = 300,				--"Hand of Protection",
		[498] = 60,					--"Divine Protection",
		[54428] = 120,				--"Divine Plea",
		[6940] = 120,				--"Hand of Sacrifice",
		[86669] = 180,				--"Guardian of Ancient Kings(Holy)",
		[31842] = 180,				--"Divine Favor",
		[31821] = 180,				--"Devotion Aura",
		[20066] = 15,				--"Repentance",
		[31850] = 180,				--"Ardent Defender",
	},
	[L["PRIEST"]] = {
		[64044] = 45,				--"Psychic Horror",
		[8122] = 30,				--"Psychic Scream",
		[15487] = 45,				--"Silence",
		[47585] = 105,				--"Dispersion",
		[33206] = 180,				--"Pain Suppression",
		[108920] = 30,				-- Void Tendrils
		[108921] = 45,				-- Ментальный демон
		[112833] = 30,				-- Призрачный облик
		[123040] = 60,				--"Mindbender",
		[89485] = 45,				--"Inner Focus",
		[10060] = 120,				--"Power Infusion",
		[88625] = 30,				--"Holy Word: Chastise",
		[586] = 30,					--"Fade",
		[112833] = 30,				--"Spectral Guise",
		[6346] = 120,				--"Fear Ward",
		[64901] = 360,				--"Hymn of Hope",
		[64843] = 180,				--"Divine Hymn",
		[73325] = 90,				--"Leap of Faith",
		[19236] = 120,				--"Desperate Prayer",
		[724] = 180,				--"Lightwell",
		[62618] = 180,				--"Power Word: Barrier",
	},
	[L["ROGUE"]] = {
		[2094] = 90,				--"Blind",
		[1766] = 13,				--"Kick",
		[31224] = 60,				--"Cloak of Shadows",
		[1856] = 120,				-- Исчезновение
		[121471] = 180,				--"Shadow Blades",
		[1776] = 10,				--"Gouge",
		[2983] = 60,				--"Sprint",
		[14185] = 300,				--"Preparation",
		[36554] = 20,				--"Shadowstep",
		[5277] = 120,				--"Evasion",
		[408] = 20,					--"Kidney Shot",
		[51722] = 60,				--"Dismantle",
		[76577] = 180,				--"Smoke Bomb",
		[51690] = 120,				--"Killing Spree",
		[51713] = 60, 				--"Shadow Dance",
		[79140] = 120,				--"Vendetta",
	},
	[L["SHAMAN"]] = {
		[8177] = 25,				--"Grounding Totem",
		[57994] = 12,				--"Wind Shear",
		[51490] = 35,				--"Thunderstorm",
		[51485] = 30,				--"Earthbind Totem",
		[8143] = 60,				--"Tremor Totem",
		[51514] = 35,				--"Hex",
		[108269] = 45,				--"Capacitor Totem",
		[108270] = 60,				--"Stone Bulwark Totem",
		[108280] = 180,				--"Healing Tide Totem",
		[98008] = 180,				--"Spirit Link Totem",
		[32182] = 300,				--"Heroism",
		[2825] = 300,				--"Bloodlust",
		[51533] = 120,				--"Feral Spirit",
		[16190] = 180,				--"Mana Tide Totem",
		[30823] = 60,				--"Shamanistic Rage",
		[2484] = 30,				--"Earthbind Totem",
		[79206] = 120,				--"Spiritwalker's Grace",
		[16166] = 90,				--"Elemental Mastery",
		[16188] = 90,				--"Ancestral Swiftness",
		[108273] =	60,				-- Windwalk Totem
		[108285] = 	180,			-- Call of the Elements
	},
	[L["WARRIOR"]] = {
		[102060] = 40,				--"Разрушительный крик"
		[100] = 12,					--"Charge",
		[6552] = 15,				--"Pummel",
		[23920] = 20,				--"Spell Reflection",
		[46924] = 60,				--"Bladestorm",
		[46968] = 40,				--"Shockwave",
		[107574] = 180,				--"Avatar",
		[12292] = 60, 				--"Bloodbath",
		[86346] = 20,				--"Colossus Smash",
		[676] = 60,					--"Disarm",
		[5246] = 90,				--"Intimidating Shout",
		[871] = 180,				--"Shield Wall",	
		[118038] = 120,				--"Die by the Sword",
		[1719] = 180,				--"Recklessness",
		[3411] = 30,				--"Intervene",
		[64382] = 300,				--"Shattering Throw",
		[6544] = 30,				--"Heroic Leap",
		[12975] = 180,				--"Last Stand",
		[114028] = 60,				-- Mass Spell Reflection
		[18499] = 30,				-- Berserker Rage
	},
};
local Interrupts = {
	47528,	-- Mind Freeze
	80964,	-- Skull Bash (bear)
	80965,	-- Skull Bash (cat)
	34490,	-- Silencing Shot
	2139,	-- Counterspell
	96231,	-- Rebuke
	15487,	-- Silence
	1766,	-- Kick
	57994,	-- Wind Shear
	6552,	-- Pummel
	102060,	-- Disrupting Shout
	24259,	-- Spell Lock
	147362,	-- Counter Shot
	116705, -- Spear Hand Strike
};
local Resets = {
	[11958] = {
		45438,		-- Ice Block
		122,		-- Frost Nova
		120			-- Cone of Cold
	},
	[14185] = {
		2983,		-- Sprint
		1856,		-- Vanish
		5277,		-- Evasion
		51722,		-- Dismantle
	},
	[108285] = {
		108269,		-- Capacitor Totem
		8177,		-- Grounding Totem
		51485,		-- Earthgrab Totem
		8143,		-- Tremor Totem
		108270,		-- Stone Bulwark Totem
		108273,		-- Windwalk Totem
	},
};

NCEnabledCDs = {};
NameplateCooldownsDB = {};
local charactersDB = {};
local CDCache = {};
local TextureCache = {};
local ElapsedTimer = 0;
local GUIFrame;
local db;
local LocalPlayerFullName = UnitName("player").." - "..GetRealmName();
local cooldownFrameBorder = "Interface\\AddOns\\NameplateCooldowns\\media\\CooldownFrameBorder.tga";
local cooldownFrameFont = "Interface\\AddOns\\NameplateCooldowns\\media\\teen_bold.ttf";
local smudgeTexture = "Interface\\AddOns\\NameplateCooldowns\\media\\Smudge.tga";
local GUIBorderTexture = "Interface\\AddOns\\NameplateCooldowns\\media\\Border";
local gUI3MoP;

local _G = _G;
local pairs = pairs;
local select = select;
local WorldFrame = WorldFrame;
local string_match = strmatch;
local string_gsub = gsub;
local string_find = strfind;
local bit_band = bit.band;
local GetTime = GetTime;
local tContains = tContains;

local OnStartup = OnStartup;
local OnUpdate = OnUpdate;
local LOADING_SCREEN_DISABLED = LOADING_SCREEN_DISABLED;
local COMBAT_LOG_EVENT_UNFILTERED = COMBAT_LOG_EVENT_UNFILTERED;
local ShowGUI = ShowGUI;
local InitializeGUI = InitializeGUI;
local Print = Print;
local OnGUICategoryClick = OnGUICategoryClick;
local CreateGUICategory = CreateGUICategory;
local ShowGUICategory = ShowGUICategory;
local RebuildCache = RebuildCache;
local AllocateIcon = AllocateIcon;
local ClearFrameOnShow = ClearFrameOnShow;
local InitializeDB = InitializeDB;
local RebuildDropdowns = RebuildDropdowns;
local GUICreateSlider = GUICreateSlider;
local OnUpdateTestMode = OnUpdateTestMode;
local CheckFor_gUIMoP = CheckFor_gUIMoP;
local UpdateUnitNameForNameplate = UpdateUnitNameForNameplate;
local PLAYER_ENTERING_WORLD = PLAYER_ENTERING_WORLD;
local GUICreateButton = GUICreateButton;

SLASH_NAMEPLATECOOLDOWNS1 = '/nc';
function SlashCmdList.NAMEPLATECOOLDOWNS(msg, editBox)
    ShowGUI();
end

function AllocateIcon(frame)
	local icon = CreateFrame("frame", nil, frame);
	icon:SetWidth(db.IconSize);
	icon:SetHeight(db.IconSize);
	icon.texture = icon:CreateTexture(nil, "BORDER");
	icon.texture:SetAllPoints(icon);
	icon.cooldown = icon:CreateFontString(nil, "OVERLAY");
	icon.cooldown:SetTextColor(0.7, 1, 0);
	icon.cooldown:SetAllPoints(icon);
	icon.cooldown:SetFont(cooldownFrameFont, ceil(db.IconSize - db.IconSize / 2), "OUTLINE");
	icon.border = icon:CreateTexture(nil, "OVERLAY");
	icon.border:SetTexture(cooldownFrameBorder);
	icon.border:SetVertexColor(1, 0.35, 0);
	icon.border:SetAllPoints(icon);
	icon.border:Hide();
	icon:SetPoint("TOPLEFT", frame, db.IconXOffset + frame.NCIconsCount * db.IconSize, db.IconYOffset);
	icon:Hide();
	frame.NCIconsCount = frame.NCIconsCount + 1;
	icon.hidden = 1;
	icon.borderIsHidden = 1;
	icon.spellID = 0;
	table.insert(frame.NCIcons, icon);
end

function ClearFrameOnShow(frame)
	for _, value in pairs(frame.NCIcons) do
		if (not value.hidden) then
			value:Hide();
			value.hidden = 1;
		end
	end
	UpdateUnitNameForNameplate(frame);
end

function UpdateUnitNameForNameplate(f)
	if (gUI3MoP) then
		f.NCUnitName = string_gsub(f.name:GetText(), '%s%(%*%)','');
	else
		local _, nameplateChild = f:GetChildren();
		local name = nameplateChild:GetRegions();
		f.NCUnitName = string_gsub(name:GetText(), '%s%(%*%)','');
	end
end

function OnStartup()
	InitializeDB();
	for _, k in pairs(CDs) do
		for spellID in pairs(k) do
			if (db.CDsTable[spellID] == nil) then
				db.CDsTable[spellID] = true;
				Print(format(L["New spell has been added: %s"], GetSpellLink(spellID)));
			end
		end
	end
	RebuildCache();
	CheckFor_gUIMoP();
	MainFrame:SetScript("OnUpdate", function(self, elapsed)
		ElapsedTimer = ElapsedTimer + elapsed;
		if (ElapsedTimer >= 0.5) then
			OnUpdate();				
			ElapsedTimer = 0;
		end
	end);
	MainFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	MainFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function InitializeDB()
	if (NameplateCooldownsDB[LocalPlayerFullName] == nil) then
		NameplateCooldownsDB[LocalPlayerFullName] = { CDsTable = NCEnabledCDs, IconSize = 26, IconXOffset = 0, IconYOffset = 30 };
	end
	db = NameplateCooldownsDB[LocalPlayerFullName];
end

function CheckFor_gUIMoP()
	for i = 1, GetNumAddOns() do
		local name, _, _, enabled = GetAddOnInfo(i);
		if (name == "gUI-v3" and enabled) then
			gUI3MoP = 1;
			break;
		end
	end
end

function OnUpdate()
	local currentTime = GetTime();
	local totalFramesCount = WorldFrame:GetNumChildren();
	for i = 1, totalFramesCount do
		local f = select(i, WorldFrame:GetChildren());
		local nameplateFullName = f:GetName();
		if (nameplateFullName and string_find(nameplateFullName, "NamePlate")) then
			if (f:IsVisible()) then
				if (not f.NCIcons) then
					f.NCIcons = {};
					f.NCIconsCount = 0;
					UpdateUnitNameForNameplate(f);
					f:HookScript("OnShow", ClearFrameOnShow);
				end
				local name = f.NCUnitName;
				local counter = 1;
				if (charactersDB[name]) then
					for index, value in pairs(charactersDB[name]) do
						local duration = CDCache[index];
						local last = currentTime - value;
						if (last < duration) then
							if (counter > f.NCIconsCount) then
								AllocateIcon(f);
							end
							local icon = f.NCIcons[counter];
							if (icon.spellID ~= index) then
								icon.texture:SetTexture(TextureCache[index]);
								icon.spellID = index;
							end
							if (tContains(Interrupts, index)) then
								if (icon.borderIsHidden) then
									icon.border:Show();
									icon.borderIsHidden = nil;
								end
							elseif (not icon.borderIsHidden) then
								icon.border:Hide();
								icon.borderIsHidden = 1;
							end
							local remain = duration - last;
							if (remain >= 60) then
								icon.cooldown:SetText(ceil(remain/60).."m");
							else
								icon.cooldown:SetText(ceil(remain));
							end
							if (icon.hidden) then
								icon:Show();
								icon.hidden = nil;
							end
							counter = counter + 1;
						end
					end
				end
				for k = counter, f.NCIconsCount do
					if (not f.NCIcons[k].hidden) then
						f.NCIcons[k]:Hide();
						f.NCIcons[k].hidden = 1;
					end
				end
			end
		end
	end
end

function OnUpdateTestMode()
	local totalFramesCount = WorldFrame:GetNumChildren();
	for i = 1, totalFramesCount do
		local f = select(i, WorldFrame:GetChildren());
		local nameplateFullName = f:GetName();
		if (nameplateFullName and string_find(nameplateFullName, "NamePlate")) then
			if (f:IsVisible()) then
				if (not f.NCIcons) then
					f.NCIcons = {};
					f.NCIconsCount = 0;
					UpdateUnitNameForNameplate(f);
					f:HookScript("OnShow", ClearFrameOnShow);
				end
				local counter = 1;
				for i = 1, 2 do
					if (counter > f.NCIconsCount) then
						AllocateIcon(f);
					end
					local icon = f.NCIcons[counter];
					if (icon.spellID ~= 42292) then
						icon.texture:SetTexture(TextureCache[42292]);
						icon.spellID = index;
					end
					if (not icon.borderIsHidden) then
						icon.border:Hide();
						icon.borderIsHidden = 1;
					end
					if (i == 1) then
						local n = tonumber(icon.cooldown:GetText());
						if (n == nil or n <= 0 or n > 30) then
							icon.cooldown:SetText("30");
						else
							icon.cooldown:SetText(tostring(n - 1));
						end
					else
						icon.cooldown:SetText("2m");
					end
					if (icon.hidden) then
						icon:Show();
						icon.hidden = nil;
					end
					icon:SetWidth(db.IconSize);
					icon:SetHeight(db.IconSize);
					icon:SetPoint("TOPLEFT", f, db.IconXOffset + (counter - 1) * db.IconSize, db.IconYOffset);
					counter = counter + 1;
				end
				for k = counter, f.NCIconsCount do
					if (not f.NCIcons[k].hidden) then
						f.NCIcons[k]:Hide();
						f.NCIcons[k].hidden = 1;
					end
				end
			end
		end
	end
end

function PLAYER_ENTERING_WORLD()
	wipe(charactersDB);
end

function LOADING_SCREEN_DISABLED()
	MainFrame:UnregisterEvent("LOADING_SCREEN_DISABLED");
	OnStartup();
end

function COMBAT_LOG_EVENT_UNFILTERED(...)
	local _, eventType, _, _, srcName, srcFlags, _, _, _, _, _, spellID = ...;
	if (bit_band(srcFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) ~= 0) then
		if (CDCache[spellID]) then
			if (eventType == "SPELL_CAST_SUCCESS" or eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_MISSED" or eventType == "SPELL_SUMMON") then
				local Name = string_match(srcName, "[%P]+");
				if (not charactersDB[Name]) then
					charactersDB[Name] = {};
				end
				charactersDB[Name][spellID] = GetTime();
			end
		end
		if (Resets[spellID]) then
			if (eventType == "SPELL_CAST_SUCCESS") then
				local Name = string_match(srcName, "[%P]+");
				if (charactersDB[Name]) then
					for _, v in pairs(Resets[spellID]) do
						charactersDB[Name][v] = nil;
					end
				end
			end
		end
	end
end

function RebuildCache()
	wipe(CDCache);
	wipe(TextureCache);
	wipe(charactersDB);
	for _, k in pairs(CDs) do
		for spellID, timeInSec in pairs(k) do
			if (db.CDsTable[spellID] == true) then
				CDCache[spellID] = timeInSec;
				TextureCache[spellID] = select(3, GetSpellInfo(spellID));
			end
		end
	end
	if (UnitFactionGroup("player") == "Alliance") then
		TextureCache[42292] = "Interface\\Icons\\INV_Jewelry_TrinketPVP_01";
	else
		TextureCache[42292] = "Interface\\Icons\\INV_Jewelry_TrinketPVP_02";
	end
end

function ShowGUI()
	if (not InCombatLockdown()) then
		if (not GUIFrame) then
			InitializeGUI();
		end
		GUIFrame:Show();
		OnGUICategoryClick(GUIFrame.CategoryButtons[1]);
	else
		Print(L["Options are not available in combat!"]);
	end
end

function InitializeGUI()
	GUIFrame = CreateFrame("Frame", "NC_GUIFrame", UIParent);
	GUIFrame:SetHeight(350);
	GUIFrame:SetWidth(500);
	GUIFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 80);
	GUIFrame:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = 1,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 3, right = 3, top = 3, bottom = 3 } 
	});
	GUIFrame:SetBackdropColor(0.1,0.22,0.35,1);
	GUIFrame:SetBackdropBorderColor(0.1,0.1,0.1,1);
	GUIFrame:EnableMouse(1);
	GUIFrame:SetMovable(1);
	GUIFrame:SetFrameStrata("DIALOG");
	GUIFrame:SetToplevel(1);
	GUIFrame:SetClampedToScreen(1);
	GUIFrame:SetScript("OnMouseDown", function() GUIFrame:StartMoving(); end);
	GUIFrame:SetScript("OnMouseUp", function() GUIFrame:StopMovingOrSizing(); end);
	GUIFrame:Hide();
	
	GUIFrame.CategoryButtons = {};
	GUIFrame.ActiveCategory = 1;
	
	local header = GUIFrame:CreateFontString("NC_GUIHeader", "ARTWORK", "GameFontHighlight");
	header:SetFont(GameFontNormal:GetFont(), 22, "THICKOUTLINE");
	header:SetPoint("CENTER", GUIFrame, "CENTER", 0, 185);
	header:SetText("NameplateCooldowns");
	
	GUIFrame.outline = CreateFrame("Frame", nil, GUIFrame);
	GUIFrame.outline:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = 1,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	});
	GUIFrame.outline:SetBackdropColor(0.1, 0.1, 0.2, 1);
	GUIFrame.outline:SetBackdropBorderColor(0.8, 0.8, 0.9, 0.4);
	GUIFrame.outline:SetPoint("TOPLEFT", 12, -12);
	GUIFrame.outline:SetPoint("BOTTOMLEFT", 12, 12);
	GUIFrame.outline:SetWidth(100);
	
	local closeButton = CreateFrame("Button", "NC_GUICloseButton", GUIFrame, "UIPanelButtonTemplate");
	closeButton:SetWidth(24);
	closeButton:SetHeight(24);
	closeButton:SetPoint("TOPRIGHT", 0, 22);
	closeButton:SetScript("OnClick", function() GUIFrame:Hide(); end);
	closeButton.text = closeButton:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	closeButton.text:SetPoint("CENTER", closeButton, "CENTER", 1, -1);
	closeButton.text:SetText("X");
	
	local scrollFramesTipText = GUIFrame:CreateFontString("NC_GUIScrollFramesTipText", "OVERLAY", "GameFontNormal");
	scrollFramesTipText:SetFont("Fonts\\FRIZQT__.TTF", 12, nil);
	scrollFramesTipText:SetPoint("CENTER", GUIFrame, "LEFT", 300, 130);
	scrollFramesTipText:SetText(L["Click on icon to enable/disable tracking"]);
	
	GUIFrame.Categories = {};
	
	for index, value in pairs({L["General"], L["Profiles"], L["WARRIOR"], L["DRUID"], L["PRIEST"], L["MAGE"], L["MONK"], L["HUNTER"], L["PALADIN"], L["ROGUE"], L["DEATHKNIGHT"], L["WARLOCK"], L["SHAMAN"], L["MISC"]}) do
		local b = CreateGUICategory();
		b.index = index;
		b.text:SetText(value);
		if (index == 1) then
			b:LockHighlight();
			b.text:SetTextColor(1, 1, 1);
			b:SetPoint("TOPLEFT", GUIFrame.outline, "TOPLEFT", 5, -6);
		elseif (index == 2) then
			b:SetPoint("TOPLEFT",GUIFrame.outline,"TOPLEFT", 5, -24);
		else
			b:SetPoint("TOPLEFT",GUIFrame.outline,"TOPLEFT", 5, -18 * (index - 1) - 26);
		end
		
		GUIFrame.Categories[index] = {};
		
		if (index == 1) then
			local textGeneralLabel = GUIFrame:CreateFontString("NC_GUIGeneralLabel", "OVERLAY", "GameFontNormal");
			textGeneralLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, nil);
			textGeneralLabel:SetPoint("CENTER", GUIFrame, "LEFT", 300, 130);
			textGeneralLabel:SetText(L["You should reload UI after changing settings on this page"]);
			textGeneralLabel:Hide();
			table.insert(GUIFrame.Categories[index], textGeneralLabel);
			
			local buttonSwitchTestMode = GUICreateButton("NC_GUIGeneralButtonSwitchTestMode", GUIFrame, L["Enable test mode (need at least one visible nameplate)"]);
			buttonSwitchTestMode:SetWidth(340);
			buttonSwitchTestMode:SetHeight(40);
			buttonSwitchTestMode:SetPoint("TOPLEFT", GUIFrame, "TOPLEFT", 130, -80);
			buttonSwitchTestMode:SetScript("OnClick", function(self, ...)
				if (self.Text:GetText() == L["Enable test mode (need at least one visible nameplate)"]) then
					MainFrame:SetScript("OnUpdate", function(self, elapsed)
						ElapsedTimer = ElapsedTimer + elapsed;
						if (ElapsedTimer >= 0.5) then
							OnUpdateTestMode();
							ElapsedTimer = 0;
						end
					end);
					OnUpdateTestMode();
					self.Text:SetText(L["Disable test mode"]);
				else
					MainFrame:SetScript("OnUpdate", function(self, elapsed)
						ElapsedTimer = ElapsedTimer + elapsed;
						if (ElapsedTimer >= 0.5) then
							OnUpdate();
							ElapsedTimer = 0;
						end
					end);
					OnUpdate();
					self.Text:SetText(L["Enable test mode (need at least one visible nameplate)"]);
				end
			end);
			table.insert(GUIFrame.Categories[index], buttonSwitchTestMode);
			
			local sliderIconSize = GUICreateSlider(GUIFrame, 130, -140, 340, "NC_GUIGeneralSliderIconSize");
			sliderIconSize.label:SetText(L["Icon size"]);
			sliderIconSize.slider:SetValueStep(1);
			sliderIconSize.slider:SetMinMaxValues(1, 50);
			sliderIconSize.slider:SetValue(db.IconSize);
			sliderIconSize.slider:SetScript("OnValueChanged", function(self, value)
				sliderIconSize.editbox:SetText(tostring(ceil(value)));
				db.IconSize = ceil(value);
			end);
			sliderIconSize.editbox:SetText(tostring(db.IconSize));
			sliderIconSize.editbox:SetScript("OnEnterPressed", function(self, value)
				if (sliderIconSize.editbox:GetText() ~= "") then
					local v = tonumber(sliderIconSize.editbox:GetText());
					if (v == nil) then
						sliderIconSize.editbox:SetText(tostring(db.IconSize));
						Print(L["Value must be a number"]);
					else
						if (v > 50) then
							v = 50;
						end
						if (v < 1) then
							v = 1;
						end
						sliderIconSize.slider:SetValue(v);
					end
					sliderIconSize.editbox:ClearFocus();
				end
			end);
			sliderIconSize.lowtext:SetText("1");
			sliderIconSize.hightext:SetText("50");
			table.insert(GUIFrame.Categories[index], sliderIconSize);
			
			local sliderIconXOffset = GUICreateSlider(GUIFrame, 130, -210, 155, "NC_GUIGeneralSliderIconXOffset");
			sliderIconXOffset.label:SetText(L["Icon X-coord offset"]);
			sliderIconXOffset.slider:SetValueStep(1);
			sliderIconXOffset.slider:SetMinMaxValues(-100, 100);
			sliderIconXOffset.slider:SetValue(db.IconXOffset);
			sliderIconXOffset.slider:SetScript("OnValueChanged", function(self, value)
				sliderIconXOffset.editbox:SetText(tostring(ceil(value)));
				db.IconXOffset = ceil(value);
			end);
			sliderIconXOffset.editbox:SetText(tostring(db.IconXOffset));
			sliderIconXOffset.editbox:SetScript("OnEnterPressed", function(self, value)
				if (sliderIconXOffset.editbox:GetText() ~= "") then
					local v = tonumber(sliderIconXOffset.editbox:GetText());
					if (v == nil) then
						sliderIconXOffset.editbox:SetText(tostring(db.IconXOffset));
						Print(L["Value must be a number"]);
					else
						if (v > 100) then
							v = 100;
						end
						if (v < -100) then
							v = -100;
						end
						sliderIconXOffset.slider:SetValue(v);
					end
					sliderIconXOffset.editbox:ClearFocus();
				end
			end);
			sliderIconXOffset.lowtext:SetText("-100");
			sliderIconXOffset.hightext:SetText("100");
			table.insert(GUIFrame.Categories[index], sliderIconXOffset);
			
			local sliderIconYOffset = GUICreateSlider(GUIFrame, 315, -210, 155, "NC_GUIGeneralSliderIconYOffset");
			sliderIconYOffset.label:SetText(L["Icon Y-coord offset"]);
			sliderIconYOffset.slider:SetValueStep(1);
			sliderIconYOffset.slider:SetMinMaxValues(-100, 100);
			sliderIconYOffset.slider:SetValue(db.IconYOffset);
			sliderIconYOffset.slider:SetScript("OnValueChanged", function(self, value)
				sliderIconYOffset.editbox:SetText(tostring(ceil(value)));
				db.IconYOffset = ceil(value);
			end);
			sliderIconYOffset.editbox:SetText(tostring(db.IconYOffset));
			sliderIconYOffset.editbox:SetScript("OnEnterPressed", function(self, value)
				if (sliderIconYOffset.editbox:GetText() ~= "") then
					local v = tonumber(sliderIconYOffset.editbox:GetText());
					if (v == nil) then
						sliderIconYOffset.editbox:SetText(tostring(db.IconYOffset));
						Print(L["Value must be a number"]);
					else
						if (v > 100) then
							v = 100;
						end
						if (v < -100) then
							v = -100;
						end
						sliderIconYOffset.slider:SetValue(v);
					end
					sliderIconYOffset.editbox:ClearFocus();
				end
			end);
			sliderIconYOffset.lowtext:SetText("-100");
			sliderIconYOffset.hightext:SetText("100");
			table.insert(GUIFrame.Categories[index], sliderIconYOffset);
		elseif (index == 2) then
			local textProfilesCurrentProfile = GUIFrame:CreateFontString("NC_GUIProfilesTextCurrentProfile", "OVERLAY", "GameFontNormal");
			textProfilesCurrentProfile:SetFont("Fonts\\FRIZQT__.TTF", 12, nil);
			textProfilesCurrentProfile:SetPoint("CENTER", GUIFrame, "LEFT", 300, 130);
			textProfilesCurrentProfile:SetText(format(L["Current profile: [%s]"], LocalPlayerFullName));
			table.insert(GUIFrame.Categories[index], textProfilesCurrentProfile);
			
			local dropdownCopyProfile = CreateFrame("Frame", "NC_GUIProfilesDropdownCopyProfile", GUIFrame, "UIDropDownMenuTemplate");
			UIDropDownMenu_SetWidth(dropdownCopyProfile, 210);
			dropdownCopyProfile:SetPoint("TOPLEFT", GUIFrame, "TOPLEFT", 120, -80);
			dropdownCopyProfile.text = dropdownCopyProfile:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
			dropdownCopyProfile.text:SetPoint("LEFT", 20, 20);
			dropdownCopyProfile.text:SetText(L["Copy other profile to current profile:"]);
			table.insert(GUIFrame.Categories[index], dropdownCopyProfile);
			
			local buttonCopyProfile = GUICreateButton("NC_GUIProfilesButtonCopyProfile", GUIFrame, L["Copy"]);
			buttonCopyProfile:SetWidth(90);
			buttonCopyProfile:SetHeight(24);
			buttonCopyProfile:SetPoint("TOPLEFT", GUIFrame, "TOPLEFT", 380, -82);
			buttonCopyProfile:SetScript("OnClick", function(self, ...)
				if (dropdownCopyProfile.myvalue ~= nil) then
					NameplateCooldownsDB[LocalPlayerFullName] = NameplateCooldownsDB[dropdownCopyProfile.myvalue];
					Print(format(L["Data from '%s' has been successfully copied to '%s'"], dropdownCopyProfile.myvalue, LocalPlayerFullName));
					RebuildDropdowns();
				end
			end);
			table.insert(GUIFrame.Categories[index], buttonCopyProfile);
			
			local dropdownDeleteProfile = CreateFrame("Frame", "NC_GUIProfilesDropdownDeleteProfile", GUIFrame, "UIDropDownMenuTemplate");
			UIDropDownMenu_SetWidth(dropdownDeleteProfile, 210);
			dropdownDeleteProfile:SetPoint("TOPLEFT", GUIFrame, "TOPLEFT", 120, -120);
			dropdownDeleteProfile.text = dropdownDeleteProfile:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
			dropdownDeleteProfile.text:SetPoint("LEFT", 20, 20);
			dropdownDeleteProfile.text:SetText(L["Delete profile:"]);
			table.insert(GUIFrame.Categories[index], dropdownDeleteProfile);
			
			local buttonDeleteProfile = GUICreateButton("NC_GUIProfilesButtonDeleteProfile", GUIFrame, L["Delete"]);
			buttonDeleteProfile:SetWidth(90);
			buttonDeleteProfile:SetHeight(24);
			buttonDeleteProfile:SetPoint("TOPLEFT", GUIFrame, "TOPLEFT", 380, -122);
			buttonDeleteProfile:SetScript("OnClick", function(self, ...)
				if (dropdownDeleteProfile.myvalue ~= nil) then
					NameplateCooldownsDB[dropdownDeleteProfile.myvalue] = nil;
					Print(format(L["Profile '%s' has been successfully deleted"], dropdownDeleteProfile.myvalue));
					RebuildDropdowns();
				end
			end);
			table.insert(GUIFrame.Categories[index], buttonDeleteProfile);
			
			RebuildDropdowns();
		else
			local scrollAreaBackground = CreateFrame("Frame", "NC_GUIScrollFrameBackground_"..tostring(index - 1), GUIFrame);
			scrollAreaBackground:SetPoint("TOPLEFT", GUIFrame, "TOPLEFT", 120, -60);
			scrollAreaBackground:SetPoint("BOTTOMRIGHT", GUIFrame, "BOTTOMRIGHT", -30, 15);
			scrollAreaBackground:SetBackdrop({
				bgFile = smudgeTexture,
				edgeFile = GUIBorderTexture,
				tile = true, edgeSize = 3, tileSize = 1,
				insets = { left = 3, right = 3, top = 3, bottom = 3 }
			});
			scrollAreaBackground:SetBackdropColor(0.1, 0.22, 0.35, 0.8)
			scrollAreaBackground:SetBackdropBorderColor(0.3, 0.3, 0.5, 1);
			scrollAreaBackground:Hide();
			table.insert(GUIFrame.Categories[index], scrollAreaBackground);
			
			local scrollArea = CreateFrame("ScrollFrame", "NC_GUIScrollFrame_"..tostring(index - 1), scrollAreaBackground, "UIPanelScrollFrameTemplate");
			scrollArea:SetPoint("TOPLEFT", scrollAreaBackground, "TOPLEFT", 5, -5);
			scrollArea:SetPoint("BOTTOMRIGHT", scrollAreaBackground, "BOTTOMRIGHT", -5, 5);
			scrollArea:Show();
			
			local scrollAreaChildFrame = CreateFrame("Frame", "NC_GUIScrollFrameChildFrame_"..tostring(index - 1), scrollArea);
			scrollArea:SetScrollChild(scrollAreaChildFrame);
			scrollAreaChildFrame:SetPoint("CENTER", GUIFrame, "CENTER", 0, 1);
			scrollAreaChildFrame:SetWidth(288);
			scrollAreaChildFrame:SetHeight(288);
			
			local iterator = 1;
			for spellID in pairs(CDs[value]) do
				local n, _, icon = GetSpellInfo(spellID);
				if (not n) then
					Print(format(L["Unknown spell: %s"], spellID));
				end
				
				local spellItem = CreateFrame("button", nil, scrollAreaChildFrame, "SecureActionButtonTemplate");
				spellItem:SetHeight(20);
				spellItem:SetWidth(20);
				spellItem:SetPoint("TOPLEFT", 3, ((iterator - 1) * -22) - 10);
				
				spellItem.tex = spellItem:CreateTexture();
				spellItem.tex:SetAllPoints(spellItem);
				spellItem.tex:SetHeight(20);
				spellItem.tex:SetWidth(20);
				spellItem.tex:SetTexture(icon);
				
				spellItem.Text = spellItem:CreateFontString(nil, "OVERLAY");
				spellItem.Text:SetFont("Fonts\\FRIZQT__.TTF", 12, nil);
				spellItem.Text:SetPoint("LEFT", 22, 0);
				spellItem.Text:SetText(n.."  (ID: "..tostring(spellID)..")");
				spellItem:EnableMouse(true);
				
				spellItem:SetScript("OnEnter", function(self, ...)
					GameTooltip:SetOwner(spellItem, "ANCHOR_TOPRIGHT");
					GameTooltip:SetSpellByID(spellID);
					GameTooltip:Show();
				end)
				spellItem:SetScript("OnLeave", function(self, ...)
					GameTooltip:Hide();
				end)
				spellItem:SetScript("OnClick", function(self, ...)
					if (self.tex:GetAlpha() > 0.5) then
						db.CDsTable[spellID] = false;
						self.tex:SetAlpha(0.3);
					else
						db.CDsTable[spellID] = true;
						self.tex:SetAlpha(1.0);
					end
					RebuildCache();
				end)
				if (db.CDsTable[spellID] == true) then
					spellItem.tex:SetAlpha(1.0);
				else
					spellItem.tex:SetAlpha(0.3);
				end
				iterator = iterator + 1;
			end
		end
	end
end

function OnGUICategoryClick(self, ...)
	GUIFrame.CategoryButtons[GUIFrame.ActiveCategory].text:SetTextColor(1, 0.82, 0);
	GUIFrame.CategoryButtons[GUIFrame.ActiveCategory]:UnlockHighlight();
	GUIFrame.ActiveCategory = self.index;
	self.text:SetTextColor(1, 1, 1);
	self:LockHighlight();
	PlaySound("igMainMenuOptionCheckBoxOn");
	ShowGUICategory(GUIFrame.ActiveCategory);
end

function ShowGUICategory(index)
	for i, v in pairs(GUIFrame.Categories) do
		for k, l in pairs(v) do
			l:Hide();
		end
	end
	for i, v in pairs(GUIFrame.Categories[index]) do
		v:Show();
	end
	if (index > 2) then
		NC_GUIScrollFramesTipText:Show();
	else
		NC_GUIScrollFramesTipText:Hide();
	end
end

function RebuildDropdowns()
	local info = {};
	NC_GUIProfilesDropdownCopyProfile.myvalue = nil;
	UIDropDownMenu_SetText(NC_GUIProfilesDropdownCopyProfile, "");
	local initCopyProfile = function()
		wipe(info);
		for index in pairs(NameplateCooldownsDB) do
			if (index ~= LocalPlayerFullName) then
				info.text = index;
				info.func = function(self)
					NC_GUIProfilesDropdownCopyProfile.myvalue = index;
					UIDropDownMenu_SetText(NC_GUIProfilesDropdownCopyProfile, index);
				end
				info.notCheckable = true;
				UIDropDownMenu_AddButton(info);
			end
		end
	end
	UIDropDownMenu_Initialize(NC_GUIProfilesDropdownCopyProfile, initCopyProfile);
	
	NC_GUIProfilesDropdownDeleteProfile.myvalue = nil;
	UIDropDownMenu_SetText(NC_GUIProfilesDropdownDeleteProfile, "");
	local initDeleteProfile = function()
		wipe(info);
		for index in pairs(NameplateCooldownsDB) do
			info.text = index;
			info.func = function(self)
				NC_GUIProfilesDropdownDeleteProfile.myvalue = index;
				UIDropDownMenu_SetText(NC_GUIProfilesDropdownDeleteProfile, index);
			end
			info.notCheckable = true;
			UIDropDownMenu_AddButton(info);
		end
	end
	UIDropDownMenu_Initialize(NC_GUIProfilesDropdownDeleteProfile, initDeleteProfile);
end

function CreateGUICategory()
	local b = CreateFrame("Button", nil, GUIFrame.outline);
	b:SetWidth(92);
	b:SetHeight(18);
	b:SetScript("OnClick", OnGUICategoryClick);
	b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
	b:GetHighlightTexture():SetAlpha(0.7);
	b.text = b:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	b.text:SetPoint("LEFT", 3, 0);
	GUIFrame.CategoryButtons[#GUIFrame.CategoryButtons + 1] = b;
	return b;
end

function GUICreateSlider(parent, x, y, size, publicName)
	local frame = CreateFrame("Frame", publicName, parent);
	frame:SetHeight(100);
	frame:SetWidth(size);
	frame:SetPoint("TOPLEFT", x, y);

	frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	frame.label:SetFont("Fonts\\FRIZQT__.TTF", 12, nil);
	frame.label:SetPoint("TOPLEFT");
	frame.label:SetPoint("TOPRIGHT");
	frame.label:SetJustifyH("CENTER");
	frame.label:SetHeight(15);
	
	frame.slider = CreateFrame("Slider", nil, frame);
	frame.slider:SetOrientation("HORIZONTAL")
	frame.slider:SetHeight(15)
	frame.slider:SetHitRectInsets(0, 0, -10, 0)
	frame.slider:SetBackdrop({
		bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
		edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
		tile = true, tileSize = 8, edgeSize = 8,
		insets = { left = 3, right = 3, top = 6, bottom = 6 }
	});
	frame.slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
	frame.slider:SetPoint("TOP", frame.label, "BOTTOM")
	frame.slider:SetPoint("LEFT", 3, 0)
	frame.slider:SetPoint("RIGHT", -3, 0)

	frame.lowtext = frame.slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	frame.lowtext:SetPoint("TOPLEFT", frame.slider, "BOTTOMLEFT", 2, 3)

	frame.hightext = frame.slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	frame.hightext:SetPoint("TOPRIGHT", frame.slider, "BOTTOMRIGHT", -2, 3)

	frame.editbox = CreateFrame("EditBox", nil, frame)
	frame.editbox:SetAutoFocus(false)
	frame.editbox:SetFontObject(GameFontHighlightSmall)
	frame.editbox:SetPoint("TOP", frame.slider, "BOTTOM")
	frame.editbox:SetHeight(14)
	frame.editbox:SetWidth(70)
	frame.editbox:SetJustifyH("CENTER")
	frame.editbox:EnableMouse(true)
	frame.editbox:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
		tile = true, edgeSize = 1, tileSize = 5,
	});
	frame.editbox:SetBackdropColor(0, 0, 0, 0.5)
	frame.editbox:SetBackdropBorderColor(0.3, 0.3, 0.30, 0.80)
	frame.editbox:SetScript("OnEscapePressed", function() frame.editbox:ClearFocus(); end)
	frame:Hide();
	return frame;
end

function GUICreateButton(publicName, parentFrame, text)
	local button = CreateFrame("Button", publicName, parentFrame);
	button.Background = button:CreateTexture(nil, "BORDER");
	button.Background:SetPoint("TOPLEFT", 1, -1);
	button.Background:SetPoint("BOTTOMRIGHT", -1, 1);
	button.Background:SetTexture(0, 0, 0, 1);

	button.Border = button:CreateTexture(nil, "BACKGROUND");
	button.Border:SetPoint("TOPLEFT", 0, 0);
	button.Border:SetPoint("BOTTOMRIGHT", 0, 0);
	button.Border:SetTexture(unpack({0.73, 0.26, 0.21, 1}));

	button.Normal = button:CreateTexture(nil, "ARTWORK");
	button.Normal:SetPoint("TOPLEFT", 2, -2);
	button.Normal:SetPoint("BOTTOMRIGHT", -2, 2);
	button.Normal:SetTexture(unpack({0.38, 0, 0, 1}));
	button:SetNormalTexture(button.Normal);

	button.Disabled = button:CreateTexture(nil, "OVERLAY");
	button.Disabled:SetPoint("TOPLEFT", 3, -3);
	button.Disabled:SetPoint("BOTTOMRIGHT", -3, 3);
	button.Disabled:SetTexture(0.6, 0.6, 0.6, 0.2);
	button:SetDisabledTexture(button.Disabled);

	button.Highlight = button:CreateTexture(nil, "OVERLAY");
	button.Highlight:SetPoint("TOPLEFT", 3, -3);
	button.Highlight:SetPoint("BOTTOMRIGHT", -3, 3);
	button.Highlight:SetTexture(0.6, 0.6, 0.6, 0.2);
	button:SetHighlightTexture(button.Highlight);

	button.Text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	button.Text:SetPoint("CENTER", 0, 0);
	button.Text:SetJustifyH("CENTER");
	button.Text:SetTextColor(1, 0.82, 0, 1);
	button.Text:SetText(text);

	button:SetScript("OnMouseDown", function(self) self.Text:SetPoint("CENTER", 1, -1) end);
	button:SetScript("OnMouseUp", function(self) self.Text:SetPoint("CENTER", 0, 0) end);
	return button;
end

function Print(message)
	DEFAULT_CHAT_FRAME:AddMessage(format("NameplateCooldowns: %s", message), 0, 128, 128);
end

MainFrame:SetScript("OnEvent", function(self, event, ...)
	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		COMBAT_LOG_EVENT_UNFILTERED(...);
	elseif (event == "PLAYER_ENTERING_WORLD") then
		PLAYER_ENTERING_WORLD();
	else
		LOADING_SCREEN_DISABLED();
	end
end);