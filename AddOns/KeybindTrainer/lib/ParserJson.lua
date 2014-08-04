--
-- Custom Trial parser, written to use json4lua.
--

-- Upvalues: Scope Tables
local Main       = KeybindTrainer;
local L          = Main.Text;
local U          = FitzUtils;

-- Imports
local json     = json
local string   = string
local table    = table
local pcall    = pcall
local ipairs   = ipairs
local type     = type
local tonumber = tonumber


-- For speed
local len      = string.utf8len

-- Module declaration
KT_Parser = {}

-- Module globals
local g_parse_input = nil
local g_parse_err   = nil


--
-- Local Helper Functions
--

-- Translate the eng-only json4lua errors into
-- localized error strings.
local function SetParseErr(err, input, from_lib)
   if not from_lib then -- JSON ok, format err
      g_parse_input = input
      g_parse_err   = err
      return
   end
   -- JSON error: parse and display debug info to user.
   g_parse_err   = L["Malformed input."]
   g_parse_input = string.match(err, "Context:%s*(.-)%s*%^$") or string.match(err, "boolean:%s*(.+)$")

   -- If we weren't able to get good error input, just
   -- assign the input string.
   g_parse_input = g_parse_input or input
end


--
-- Public Parser Interface
--

-- Clear Parser Error State
function KT_Parser.Init()
   g_parse_input = nil
   g_parse_err   = nil
end

-- Get localized parser error
function KT_Parser.GetErr()
   return g_parse_err, g_parse_input
end

-- Call into json4lua to parse the input string.
-- Check returned table contents, erroring where
-- necessary.  Return constructed trial.
function KT_Parser.Parse(trial_str)
   if len(trial_str) == 0 then 
      return SetParseErr(L["No input to parse!"], trial_str)
   end
   local status, data = pcall(json.decode, trial_str)
   if not status then return SetParseErr(data, trial_str, true) end

   -- Did we get a table?
   if type(data) ~= "table" then
      return SetParseErr(L["Input is in the wrong format."], trial_str)
   end

   -- Ensure we have binds to parse before creating trial.
   if not data.binds then
      return SetParseErr(L["Could not find valid Actions in input."], trial_str)
   end

   -- Create the trial object
   if not data.name or len(data.name) == 0 then
      return SetParseErr(L["Valid Trial name required."], trial_str)
   end
   local trial = Main:NewCustomTrial(data.name, data.desc, trial_str)
   if data.gcd ~= nil and type(data.gcd) ~= "number" and data.gcd ~= "random" then
      return SetParseErr(L["Could not parse trial gcd value.  Number or 'random' required."], data.gcd)
   end
   trial:SetDelay(data.gcd)

   -- Define function to process action tuples, done here
   -- to use upvalues to indicate error.
   local is_err = false
   local proc_func = function (action_tuple, action)
                        local cd = action.cd
                        if cd ~= nil and type(cd) ~= "number" then
                           is_err = true
                           return SetParseErr(L["Could not parse action cooldown value."],
                                              json.encode(action))
                        end
                        local name  = action.action
                        if name == nil then
                           is_err = true
                           return SetParseErr(L["Could not parse spell or item name."],
                                              json.encode(action))
                        end
                        action_tuple:AddAction(nil, name, cd)
                     end

   -- Process the action tuples
   for _,tuple in ipairs(data.binds) do
      local action_tuple = Main:NewActionTuple()
      if #tuple == 0 then -- single action
         proc_func(action_tuple, tuple)
      else                -- multi-action 
         for _,action in ipairs(tuple) do
            proc_func(action_tuple, action)
         end
      end
      if is_err then return nil end
      trial:AddActionTuple(action_tuple)
   end
   
   -- Done
   return trial
end
