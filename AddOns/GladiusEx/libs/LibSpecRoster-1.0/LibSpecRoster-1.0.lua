-- LibSpecRoster
-- Project: LibSpecRoster-1.0, r23
-- File: LibSpecRoster-1.0.lua
-- Last Modified: 2013-11-19T09:58:11Z
-- Author: msaint (with thanks to Greltok for improvements and corrections -- though any lingering bugs are still mine)
-- Project desc: Efficiently maintains up to date raid spec information, inspecting
--               only when needed.


--  Library methods:
--    lib.RegisterMessage(yourObject, "messageName", yourMethod)
--    lib.UnregisterMessage(yourObject, "messageName")
--    lib.UnregisterAllMessages(yourObject)
--    lib.getInspectData(guid) - returns specName, specID, class, role, blizzRole, talents, glyphs
--    lib:getSpecialization(guid) - returns specName, specID, class -- class is the non-localized version, i.e. the second return value from UnitClass()
--    lib:getRole(guid) - returns role, blizzRole  -- role is one of "tank" | "healer" | "melee" | "ranged", blizzRole is one of "TANK" | "HEALER" | "DAMAGER"
--    lib:rescan(guid | nil) - reinspects the parameter guid  -- pass nil to reinspect all
--
--
--  Messages:
--    "LSR_Added" - params: eventName, guid, unit
--    "LSR_SpecializationChanged" - params: eventName, guid, unit, specID, talents, glyphs
--    "LSR_RoleChanged" - params: eventName, guid, unit, role
--    "LSR_TalentUpdate" - params: eventName, guid, unit, specID, talents, glyphs
--    "LSR_GlyphUpdate" - params: eventName, guid, unit, specID, talents, glyphs
--       -- Note that TalentUpdate and GlyphUpdate have the same params as SpecializationChanged, making it easy to consolidate handlers
--
--
-- **Caveat!!!**
--    Specialization changes, and thus role changes, are always detected for all group members.
--    BUT, talent changes and glyph changes done without changing between specs will not be
--    detected until the unit change specializations, UNLESS THEY ARE INSPECTED for some other
--    reason.  If you subscribe to talent or glyph updates, you can trigger a check by calling
--    :rescan(guid) or NotifyInspect(unit).  The inspect will be captured, and any changes
--    to talents or glyphs will trigger a callback.

-- Globals to ignore:
-- GLOBALS: DEFAULT_CHAT_FRAME, MAX_NUM_TALENT_TIERS, NUM_GLYPH_SLOTS, NotifyInspect

--[===[@debug@
local DEBUG = true
local debug = DEBUG and function(s) DEFAULT_CHAT_FRAME:AddMessage("LSR: "..s, 1, 0, 0) end or function() return end
MSO__inspectTally = (DEBUG and {}) or nil
--@end-debug@]===]

-- ***** Obtain the library object **********
local LIB_VERSION = tonumber("23") or 5000
local MAJOR, MINOR = "LibSpecRoster-1.0", LIB_VERSION
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end
local msg = LibStub("CallbackHandler-1.0"):New(lib, "RegisterMessage", "UnregisterMessage", "UnregisterAllMessages")

-- ***** LUA library functions made local **********
local math, max
      = math, math.max
local table, tinsert, tremove
      = table, tinsert, tremove
local pairs, ipairs, next, select, type, tostring
      = pairs, ipairs, next, select, type, tostring
local S = tostring

-- ***** API functions made local **********
local GetNumGroupMembers, IsInRaid, UnitGUID, UnitClass
      = GetNumGroupMembers, IsInRaid, UnitGUID, UnitClass
local UnitIsConnected, CanInspect
      = UnitIsConnected, CanInspect
local GetSpecializationInfoByID, GetInspectSpecialization, GetInspectTalent
      = GetSpecializationInfoByID, GetInspectSpecialization, GetInspectTalent
local GetGlyphSocketInfo, GetClassInfo, GetNumClasses
      = GetGlyphSocketInfo, GetClassInfo, GetNumClasses
local RegisterEvent, UnregisterAllEvents
      = RegisterEvent, UnregisterAllEvents

