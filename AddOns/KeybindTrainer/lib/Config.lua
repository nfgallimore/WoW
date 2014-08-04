--
-- UI Config libary.
-- Used by UI.lua to implement the UI for KeybindTrainer
--

-- Upvalues
local Main       = KeybindTrainer;
local CVals      = KT_UIConfigVals;
local U          = FitzUtils;

-- For convienience
local C          = Main.Constants;
local Trials     = Main.Trials;
local UI         = Main.UI

-- For speed
local next       = next

--
-- Internal Helpers
--

-- Lookup UI config from the UI layout.
local function GetUIConfig(block, widget)
   -- UI config is nested, so just need to
   -- find the root element, then do the lookup.
   local root = UI[block:GetName()]
   if not root then
      if UI[block:GetParent():GetName()] and
         UI[block:GetParent():GetName()][block:GetName()] then
         root = UI[block:GetParent():GetName()][block:GetName()]
      else -- Right now, only support 3 levels of nesting.
         return nil
      end
   end
   if widget then return root[widget:GetName()]
   else           return root end
end


--
-- General Config Functions
--

-- Run a callback for a widget, if it is defined in the UI layout.
function Main:RunCb(w, type, ...)
   local cb = GetUIConfig(w:GetParent(), w)
   if cb and cb[type] then return cb[type](w, ...) end
end

-- Enable/Disable interaction with all config.
function Main:IsConfigDisabled()
   return self.config_disabled
end

-- Specialized function to disable/enable a list of widgets.
function Main:EnableAllConfig(enable, list)
   if not list then list = self.main_widget_list end
   self.config_disabled = not enable
   for _,w in pairs(list) do
      if enable then
         self:EnableWidget(w)
      else
         self:DisableWidget(w)
      end
   end
end

-- Disable/Enable a widget graphically.
function Main:DisableWidget(w)
   if w.SetFontObject  then
      w.on_font = w:GetFontObject()
      w:SetFontObject("GameFontDisable")
   end
   if w.ClearFocus     then w:ClearFocus()                 end
   if w.Disable        then w:Disable()                    end
   if w.EnableKeyboard then w:EnableKeyboard(false)        end
   if w.EnableMouse    then w:EnableMouse(false)           end
end
function Main:EnableWidget(w, font_override)
   if w.SetFontObject  then
      if font_override then w:SetFontObject(font_override)
      else                  w:SetFontObject(w.on_font)     end
   end
   if w.EnableKeyboard then w:EnableKeyboard(true)         end
   if w.EnableMouse    then w:EnableMouse(true)            end
   if w.Enable         then w:Enable()                     end
end

-- Put/Get a config value to the global config table.
function Main:SetVar(name, value)
   CVals[name] = value
end
function Main:GetVar(name, allow_default)
   if CVals[name] ~= nil then return CVals[name]
   elseif allow_default then return self.ValDefaults[name] end
end

-- Register a widget
function Main:RegisterWidget(widget, list)
   if not list then list = self.widget_list end
   list[widget:GetName()] = widget
end
function Main:UnRegisterWidget(widget, list)
   if not list then list = self.widget_list end
   list[widget:GetName()] = nil
end

-- Reset all config state from saved variables.
function Main:RestoreConfigState(from_map)
   for n,w in pairs(self.widget_list) do
      -- Set the default where there isn't user input.
      if from_map[n] == nil then self:SetVar(n, self.ValDefaults[n])
      else self:SetVar(n, from_map[n]) end
      self:RunCb(w, C.LOAD, self:GetVar(n))
   end
end


--
-- Block Config
--

-- Init a block of config widgets
-- TODO: Right now, no tooltips for this.
function Main:LoadBlock(frame, label)
   -- Get text from localization.
   txt = GetUIConfig(frame)
   if not txt then return end

   -- Set the label.
   label:SetText(txt.label)
end


--
-- Widget: Tooltips
-- 

-- Show/Hide a tooltip for a widget at optional arg anchor.
-- If anchor isn't specific, anchor to widget.
local function ShowWidgetToolTip(block, widget, anchor, override)
   -- Get localized text, if there isn't any we're done.
   txt_table = GetUIConfig(block, widget)
   if not (txt_table and txt_table.tt) then return end
   
   -- Pick anchor and set tooltip.
   if not anchor then anchor = widget end
   if Main:IsConfigDisabled() and not override then return end
   GameTooltip:SetOwner(anchor, "ANCHOR_TOPRIGHT");
   GameTooltip:SetText(txt_table.tt);
   GameTooltip:Show();
end

-- Helper to show/hide a tooltip for a slider button,
-- which is a grandchild of a block.
local function ShowDropDownButtonToolTip(button)
   local slider = button:GetParent()
   local block  = slider:GetParent()
   ShowWidgetToolTip(block, slider, button)
