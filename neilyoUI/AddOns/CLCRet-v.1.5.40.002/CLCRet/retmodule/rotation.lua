-- don't load if class is wrong
local _, class = UnitClass("player")
if class ~= "PALADIN" then return end

local _, xmod = ...

xmod.retmodule = {}
xmod = xmod.retmodule

local GetTime = GetTime
local db

-- debug if clcInfo detected
local debug
if clcInfo then debug = clcInfo.debug end

local ef = CreateFrame("Frame") 	-- event frame
ef:Hide()
local qTaint = true								-- will force queue check

xmod.version = 5000006
xmod.defaults = {
	version = xmod.version,
	
	prio = "inq tv5 how exo cs j tv3",
	rangePerSkill = false,
	inqRefresh = 5,
	inqApplyMin = 3,

	howclash = 0,  	-- priority time for hammer of wrath
	csclash = 0,		-- priority time for cs
	exoclash = 0, 	-- priority time for exorcism
	ssduration = 0, -- minimum duration on ss buff before suggesting refresh
}

-- @defines
--------------------------------------------------------------------------------
local gcdId 				= 85256 	-- tv for gcd
-- list of spellId
local inqId					= 84963		-- inquisition
local tvId					= 85256		-- templar's verdict
local exoId					= 879			-- exorcism
local mexoId				= 122032	-- mass exorcism
local howId 				=	24275		-- hammer of wrath
local csId 					= 35395		-- crusader strike
local dsId					= 53385		-- divine storm
local jId						= 20271		-- judgement
local esId					= 114157	-- execution sentence
local hprId					= 114165	-- holy prism
local lhId					= 114158	-- light's hammer
local ssId					=	20925		-- sacred shield
-- buffs
local buffInq 	= GetSpellInfo(inqId)		-- inquisition
local buffDP 		= GetSpellInfo(90174)		-- divine purpose
local buffHA		= GetSpellInfo(105809)	-- holy avenger
local buffAW    = GetSpellInfo(31884)		-- avenging wrath	
local buff4T15 	= GetSpellInfo(138169)  -- templar's verdict buff
local buff4T16	= GetSpellInfo(144595)	-- divine crusader

-- custom function to check ss since there are 2 buffs with same name
--local buffSS		= 65148
local buffSS = 20925

-- status vars
local s1, s2
local s_ctime, s_otime, s_gcd, s_hp, s_inq, s_dp, s_ha, s_aw, s_ss, s_4t15, s_4t16, s_haste, s_targetType
local s_exoId = exoId

-- the queue
local qn = {} 		-- normal queue
local q						-- working queue

local function GetCooldown(id)
	local start, duration = GetSpellCooldown(id)
	if start == nil then return 100 end
	local cd = start + duration - s_ctime - s_gcd
	if cd < 0 then return 0 end
	return cd
end

