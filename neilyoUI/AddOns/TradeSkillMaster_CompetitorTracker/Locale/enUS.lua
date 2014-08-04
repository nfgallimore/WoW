-- TradeSkillMaster_CompetitorTracker Locale - enUS
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/competitortracker/localization/

local debug = false
--[===[@debug@
debug = true
--@end-debug@]===]

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_CompetitorTracker", "enUS", true, debug)
if not L then return end

-- <<Tracker.lua>> --
L["SlashCommandHelp"] = "Toggles Competitor Monitor module/window"
L["TSMModuleIconText"] = "Competitor Tracker"
L["VersionText"] = "Version:%s"





-- <<Monitor.lua>> ---------------------------------------------------------------------------------
L["MHeadBefore"] = "Before"
L["MHeadLocation"] = "Location"
L["MHeadName"] = "Name"
L["MHeadNotes"] = "Notes"
L["MHeadNow"] = "Now"
L["MonitorDisabled"] = "Monitor module disabled."
L["MonitorEnabled"] = "Monitor module enabled."
L["MonitorTitle"] = "Competitor Monitor"





-- <<Data.lua>> ------------------------------------------------------------------------------------
L["DataAddFriend"] = "Adding %s to friends list."
L["DataChecking"] = "Checking friendlist..."
L["DataDelete"] = "[%s] competitor data deleted and added to the deleted competitors list."
L["DataDisabled"] = "Data module disabled."
L["DataEnabled"] = "Data module enabled."
L["DataFriendCount"] = "Local friend count:%d"
L["DataFriendListWait"] = "Friend list not ready, will try again in 15 seconds."
L["DataRegister"] = "[%s] competitor registered"
L["DataRemove"] = "Removing %s from friends list."
L["DataRemovedRecord"] = "Removed record:%s, %s"
L["DataRemoveFromDeleted"] = "[%s] competitor removed from the deleted competitors list, because manually added to the friends list."
L["DataSetNote"] = "Setting note \"%s\" for %s."
L["DataWillBeDeleted"] = "[%s] competitor data will be deleted after [%s] when the next friend list change event happens."





-- << Config.lua >> --------------------------------------------------------------------------------
L["OptChatLevelInfo"] = "Only the lower level messages will be printed"
L["OptChatLevelLabel"] = "Verbosity"
L["OptDataModuleEnabledInfo"] = "If you enable this option, the data module will record all login/logout activity in the background."
L["OptDataModuleEnabledLabel"] = "Track Competitors"
L["OptDefaultChatInfo"] = "Allows selection of which chat window to display messages"
L["OptDefaultChatLabel"] = "Default Chat Window"
L["OptMonitorMaxRowsInfo"] = "Number of Monitor Window Rows (Requires Reload)."
L["OptMonitorMaxRowsLabel"] = "Monitor Window Rows"
L["OptMonitorModuleEnabledInfo"] = "If you enable this option, you can monitor the activity of competitors in a window."
L["OptMonitorModuleEnabledLabel"] = "Competitor Monitor Enabled"
L["OptSyncInfo"] = "If you add or remove someone from your friends list and relog to an alt, that person will be added/removed from the alt's friends list as well. Also, any entries on that alt's list which isn't in the global list, will be added to the other characters whenever you log them in."
L["OptSyncLabel"] = "Syncronize Competitors"
L["OptTabOptions"] = "Options"
L["OptTabProfiles"] = "Profiles"
L["OptTrackMakDisabledInfo"] = "First, enable the track only with mark checkbox!"
L["OptTrackMakedInfo"] = "Track competitor only if marked in the friend note field."
L["OptTrackMakedLabel"] = "Track only with mark"
L["OptTrackMakInfo"] = "Track competitor only if marked with this in the friend note field."
L["OptTrackMakLabel"] = "Track Mark"
L["OptTrackMaxRecordInfo"] = "Max record saved for each comptetitor."
L["OptTrackMaxRecordLabel"] = "Max saved record"
L["OptTrackMaxRowsInfo"] = "Number of rows displayed (Requires Reload)."
L["OptTrackMaxRowsLabel"] = "History List Rows"
L["TreeCompetitors"] = "Competitors"
L["TreeOptions"] = "Options"
L["deleted/DeletedInfo"] = "Here you can remove competitor from the deleted list. Therefore, the competitor will not be deleted -removed from your friend list - when you relog on an ALT and also Syncronize Competitors option  is enabled."
L["deleted/DeletedTab"] = "Deleted"
L["deleted/DeletedTitle"] = "Deleted Competitor List Options"
L["profile/ProfileAccept"] = "Accept"
L["profile/ProfileCancel"] = "Cancel"
L["profile/ProfileChoose"] = "Existing Profiles"
L["profile/ProfileChooseDesc"] = "You can either create a new profile by entering a name in the editbox, or choose one of the already exisiting profiles."
L["profile/ProfileCopy"] = "Copy From"
L["profile/ProfileCopyDesc"] = "Copy the settings from one existing profile into the currently active profile."
L["profile/ProfileCurrent"] = "Current Profile:"
L["profile/ProfileDefault"] = "Default"
L["profile/ProfileDelete"] = "Delete a Profile"
L["profile/ProfileDeleteDesc"] = "Delete existing and unused profiles from the database to save space, and cleanup the SavedVariables file."
L["profile/ProfileDeleteSure"] = "Are you sure you want to delete the selected profile?"
L["profile/ProfileIntro"] = "You can change the active database profile, so you can have different settings for every character."
L["profile/ProfileNew"] = "New"
L["profile/ProfileNewSub"] = "Create a new empty profile."
L["profile/ProfileReset"] = "Reset Profile"
L["profile/ProfileResetDesc"] = "Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over."
L["profile/Profiles"] = "Profiles"




