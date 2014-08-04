--
-- Global definitions for the KeybindTrainer addon
--

-- Main Scope Table --
KeybindTrainer = {
   -- SlotPool Object Ref
   -- Represents the state of the user's action slots.
   UserSlots        = SlotPool:New(),

   -- Parsed Trials
   Trials           = {},
   TrialDisplayList = {},
   
   -- Non-saved config vals
   Vals             = {},
   
   -- Config default values
   ValDefaults      = {
      -- Default duration, set to ~1 unhasted GCD
      KT_DurationInput   = 0.1,
      -- Default icon scale, set to 1
      KT_IconSizeSlider  = 1.0,
      -- Default trial.
      KT_SelectTrial     = "KT_basic",
      -- By default, show timer.
      KT_ShowTimer       = true,
      -- By default, randomize position.
      KT_RandomPosition  = true,
      -- By default, randomize order.
      KT_RandomOrder  = true,
      -- By default, save custom trials to SavedVariables.
      KT_SaveToProfile   = true,
      -- Turn on stats by default
      KT_SaveStats       = true,
      -- Turn on startup msg by default
      KT_ShowStartupMsg  = true,
      -- Show minimap icon by default
      KT_ShowMinimapIcon = true,
      -- Not continuous
      KT_Continuous      = false,
      -- Timers not shown
      KT_ShowTimer       = false,
      -- If Dominos/Bartender loaded, def them on
      KT_Dominos         = true,
      KT_Bartender       = true,
   }, 

   -- Constants
   Constants        = {
      -- Run with debug printouts on?
      DEBUG               = debug_print,
      
      -- Scroll lines moved on scroll in ScrollFrames
      SCROLL              = 1,

      -- Widget config/callback prefixes
      LOAD                = "load",
      CLICK               = "click",
      CREATE              = "create",

      -- Graph callbacks 
      GRAPH_TYPE          = "type",
      GRAPH_FIELD         = "field",
      GRAPH_FUNC          = "func",
      GRAPH_LINE          = "line",
      
      -- Display constants
      GRAPH_NUM_BARS      = 8,
      DEFAULT_ACTION_SIZE = 36,
      DEFAULT_TEXT_SIZE   = 10,
      DEFAULT_PAD_SIZE    = 40,
      DEFAULT_BAR_HEIGHT  = 35, -- For stats bars.
      
      -- Trial constants
      RANDOM              = "random", 
      GCD                 = 1.5,  -- default GCD value
      
      -- Button textures (loaded at trial start)
      RIGHT               = "Interface\\RAIDFRAME\\ReadyCheck-Ready" ,
      WRONG               = "Interface\\RAIDFRAME\\ReadyCheck-NotReady",
      NOBIND              = "Interface\\RAIDFRAME\\ReadyCheck-Waiting",
      NOTEX               = "Interface\\Icons\\INV_Misc_QuestionMark",
      
      -- Threshold on times before we toss it as an outlier (secs)
      BIND_TIME_THRESH    = 10,
      TRIAL_TIME_THRESH   = 3600,
      
      -- Delimiter on stat ids
      STAT_ID_DELIM       = "|",
      
      -- Limit on # of saved statistics
      STAT_SAMPLE_LIMIT   = 50,
      
      -- Statistic field ids.
      STAT_FIELDS = {
         NAME           = 1,
         INFO           = 2,
         LIST           = 3,
         LIST_SUMS      = 4,
         LIST_MAX       = 5,   
         
         -- Idx into STAT_LIST field entries
         LIST_TIME      = 1,
         LIST_MISS      = 2,
      },
   },

   -- The buttons, cooldowns, and overlays used to display actions.
   buttons          = {},
   cooldowns        = {},
   overlays         = {},

   -- List of all config widgets used to configure trials.
   widget_list      = {},

   -- List of widgets on the main screen
   main_widget_list = {},

   -- List of all statistics graph widgets for graph flipping.
   graph_list       = {},

   -- Ref to the minimap icon object
   minimap_icon     = nil,
}


--
-- References to SavedVariables
--

-- Custom Trials --
KT_CustomTrials       = { }

-- Statistics --
KT_Stats               = {
   -- Records
   actions = {
      -- ID -> { min, max, sum, num... }
   },
   trials  = {
      -- ID -> { min, max, sum, num, plot... }
   },
}

-- Config vals saved per-character --
KT_UIConfigVals       = { }