-- ***** Constants-ish **********
local updateDelay = 0.275 -- miliseconds between updates / talent requests
local notifyTimeout = 2.5 -- If requests don't come back in this time, requeue
local inspectsPerFive = 8 -- Throttle so that no more than this many requests go out in any five second period
local GOOD, INVALID, QUEUED, REQUEUE, REQUESTED, REQUESTED_GOOD = "GOOD", "INVALID", "QUEUED", "REQUEUE", "REQUESTED", "REQUESTED_GOOD"
local valid_status = {GOOD = true, INVALID = true, QUEUED = true, REQUEUE = true, REQUESTED = true} -- REQUESTED_GOOD is not here because you cannot ask for it with setStatus
local classID = {} -- Class IDs, filled by init
local specIDRoles = {
      -- Death Knight
      [250] = "tank", -- Blood
      [251] = "melee", -- Frost
      [252] = "melee", -- Unholy
      -- Druid
      [102] = "ranged", -- Balance
      [103] = "melee", -- Feral
      [104] = "tank", -- Guardian
      [105] = "healer", -- Restoration
      -- Hunter
      [253] = "ranged", -- Beast Mastery
      [254] = "ranged", -- Marksmanship
      [255] = "ranged", -- Survival
      -- Mage
      [62] = "ranged", -- Arcane
      [63] = "ranged", -- Fire
      [64] = "ranged", -- Frost
      -- Monk
      [268] = "tank", -- Brewmaster
      [269] = "melee", -- Windwalker
      [270] = "healer", -- Mistweaver
      -- Paladin
      [65] = "healer", -- Holy
      [66] = "tank", -- Protection
      [70] = "melee", -- Retribution
      -- Priest
      [256] = "healer", -- Discipline
      [257] = "healer", -- Holy
      [258] = "ranged", -- Shadow
      -- Rogue
      [259] = "melee", -- Assassination
      [260] = "melee", -- Combat
      [261] = "melee", -- Subtlety
      -- Shaman
      [262] = "ranged", -- Elemental
      [263] = "melee", -- Enhancement
      [264] = "healer", -- Restoration
      -- Warlock
      [265] = "ranged", -- Affliction
      [266] = "ranged", -- Demonology
      [267] = "ranged", -- Destruction
      -- Warrior
      [71] = "melee", -- Arms
      [72] = "melee", -- Fury
      [73] = "tank", -- Protection
   }

local fixedRoles = {
      HUNTER = "ranged",
      MAGE = "ranged",
      ROGUE = "melee",
      WARLOCK = "ranged",
   }

local fixedBlizzRoles = {
      HUNTER = "DAMAGER",
      MAGE = "DAMAGER",
      ROGUE = "DAMAGER",
      WARLOCK = "DAMAGER",
   }

-- ***** Local tables **********
local events = {} -- Used by event handlers and timers
local group = {} -- All raid members: group[guid] = {unitID, status, statusElapsed, class, specID, specName, oldSpecID, talents, oldTalents, glyphs, oldGlyphs}
                 -- group[].talents is an array of the form {[talentLine] = spellID | false} representing the selected talent at each tier
                 -- group[].glyphs is an array of the form {[glyphSlot] = {spellID = spellID, rank = 1 | 2} | false} where rank==1 is a major glyph, rank==2 is a minor glyph

-- ***** Local variables **********
local playerGUID -- Set in init() and used in setStatus()

-- ***** Event Frame Setup **********
local eFrame = _G["LibSpecRosterEventFrame"] or CreateFrame("Frame", "LibSpecRosterEventFrame", UIParent)
eFrame:SetScript("OnEvent", function(self, event, ...)
      if events[event] then
         events[event](events, ...)
      end
   end)
eFrame:RegisterEvent("PLAYER_ENTERING_WORLD") -- This is where we will initialize the library

-- ***** Local utility functions **********
local function shallowCopy(t)
   if t and type(t) == "table" then
      local t2 = {}
      for k, v in pairs(t) do
         t2[k] = v
      end
      return t2
   end
end

