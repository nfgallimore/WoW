-- Created by Value -- 
-- 1.0 Release Version -- 

-- Create Frame To Make Sure Saved Variables Have Loaded -- 
local addonsLoaded = CreateFrame("Frame")

-- Register Events For addonsLoaded Frame -- 
addonsLoaded:RegisterEvent("ADDON_LOADED")
addonsLoaded:RegisterEvent("PLAYER_LOGOUT")

-- Declare playerName, playerRealm, and checkLoadCount Before Checking If Profile Exists -- 
local battlefieldWinner = nil
local playerName = UnitName("player")
local playerRealm = GetRealmName()
local playersTeam = nil
local playersTeam2v2 = nil
local playersTeam3v3 = nil
local playersTeam5v5 = nil
local catchCount = 0
local checkLoadCount = false
local storeEnemy1 = nil
local storeEnemy2 = nil
local storeEnemy3 = nil
local storeEnemy4 = nil
local storeEnemy5 = nil
local storeClass1 = nil
local storeClass2 = nil
local storeClass3 = nil
local storeClass4 = nil
local storeClass5 = nil
local temporary1boolean = false
local temporary2boolean = false
local temporary3boolean = false
local temporary4boolean = false
local temporary5boolean = false
local teamName = nil
local specific1 = 0
local specific2 = 0
local specific3 = 0
local specific4 = 0
local specific5 = 0
local bracketChoice = nil
local playerChoice = nil
local playerChoiceName = nil
local enemyChoice = nil
local specificPlayerStorage = ""
local deathKnightBoolean = false
local druidBoolean = false
local hunterBoolean = false
local mageBoolean = false
local monkBoolean = false
local paladinBoolean = false
local priestBoolean = false
local rogueCBoolean = false
local shamanBoolean = false
local warlockBoolean = false
local warriorBoolean = false
local alreadyCreated = false
local fontStringStorage = {}

-- Items For Drop Down Menu -- 
playerItems = {"Step 2"}

-- Function To Make Sure Current Addon Variables Are Loaded
function addonsLoaded:OnEvent(event, arg1)
    if event == "ADDON_LOADED" and arg1 == "WinLossTracker" then
        if player == nil then
            player = {}
        end 
        -- Loop To Check If Player Profile Has Already Been Created --
        for k,v in pairs (player) do 
            -- Checks To See If Player Is Already In Database -- 
            if (v.playerName == playerName) then
                checkLoadCount = true
            end
        end   
        -- If Character Is Not In Database Then Add To Database -- 
        if (checkLoadCount == false) then
            -- Creates New Profile If Not In Database. -- 
            newCharacter = Player:new(playerName, playerRealm)
            table.insert(player, newCharacter)
        end     
        populatePlayerItems()
    end
end

-- Set Script For addonsLoaded Frame -- 
addonsLoaded:SetScript("OnEvent", addonsLoaded.OnEvent)

---------------- Everything Below This Point Deals With GUI ----------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Currently the GUI is created from scratch (first time attempting LUA   --
-- and a WoW addon) so it is very nasty code. Maybe convert it to OOP     --
-- once I complete the data structure since the GUI won't change much if  --
-- at all once that happens.                                              --

