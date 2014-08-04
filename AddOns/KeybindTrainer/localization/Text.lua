-- Core Localization for KeybindTrainer
--
-- By default, US English is used.  For translations, redefine
-- variables in the appropriate "GetLocale" block.
--

-- Upvalues
local Main = KeybindTrainer


-- English (default)
-- No need to define translations, set __index to return index string.
-- Usage example: Main.Text["This is some text"] returns "This is some text"
Main.Text = setmetatable({ }, { __index = function(loc_table, str) return str end })

-- Set Help HTML for this locale
Main.HelpDialogText      = KT_Help_US_En


-- German (example)
-- Usage example: KV.L["good"] returns "gut"
if (GetLocale() == "deDE") then 
   Main.Text = {
      -- Translations here.
      ["good"] = "gut",
   }

   -- Set Help HTML for this locale
   Main.HelpDialogText      = KT_Help_DE
end