-- TODO	DP tests
-- actions ---------------------------------------------------------------------
local actions = {
	-- inq
	inq = {
		id = inqId,
		GetCD = function()
			if s_inq <= db.inqRefresh and s_hp >= db.inqApplyMin then
				return 0
			end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
			s_inq = 100 -- make sure it's not shown as next skill
			if s_dp <= 0 then
				s_hp = max(0, s_hp - 3)
			end
		end,
		info = "apply Inquisition"
	},
	inqdp = {
		id = inqId,
		GetCD = function()
			if s_inq <= db.inqRefresh and s_dp > 0.1 then
				return 0
			end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
			s_inq = 100 -- make sure it's not shown as next skill
			s_dp = 0
		end,
		info = "apply Inquisition when Divine Purpose procs",
	},
	tv5 = {
		id = tvId,
		GetCD = function()
			if (s_hp >= 5) or (s_hp >= 3 and s_ha > 0) then return 0 end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5
			if s_dp <= 0 then
				s_hp = max(0, s_hp - 3)
			end
		end,
		info = "Templar's Verdict HP >= 5",
	},
	tv4 = {
		id = tvId,
		GetCD = function()
			if (s_hp >= 4) or (s_hp >= 3 and s_ha > 0) then return 0 end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5
			if s_dp <= 0 then
				s_hp = max(0, s_hp - 3)
			end
		end,
		info = "Templar's Verdict HP >= 4",
	},
	tv4_4t15 = {
		id = tvId,
		GetCD = function()
			if ( ((s_hp >= 4) or (s_hp >= 3 and s_ha > 0)) and s_4t15 > 0) then return 0 end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5
			s_4t15 = 0
			if s_dp <= 0 then
				s_hp = max(0, s_hp - 3)
			end
		end,
		info = "Templar's Verdict HP >= 4 and 4 piece T15 buff active",
	},
	tv4aw = {
		id = tvId,
		GetCD = function()
			if ( ((s_hp >= 4) or (s_hp >= 3 and s_ha > 0)) and (s_aw > 0) ) then return 0 end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5
			if s_dp <= 0 then
				s_hp = max(0, s_hp - 3)
			end
		end,
		info = "Templar's Verdict HP >= 4 and Avenging Wrath up",
	},
	tv3 = {
		id = tvId,
		GetCD = function()
			if s_hp >= 3 then return 0 end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5
			if s_dp <= 0 then
				s_hp = max(0, s_hp - 3)
			end
		end,
		info = "Templar's Verdict HP >= 3",
	},
	tv3_4t15 = {
		id = tvId,
		GetCD = function()
			if ( s_hp >= 3 and s_4t15 > 0 ) then return 0 end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5
			s_4t15 = 0
			if s_dp <= 0 then
				s_hp = max(0, s_hp - 3)
			end
		end,
		info = "Templar's Verdict HP >= 3 and 4 piece T15 buff active",
	},
	tvdp = {
		id = tvId,
		GetCD = function()
			if s_dp > 0.1 then return 0 end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5
			s_dp = 0
		end,
		info = "Templar's Verdict when Divine Purpose procs"
	},
	tvaw = {
		id = tvId,
		GetCD = function()
			if (s_hp >= 3) and (s_aw > 0) then return 0 end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5
			if s_dp <= 0 then
				s_hp = max(0, s_hp - 3)
			end
		end,
		info = "Templar's Verdict HP >= 3 during Avenging Wrath",
	},
	exo = {
		id = exoId,
		GetCD = function()
			if s1 == s_exoId then
				return 100 -- lazy stuff
			else
				return max(0, GetCooldown(s_exoId) - db.exoclash)
			end
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
			if s_ha > 0 then
				s_hp = min(5, s_hp + 3)
			else
				s_hp = min(5, s_hp + 1)
			end
		end,
		info = "Exorcism",
	},
	exoaw = {
		id = exoId,
		GetCD = function()
			if (s1 ~= s_exoId) and (s_aw > 0) then
				return max(0, GetCooldown(s_exoId) - db.exoclash)
			end
			return 100 -- lazy stuff
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
			if s_ha > 0 then
				s_hp = min(5, s_hp + 3)
			else
				s_hp = min(5, s_hp + 1)
			end
		end,
		info = "Exorcism during Avenging Wrath",
	},
	how = {
		id = howId,
		GetCD = function()
			if IsUsableSpell(howId) and s1 ~= howId then
				return max(0, GetCooldown(howId) - db.howclash)
			end
			return 100 -- lazy stuff
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
			if s_ha > 0 then
				s_hp = min(5, s_hp + 3)
			else
				s_hp = min(5, s_hp + 1)
			end
		end,
		info = "Hammer of Wrath",
	},
	howaw = {
		id = howId,
		GetCD = function()
			if IsUsableSpell(howId) and (s1 ~= howId) and (s_aw > 0) then
				return max(0, GetCooldown(howId) - db.howclash)
			end
			return 100 -- lazy stuff
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
			if s_ha > 0 then
				s_hp = min(5, s_hp + 3)
			else
				s_hp = min(5, s_hp + 1)
			end
		end,
		info = "Hammer of Wrath during Avenging Wrath",
	},
	cs = {
		id = csId,
		GetCD = function()
			if s1 == csId then
				return max(0, (4.5 / s_haste - 1.5 - db.csclash))
			else
				return max(0, GetCooldown(csId) - db.csclash)
			end
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5
			if s_ha > 0 then
				s_hp = min(5, s_hp + 3)
			else
				s_hp = min(5, s_hp + 1)
			end
		end,
		info = "Crusader Strike",
	},
	cs_n4t15 = {
		id = csId,
		GetCD = function()
			if s_4t15 > 0 then return 100 end
			if s1 == csId then
				return max(0, (4.5 / s_haste - 1.5 - db.csclash))
			else
				return max(0, GetCooldown(csId) - db.csclash)
			end
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5
			if s_ha > 0 then
				s_hp = min(5, s_hp + 3)
			else
				s_hp = min(5, s_hp + 1)
			end
		end,
		info = "Crusader Strike without 4t15 buff",
	},
	j = {
		id = jId,
		GetCD = function()
			if s1 ~= jId then
				return GetCooldown(jId)
			end
			return 100 -- lazy stuff
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5
			if s_ha > 0 then
				s_hp = min(5, s_hp + 3)
			else
				s_hp = min(5, s_hp + 1)
			end
		end,
		info = "Judgement",
	},
	jhow = {
		id = jId,
		GetCD = function()
			if ( s1 ~= jId and IsUsableSpell(howId) ) then
				return GetCooldown(jId)
			end
			return 100 -- lazy stuff
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5
			if s_ha > 0 then
				s_hp = min(5, s_hp + 3)
			else
				s_hp = min(5, s_hp + 1)
			end
		end,
		info = "Judgement when Hammer of Wrath is usable",
	},
	jaw = {
		id = jId,
		GetCD = function()
			if ( (s1 ~= jId) and (s_aw > 0) ) then
				return GetCooldown(jId)
			end
			return 100 -- lazy stuff
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5
			if s_ha > 0 then
				s_hp = min(5, s_hp + 3)
			else
				s_hp = min(5, s_hp + 1)
			end
		end,
		info = "Judgement during Avenging Wrath",
	},
	es = {
		id = esId,
		GetCD = function()
			if s1 ~= esId then
				return GetCooldown(esId)
			end
			return 100 -- lazy stuff
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
		end,
		info = "Execution Sentence",
		reqTalent = 18,
	},
	inqes = {
		id = esId,
		GetCD = function()
			if s1 ~= esId and s_inq > 0 then
				return GetCooldown(esId)
			end
			return 100 -- lazy stuff
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
		end,
		info = "Execution Sentence with Inquistion active",
		reqTalent = 18,
	},
	hpr = {
		id = hprId,
		GetCD = function()
			if s1 ~= hprId then
				return GetCooldown(hprId)
			end
			return 100 -- lazy stuff
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
		end,
		info = "Holy Prism",
		reqTalent = 16,
	},
	inqhpr = {
		id = hprId,
		GetCD = function()
			if s1 ~= hprId and s_inq > 0 then
				return GetCooldown(hprId)
			end
			return 100 -- lazy stuff
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
		end,
		info = "Holy Prism with Inquisition active",
		reqTalent = 16,
	},
	lh = {
		id = lhId,
		GetCD = function()
			if s1 ~= lhId then
				return GetCooldown(lhId)
			end
			return 100 -- lazy stuff
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
		end,
		info = "Light's Hammer",
		reqTalent = 17,
	},
	inqlh = {
		id = lhId,
		GetCD = function()
			if s1 ~= lhId and s_inq > 0 then
				return GetCooldown(lhId)
			end
			return 100 -- lazy stuff
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
		end,
		info = "Light's Hammer with Inquisition active",
		reqTalent = 17,
	},
	ss = {
		id = ssId,
		GetCD = function()
			if s1 ~= ssId and s_ss <= db.ssduration then
				return 1.5 / s_haste	-- always return the time it would need to cast the skill so it doesn't overlap any dmg ability
			end
			return 100 -- lazy stuff
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste + 0.1 -- a bit of extra time to reduce flashing
			s_ss = 30
		end,
		info = "Sacred Shield",
		reqTalent = 9,
	},
	ds_4t16 = {
		id = dsId,
		GetCD = function()
			if ( s_4t16 > 0 ) then return 0 end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5
			s_4t16 = 0
		end,
		info = "Divine Storm with 4t16 active",
	},

	ds_4t16_5hp = {
		id = dsId,
		GetCD = function()
			if ( (s_4t16 > 0) and (s_hp >= 5) ) then return 0 end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5
			s_4t16 = 0
		end,
		info = "Divine Storm with 4t16 active and 5HP",
	},
}
--------------------------------------------------------------------------------