end


--
-- Widget: DropDown Menu
--

-- Clear the selected value from a dropdown
function Main:ClearDropDownMenu(menu)
   -- Reset selected trial and menu item.
   Main:SetVar(menu:GetName(), nil)
   UIDropDownMenu_ClearAll(menu)

   -- Turn off the trial start button, if shown
   _G["KT_StartTrial"]:Hide()           
end

-- Initial load of a dropdown--called from XML OnLoad.
function Main:CreateDropDownMenu(block, frame, button, label, no_register)
   -- Get layout config.  Without it, error.
   local conf  = GetUIConfig(block, frame)
   if not conf then return end

   -- Init menu with saved init function--load function MUST be defined.
   UIDropDownMenu_Initialize(frame, conf[C.LOAD]);
   UIDropDownMenu_SetWidth(frame, 160);

   -- Set tooltip.  Note: keep the tooltip showing for both the button
   -- and the dropdown.
   button:SetScript("OnEnter", ShowDropDownButtonToolTip);
   button:SetScript("OnLeave", function() GameTooltip:Hide(); end);

   -- Set label.
   label:SetText(conf.label)

   -- Call create callback
   self:RunCb(frame, C.CREATE, button, label)
end

-- Helper called for dropdown OnEnter to create tooltip
function Main:CreateDropDownToolTip(button)
   ShowDropDownButtonToolTip(button);
end

-- Callback for all Dropdown Menu options
function KT_OnOptionSelect(self, opt_id, menu)
   local menu_id = self:GetID()
   UIDropDownMenu_SetSelectedID(menu, menu_id)
   Main:SetVar(menu:GetName(), opt_id) 

   -- If an option callback saved, call it.
   Main:RunCb(menu, C.CLICK, self, opt_id, menu)
end

-- Helper to add buttons to a dropdown.  Uses pre-created
-- tables in UIDropDownMenu.lua to save memory.
function Main:AddMenuButton(menu, id, is_title, txt_tbl)
   local info = UIDropDownMenu_CreateInfo()  
   if is_title then
      info.isTitle         = true
      info.checked         = nil
      info.notClickable    = true
      info.notCheckable    = true
      info.fontObject      = GameFontNormalSmallLeft
   else
      info.isTitle         = nil
      info.func            = KT_OnOptionSelect
      info.arg1            = id
      info.arg2            = menu
      info.tooltipOnButton = true
      info.value           = id
      local selected       = Main:GetVar(menu:GetName())
      if selected and selected == id then info.checked = true
      else                                info.checked = nil end
   end
     
   -- Append any localized text and add button
   if txt_tbl then
      for k,v in pairs(txt_tbl) do 
         info[k] = v
      end
   end

   -- Save the option id for this menu item and add it
   Main:SetVar(menu:GetName()..id, menu._menu_id)
   UIDropDownMenu_AddButton(info)
   menu._menu_id = menu._menu_id + 1
end
   

--
-- Widget: Check Boxes
--

-- Init a check box
function Main:LoadCheckBox(block, cb, no_register)
   -- Get text from localization.
   txt_table = GetUIConfig(block, cb)
   if not txt_table then return end

   -- Set tool tip (TODO: make more complete)
   cb.tooltipText = txt_table.tt

   -- Set the label
   local label = _G[cb:GetName() .. "Text"]
   label:SetText(txt_table.label)

   -- Call create callback
   self:RunCb(cb, C.CREATE, cb, label)
end

-- Handle a config option click.
function Main:OnCheck(cb)
   if cb:GetChecked() then
      U:Print(cb:GetName().." is CHECKED!")
      self:SetVar(cb:GetName(), true)
   else
      self:SetVar(cb:GetName(), false)
   end 
   self:RunCb(cb, C.CLICK)
end

-- Custom helper to en/disable other widgets via this checkbox.
function Main:ChangeOther(cb, widget)
   local label = _G[widget:GetName() .. "Text"]

   -- Depending on state, disable/enable.
   if cb:GetChecked() then
      -- Clear widget state.
      if widget.SetChecked then widget:SetChecked(false) end
      self:SetVar(widget:GetName(), nil)

      -- Disable
      self:DisableWidget(widget)
      if label then self:DisableWidget(label) end
   else  
      self:EnableWidget(widget, "GameFontHighlight")
      if label then self:EnableWidget(label, "GameFontNormal") end
   end
end


--
-- Widget: Buttons
--

-- Init a Button
function Main:LoadButton(block, button, no_register)
   -- Get text from localization.
   txt_table = GetUIConfig(block, button)
   if not txt_table then return end

   -- Set tool tip (TODO: make more complete)
   button.tooltipText = txt_table.tt

   -- Set the text.
   button:SetText(txt_table.label)
   button:SetDisabledFontObject("GameFontDisable")

   -- Call create callback
   self:RunCb(button, C.CREATE, button)