local function uniter()
-- use is: for i, unitID in uniter() do block end
-- i starts at 1 and corresponds to raid or party unit number.
-- For party (and solo), player is 'player' and is given last
   local raid, N = IsInRaid(), GetNumGroupMembers()
   N = N + ((N==0 or raid) and 1 or 0) -- The relation between index and reported size works differently for solo, party, and raid. Silly and confusing, but there it is.
   local iter = function(prefix, i)
      i = i + 1
      if (i < N) then
         return i, prefix..tostring(i)
      elseif (i == N and not raid) then
         return i, "player"
      else
         return nil
      end
   end
   return iter, (raid and "raid" or "party"), 0
end

local function buildRoster()
   local roster, guid = {}
   for i, unit in uniter() do
      guid = UnitGUID(unit)
      if guid then
         roster[guid] = unit
      else
         --[===[@debug@
         debug("Gah!! GUID was not available for "..S(unit)) --@end-debug@]===]
      end
   end
   return roster
end

local function getTalentTable(guid)
   local rec = group[guid]
   if rec then
      local unit = rec.unitID
      local talents = {}
      for i = 1, MAX_NUM_TALENT_TIERS do
         talents[i] = talents[i] or false -- GetInspectTalent returns nil for empty lines, but we don't want holes in our array!
         local line, spellID = GetInspectTalent(unit, i) -- Curiously, sometimes the index given is unrelated to the line in the talent tab, but 1 to 6 gets all lines
         if line then
            talents[line + 1] = spellID or false -- the line returned is zero indexed.  That's what happens when C programmers write lua api functions, eh?
         end
      end
      return (next(talents) and talents) or nil -- nil if no talents were found, it makes the result easier to use
   end
end

local function getGlyphTable(guid)
   local unit = ((guid ~= playerGUID) and group[guid].unitID) or nil -- "player" needs no params except index
   local glyphs = {}
   for i=1, NUM_GLYPH_SLOTS do
      local _, rank, _, spellID = GetGlyphSocketInfo(i, nil, not not unit, unit) -- note that arg3 must be the boolean 'true', not just evaluate to true.
      glyphs[i] = (spellID and { spellID = spellID, rank = rank }) or false -- False prevents holes in the array, but signals that the slot is empty
   end
   return (next(glyphs) and glyphs) or nil
end

local function talentsChanged(guid, isGlyphs)
   local rec = guid and group[guid]
   if rec then
      local t1, t2 = rec[((isGlyphs and "glyphs") or "talents")], rec[((isGlyphs and "oldGlyphs") or "oldTalents")]
      if t1 and next(t1) then
         if t2 and next(t2) then
            for i, d in ipairs(t1) do
               local v1, v2 = ((isGlyphs and d and d.spellID) or d), ((isGlyphs and t2[i] and t2[i].spellID) or t2[i])
               if (v1 ~= v2) then return true end
            end
         else -- We now have new data but no old data
            return true
         end
      end
   end
end
local function glyphsChanged(guid) return talentsChanged(guid, true) end

local function fireMessages(guid)
   local rec = guid and group[guid]
   if (rec.specID ~= rec.oldSpecID) then
      msg:Fire("LSR_SpecializationChanged", guid, rec.unitID, rec.specID, rec.talents, rec.glyphs)
      if specIDRoles[rec.oldSpecID] ~= specIDRoles[rec.specID] then
         msg:Fire("LSR_RoleChanged", guid, rec.unitID, specIDRoles[rec.specID])
      end
   end
   if talentsChanged(guid) then
      msg:Fire("LSR_TalentUpdate", guid, rec.unitID, rec.specID, rec.talents, rec.glyphs)
   end
   if glyphsChanged(guid) then
      msg:Fire("LSR_GlyphUpdate", guid, rec.unitID, rec.specID, rec.talents, rec.glyphs)
   end
end

local setStatus
do
   local lock
   setStatus = function (guid, status)
      if not (guid and status and valid_status[status]) then return end
      while lock do end -- This is not perfect, but also not as bad as it looks
      lock = true
      local rec, doFire = group[guid]
      if rec then
         local oldStat = rec.status
         rec.status = ((status == REQUESTED) and (oldStat == GOOD) and REQUESTED_GOOD) or ((status == INVALID) and (oldStat == REQUESTED_GOOD) and REQUESTED)
                     or (   (  ((status == INVALID) and (oldStat == GOOD)) or ( (status == GOOD) and ((oldStat ~= INVALID) or (guid == playerGUID)) )
                        or ( (oldStat ~= GOOD) and ((status == QUEUED) or (status == REQUEUE) or (status == REQUESTED)) )  ) and status   ) or oldStat
         rec.statusElapsed = (((rec.status == REQUESTED) or (rec.status == REQUESTED_GOOD)) and (((status ~= REQUESTED) and rec.statusElapsed) or 0)) or nil
      end
      lock = nil
      if (status == GOOD) and rec and (rec.status == GOOD) then
         fireMessages(guid)
      end
   end
