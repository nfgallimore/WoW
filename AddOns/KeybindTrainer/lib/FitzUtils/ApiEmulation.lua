--
-- Client API Emulation
--
-- Intended to be used for unit testing WoW addons.
--
-- !!WARNING!!  Do not include in any WoW addon .toc file.  !!WARNING!!
--
-- (c) Fitzcairn of Cenarion Circle
-- fitz.wowaddons@gmail.com


-- Include the utils file.
-- This will also error out the load if for some reason this is included
-- in a toc file inadvertently.
require('Util')
local U = FitzUtils;


--
-- Blizzard API Emulation
-- Stubs for required Blizzard API functions to allow for unit testing.
--

-- The global test state, populated by ResetClientTestState().
local g_test_state = {}

-- Data structure describing the state of our emulated wow client
-- This is used by the API emulation, and will be copied and modified
-- in unit tests to set up the test.
local g_test_state_template = {
   -- Slash commands
   SlashCmdList = {},

   -- User class
   user_class = "Rogue",

   -- Action bar state
   possess_bar_visible  = nil,
   curr_action_bar_page = 1,
   bonus_bar_offset     = 0,
   extra_bar_visibility = {
      BL  = nil,
      BR  = nil,
      RB  = nil,
      RB2 = nil, 
   },

   -- Spell list for tests.
   spell = {
      -- EXAMPLE:
      -- {
      --    id          = 1234,
      --    name        = "spell",
      --    rank        = "Rank 1",
      --    icon        = "/path/to/fake/icon",
      --    powerCost   = 50,
      --    isFunnel    = false,
      --    powerType   = 0,
      --    castingTime = 100,
      --    minRange    = 0,
      --    maxRange    = 5,
      -- },
   },

   -- Item list for tests
   item = {
      -- EXAMPLE:
      -- {
      --    id          = 1234,
      --    name        = "item",
      --    link        = "item:1234",
      --    quality     = 4,
      --    iLevel      = 232,
      --    reqLevel    = 80,
      --    class       = "Weapon",
      --    subclass    = "Guns",
      --    maxStack    = 1,
      --    equipSlot   = 15,
      --    icon        = "/path/to/fake/icon",
      --    vendorPrice = 1,
      -- },
   },

   -- Equipmentset list for tests.
   equipmentset = {
      -- EXAMPLE:
      -- {
      --    name  = "Set",
      --    icon  = "/path/to/fake/icon",
      --    setId = 1234,
      -- },
   },

   -- Macro list for tests.
   macro = {
      -- EXAMPLE:
      -- {
      --    name  = "test",
      --    icon  = "/path/to/fake/icon",
      --    body  = "/cast Spell",
      -- }
   },

   -- Bind table, populated from the bar state (below) by ResetClientTestState.
   binds = {
      -- Example: ACTIONBUTTON1 = {"bind", "bind", ...}
   },
   
   -- Action bar slot tables in order of slot ID.  Among other things,
   -- each slot has an action with a type and an id that references into
   -- the table for that tyle.  ResetClientTestState will populate _G
   -- with these.  Binds will be assigned in the test setup.
   bar = {
      { name = "ActionButton1",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON1",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton2",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON2",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton3",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON3",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton4",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON4",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton5",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON5",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton6",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON6",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton7",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON7",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton8",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON8",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton9",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON9",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton10",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON10",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton11",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON11",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton12",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON12",
        action = { type = "spell", id = "test" } },
      
      { name = "BonusActionButton1",  binds = {}, buttonType = "BONUSACTIONBUTTON", cmd = "BONUSACTIONBUTTON1",
        action = { type = "spell", id = "test" } },
      { name = "BonusActionButton2",  binds = {}, buttonType = "BONUSACTIONBUTTON", cmd = "BONUSACTIONBUTTON2",
        action = { type = "spell", id = "test" } },
      { name = "BonusActionButton3",  binds = {}, buttonType = "BONUSACTIONBUTTON", cmd = "BONUSACTIONBUTTON3",
        action = { type = "spell", id = "test" } },
      { name = "BonusActionButton4",  binds = {}, buttonType = "BONUSACTIONBUTTON", cmd = "BONUSACTIONBUTTON4",
        action = { type = "spell", id = "test" } },
      { name = "BonusActionButton5",  binds = {}, buttonType = "BONUSACTIONBUTTON", cmd = "BONUSACTIONBUTTON5",
        action = { type = "spell", id = "test" } },
      { name = "BonusActionButton6",  binds = {}, buttonType = "BONUSACTIONBUTTON", cmd = "BONUSACTIONBUTTON6",
        action = { type = "spell", id = "test" } },
      { name = "BonusActionButton7",  binds = {}, buttonType = "BONUSACTIONBUTTON", cmd = "BONUSACTIONBUTTON7",
        action = { type = "spell", id = "test" } },
      { name = "BonusActionButton8",  binds = {}, buttonType = "BONUSACTIONBUTTON", cmd = "BONUSACTIONBUTTON8",
        action = { type = "spell", id = "test" } },
      { name = "BonusActionButton9",  binds = {}, buttonType = "BONUSACTIONBUTTON", cmd = "BONUSACTIONBUTTON9",
        action = { type = "spell", id = "test" } },
      { name = "BonusActionButton10",  binds = {}, buttonType = "BONUSACTIONBUTTON", cmd = "BONUSACTIONBUTTON10",
        action = { type = "spell", id = "test" } },
      { name = "BonusActionButton11",  binds = {}, buttonType = "BONUSACTIONBUTTON", cmd = "BONUSACTIONBUTTON11",
        action = { type = "spell", id = "test" } },
      { name = "BonusActionButton12",  binds = {}, buttonType = "BONUSACTIONBUTTON", cmd = "BONUSACTIONBUTTON12",
        action = { type = "spell", id = "test" } },
      
      { name = "MultiBarRightButton1",  binds = {}, buttonType = "MULTIACTIONBAR3BUTTON", cmd = "MULTIACTIONBAR3BUTTON1",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarRightButton2",  binds = {}, buttonType = "MULTIACTIONBAR3BUTTON", cmd = "MULTIACTIONBAR3BUTTON2",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarRightButton3",  binds = {}, buttonType = "MULTIACTIONBAR3BUTTON", cmd = "MULTIACTIONBAR3BUTTON3",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarRightButton4",  binds = {}, buttonType = "MULTIACTIONBAR3BUTTON", cmd = "MULTIACTIONBAR3BUTTON4",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarRightButton5",  binds = {}, buttonType = "MULTIACTIONBAR3BUTTON", cmd = "MULTIACTIONBAR3BUTTON5",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarRightButton6",  binds = {}, buttonType = "MULTIACTIONBAR3BUTTON", cmd = "MULTIACTIONBAR3BUTTON6",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarRightButton7",  binds = {}, buttonType = "MULTIACTIONBAR3BUTTON", cmd = "MULTIACTIONBAR3BUTTON7",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarRightButton8",  binds = {}, buttonType = "MULTIACTIONBAR3BUTTON", cmd = "MULTIACTIONBAR3BUTTON8",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarRightButton9",  binds = {}, buttonType = "MULTIACTIONBAR3BUTTON", cmd = "MULTIACTIONBAR3BUTTON9",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarRightButton10",  binds = {}, buttonType = "MULTIACTIONBAR3BUTTON", cmd = "MULTIACTIONBAR3BUTTON10",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarRightButton11",  binds = {}, buttonType = "MULTIACTIONBAR3BUTTON", cmd = "MULTIACTIONBAR3BUTTON11",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarRightButton12",  binds = {}, buttonType = "MULTIACTIONBAR3BUTTON", cmd = "MULTIACTIONBAR3BUTTON12",
        action = { type = "spell", id = "test" } },
      
      { name = "MultiBarLeftButton1",  binds = {}, buttonType = "MULTIACTIONBAR4BUTTON", cmd = "MULTIACTIONBAR4BUTTON1",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarLeftButton2",  binds = {}, buttonType = "MULTIACTIONBAR4BUTTON", cmd = "MULTIACTIONBAR4BUTTON2",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarLeftButton3",  binds = {}, buttonType = "MULTIACTIONBAR4BUTTON", cmd = "MULTIACTIONBAR4BUTTON3",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarLeftButton4",  binds = {}, buttonType = "MULTIACTIONBAR4BUTTON", cmd = "MULTIACTIONBAR4BUTTON4",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarLeftButton5",  binds = {}, buttonType = "MULTIACTIONBAR4BUTTON", cmd = "MULTIACTIONBAR4BUTTON5",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarLeftButton6",  binds = {}, buttonType = "MULTIACTIONBAR4BUTTON", cmd = "MULTIACTIONBAR4BUTTON6",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarLeftButton7",  binds = {}, buttonType = "MULTIACTIONBAR4BUTTON", cmd = "MULTIACTIONBAR4BUTTON7",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarLeftButton8",  binds = {}, buttonType = "MULTIACTIONBAR4BUTTON", cmd = "MULTIACTIONBAR4BUTTON8",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarLeftButton9",  binds = {}, buttonType = "MULTIACTIONBAR4BUTTON", cmd = "MULTIACTIONBAR4BUTTON9",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarLeftButton10",  binds = {}, buttonType = "MULTIACTIONBAR4BUTTON", cmd = "MULTIACTIONBAR4BUTTON10",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarLeftButton11",  binds = {}, buttonType = "MULTIACTIONBAR4BUTTON", cmd = "MULTIACTIONBAR4BUTTON11",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarLeftButton12",  binds = {}, buttonType = "MULTIACTIONBAR4BUTTON", cmd = "MULTIACTIONBAR4BUTTON12",
        action = { type = "spell", id = "test" } },
      
      { name = "MultiBarBottomRightButton1",  binds = {}, buttonType = "MULTIACTIONBAR2BUTTON", cmd = "MULTIACTIONBAR2BUTTON1",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomRightButton2",  binds = {}, buttonType = "MULTIACTIONBAR2BUTTON", cmd = "MULTIACTIONBAR2BUTTON2",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomRightButton3",  binds = {}, buttonType = "MULTIACTIONBAR2BUTTON", cmd = "MULTIACTIONBAR2BUTTON3",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomRightButton4",  binds = {}, buttonType = "MULTIACTIONBAR2BUTTON", cmd = "MULTIACTIONBAR2BUTTON4",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomRightButton5",  binds = {}, buttonType = "MULTIACTIONBAR2BUTTON", cmd = "MULTIACTIONBAR2BUTTON5",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomRightButton6",  binds = {}, buttonType = "MULTIACTIONBAR2BUTTON", cmd = "MULTIACTIONBAR2BUTTON6",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomRightButton7",  binds = {}, buttonType = "MULTIACTIONBAR2BUTTON", cmd = "MULTIACTIONBAR2BUTTON7",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomRightButton8",  binds = {}, buttonType = "MULTIACTIONBAR2BUTTON", cmd = "MULTIACTIONBAR2BUTTON8",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomRightButton9",  binds = {}, buttonType = "MULTIACTIONBAR2BUTTON", cmd = "MULTIACTIONBAR2BUTTON9",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomRightButton10",  binds = {}, buttonType = "MULTIACTIONBAR2BUTTON", cmd = "MULTIACTIONBAR2BUTTON10",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomRightButton11",  binds = {}, buttonType = "MULTIACTIONBAR2BUTTON", cmd = "MULTIACTIONBAR2BUTTON11",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomRightButton12",  binds = {}, buttonType = "MULTIACTIONBAR2BUTTON", cmd = "MULTIACTIONBAR2BUTTON12",
        action = { type = "spell", id = "test" } },
      
      { name = "MultiBarBottomLeftButton1",  binds = {}, buttonType = "MULTIACTIONBAR1BUTTON", cmd = "MULTIACTIONBAR1BUTTON1",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomLeftButton2",  binds = {}, buttonType = "MULTIACTIONBAR1BUTTON", cmd = "MULTIACTIONBAR1BUTTON2",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomLeftButton3",  binds = {}, buttonType = "MULTIACTIONBAR1BUTTON", cmd = "MULTIACTIONBAR1BUTTON3",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomLeftButton4",  binds = {}, buttonType = "MULTIACTIONBAR1BUTTON", cmd = "MULTIACTIONBAR1BUTTON4",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomLeftButton5",  binds = {}, buttonType = "MULTIACTIONBAR1BUTTON", cmd = "MULTIACTIONBAR1BUTTON5",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomLeftButton6",  binds = {}, buttonType = "MULTIACTIONBAR1BUTTON", cmd = "MULTIACTIONBAR1BUTTON6",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomLeftButton7",  binds = {}, buttonType = "MULTIACTIONBAR1BUTTON", cmd = "MULTIACTIONBAR1BUTTON7",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomLeftButton8",  binds = {}, buttonType = "MULTIACTIONBAR1BUTTON", cmd = "MULTIACTIONBAR1BUTTON8",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomLeftButton9",  binds = {}, buttonType = "MULTIACTIONBAR1BUTTON", cmd = "MULTIACTIONBAR1BUTTON9",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomLeftButton10",  binds = {}, buttonType = "MULTIACTIONBAR1BUTTON", cmd = "MULTIACTIONBAR1BUTTON10",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomLeftButton11",  binds = {}, buttonType = "MULTIACTIONBAR1BUTTON", cmd = "MULTIACTIONBAR1BUTTON11",
        action = { type = "spell", id = "test" } },
      { name = "MultiBarBottomLeftButton12",  binds = {}, buttonType = "MULTIACTIONBAR1BUTTON", cmd = "MULTIACTIONBAR1BUTTON12",
        action = { type = "spell", id = "test" } },

      { name = "ActionButton1",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON1",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton2",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON2",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton3",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON3",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton4",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON4",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton5",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON5",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton6",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON6",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton7",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON7",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton8",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON8",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton9",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON9",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton10",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON10",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton11",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON11",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton12",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON12",
        action = { type = "spell", id = "test" } },
      
      { name = "ActionButton1",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON1",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton2",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON2",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton3",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON3",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton4",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON4",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton5",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON5",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton6",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON6",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton7",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON7",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton8",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON8",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton9",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON9",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton10",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON10",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton11",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON11",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton12",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON12",
        action = { type = "spell", id = "test" } },
      
      { name = "ActionButton1",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON1",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton2",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON2",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton3",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON3",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton4",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON4",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton5",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON5",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton6",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON6",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton7",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON7",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton8",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON8",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton9",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON9",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton10",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON10",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton11",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON11",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton12",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON12",
        action = { type = "spell", id = "test" } },
      
      { name = "ActionButton1",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON1",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton2",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON2",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton3",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON3",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton4",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON4",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton5",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON5",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton6",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON6",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton7",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON7",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton8",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON8",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton9",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON9",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton10",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON10",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton11",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON11",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton12",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON12",
        action = { type = "spell", id = "test" } },
      
      { name = "ActionButton1",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON1",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton2",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON2",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton3",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON3",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton4",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON4",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton5",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON5",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton6",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON6",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton7",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON7",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton8",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON8",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton9",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON9",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton10",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON10",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton11",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON11",
        action = { type = "spell", id = "test" } },
      { name = "ActionButton12",  binds = {}, buttonType = "ACTIONBUTTON", cmd = "ACTIONBUTTON12",
        action = { type = "spell", id = "test" } },
   }
}   
-- API emulations.
function IsPossessBarVisible()
   return g_test_state.possess_bar_visible
