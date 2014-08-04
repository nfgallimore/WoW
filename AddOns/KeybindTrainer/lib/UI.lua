--
-- UI Widget Layout
-- 
-- Defines widget-specific text and callbacks for UI objects set up using
-- methods defined in lib/Config.lua
--

-- Upvalues
local Main       = KeybindTrainer;
local ABM        = ActionBindManager;

-- For convenience
local C          = Main.Constants;
local L          = Main.Text;
local Trials     = Main.Trials;
local TrialList  = Main.TrialDisplayList;


--
-- Shared Callback Functions
--

-- Checkbox: OnLoad handler to restore state.
local function CbOnLoad(cb, checked)
   if checked then
      cb:SetChecked()
   end
end

-- Widget Create: register widget
local function WidgetOnCreate(...)
   local w
   for i = 1, select('#', ...) do
      w = select(i, ...)
      Main:RegisterWidget(w)      
   end
end

-- Widget Create: register widget, and also register for disable
-- on trial start.
local function WidgetOnCreateTrialDisable(...)
   local w
   for i = 1, select('#', ...) do
      w = select(i, ...)
      Main:RegisterWidget(w)
      Main:RegisterWidget(w, Main.main_widget_list)
   end
end


--
-- Config for all UI widgets.
--

Main.UI = {
   KT_Frame = {
      title   = L["KeybindTrainer"],
      version = "1.01",
   },
   KT_MinimapIcon = {
      text   = L["KeybindTrainer"],
      tt_off = L["Click to show KeybindTrainer"],
      tt_on  = L["Click to hide KeybindTrainer"],
   },
   KT_SelectTrialMenu = {
      KT_SelectTrial = {
         tt      = L["Select what KeybindTrainer trial to run."],
         label   = L["Trial:"],
         help    = "",
         options = {
            trial_def_title = {
               text         = L["Default Trials"],
            },
            trial_all = {
               text         = L["All Action Binds"],
               tooltipTitle = L["All Action Binds"],
               tooltipText  = L["Iterate through all binds for all action bars."],
            },
            trial_visible = {
               text         = L["All Visible Action Binds"],
               tooltipTitle = L["All Visible Action Binds"],
               tooltipText  = L["Iterate through all binds actions KeybindTrainer thinks are currently visible to the player."],
            },
            trial_dominos = {
               text         = L["All Blizzard + Dominos Binds"],
               tooltipTitle = L["All Action Binds, Including Dominos"],
               tooltipText  = L["Iterate through all binds set through Blizzard and the Dominos action bar mod."],
            },
            trial_bartender = {
               text         = L["All Blizzard + Bartender4 Binds"],
               tooltipTitle = L["All Action Binds, Including Bartender"],
               tooltipText  = L["Iterate through all binds set through Blizzard and the Bartender4 action bar mod."],
            },
            trial_battle = {
               text         = L["Warrior: Battle Stance Binds"],
               tooltipTitle = L["Battle Stance Keybinds"],
               tooltipText  = L["Iterate through all binds for action slots displayed when you enter Battle Stance."],
            },
            trial_berserker = {
               text         = L["Warrior: Berserker Stance Binds"],
               tooltipTitle = L["Berserker Stance Keybinds"],
               tooltipText  = L["Iterate through all binds for action slots displayed when you enter Berserker Stance."],
            },
            trial_defensive = {
               text         = L["Warrior: Defensive Stance Binds"],
               tooltipTitle = L["Defensive Stance Keybinds"],
               tooltipText  = L["Iterate through all binds for action slots displayed when you enter Defensive Stance."],
            },
            trial_cat = {
               text         = L["Druid: Cat Form Binds"],
               tooltipTitle = L["Cat Form Keybinds"],
               tooltipText  = L["Iterate through all binds for action slots displayed when you enter Cat Form."],
            },

            -- In 4.0.3a the prowl bar functionality changed.  Temporarily
            -- disabling this trial.
            --trial_prowl = {
            -- text         = L["Druid: Prowl Binds"],
            --   tooltipTitle = L["Cat Form Prowl Keybinds"],
            --   tooltipText  = L["Iterate through all binds for action slots displayed when you enter stealth (Prowl) in Cat Form."],
            --},

            trial_bear = {
               text         = L["Druid: Bear Form Binds"],
               tooltipTitle = L["Bear Form Keybinds"],
               tooltipText  = L["Iterate through all binds for action slots displayed when you enter Bear Form."],
            },
            trial_moonkin = {
               text         = L["Druid: Moonkin Form Binds"],
               tooltipTitle = L["Moonkin Form Keybinds"],
               tooltipText  = L["Iterate through all binds for action slots displayed when you enter Moonkin Form."],
            },
            trial_rogue = {
               text         = L["Rogue: Stealth Binds"],
               tooltipTitle = L["Stealth Keybinds"],
               tooltipText  = L["Iterate through all binds on your Stealth bar."],
            },
            trial_priest = {
               text         = L["Priest: Shadowform Binds"],
               tooltipTitle = L["Shadowform Keybinds"],
               tooltipText  = L["Iterate through all binds on your Shadowform bar."],
            },
            trial_cust_title = {
               text         = L["Custom Trials"],
            },
         },

         -- Load trial menu.
         [C.LOAD] = function (menu)
                       local menu_name = menu:GetName()
                       local cfg_block = menu:GetParent():GetName()
                       menu._menu_id = 1
                       
                       -- If trials aren't loaded yet, nothing to do here.
                       if not Trials then return end
                       
                       -- Get the latest trial display info for default trials
                       Main:RefreshTrialDisplayList()

                       -- Get a ref to the localized menu options.
                       local opt_table_txt = Main.UI[cfg_block][menu_name].options
                       if not opt_table_txt then return end
                       
                       -- Add the predefined trials
                       Main:AddMenuButton(menu, "trial_def_title", true,
                                          opt_table_txt["trial_def_title"])
                       for _,t in ipairs(TrialList) do
                          if t:IsDefault() and not t:Hidden() then
                             -- Set localized name for this trial
                             t:SetName(opt_table_txt[t:GetID()].tooltipTitle)
                             -- Add to menu
                             Main:AddMenuButton(menu, t:GetID(), false, opt_table_txt[t:GetID()])
                          end
                       end
                       
                       -- Add the custom trials
                       Main:AddMenuButton(menu, "trial_cust_title", true,
                                          opt_table_txt["trial_cust_title"])
                       for _,t in ipairs(TrialList) do
                          if not t:IsDefault() then
                             Main:AddMenuButton(menu, t:GetID(), false, t:GetMenuText())
                          end
                       end
                    end,
                       
         -- Click handler: on select, disable/the edit custom
         -- trial button depending on what is selected.
         [C.CLICK] =  function (menu, menu_item, opt_id, menu)
                         local trial = Trials[opt_id]
                         if not trial then return end
                         local b = _G["KT_EditCustom"]
                         if trial:IsDefault() then
                            b:Disable()
                            Main:UnRegisterWidget(b)
                         else
                            b:Enable()
                            Main:RegisterWidget(b)
                         end
                         
                         -- Show "Start" button
                         _G["KT_StartTrial"]:Show()
                      end,
         
         -- On create, register widget
         [C.CREATE] = WidgetOnCreateTrialDisable,
      },
      KT_AddCustom = {
         tt     = L["Create a custom KeybindTrainer trial."],
         label  = L["Add"],

         -- OnClick handler for Add custom trial.
         [C.CLICK] = function() 
                        _G["KT_CustomTrialInput"]:SetText("")
                        Main:ShowDialog(_G["KT_CustomInputDialog"], nil, "KT_Frame")
                     end,

         -- On create, register widget
         [C.CREATE] = WidgetOnCreateTrialDisable,
      },
      KT_EditCustom = {
         tt     = L["Edit/Delete the selected custom KeybindTrainer trial."],
         label  = L["Edit"],

         -- OnClick handler for edit custom trial.
         [C.CLICK] = function() 
                        -- Get custom trial string from saved vars.
                        local trial = Main:GetVar("KT_SelectTrial") 
                        if not (trial and Trials[trial] and not Trials[trial]:IsDefault()) then 
                           return
                        end
                        -- Populate box and show.
                        _G["KT_CustomTrialEditInput"]:SetText(Trials[trial]:GetStr())
                        Main:ShowDialog(_G["KT_CustomEditDialog"], nil, "KT_Frame")
                     end,

         -- On create, register widget
         [C.CREATE] = WidgetOnCreateTrialDisable,
      },
   },

   -- Other buttons visible from the front UI
   KT_OtherOptionsMenu = {
      label = "",
      KT_ShowOptions = {
         tt     = L["Show configuration options."],
         label  = L["Options"],

         -- Click handler: show help
         [C.CLICK] = function() 
                        Main:ShowDialog(_G["KT_OptionsDialog"], nil, "KT_Frame")
                     end,

         -- On create, register widget
         [C.CREATE] = WidgetOnCreateTrialDisable,
      },
      KT_ShowHelp = {
         tt     = L["Display addon help."],
         label  = L["Help"],

         -- Click handler: show help
         [C.CLICK] = function() 
                        Main:ShowDialog(_G["KT_HelpDialog"], nil, "KT_Frame")
                     end,

         -- On create, register widget
         [C.CREATE] = WidgetOnCreateTrialDisable,
      },
      KT_ViewStats = {
         tt     = L["View per-character historical timing information."],
         label  = L["Stats"],
         
         -- Click handler: Show the stats dialog
         [C.CLICK] = function() 
                        Main:ShowDialog(_G["KT_StatisticsDialog"], nil, "KT_Frame")
                     end,

         -- On create, register widget
         [C.CREATE] = WidgetOnCreateTrialDisable,
      },
   },
   KT_CustomInputDialog = {
      title = L["Create Trial"],
      text = L["Type or paste in your Custom Trial below. See 'Help' for how to create Custom Trials."],
      KT_CustomTrialInput = {
         tt     = "",
         label  = "",
      },
      KT_SaveToProfile = {
         tt     = L["Save to profile for all characters."],
         label  = L["Save to Profile"],

         -- Load handler
         [C.LOAD]  = CbOnLoad,

         -- On create, register widget
         [C.CREATE] = WidgetOnCreate,
      },
      KT_CustomTrialAcceptButton = {
         tt     = "",
         label  = L["Save"],

         -- Click handler: parse and save input
         [C.CLICK] = function() 
                        local dialog  = _G["KT_CustomInputDialog"]
                        local input   = _G["KT_CustomTrialInput"]:GetText()
                        
                        -- Parse 
                        local err = Main:LoadCustom(input)
                        if err then return Main:SetError(dialog, err) end
                        
                        -- Reset selected trial and menu item.
                        Main:ClearDropDownMenu(_G["KT_SelectTrial"])
                        
                        -- Done
                        Main:CloseAll()
                     end,
      },
      KT_CustomTrialCancelButton = {
         tt     = "",
         label  = L["Cancel"],

         -- Click handler: close up
         [C.CLICK] = function()
                        Main:CloseAll()
                     end,
      },
      KT_CustomTrialCreateHelpButton = {
         tt     = L["Show the help window alongside this one."],
         label  = L["Help"],

         -- Click handler: show help
         [C.CLICK] = function() 
                        -- Shift the custom trial box over, and 
                        -- show the help dialog alongside.
                        local this = _G["KT_CustomInputDialog"]
                        local help = _G["KT_HelpDialog"]
                        this:ClearAllPoints()
                        this:SetPoint("RIGHT", "UIParent", "CENTER", -5, 0)
                        
                        Main:ShowDialog(help, true)
                        help:ClearAllPoints()
                        help:SetPoint("LEFT", "UIParent", "CENTER", 5, 0)
                     end
      },
   },
   KT_CustomEditDialog = {
      title = L["Edit Trial"],
      text = L["Edit or delete the Custom Trial below."],
      KT_CustomTrialEditInput = {
         tt     = "",
         label  = "",
      },
      KT_CustomTrialEditDeleteButton = {
         tt     = L["WARNING: trial will be deleted for all your characters!"],
         label  = L["Delete"],

         -- Click handler: delete a trial
         [C.CLICK] = function()
                        Main:RemoveTrial(Main:GetVar("KT_SelectTrial"))
                        
                        -- Reset selected trial and menu item.
                        Main:ClearDropDownMenu(_G["KT_SelectTrial"])
                        
                        -- Done
                        Main:CloseAll()
                        
                        -- Disable the edit custom button since there's
                        -- nothing selected now.
                        local b = _G["KT_EditCustom"]
                        b:Disable()
                        Main:UnRegisterWidget(b)
                     end,
      },
      KT_CustomTrialEditAcceptButton = {
         tt     = "",
         label  = L["Save"],

         -- Click handler: parse and close
         [C.CLICK] = function() 
                        local dialog  = _G["KT_CustomEditDialog"]
                        local input   = _G["KT_CustomTrialEditInput"]:GetText()
                        local menu    = _G["KT_SelectTrial"]
              
                        -- Parse 
                        local err = Main:LoadCustom(input, Main:GetVar("KT_SelectTrial"))
                        if err then return Main:SetError(dialog, err) end
                        
                        -- Reset selected trial and menu item.
                        Main:ClearDropDownMenu(_G["KT_SelectTrial"])
                        
                        -- Done
                        Main:CloseAll()
                     end,
      },
      KT_CustomTrialEditCancelButton = {
         tt     = "",
         label  = L["Cancel"],

         -- Click handler: close the dialog box
         [C.CLICK] = function()
                        Main:CloseAll()
                     end,
      },
      KT_CustomTrialEditHelpButton = {
         tt     = L["Show the help window alongside this one."],
         label  = L["Help"],

         -- Click handler: show help
         [C.CLICK] = function() 
                        -- Shift the custom trial box over, and 
                        -- show the help dialog alongside.
                        local this = _G["KT_CustomEditDialog"]
                        local help = _G["KT_HelpDialog"]
                        this:ClearAllPoints()
                        this:SetPoint("RIGHT", "UIParent", "CENTER", -5, 0)
                        
                        Main:ShowDialog(help, true)
                        help:ClearAllPoints()
                        help:SetPoint("LEFT", "UIParent", "CENTER", 5, 0)
                     end,
      }
   },
   KT_StatisticsDialog = {
      title = L["Keybind Stats"],
      text  = L["KeybindTrainer statistics are continuously saved for each character until cleared."],

      KT_SelectStatistic = {
         tt      = L["Select which statistic to show."],
         label   = L["Stat:"],
         options = {
            KT_ActionsLastTimeGraph = {
               text         = L["Seconds per Bind"],
               tooltipTitle = L["Seconds per Bind for Last Trial"],
               tooltipText  = L["Show how much time you spent per bind for the last KeybindTrainer trial."],
            },
            KT_ActionsLastMissGraph = {
               text         = L["Miss per Bind"],
               tooltipTitle = L["Misses per Bind for Last Trial"],
               tooltipText  = L["Show how many misses you had per bind for the last KeybindTrainer trial."],
            },
            KT_ActionsMaxTimeGraph = {
               text         = L["Max Seconds per Bind"],
               tooltipTitle = L["Maximum Seconds per Bind Over All Trials"],
               tooltipText  = L["Show the maximum time you spent per bind since the last time you cleared your statistics."],
            },
            KT_ActionsAvgTimeGraph = {
               text         = L["Avg Seconds per Bind"],
               tooltipTitle = L["Average Seconds per Bind Over All Trials"],
               tooltipText  = L["Show how much time you spent per bind on average since the last time you cleared your statistics."],
            },
            KT_ActionsAvgMissGraph = {
               text         = L["Avg Miss per Bind"],
               tooltipTitle = L["Average Misses per Bind Over All Trials"],
               tooltipText  = L["Show how many misses you had per bind on average since the last time you cleared your statistics."],
            },
         },

         -- Load stat select menu.
         [C.LOAD] = function (menu)
                       local menu_name = menu:GetName()
                       local cfg_block = menu:GetParent():GetName()
                       menu._menu_id = 1
                       
                       -- Get a ref to the localized menu options.
                       local opt_table_txt = Main.UI[cfg_block][menu_name].options
                       if not opt_table_txt then return end
                       
                       -- Construct buttons
                       for id, stat in pairs(opt_table_txt) do
                          Main:AddMenuButton(menu, id, false, stat)
                       end
                    end,
                       
         -- Click handler: refresh graph to show the correct statistic.
         [C.CLICK] = function (menu, _, opt_id, _)
                        for id,g in pairs(Main.graph_list) do
                           if id == opt_id then g:Show()
                           else g:Hide() end
                        end
                     end,
      },
      KT_StatisticsDialogOk = {
         tt     = "",
         label  = L["OK"],

         -- Click handler: close stats
         [C.CLICK] = function() 
                        Main:HideDialog(_G["KT_StatisticsDialog"])
                     end,
      },
      KT_StatisticsDialogClear = {
         tt     = L["Clear saved statistics for this character."],
         label  = L["Clear"],

         -- Click handler: clear stats
         [C.CLICK] = function() 
                        Main:ClearStats()
                        Main:HideDialog(_G["KT_StatisticsDialog"])
                     end,
      },
   },
   KT_TrialDisplayFrame = {
      KT_StartTrial = {
         tt     = L["Start the currently selected Keybind Trial"],
         label  = L["Start Trial"],

         -- Click handler: kick off a trial!
         [C.CLICK] = function(button) 
                        button:Hide()
                        Main:BeginTrial()
                     end,
      },
      KT_Skip = {
         tt     = L["Skip to the next binds without recording stats."],
         label  = L["Skip Ahead"],

         -- Click handler: skip ahead
         [C.CLICK] = function(self) 
              Main:CancelCooldownsAndAdvanceTuple()
           end,
      },
   },
   KT_HelpDialog = {
      title = L["Help"],
      KT_CloseHelp = {
         label  = L["Close"],

         -- Click handler: close
         [C.CLICK] = function() 
                        Main:HideDialog(_G["KT_HelpDialog"])
                     end,
      },
   },
   KT_AboutDialog = {
      title = L["About"],
      KT_CloseAbout = {
         label  = L["Close"],

         -- Click handler: close
         [C.CLICK] = function() 
                        Main:HideDialog(_G["KT_AboutDialog"])
                     end,
      },
   },

   -- Options Dialog
   KT_OptionsDialog = {
      title = L["Options"],
      KT_CloseOptions = {
         label  = L["Close"],

         -- Click handler: close
         [C.CLICK] = function() 
                        Main:HideDialog(_G["KT_OptionsDialog"])
                     end,
      },

      KT_BindOptsMenu = {
         label = L["Binds"],
         KT_PetBar = {
            tt     = L["Include binds from your Pet bars in trials."],
            label  = L["Include Pet Bar"],
            
            -- Load handler
            [C.LOAD]  = CbOnLoad,

            -- On create, register widget
            [C.CREATE] = WidgetOnCreate,
         },
         KT_StanceBar = {
            tt     = L["Include binds from your Stance bars in trials."],
            label  = L["Include Stance Bar"],
            
            -- Load handler
            [C.LOAD]  = CbOnLoad,

            -- On create, register widget
            [C.CREATE] = WidgetOnCreate,
         },
         KT_TotemBar = {
            tt     = L["Include binds from your Totem bars in trials."],
            label  = L["Include Totem Bar"],
            
            -- Load handler
            [C.LOAD]  = CbOnLoad,

            -- On create, register widget
            [C.CREATE] = WidgetOnCreate,
         },

         -- Addon support -->
         KT_BindPad = {
            tt     = L["Use binds from BindPad."],
            label  = L["Include BindPad"],
            
            -- Onload Handler: No bindpad?  Disable permenantly
            [C.LOAD] = function(cb, checked)
                          local label = _G[cb:GetName() .. "Text"]
                          if not ABM:Loaded("BindPad") then
                             Main:SetVar(cb:GetName(), false)
                             Main:DisableWidget(cb)
                             Main:DisableWidget(label)
                             Main:UnRegisterWidget(cb)
                             Main:UnRegisterWidget(label)
                          else
                             CbOnLoad(cb, checked)
                          end
                       end,

            -- On create, register widget
            [C.CREATE] = WidgetOnCreate,
         },
         KT_Dominos = {
            tt     = L["Use binds from Dominos."],
            label  = L["Include Dominos"],

            -- Onclick Handler: refresh the dropdown
            [C.CLICK] = function(cb) 
                           -- Re-create the trial data structure.
                           Main:RefreshTrialDisplayList()

                           -- Disable/enable the pet/stance/totem options.
                           Main:ChangeOther(cb, _G["KT_PetBar"])
                           Main:ChangeOther(cb, _G["KT_StanceBar"])
                           Main:ChangeOther(cb, _G["KT_TotemBar"])
                        end,

            -- Onload Handler: No dominos?  Disable permenantly
            [C.LOAD] = function(cb, checked) 
                          local label = _G[cb:GetName() .. "Text"]
                          if not ABM:Loaded("Dominos") then
                             Main:SetVar(cb:GetName(), false)
                             Main:DisableWidget(cb)
                             Main:DisableWidget(label)
                             Main:UnRegisterWidget(cb)
                             Main:UnRegisterWidget(label)
                          else
                             CbOnLoad(cb, checked)
                             -- Disable/enable the pet/stance/totem options.
                             Main:ChangeOther(cb, _G["KT_PetBar"])
                             Main:ChangeOther(cb, _G["KT_StanceBar"])
                             Main:ChangeOther(cb, _G["KT_TotemBar"])
                          end
                       end,

            -- On create, register widget
            [C.CREATE] = WidgetOnCreate,
         },
         KT_Bartender = {
            tt     = L["Use binds from Bartender4."],
            label  = L["Include Bartender"],

            -- Onclick Handler: refresh the dropdown
            [C.CLICK] = function(cb) 
                           -- Re-create the trial data structure.
                           Main:RefreshTrialDisplayList()

                           -- Disable/enable the pet/stance/totem options.
                           Main:ChangeOther(cb, _G["KT_PetBar"])
                           Main:ChangeOther(cb, _G["KT_StanceBar"])
                           Main:ChangeOther(cb, _G["KT_TotemBar"])
                        end,

            -- Onload Handler: No bartender?  Disable permenantly
            [C.LOAD] = function(cb, checked) 
                          local label = _G[cb:GetName() .. "Text"]
                          if not ABM:Loaded("Bartender4") then
                             Main:SetVar(cb:GetName(), false)
                             Main:DisableWidget(cb)
                             Main:DisableWidget(label)
                             Main:UnRegisterWidget(cb)
                             Main:UnRegisterWidget(label)
                          else
                             CbOnLoad(cb, checked)
                             -- Disable/enable the pet/stance/totem options.
                             Main:ChangeOther(cb, _G["KT_PetBar"])
                             Main:ChangeOther(cb, _G["KT_StanceBar"])
                             Main:ChangeOther(cb, _G["KT_TotemBar"])
                          end
                       end,

            -- On create, register widget
            [C.CREATE] = WidgetOnCreate,
         },
      },
      KT_TrialMenu = {
         label = L["Trial"],
         KT_Continuous = {
            tt     = L["Repeat trial continuously until stopped by the user."],
            label  = L["Run Continuously"],
            
            -- Load handler
            [C.LOAD]  = CbOnLoad,

            -- On create, register widget
            [C.CREATE] = WidgetOnCreate,
         },
         KT_RandomOrder = {
            tt     = L["Randomize the order of the keybinds displayed."],
            label  = L["Randomize Bind Order"],
            
            -- Load handler
            [C.LOAD]  = CbOnLoad,

            -- On create, register widget
            [C.CREATE] = WidgetOnCreate,
         },
         KT_SaveStats = {
            tt     = L["Save statistics from this run to per-character historical timing information."],
            label  = L["Save Stats"],
            
            -- Load handler
            [C.LOAD]  = CbOnLoad,

            -- On create, register widget
            [C.CREATE] = WidgetOnCreate,
         },
      },

      KT_AddonMenu = {
         label = L["Addon"],
         KT_ShowMinimapIcon = {
            tt     = L["Turn the minimap icon on/off."],
            label  = L["Show Minimap Icon"],

            -- Click handler: if checked, turn on minimap--else, turn it off.
            [C.CLICK] = function(cb) 
                           if not Main:GetVar("KT_ShowMinimapIcon", true) then
                              Main.minimap_icon:Hide("KT_MinimapIcon")
                           else
                              Main.minimap_icon:Show("KT_MinimapIcon")
                           end
                        end,
            
            -- Load handler
            [C.LOAD]  = CbOnLoad,

            -- On create, register widget
            [C.CREATE] = WidgetOnCreate,

         },
         KT_ShowStartupMsg = {
            tt     = L["Show a message at startup."],
            label  = L["Show Startup Msg"],
            
            -- Load handler
            [C.LOAD]  = CbOnLoad,

            -- On create, register widget
            [C.CREATE] = WidgetOnCreate,
         },
      },

      KT_DisplayMenu = {
         label = L["Display"],
         KT_RandomPosition = {
            tt     = L["Randomize the positions icons appear in during the trial."],
            label  = L["Random Position"],
            
            -- Load handler
            [C.LOAD]  = CbOnLoad,

            -- On create, register widget
            [C.CREATE] = WidgetOnCreate,
         },
         KT_ShowTimer = {
            tt     = L["Display a timer while trials are running."],
            label  = L["Show Timers"],
            
            -- Load handler
            [C.LOAD]  = CbOnLoad,

            -- On create, register widget
            [C.CREATE] = WidgetOnCreate,
         },
         KT_IconSizeSlider = {
            tt     = L["Size of the ability icons."],
            label  = L["Icon Scale:"],
            
            -- Load handler
            -- TODO: Write 
            --[C.LOAD]  = ??

            -- On create, register widget
            [C.CREATE] = WidgetOnCreate,
         },
         KT_DurationInput= {
            tt     = L["Seconds between displaying each set of actions."],
            label  = L["Delay (s):"],
            
            -- Load handler
            -- TODO: Write 
            --[C.LOAD]  = ??
            
            -- On create, register widget
            [C.CREATE] = WidgetOnCreate,
         },
         KT_RandomTime = {
            tt     = L["Randomize time between displaying each set of actions."],
            label  = L["Random Delay"],
            
            -- Load handler
            [C.LOAD]  = CbOnLoad,

            -- On create, register widget
            [C.CREATE] = WidgetOnCreate,
         },
      },

   },

   -- Graphs
   KT_ActionsLastTimeGraph = {
      text  = L["Seconds per Bind"],
   },
   KT_ActionsLastMissGraph = {
      text  = L["Miss per Bind"],
   },
   KT_ActionsMaxTimeGraph = {
      text  = L["Max Seconds per Bind"],
   },
   KT_ActionsAvgTimeGraph = {
      text  = L["Average Seconds per Bind"],
   },
   KT_ActionsAvgMissGraph = {
      text  = L["Average Keybind Misses per Bind"],
   },
}

