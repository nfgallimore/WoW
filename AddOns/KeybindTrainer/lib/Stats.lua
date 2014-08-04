--
-- Functions implementing trial statistics.
--

-- Static upvalues
local Main     = KeybindTrainer;
local U        = FitzUtils;
local FL       = FitzUtilsFifoList;

-- For convenience
local L        = Main.Text;
local C        = Main.Constants;

-- Local Globals
local g_last_trial         = nil;


--
-- Stats Interface
--

-- Helper to create a stat record
function Main:CreateStatRecord(t, m)
   local s = {}
   s[C.STAT_FIELDS.LIST_TIME] = t
   s[C.STAT_FIELDS.LIST_MISS] = m
   return s
end

-- Helper to construct the stat id
function Main:CreateStatId(n, i)
   if not n then
      return "action"..C.STAT_ID_DELIM..i
   else
      return n..C.STAT_ID_DELIM..i
   end
end

-- Record stats for a Trial or Action object.  Note: OOP would be much
-- cleaner here, but because we want to be able to serialize this to user
-- saved variables, we define an interface on top of a giant global table.
function Main:RecordStats(obj)
   if not obj then return end
   local info_val   = ""
   local name       = ""
   local stats_ref  = nil
   local time, miss = obj:GetTime(), obj:GetMiss()
   local f          = C.STAT_FIELDS

   -- Threshold time to get rid of outliers, and set
   -- the info field--texture for action, ordering for trials.
   if obj:GetStatType() == "action" then
      -- Removed after testing, was just causing user confusion
      --if obj:GetTime() >= C.BIND_TIME_THRESH then return end
      info_val  = obj:GetTex()
      stats_ref = KT_Stats.actions
      name      = obj:GetMacroDisplayName() -- Nil unless this is a macro
   else
      -- Removed after testing, was just causing user confusion
      --if obj:GetTime() >= C.TRIAL_TIME_THRESH then return end
      info_val  = tostring(self:GetVar("KT_RandomOrder"))
      stats_ref = KT_Stats.trials
      name      = obj:GetName()
   end
   local id = self:CreateStatId(name, info_val)

   if not stats_ref[id] then 
      stats_ref[id] = {
         [f.NAME]      = name,
         [f.INFO]      = info_val,
         [f.LIST]      = FL:New(C.STAT_SAMPLE_LIMIT),
         [f.LIST_SUMS] = self:CreateStatRecord(0,0),
         [f.LIST_MAX]  = self:CreateStatRecord(0,0),
      }
   end

   -- Update sums
   local sums = stats_ref[id][f.LIST_SUMS]
   sums[f.LIST_TIME] = sums[f.LIST_TIME] + time
   sums[f.LIST_MISS] = sums[f.LIST_MISS] + miss

   -- Update max
   local maxs = stats_ref[id][f.LIST_MAX]
   maxs[f.LIST_TIME] = max(maxs[f.LIST_TIME], time)
   maxs[f.LIST_MISS] = max(maxs[f.LIST_MISS], miss) 

   -- Add a time/miss count record
   FL:Push(stats_ref[id][f.LIST],
           self:CreateStatRecord(time, miss))
end


--
-- Stats Display
--

-- Cruct the string describing the last trial.
function Main:GetTrialStatText(t)
   return string.format(L["Trial '%s' took %s secs with %s missed binds."],
                        t:GetName(), string.format("%.2f", t:GetTime()),
                        t:GetMiss())
end

-- Helpers
function KT_GetStatAvg(a, field)
   local f = C.STAT_FIELDS
   return (a[f.LIST_SUMS][field] / FL:Size(a[f.LIST]))
end   

function KT_GetStatLast(a, field)
   return FL:Tail(a[C.STAT_FIELDS.LIST])[field]
end
function KT_GetStatMax(a, field)
   return a[C.STAT_FIELDS.LIST_MAX][field]
end

-- Get a sorted list of stat_tyle -> stats list element reference
-- Unfortunately, creates a new table of references.
-- TODO: create table index of id into the stats arrays so that
-- they can be sorted in place without creating lots of tables.
function Main:GetSortedStatList(stat_type, val_type, op_func)
   local list = {}
   for id, stat in pairs(KT_Stats[stat_type]) do table.insert(list, stat) end
   table.sort(list, function(a, b)
                       return op_func(a, val_type) > op_func(b, val_type)
                    end)
   return list
end

-- Clear stats
function Main:ClearStats()
   KT_Stats.actions = {}
   KT_Stats.trials  = {}
end

-- Do we have any stats to display?
function Main:HasStats()
   return (#KT_Stats.actions > 0)
end