end

local function setGUIDData(guid)
   local rec = group[guid]
   local specID, specName, _, _, _, blizzRole = GetSpecializationInfoByID(GetInspectSpecialization(rec.unitID))
   if specID and specID > 0 then
      rec.oldSpecID, rec.specID, rec.specName, rec.blizzRole = rec.specID, specID, specName, blizzRole
      rec.oldTalents, rec.talents, rec.oldGlyphs, rec.glyphs = rec.talents, getTalentTable(guid), rec.glyphs, getGlyphTable(guid)
      setStatus(guid, GOOD)
   end
end

-- ***** OnUpdate - Where it all happens! **********
local OnUpdate
local incrementThrottleCounter
do
   local sinceLast, queue = 0, {}

   local inspectThrottleCounter, throttleSinceLast, averageInspectInterval = 0, 0, (5 / inspectsPerFive) -- Let's not do this division every time
   incrementThrottleCounter = function()
      inspectThrottleCounter = inspectThrottleCounter + 1
   end
   local function throttleUpdate(elapsed)
      if inspectThrottleCounter <= 0 then
         inspectThrottleCounter, throttleSinceLast = 0, 0
      else
         throttleSinceLast = throttleSinceLast + elapsed
         if (throttleSinceLast >= averageInspectInterval) then
            throttleSinceLast = averageInspectInterval - throttleSinceLast
            inspectThrottleCounter = inspectThrottleCounter - 1
            --[===[@debug@
            if (inspectThrottleCounter < 0) or (inspectThrottleCounter > (inspectsPerFive + 1)) then
               debug("Ruh roh. throttleCounter is now "..tostring(inspectThrottleCounter))
            end --@end-debug@]===]
         end
      end
   end
   local function throttleInspect()
      return (inspectThrottleCounter >= inspectsPerFive)
   end

   OnUpdate = function (self, elapsed)
      throttleUpdate(elapsed)
      sinceLast = sinceLast + elapsed
      if (sinceLast >= updateDelay) then
         local bumpTime = sinceLast
         sinceLast = updateDelay - sinceLast -- REALLY do it every updateDelay ms
         for guid, rec in pairs(group) do
            local status = rec.status
            if (status == REQUESTED) or (status == REQUESTED_GOOD) then
               rec.statusElapsed = rec.statusElapsed + bumpTime
               if rec.statusElapsed > notifyTimeout then
                  setStatus(guid, ((status == REQUESTED_GOOD) and GOOD) or REQUEUE)
               end
            end
            if (rec.status == INVALID) or (rec.status == REQUEUE) then
               tinsert(queue, 1, guid)
               setStatus(guid, QUEUED)
            end
         end
         if not throttleInspect() then
            for i = #queue, 1, -1 do
               local guid = queue[i]
               local rec = group[guid]
               tremove(queue, i)
               if rec then
                  local unit = rec.unitID
                  if (rec.status == QUEUED) and unit and CanInspect(unit) then
                     if UnitIsConnected(unit) then
                        --[===[@debug@
                        debug("Sending NotifyInspect for "..unit) --@end-debug@]===]
                        if DEBUG then
                           local name = UnitName(unit)
                           MSO__inspectTally[name] = (MSO__inspectTally[name] or 0) + 1
                        end --@end-debug@
                        NotifyInspect(unit) -- REQUESTED status is set by our secure hook on NotifyInspect
                        break -- Only one request per requestThrottleDelay!
                     else-- CanInspect() is always true for group members, even if they are offline
                        setStatus(guid, REQUEUE)
                     end
                  end
               end
            end
         end
      end
   end
end