SLASH_WINLOSSTRACKER1 = '/wlt', '/winlosstracker'
function SlashCmdList.WINLOSSTRACKER(msg, editbox)
    if (alreadyCreated == false) then
        alreadyCreated = true
        frameShowing = true
        -- Creates Parent Frame -- 
        winLossTrackerFrame = CreateFrame("Frame", "DragFrame", UIParent)
        winLossTrackerFrame:SetSize(1000, 700)
        winLossTrackerFrame:SetPoint("CENTER")
        winLossTrackerFrame:SetMovable(true)
        winLossTrackerFrame:EnableMouse(true)
        winLossTrackerFrame:SetClampedToScreen(true)
        winLossTrackerFrame:RegisterForDrag("LeftButton")
        winLossTrackerFrame:SetScript("OnDragStart", winLossTrackerFrame.StartMoving)
        winLossTrackerFrame:SetScript("OnDragStop", winLossTrackerFrame.StopMovingOrSizing)
        winLossTrackerFrame:SetBackdrop({
              bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", 
              edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", 
              tile=1, tileSize=32, edgeSize=32, 
              insets={left=11, right=12, top=12, bottom=11}
        })

        -- Create Frame for Border -- 
        borderlol = CreateFrame("ScrollFrame", nil, winLossTrackerFrame)
        borderlol:SetPoint("TOPLEFT", 175, -125)
        borderlol:SetPoint("BOTTOMRIGHT", -35, 20)
        borderlol:SetBackdrop({
              bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", 
              edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", 
              tile=1, tileSize=32, edgeSize=32, 
              insets={left=11, right=12, top=12, bottom=11}
        })

        -- Creates Scroll Frame for Parent Frame -- 
        wltfScrollFrame = CreateFrame("ScrollFrame", nil, winLossTrackerFrame)
        wltfScrollFrame:SetPoint("TOPLEFT", 190, -140)
        wltfScrollFrame:SetPoint("BOTTOMRIGHT", -50, 35)

        -- Creates Scroll Bar for Parent Frame-- 
        wltfScrollBar = CreateFrame("Slider", "ScrollBar", wltfScrollFrame, "UIPanelScrollBarTemplate")
        wltfScrollBar:SetPoint("TOPLEFT", winLossTrackerFrame, "TOPRIGHT", -30, -140)
        wltfScrollBar:SetPoint("BOTTOMLEFT", winLossTrackerFrame, "BOTTOMRIGHT", -30, 35)
        wltfScrollBar:SetMinMaxValues(0, 0)
        wltfScrollBar:SetValueStep(1)
        wltfScrollBar.scrollStep = 1
        wltfScrollBar:SetWidth(16)
        wltfScrollBar:SetScript("OnValueChanged",
                function (self, value)
                        scrollFrameContent:SetScrollOffset(select(2, wltfScrollBar:GetMinMaxValues()) - value)
                        self:GetParent():SetVerticalScroll(value)
                end)
        scrollbackground = wltfScrollBar:CreateTexture(nil, "BACKGROUND")
        scrollbackground:SetAllPoints(wltfScrollBar)
        scrollbackground:SetTexture(0, 0, 0, 0)
        winLossTrackerFrame.wltfScrollBar = wltfScrollBar

        -- Creates Content for Parent Frame -- 
        scrollFrameContent = CreateFrame("ScrollingMessageFrame", nil, winLossTrackerFrame)
        scrollFrameContent:SetPoint("TOPLEFT", 190, -140)
        scrollFrameContent:SetPoint("BOTTOMRIGHT", -50, 35)
        scrollFrameContent:SetSize(760, 525)
        scrollFrameContent:SetHyperlinksEnabled(true)
        scrollFrameContent:SetFading(false)

        wltfScrollFrame:SetScrollChild(scrollFrameContent) 
        wltfScrollBar:SetValue(select(2, wltfScrollBar:GetMinMaxValues()))
	winLossTrackerFrame:SetScript("OnMouseWheel", function(self, delta)	
		local cur_val = wltfScrollBar:GetValue()
		local min_val, max_val = wltfScrollBar:GetMinMaxValues()

		if delta < 0 and cur_val < max_val then
			cur_val = math.min(max_val, cur_val + 30)
			wltfScrollBar:SetValue(cur_val)			
		elseif delta > 0 and cur_val > min_val then
			cur_val = math.max(min_val, cur_val - 30)
			wltfScrollBar:SetValue(cur_val)		
		end	
	 end)

        -- Exit Button For Top Right -- 
        exitFrame = CreateFrame("Frame", nil, winLossTrackerFrame)
        exitFrame:SetSize(24, 24)
        exitFrame:SetAllPoints()
        exitFrame.btn = CreateFrame("Button", nil, exitFrame, "UIPanelButtonTemplate")
        exitFrame.btn:SetSize(24, 24)
        exitFrame.btn:SetText("X")
        exitFrame.btn:SetPoint("TOPRIGHT", -12, -12)
        exitFrame.btn:SetAlpha(1)
        exitFrame.btn:Show()
        exitFrame.btn:SetScript("OnClick", function() winLossTrackerFrame:Hide() end)

        -- Creates "Fetch" Button for Parent Frame -- 
        fetchButtonFrame = CreateFrame("Frame", nil, winLossTrackerFrame)
        fetchButtonFrame:SetSize(150, 50)
        fetchButtonFrame:SetAllPoints()
        fetchButtonFrame.btn = CreateFrame("Button", nil, fetchButtonFrame, "UIPanelButtonTemplate")
        fetchButtonFrame.btn:SetSize(150, 50)
        fetchButtonFrame.btn:SetText("Fetch!")
        fetchButtonFrame.btn:SetPoint("TOP", winLossTrackerFrame, "TOP", 350, -50)
        fetchButtonFrame.btn:SetScript("OnClick", 
            function()
                for k,v in pairs (player) do
                    keyStorage1 = k
                    -- Sorts all 2v2 teams by class. If class is same then by name. --
                    for k,v in pairs (v.twoEnemyArenaTeams) do 
                        sortboolean = true
                        while (sortboolean) do
                            sortboolean = sort2v2(v)
                        end
                    end
                    -- Sorts all 3v3 teams by class. If class is same then by name. -- 
                    for k,v in pairs (v.threeEnemyArenaTeams) do
                        sortboolean = true
                        while (sortboolean) do
                            sortboolean = sort3v3(v)
                        end
                    end
                    -- Sorts all 5v5 teams by class. If class is same then by name. -- 
                    for k,v in pairs (v.fiveEnemyArenaTeams) do
                        sortboolean = true
                        while (sortboolean) do
                            sortboolean = sort5v5(v)
                        end
                    end

                    -- Temporary fix for empty specific player tables causing sorting LUA errors -- 
                    local emptyCount = 0
                    for k,v in pairs (v.specificPlayer) do
                        if (v.specificEnemy == nil) then
                            v.specificEnemy = "Empty Placeholder, Fix it Value!"
                        end
                    end


                    -- Sorts Specific Players Table By Name -- 
                    table.sort(v.specificPlayer, function (object1, object2) return object1.specificEnemy < object2.specificEnemy end)
                    -- Sorts 2v2 by Win/Loss Ratio --
                    table.sort(v.twoEnemyArenaTeams, sortTwoArenaTeams)
                    -- Sorts 3v3 by Win/Loss Ratio -- 
                    table.sort(v.threeEnemyArenaTeams, sortThreeArenaTeams)
                    -- Sorts 5v5 by Win/Loss Ratio -- 
                    table.sort(v.fiveEnemyArenaTeams, sortFiveArenaTeams)
                end

                if (bracketChoice ~= nil and playerChoice ~= nil and enemyChoice ~= nil) then
                    fetchResults()
                end
            end)
        fetchButtonFrame.btn:SetAlpha(1)
        fetchButtonFrame.btn:Show()

        -- Creates "Arena Dropdown Menu" for Parent Frame -- 
        if not arenaDropDownMenu then
           CreateFrame("Button", "arenaDropDownMenu", winLossTrackerFrame, "UIDropDownMenuTemplate")
        end

        arenaDropDownMenu:ClearAllPoints()
        arenaDropDownMenu:SetPoint("TOP", winLossTrackerFrame, "TOP", -325, -62)
        arenaDropDownMenu:Show()

        -- Items For Drop Down Menu -- 
        local arenaItems = {
           "Step 1",
           "2v2",
           "3v3",
           "5v5",
        }

        local function OnClick(self)
            UIDropDownMenu_SetSelectedID(arenaDropDownMenu, self:GetID())
            if (self:GetID() == 1) then
                bracketChoice = nil
            elseif (self:GetID() == 2) then
                bracketChoice = "2v2"
            elseif (self:GetID() == 3) then
                bracketChoice = "3v3"
            elseif (self:GetID() == 4) then
                bracketChoice = "5v5"
            end
            populatePlayerItems()
        end

        local function initialize(self, level)
           local info = UIDropDownMenu_CreateInfo()
           for k,v in pairs(arenaItems) do
              info = UIDropDownMenu_CreateInfo()
              info.text = v
              info.value = v
              info.func = OnClick
              UIDropDownMenu_AddButton(info, level)
           end
        end

        UIDropDownMenu_Initialize(arenaDropDownMenu, initialize)
        UIDropDownMenu_SetWidth(arenaDropDownMenu, 125);
        UIDropDownMenu_SetButtonWidth(arenaDropDownMenu, 124)
        UIDropDownMenu_SetSelectedID(arenaDropDownMenu, 1)
        UIDropDownMenu_JustifyText(arenaDropDownMenu, "LEFT")

        -- Creates "Enemy Dropdown Menu" for Parent Frame -- 
        if not EnemyDropDownMenu then
            CreateFrame("Button", "EnemyDropDownMenu", winLossTrackerFrame, "UIDropDownMenuTemplate")
        end

        EnemyDropDownMenu:ClearAllPoints()
        EnemyDropDownMenu:SetPoint("TOP", winLossTrackerFrame, "TOP", 125, -62)
        EnemyDropDownMenu:Show()

        -- Items For Drop Down Menu -- 
        enemyItems = {
            "Step 3",
            "Arena Teams",
            "Specific Players",
            }

        local function OnClick(self)
            UIDropDownMenu_SetSelectedID(EnemyDropDownMenu, self:GetID())
            if (self:GetID() == 1) then
                enemyChoice = nil
                deathKnightCheckBox:Hide()
                druidCheckBox:Hide()
                hunterCheckBox:Hide()
                mageCheckBox:Hide()
                monkCheckBox:Hide()
                paladinCheckBox:Hide()
                priestCheckBox:Hide()
                rogueCheckBox:Hide()
                shamanCheckBox:Hide()
                warlockCheckBox:Hide()
                warriorCheckBox:Hide()
            elseif (self:GetID() == 2) then
                enemyChoice = "Arena Teams"
                deathKnightCheckBox:Show()
                druidCheckBox:Show()
                hunterCheckBox:Show()
                mageCheckBox:Show()
                monkCheckBox:Show()
                paladinCheckBox:Show()
                priestCheckBox:Show()
                rogueCheckBox:Show()
                shamanCheckBox:Show()
                warlockCheckBox:Show()
                warriorCheckBox:Show()
            elseif (self:GetID() == 3) then
                enemyChoice = "Specific Players"
                deathKnightCheckBox:Hide()
                druidCheckBox:Hide()
                hunterCheckBox:Hide()
                mageCheckBox:Hide()
                monkCheckBox:Hide()
                paladinCheckBox:Hide()
                priestCheckBox:Hide()
                rogueCheckBox:Hide()
                shamanCheckBox:Hide()
                warlockCheckBox:Hide()
                warriorCheckBox:Hide()
            end
        end

        local function initialize(self, level)
           local info = UIDropDownMenu_CreateInfo()
           for k,v in pairs(enemyItems) do
              info = UIDropDownMenu_CreateInfo()
              info.text = v
              info.value = v
              info.func = OnClick
              UIDropDownMenu_AddButton(info, level)
           end
        end

        UIDropDownMenu_Initialize(EnemyDropDownMenu, initialize)
        UIDropDownMenu_SetWidth(EnemyDropDownMenu, 125);
        UIDropDownMenu_SetButtonWidth(EnemyDropDownMenu, 124)
        UIDropDownMenu_SetSelectedID(EnemyDropDownMenu, 1)
        UIDropDownMenu_JustifyText(EnemyDropDownMenu, "LEFT")

        -- Creates "Player Dropdown Menu" for Parent Frame -- 
        if not PlayerDropDownMenu then
           CreateFrame("Button", "PlayerDropDownMenu", winLossTrackerFrame, "UIDropDownMenuTemplate")
        end

        PlayerDropDownMenu:ClearAllPoints()
        PlayerDropDownMenu:SetPoint("TOP", winLossTrackerFrame, "TOP", -100, -62)
        PlayerDropDownMenu:Show()

        local function OnClick(self)
            UIDropDownMenu_SetSelectedID(PlayerDropDownMenu, self:GetID())
            playerChoice = self:GetID()
            for k,v in pairs(playerItems) do
                if k == playerChoice then
                    playerChoiceName = v
                end
            end
        end

        local function initialize(self, level)
           local info = UIDropDownMenu_CreateInfo()
           for k,v in pairs(playerItems) do
              info = UIDropDownMenu_CreateInfo()
              info.text = v
              info.value = v
              info.func = OnClick
              UIDropDownMenu_AddButton(info, level)
           end
        end

        UIDropDownMenu_Initialize(PlayerDropDownMenu, initialize)
        UIDropDownMenu_SetWidth(PlayerDropDownMenu, 125);
        UIDropDownMenu_SetButtonWidth(PlayerDropDownMenu, 124)
        UIDropDownMenu_SetSelectedID(PlayerDropDownMenu, 1)
        UIDropDownMenu_JustifyText(PlayerDropDownMenu, "LEFT")

        -- Create Text Above Enemy Drop Down Menu -- 
        local enemyDDMText = winLossTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        enemyDDMText:SetPoint("TOP", 105, -48)
        enemyDDMText:SetText("Choose Enemy: ")

        -- Create Text Above Player Drop Down Menu -- 
        local playerDDMText = winLossTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        playerDDMText:SetPoint("TOP", -120, -48)
        playerDDMText:SetText("Choose Profile: ")

        -- Create Text Above Arena Drop Down Menu -- 
        local arenaDDMText = winLossTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        arenaDDMText:SetPoint("TOP", -324, -48)
        arenaDDMText:SetText("Choose Arena Bracket: ")

        -- Create Text Above Arena Drop Down Menu -- 
        local titleText = winLossTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        titleText:SetPoint("TOP", 0, -15)
        titleText:SetText("Win/Loss Tracker")

        -- Create Checkbox for Death Knights -- 
        deathKnightCheckBox = CreateFrame("CheckButton", "DeathKnightCheckBox", winLossTrackerFrame, "ChatConfigCheckButtonTemplate");
        deathKnightCheckBox:SetPoint("TOPLEFT", 30, -150)
        DeathKnightCheckBoxText:SetText(getClassName(1))
        deathKnightCheckBox:SetScript("OnClick", 
            function()
                if deathKnightCheckBox:GetChecked() == 1 then
                    deathKnightBoolean = true
                else
                    deathKnightBoolean = false
                end
            end)

        -- Create Checkbox for Druid -- 
        druidCheckBox = CreateFrame("CheckButton", "DruidCheckBox", winLossTrackerFrame, "ChatConfigCheckButtonTemplate");
        druidCheckBox:SetPoint("TOPLEFT", 30, -200)
        DruidCheckBoxText:SetText(getClassName(2))
        druidCheckBox:SetScript("OnClick", 
            function()
                if druidCheckBox:GetChecked() == 1 then
                    druidBoolean = true
                else
                    druidBoolean = false
                end
            end)

        -- Create Checkbox for Hunter --
        hunterCheckBox = CreateFrame("CheckButton", "HunterCheckBox", winLossTrackerFrame, "ChatConfigCheckButtonTemplate");
        hunterCheckBox:SetPoint("TOPLEFT", 30, -250)
        HunterCheckBoxText:SetText(getClassName(3))
        hunterCheckBox:SetScript("OnClick", 
            function()
                if hunterCheckBox:GetChecked() == 1 then
                    hunterBoolean = true
                else
                    hunterBoolean = false
                end
            end)

        -- Create Checkbox for Mage --
        mageCheckBox = CreateFrame("CheckButton", "MageCheckBox", winLossTrackerFrame, "ChatConfigCheckButtonTemplate");
        mageCheckBox:SetPoint("TOPLEFT", 30, -300)
        MageCheckBoxText:SetText(getClassName(4))
        mageCheckBox:SetScript("OnClick", 
            function()
                if mageCheckBox:GetChecked() == 1 then
                    mageBoolean = true
                else
                    mageBoolean = false
                end
            end)

        -- Create Checkbox for Monk --
        monkCheckBox = CreateFrame("CheckButton", "MonkCheckBox", winLossTrackerFrame, "ChatConfigCheckButtonTemplate");
        monkCheckBox:SetPoint("TOPLEFT", 30, -350)
        MonkCheckBoxText:SetText(getClassName(5))
        monkCheckBox:SetScript("OnClick", 
            function()
                if monkCheckBox:GetChecked() == 1 then
                    monkBoolean = true
                else
                    monkBoolean = false
                end
            end)

        -- Create Checkbox for Paladin --
        paladinCheckBox = CreateFrame("CheckButton", "PaladinCheckBox", winLossTrackerFrame, "ChatConfigCheckButtonTemplate");
        paladinCheckBox:SetPoint("TOPLEFT", 30, -400)
        PaladinCheckBoxText:SetText(getClassName(6))
        paladinCheckBox:SetScript("OnClick", 
            function()
                if paladinCheckBox:GetChecked() == 1 then
                    paladinBoolean = true
                else
                    paladinBoolean = false
                end
            end)

        -- Create Checkbox for Priest --
        priestCheckBox = CreateFrame("CheckButton", "PriestCheckBox", winLossTrackerFrame, "ChatConfigCheckButtonTemplate");
        priestCheckBox:SetPoint("TOPLEFT", 30, -450)
        PriestCheckBoxText:SetText(getClassName(7))
        priestCheckBox:SetScript("OnClick", 
            function()
                if priestCheckBox:GetChecked() == 1 then
                    priestBoolean = true
                else
                    priestBoolean = false
                end
            end)

        -- Create Checkbox for Rogue --
        rogueCheckBox = CreateFrame("CheckButton", "RogueCheckBox", winLossTrackerFrame, "ChatConfigCheckButtonTemplate");
        rogueCheckBox:SetPoint("TOPLEFT", 30, -500)
        RogueCheckBoxText:SetText(getClassName(8))
        rogueCheckBox:SetScript("OnClick", 
            function()
                if rogueCheckBox:GetChecked() == 1 then
                    rogueBoolean = true
                else
                    rogueBoolean = false
                end
            end)

        -- Create Checkbox for Shaman --
        shamanCheckBox = CreateFrame("CheckButton", "ShamanCheckBox", winLossTrackerFrame, "ChatConfigCheckButtonTemplate");
        shamanCheckBox:SetPoint("TOPLEFT", 30, -550)
        ShamanCheckBoxText:SetText(getClassName(9))
        shamanCheckBox:SetScript("OnClick", 
            function()
                if shamanCheckBox:GetChecked() == 1 then
                    shamanBoolean = true
                else
                    shamanBoolean = false
                end
            end)

        -- Create Checkbox for Warlock --
        warlockCheckBox = CreateFrame("CheckButton", "WarlockCheckBox", winLossTrackerFrame, "ChatConfigCheckButtonTemplate");
        warlockCheckBox:SetPoint("TOPLEFT", 30, -600)
        WarlockCheckBoxText:SetText(getClassName(10))
        warlockCheckBox:SetScript("OnClick", 
            function()
                if warlockCheckBox:GetChecked() == 1 then
                    warlockBoolean = true
                else
                    warlockBoolean = false
                end
            end)

        -- Create Checkbox for Warrior --
        warriorCheckBox = CreateFrame("CheckButton", "WarriorCheckBox", winLossTrackerFrame, "ChatConfigCheckButtonTemplate");
        warriorCheckBox:SetPoint("TOPLEFT", 30, -650)
        WarriorCheckBoxText:SetText(getClassName(11))
        warriorCheckBox:SetScript("OnClick", 
            function()
                if warriorCheckBox:GetChecked() == 1 then
                    warriorBoolean = true
                else
                    warriorBoolean = false
                end
            end) 

        deathKnightCheckBox:Hide()
        druidCheckBox:Hide()
        hunterCheckBox:Hide()
        mageCheckBox:Hide()
        monkCheckBox:Hide()
        paladinCheckBox:Hide()
        priestCheckBox:Hide()
        rogueCheckBox:Hide()
        shamanCheckBox:Hide()
        warlockCheckBox:Hide()
        warriorCheckBox:Hide()
    elseif (winLossTrackerFrame:IsShown()) then
        winLossTrackerFrame:Hide()
    elseif (not winLossTrackerFrame:IsShown()) then
        winLossTrackerFrame:Show()
    end
