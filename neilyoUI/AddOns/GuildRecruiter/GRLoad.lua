-- Author      : Yottabyte
-- Create Date : 10/20/2010 11:13:35 PM


GRMain:Hide()

GRLoad = CreateFrame("Button",nil,WhoFrame,"UIPanelButtonTemplate")
		GRLoad:SetHeight(20)
		GRLoad:SetWidth(105)
		GRLoad:SetText("Guild Recruiter")
		GRLoad:SetPoint("TOPLEFT",147,-42)
		GRLoad:SetScript("OnClick",function()
		      if GRMain:IsVisible()~=1 then
GRAttunement()
else
GRMain:Hide()
end
		end)
		
-- Guild Invite Button--
-- Full credit goes to RIOKOU who made the "EasyAddFriend" addon and to Ezoteriqe for modifying it for guilds.--

local EasyGInv = CreateFrame("Frame","EasyGInvFrame")
EasyGInv:SetScript("OnEvent", function() hooksecurefunc("UnitPopup_ShowMenu", EasyGInvCheck) end)
EasyGInv:RegisterEvent("PLAYER_LOGIN")

local PopupUnits = {"PARTY", "PLAYER", "RAID_PLAYER", "RAID", "FRIEND", "TEAM", "CHAT_ROSTER", "TARGET", "FOCUS"}

local EasyGInvButtonInfo = {
	text = "Invite To Guild",
	value = "EZ_GINV",
	func = function()
	
	if GRDNIBypass:GetChecked()~=1 then
	if tContains(DNIt, UIDROPDOWNMENU_OPEN_MENU.name)~=1 then
	SendChatMessage(GRInvite:GetText(),"WHISPER",nil,UIDROPDOWNMENU_OPEN_MENU.name)
	GuildInvite(UIDROPDOWNMENU_OPEN_MENU.name)
	tinsert(DNIt, UIDROPDOWNMENU_OPEN_MENU.name)
	print(UIDROPDOWNMENU_OPEN_MENU.name, 'was invited and added to the Do Not Invite List!')
	else
	print(UIDROPDOWNMENU_OPEN_MENU.name, 'was NOT invited because they are on the Do Not Invite List!')
	end
	end
	if GRDNIBypass:GetChecked()==1 then
	SendChatMessage(GRInvite:GetText(),"WHISPER",nil,UIDROPDOWNMENU_OPEN_MENU.name)
	GuildInvite(UIDROPDOWNMENU_OPEN_MENU.name)
	if tContains(DNIt, UIDROPDOWNMENU_OPEN_MENU.name)~=1 then
	tinsert(DNIt, UIDROPDOWNMENU_OPEN_MENU.name)
	print(UIDROPDOWNMENU_OPEN_MENU.name, 'was invited and added to the Do Not Invite List!')
	else
	print(UIDROPDOWNMENU_OPEN_MENU.name, 'was invited even though he IS on the Do Not Invite List!')
	end
	end
	end,
	notCheckable = 1,
}

local CancelButtonInfo = {
	text = "Cancel",
	value = "CANCEL",
	notCheckable = 1
}

function EasyGInvCheck()
	if CanGuildInvite() then		
		local PossibleButton = getglobal("DropDownList1Button"..(DropDownList1.numButtons)-1)
		if PossibleButton["value"] ~= "EZ_GINV" then									-- is there not already an "Invite To Guild" button on it?
								
			local GoodUnit = false
			for i=1, #PopupUnits do	
			if OPEN_DROPDOWNMENUS[1]["which"] == PopupUnits[i] then
				GoodUnit = true
				end
			end
														
			if UIDROPDOWNMENU_OPEN_MENU["unit"] == "target" and ((not UnitIsPlayer("target"))) then
				GoodUnit = false										-- make sure the unit isn't an npc or enemy player
			end
			
			if GoodUnit then											-- is the unit of the popup one that we want to use? (e.g. not vehicles, npcs, or enemy players)
					CreateEasyGInvButton()									-- Add the button
			end
		end
	end
end

function CreateEasyGInvButton()
			
		-- we have decided to actually make the frame, we are going to place it above the "Cancel" button
		local CancelButtonFrame = getglobal("DropDownList1Button"..DropDownList1.numButtons)
		CancelButtonFrame:Hide() 									-- hide the "Cancel" button
		DropDownList1.numButtons = DropDownList1.numButtons - 1		-- make the DropDownMenu API think the "Cancel" button never existed
		UIDropDownMenu_AddButton(EasyGInvButtonInfo)				-- create our "Add Friend" button, it gets put where the cancel button used to be
		UIDropDownMenu_AddButton(CancelButtonInfo)					-- create a new cancel button after our "Add Friend" button
	
end
		