-- ***** Library initialization **********
local function init()
   -- Fill classID table with className = ID
   for i=1, GetNumClasses() do
      local _, name, id = GetClassInfo(i)
      classID[name] = id
   end
   playerGUID = UnitGUID("player") -- Why look it up more times?
   -- Create initial roster before handling events
   events:GROUP_ROSTER_UPDATE()
   eFrame:UnregisterAllEvents()
   for e, _ in pairs(events) do
      eFrame:RegisterEvent(e)
   end
   eFrame:Show()
end

function events:PLAYER_ENTERING_WORLD()
   -- Ridiculous hack here just because I want to index by GUID
   local sinceLast, delay = 0, updateDelay
   local function doWaitForGUIDs(self, elapsed)
      sinceLast = sinceLast + elapsed
      if sinceLast >= delay then
         for _, unit in uniter() do
            if not UnitGUID(unit) then
               sinceLast = 0
               return
            end
         end
         eFrame:Hide()
         eFrame:SetScript("OnUpdate", OnUpdate)
         init()
      end
   end
   eFrame:SetScript("OnUpdate", doWaitForGUIDs)
   eFrame:Show()
   events.PLAYER_ENTERING_WORLD = nil
end

-- ***** Event handlers **********
function events:GROUP_ROSTER_UPDATE()
   local newRoster = buildRoster()
   for guid, rec in pairs(group) do -- Discard or update existing entries in group
      if not newRoster[guid] then -- discard
         group[guid] = nil
      else -- same toon, new unitID: update and remove from newRoster
         rec.unitID = newRoster[guid]
         newRoster[guid] = nil
      end
   end
   for guid, unit in pairs(newRoster) do -- Any units still in newRoster must be added to group
      local unitClass = (select(2, UnitClass(unit)))
      if unitClass then
          group[guid] = {unitID = unit, class = unitClass, status = INVALID}
          msg:Fire("LSR_Added", guid, unit)
      end
   end
end

function events:PLAYER_SPECIALIZATION_CHANGED(unit)
   unit = unit or "player" -- This event sometimes leaves out unit for the player
   --[===[@debug@
   debug("PLAYER_SPECIALIZATION_CHANGED event for "..S(unit)) --@end-debug@]===]
   local guid = UnitGUID(unit)
   if guid and group[guid] then
      setStatus(guid, INVALID)
   end
end

function events:INSPECT_READY(guid)
   --[===[@debug@
   debug("INSPECT_READY received for "..S(guid)) --@end-debug@]===]
   local rec = guid and group[guid]
    if guid and group[guid] then
      setGUIDData(guid)
   end
end

function events:UNIT_NAME_UPDATE(unit)
   --[===[@debug@
   debug("UNIT_NAME_UPDATE event for "..S(unit)) --@end-debug@]===]
   self:GROUP_ROSTER_UPDATE()
end

-- ***** Hook to catch inspects from other addons and avoid duplicating them **********
local function notifyInspect(unit)
   local guid = UnitGUID(unit)
   if (guid and group[guid] and CanInspect(unit) and UnitIsConnected(unit)) then
      setStatus(guid, REQUESTED)
      incrementThrottleCounter()
	end
end
hooksecurefunc("NotifyInspect", notifyInspect)

-- ***** Exposed Library Methods **********
function lib:getInspectData(guid)
   local rec = guid and group[guid]
   if rec then
      return rec.specName, rec.specID, rec.class, ((rec.specID and specIDRoles[rec.specID]) or (rec.class and fixedRoles[rec.class])), (rec.blizzRole or (rec.class and fixedBlizzRoles[rec.class])), (rec.talents and shallowCopy(rec.talents)), (rec.glyphs and shallowCopy(rec.glyphs))
   end
end

function lib:getSpecialization(guid)
   local rec = guid and group[guid]
   if rec then
      return rec.specName, rec.specID, rec.class
   end
end

function lib:getRole(guid)
   local rec = guid and group[guid]
   if rec then
      return ((rec.specID and specIDRoles[rec.specID]) or (rec.class and fixedRoles[rec.class])), (rec.blizzRole or (rec.class and fixedBlizzRoles[rec.class]))
   end
end

function lib:rescan(guid)
   if guid then
      if group[guid] then
         setStatus(guid, INVALID)
      end
   else
      for guid in pairs(group) do
         setStatus(guid, INVALID)
      end
   end
end