end

---------- Everything Below This Point Deals With Data Structure -----------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- I create a "Player" class which will be created any time the user logs --
-- in to a new character. If there is already a profile for that          --
-- character then a new class will not be created. For every "Player"     --
-- class created there should be information regarding what arena teams   --
-- that player has gone up against.                                       --

-- Player Class To Create New Profiles -- 
Player = {}
Player.__index = Player
function Player:new(playerName, playerRealm)
    local object = {
        playerName = playerName, 
        playerRealm = playerRealm,
        twoEnemyArenaTeams = {},
        threeEnemyArenaTeams = {},
        fiveEnemyArenaTeams = {},
        specificPlayer = {}, 
    }   
    setmetatable(object, Player)
    return object
end

-- Functions That Add Enemy Arena Teams -- 
-- 2v2 Arenas -- 
function Player:add2v2ArenaTeam()
    local newArenaTeam = twovtwoEnemyArenaTeam:new(storeEnemy1, storeEnemy2, storeClass1, storeClass2)
    table.insert(self.twoEnemyArenaTeams, newArenaTeam)
    -- Adds win or loss to the most recent 2v2 team added to database -- 
    for k,v in pairs (self.twoEnemyArenaTeams) do
        check1 = tContains2v2(v, storeEnemy1)
        check2 = tContains2v2(v, storeEnemy2)
        -- Add Win Or Loss If Arena Team Exists -- 
        if (check1 and check2) then
            -- Add Win Or Loss to 2v2 team
            if (teamName == playersTeam2v2) then
                v.win = v.win + 1
            elseif (teamName ~= playersTeam2v2) then
                v.loss = v.loss + 1
            end
        end
    end
    catchCount = catchCount + 1
    clearVariables()
end
-- 3v3 Arenas -- 
function Player:add3v3ArenaTeam()
    local newArenaTeam = threevthreeEnemyArenaTeam:new(storeEnemy1, storeEnemy2, storeEnemy3, storeClass1, storeClass2, storeClass3)
    table.insert(self.threeEnemyArenaTeams, newArenaTeam)
    for k,v in pairs (self.threeEnemyArenaTeams) do
        check1 = tContains3v3(v, storeEnemy1)
        check2 = tContains3v3(v, storeEnemy2)
        check3 = tContains3v3(v, storeEnemy3)
        -- Add Win Or Loss If Arena Team Exists -- 
        if (check1 and check2 and check3) then
            -- Add Win Or Loss to 3v3 team
            if (teamName == playersTeam3v3) then
                v.win = v.win + 1
            elseif (teamName ~= playersTeam3v3) then
                v.loss = v.loss + 1
            end
        end
    end
    catchCount = catchCount + 1
    clearVariables()
end
-- 5v5 Arenas -- 
function Player:add5v5ArenaTeam()
    local newArenaTeam = fivevfiveEnemyArenaTeam:new(storeEnemy1, storeEnemy2, storeEnemy3, storeEnemy4, storeEnemy5, storeClass1, storeClass2, storeClass3, storeClass4, storeClass5)
    table.insert(self.fiveEnemyArenaTeams, newArenaTeam)
    for k,v in pairs (self.fiveEnemyArenaTeams) do
        check1 = tContains5v5(v, storeEnemy1)
        check2 = tContains5v5(v, storeEnemy2)
        check3 = tContains5v5(v, storeEnemy3)
        check4 = tContains5v5(v, storeEnemy4)
        check5 = tContains5v5(v, storeEnemy5)
        -- Add Win Or Loss If Arena Team Exists -- 
        if (check1 and check2 and check3 and check4 and check5) then
            -- Add Win Or Loss to 5v5 team
            if (teamName == playersTeam5v5) then
                v.win = v.win + 1
            elseif (teamName ~= playersTeam5v5) then
                v.loss = v.loss + 1
            end
        end
    end
    catchCount = catchCount + 1
    clearVariables()
end

-- Function That Adds Specific Players To Profile --
function Player:addSpecificPlayer() 
    if (specific1 == 1) then
        if (tostring(storeEnemy1) ~= nil) then
            local newSpecificPlayer = SpecificPlayer:new(storeEnemy1, storeClass1)
            table.insert(self.specificPlayer, newSpecificPlayer)
        elseif (tostring(storeEnemy1) == nil) then
        end
    end
    if (specific2 == 1) then
        if (tostring(storeEnemy2) ~= nil) then
            local newSpecificPlayer = SpecificPlayer:new(storeEnemy2, storeClass2)
            table.insert(self.specificPlayer, newSpecificPlayer)
        elseif (tostring(storeEnemy2) == nil) then
        end
    end
    if (specific3 == 1) then
        if (tostring(storeEnemy3) ~= nil) then
            local newSpecificPlayer = SpecificPlayer:new(storeEnemy3, storeClass3)
            table.insert(self.specificPlayer, newSpecificPlayer)
        elseif (tostring(storeEnemy3) == nil) then
        end
    end
    if (specific4 == 1) then
        if (tostring(storeEnemy4) ~= nil) then
            local newSpecificPlayer = SpecificPlayer:new(storeEnemy4, storeClass4)
            table.insert(self.specificPlayer, newSpecificPlayer)
        elseif (tostring(storeEnemy4) == nil) then
        end
    end
    if (specific5 == 1) then
        if (tostring(storeEnemy5) ~= nil) then
            local newSpecificPlayer = SpecificPlayer:new(storeEnemy5, storeClass5)
            table.insert(self.specificPlayer, newSpecificPlayer)
        elseif (tostring(storeEnemy5) == nil) then
        end
    end
    specific1 = 0
    specific2 = 0
    specific3 = 0
    specific4 = 0
    specific5 = 0
end