-- Profile Section -- 
L["ProfileAccept"] = "Accept"
L["ProfileCancel"] = "Cancel"
L["ProfileChoose"] = "Existing Profiles"
L["ProfileChooseDesc"] = "You can either create a new profile by entering a name in the editbox, or choose one of the already exisiting profiles."
L["ProfileCopy"] = "Copy From"
L["ProfileCopyDesc"] = "Copy the settings from one existing profile into the currently active profile."
L["ProfileCurrent"] = "Current Profile:"
L["ProfileDefault"] = "Default"
L["ProfileDelete"] = "Delete a Profile"
L["ProfileDeleteDesc"] = "Delete existing and unused profiles from the database to save space, and cleanup the SavedVariables file."
L["ProfileDeleteSure"] = "Are you sure you want to delete the selected profile?"
L["ProfileIntro"] = "You can change the active database profile, so you can have different settings for every character."
L["ProfileNew"] = "New"
L["ProfileNewSub"] = "Create a new empty profile."
L["ProfileReset"] = "Reset Profile"
L["ProfileResetDesc"] = "Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over."
L["Profiles"] = true




-- Deleted Competitor List Section --
L["DeletedInfo"] = "Here you can remove competitor from the deleted list. Therefore, the competitor will not be deleted -removed from your friend list - when you relog on an ALT and also Syncronize Competitors option  is enabled."
L["DeletedTab"] = "Deleted"
L["DeletedTitle"] = "Deleted Competitor List Options"




-- Viwer Section --
L["CClass"] = "Class"
L["CLevel"] = "Level"
L["CLocation"] = "Last location"
L["CName"] = "Name"
L["CNote"] = "Note"
L["CStatus"] = "Last status"
L["HistoryTabText"] = "History"
L["VHeadLocation"] = "Location"
L["VHeadPeriode"] = "Periode"
L["VHeadTime"] = "Time"



-- Management Section --
L["ManagementTabText"] = "Management"
L["MGDropdownInfo"] = "This competitor/character will be the goblin character who list the items in the Auction House. Everyone knows that the goblins are the ultimate Auction House Traders. "
L["MGDropdownLabel"] = "Goblin"
L["MGRemoveBtnInfo"] = "Click this button to remove/clear goblin selection for this competitor."
L["MGRemoveBtnText"] = "Remove Goblin Selection"
L["MGSTitle"] = "Goblin Settings"
L["MHClearBtnInfo"] = "Click this button to clear the competitor history."
L["MHClearBtnText"] = "Clear History"
L["MHSTitle"] = "History Settings"