local function UpdateQueue()
	-- normal queue
	qn = {}
	for v in string.gmatch(db.prio, "[^ ]+") do
		if actions[v] then
			table.insert(qn, v)
		else
			print("clcretmodule - invalid action:", v)
		end
	end
	db.prio = table.concat(qn, " ")

	-- force reconstruction for q
	qTaint = true
end

local function GetBuff(buff)
	local left = 0
	local _, expires
	_, _, _, _, _, _, expires = UnitBuff("player", buff, nil, "PLAYER")
	if expires then
		left = max(0, expires - s_ctime - s_gcd)
	end
	return left
end

-- special case for SS
local function GetBuffSS()
	-- parse all buffs and look for id
	local i = 1
	local name, _, _, _, _, _, expires, _, _, _, spellId = UnitAura("player", i, "HELPFUL")
	while name do
		if spellId == buffSS then break end
		i = i + 1
		name, _, _, _, _, _, expires, _, _, _, spellId = UnitAura("player", i, "HELPFUL")
	end
	
	local left = 0
	if name and expires then
		left = max(0, expires - s_ctime - s_gcd)
	end
	s_ss = left
end

-- reads all the interesting data
local function GetStatus()
	-- current time
	s_ctime = GetTime()
	
	-- gcd value
	local start, duration = GetSpellCooldown(gcdId)
	s_gcd = start + duration - s_ctime
	if s_gcd < 0 then s_gcd = 0 end
	
	-- the buffs
	s_inq 	= GetBuff(buffInq)
	s_dp	= GetBuff(buffDP)
	s_ha	= GetBuff(buffHA)
	s_aw	= GetBuff(buffAW)
	s_4t16 	= GetBuff(buff4T16)


	-- special for ss
	GetBuffSS()

	-- 4piece t15 has no duration
	if UnitBuff("player", buff4T15) then
		s_4t15 = 100000
	else
		s_4t15 = 0
	end
	
	-- client hp and haste
	s_hp = UnitPower("player", SPELL_POWER_HOLY_POWER)
	s_haste = 1 + UnitSpellHaste("player") / 100