-- Add 2v2 Arena Team Class --
twovtwoEnemyArenaTeam = {}
twovtwoEnemyArenaTeam.__index = twovtwoEnemyArenaTeam
function twovtwoEnemyArenaTeam:new(enemy1, enemy2, enemyClass1, enemyClass2)
    local object = {
        enemy1 = enemy1,
        enemy2 = enemy2,
        enemyClass1 = enemyClass1,
        enemyClass2 = enemyClass2,
        win = 0,
        loss = 0,
        draw = 0,
    }
    setmetatable(object, twovtwoEnemyArenaTeam)
    return object
end

-- Add 3v3 Arena Team Class -- 
threevthreeEnemyArenaTeam = {}
threevthreeEnemyArenaTeam.__index = threevthreeEnemyArenaTeam
function threevthreeEnemyArenaTeam:new(enemy1, enemy2, enemy3, enemyClass1, enemyClass2, enemyClass3)
    local object = {
        enemy1 = enemy1,
        enemy2 = enemy2,
        enemy3 = enemy3,
        enemyClass1 = enemyClass1,
        enemyClass2 = enemyClass2,
        enemyClass3 = enemyClass3,
        win = 0,
        loss = 0,
        draw = 0,
    }
    setmetatable(object, threevthreeEnemyArenaTeam)
    return object
end

-- Add 5v5 Arena Team Class -- 
fivevfiveEnemyArenaTeam = {}
fivevfiveEnemyArenaTeam.__index = fivevfiveEnemyArenaTeam
function fivevfiveEnemyArenaTeam:new(enemy1, enemy2, enemy3, enemy4, enemy5, enemyClass1, enemyClass2, enemyClass3, enemyClass4, enemyClass5)
    local object = {
        enemy1 = enemy1,
        enemy2 = enemy2,
        enemy3 = enemy3,
        enemy4 = enemy4,
        enemy5 = enemy5,
        enemyClass1 = enemyClass1,
        enemyClass2 = enemyClass2,
        enemyClass3 = enemyClass3,
        enemyClass4 = enemyClass4,
        enemyClass5 = enemyClass5,
        win = 0,
        loss = 0,
        draw = 0,
    }
    setmetatable(object, threevthreeEnemyArenaTeam)
    return object
end

-- Specific Player Class To Add Specific Players To The Database -- 
SpecificPlayer = {}
SpecificPlayer.__index = SpecificPlayer
function SpecificPlayer:new(specificEnemy, specificEnemyClass)
    local object = {
        specificEnemy = specificEnemy,
        specificEnemyClass = specificEnemyClass
    }
    setmetatable(object, SpecificPlayer)
    return object
end

-- Everything Below This Point Deals With Events And Adding Teams To Data -- 
-- Structure --
----------------------------------------------------------------------------
----------------------------------------------------------------------------

-- Create Frame To Check for WoW Events To Add To Data Structure -- 
local wowEvents = CreateFrame("Frame")

-- More WoW Events Being Tracked -- 
wowEvents:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
wowEvents:RegisterEvent("ARENA_OPPONENT_UPDATE")
wowEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
wowEvents:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

