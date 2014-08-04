--
-- Localization for the BindManager library.
--

ActionBindManagerText = setmetatable({ }, { __index = function(loc_table, str) return str end })

-- German (example)
-- Usage example: KV.L["good"] returns "gut"
if (GetLocale() == "deDE") then 
   ActionBindManagerText = {
      -- Translations here.
      ["good"] = "gut",
   }
end