end

-- remove all talents not available and present in rotation
-- adjust for modified skills present in rotation
local function GetWorkingQueue()
	q = {}
	local name, selected, available
	for k, v in pairs(qn) do
		-- see if it has a talent requirement
		if actions[v].reqTalent then
			-- see if the talent is activated
			name, _, _, _, selected, available = GetTalentInfo(actions[v].reqTalent)
			if name and selected and available then
				table.insert(q, v)
			end
		else
			table.insert(q, v)
		end
	end

	-- adjust exo depending on glyph
	local glyphSpellId
	local mexo = false
	for i = 1, 3 do
		-- major glyphs are 2, 4, 6
		_, _, _, glyphSpellId = GetGlyphSocketInfo(i*2)
		if glyphSpellId == 122028 then
			mexo = true
			break
		end
	end

	if mexo then
		-- mass exorcism glyph detected
		-- switch spellid for actions
		actions["exo"].id = mexoId
		s_exoId = mexoId
	else
		actions["exo"].id = exoId
		s_exoId = exoId
	end
end

local function GetNextAction()
	-- check if working queue needs updated due to glyph talent changes
	if qTaint then
		GetWorkingQueue()
		qTaint = false
	end

	local n = #q
	
	-- parse once, get cooldowns, return first 0
	for i = 1, n do
		local action = actions[q[i]]
		local cd = action.GetCD()
		if debug and debug.enabled then
			debug:AddBoth(q[i], cd)
		end
		if cd == 0 then
			return action.id, q[i]
		end
		action.cd = cd
	end
	
	-- parse again, return min cooldown
	local minQ = 1
	local minCd = actions[q[1]].cd
	for i = 2, n do
		local action = actions[q[i]]
		if minCd > action.cd then
			minCd = action.cd
			minQ = i
		end
	end
	return actions[q[minQ]].id, q[minQ]
end

-- exposed functions

-- this function should be called from addons
function xmod.Init()
	db = xmod.db
	UpdateQueue()
end

function xmod.GetActions()
	return actions
end

function xmod.Update()
	UpdateQueue()
end

function xmod.Rotation()
	s1 = nil
	GetStatus()
	if debug and debug.enabled then
		debug:Clear()
		debug:AddBoth("ctime", s_ctime)
		debug:AddBoth("gcd", s_gcd)
		debug:AddBoth("hp", s_hp)
		debug:AddBoth("ha", s_ha)
		debug:AddBoth("inq", s_inq)
		debug:AddBoth("dp", s_dp)
		debug:AddBoth("haste", s_haste)
		debug:AddBoth("4t15", s_4t15)
	end
	local action
	s1, action = GetNextAction()
	if debug and debug.enabled then
		debug:AddBoth("s1", action)
	end
	-- 
	s_otime = s_ctime -- save it so we adjust buffs for next
	actions[action].UpdateStatus()
	
	-- adjust buffs
	s_otime = s_ctime - s_otime
	s_inq = max(0, s_inq - s_otime)
	s_dp = max(0, s_dp - s_otime)
	s_ha = max(0, s_ha - s_otime)
	s_ss = max(0, s_ss - s_otime)
	s_aw = max(0, s_aw - s_otime)
	s_4t16 = max(0, s_4t16 - s_otime)
	
	if debug and debug.enabled then
		debug:AddBoth("ctime", s_ctime)
		debug:AddBoth("otime", s_otime)
		debug:AddBoth("gcd", s_gcd)
		debug:AddBoth("hp", s_hp)
		debug:AddBoth("ha", s_ha)
		debug:AddBoth("inq", s_inq)
		debug:AddBoth("dp", s_dp)
		debug:AddBoth("haste", s_haste)
		debug:AddBoth("4t15", s_4t15)
	end
	s2, action = GetNextAction()
	if debug and debug.enabled then
		debug:AddBoth("s2", action)
	end

	return s1, s2
end

-- event frame
ef = CreateFrame("Frame")
ef:Hide()
ef:SetScript("OnEvent", function() qTaint = true end)
ef:RegisterEvent("PLAYER_TALENT_UPDATE")