function wowEvents:OnEvent(event, arg1)
    -- Code To Store Enemy Arena Names -- 
    local pvpType, isFFA, faction = GetZonePVPInfo()
    if (("ARENA_OPPONENT_UPDATE" == event or "COMBAT_LOG_EVENT_UNFILTERED" == event) and tostring(pvpType) == "arena") then
        isUnratedArena, isRatedArena = IsActiveBattlefieldArena()
        if (isUnratedArena or isRatedArena) then
            temporary1 = GetUnitName("arena1", true)
            temporary2 = GetUnitName("arena2", true)
            temporary3 = GetUnitName("arena3", true)
            temporary4 = GetUnitName("arena4", true)
            temporary5 = GetUnitName("arena5", true)
            if (temporary1 ~= "Unknown") then
                if (temporary1 ~= nil) then
                    if (temporary1boolean ~= true) then
                        storeEnemy1 = GetUnitName("arena1", true)
                        localizedClass1, storeClass1, classIndex1 = UnitClass("arena1");
                        temporary1boolean = true
                    end
                end
            end
            if (temporary2 ~= "Unknown") then
                if (temporary2 ~= nil) then
                    if (temporary2boolean ~= true) then
                        storeEnemy2 = GetUnitName("arena2", true)
                        localizedClass2, storeClass2, classIndex2 = UnitClass("arena2");
                        temporary2boolean = true
                    end
                end
            end
            if (temporary3 ~= "Unknown") then
                if (temporary3 ~= nil) then
                    if (temporary3boolean ~= true) then
                        storeEnemy3 = GetUnitName("arena3", true)
                        localizedClass3, storeClass3, classIndex3 = UnitClass("arena3");
                        temporary3boolean = true
                    end
                end
            end
            if (temporary4 ~= "Unknown") then
                if (temporary4 ~= nil) then
                    if (temporary4boolean ~= true) then
                        storeEnemy4 = GetUnitName("arena4", true)
                        localizedClass4, storeClass4, classIndex4 = UnitClass("arena4");
                        temporary4boolean = true
                    end
                end
            end
            if (temporary5 ~= "Unknown") then
                if (temporary5 ~= nil) then   
                    if (temporary5boolean ~= true) then
                        storeEnemy5 = GetUnitName("arena5", true)
                        localizedClass5, storeClass5, classIndex5 = UnitClass("arena5");
                        temporary5boolean = true
                    end
                end
            end
        end
    end

    -- Checks Scoreboard To See If You Won -- 
    if ("UPDATE_BATTLEFIELD_STATUS" == event) then
    isUnratedArena, isRatedArena = IsActiveBattlefieldArena()
        if (isRatedArena or isUnratedArena) then
        havana = getCorrectTeams()
        battlefieldWinner = GetBattlefieldWinner()
        if battlefieldWinner ~= nil then
            teamName, oldTeamRating, newTeamRating, teamRating = GetBattlefieldTeamInfo(battlefieldWinner);
        end
        arenaTeamExists = 0
        catchCount = 0
            for k,v in pairs (player) do
                if (v.playerName == playerName) then
                    if (temporary1boolean == true and temporary2boolean == true and temporary3boolean == false and temporary4boolean == false and temporary5boolean == false) then
                        -- Checks if specific player is already in database -- 
                        checkSpecificPlayer1 = tContainsSpecificPlayer(v.specificPlayer, storeEnemy1)
                        checkSpecificPlayer2 = tContainsSpecificPlayer(v.specificPlayer, storeEnemy2)
                        -- Add player to database if needed --
                        if (not checkSpecificPlayer1) then
                            specific1 = specific1 + 1
                        end
                        if (not checkSpecificPlayer2) then
                            specific2 = specific2 + 1
                        end
                        -- Checks If 2v2 Arena Team Already Exists -- 
                        for k,v in pairs (v.twoEnemyArenaTeams) do
                            check1 = tContains2v2(v, storeEnemy1)
                            check2 = tContains2v2(v, storeEnemy2)
                            -- Add Win Or Loss If Arena Team Exists -- 
                            if (check1 and check2) then
                            catchCount = catchCount + 1
                                -- Add Win Or Loss to 2v2 team
                                if (teamName == playersTeam2v2) then
                                        v.win = v.win + 1
                                elseif (teamName ~= playersTeam2v2) then
                                        v.loss = v.loss + 1
                                end
                                arenaTeamExists = arenaTeamExists + 1
                                clearVariables()
                            end
                        end
                        -- Add Specific Players If They Do Not Exist -- 
                        if (specific1 == 1 or specific2 == 1) then 
                            Player.addSpecificPlayer(v)
                        end
                        -- Add Arena Team If It Does Not Exist -- 
                        if (arenaTeamExists == 0) then
                            Player.add2v2ArenaTeam(v)
                        end    
                    elseif (temporary1boolean == true and temporary2boolean == true and temporary3boolean == true and temporary4boolean == false and temporary5boolean == false) then
                        -- Checks if specific player is already in database -- 
                        checkSpecificPlayer1 = tContainsSpecificPlayer(v.specificPlayer, storeEnemy1)
                        checkSpecificPlayer2 = tContainsSpecificPlayer(v.specificPlayer, storeEnemy2)
                        checkSpecificPlayer3 = tContainsSpecificPlayer(v.specificPlayer, storeEnemy3)
                        -- Add player to database if needed --
                        if (not checkSpecificPlayer1) then
                            specific1 = specific1 + 1
                        end
                        if (not checkSpecificPlayer2) then
                            specific2 = specific2 + 1
                        end
                        if (not checkSpecificPlayer3) then
                            specific3 = specific3 + 1
                        end
                        -- Checks If 3v3 Arena Team Already Exists -- 
                        for k,v in pairs (v.threeEnemyArenaTeams) do
                            check1 = tContains3v3(v, storeEnemy1)
                            check2 = tContains3v3(v, storeEnemy2)
                            check3 = tContains3v3(v, storeEnemy3)
                            -- Add Win Or Loss If Arena Team Exists -- 
                            if (check1 and check2 and check3) then
                            catchCount = catchCount + 1
                                  -- Add Win Or Loss to 3v3 team
                                if (teamName == playersTeam3v3) then
                                        v.win = v.win + 1
                                elseif (teamName ~= playersTeam3v3) then
                                        v.loss = v.loss + 1
                                end
                                arenaTeamExists = arenaTeamExists + 1
                                clearVariables()
                            end
                        end
                        -- Add Specific Players If They Do Not Exist -- 
                        if (specific1 == 1 or specific2 == 1 or specific3 == 1) then 
                            Player.addSpecificPlayer(v)
                        end
                        -- Add Arena Team If It Does Not Exist -- 
                        if (arenaTeamExists == 0) then
                            Player.add3v3ArenaTeam(v)
                        end         
                    elseif (temporary1boolean == true and temporary2boolean == true and temporary3boolean == true and temporary4boolean == true and temporary5boolean == true) then
                        -- Checks if specific player is already in database -- 
                        checkSpecificPlayer1 = tContainsSpecificPlayer(v.specificPlayer, storeEnemy1)
                        checkSpecificPlayer2 = tContainsSpecificPlayer(v.specificPlayer, storeEnemy2)
                        checkSpecificPlayer3 = tContainsSpecificPlayer(v.specificPlayer, storeEnemy3)
                        checkSpecificPlayer4 = tContainsSpecificPlayer(v.specificPlayer, storeEnemy4)
                        checkSpecificPlayer5 = tContainsSpecificPlayer(v.specificPlayer, storeEnemy5)
                        -- Add player to database if needed --
                        if (not checkSpecificPlayer1) then
                            specific1 = specific1 + 1
                        end
                        if (not checkSpecificPlayer2) then
                            specific2 = specific2 + 1
                        end
                        if (not checkSpecificPlayer3) then
                            specific3 = specific3 + 1
                        end
                        if (not checkSpecificPlayer4) then
                            specific4 = specific4 + 1
                        end
                        if (not checkSpecificPlayer5) then
                            specific5 = specific5 + 1
                        end                            
                        -- Checks If 5v5 Arena Team Already Exists -- 
                        for k,v in pairs (v.fiveEnemyArenaTeams) do
                            check1 = tContains5v5(v, storeEnemy1)
                            check2 = tContains5v5(v, storeEnemy2)
                            check3 = tContains5v5(v, storeEnemy3)
                            check4 = tContains5v5(v, storeEnemy4)
                            check5 = tContains5v5(v, storeEnemy5)
                            -- Add Win Or Loss If Arena Team Exists -- 
                            if (check1 and check2 and check3 and check4 and check5) then
                            catchCount = catchCount + 1
                                   -- Add Win Or Loss to 5v5 team
                                if (teamName == playersTeam5v5) then
                                        v.win = v.win + 1
                                elseif (teamName ~= playersTeam5v5) then
                                        v.loss = v.loss + 1
                                end
                                arenaTeamExists = arenaTeamExists + 1
                                clearVariables()
                            end
                        end
                        -- Add Specific Players If They Do Not Exist -- 
                        if (specific1 == 1 or specific2 == 1 or specific3 == 1 or specific4 == 1 or specific5 == 1) then 
                            Player.addSpecificPlayer(v)
                        end
                        -- Add Arena Team If It Does Not Exist -- 
                        if (arenaTeamExists == 0) then
                            Player.add5v5ArenaTeam(v)
                        end         
                    end
                end
            end
        end
    end
    
    -- If Player Leaves Arena (Automatic Loss Against The Other Team) -- 
    -- If player loses arena make sure you catch and dump the information to the correct area just incase
    -- After check to see if battlefieldWinner is nil to add loss to player leaving arena
    if ("PLAYER_ENTERING_WORLD" == event) then
    temporary1 = "Unknown"
    temporary2 = "Unknown"
    temporary3 = "Unknown"
    temporary4 = "Unknown"
    temporary5 = "Unknown"
    arenaTeamExists = 0
    isUnratedArena, isRatedArena = IsActiveBattlefieldArena()
    if (isUnratedArena or isRatedArena) then
        clearVariables()
    end
        if (catchCount == 0 and isRatedArena == nil and isUnratedArena == nil)  then
            for k,v in pairs (player) do
                if (v.playerName == playerName) then
                    if (temporary1boolean == true and temporary2boolean == true and temporary3boolean == false and temporary4boolean == false and temporary5boolean == false) then
                        -- Checks if specific player is already in database -- 
                        checkSpecificPlayer1 = tContainsSpecificPlayer(v.specificPlayer, storeEnemy1)
                        checkSpecificPlayer2 = tContainsSpecificPlayer(v.specificPlayer, storeEnemy2)
                        -- Add player to database if needed --
                        if (not checkSpecificPlayer1) then
                            specific1 = specific1 + 1
                        end
                        if (not checkSpecificPlayer2) then
                            specific2 = specific2 + 1
                        end
                        -- Checks If 2v2 Arena Team Already Exists -- 
                        for k,v in pairs (v.twoEnemyArenaTeams) do
                            check1 = tContains2v2(v, storeEnemy1)
                            check2 = tContains2v2(v, storeEnemy2)
                            -- Add Win Or Loss If Arena Team Exists -- 
                            if (check1 and check2) then
                                -- Add Win Or Loss to 2v2 team
                                if (teamName == playersTeam2v2) then
                                    v.win = v.win + 1
                                elseif (teamName ~= playersTeam2v2) then
                                    v.loss = v.loss + 1
                                end
                                arenaTeamExists = arenaTeamExists + 1
                                clearVariables()
                            end
                        end
                        -- Add Specific Players If They Do Not Exist -- 
                        if (specific1 == 1 or specific2 == 1) then 
                            Player.addSpecificPlayer(v)
                        end
                        -- Add Arena Team If It Does Not Exist -- 
                        if (arenaTeamExists == 0) then
                            Player.add2v2ArenaTeam(v)
                        end    
                    elseif (temporary1boolean == true and temporary2boolean == true and temporary3boolean == true and temporary4boolean == false and temporary5boolean == false) then
                        -- Checks if specific player is already in database -- 
                        checkSpecificPlayer1 = tContainsSpecificPlayer(v.specificPlayer, storeEnemy1)
                        checkSpecificPlayer2 = tContainsSpecificPlayer(v.specificPlayer, storeEnemy2)
                        checkSpecificPlayer3 = tContainsSpecificPlayer(v.specificPlayer, storeEnemy3)
                        -- Add player to database if needed --
                        if (not checkSpecificPlayer1) then
                            specific1 = specific1 + 1
                        end
                        if (not checkSpecificPlayer2) then
                            specific2 = specific2 + 1
                        end
                        if (not checkSpecificPlayer3) then
                            specific3 = specific3 + 1
                        end                  
                        -- Checks If 3v3 Arena Team Already Exists -- 
                        for k,v in pairs (v.threeEnemyArenaTeams) do
                            check1 = tContains3v3(v, storeEnemy1)
                            check2 = tContains3v3(v, storeEnemy2)
                            check3 = tContains3v3(v, storeEnemy3)
                            -- Add Win Or Loss If Arena Team Exists -- 
                            if (check1 and check2 and check3) then
                                -- Add Win Or Loss to 3v3 team
                                if (teamName == playersTeam3v3) then
                                    v.win = v.win + 1
                                elseif (teamName ~= playersTeam3v3) then
                                    v.loss = v.loss + 1
                                end
                                arenaTeamExists = arenaTeamExists + 1
                                clearVariables()
                            end
                        end
                        -- Add Specific Players If They Do Not Exist -- 
                        if (specific1 == 1 or specific2 == 1 or specific3 == 1) then 
                            Player.addSpecificPlayer(v)
                        end
                        -- Add Arena Team If It Does Not Exist -- 
                        if (arenaTeamExists == 0) then
                            Player.add3v3ArenaTeam(v)
                        end         
                    elseif (temporary1boolean == true and temporary2boolean == true and temporary3boolean == true and temporary4boolean == true and temporary5boolean == true) then
                        -- Checks if specific player is already in database -- 
                        checkSpecificPlayer1 = tContainsSpecificPlayer(v.specificPlayer, storeEnemy1)
                        checkSpecificPlayer2 = tContainsSpecificPlayer(v.specificPlayer, storeEnemy2)
                        checkSpecificPlayer3 = tContainsSpecificPlayer(v.specificPlayer, storeEnemy3)
                        checkSpecificPlayer4 = tContainsSpecificPlayer(v.specificPlayer, storeEnemy4)
                        checkSpecificPlayer5 = tContainsSpecificPlayer(v.specificPlayer, storeEnemy5)
                        -- Add player to database if needed --
                        if (not checkSpecificPlayer1) then
                            specific1 = specific1 + 1
                        end
                        if (not checkSpecificPlayer2) then
                            specific2 = specific2 + 1
                        end
                        if (not checkSpecificPlayer3) then
                            specific3 = specific3 + 1
                        end
                        if (not checkSpecificPlayer4) then
                            specific4 = specific4 + 1
                        end
                        if (not checkSpecificPlayer5) then
                            specific5 = specific5 + 1
                        end                            
                        -- Checks If 5v5 Arena Team Already Exists -- 
                        for k,v in pairs (v.fiveEnemyArenaTeams) do
                            check1 = tContains5v5(v, storeEnemy1)
                            check2 = tContains5v5(v, storeEnemy2)
                            check3 = tContains5v5(v, storeEnemy3)
                            check4 = tContains5v5(v, storeEnemy4)
                            check5 = tContains5v5(v, storeEnemy5)
                            -- Add Win Or Loss If Arena Team Exists -- 
                            if (check1 and check2 and check3 and check4 and check5) then
                                -- Add Win Or Loss to 5v5 team
                                if (teamName == playersTeam5v5) then
                                    v.win = v.win + 1
                                elseif (teamName ~= playersTeam5v5) then
                                    v.loss = v.loss + 1
                                end
                                arenaTeamExists = arenaTeamExists + 1
                                clearVariables()
                            end
                        end
                        -- Add Specific Players If They Do Not Exist -- 
                        if (specific1 == 1 or specific2 == 1 or specific3 == 1 or specific4 == 1 or specific5 == 1) then 
                            Player.addSpecificPlayer(v)
                        end
                        -- Add Arena Team If It Does Not Exist -- 
                        if (arenaTeamExists == 0) then
                            Player.add5v5ArenaTeam(v)
                       end         
                   end
               end
            end
        end
        if catchCount >= 1 then
            catchCount = 0
            clearVariables()
        end
    end
end

-- Set Script For Adding Teams -- 
wowEvents:SetScript("OnEvent", wowEvents.OnEvent)

-- Function to check if 2v2 team already exists -- 
function tContains2v2(table, item)
    if (tostring(table.enemy1) == item or tostring(table.enemy2) == item) then
        return true
    end
    return false
end

-- Function to check if 3v3 team already exists -- 
function tContains3v3(table, item)
    if (tostring(table.enemy1) == item or tostring(table.enemy2) == item or tostring(table.enemy3) == item) then
        return true
    end
    return false