end

function GetActionBarPage()
   return g_test_state.curr_action_bar_page
end

function GetActionBarToggles()
   local s = g_test_state.extra_bar_visibility
   return s.BL, s.BR, s.RB, s.RB2
end

function GetBonusBarOffset()
   return g_test_state.bonus_bar_offset
end

-- [4.0.1] This now returns type, spell_id, sub_type instead of 
-- type, id, sub_type, spell_id
function GetActionInfo(slot)
   local type, id, subType = nil, nil, nil, nil
   if g_test_state.bar[slot] then
      local a = g_test_state.bar[slot].action
      if g_test_state[a.type][a.id] then
         if a.type == "spell" then
            type, id, subType = a.type, g_test_state.spell[a.id].id, a.type
         else
            type, id, subType = a.type, a.id, nil
         end

         -- TODO: add emulation for companions and mounts.

      end
   end
   return type, id, subType, spellID
end

function GetActionTexture(slot)
   local tex = nil
   if g_test_state.bar[slot] then
      local a = g_test_state.bar[slot].action
      if g_test_state[a.type][a.id] then
         tex = g_test_state[a.type][a.id].icon
      end
   end
   return tex
end

function GetBindingKey(cmd)
   if not g_test_state.binds[cmd] then return "" end
   return unpack(g_test_state.binds[cmd].binds)