end

-- Handle a config button click.
function Main:OnClick(button)
   self:RunCb(button, C.CLICK)
end

-- Helper called for button OnEnter
function Main:CreateButtonToolTip(button, override)
   ShowWidgetToolTip(button:GetParent(), button, nil, override);
end


--
-- Widget: Sliders
--

-- Init a slider
function Main:LoadSlider(block, slider, label, val_label, low, high, l_v, h_v, no_register)
   -- Set up slider
   slider:SetValueStep(0.1);
   slider:SetMinMaxValues(l_v, h_v);

   -- Position and set slider lables
   low:SetText(string.format("%.1f", l_v));
   low:SetFontObject("GameFontHighlight");
   high:SetText(string.format("%.1f", h_v));
   high:SetFontObject("GameFontHighlight");

   -- Set tt and label
   txt_table = GetUIConfig(block, slider)
   slider.tooltipText = txt_table.tt
   label:SetFontObject("GameFontNormal");
   label:SetText(txt_table.label)
   label:ClearAllPoints()
   label:SetPoint("LEFT", slider, "TOPLEFT", 0, 8)

   -- Set initial value.
   self:OnSlide(slider, self:GetVar(slider:GetName(), true), val_label);

   -- Call create callback
   self:RunCb(slider, C.CREATE, slider, label, val_label, low, high)
end

-- Handle a slider change
function Main:OnSlide(slider, value, val_label)
   slider:SetValue(value)
   val_label:SetText(string.format("%.1f", value));
   self:SetVar(slider:GetName(), value)
   U:Print("  SLIDER: "..slider:GetName().." = "..self:GetVar(slider:GetName()))
end


--
-- Widget: Edit Box (+ label)
--

-- Set a value for the edit box
function Main:SetEditBoxInput(editbox, val)
   editbox:SetText(val)
   self:SetVar(editbox:GetName(), val)
end

-- Set default value for edit box
function Main:SetEditBoxDefInput(editbox)
   local def = self:GetVar(editbox:GetName(), true)
   if def == nil then return end
   self:SetEditBoxInput(editbox, def)
end

-- Load an edit box.
function Main:LoadEditBox(block, editbox, label, no_register)
   -- Set tt and label
   txt_table = GetUIConfig(block, editbox)
   editbox.tooltipText = txt_table.tt
   label:SetFontObject("GameFontNormal");
   label:SetText(txt_table.label);

   -- Set any default values.
   self:SetEditBoxDefInput(editbox)

   -- Call create callback
   self:RunCb(editbox, C.CREATE, editbox, label)
end

-- Helper called for EditBox OnEnter
function Main:CreateEditBoxToolTip(editbox)
   ShowWidgetToolTip(editbox:GetParent(), editbox);
end

-- Helper called to clean input, set the default, and
-- save values for FLOAT input.  Used we lose keyboard focus.
function Main:SaveEditBoxFloatValue(editbox)
   local t = editbox:GetText()

   -- Remove any bad characters.
   t, _ = t:gsub("[^%d%.]", "")
   if t:len() > 0 then
      t, _  = t:gsub("%.+", ".")
      t, _  = t:gsub("^%.", "0.")
      t, _  = t:gsub("%.$", ".0")
   end
 
   -- If we didn't get anything, save the default
   if t:len() == 0 then 
      self:SetEditBoxDefInput(editbox)
   else
      editbox:SetText(t)
      self:SetVar(editbox:GetName(), t)
   end
end


--
-- Widget: Dialog Popup
--

-- Load a dialog box.
function Main:LoadDialog(frame, text, title)
   -- Get text from localization.
   txt = GetUIConfig(frame)
   if not txt then return end

   -- Set the dialog text if there is any.
   if text  and txt.text  then text:SetText(txt.text)   end
   if title and txt.title then title:SetText(txt.title) end
end

-- Close the currently open dialog box.
function Main:CloseAll()
   local open = self:GetVar("DialogShown") or {}
   for box,_ in pairs(open) do
      self:HideDialog(box)
   end
   self:SetVar("DialogShown", nil)
end

-- Show dialog box.
function Main:ShowDialog(frame, stayopen, centerframe)
   -- Default: close any other open dialogs--only one open at a time.
   if not stayopen then self:CloseAll() end

   -- Disable all other widgets in config if nec.
   if not self:IsConfigDisabled() then
      self:EnableAllConfig(false)
   end

   -- Close all open dropdowns
   CloseDropDownMenus()

   -- Disallow trials from starting when any dialog is shown.
   local open = self:GetVar("DialogShown") or {}
   open[frame] = 1
   self:SetVar("DialogShown", open) 

   -- Clear error
   self:SetError(frame, "")

   -- Show dialog box in center of screen by default.
   frame:ClearAllPoints()
   centerframe = centerframe or "UIParent"
   frame:SetPoint("CENTER", centerframe, "CENTER", 0, 0)
   frame:Show()