end

-- Function to check if 5v5 team already exists --
function tContains5v5(table, item)
    if (tostring(table.enemy1) == item or tostring(table.enemy2) == item or tostring(table.enemy3) == item or tostring(table.enemy4) == item or tostring(table.enemy5) == item) then
        return true
    end
    return false
end

-- Function to check if specific player already exists -- 
function tContainsSpecificPlayer(table, item)
    if (tostring(table.specificEnemy) == item) then
        return true
    end
    return false
end

-- Function To Clear Variables --
function clearVariables()
    temporary1boolean = false
    temporary2boolean = false
    temporary3boolean = false
    temporary4boolean = false
    temporary5boolean = false
    teamName = nil
    battlefieldWinner = nil
    storeEnemy1 = nil
    storeEnemy2 = nil
    storeEnemy3 = nil
    storeEnemy4 = nil
    storeEnemy5 = nil
    storeClass1 = nil
    storeClass2 = nil
    storeClass3 = nil
    storeClass4 = nil
    storeClass5 = nil
end

-- Sorts 2v2 teams by class then names --
function sort2v2(object)
    local c1 = nil
    local c2 = nil
    local n1 = nil
    local n2 = nil
    if (object.enemyClass1 > object.enemyClass2) then
        c1 = object.enemyClass1
        c2 = object.enemyClass2
        n1 = object.enemy1
        n2 = object.enemy2
        object.enemyClass1 = c2
        object.enemyClass2 = c1
        object.enemy1 = n2
        object.enemy2 = n1
        return true
    elseif (object.enemyClass1 == object.enemyClass2) then
        if (object.enemy1 > object.enemy2) then
            c1 = object.enemyClass1
            c2 = object.enemyClass2
            n1 = object.enemy1
            n2 = object.enemy2
            object.enemyClass1 = c2
            object.enemyClass2 = c1
            object.enemy1 = n2
            object.enemy2 = n1
            return true
        end
    end
end

-- Sorts 3v3 teams by class then names -- 
function sort3v3(object)
    local c1 = nil
    local c2 = nil
    local c3 = nil
    local n1 = nil
    local n2 = nil
    local n3 = nil
    local c1 = nil
    local c2 = nil
    local c3 = nil
    local c4 = nil
    local c5 = nil
    local n1 = nil
    local n2 = nil
    local n3 = nil
    local n4 = nil
    local n5 = nil
    if (object.enemyClass1 > object.enemyClass2) then
        c1 = object.enemyClass1
        c2 = object.enemyClass2
        n1 = object.enemy1
        n2 = object.enemy2
        object.enemyClass1 = c2
        object.enemyClass2 = c1
        object.enemy1 = n2
        object.enemy2 = n1
        return true
    elseif (object.enemyClass1 == object.enemyClass2) then
        if (object.enemy1 > object.enemy2) then
            c1 = object.enemyClass1
            c2 = object.enemyClass2
            n1 = object.enemy1
            n2 = object.enemy2
            object.enemyClass1 = c2
            object.enemyClass2 = c1
            object.enemy1 = n2
            object.enemy2 = n1
            return true
        end
    elseif (object.enemyClass2 > object.enemyClass3) then
        c2 = object.enemyClass2
        c3 = object.enemyClass3
        n2 = object.enemy2
        n3 = object.enemy3
        object.enemyClass2 = c3
        object.enemyClass3 = c2
        object.enemy2 = n3
        object.enemy3 = n2
        return true
    elseif (object.enemyClass2 == object.enemyClass3) then
        if (object.enemy2 > object.enemy3) then
            c2 = object.enemyClass2
            c3 = object.enemyClass3
            n2 = object.enemy2
            n3 = object.enemy3
            object.enemyClass2 = c3
            object.enemyClass3 = c2
            object.enemy2 = n3
            object.enemy3 = n2
            return true
        end
    end
end

-- Sorts 5v5  teams by class then names -- 
function sort5v5(object)
    local c1 = nil
    local c2 = nil
    local c3 = nil
    local c4 = nil
    local c5 = nil
    local n1 = nil
    local n2 = nil
    local n3 = nil
    local n4 = nil
    local n5 = nil
    if (object.enemyClass1 > object.enemyClass2) then
        c1 = object.enemyClass1
        c2 = object.enemyClass2
        n1 = object.enemy1
        n2 = object.enemy2
        object.enemyClass1 = c2
        object.enemyClass2 = c1
        object.enemy1 = n2
        object.enemy2 = n1
        return true
    elseif (object.enemyClass1 == object.enemyClass2) then
        if (object.enemy1 > object.enemy2) then
            c1 = object.enemyClass1
            c2 = object.enemyClass2
            n1 = object.enemy1
            n2 = object.enemy2
            object.enemyClass1 = c2
            object.enemyClass2 = c1
            object.enemy1 = n2
            object.enemy2 = n1
            return true
        end
    elseif (object.enemyClass2 > object.enemyClass3) then
        c2 = object.enemyClass2
        c3 = object.enemyClass3
        n2 = object.enemy2
        n3 = object.enemy3
        object.enemyClass2 = c3
        object.enemyClass3 = c2
        object.enemy2 = n3
        object.enemy3 = n2
        return true
    elseif (object.enemyClass2 == object.enemyClass3) then
        if (object.enemy2 > object.enemy3) then
            c2 = object.enemyClass2
            c3 = object.enemyClass3
            n2 = object.enemy2
            n3 = object.enemy3
            object.enemyClass2 = c3
            object.enemyClass3 = c2
            object.enemy2 = n3
            object.enemy3 = n2
            return true
        end
    elseif (object.enemyClass3 > object.enemyClass4) then
        c3 = object.enemyClass3
        c4 = object.enemyClass4
        n3 = object.enemy3
        n4 = object.enemy4
        object.enemyClass3 = c4
        object.enemyClass4 = c3
        object.enemy3 = n4
        object.enemy4 = n3
        return true
    elseif (object.enemyClass3 == object.enemyClass4) then
        if (object.enemy3 > object.enemy4) then
            c3 = object.enemyClass3
            c4 = object.enemyClass4
            n3 = object.enemy3
            n4 = object.enemy4
            object.enemyClass3 = c4
            object.enemyClass4 = c3
            object.enemy3 = n4
            object.enemy4 = n3
            return true
        end
    elseif (object.enemyClass4 > object.enemyClass5) then
        c4 = object.enemyClass4
        c5 = object.enemyClass5
        n4 = object.enemy4
        n5 = object.enemy5
        object.enemyClass4 = c5
        object.enemyClass5 = c4
        object.enemy4 = n5
        object.enemy5 = n4
        return true
    elseif (object.enemyClass4 == object.enemyClass5) then
        if (object.enemy4 > object.enemy5) then
            c4 = object.enemyClass4
            c5 = object.enemyClass5
            n4 = object.enemy4
            n5 = object.enemy5
            object.enemyClass4 = c5
            object.enemyClass5 = c4
            object.enemy4 = n5
            object.enemy5 = n4
            return true
        end
    end
    return false
end

-- Function To Display Results Onto Scroll Frame -- 
function fetchResults()
    for k,v in pairs (fontStringStorage) do
        v.newString:Hide()
        fontStringStorage[k] = nil
    end
    pCount = 1
    setSpacing = 0
    if (bracketChoice == "2v2") then
        if (enemyChoice == "Arena Teams") then
            get2v2ArenaTeams()
        elseif (enemyChoice == "Specific Players") then
            get2v2SpecificPlayers()
        end
    elseif (bracketChoice == "3v3") then
        if (enemyChoice == "Arena Teams") then
            get3v3ArenaTeams()
        elseif (enemyChoice == "Specific Players") then
            get3v3SpecificPlayers()
        end
    elseif (bracketChoice == "5v5") then
        if (enemyChoice == "Arena Teams") then
            get5v5ArenaTeams()
        elseif (enemyChoice == "Specific Players") then
            get5v5SpecificPlayers()
        end
    end
    local checkIfZero = ((setSpacing * 10) - 450)
    if (checkIfZero >= 0) then
        wltfScrollBar:SetMinMaxValues(0, (setSpacing * 10) - 450)
    elseif (checkIfZero <= 0) then
        wltfScrollBar:SetMinMaxValues(0, 0)
    end
end

-- Grabs 2v2 Arena Teams To Display On Frame -- 
function get2v2ArenaTeams()
    for k,v in pairs (player) do
        if ((v.playerName .. " - " .. v.playerRealm) == playerChoiceName) then
            inputFontStrings(table.concat({v.playerName, "-", v.playerRealm, "vs 2v2 Arena Teams"}, " "))
            setSpacing = setSpacing + 2
            for k,v in pairs (v.twoEnemyArenaTeams) do
                discardTeam = false
                toCheckFor = ifClassCheckIsTrue()
                if (toCheckFor ~= nil) then
                    for i, name in ipairs(toCheckFor) do
                        if v.enemyClass1 == name or v.enemyClass2 == name then
                        else
                           discardTeam = true 
                        end
                    end
                end
                if (discardTeam ~= true) then
                    pCount = pCount + 1
                    inputFontStrings(table.concat({"|r", (pCount - 1), ") Win - Loss:", v.win, " - ", v.loss, " (", round(((v.win / (v.win + v.loss)) * 100)), "%) \n", getClassColor(v.enemyClass1), v.enemy1, "|r, ", getClassColor(v.enemyClass2), v.enemy2}))
                    setSpacing = setSpacing + 4
                end
            end
        end
    end
end