end

function GetEquipmentSetInfo(index)
   local name, icon, setID = nil, nil, nil
   if g_test_state.equipmentset[index] then
      local e = g_test_state.equipmentset[index]
      name, icon, setID = e.name, e.icon, nil
   end
   return name, icon, setID
end

function GetItemInfo(item)
   local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, icon, vendorPrice = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
   if g_test_state.item[item] then
      i = g_test_state.item[item]
      name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, icon, vendorPrice = i.name, i.link, i.quality, i.iLevel, i.reqLevel, i.class, i.subclass, i.maxStack, i.equipSlot, i.icon, i.vendorPrice
   end
   return name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, icon, vendorPrice
end

function GetMacroInfo(id)
   local name, icon, body = nil, nil, nil
   if g_test_state.macro[id] then
      local m = g_test_state.macro[id]
      name, icon, body = m.name, m.icon, m.body
   end
   return name, icon, body
end

function GetSpellInfo(spell)
   local name, rank, icon, powerCost, isFunnel, powerType, castingTime, minRange, maxRange = nil, nil, nil, nil, nil, nil, nil, nil, nil
   if g_test_state.spell[spell] then
      s = g_test_state.spell[spell] 
      name, rank, icon, powerCost, isFunnel, powerType, castingTime, minRange, maxRange = s.name, s.rank, s.icon, s.powerCost, s.isFunnel, s.powerType, s.castingTime, s.minRange, s.maxRange
   end
   return name, rank, icon, powerCost, isFunnel, powerType, castingTime, minRange, maxRange
