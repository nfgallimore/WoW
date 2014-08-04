-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_WoWuction                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_wowuction           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- register this file with Ace Libraries
local TSM = select(2, ...)
TSM = LibStub("AceAddon-3.0"):NewAddon(TSM, "TSM_WoWuction", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries

local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_WoWuction") -- loads the localization table

local savedDBDefaults = {
	factionrealm = {},
	profile = {
		tooltip = true,
		marketValue = true,
		medianPrice = true,
		regionMarketValue = true,
		regionMedianPrice = true,
		regionDailyAvg = true,
	},
}

-- Called once the player has loaded WOW.
function TSM:OnInitialize()
	-- load the savedDB into TSM.db
	TSM.db = LibStub:GetLibrary("AceDB-3.0"):New("TradeSkillMaster_WoWuctionDB", savedDBDefaults, true)
	-- register this module with TSM
	TSM:RegisterModule()
end

-- registers this module with TSM by first setting all fields and then calling TSMAPI:NewModule().
function TSM:RegisterModule()
	TSM.priceSources = {
		{ key = "wowuctionMarket", label = L["WoWuction Realm Market Value"], callback = "GetData", arg = "marketValue" },
		{ key = "wowuctionMedian", label = L["WoWuction Realm Median Price"], callback = "GetData", arg = "medianPrice" },
		{ key = "wowuctionRegionMarket", label = L["WoWuction Region Market Value"], callback = "GetData", arg = "regionMarketValue" },
		{ key = "wowuctionRegionMedian", label = L["WoWuction Region Median Price"], callback = "GetData", arg = "regionMedianPrice" },
	}
	TSM.moduleAPIs = {
		{ key = "wowuctionLastScan", callback = "GetLastCompleteScan" },
		{ key = "wowuctionLastScanTime", callback = "GetLastScanTime" },
	}
	TSM.tooltipOptions = { callback = "LoadTooltipOptions" }

	TSMAPI:NewModule(TSM)
end

function TSM:OnEnable()
	local realms = { GetRealmName(), "region" }
	local faction = strlower(UnitFactionGroup("player"))
	local extractedData = {}
	local hasData = false

	if TSM.data then
		for _, realm in ipairs(realms) do
			if TSM.data[realm] and TSM.data[realm][faction] then
				extractedData.lastUpdate = extractedData.lastUpdate or TSM.data[realm].lastUpdate
				if #TSM.data[realm][faction] > 0 then
					for _, itemData in ipairs(TSM.data[realm][faction]) do
						local itemID = itemData[1] -- itemID always in the first slot
						extractedData[itemID] = extractedData[itemID] or {}
						for i = 2, #itemData do
							local key = TSM.data[realm].fields[i]
							if key == "regionAvgDailyQuantityX100" then
								key = "regionAvgDailyQuantity"
								itemData[i] = itemData[i] / 100
							end
							extractedData[itemID][key] = itemData[i]
						end
						hasData = true
					end
				else
					hasData = true
					extractedData = CopyTable(TSM.data[realm][faction])
				end
			end
		end
		wipe(TSM.data)
	end
	if not hasData then
		TSM:Print(L["No wowuction data found. Go to the \"Data Export\" page for your realm on wowuction.com to download data."])
	end

	TSM.data = extractedData
end

function TSM:GetTooltip(itemString)
	if not TSM.db.profile.tooltip then return end
	if not strfind(itemString, "item:") then return end
	local itemID = TSMAPI:GetItemID(itemString)
	if not itemID then return end
	local data = TSM:GetData(itemID)
	local moneyCoinsTooltip = TSMAPI:GetMoneyCoinsTooltip()

	local text = {}
	if not data then return end
	if TSM.db.profile.marketValue then
		if data.marketValue and data.marketValue > 0 then
			if moneyCoinsTooltip then
				tinsert(text, { left = "  " .. L["Realm Market Value:"], right = TSMAPI:FormatTextMoneyIcon(data.marketValue, "|cffffffff", true) .. " (+/-" .. TSMAPI:FormatTextMoneyIcon(data.marketValueErr, "|cffffffff", true) .. ")" })
			else
				tinsert(text, { left = "  " .. L["Realm Market Value:"], right = TSMAPI:FormatTextMoney(data.marketValue, "|cffffffff", true) .. " (+/-" .. TSMAPI:FormatTextMoney(data.marketValueErr, "|cffffffff", true) .. ")" })
			end
		end
	end
	if TSM.db.profile.medianPrice then
		if data.medianPrice and data.medianPrice > 0 then
			if moneyCoinsTooltip then
				tinsert(text, { left = "  " .. L["Realm Median Price:"], right = TSMAPI:FormatTextMoneyIcon(data.medianPrice, "|cffffffff", true) .. " (+/-" .. TSMAPI:FormatTextMoneyIcon(data.medianPriceErr, "|cffffffff", true) .. ")" })
			else
				tinsert(text, { left = "  " .. L["Realm Median Price:"], right = TSMAPI:FormatTextMoney(data.medianPrice, "|cffffffff", true) .. " (+/-" .. TSMAPI:FormatTextMoney(data.medianPriceErr, "|cffffffff", true) .. ")" })
			end
		end
	end
	if TSM.db.profile.regionMarketValue then
		if data.regionMarketValue and data.regionMarketValue > 0 then
			if moneyCoinsTooltip then
				tinsert(text, { left = "  " .. L["Region Market Value:"], right = TSMAPI:FormatTextMoneyIcon(data.regionMarketValue, "|cffffffff", true) .. " (+/-" .. TSMAPI:FormatTextMoneyIcon(data.regionMarketValueErr, "|cffffffff", true) .. ")" })
			else
				tinsert(text, { left = "  " .. L["Region Market Value:"], right = TSMAPI:FormatTextMoney(data.regionMarketValue, "|cffffffff", true) .. " (+/-" .. TSMAPI:FormatTextMoney(data.regionMarketValueErr, "|cffffffff", true) .. ")" })
			end
		end
	end
	if TSM.db.profile.regionMedianPrice then
		if data.regionMedianPrice and data.regionMedianPrice > 0 then
			if moneyCoinsTooltip then
				tinsert(text, { left = "  " .. L["Region Median Price:"], right = TSMAPI:FormatTextMoneyIcon(data.regionMedianPrice, "|cffffffff", true) .. " (+/-" .. TSMAPI:FormatTextMoneyIcon(data.regionMedianPriceErr , "|cffffffff", true) .. ")" })
			else
				tinsert(text, { left = "  " .. L["Region Median Price:"], right = TSMAPI:FormatTextMoney(data.regionMedianPrice, "|cffffffff", true) .. " (+/-" .. TSMAPI:FormatTextMoney(data.regionMedianPriceErr, "|cffffffff", true) .. ")" })
			end
		end
	end
	if TSM.db.profile.regionDailyAvg then
		if data.regionAvgDailyQuantity and data.regionAvgDailyQuantity > 0 then
			tinsert(text, { left = "  " .. L["Region Avg Daily Quantity:"], right = "|cffffffff" .. data.regionAvgDailyQuantity })
		end
	end

	if #text > 0 then
		local lastScan = TSM:GetLastScanTime()
		if lastScan then
			local timeDiff = SecondsToTime(time() - lastScan)
			tinsert(text, 1, { left = "|cffffff00" .. "TSM WoWuction:", right = "|cffffffff" .. format(L["%s ago"], timeDiff) })
		else
			tinsert(text, 1, { left = "|cffffff00" .. "TSM WoWuction:", right = "|cffffffff" .. L["Not Scanned"] })
		end
		return text
	end
end

function TSM:GetData(itemID, key)
	if type(itemID) ~= "number" then itemID = TSMAPI:GetItemID(itemID) end

	local data
	if not (TSM.data and TSM.data[itemID] and (not key or TSM.data[itemID][key])) then return end

	data = TSM.data[itemID]

	if key then
		return data[key] > 0 and data[key]
	else
		return data
	end
end

function TSM:GetLastCompleteScan()
	if not TSM.data then return end

	local lastScan = {}
	for itemID, data in pairs(TSM.data) do
		if itemID ~= "lastUpdate" and data.marketValue and data.minBuyout then
			lastScan[itemID] = { marketValue = data.marketValue, minBuyout = data.minBuyout }
		end
	end

	return lastScan
end

function TSM:GetLastScanTime()
	return TSM.data and TSM.data.lastUpdate
end

function TSM:LoadTooltipOptions(container)
	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			fullHeight = true,
			children = {
				{
					type = "CheckBox",
					label = L["Enable display of WoWuction data in tooltip."],
					relativeWidth = 1,
					settingInfo = { TSM.db.profile, "tooltip" },
					callback = function(_, _, value)
						container:ReloadTab()
					end,
				},
				{
					type = "CheckBox",
					label = L["Display realm market price in tooltip."],
					disabled = not TSM.db.profile.tooltip,
					relativeWidth = 0.49,
					settingInfo = { TSM.db.profile, "marketValue" },
					tooltip = L["If checked, the market value of the item will be shown"],
				},
				{
					type = "CheckBox",
					label = L["Display realm median price in tooltip."],
					disabled = not TSM.db.profile.tooltip,
					settingInfo = { TSM.db.profile, "medianPrice" },
					tooltip = L["If checked, the median price of the item will be shown."],
				},
				{
					type = "CheckBox",
					label = L["Display region market value in tooltip."],
					disabled = not TSM.db.profile.tooltip,
					relativeWidth = 0.49,
					settingInfo = { TSM.db.profile, "regionMarketValue" },
					tooltip = L["If checked, the market value across the region of the item will be shown."],
				},
				{
					type = "CheckBox",
					label = L["Display region median price in tooltip."],
					disabled = not TSM.db.profile.tooltip,
					settingInfo = { TSM.db.profile, "regionMedianPrice" },
					tooltip = L["If checked, the median price across the region of the item will be shown."],
				},
				{
					type = "CheckBox",
					label = L["Display region average daily quantity in tooltips."],
					disabled = not TSM.db.profile.tooltip,
					relativeWidth = 0.49,
					settingInfo = { TSM.db.profile, "regionDailyAvg" },
					tooltip = L["If checked, the average daily quantity across the region will be shown."],
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end