-- Grabs 3v3 Arena Teams To Display On Screen -- 
function get3v3ArenaTeams()
    for k,v in pairs (player) do
        if ((v.playerName .. " - " .. v.playerRealm) == playerChoiceName) then
            inputFontStrings(table.concat({v.playerName, "-", v.playerRealm, "vs 3v3 Arena Teams"}, " "))
            setSpacing = setSpacing + 2
            for k,v in pairs (v.threeEnemyArenaTeams) do
                discardTeam = false
                toCheckFor = ifClassCheckIsTrue()
                if (toCheckFor ~= nil) then
                    for i, name in ipairs(toCheckFor) do
                        if v.enemyClass1 == name or v.enemyClass2 == name or v.enemyClass3 == name then
                        else
                           discardTeam = true 
                        end
                    end
                end
                if (discardTeam ~= true) then
                    pCount = pCount + 1
                    inputFontStrings(table.concat({"|r", (pCount - 1), ") Win - Loss:", v.win, " - ", v.loss, " (", round(((v.win / (v.win + v.loss)) * 100)), "%) \n", getClassColor(v.enemyClass1), v.enemy1, "|r, ", getClassColor(v.enemyClass2), v.enemy2, "|r, ", getClassColor(v.enemyClass3), v.enemy3}))
                    setSpacing = setSpacing + 4
                end
            end
        end
    end
end

-- Grabs 5v5 Arena Teams To Display On Screen -- 
function get5v5ArenaTeams()
    for k,v in pairs (player) do
        if ((v.playerName .. " - " .. v.playerRealm) == playerChoiceName) then
            inputFontStrings(table.concat({v.playerName, "-", v.playerRealm, "vs 5v5 Arena Teams"}, " "))
        setSpacing = setSpacing + 2
        for k,v in pairs (v.fiveEnemyArenaTeams) do
            discardTeam = false
            toCheckFor = ifClassCheckIsTrue()
            if (toCheckFor ~= nil) then
                for i, name in ipairs(toCheckFor) do
                    if v.enemyClass1 == name or v.enemyClass2 == name or v.enemyClass3 == name or v.enemyClass4 == name or v.enemyClass5 == name then
                    else
                        discardTeam = true 
                    end
                end
            end
            if (discardTeam ~= true) then
                pCount = pCount + 1
                inputFontStrings(table.concat({"|r", (pCount - 1), ") Win - Loss:", v.win, " - ", v.loss, " (", round(((v.win / (v.win + v.loss)) * 100)), "%) \n", getClassColor(v.enemyClass1), v.enemy1, "|r, ", getClassColor(v.enemyClass2), v.enemy2, "|r, ", getClassColor(v.enemyClass3), v.enemy3, "\n     ", getClassColor(v.enemyClass4), v.enemy4, "|r, ", getClassColor(v.enemyClass5), v.enemy5}))
                setSpacing = setSpacing + 5
            end
        end
        end
    end
end

-- Grabs 2v2 Specific Players To Display On Screen -- 
function get2v2SpecificPlayers()
    for k,v in pairs (player) do
        if ((v.playerName .. " - " .. v.playerRealm) == playerChoiceName) then
            inputFontStrings(table.concat({v.playerName, "-", v.playerRealm, "vs Specific Players"}, " "))
            for k,v in ipairs (v.specificPlayer) do
                checkContain = false
                specificPlayerExists = checkSpecific2v2Exists(v.specificEnemy)
                if (specificPlayerExists == true) then
                    pCount = pCount + 1
                    setSpacing = setSpacing + 4
                    inputFontStrings(table.concat({"|r", (pCount - 1), ") ", getClassColor(v.specificEnemyClass), v.specificEnemy}))
                    grab2v2SpecificPlayersTeams(v)
                end
            end
        end
    end
end

-- Works With Above Function -- 
function checkSpecific2v2Exists(enemy)
    for k,v in pairs (player) do
        if ((v.playerName .. " - " .. v.playerRealm) == playerChoiceName) then
            for k,v in pairs (v.twoEnemyArenaTeams) do
                checkContain = tContains2v2(v, enemy)
                if (checkContain == true) then
                    return true
                end
            end
        end
     end
     return false
end

-- Works With Above Two Functions -- 
function grab2v2SpecificPlayersTeams(object)
    for k,v in pairs (player) do
        if ((v.playerName .. " - " .. v.playerRealm) == playerChoiceName) then
            for k,v in pairs (v.twoEnemyArenaTeams) do
                if (object.specificEnemy == v.enemy1 or object.specificEnemy == v.enemy2) then
                    setSpacing = setSpacing + 3
                    inputFontStrings(table.concat({"|r          Win - Loss: ", v.win, " - ", v.loss, " (", round(((v.win / (v.win + v.loss)) * 100)), "%) \n", "          ", getClassColor(v.enemyClass1), v.enemy1, "|r, ", getClassColor(v.enemyClass2), v.enemy2}))
                end
            end
        end
    end
end

-- Grabs 3v3 Specific Players To Display On Screen -- 
function get3v3SpecificPlayers()
    for k,v in pairs (player) do
        if ((v.playerName .. " - " .. v.playerRealm) == playerChoiceName) then
            inputFontStrings(table.concat({v.playerName, "-", v.playerRealm, "vs Specific Players"}, " "))
            for k,v in pairs (v.specificPlayer) do
                checkContain = false
                specificPlayerExists = checkSpecific3v3Exists(v.specificEnemy)
                if (specificPlayerExists == true) then
                    pCount = pCount + 1
                    setSpacing = setSpacing + 4
                    inputFontStrings(table.concat({"|r", (pCount - 1), ") ", getClassColor(v.specificEnemyClass), v.specificEnemy}))
                    grab3v3SpecificPlayersTeams(v)
                end
            end
        end
    end
end

-- Works With Above Two Functions -- 
function checkSpecific3v3Exists(enemy)
    for k,v in pairs (player) do
        if ((v.playerName .. " - " .. v.playerRealm) == playerChoiceName) then
            for k,v in pairs (v.threeEnemyArenaTeams) do
                checkContain = tContains3v3(v, enemy)
                if (checkContain == true) then
                    return true
                end
            end
        end
     end
     return false
end

-- Works With Above Two Functions -- 
function grab3v3SpecificPlayersTeams(object)
    for k,v in pairs (player) do
        if ((v.playerName .. " - " .. v.playerRealm) == playerChoiceName) then
            for k,v in pairs (v.threeEnemyArenaTeams) do
                if (object.specificEnemy == v.enemy1 or object.specificEnemy == v.enemy2 or object.specificEnemy == v.enemy3) then
                    setSpacing = setSpacing + 3
                    inputFontStrings(table.concat({"|r          Win - Loss: ", v.win, " - ", v.loss, " (", round(((v.win / (v.win + v.loss)) * 100)), "%) \n", "          ", getClassColor(v.enemyClass1), v.enemy1, "|r, ", getClassColor(v.enemyClass2), v.enemy2, "|r, ", getClassColor(v.enemyClass3), v.enemy3}))
                end
            end
        end
    end
end

-- Grabs 5v5 Specific Players To Display On Screen --
function get5v5SpecificPlayers()
    for k,v in pairs (player) do
        if ((v.playerName .. " - " .. v.playerRealm) == playerChoiceName) then
            inputFontStrings(table.concat({v.playerName, "-", v.playerRealm, "vs Specific Players"}, " "))
            for k,v in pairs (v.specificPlayer) do
                checkContain = false
                specificPlayerExists = checkSpecific5v5Exists(v.specificEnemy)
                if (specificPlayerExists == true) then
                    pCount = pCount + 1
                    setSpacing = setSpacing + 4
                    inputFontStrings(table.concat({"|r", (pCount - 1), ") ", getClassColor(v.specificEnemyClass), v.specificEnemy}))
                    grab5v5SpecificPlayersTeams(v)
                end
            end
        end
    end
end

-- Works With Above Two Functions -- 
function checkSpecific5v5Exists(enemy)
    for k,v in pairs (player) do
        if ((v.playerName .. " - " .. v.playerRealm) == playerChoiceName) then
            for k,v in pairs (v.fiveEnemyArenaTeams) do
                checkContain = tContains5v5(v, enemy)
                if (checkContain == true) then
                    return true
                end
            end
        end
     end
     return false
end

-- Works With Above Two Functions -- 
function grab5v5SpecificPlayersTeams(object)
    for k,v in pairs (player) do
        if ((v.playerName .. " - " .. v.playerRealm) == playerChoiceName) then
            for k,v in pairs (v.fiveEnemyArenaTeams) do
                if (object.specificEnemy == v.enemy1 or object.specificEnemy == v.enemy2 or object.specificEnemy == v.enemy3 or object.specificEnemy == v.enemy4 or object.specificEnemy == v.enemy5) then
                    setSpacing = setSpacing + 4
                    inputFontStrings(table.concat({"|r          Win - Loss: ", v.win, " - ", v.loss, " (", round(((v.win / (v.win + v.loss)) * 100)), "%) \n", "          ", getClassColor(v.enemyClass1), v.enemy1, "|r, ", getClassColor(v.enemyClass2), v.enemy2, "|r, ", getClassColor(v.enemyClass3), v.enemy3, "\n          ", getClassColor(v.enemyClass4), getClassColor(v.enemyClass5), v.enemy4, "|r, ", v.enemy5}))
                end
            end
        end
    end
end

-- If User Included Check Boxes In Search -- 
function ifClassCheckIsTrue()
    checkedClasses = {}
    if deathKnightBoolean == true then
        table.insert(checkedClasses, "DEATHKNIGHT")
    end
    if druidBoolean == true then
        table.insert(checkedClasses, "DRUID")
    end
    if hunterBoolean == true then
        table.insert(checkedClasses, "HUNTER")
    end
    if mageBoolean == true then
        table.insert(checkedClasses, "MAGE")
    end
    if monkBoolean == true then
        table.insert(checkedClasses, "MONK")
    end
    if paladinBoolean == true then
        table.insert(checkedClasses, "PALADIN")
    end
    if priestBoolean == true then
        table.insert(checkedClasses, "PRIEST")
    end
    if rogueBoolean == true then
        table.insert(checkedClasses, "ROGUE")
    end
    if shamanBoolean == true then
        table.insert(checkedClasses, "SHAMAN")
    end
    if warlockBoolean == true then
        table.insert(checkedClasses, "WARLOCK")
    end
    if warriorBoolean == true then
        table.insert(checkedClasses, "WARRIOR")
    end
    return checkedClasses
end

