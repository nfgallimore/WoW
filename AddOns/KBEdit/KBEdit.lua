

--=============== Editor for keyboard Layouts ====================

--[[
Components:
dropdown to switch between layouts (or add new layout)`
"new" button to add buttons
input box to change name of layout


(need framestrata of dialog for onkeydown)

--]]

KBEditLayouts = {}

local addon = {}

local Keys = {}

local layout = "test"

local locked = false

local function GetCursorScaledPosition()
	local scale, x, y = UIParent:GetScale(), GetCursorPosition()
	return x / scale, y / scale
end

local Editor = CreateFrame("Frame", nil, UIParent) --resizable, repositionable

--==============================

local Controls = CreateFrame("Frame", nil, UIParent)
Controls:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 }});
Controls:SetBackdropColor(0,0,0,0.8);
Controls:EnableMouse(true)
Controls:SetMovable(true)
Controls:SetSize(250, 180)
Controls:SetPoint("TOPLEFT", UIParent, "CENTER", -400, 400)
Controls:SetScript("OnMouseDown", function(s) s:StartMoving() end)
Controls:SetScript("OnMouseUp", function(s) s:StopMovingOrSizing() end)
Controls:Hide()

Controls.Slider = CreateFrame("Slider", "KBEdit_Slider1", Controls, "OptionsSliderTemplate")

				Controls.Slider:SetMinMaxValues(0.5,1)
				Controls.Slider:SetValueStep(0.05)
				Controls.Slider:SetValue(1)
				_G[Controls.Slider:GetName().."Low"]:SetText("0.5")
				_G[Controls.Slider:GetName().."High"]:SetText("1")
				Controls.Slider:SetScript("OnValueChanged",
							function(self) Editor:SetScale(self:GetValue())end)
						
				Controls.Slider:SetWidth(200)
				Controls.Slider:SetHeight(20)
				Controls.Slider:SetPoint("BOTTOMLEFT", Controls, "BOTTOMLEFT", 15, 15)

local Exporter = CreateFrame("Frame", nil, Controls)
Exporter:SetSize(200, 130)
Exporter:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 }});
Exporter:SetBackdropColor(0,0,0,0.8);
Exporter:SetPoint("TOPLEFT", Controls, "TOPRIGHT", 30, 0)
Exporter:Hide()


Exporter.Input  = CreateFrame("EditBox", "KBEditInput", Exporter, "InputBoxTemplate")
Exporter.Input:SetSize(150, 30)
Exporter.Input:SetPoint("TOPLEFT", Exporter, "TOPLEFT", 25, -20)
Exporter.Input:SetAutoFocus(false)

Exporter.FS = Exporter:CreateFontString(nil, "OVERLAY", "GameFontNormal")
Exporter.FS:SetPoint("TOPLEFT", Exporter, "TOPLEFT", 10, -40)
Exporter.FS:SetPoint("BOTTOMRIGHT", Exporter, "BOTTOMRIGHT", -10, 10)
Exporter.FS:SetText("To share your keyboard layout, copy the above text and paste it into KeyBind's 'Layouts.lua' file")


--==============================

local function DragOrSize(self, button)
local x, y = GetCursorScaledPosition()
local sl, sr = self:GetLeft(), self:GetRight()
local st, sb = self:GetTop(), self:GetBottom()

if IsAltKeyDown() and IsShiftKeyDown() then
	local a = addon.NewButton()
	a:SetSize(self:GetSize())
	a:ClearAllPoints()
	a:SetPoint("TOPLEFT", Editor, "TOPLEFT", self:GetLeft()-Editor:GetLeft(), self:GetTop()-Editor:GetTop())
	a.label:SetText(self.label:GetText())
	self.label:SetText("")
	self:StartMoving()
else
	if x > sl and x < sl + 5 then
		self:StartSizing("LEFT")
	elseif x < sr and x > sr - 5 then
		self:StartSizing("RIGHT")
	elseif y < st and y > st -5 then
		self:StartSizing("TOP")
	elseif y > sb and y < sb + 5 then
		self:StartSizing("BOTTOM")
	else
		self:StartMoving()
	end
end
-- get x and y of mouse
-- get locations of frame
--decide between resizing or dragging
end

local function Release(self, button)
	self:StopMovingOrSizing()


	local sl, st = floor(self:GetLeft()+0.5), floor(0.5+self:GetTop())
	local el, et = floor(Editor:GetLeft()+0.5), floor(Editor:GetTop()+0.5)
	
	self:SetPoint("TOPLEFT", Editor, "TOPLEFT", sl-el, st-et)
	
	
	local l, r, t, b = Editor:GetLeft(), Editor:GetRight(), Editor:GetTop(), Editor:GetBottom()
	local cx, cy = self:GetCenter()
	
	--print(cx, l, cx, r, cy, t, cy, b)
	
	if cx < l or cx > r or cy > t or cy<b then
		--print(cx, l, cx, r, cy, t, cy, b)
		Keys[self] = nil
		self:Hide()
	end
	
	
end

local function MouseWheel(self, value)
	local x, y = self:GetCenter()
	local sl, st = self:GetLeft()+0.5,0.5+self:GetTop()
	local el, et = Editor:GetLeft()+0.5, Editor:GetTop()+0.5
	if IsShiftKeyDown() then
		self:SetPoint("TOPLEFT", Editor, "TOPLEFT", sl-el+value, st-et)
	else
		self:SetPoint("TOPLEFT", Editor, "TOPLEFT", sl-el, st-et+value)
	end

end

local function KeyDown(self, key)
	if not locked then
		self.label:SetText(key)
	end
end

local function SaveLayout(self)
	local msg = Editor.Input:GetText()
	KBEditLayouts[msg] = {}
	for _,button in pairs(Keys) do
		KBEditLayouts[msg][#KBEditLayouts[msg]+1] =  {button.label:GetText(), "Keyboard",floor(button:GetLeft()-Editor:GetLeft()+0.5), floor(button:GetTop()-Editor:GetTop()+0.5), floor(button:GetWidth()+0.5), floor(button:GetHeight()+0.5)}
	end
end

Editor.Input  = CreateFrame("EditBox", "KBEditInputExp", Controls, "InputBoxTemplate")
Editor.Input:SetSize(100, 30)
Editor.Input:SetPoint("TOPLEFT", Controls, "TOPLEFT", 25, -45)
Editor.Input:SetAutoFocus(false)

Editor.Save = CreateFrame("Button", nil, Controls, "UIPanelButtonTemplate")
Editor.Save:SetSize(100, 30)
Editor.Save:SetPoint("TOPRIGHT", Controls, "TOPRIGHT", -10, -10)
Editor.Save:SetScript("OnClick", SaveLayout)
Editor.Save:SetText("Save")



Editor.Delete = CreateFrame("Button", nil, Controls, "UIPanelButtonTemplate")
Editor.Delete:SetText("Delete")
Editor.Delete:SetSize(100, 30)
Editor.Delete:SetPoint("TOPRIGHT", Editor.Save, "BOTTOMRIGHT", 0, -5)
Editor.Delete:SetScript("OnClick", function(self) KBEditLayouts[Editor.Input:GetText()] = nil end)

Editor.Lock = CreateFrame("Button", nil, Controls, "UIPanelButtonTemplate")
Editor.Lock:SetSize(100, 30)
Editor.Lock:SetPoint("TOPRIGHT", Editor.Delete, "BOTTOMRIGHT", 0, -5)
Editor.Lock:SetScript("OnClick", SaveLayout)
Editor.Lock:SetText("Lock Binds")

Editor.New = CreateFrame("Button", nil, Controls, "UIPanelButtonTemplate")
Editor.New:SetSize(100,30)
Editor.New:SetPoint("TOPRIGHT", Editor.Lock, "TOPLEFT", -20, 0)

Editor.New:SetText("New Key")

Editor.Close = CreateFrame("Button",nil, Controls, "UIPanelButtonTemplate")
Editor.Close:SetSize(15, 15)
Editor.Close:SetText("X")
Editor.Close:SetScript("OnClick", function(s) Controls:Hide() Editor:Hide() end)
Editor.Close:SetPoint("TOPRIGHT", Controls, "TOPRIGHT")

local function export()
		local msg = "['"..Editor.Input:GetText().."'] = "
	for _,button in pairs(Keys) do
	
		msg = msg.."{ '"..(button.label:GetText() or "")
		.."', Keyboard, "
		..(floor(button:GetLeft()-Editor:GetLeft()+0.5))
		..", "
		..(floor(button:GetTop()-Editor:GetTop()+0.5))
		..", "
		..floor(button:GetWidth()+0.5)
		..", "
		..floor(button:GetHeight()+0.5)
		.." },\n"
		
	end
	msg = msg.."}"
	Exporter.Input:SetText(msg)
	Exporter:Show()
end

Editor.Export = CreateFrame("Button", nil, Controls, "UIPanelButtonTemplate")
Editor.Export:SetSize(100,30)
Editor.Export:SetPoint("TOPRIGHT", Editor.Lock, "BOTTOMRight", 0, -5)
Editor.Export:SetScript("OnClick", export)
Editor.Export:SetText("Export")




Editor.Lock:SetScript("OnClick", function(s)
																	if locked then
																		locked = false
																		s:SetText("Lock Binds")
																	else
																		locked = true
																		s:SetText("Unlock Binds")
																	end
																	end)

--=================

local KBEditDD = CreateFrame("Frame", "KBEditDD", Controls, "UIDropDownMenuTemplate")
KBEditDD:SetPoint("TOPLEFT", -5, -10)
UIDropDownMenu_SetWidth(KBEditDD, 100)
UIDropDownMenu_SetButtonWidth(KBEditDD, 100)

local function SwitchBoard(board)
	for _,k in pairs(Keys) do
		k:Hide()
	end
	
	Keys = {}
	
	Editor.Input:SetText(board)
	
	local loc = KBEditLayouts[board] or KeyBindAllBoards[board]
	local cx, cy = Editor:GetCenter()
	local left, right, top, bottom = cx, cx, cy, cy
	
	
	for i, info in pairs(loc) do
		local k = Keys[i]
		if not k then
			k = addon.NewButton()
		end
		k.label:SetText(info[1])
		k:ClearAllPoints()
		k:SetPoint("TOPLEFT", Editor, "TOPLEFT", info[3], info[4])
		k:SetSize(info[5], info[6])
		k:Show()
		
		local l, r, t, b = k:GetLeft(), k:GetRight(), k:GetTop(), k:GetBottom()
		
		if l < left then
			left = l
		end
		if r > right then
			right = r
		end
		if t > top then
			top = t
		end
		if b < bottom then
			bottom = b
		end
	end
	Editor:SetWidth(right-left + 15)

	Editor:SetHeight(top-bottom+ 10)
end

local function KBEditDD_Initialize(self, level) -- the menu items, needs a cleanup
		level = level or 1
	local info = UIDropDownMenu_CreateInfo()
	local value = UIDROPDOWNMENU_MENU_VALUE
	
		--KeyBindAllBoards
	if KeyBindAllBoards then
		for name in pairs(KeyBindAllBoards) do
			info.text = name
			info.colorCode = "|cFF31BD22"
			--set color
			info.value = name
			info.func = function() SwitchBoard(name) UIDropDownMenu_SetText(self, name) end
			UIDropDownMenu_AddButton(info,level)
		end
	end
	info.colorCode = "|cFFFFFFFF"
	for name in pairs(KBEditLayouts) do
		info.text = name
		info.value = name
		info.func = function() SwitchBoard(name) UIDropDownMenu_SetText(self, name)end
		UIDropDownMenu_AddButton(info, level)
	end
	
		info.text = "New Layout"
		info.value = "New Layout"
		info.func = function() Editor.Input:SetText("New Layout") for _,k in pairs(Keys) do k:Hide() end UIDropDownMenu_SetText(self, name) end
		UIDropDownMenu_AddButton(info, level)	
	
end

UIDropDownMenu_Initialize(KBEditDD, KBEditDD_Initialize)




Editor:SetWidth(1000)
Editor:SetHeight(200)

Editor:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
                                            edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
                                            tile = true, tileSize = 16, edgeSize = 16, 
                                            insets = { left = 4, right = 4, top = 4, bottom = 4 }});
Editor:SetBackdropColor(0,0,0,0.8);
Editor:SetPoint("TOPLEFT", UIParent, "CENTER", -500, 100)
Editor:EnableMouse(true)
Editor:SetMovable(true)
Editor:SetResizable(true)
Editor:SetScript("OnMouseDown", DragOrSize)
Editor:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)


function addon.NewButton() -- creates new buttons to add the the keyboard
	local button = CreateFrame("Frame", nil, Editor) -- parent it to the keyboard
	button:SetMovable(true)
	button:EnableMouse(true)
	button:EnableKeyboard(true)
	button:SetResizable(true)
	
	button:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
                                            edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
                                            tile = true, tileSize = 16, edgeSize = 16, 
                                            insets = { left = 4, right = 4, top = 4, bottom = 4 }});
	button:SetBackdropColor(0,0,0,0.8);
	button.label = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	button.label:SetFont("Fonts\\ARIALN.TTF", 15 )
	button.label:SetTextColor(1,1,1,0.7)
	
	button.label:SetPoint("TOPLEFT", button, "TOPLEFT", 20,  -10)
	button.label:SetPoint("RIGHT", button, "RIGHT", -20,  0)
	button.label:SetPoint("BOTTOM", button, "BOTTOM")
	button.label:SetJustifyH("LEFT")
	button.label:SetJustifyV("TOP")
	button.label:SetNonSpaceWrap(true)

	button:SetScript("OnEnter", function(self) self:EnableKeyboard(true) self:SetScript("OnKeyDown", KeyDown) end)-- enable keyboard, etc
	button:SetScript("OnLeave", function(self) self:EnableKeyboard(false) self:SetScript("OnKeyDown", nil) end)
	
	button:SetScript("OnMouseDown", DragOrSize)
	button:SetScript("OnMouseUp", Release)
	button:SetScript("OnMouseWheel", MouseWheel)

	button:SetSize(50,50)
	button:SetPoint("BOTTOMLEFT", Editor, "TOPLEFT", 0 , 30)
	--add a close button to delete it
	
	Keys[button] = button

		return button												
end

Editor.New:SetScript("OnClick", addon.NewButton)

local function ExportLayout()
KBEditLayouts = {}
	KBEditLayouts["test"] = {}
	for _,button in pairs(Keys) do
	
		KBEditLayouts["test"][#KBEditLayouts["test"]+1] =  {button.label:GetText(), "Keyboard",floor(button:GetLeft()-Editor:GetLeft()+0.5), floor(Editor:GetTop()-button:GetTop()+0.5), floor(button:GetWidth()+0.5), floor(button:GetHeight()+0.5)}
	end
end




--=========================================
--==========================================
Editor:Hide()

SLASH_KBEdit1 = "/kbedit";

SlashCmdList["KBEdit"] = function() Editor:Show() Controls:Show() end

				