end

function GetSpellTexture(name)
   local t, _ = select(3, GetSpellInfo(name))
   return t
end

function GetLocale()
   return "US"
end


function GetNumShapeshiftForms()
   return 4
end

function UnitClass()
   return g_test_state.class
end

-- Available in wow's lua version.
function strtrim(str) 
   str = string.match(str, '^%s*(.-)%s*$')
   return str
end

-- Create SlashCmdList so the libraries will load.
-- This will be overridden in unit tests later.
SlashCmdList = {}


--
-- Non-WoW API Emulation
--

-- Define LibStub so the ACE libraries can load.
function LibStub(...)
   return {
      NewDataObject = function(...) return end
   }
end


--
-- Emulation API Helpers
--

-- Reset the test state back to the original defined above,
-- creating a copy for modification and letting whatever was
-- set.
function ResetClientTestState()
   g_test_state = U:DeepCopy(g_test_state_template)

   -- Add the bar slots into _G to emulate WoW's env.
   for _,b in ipairs(g_test_state.bar) do
      _G[b.name] = b
   end

   return g_test_state
end

-- Add a spell/item/equipmentset/macro to the test state.
function AddTestAction(type, id, name, icon)
   assert(g_test_state[type])
   assert(id ~= nil and name)
   if not icon then icon = name end
   link = type..":"..name

   local action = g_test_state[type][id] or {}
   action.id   = id
   action.name = name
   action.link = link
   action.icon = icon
   g_test_state[type][id] = action
end

-- Add a spell/item/equipmentset/macro to a slot.
function AddTestActionToSlot(slot, type, id)
   assert(g_test_state.bar[slot]) -- ok slot
   assert(g_test_state[type][id]) -- ok action
   local b = g_test_state.bar[slot].action
   b.type  = type
   b.id    = id
end

-- Add one or more a keybinds for a slot.
function AddTestKeybind(replace, slot, ...)
   assert(g_test_state.bar[slot])
   local b = g_test_state.bar[slot]
   local binds = {...}

   if replace then
      b.binds = binds
   else 
      for _,bind in ipairs(binds) do
         table.insert(b.binds, bind)
      end
   end
   g_test_state.binds[b.cmd] = b
end

-- Set the unit class
function TestSetUnitClass(class)
   g_test_state.unit_class = class
end