-- Return Colors For Classes To Input To String -- 
function getClassColor(ssClass)
    if (ssClass == "DEATHKNIGHT") then
        return  "|cffC41F3B" 
    elseif (ssClass == "DRUID") then
        return "|cffFF7D0A"
    elseif (ssClass == "HUNTER") then
        return "|cffABD473"
    elseif (ssClass == "MAGE") then
        return "|cff69CCF0"
    elseif (ssClass == "MONK") then
        return "|cff00FF96"
    elseif (ssClass == "PALADIN") then
        return "|cffF58CBA"
    elseif (ssClass == "PRIEST") then
        return "|cffFFFFFF"
    elseif (ssClass == "ROGUE") then
        return "|cffFFF569"
    elseif (ssClass == "SHAMAN") then
        return "|cff0070DE"
    elseif (ssClass == "WARLOCK") then
        return "|cff9482C9"
    elseif (ssClass == "WARRIOR") then
        return "|cffC79C6E"
    end
end

-- Returns  Class Name With Colors For CheckBoxes -- 
function getClassName(number)
    if (number == 1) then
        return  "|cffC41F3B Death Knight" 
    elseif (number == 2) then
        return "|cffFF7D0A Druid"
    elseif (number == 3) then
        return "|cffABD473 Hunter"
    elseif (number == 4) then
        return "|cff69CCF0 Mage"
    elseif (number == 5) then
        return "|cff00FF96 Monk"
    elseif (number == 6) then
        return "|cffF58CBA Paladin"
    elseif (number == 7) then
        return "|cffFFFFFF Priest"
    elseif (number == 8) then
        return "|cffFFF569 Rogue"
    elseif (number == 9) then
        return "|cff0070DE Shaman"
    elseif (number == 10) then
        return "|cff9482C9 Warlock"
    elseif (number == 11) then
        return "|cffC79C6E Warrior"
    end
end

-- Round Percentages -- 
function round(number)
    return (("%d"):format(number))
end

-- Adds FontStrings To Table To Be Output -- 
function inputFontStrings(message)
    local newFontString = HoldFont:new(message)
    table.insert(fontStringStorage, newFontString)
end

-- Add Font -- 
HoldFont = {}
HoldFont.__index = HoldFont
function HoldFont:new(message)
    local newString = scrollFrameContent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    newString:SetPoint("TOPLEFT", scrollFrameContent, "TOPLEFT", 0, setSpacing * -10)
    newString:SetFont("GameFontNormal", 14, nil)
    newString:SetFontObject("GameFontNormal")
    newString:SetJustifyH("LEFT")
    newString:SetText(message)
    local object = {
        newString = newString
    }        
    setmetatable(object, HoldFont)
    return object
end

-- Gettin dem teams yo
function getCorrectTeams() 
    for i = 1, 3, 1 do
        playersTeam, teamSize, teamRating, weekPlayed, weekWins, seasonPlayed, seasonWins, playerPlayed, seasonPlayerPlayed, teamRank, playerRating = GetArenaTeam(i);
        if (teamSize == 2) then
            playersTeam2v2 = playersTeam
        end
        if (teamSize == 3) then
            playersTeam3v3 = playersTeam
        end
        if (teamSize == 5) then
            playersTeam5v5 = playersTeam
        end
    end
end

-- Sort 2v2 tables
function sortTwoArenaTeams(object1, object2)
    if tonumber(object1.win) / (tonumber(object1.win) + tonumber(object1.loss)) > tonumber(object2.win) / (tonumber(object2.win) + tonumber(object2.loss)) then
        return true
    elseif tonumber(object1.win) / (tonumber(object1.win) + tonumber(object1.loss)) == tonumber(object2.win) / (tonumber(object2.win) + tonumber(object2.loss)) then
        if object1.enemyClass1 == object2.enemyClass1 and object1.enemy1 == object2.enemy1 and object1.enemyClass2 == object2.enemyClass2 and object1.enemy2 < object2.enemy2 then
            return true
        elseif object1.enemyClass1 == object2.enemyClass1 and object1.enemy1 == object2.enemy1 and object1.enemyClass2 < object2.enemyClass2 then
            return true
        elseif object1.enemyClass1 == object2.enemyClass1 and object1.enemy1 < object2.enemy1 then
            return true
        elseif object1.enemyClass1 < object2.enemyClass1 then
            return true
        end
    else
        return false
    end
end

-- Sort 3v3 tables
function sortThreeArenaTeams(object1, object2)
    if tonumber(object1.win) / (tonumber(object1.win) + tonumber(object1.loss)) > tonumber(object2.win) / (tonumber(object2.win) + tonumber(object2.loss)) then
        return true
    elseif tonumber(object1.win) / (tonumber(object1.win) + tonumber(object1.loss)) == tonumber(object2.win) / (tonumber(object2.win) + tonumber(object2.loss)) then
        if object1.enemyClass1 == object2.enemyClass1 and object1.enemy1 == object2.enemy1 and object1.enemyClass2 == object2.enemyClass2 and object1.enemy2 == object2.enemy2 and object1.enemyClass3 == object2.enemyClass3 and object1.enemy3 < object2.enemy3 then
            return true
        elseif object1.enemyClass1 == object2.enemyClass1 and object1.enemy1 == object2.enemy1 and object1.enemyClass2 == object2.enemyClass2 and object1.enemy2 == object2.enemy2 and object1.enemyClass3 < object2.enemyClass3 then
            return true
        elseif object1.enemyClass1 == object2.enemyClass1 and object1.enemy1 == object2.enemy1 and object1.enemyClass2 == object2.enemyClass2 and object1.enemy2 < object2.enemy2 then
            return true
        elseif object1.enemyClass1 == object2.enemyClass1 and object1.enemy1 == object2.enemy1 and object1.enemyClass2 < object2.enemyClass2 then
            return true
        elseif object1.enemyClass1 == object2.enemyClass1 and object1.enemy1 < object2.enemy1 then
            return true
        elseif object1.enemyClass1 < object2.enemyClass1 then
            return true
        end
    else
        return false
    end
end

-- Sort 5v5 tables
function sortFiveArenaTeams(object1, object2)
    if tonumber(object1.win) / (tonumber(object1.win) + tonumber(object1.loss)) > tonumber(object2.win) / (tonumber(object2.win) + tonumber(object2.loss)) then
        return true
    elseif tonumber(object1.win) / (tonumber(object1.win) + tonumber(object1.loss)) == tonumber(object2.win) / (tonumber(object2.win) + tonumber(object2.loss)) then
        if object1.enemyClass1 == object2.enemyClass1 and object1.enemy1 == object2.enemy1 and object1.enemyClass2 == object2.enemyClass2 and object1.enemy2 == object2.enemy2 and object1.enemyClass3 == object2.enemyClass3 and object1.enemy3 == object2.enemy3 and object1.enemyClass4 == object2.enemyClass4 and object1.enemy4 == object2.enemy4 and object1.enemyClass5 == object2.enemyClass5 and object1.enemy5 < object2.enemy5 then
            return true
        elseif object1.enemyClass1 == object2.enemyClass1 and object1.enemy1 == object2.enemy1 and object1.enemyClass2 == object2.enemyClass2 and object1.enemy2 == object2.enemy2 and object1.enemyClass3 == object2.enemyClass3 and object1.enemy3 == object2.enemy3 and object1.enemyClass4 == object2.enemyClass4 and object1.enemy4 == object2.enemy4 and object1.enemyClass5 < object2.enemyClass5 then
            return true
        elseif object1.enemyClass1 == object2.enemyClass1 and object1.enemy1 == object2.enemy1 and object1.enemyClass2 == object2.enemyClass2 and object1.enemy2 == object2.enemy2 and object1.enemyClass3 == object2.enemyClass3 and object1.enemy3 == object2.enemy3 and object1.enemyClass4 == object2.enemyClass4 and object1.enemy4 < object2.enemy4 then
            return true
        elseif object1.enemyClass1 == object2.enemyClass1 and object1.enemy1 == object2.enemy1 and object1.enemyClass2 == object2.enemyClass2 and object1.enemy2 == object2.enemy2 and object1.enemyClass3 == object2.enemyClass3 and object1.enemy3 == object2.enemy3 and object1.enemyClass4 < object2.enemyClass4 then
           return true
        elseif object1.enemyClass1 == object2.enemyClass1 and object1.enemy1 == object2.enemy1 and object1.enemyClass2 == object2.enemyClass2 and object1.enemy2 == object2.enemy2 and object1.enemyClass3 == object2.enemyClass3 and object1.enemy3 < object2.enemy3 then
            return true
        elseif object1.enemyClass1 == object2.enemyClass1 and object1.enemy1 == object2.enemy1 and object1.enemyClass2 == object2.enemyClass2 and object1.enemy2 == object2.enemy2 and object1.enemyClass3 < object2.enemyClass3 then
            return true
        elseif object1.enemyClass1 == object2.enemyClass1 and object1.enemy1 == object2.enemy1 and object1.enemyClass2 == object2.enemyClass2 and object1.enemy2 < object2.enemy2 then
            return true
        elseif object1.enemyClass1 == object2.enemyClass1 and object1.enemy1 == object2.enemy1 and object1.enemyClass2 < object2.enemyClass2 then
            return true
        elseif object1.enemyClass1 == object2.enemyClass1 and object1.enemy1 < object2.enemy1 then
            return true
        elseif object1.enemyClass1 < object2.enemyClass1 then
            return true
        end
    else
        return false
    end
end

-- Populates player items list -- 
function populatePlayerItems()
    -- Sets playerItems to nil --
    playerItems = {"Step 2"}
    -- Sorts Player Table -- 
    table.sort(player, function (player1, player2) return player1.playerName < player2.playerName end)
    -- Populates playerItems List -- 
    for k,v in pairs (player) do
        if (v.twoEnemyArenaTeams[1] ~= nil or v.threeEnemyArenaTeams[1] ~= nil or v.fiveEnemyArenaTeams[1] ~= nil) then
            table.insert(playerItems, tostring(v.playerName .. " - " .. v.playerRealm))
        end
    end
end
