
MacroToolkitDB = {
	["char"] = {
		["Darkrizen - Tichondrius"] = {
			["extended"] = {
				["37"] = {
					["name"] = " ",
					["icon"] = "SPELL_NATURE_SWIFTNESS",
					["body"] = "/2 |cffffff00|Hachievement:2091:0300000008BE3783:1:4:21:9:0:0:0:0|h[Gladiator]|h|r Holy Paladin LF 3's or RBG's\n/2 |cffffff00|Hachievement:2091:0300000008BE3783:1:4:21:9:0:0:0:0|h[Gladiator]|h|r Holy Paladin LF 3's or RBG's\n/1 Holy Paladin LF 3's or RBG's\n/1 Holy Paladin LF 3's or RBG's",
				},
				["40"] = {
					["name"] = "HoJ",
					["icon"] = "SPELL_HOLY_FISTOFJUSTICE",
					["body"] = "#showtooltip [mod:shift] Hammer of Wrath; Hammer of Justice\n/cast [mod:shift] Hammer of Wrath\n/cast [mod:shift] Judgment\n/cast [mod:shift] Holy Shock\n/use [@focus,exists,harm,nodead]Hammer of Justice\n/stopmacro [@focus,exists,harm]\n/use [harm,nodead]Hammer of Justice\n/stopmacro [harm,nodead,exists]\n/targetenemy\n/use Hammer of Justice\n/targetlasttarget\n",
				},
				["41"] = {
					["icon"] = "ABILITY_PALADIN_TURNEVIL",
					["name"] = "Fear",
					["body"] = "#showtooltip\n/targetenemyplayer [noharm]\n/use [@focus][] Turn Evil\n/targetlasttarget [harm,exists]\n",
				},
			},
			["backups"] = {
			},
		},
		["Harvardswag - Tichondrius"] = {
			["backups"] = {
			},
			["extended"] = {
				["37"] = {
					["name"] = "Curse",
					["icon"] = "SPELL_SHADOW_CURSEOFSARGERAS",
					["body"] = "/targetenemy\n/use Agony",
				},
			},
		},
		["Darkrísen - Mal'Ganis"] = {
			["backups"] = {
			},
			["extended"] = {
				["37"] = {
					["icon"] = "SPELL_HOLY_FISTOFJUSTICE",
					["name"] = "HoJ",
					["body"] = "#showtooltip Cyclone\n/use [@focus,exists,harm,nodead]Cyclone\n/stopmacro [@focus,exists,harm]\n/use [harm,nodead]Cyclone\n/stopmacro [harm,nodead,exists]\n/targetenemy\n/use Cyclone\n/targetlasttarget\n",
				},
			},
		},
	},
	["profileKeys"] = {
		["Sillytwink - Gilneas"] = "profile",
		["Darkrísen - Tichondrius"] = "profile",
		["Sourlemons - Mal'Ganis"] = "profile",
		["Darkraged - Eonar"] = "profile",
		["Darkrizen - Sargeras"] = "profile",
		["Darkrizen - Arygos"] = "profile",
		["Harvardswag - Tichondrius"] = "profile",
		["Darkrísen - Mal'Ganis"] = "profile",
		["Darkrizen - Tichondrius"] = "profile",
	},
	["global"] = {
		["ebackups"] = {
		},
		["lastbackup"] = "Apr 20 22:24:59",
		["backups"] = {
			{
				["m"] = {
					{
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 1,
						["name"] = "AF",
						["body"] = "/run LoadAddOn(\"Blizzard_ArenaUI\") ArenaEnemyFrames:Show() ArenaEnemyFrame1:Show() ArenaEnemyFrame2:Show() ArenaEnemyFrame3:Show() ArenaEnemyFrame1CastingBar:Show() ArenaEnemyFrame2CastingBar:Show() ArenaEnemyFrame3CastingBar:Show()\n",
					}, -- [1]
					{
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 2,
						["name"] = "AF Hide",
						["body"] = "/run LoadAddOn(\"Blizzard_ArenaUI\") ArenaEnemyFrames:Hide() ArenaEnemyFrame1:Hide() ArenaEnemyFrame2:Hide() ArenaEnemyFrame3:Hide() ArenaEnemyFrame1CastingBar:Hide() ArenaEnemyFrame2CastingBar:Hide() ArenaEnemyFrame3CastingBar:Hide()\n",
					}, -- [2]
					{
						["icon"] = "INV_MISC_FOOD_100",
						["index"] = 3,
						["name"] = "Eat",
						["body"] = "/cancelaura Hand of Protection\n/use Conjured Mana Buns\n/use Frybread\n/use Bandage\n/use Plump Fig\n/use Golden Carp Consomme\n/cast !Stealth\n",
					}, -- [3]
					{
						["icon"] = "ABILITY_WARRIOR_REVENGE",
						["index"] = 4,
						["name"] = "Focus",
						["body"] = "/focus target\n/focus [@mouseover,nodead,exists]",
					}, -- [4]
					{
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 5,
						["name"] = "gr",
						["body"] = "#show [mod:ctrl] Rupture; Garrote\n/targetenemyplayer [notarget]\n/cast [nomod,nostealth] Shadow Dance\n/cast [nomod] Garrote; [mod:ctrl] Rupture\n/cast [mod:shift, target=focus] Garrote\n/use [stance:3] 13\n/cast [nomod] Premeditation;\n/startattack\n",
					}, -- [5]
					{
						["icon"] = "ACHIEVEMENT_GUILDPERK_BARTERING",
						["index"] = 6,
						["name"] = "Guild",
						["body"] = "/2 <LQQT> Gladiator Lead, Level 25 PVP Guild recruiting 2k+ XP Players PST with achieve and you're in! Otherwise, come try out as a recruit for a while and see if you get any better!\n",
					}, -- [6]
					{
						["icon"] = "ACHIEVEMENT_GUILDPERK_HASTYHEARTH",
						["index"] = 7,
						["name"] = "MacroPoster",
						["body"] = "|cffffff00|Hachievement:2091:0300000008BE3783:1:4:21:9:0:0:0:0|h[Gladiator]|h|r HPal, Rdruid, and Mage  LF a legit warlock and ele shaman\n",
					}, -- [7]
					{
						["icon"] = "ABILITY_MOUNT_RAZORSCALE",
						["index"] = 8,
						["name"] = "Mount",
						["body"] = "#showtooltip Ironbound Proto-Drake\n/use [flyable] Ironbound Proto-Drake\n/use [noflyable]Black War Elekk\n/dismount [mounted]\n",
					}, -- [8]
					{
						["icon"] = "ACHIEVEMENT_GUILDPERK_HONORABLEMENTION_RANK2",
						["index"] = 9,
						["name"] = "Party",
						["body"] = "/run PartyMemberFrame1:ClearAllPoints() PartyMemberFrame1:SetPoint(\"TOPLEFT\", 188, -250)\n/run PartyMemberFrame2:ClearAllPoints() PartyMemberFrame2:SetPoint(\"TOPLEFT\", 188, -170)\n/run PartyMemberFrame3:ClearAllPoints() PartyMemberFrame3:SetPoint(\"TOPLEFT\",\n",
					}, -- [9]
					{
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 10,
						["name"] = "pvp",
						["body"] = "#show Every Man for Himself\n/use Every Man for Himself\n/cast !Stealth\n",
					}, -- [10]
					{
						["icon"] = "SPELL_FROST_ARCTICWINDS",
						["index"] = 11,
						["name"] = "Reset",
						["body"] = "/run for i=1,58 do _G[\"t\"..i]:Hide() end\n",
					}, -- [11]
					{
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 12,
						["name"] = "sap",
						["body"] = "#show Sap\n/tar nearestenemy\n/cast [nostealth] Shadow Dance\n/cast [mod:shift, target=focus] Sap\n/cast [notarget, target=nearestenemy] Sap; Sap\n",
					}, -- [12]
					{
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 13,
						["name"] = "Step1",
						["body"] = "/target arena1\n/cast [target=arena1] Shadowstep\n/startattack\n",
					}, -- [13]
					{
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 14,
						["name"] = "Step2",
						["body"] = "/target arena2\n/cast [target=arena2] Shadowstep\n/startattack\n",
					}, -- [14]
					{
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 15,
						["name"] = "Step3",
						["body"] = "/target arena3\n/cast [target=arena3] Shadowstep\n/startattack\n",
					}, -- [15]
					{
						["icon"] = "INV_MISC_TOKEN_ARGENTDAWN3",
						["index"] = 16,
						["name"] = "trink",
						["body"] = "#showtooltip\n/use 13\n/use 14\n/use 10",
					}, -- [16]
				},
				["d"] = "Mar 17 01:00:37",
				["n"] = "Rogue",
			}, -- [1]
			{
				["m"] = {
					{
						["name"] = "DL",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 1,
						["body"] = "/cast [mod:alt,@Darkrizen][] Divine Light\n",
					}, -- [1]
					{
						["name"] = "Focus",
						["icon"] = "ABILITY_WARRIOR_REVENGE",
						["index"] = 2,
						["body"] = "/focus target\n/focus [@mouseover,nodead,exists]\n",
					}, -- [2]
					{
						["name"] = "Glad",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 3,
						["body"] = "#showtooltip\n/use [flyable]Deadly Gladiator's Frost Wyrm\n/use [noflyable]Summon Thalassian Charger\n/dismount [mounted]\n",
					}, -- [3]
					{
						["name"] = "gr",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 4,
						["body"] = "#show [mod:ctrl] Rupture; Garrote\n/targetenemyplayer [notarget]\n/cast [nomod,nostealth] Shadow Dance\n/cast [nomod] Garrote; [mod:ctrl] Rupture\n/cast [mod:shift, target=focus] Garrote\n/use [stance:3] 13\n/cast [nomod] Premeditation;\n/startattack\n",
					}, -- [4]
					{
						["name"] = "HL",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 5,
						["body"] = "/cast [mod:alt,@Darkrizen][] Holy Light\n",
					}, -- [5]
					{
						["name"] = "LoD",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 6,
						["body"] = "/cast [nomod] Light of Dawn; [mod:shift] Divine Plea\n",
					}, -- [6]
					{
						["name"] = "MacroPoster",
						["icon"] = "ACHIEVEMENT_GUILDPERK_HASTYHEARTH",
						["index"] = 7,
						["body"] = "LF |cffffff00|Hachievement:2091:0300000008BE3783:1:4:21:9:0:0:0:0|h[Gladiator]|h|r DPS for an all glad RBG group\n",
					}, -- [7]
					{
						["name"] = "Mnt",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 8,
						["body"] = "#showtooltip\n/use [flyable]Ironbound Proto-Drake\n/use [noflyable]Summon Thalassian Charger\n/dismount [mounted]\n",
					}, -- [8]
					{
						["name"] = "NO!",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 9,
						["body"] = "/use Grievous Gladiator's Medallion of Meditation\n/w Darkrizen Dude quit standing out in the fucking open. WTF.\n",
					}, -- [9]
					{
						["name"] = "Party",
						["icon"] = "ACHIEVEMENT_GUILDPERK_HONORABLEMENTION_RANK2",
						["index"] = 10,
						["body"] = "/run PartyMemberFrame1:ClearAllPoints() PartyMemberFrame1:SetPoint(\"TOPLEFT\", 188, -250)\n/run PartyMemberFrame2:ClearAllPoints() PartyMemberFrame2:SetPoint(\"TOPLEFT\", 188, -170)\n/run PartyMemberFrame3:ClearAllPoints() PartyMemberFrame3:SetPoint(\"TOPLEFT\",\n",
					}, -- [10]
					{
						["name"] = "Reset",
						["icon"] = "INV_CHEST_PLATE15",
						["index"] = 11,
						["body"] = "/run for i=1,58 do _G[\"t\"..i]:Hide() end\n",
					}, -- [11]
					{
						["name"] = "sap",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 12,
						["body"] = "#show Sap\n/tar nearestenemy\n/cast [nostealth] Shadow Dance\n/cast [mod:shift, target=focus] Sap\n/cast [notarget, target=nearestenemy] Sap; Sap\n",
					}, -- [12]
					{
						["name"] = "trink",
						["icon"] = "INV_PET_CRANEGOD",
						["index"] = 13,
						["body"] = "#showtooltip 13\n/use 13\n/use 14\n/use 10\n",
					}, -- [13]
				},
				["d"] = "Mar 21 13:13:27",
				["n"] = "Paladin",
			}, -- [2]
			{
				["m"] = {
					{
						["name"] = "DL",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 1,
						["body"] = "/cast [mod:alt,@Darkrizen][] Divine Light\n",
					}, -- [1]
					{
						["name"] = "Focus",
						["icon"] = "ABILITY_WARRIOR_REVENGE",
						["index"] = 2,
						["body"] = "/focus target\n/focus [@mouseover,nodead,exists]\n",
					}, -- [2]
					{
						["name"] = "Glad",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 3,
						["body"] = "#showtooltip\n/use [flyable]Deadly Gladiator's Frost Wyrm\n/use [noflyable]Summon Thalassian Charger\n/dismount [mounted]\n",
					}, -- [3]
					{
						["name"] = "gr",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 4,
						["body"] = "#show [mod:ctrl] Rupture; Garrote\n/targetenemyplayer [notarget]\n/cast [nomod,nostealth] Shadow Dance\n/cast [nomod] Garrote; [mod:ctrl] Rupture\n/cast [mod:shift, target=focus] Garrote\n/use [stance:3] 13\n/cast [nomod] Premeditation;\n/startattack\n",
					}, -- [4]
					{
						["name"] = "HL",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 5,
						["body"] = "/cast [mod:alt,@Darkrizen][] Holy Light\n",
					}, -- [5]
					{
						["name"] = "LoD",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 6,
						["body"] = "/cast [nomod] Light of Dawn; [mod:shift] Divine Plea\n",
					}, -- [6]
					{
						["name"] = "MacroPoster",
						["icon"] = "ACHIEVEMENT_GUILDPERK_HASTYHEARTH",
						["index"] = 7,
						["body"] = "LF |cffffff00|Hachievement:2091:0300000008BE3783:1:4:21:9:0:0:0:0|h[Gladiator]|h|r DPS for an all glad RBG group\n",
					}, -- [7]
					{
						["name"] = "Mnt",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 8,
						["body"] = "#showtooltip\n/use [flyable]Ironbound Proto-Drake\n/use [noflyable]Summon Thalassian Charger\n/dismount [mounted]\n",
					}, -- [8]
					{
						["name"] = "NO!",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 9,
						["body"] = "/use Grievous Gladiator's Medallion of Meditation\n/w Darkrizen Dude quit standing out in the fucking open. WTF.\n",
					}, -- [9]
					{
						["name"] = "Party",
						["icon"] = "ACHIEVEMENT_GUILDPERK_HONORABLEMENTION_RANK2",
						["index"] = 10,
						["body"] = "/run PartyMemberFrame1:ClearAllPoints() PartyMemberFrame1:SetPoint(\"TOPLEFT\", 188, -250)\n/run PartyMemberFrame2:ClearAllPoints() PartyMemberFrame2:SetPoint(\"TOPLEFT\", 188, -170)\n/run PartyMemberFrame3:ClearAllPoints() PartyMemberFrame3:SetPoint(\"TOPLEFT\",\n",
					}, -- [10]
					{
						["name"] = "Reset",
						["icon"] = "INV_CHEST_PLATE15",
						["index"] = 11,
						["body"] = "/run for i=1,58 do _G[\"t\"..i]:Hide() end\n",
					}, -- [11]
					{
						["name"] = "sap",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 12,
						["body"] = "#show Sap\n/tar nearestenemy\n/cast [nostealth] Shadow Dance\n/cast [mod:shift, target=focus] Sap\n/cast [notarget, target=nearestenemy] Sap; Sap\n",
					}, -- [12]
					{
						["name"] = "trink",
						["icon"] = "INV_PET_CRANEGOD",
						["index"] = 13,
						["body"] = "#showtooltip 13\n/use 13\n/use 14\n/use 10\n",
					}, -- [13]
				},
				["d"] = "Mar 21 13:14:02",
				["n"] = "Paladin",
			}, -- [3]
			{
				["m"] = {
					{
						["name"] = "1",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 1,
						["body"] = "/use [@party1] Hand of Protection\n",
					}, -- [1]
					{
						["name"] = "1",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 2,
						["body"] = "/use [@party1] Hand of Freedom\n",
					}, -- [2]
					{
						["name"] = "2",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 3,
						["body"] = "/use [@party2] Hand of Freedom\n",
					}, -- [3]
					{
						["name"] = "2",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 4,
						["body"] = "/use [@party2] Hand of Protection\n",
					}, -- [4]
					{
						["name"] = "3",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 5,
						["body"] = "/cast [@party3] Hand of Freedom\n",
					}, -- [5]
					{
						["name"] = "3",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 6,
						["body"] = "/use [@party3] Hand of Protection\n",
					}, -- [6]
					{
						["name"] = "4",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 7,
						["body"] = "/cast [@party3] Hand of Freedom\n",
					}, -- [7]
					{
						["name"] = "4",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 8,
						["body"] = "/cast [@party4] Hand of Protection\n",
					}, -- [8]
					{
						["name"] = "d",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 9,
						["body"] = "/cast Disarm\n",
					}, -- [9]
					{
						["name"] = "dis m",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 10,
						["body"] = "/cast [@player] Cleanse\n",
					}, -- [10]
					{
						["name"] = "disp3",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 11,
						["body"] = "/cast [@party3] Cleanse\n",
					}, -- [11]
					{
						["name"] = "disp4",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 12,
						["body"] = "/cast [@party4] Cleanse\n",
					}, -- [12]
					{
						["name"] = "fear 1",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 13,
						["body"] = "/use [@arena1] Turn Evil\n",
					}, -- [13]
					{
						["name"] = "fear 2",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 14,
						["body"] = "/use [@arena2] Turn Evil\n",
					}, -- [14]
					{
						["name"] = "fear 3",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 15,
						["body"] = "/use [@arena3] Turn Evil\n",
					}, -- [15]
					{
						["name"] = "fear 4",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 16,
						["body"] = "/use [@arena4] Turn Evil\n",
					}, -- [16]
					{
						["name"] = "fear 5",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 17,
						["body"] = "/use [@arena5] Turn Evil\n",
					}, -- [17]
					{
						["name"] = "Focus",
						["icon"] = "ABILITY_WARRIOR_REVENGE",
						["index"] = 18,
						["body"] = "/targetenemy\n/focus target\n/focus [@mouseover,nodead,exists]\n",
					}, -- [18]
					{
						["name"] = "Glad",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 19,
						["body"] = "#showtooltip\n/use [flyable]Deadly Gladiator's Frost Wyrm\n/use [flyable]Ironbound Proto-Drake\n/use [noflyable]Summon Thalassian Charger;Dreadsteed;Pinto\n/dismount [mounted]\n",
					}, -- [19]
					{
						["name"] = "hoj 1",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 20,
						["body"] = "/use [@arena1] Hammer of Justice\n",
					}, -- [20]
					{
						["name"] = "hoj 2",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 21,
						["body"] = "/use [@arena2] Hammer of Justice\n",
					}, -- [21]
					{
						["name"] = "hoj 3",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 22,
						["body"] = "/use [@arena3] Hammer of Justice\n",
					}, -- [22]
					{
						["name"] = "hoj 4",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 23,
						["body"] = "/use [@arena4] Hammer of Justice\n",
					}, -- [23]
					{
						["name"] = "hoj 5",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 24,
						["body"] = "/use [@arena5] Hammer of Justice\n",
					}, -- [24]
					{
						["name"] = "MacroPoster",
						["icon"] = "ACHIEVEMENT_GUILDPERK_HASTYHEARTH",
						["index"] = 25,
						["body"] = "LF Hunter for 1700 cr 3's KFC\n",
					}, -- [25]
					{
						["name"] = "mnt",
						["icon"] = "ABILITY_MOUNT_RAZORSCALE",
						["index"] = 26,
						["body"] = "/use [flyable] Ironbound Proto-Drake\n/use Dreadsteed\n",
					}, -- [26]
					{
						["name"] = "p1",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 27,
						["body"] = "/tar party1\n/use Holy Shock\n/targetlasttarget\n/use Beacon of Light\n/tar party1\n",
					}, -- [27]
					{
						["name"] = "p2",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 28,
						["body"] = "/tar party2\n/use Holy Shock\n/targetlasttarget\n/use Beacon of Light\n/tar party2\n",
					}, -- [28]
					{
						["name"] = "p3",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 29,
						["body"] = "/tar party3\n/use Holy Shock\n/targetlasttarget\n/use Beacon of Light\n/tar party3\n",
					}, -- [29]
					{
						["name"] = "p4",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 30,
						["body"] = "/tar party4\n/use Holy Shock\n/targetlasttarget\n/use Beacon of Light\n/tar party4\n",
					}, -- [30]
					{
						["name"] = "sac1",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 31,
						["body"] = "#showtooltip\n/use [@party1] Hand of Sacrifice\n",
					}, -- [31]
					{
						["name"] = "sac2",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 32,
						["body"] = "#showtooltip\n/use [@party2] Hand of Sacrifice\n",
					}, -- [32]
					{
						["name"] = "sac3",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 33,
						["body"] = "#showtooltip\n/use [@party3] Hand of Sacrifice\n",
					}, -- [33]
					{
						["name"] = "sac4",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 34,
						["body"] = "#showtooltip\n/use [@party4] Hand of Sacrifice\n",
					}, -- [34]
					{
						["name"] = "Self",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 35,
						["body"] = "/cast [@player] Hand of Freedom\n",
					}, -- [35]
				},
				["d"] = "Apr 06 00:51:17",
				["n"] = "3s",
			}, -- [4]
			{
				["m"] = {
					{
						["name"] = "1",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 1,
						["body"] = "/use [@party1] Hand of Protection\n",
					}, -- [1]
					{
						["name"] = "1",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 2,
						["body"] = "/use [@party1] Hand of Freedom\n",
					}, -- [2]
					{
						["name"] = "2",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 3,
						["body"] = "/use [@party2] Hand of Freedom\n",
					}, -- [3]
					{
						["name"] = "2",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 4,
						["body"] = "/use [@party2] Hand of Protection\n",
					}, -- [4]
					{
						["name"] = "3",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 5,
						["body"] = "/cast [@party3] Hand of Freedom\n",
					}, -- [5]
					{
						["name"] = "3",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 6,
						["body"] = "/use [@party3] Hand of Protection\n",
					}, -- [6]
					{
						["name"] = "4",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 7,
						["body"] = "/cast [@party3] Hand of Freedom\n",
					}, -- [7]
					{
						["name"] = "4",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 8,
						["body"] = "/cast [@party4] Hand of Protection\n",
					}, -- [8]
					{
						["name"] = "d",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 9,
						["body"] = "/cast Disarm\n",
					}, -- [9]
					{
						["name"] = "dis m",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 10,
						["body"] = "/cast [@player] Cleanse\n",
					}, -- [10]
					{
						["name"] = "disp3",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 11,
						["body"] = "/cast [@party3] Cleanse\n",
					}, -- [11]
					{
						["name"] = "disp4",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 12,
						["body"] = "/cast [@party4] Cleanse\n",
					}, -- [12]
					{
						["name"] = "fear 1",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 13,
						["body"] = "/use [@arena1] Turn Evil\n",
					}, -- [13]
					{
						["name"] = "fear 2",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 14,
						["body"] = "/use [@arena2] Turn Evil\n",
					}, -- [14]
					{
						["name"] = "fear 3",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 15,
						["body"] = "/use [@arena3] Turn Evil\n",
					}, -- [15]
					{
						["name"] = "fear 4",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 16,
						["body"] = "/use [@arena4] Turn Evil\n",
					}, -- [16]
					{
						["name"] = "fear 5",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 17,
						["body"] = "/use [@arena5] Turn Evil\n",
					}, -- [17]
					{
						["name"] = "Focus",
						["icon"] = "ABILITY_WARRIOR_REVENGE",
						["index"] = 18,
						["body"] = "/targetenemy\n/focus target\n/focus [@mouseover,nodead,exists]\n",
					}, -- [18]
					{
						["name"] = "Glad",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 19,
						["body"] = "#showtooltip\n/use [flyable]Deadly Gladiator's Frost Wyrm\n/use [flyable]Ironbound Proto-Drake\n/use [noflyable]Summon Thalassian Charger;Dreadsteed;Pinto\n/dismount [mounted]\n",
					}, -- [19]
					{
						["name"] = "hoj 1",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 20,
						["body"] = "/use [@arena1] Hammer of Justice\n",
					}, -- [20]
					{
						["name"] = "hoj 2",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 21,
						["body"] = "/use [@arena2] Hammer of Justice\n",
					}, -- [21]
					{
						["name"] = "hoj 3",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 22,
						["body"] = "/use [@arena3] Hammer of Justice\n",
					}, -- [22]
					{
						["name"] = "hoj 4",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 23,
						["body"] = "/use [@arena4] Hammer of Justice\n",
					}, -- [23]
					{
						["name"] = "hoj 5",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 24,
						["body"] = "/use [@arena5] Hammer of Justice\n",
					}, -- [24]
					{
						["name"] = "MacroPoster",
						["icon"] = "ACHIEVEMENT_GUILDPERK_HASTYHEARTH",
						["index"] = 25,
						["body"] = "LF Hunter for 1700 cr 3's KFC\n",
					}, -- [25]
					{
						["name"] = "mnt",
						["icon"] = "ABILITY_MOUNT_RAZORSCALE",
						["index"] = 26,
						["body"] = "/use [flyable] Ironbound Proto-Drake\n/use Dreadsteed\n",
					}, -- [26]
					{
						["name"] = "p1",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 27,
						["body"] = "/tar party1\n/use Holy Shock\n/targetlasttarget\n/use Beacon of Light\n/tar party1\n",
					}, -- [27]
					{
						["name"] = "p2",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 28,
						["body"] = "/tar party2\n/use Holy Shock\n/targetlasttarget\n/use Beacon of Light\n/tar party2\n",
					}, -- [28]
					{
						["name"] = "p3",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 29,
						["body"] = "/tar party3\n/use Holy Shock\n/targetlasttarget\n/use Beacon of Light\n/tar party3\n",
					}, -- [29]
					{
						["name"] = "p4",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 30,
						["body"] = "/tar party4\n/use Holy Shock\n/targetlasttarget\n/use Beacon of Light\n/tar party4\n",
					}, -- [30]
					{
						["name"] = "sac1",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 31,
						["body"] = "#showtooltip\n/use [@party1] Hand of Sacrifice\n",
					}, -- [31]
					{
						["name"] = "sac2",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 32,
						["body"] = "#showtooltip\n/use [@party2] Hand of Sacrifice\n",
					}, -- [32]
					{
						["name"] = "sac3",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 33,
						["body"] = "#showtooltip\n/use [@party3] Hand of Sacrifice\n",
					}, -- [33]
					{
						["name"] = "sac4",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 34,
						["body"] = "#showtooltip\n/use [@party4] Hand of Sacrifice\n",
					}, -- [34]
					{
						["name"] = "Self",
						["icon"] = "INV_MISC_QUESTIONMARK",
						["index"] = 35,
						["body"] = "/cast [@player] Hand of Freedom\n",
					}, -- [35]
				},
				["d"] = "Apr 06 00:51:21",
				["n"] = "3s - Hpal",
			}, -- [5]
			{
				["m"] = {
					{
						["name"] = "1",
						["icon"] = "SPELL_HOLY_SEALOFSACRIFICE",
						["index"] = 1,
						["body"] = "/use [@party1] Hand of Sacrifice\n",
					}, -- [1]
					{
						["name"] = "2",
						["icon"] = "SPELL_HOLY_SEALOFSACRIFICE",
						["index"] = 2,
						["body"] = "#showtooltip\n/use [@party2] Hand of Sacrifice\n",
					}, -- [2]
					{
						["name"] = "BoP 3",
						["icon"] = "SPELL_HOLY_SEALOFPROTECTION",
						["index"] = 3,
						["body"] = "/use [@party3] Hand of Protection\n",
					}, -- [3]
					{
						["name"] = "BoP 4",
						["icon"] = "SPELL_HOLY_SEALOFPROTECTION",
						["index"] = 4,
						["body"] = "/use [@party4] Hand of Protection\n",
					}, -- [4]
					{
						["name"] = "den",
						["icon"] = "SPELL_HOLY_PURIFYINGPOWER",
						["index"] = 5,
						["body"] = "#showtooltip\n/targetenemy [noharm]\n/use [noharm][] Denounce\n/targetlasttarget [harm]\n",
					}, -- [5]
					{
						["name"] = "Disp",
						["icon"] = "SPELL_HOLY_PURIFY",
						["index"] = 6,
						["body"] = "/cast [@player] Cleanse\n",
					}, -- [6]
					{
						["name"] = "Disp 3",
						["icon"] = "SPELL_HOLY_PURIFY",
						["index"] = 7,
						["body"] = "/cast [@party3] Cleanse\n",
					}, -- [7]
					{
						["name"] = "Disp 4",
						["icon"] = "SPELL_HOLY_PURIFY",
						["index"] = 8,
						["body"] = "/cast [@party4] Cleanse\n",
					}, -- [8]
					{
						["name"] = "Focus",
						["icon"] = "ABILITY_WARRIOR_REVENGE",
						["index"] = 9,
						["body"] = "/targetenemy\n/focus target\n/focus [@mouseover,nodead,exists]\n",
					}, -- [9]
					{
						["name"] = "Glad",
						["icon"] = "ABILITY_MOUNT_REDFROSTWYRM_01",
						["index"] = 10,
						["body"] = "#showtooltip\n/use [flyable]Deadly Gladiator's Frost Wyrm\n/use [flyable]Ironbound Proto-Drake\n/use [noflyable]Summon Thalassian Charger;Dreadsteed;Pinto\n/dismount [mounted]\n",
					}, -- [10]
					{
						["name"] = "MacroPoster",
						["icon"] = "INV_HAMMER_03",
						["index"] = 11,
						["body"] = "",
					}, -- [11]
					{
						["name"] = "Party3",
						["icon"] = "ABILITY_PALADIN_BEACONOFLIGHT",
						["index"] = 12,
						["body"] = "#showtooltip\n/focus\n/tar Party2\n/castsequence reset=3 Beacon of Light, Cleanse\n/use [@focus] Beacon of Light\n",
					}, -- [12]
					{
						["name"] = "Party4",
						["icon"] = "ABILITY_PALADIN_BEACONOFLIGHT",
						["index"] = 13,
						["body"] = "#showtooltip\n/focus\n/tar Party4\n/castsequence reset=3 Beacon of Light, Cleanse\n/use [@focus] Beacon of Light\n",
					}, -- [13]
					{
						["name"] = "trink",
						["icon"] = "INV_MISC_TOKEN_ARGENTDAWN3",
						["index"] = 14,
						["body"] = "#showtooltip 13\n/use 13\n/use 14\n/use 10\n",
					}, -- [14]
				},
				["d"] = "Apr 20 22:24:59",
				["n"] = "Hpal",
			}, -- [6]
		},
	},
	["profiles"] = {
		["profile"] = {
			["replacemt"] = false,
			["y"] = 144.3996429443359,
			["x"] = 419.8399658203125,
			["height"] = 426.8800048828125,
			["visconditions"] = false,
		},
	},
}