end

-- Hide dialog box.
function Main:HideDialog(frame)
   -- Register this window as closed.
   local open = self:GetVar("DialogShown") or {}
   open[frame] = nil
   self:SetVar("DialogShown", open) 

   -- Hide the dialog box
   frame:Hide()

   -- Is everything closed?  If not, done.
   if next(self:GetVar("DialogShown")) ~= nil then return end

   -- Enable all other widgets in config.
   self:EnableAllConfig(true)
end

-- Add a warning string to the dialog box.
function Main:SetError(frame, txt)
   -- Get a reference to the warning text and set
   local label = _G[frame:GetName().."Error"]
   if not label then return end
   label:SetText(txt)
   label:SetTextColor(1, 0, 0, 1)
end


--
-- Widget: Scroll Graph
--

-- Register a graph.
function Main:RegisterGraph(graph)
   self.graph_list[graph:GetName()] = graph
end

-- On show handler for all graphs.  Graph type determined at load time
-- via config variables.
function Main:ShowGraph(graph, display, title)
   local gname = graph:GetName()
   local conf  = GetUIConfig(graph)

   -- Get the type (action|trial), field (miss|time), and op (max|avg|last)
   -- callback for this graph
   local type      = self:GetVar(C.GRAPH_TYPE  .. gname)
   local field     = self:GetVar(C.GRAPH_FIELD .. gname)
   local show_last = self:GetVar(C.GRAPH_LINE  .. gname)
   local op_func   = self:GetVar(C.GRAPH_FUNC  .. gname)

   -- Set title
   title:SetText(conf.text)

   -- Get a list of the stats for the actions sorted by op_func.
   local sorted_action_list = self:GetSortedStatList(type, field, op_func)
   local max_val = 0
   if #sorted_action_list > 0 then
      max_val = op_func(sorted_action_list[1], field)
   end

   -- Set the slider basics.
   local slider = _G[gname.."HSlider"]
   local sl_max = #sorted_action_list - C.GRAPH_NUM_BARS + 1

   if sl_max < 1 then sl_max = 1 end
   slider:SetMinMaxValues(1, sl_max)
   slider:SetValueStep(1.0)
   slider:SetValue(1)

   -- Create the slider OnValueChanged function, using the
   -- upvalues constructed each time the dialog is shown.
   slider:SetScript("OnValueChanged", 
     function()
        local val, hgt, b, lst, line, i, j
        local offset = slider:GetValue() - 1

        -- Depending on where the slider is, write out
        for j = 1,C.GRAPH_NUM_BARS,1 do
           i = j + offset
           if i <= #sorted_action_list then
              -- Get val
              val = op_func(sorted_action_list[i], field)
              hgt = (val / max_val) * C.DEFAULT_BAR_HEIGHT
              
              -- Set up the bar to be max high, and add label.
              --U:Print("   val: "..val.."  hgt: "..hgt.."  max: "..max_val)
              _G[display:GetName().."Col"..j.."Bar"]:SetHeight(hgt + 1)
              _G[display:GetName().."Col"..j.."BarVal"]:SetText(string.format("%.2f", val))
              
              -- Set up the icon
              b = _G[display:GetName().."Col"..j.."Icon"]
              b:SetNormalTexture(sorted_action_list[i][C.STAT_FIELDS.INFO])
              self:SetActionButtonMacroName(b, sorted_action_list[i][C.STAT_FIELDS.NAME])
              
              -- Set the lines for last value if requested
              if show_last then
                 lst  = (KT_GetStatLast(sorted_action_list[i], field) / max_val) * C.DEFAULT_BAR_HEIGHT
                 line = _G[display:GetName().."Col"..j.."BarLine"]
                 line:SetPoint("TOP", line:GetParent(), "BOTTOM", 0, lst)
                 line:Show()
              end
              
              -- Done, show bar
              _G[display:GetName().."Col"..j]:Show()
           else
              _G[display:GetName().."Col"..j]:Hide()
           end
        end
     end
  )
     
   -- Call the update handler.
   slider:GetScript("OnValueChanged")()
end

-- On hide graph, un-register slider OnValueChanged handler 
-- to allow upvalues to be reclaimed.
function Main:HideGraph(graph)
   local slider = _G[graph:GetName().."HSlider"]
   slider:SetScript("OnValueChanged", nil)
end
