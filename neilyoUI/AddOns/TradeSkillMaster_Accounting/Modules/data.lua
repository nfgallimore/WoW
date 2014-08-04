-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Accounting table and register a new module
local TSM = select(2, ...)
local Data = TSM:NewModule("Data", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table

local SECONDS_PER_DAY = 24 * 60 * 60
local TIME_BUCKET = 300 -- group sales/buys within 5 minutes together
local REPAIR_COST, REPAIR_MONEY, COULD_REPAIR, CAN_REPAIR = 0, 0, false, ""
local expired = AUCTION_EXPIRED_MAIL_SUBJECT:gsub("%%s", "")
local cancelled = AUCTION_REMOVED_MAIL_SUBJECT:gsub("%%s", "")
local outbid = AUCTION_OUTBID_MAIL_SUBJECT:gsub("%%s", "(.+)")

function Data:Load()
	Data.items = {}
	Data.money = {}
	Data.auctions = {}
	local LibParse = LibStub("LibParse")
	for _, data in ipairs(select(2, LibParse:CSVDecode(TSM.db.factionrealm.csvSales)) or {}) do
		if data.itemString then
			if data.itemName == "?" then data.itemName = nil end
			data.itemName = data.itemName or TSMAPI:GetSafeItemInfo(data.itemString) or TSM:GetItemName(data.itemString)
			Data.items[data.itemString] = Data.items[data.itemString] or { sales = {}, buys = {} }
			Data.items[data.itemString].name = Data.items[data.itemString].name or data.itemName
			tinsert(Data.items[data.itemString].sales, data)
		end
	end
	for _, data in ipairs(select(2, LibParse:CSVDecode(TSM.db.factionrealm.csvBuys)) or {}) do
		if data.itemString then
			if data.itemName == "?" then data.itemName = nil end
			data.itemName = data.itemName or TSMAPI:GetSafeItemInfo(data.itemString) or TSM:GetItemName(data.itemString)
			Data.items[data.itemString] = Data.items[data.itemString] or { sales = {}, buys = {} }
			Data.items[data.itemString].name = Data.items[data.itemString].name or data.itemName
			tinsert(Data.items[data.itemString].buys, data)
		end
	end
	for _, data in ipairs(select(2, LibParse:CSVDecode(TSM.db.factionrealm.csvIncome)) or {}) do
		if data.type then
			Data.money[data.type] = Data.money[data.type] or { income = {}, expense = {} }
			tinsert(Data.money[data.type].income, data)
		end
	end
	for _, data in ipairs(select(2, LibParse:CSVDecode(TSM.db.factionrealm.csvExpense)) or {}) do
		if data.type then
			Data.money[data.type] = Data.money[data.type] or { income = {}, expense = {} }
			tinsert(Data.money[data.type].expense, data)
		end
	end
	for _, data in ipairs(select(2, LibParse:CSVDecode(TSM.db.factionrealm.csvExpired)) or {}) do
		if data.itemString then
			data.itemName = data.itemName or TSMAPI:GetSafeItemInfo(data.itemString) or TSM:GetItemName(data.itemString)
			Data.auctions[data.itemString] = Data.auctions[data.itemString] or { expired = {}, cancelled = {} }
			Data.auctions[data.itemString].name = Data.auctions[data.itemString].name or data.itemName
			tinsert(Data.auctions[data.itemString].expired, data)
		end
	end
	for _, data in ipairs(select(2, LibParse:CSVDecode(TSM.db.factionrealm.csvCancelled)) or {}) do
		if data.itemString then
			data.itemName = data.itemName or TSMAPI:GetSafeItemInfo(data.itemString) or TSM:GetItemName(data.itemString)
			Data.auctions[data.itemString] = Data.auctions[data.itemString] or { expired = {}, cancelled = {} }
			Data.auctions[data.itemString].name = Data.auctions[data.itemString].name or data.itemName
			tinsert(Data.auctions[data.itemString].cancelled, data)
		end
	end
	for player, data in pairs(TSM.db.factionrealm.goldLog) do
		if type(data) == "string" then
			TSM.db.factionrealm.goldLog[player] = select(2, LibParse:CSVDecode(data))
		end
	end

	Data:RawHook("TakeInboxItem", function(...) Data:ScanCollectedMail("TakeInboxItem", 1, ...) end, true)
	Data:RawHook("TakeInboxMoney", function(...) Data:ScanCollectedMail("TakeInboxMoney", 1, ...) end, true)
	Data:RawHook("AutoLootMailItem", function(...) Data:ScanCollectedMail("AutoLootMailItem", 1, ...) end, true)
	Data:RawHook("SendMail", function(...) Data:CheckSendMail("SendMail", ...) end, true)
	Data:SecureHook("UseContainerItem", function(...) Data:CheckMerchantSale(...) end)
	Data:SecureHook("BuyMerchantItem", function(...) Data:BuyMerchantItem(...) end)
	Data:SecureHook("BuybackItem", function(...) Data:BuybackMerchantItem(...) end)
	Data:RegisterEvent("AUCTION_OWNED_LIST_UPDATE", "ScanAuctionItems")
	Data:RegisterEvent("MERCHANT_SHOW", "SetupRepairCost")
	Data:RegisterEvent("MERCHANT_UPDATE", "ResetRepairMoney")
	Data:RegisterEvent("UPDATE_INVENTORY_DURABILITY", "AddRepairCosts")
	TSMAPI:RegisterForBagChange(function(...) Data:ScanBagItems(...) end)
	TSMAPI:CreateFunctionRepeat("accountingGoldTracking", Data.LogGold)
end

function Data:CheckMerchantSale(bag, slot, onSelf)
	if MerchantFrame:IsShown() and not onSelf then
		local itemString = TSMAPI:GetItemString(GetContainerItemLink(bag, slot))
		local quantity = select(2, GetContainerItemInfo(bag, slot))
		local vendorValue = select(11, TSMAPI:GetSafeItemInfo(itemString))
		local saleTime = time()
		if itemString then
			Data:AddRecord("sales", itemString, vendorValue, quantity, "Merchant", saleTime, "Vendor")
		end
	end
end

function Data:BuyMerchantItem(index, quantity)
	local itemName, _, price, batchQuantity, _, _, extendedCost = GetMerchantItemInfo(index);
	if not quantity then
		quantity = batchQuantity
	end
	if price and price > 0 then
		local link = GetMerchantItemLink(index);
		local itemString = TSM.db.global.itemStrings[itemName] or TSMAPI:GetItemString(link)
		local buyPrice = floor(price / batchQuantity + 0.5)
		local buyTime = time()
		Data:AddRecord("buys", itemString, buyPrice, quantity, "Merchant", buyTime, "Vendor")
	end
end

function Data:BuybackMerchantItem(index)
	local itemName, _, price, quantity, _, _ = GetBuybackItemInfo(index)
	local link = GetMerchantItemLink(index);
	local itemString = TSM.db.global.itemStrings[itemName] or TSMAPI:GetItemString(link)
	local buyPrice = floor(price / quantity + 0.5)
	local buyTime = time()
	Data:AddRecord("buys", itemString, buyPrice, quantity, "Merchant", buyTime, "Vendor")
end

-- scans the mail that the player just attempted to send (Pre-Hook) to see if COD
function Data:CheckSendMail(oFunc, name, currentSubject, bodyText)
	local codAmount = GetSendMailCOD()
	local moneyAmount = GetSendMailMoney()
	local mailCost = GetSendMailPrice()
	local destination = name
	local recordTime = time()
	local subject
	local total = 0
	local ignore = false

	if codAmount ~= 0 then
		for i = 1, 12 do
			local itemName, _, count, _ = GetSendMailItem(i)
			if itemName and count then
				if not subject then
					subject = itemName
				end

				if subject == itemName then
					total = total + count
				else
					ignore = true
				end
			end
		end
	else
		ignore = true
	end

	if moneyAmount > 0 then -- add a record for the money transfer
		Data:AddMoneyRecord("expense", "Money Transfer", moneyAmount, destination, recordTime)
		Data:AddMoneyRecord("expense", "Postage", mailCost - moneyAmount, destination, recordTime)
	else
		-- add a record for the mail cost
		Data:AddMoneyRecord("expense", "Postage", mailCost, destination, recordTime)
	end

	if not ignore then
		Data.hooks[oFunc](name, subject .. " (" .. total .. ") TSM", bodyText)
	else
		Data.hooks[oFunc](name, currentSubject, bodyText)
	end
end

-- scans the mail that the player just attempted to collected (Pre-Hook)
function Data:ScanCollectedMail(oFunc, attempt, index, subIndex)
	local invoiceType, itemName, buyer, bid, _, _, ahcut, _, _, _, quantity = GetInboxInvoiceInfo(index)
	local sender, subject, money, codAmount, _, itemCount = select(3, GetInboxHeaderInfo(index))
	if not subject then return end
	local success = true
	if attempt > 1 then
		if buyer == "" then
			buyer = "?"
		elseif sender == "" then
			sender = "?"
		end
	end

	if invoiceType == "seller" and buyer and buyer ~= "" then -- AH Sales
		local daysLeft = select(7, GetInboxHeaderInfo(index))
		local saleTime = (time() + (daysLeft - 30) * SECONDS_PER_DAY)
		local link = select(2, TSMAPI:GetSafeItemInfo(itemName))
		local itemString = TSM.db.global.itemStrings[itemName] or TSMAPI:GetItemString(link)
		if itemString then
			local sellPrice = floor((bid - ahcut) / quantity + 0.5)
			Data:AddRecord("sales", itemString, sellPrice, quantity, buyer, saleTime, "Auction")
		end
	elseif invoiceType == "buyer" and buyer and buyer ~= "" then -- AH Buys
		local link = GetInboxItemLink(index, subIndex or 1)
		local itemString = TSMAPI:GetItemString(link)
		if itemString then
			--might as well grab the name for future lookups
			local name = TSMAPI:GetSafeItemInfo(link)
			TSM.db.global.itemStrings[name] = itemString

			local buyPrice = floor(bid / quantity + 0.5)
			local daysLeft = select(7, GetInboxHeaderInfo(index))
			local buyTime = (time() + (daysLeft - 30) * SECONDS_PER_DAY)
			Data:AddRecord("buys", itemString, buyPrice, quantity, buyer, buyTime, "Auction")
		end
	elseif codAmount > 0 then -- COD Buys (only if all attachments are same item)
		local link = GetInboxItemLink(index, subIndex or 1)
		local itemString = TSMAPI:GetItemString(link)
		if itemString then
			--might as well grab the name for future lookups
			local name = TSMAPI:GetSafeItemInfo(link)
			TSM.db.global.itemStrings[name] = itemString

			local total = 0
			local stacks = 0
			local ignore = false
			for i = 1, ATTACHMENTS_MAX_RECEIVE do
				local nameCheck, _, count, _, _ = GetInboxItem(index, i)

				if nameCheck and count then
					if nameCheck == name then
						total = total + count
						stacks = stacks + 1
					else
						ignore = true
					end
				end
			end

			if total ~= 0 and not ignore then
				local seller = sender
				local buyPrice = floor(codAmount / total + 0.5)
				local daysLeft = select(7, GetInboxHeaderInfo(index))
				local buyTime = (time() + (daysLeft - 3) * SECONDS_PER_DAY)
				local maxStack = select(8, TSMAPI:GetSafeItemInfo(link))
				for i = 1, stacks do
					if total >= maxStack then
						Data:AddRecord("buys", itemString, buyPrice, maxStack, seller, buyTime, "COD")
						total = total - maxStack
					else
						Data:AddRecord("buys", itemString, buyPrice, total, seller, buyTime, "COD")
					end
				end
			end
		end
	elseif money > 0 and invoiceType ~= "seller" and not strfind(subject, outbid) then
		local str
		if GetLocale() == "deDE" then
			str = gsub(subject, gsub(COD_PAYMENT, TSMAPI:StrEscape("%1$s"), ""), "")
		else
			str = gsub(subject, gsub(COD_PAYMENT, TSMAPI:StrEscape("%s"), ""), "")
		end
		local daysLeft = select(7, GetInboxHeaderInfo(index))
		local saleTime = (time() + (daysLeft - 31) * SECONDS_PER_DAY)
		if str and strfind(str, "TSM$") then -- payment for a COD the player sent
			local codName = strmatch(str, "([^\(]+)"):trim()
			local qty = strmatch(str, "\(([0-9]+)\)")
			qty = tonumber(qty)
			local itemString = TSM.db.global.itemStrings[codName]
			if itemString then
				local salePrice = floor(money / qty + 0.5)
				local maxStack = select(8, TSMAPI:GetSafeItemInfo(itemString))
				local stacks = ceil(qty / maxStack)

				for i = 1, stacks do
					if qty >= maxStack then
						Data:AddRecord("sales", itemString, salePrice, maxStack, sender, saleTime, "COD")
						qty = qty - maxStack
					else
						Data:AddRecord("sales", itemString, salePrice, qty, sender, saleTime, "COD")
					end
				end
			end
		else -- record a money transfer
			local source = sender
			Data:AddMoneyRecord("income", "Money Transfer", money, source, saleTime)
		end
	elseif strfind(subject, expired) then -- expired auction
		local daysLeft = select(7, GetInboxHeaderInfo(index))
		local expiredTime = (time() + (daysLeft - 30) * SECONDS_PER_DAY)
		local link = GetInboxItemLink(index, subIndex or 1)
		local qty = select(3, GetInboxItem(index, subIndex or 1))
		local itemString = TSMAPI:GetItemString(link)
		if itemString then
			Data:AddAuctionRecord("expired", itemString, qty, expiredTime)
		end
	elseif strfind(subject, cancelled) then -- cancelled auction
		local daysLeft = select(7, GetInboxHeaderInfo(index))
		local cancelledTime = (time() + (daysLeft - 30) * SECONDS_PER_DAY)
		local link = GetInboxItemLink(index, subIndex or 1)
		local qty = select(3, GetInboxItem(index, subIndex or 1))
		local itemString = TSMAPI:GetItemString(link)
		if itemString then
			Data:AddAuctionRecord("cancelled", itemString, qty, cancelledTime)
		end
	else
		success = false
	end

	if success then
		Data.hooks[oFunc](index, subIndex)
	elseif (not select(2, GetInboxHeaderInfo(index)) or (invoiceType and (not buyer or buyer == ""))) and attempt <= 5 then
		TSMAPI:CreateTimeDelay("accountingHookDelay", 0.2, function() Data:ScanCollectedMail(oFunc, attempt + 1, index, subIndex) end)
	elseif attempt > 5 then
		Data.hooks[oFunc](index, subIndex)
	else
		Data.hooks[oFunc](index, subIndex)
	end
end

-- adds a new record for something that was sold / bought
function Data:AddRecord(dataType, itemString, price, stackSize, otherPerson, recordTime, source)
	if not itemString then return end
	if dataType ~= "sales" and dataType ~= "buys" then error("Invalid type: " .. tostring(dataType)) end
	local currentPlayer = UnitName("player")

	Data.items[itemString] = Data.items[itemString] or { sales = {}, buys = {} }
	Data.items[itemString].itemName = Data.items[itemString].itemName or TSMAPI:GetSafeItemInfo(itemString) or TSM:GetItemName(itemString)
	local otherPersonIndex = (dataType == "sales" and "buyer") or (dataType == "buys" and "seller")

	local foundRecord
	for _, record in ipairs(Data.items[itemString][dataType]) do
		if record.price == price and record.stackSize == stackSize and abs(record.time - recordTime) < TIME_BUCKET and record.player == currentPlayer then
			record.quantity = record.quantity + stackSize
			foundRecord = true
			break
		end
	end

	if not foundRecord then
		tinsert(Data.items[itemString][dataType], { time = recordTime, price = price, quantity = stackSize, stackSize = stackSize, [otherPersonIndex] = otherPerson, player = currentPlayer, source = source, })
	end
end

-- adds a new record for money received / spent
function Data:AddMoneyRecord(dataType, rType, amount, otherEntity, recordTime)
	if dataType ~= "income" and dataType ~= "expense" then error("Invalid type: " .. tostring(dataType)) end
	local currentPlayer = UnitName("player")

	Data.money[rType] = Data.money[rType] or { income = {}, expense = {} }
	local otherEntityIndex = (dataType == "income" and "source") or (dataType == "expense" and "destination")

	local foundRecord
	for i=#Data.money[rType][dataType], 1, -1 do
		local record = Data.money[rType][dataType][i]
		if type(record.time) ~= "number" then
			-- hackish fix...
			tremove(Data.money[rType][dataType], i)
		elseif abs(record.time - recordTime) < TIME_BUCKET and record.player == currentPlayer then
			record.amount = record.amount + amount
			foundRecord = true
			break
		end
	end

	if not foundRecord then
		tinsert(Data.money[rType][dataType], { time = recordTime, amount = amount, [otherEntityIndex] = otherEntity, player = currentPlayer })
	end
end

function Data:AddAuctionRecord(dataType, itemString, stackSize, recordTime)
	if dataType ~= "expired" and dataType ~= "cancelled" then error("Invalid type: " .. tostring(dataType)) end
	local currentPlayer = UnitName("player")

	Data.auctions[itemString] = Data.auctions[itemString] or { expired = {}, cancelled = {} }
	Data.auctions[itemString].itemName = Data.auctions[itemString].itemName or TSMAPI:GetSafeItemInfo(itemString) or TSM:GetItemName(itemString)

	local foundRecord
	for _, record in ipairs(Data.auctions[itemString][dataType]) do
		if record.stackSize == stackSize and abs(record.time - recordTime) < TIME_BUCKET and record.player == currentPlayer then
			record.quantity = record.quantity + stackSize
			foundRecord = true
			break
		end
	end

	if not foundRecord then
		tinsert(Data.auctions[itemString][dataType], { time = recordTime, quantity = stackSize, stackSize = stackSize, player = currentPlayer })
	end
end

-- scan the auctions the user has on the AH for name -> itemString lookup table
function Data:ScanAuctionItems()
	for i = 1, GetNumAuctionItems("owner") do
		local name = GetAuctionItemInfo("owner", i)
		if name then
			local itemString = TSMAPI:GetItemString(GetAuctionItemLink("owner", i))
			TSM.db.global.itemStrings[name] = itemString
		end
	end
end

-- scans the bags to help build the name -> itemString lookup table
function Data:ScanBagItems(state)
	for itemString in pairs(state) do
		local name = TSMAPI:GetSafeItemInfo(itemString)
		if name then
			TSM.db.global.itemStrings[name] = itemString
		end
	end
end




-- ************************************************ --
--				GUI Helper Functions							 --
-- ************************************************ --

-- returns a formatted time in the format that the user has selected
function Data:GetFormattedTime(rTime)
	if TSM.db.factionrealm.timeFormat == "ago" then
		return format(L["%s ago"], SecondsToTime(time() - rTime) or "?")
	elseif TSM.db.factionrealm.timeFormat == "usdate" then
		return date("%m/%d/%y %H:%M", rTime)
	elseif TSM.db.factionrealm.timeFormat == "eudate" then
		return date("%d/%m/%y %H:%M", rTime)
	elseif TSM.db.factionrealm.timeFormat == "aidate" then
		return date("%y/%m/%d %H:%M", rTime)
	end
end

function Data:PopulateDataCaches()
	local temp = {}
	Data.playerDataCache = {}

	for itemString, data in pairs(Data.items) do
		for _, record in ipairs(data.buys) do
			if not temp[record.player] then
				temp[record.player] = true
				tinsert(Data.playerDataCache, record.player)
			end
		end
		for _, record in ipairs(data.sales) do
			if not temp[record.player] then
				temp[record.player] = true
				tinsert(Data.playerDataCache, record.player)
			end
		end
	end
	for type, data in pairs(TSM.Data.money) do
		for _, record in ipairs(data.income) do
			if not temp[record.player] then
				temp[record.player] = true
				tinsert(Data.playerDataCache, record.player)
			end
		end
		for _, record in ipairs(data.expense) do
			if not temp[record.player] then
				temp[record.player] = true
				tinsert(Data.playerDataCache, record.player)
			end
		end
	end
	for itemString, data in pairs(TSM.Data.auctions) do
		for _, record in ipairs(data.expired) do
			if not temp[record.player] then
				temp[record.player] = true
				tinsert(Data.playerDataCache, record.player)
			end
		end
		for _, record in ipairs(data.cancelled) do
			if not temp[record.player] then
				temp[record.player] = true
				tinsert(Data.playerDataCache, record.player)
			end
		end
	end
end

function Data:RemoveOldData(daysOld)
	local cutOffTime = time() - daysOld * SECONDS_PER_DAY
	local numRecords, numItems = 0, 0

	for itemString, data in pairs(Data.items) do
		for i = #data.sales, 1, -1 do
			if data.sales[i].time < cutOffTime then
				numRecords = numRecords + 1
				tremove(data.sales, i)
			end
		end
		for i = #data.buys, 1, -1 do
			if data.buys[i].time < cutOffTime then
				numRecords = numRecords + 1
				tremove(data.buys, i)
			end
		end
		if #data.sales == 0 and #data.buys == 0 then
			Data.items[itemString] = nil
			numItems = numItems + 1
		end
	end
	for itemString, data in pairs(Data.auctions) do
		for i = #data.expired, 1, -1 do
			if data.expired[i].time < cutOffTime then
				numRecords = numRecords + 1
				tremove(data.expired, i)
			end
		end
		for i = #data.cancelled, 1, -1 do
			if data.cancelled[i].time < cutOffTime then
				numRecords = numRecords + 1
				tremove(data.cancelled, i)
			end
		end
		if #data.expired == 0 and #data.cancelled == 0 then
			Data.auctions[itemString] = nil
			numItems = numItems + 1
		end
	end
	for type, data in pairs(Data.money) do
		for i = #data.income, 1, -1 do
			if data.income[i].time < cutOffTime then
				numRecords = numRecords + 1
				tremove(data.income, i)
			end
		end
		for i = #data.expense, 1, -1 do
			if data.expense[i].time < cutOffTime then
				numRecords = numRecords + 1
				tremove(data.expense, i)
			end
		end
		if #data.income == 0 and #data.expense == 0 then
			Data.money[type] = nil
			numItems = numItems + 1
		end
	end

	TSM:Printf(L["Removed a total of %s old records and %s items with no remaining records."], numRecords, numItems)
end

-- formats the buys/sales data into a table that the ST can use
function Data:GetSTData(dataType, filterFunc)
	if dataType ~= "buys" and dataType ~= "sales" then return
	end
	filterFunc = filterFunc or (function() return true
	end)
	local stData = {}
	for itemString, data in pairs(Data.items) do
		if #data[dataType] > 0 and filterFunc(data.name, itemString) then
			for _, record in ipairs(data[dataType]) do
				if filterFunc(data.name, itemString, record.player) then
					local rarity = select(3, GetItemInfo(itemString)) or 0
					if ((not TSM.db.factionrealm.displayGreys and rarity ~= 0) or TSM.db.factionrealm.displayGreys) then
						tinsert(stData, {
							cols = {
								{
									value = select(2, TSMAPI:GetSafeItemInfo(itemString)) or data.name,
									sortArg = data.name or itemString,
								},
								{
									value = record.player,
									sortArg = record.player,
								},
								{
									value = record.source,
									sortArg = record.source or "~",
								},
								{
									value = record.stackSize,
									sortArg = record.stackSize,
								},
								{
									value = record.quantity / record.stackSize,
									sortArg = record.quantity / record.stackSize,
								},
								{
									value = TSMAPI:FormatTextMoney(record.price),
									sortArg = record.price,
								},
								{
									value = TSMAPI:FormatTextMoney(record.price * record.quantity),
									sortArg = record.price * record.quantity,
								},
								{
									value = Data:GetFormattedTime(record.time),
									sortArg = record.time,
								},
							},
							itemString = itemString,
						})
					end
				end
			end
		end
	end

	return stData
end

-- formats the income/expense data into a table that the ST can use
function Data:GetMoneyData(dataType, filterFunc)
	if dataType ~= "income" and dataType ~= "expense" then return
	end
	filterFunc = filterFunc or (function() return true
	end)
	local stData = {}
	for type, data in pairs(TSM.Data.money) do
		if #data[dataType] > 0 and filterFunc(type) then
			for _, record in ipairs(data[dataType]) do
				if filterFunc(type, record.player) then
					if ((not TSM.db.factionrealm.displayTransfers and type ~= "Money Transfer") or TSM.db.factionrealm.displayTransfers) then
						tinsert(stData, {
							cols = {
								{
									value = type,
									sortArg = type,
								},
								{
									value = record.player,
									sortArg = record.player,
								},
								{
									value = record.source or record.destination,
									sortArg = record.source or record.destination,
								},
								{
									value = TSMAPI:FormatTextMoney(record.amount),
									sortArg = record.amount,
								},
								{
									value = Data:GetFormattedTime(record.time),
									sortArg = record.time,
								},
							},
						})
					end
				end
			end
		end
	end
	return stData
end

-- formats the expired/cancelled data into a table that the ST can use
function Data:GetAucData(dataType, filterFunc)
	if dataType ~= "expired" and dataType ~= "cancelled" then return
	end
	filterFunc = filterFunc or (function() return true
	end)
	local stData = {}
	for itemString, data in pairs(Data.auctions) do
		if #data[dataType] > 0 and filterFunc(data.name, itemString) then
			for _, record in ipairs(data[dataType]) do
				if filterFunc(data.name, itemString, record.player) then
					tinsert(stData, {
						cols = {
							{
								value = select(2, TSMAPI:GetSafeItemInfo(itemString)) or data.name,
								sortArg = data.name or itemString,
							},
							{
								value = record.player,
								sortArg = record.player,
							},
							{
								value = record.stackSize,
								sortArg = record.stackSize,
							},
							{
								value = record.quantity / record.stackSize,
								sortArg = record.quantity / record.stackSize,
							},
							{
								value = Data:GetFormattedTime(record.time),
								sortArg = record.time,
							},
						},
						itemString = itemString,
					})
				end
			end
		end
	end

	return stData
end

-- formats the item summary data into a table that the ST can use
function Data:GetItemSummaryData(filterFunc)
	filterFunc = filterFunc or (function() return true
	end)
	local itemData = {}

	for itemString, data in pairs(Data.items) do
		local sellTotal, sellNum = 0, 0
		for _, record in ipairs(data.sales) do
			local name = Data.items[itemString].name
			local rTime = record.time
			if filterFunc(name, itemString, rTime) then
				local rarity = select(3, GetItemInfo(itemString)) or 0
				if ((not TSM.db.factionrealm.displayGreys and rarity ~= 0) or TSM.db.factionrealm.displayGreys) then
					sellTotal = sellTotal + record.price * record.quantity
					sellNum = sellNum + record.quantity
				end
			end
		end
		local sellAverage = sellNum > 0 and floor(sellTotal / sellNum + 0.5) or 0

		local buyTotal, buyNum = 0, 0
		for _, record in ipairs(data.buys) do
			local name = Data.items[itemString].name
			local rTime = record.time
			if filterFunc(name, itemString, rTime) then
				buyTotal = buyTotal + record.price * record.quantity
				buyNum = buyNum + record.quantity
			end
		end
		local buyAverage = buyNum > 0 and floor(buyTotal / buyNum + 0.5) or 0

		if buyTotal ~= 0 or sellTotal ~= 0 then
			itemData[itemString] = { buyAverage = buyAverage, buyNum = buyNum, sellAverage = sellAverage, sellNum = sellNum, marketValue = TSMAPI:GetItemValue(itemString, TSM.db.factionrealm.mvSource) }
			if TSM.db.factionrealm.priceFormat == "total" then
				itemData[itemString].buyAverage = buyTotal
				itemData[itemString].sellAverage = sellTotal
			end
		end
	end

	local stData = {}
	for itemString, data in pairs(itemData) do
		local name = Data.items[itemString].name
		tinsert(stData, {
			cols = {
				{
					value = select(2, TSMAPI:GetSafeItemInfo(itemString)) or name,
					sortArg = name or itemString,
				},
				{
					value = TSMAPI:FormatTextMoney(data.marketValue) or "|cff999999---|r",
					sortArg = data.marketValue or 0,
				},
				{
					value = data.sellNum,
					sortArg = data.sellNum,
				},
				{
					value = TSMAPI:FormatTextMoney(data.sellAverage),
					sortArg = data.sellAverage,
				},
				{
					value = data.buyNum,
					sortArg = data.buyNum,
				},
				{
					value = TSMAPI:FormatTextMoney(data.buyAverage),
					sortArg = data.buyAverage,
				},
			},
			itemString = itemString,
			totalNum = data.sellNum + data.buyNum,
		})
		--end
	end

	sort(stData, function(a, b) return a.totalNum > b.totalNum
	end)

	return stData
end

-- formats the resale summary data into a table that the ST can use
function Data:GetResaleSummaryData(filterFunc)
	filterFunc = filterFunc or (function() return true
	end)
	local itemData = {}
	for itemString, data in pairs(Data.items) do
		if #data.sales > 0 and #data.buys > 0 then
			local sellTotal, sellNum = 0, 0
			for _, record in ipairs(data.sales) do
				sellTotal = sellTotal + record.price * record.quantity
				sellNum = sellNum + record.quantity
			end
			local sellAverage = floor(sellTotal / sellNum + 0.5) or 0

			local buyTotal, buyNum = 0, 0
			for _, record in ipairs(data.buys) do
				buyTotal = buyTotal + record.price * record.quantity
				buyNum = buyNum + record.quantity
			end
			local buyAverage = floor(buyTotal / buyNum + 0.5) or 0

			local profit = sellAverage - buyAverage
			local profitPercent = floor(100 * profit / buyAverage + 0.5)
			local color = profit > 0 and "|cff00ff00" or "|cffff0000"
			local profitText = TSMAPI:FormatTextMoney(profit, color) .. " (" .. color .. profitPercent .. "%|r)"

			itemData[itemString] = { avgBuy = buyAverage, buyNum = buyNum, avgSell = sellAverage, sellNum = sellNum, profit = profit, profitText = profitText }
			if TSM.db.factionrealm.priceFormat == "total" then
				itemData[itemString].avgSell = sellTotal
				itemData[itemString].avgBuy = buyTotal
			end
		end
	end

	local stData = {}
	for itemString, data in pairs(itemData) do
		local name = Data.items[itemString].name
		if filterFunc(name, itemString) then
			tinsert(stData, {
				cols = {
					{
						value = select(2, TSMAPI:GetSafeItemInfo(itemString)) or name,
						sortArg = name or itemString,
					},
					{
						value = data.sellNum,
						sortArg = data.sellNum,
					},
					{
						value = TSMAPI:FormatTextMoney(data.avgSell),
						sortArg = data.avgSell,
					},
					{
						value = data.buyNum,
						sortArg = data.buyNum,
					},
					{
						value = TSMAPI:FormatTextMoney(data.avgBuy),
						sortArg = data.avgBuy,
					},
					{
						value = data.profitText,
						sortArg = data.profit,
					},
				},
				itemString = itemString,
				totalNum = data.sellNum + data.buyNum,
			})
		end
	end

	sort(stData, function(a, b) return a.totalNum > b.totalNum
	end)

	return stData
end

-- gets data for the gold summary page
function Data:GetGoldData(filters)
	local function GroupFilter(itemString)
		if not filters.group then return true end
		local groupPath = TSMAPI:GetGroupPath(itemString)
		return groupPath and strfind(groupPath, "^" .. TSMAPI:StrEscape(filters.group))
	end

	local goldData = {
		totalSale = 0,
		monthSale = 0,
		weekSale = 0,
		topSellGold = {},
		topSellQuantity = {},
		totalBuy = 0,
		monthBuy = 0,
		weekBuy = 0,
		topBuyGold = {},
		topBuyQuantity = {},
		totalIncome = 0,
		monthIncome = 0,
		weekIncome = 0,
		topIncomeGold = {},
		topIncomeQuantity = {},
		totalExpense = 0,
		monthExpense = 0,
		weekExpense = 0,
		topExpenseGold = {},
		topExpenseQuantity = {},
		totalTime = 0,
		monthTime = 0,
		weekTime = 0
	}

	for itemString, data in pairs(Data.items) do
		if GroupFilter(itemString) then
			if #data.sales > 0 then
				local itemTotalGold, itemTotalNum = 0, 0
				for _, record in ipairs(data.sales) do
					if filters.player == "all" or filters.player == record.player then
						itemTotalNum = itemTotalNum + record.quantity
						itemTotalGold = itemTotalGold + record.price * record.quantity
						goldData.totalSale = goldData.totalSale + record.price * record.quantity
						local timeDiff = time() - record.time
						if timeDiff < (SECONDS_PER_DAY * 30) then
							if timeDiff > goldData.monthTime then
								goldData.monthTime = timeDiff
							end
							goldData.monthSale = goldData.monthSale + record.price * record.quantity
							if timeDiff < (SECONDS_PER_DAY * 7) then
								if timeDiff > goldData.weekTime then
									goldData.weekTime = timeDiff
								end
								goldData.weekSale = goldData.weekSale + record.price * record.quantity
							end
						end
						if timeDiff > goldData.totalTime then
							goldData.totalTime = timeDiff
						end
					end
				end
				if itemTotalGold > (goldData.topSellGold.price or 0) then
					local rarity = select(3, GetItemInfo(itemString)) or 0
					if ((not TSM.db.factionrealm.displayGreys and rarity ~= 0) or TSM.db.factionrealm.displayGreys) then
						goldData.topSellGold = { itemString = itemString, price = itemTotalGold, itemID = TSMAPI:GetItemID(itemString) }
					end
				end
				if itemTotalNum > (goldData.topSellQuantity.num or 0) then
					local rarity = select(3, GetItemInfo(itemString)) or 0
					if ((not TSM.db.factionrealm.displayGreys and rarity ~= 0) or TSM.db.factionrealm.displayGreys) then
						goldData.topSellQuantity = { itemString = itemString, num = itemTotalNum, itemID = TSMAPI:GetItemID(itemString) }
					end
				end
			end
			if #data.buys > 0 then
				local itemTotalGold, itemTotalNum = 0, 0
				for _, record in ipairs(data.buys) do
					if filters.player == "all" or filters.player == record.player then
						itemTotalNum = itemTotalNum + record.quantity
						itemTotalGold = itemTotalGold + record.price * record.quantity
						goldData.totalBuy = goldData.totalBuy + record.price * record.quantity
						local timeDiff = time() - record.time
						if timeDiff < (SECONDS_PER_DAY * 30) then
							if timeDiff > goldData.monthTime then
								goldData.monthTime = timeDiff
							end
							goldData.monthBuy = goldData.monthBuy + record.price * record.quantity
							if timeDiff < (SECONDS_PER_DAY * 7) then
								if timeDiff > goldData.weekTime then
									goldData.weekTime = timeDiff
								end
								goldData.weekBuy = goldData.weekBuy + record.price * record.quantity
							end
						end
						if timeDiff > goldData.totalTime then
							goldData.totalTime = timeDiff
						end
					end
				end
				if itemTotalGold > (goldData.topBuyGold.price or 0) then
					goldData.topBuyGold = { itemString = itemString, price = itemTotalGold, itemID = TSMAPI:GetItemID(itemString) }
				end
				if itemTotalNum > (goldData.topBuyQuantity.num or 0) then
					goldData.topBuyQuantity = { itemString = itemString, num = itemTotalNum, itemID = TSMAPI:GetItemID(itemString) }
				end
			end
		end
	end

	for type, data in pairs(TSM.Data.money) do
		if ((not TSM.db.factionrealm.displayTransfers and type ~= "Money Transfer") or TSM.db.factionrealm.displayTransfers) then
			if #data.income > 0 then
				local typeTotalGold, typeTotalNum = 0, 0
				for _, record in ipairs(data.income) do
					if filters.player == "all" or filters.player == record.player then
						typeTotalNum = typeTotalNum + 1
						typeTotalGold = typeTotalGold + record.amount
						goldData.totalIncome = goldData.totalIncome + record.amount
						local timeDiff = time() - record.time
						if timeDiff < (SECONDS_PER_DAY * 30) then
							if timeDiff > goldData.monthTime then
								goldData.monthTime = timeDiff
							end
							goldData.monthIncome = goldData.monthIncome + record.amount
							if timeDiff < (SECONDS_PER_DAY * 7) then
								if timeDiff > goldData.weekTime then
									goldData.weekTime = timeDiff
								end
								goldData.weekIncome = goldData.weekIncome + record.amount
							end
						end
						if timeDiff > goldData.totalTime then
							goldData.totalTime = timeDiff
						end
					end
				end
				if typeTotalGold > (goldData.topIncomeGold.amount or 0) then
					if ((not TSM.db.factionrealm.displayTransfers and type ~= "Money Transfer") or TSM.db.factionrealm.displayTransfers) then
						goldData.topIncomeGold = { type = type, amount = typeTotalGold }
					end
				end
				if typeTotalNum > (goldData.topIncomeQuantity.num or 0) then
					if ((not TSM.db.factionrealm.displayTransfers and type ~= "Money Transfer") or TSM.db.factionrealm.displayTransfers) then
						goldData.topIncomeQuantity = { type = type, num = typeTotalNum }
					end
				end
			end
			if #data.expense > 0 then
				local typeTotalGold, typeTotalNum = 0, 0
				for _, record in ipairs(data.expense) do
					if filters.player == "all" or filters.player == record.player then
						typeTotalNum = typeTotalNum + 1
						typeTotalGold = typeTotalGold + record.amount
						goldData.totalExpense = goldData.totalExpense + record.amount
						local timeDiff = time() - record.time
						if timeDiff < (SECONDS_PER_DAY * 30) then
							if timeDiff > goldData.monthTime then
								goldData.monthTime = timeDiff
							end
							goldData.monthExpense = goldData.monthExpense + record.amount
							if timeDiff < (SECONDS_PER_DAY * 7) then
								if timeDiff > goldData.weekTime then
									goldData.weekTime = timeDiff
								end
								goldData.weekExpense = goldData.weekExpense + record.amount
							end
						end
						if timeDiff > goldData.totalTime then
							goldData.totalTime = timeDiff
						end
					end
				end
				if typeTotalGold > (goldData.topExpenseGold.amount or 0) then
					if ((not TSM.db.factionrealm.displayTransfers and type ~= "Money Transfer") or TSM.db.factionrealm.displayTransfers) then
						goldData.topExpenseGold = { type = type, amount = typeTotalGold }
					end
				end
				if typeTotalNum > (goldData.topExpenseQuantity.num or 0) then
					if ((not TSM.db.factionrealm.displayTransfers and type ~= "Money Transfer") or TSM.db.factionrealm.displayTransfers) then
						goldData.topExpenseQuantity = { type = type, num = typeTotalNum }
					end
				end
			end
		end
	end


	if goldData.totalTime > (SECONDS_PER_DAY * 7) then
		goldData.weekTime = SECONDS_PER_DAY * 7
		if goldData.totalTime > (SECONDS_PER_DAY * 30) then
			goldData.monthTime = SECONDS_PER_DAY * 30
		end
	end
	goldData.totalTime = ceil(goldData.totalTime / SECONDS_PER_DAY)
	goldData.monthTime = ceil(goldData.monthTime / SECONDS_PER_DAY)
	goldData.weekTime = ceil(goldData.weekTime / SECONDS_PER_DAY)

	return goldData
end

-- get the data for the item specifics page
function Data:GetItemData(itemString)
	if not Data.items[itemString] then return end

	local data = { activity = {}, sellers = {}, buyers = {} }

	if #Data.items[itemString].buys > 0 then
		local totalBuyPrice, totalBuyNum = 0, 0
		local monthBuyPrice, monthBuyNum = 0, 0
		local weekBuyPrice, weekBuyNum = 0, 0

		for i, record in ipairs(Data.items[itemString].buys) do
			data.sellers[record.seller] = (data.sellers[record.seller] or 0) + record.quantity
			tinsert(data.activity, { type = "Purchase", price = record.price, source = record.source, quantity = record.quantity, who = record.seller, time = record.time, record = record })

			totalBuyPrice = totalBuyPrice + record.price * record.quantity
			totalBuyNum = totalBuyNum + record.quantity
			local timeDiff = time() - record.time
			if timeDiff < (SECONDS_PER_DAY * 30) then
				monthBuyPrice = monthBuyPrice + record.price * record.quantity
				monthBuyNum = monthBuyNum + record.quantity
				if timeDiff < (SECONDS_PER_DAY * 7) then
					weekBuyPrice = weekBuyPrice + record.price * record.quantity
					weekBuyNum = weekBuyNum + record.quantity
				end
			end
		end

		data.totalBuyPrice = totalBuyPrice
		data.totalBuyNum = totalBuyNum
		data.avgTotalBuy = floor(totalBuyPrice / totalBuyNum + 0.5)

		data.monthBuyPrice = monthBuyPrice
		data.monthBuyNum = monthBuyNum
		data.avgMonthBuy = monthBuyNum > 0 and floor(monthBuyPrice / monthBuyNum + 0.5) or 0

		data.weekBuyPrice = weekBuyPrice
		data.weekBuyNum = weekBuyNum
		data.avgWeekBuy = weekBuyNum > 0 and floor(weekBuyPrice / weekBuyNum + 0.5) or 0
	end

	if #Data.items[itemString].sales > 0 then
		local totalSellPrice, totalSellNum = 0, 0
		local monthSellPrice, monthSellNum = 0, 0
		local weekSellPrice, weekSellNum = 0, 0

		for i, record in ipairs(Data.items[itemString].sales) do
			data.buyers[record.buyer] = (data.buyers[record.buyer] or 0) + record.quantity
			tinsert(data.activity, { type = "Sale", price = record.price, source = record.source, quantity = record.quantity, who = record.buyer, time = record.time, record = record })

			totalSellPrice = totalSellPrice + record.price * record.quantity
			totalSellNum = totalSellNum + record.quantity
			local timeDiff = time() - record.time
			if timeDiff < (SECONDS_PER_DAY * 30) then
				monthSellPrice = monthSellPrice + record.price * record.quantity
				monthSellNum = monthSellNum + record.quantity
				if timeDiff < (SECONDS_PER_DAY * 7) then
					weekSellPrice = weekSellPrice + record.price * record.quantity
					weekSellNum = weekSellNum + record.quantity
				end
			end
		end

		data.totalSellPrice = totalSellPrice
		data.totalSellNum = totalSellNum
		data.avgTotalSell = floor(totalSellPrice / totalSellNum + 0.5)

		data.monthSellPrice = monthSellPrice
		data.monthSellNum = monthSellNum
		data.avgMonthSell = monthSellNum > 0 and floor(monthSellPrice / monthSellNum + 0.5) or 0

		data.weekSellPrice = weekSellPrice
		data.weekSellNum = weekSellNum
		data.avgWeekSell = weekSellNum > 0 and floor(weekSellPrice / weekSellNum + 0.5) or 0
	end

	sort(data.activity, function(a, b) return a.time > b.time end)
	data.stData = {}
	for _, record in pairs(data.activity) do
		tinsert(data.stData, {
			cols = {
				{
					value = record.type,
					sortArg = record.type,
				},
				{
					value = record.source,
					sortArg = record.source or "",
				},
				{
					value = record.who,
					sortArg = record.who,
				},
				{
					value = record.quantity,
					sortArg = record.quantity,
				},
				{
					value = TSMAPI:FormatTextMoney(record.price),
					sortArg = record.price,
				},
				{
					value = TSMAPI:FormatTextMoney(record.price * record.quantity),
					sortArg = record.price * record.quantity,
				},
				{
					value = Data:GetFormattedTime(record.time),
					sortArg = record.time,
				},
			},
			record = record.record,
			recordType = record.type,
		})
	end

	return data
end

function Data:SetupRepairCost()
	REPAIR_MONEY = GetMoney();
	COULD_REPAIR = CanMerchantRepair();
	-- if merchant can repair set up variables so we can track repairs
	if (COULD_REPAIR) then
		REPAIR_COST, CAN_REPAIR = GetRepairAllCost();
	end
end

function Data:ResetRepairMoney()
	-- Could have bought something before or after repair
	REPAIR_MONEY = GetMoney();
end

function Data:AddRepairCosts()
	if (COULD_REPAIR and REPAIR_COST > 0) then
		local cash = GetMoney();
		if (REPAIR_MONEY > cash) then
			-- this is probably a repair bill
			local cost = REPAIR_MONEY - cash
			local recordTime = time()
			Data:AddMoneyRecord("expense", "Repair Bill", cost, "Merchant", recordTime)
			-- reset money as this might have been a single item repair
			REPAIR_MONEY = cash;
			-- reset the repair cost for the next repair
			REPAIR_COST, CAN_REPAIR = GetRepairAllCost();
		end
	end
end

do
	local tradeInfo

	local function onAcceptUpdate(_, player, target)
		if (player == 1 or target == 1) and not (GetTradePlayerItemLink(7) or GetTradeTargetItemLink(7)) then
			-- update tradeInfo
			tradeInfo = { player = {}, target = {} }
			tradeInfo.player.money = tonumber(GetPlayerTradeMoney())
			tradeInfo.target.money = tonumber(GetTargetTradeMoney())
			tradeInfo.target.name = UnitName("NPC")

			for i = 1, 6 do
				local link = GetTradeTargetItemLink(i)
				local count = select(3, GetTradeTargetItemInfo(i))
				if link then
					tinsert(tradeInfo.target, { itemString = TSMAPI:GetItemString(link), count = count })
				end

				local link = GetTradePlayerItemLink(i)
				local count = select(3, GetTradePlayerItemInfo(i))
				if link then
					tinsert(tradeInfo.player, { itemString = TSMAPI:GetItemString(link), count = count })
				end
			end
		else
			tradeInfo = nil
		end
	end

	local function onChatMsg(_, msg)
		if not TSM.db.factionrealm.trackTrades then return
		end
		if msg == ERR_TRADE_COMPLETE and tradeInfo then
			-- trade went through
			local info
			if tradeInfo.player.money > 0 and #tradeInfo.player == 0 and tradeInfo.target.money == 0 and #tradeInfo.target > 0 then
				-- player bought items
				local itemString, count
				for i = 1, #tradeInfo.target do
					local data = tradeInfo.target[i]
					if not itemString then
						itemString = data.itemString
						count = data.count
					elseif itemString == data.itemString then
						count = count + data.count
					else
						return
					end
				end
				if not itemString or not count then return
				end
				info = { type = "buys", itemString = itemString, count = count, price = tradeInfo.player.money / count }
				info.gotText = select(2, TSMAPI:GetSafeItemInfo(itemString)) .. "x" .. count
				info.gaveText = TSMAPI:FormatTextMoney(tradeInfo.player.money)
			elseif tradeInfo.player.money == 0 and #tradeInfo.player > 0 and tradeInfo.target.money > 0 and #tradeInfo.target == 0 then
				-- player sold items
				local itemString, count
				for i = 1, #tradeInfo.player do
					local data = tradeInfo.player[i]
					if not itemString then
						itemString = data.itemString
						count = data.count
					elseif itemString == data.itemString then
						count = count + data.count
					else
						return
					end
				end
				if not itemString or not count then return
				end
				info = { type = "sales", itemString = itemString, count = count, price = tradeInfo.target.money / count }
				info.gaveText = select(2, TSMAPI:GetSafeItemInfo(itemString)) .. "x" .. count
				info.gotText = TSMAPI:FormatTextMoney(tradeInfo.target.money)
			else
				return
			end

			if TSM.db.factionrealm.autoTrackTrades then
				Data:AddRecord(info.type, info.itemString, info.price, info.count, tradeInfo.target.name, time())
			else
				StaticPopupDialogs["TSMAccountingOnTrade"] = {
					text = format(L["TSM_Accounting detected that you just traded %s %s in return for %s. Would you like Accounting to store a record of this trade?"], tradeInfo.target.name, info.gaveText, info.gotText),
					button1 = YES,
					button2 = NO,
					timeout = 0,
					whileDead = true,
					hideOnEscape = true,
					OnAccept = function() Data:AddRecord(info.type, info.itemString, info.price, info.count, tradeInfo.target.name, time()) end,
					OnCancel = function() end,
				}
				TSMAPI:ShowStaticPopupDialog("TSMAccountingOnTrade")
			end
		end
	end

	Data:RegisterEvent("TRADE_ACCEPT_UPDATE", onAcceptUpdate)
	Data:RegisterEvent("UI_INFO_MESSAGE", onChatMsg)
end

local lastTrackMinute = 0
function Data:LogGold()
	local currentTime = time()
	local currentMinute = floor(currentTime / 60)
	if currentMinute <= lastTrackMinute then return end
	local player = UnitName("player")
	if not player then return end
	lastTrackMinute = currentMinute

	TSM.db.factionrealm.goldLog[player] = TSM.db.factionrealm.goldLog[player] or {}
	local goldLog = TSM.db.factionrealm.goldLog[player]
	local currentGold = TSM:Round(GetMoney(), COPPER_PER_GOLD * 1000)
	if #goldLog > 0 and currentGold == goldLog[#goldLog].copper then
		goldLog[#goldLog].endMinute = currentMinute
	else
		if #goldLog > 0 then
			goldLog[#goldLog].endMinute = currentMinute - 1
		end
		tinsert(goldLog, { startMinute = currentMinute, endMinute = currentMinute, copper = currentGold })
	end
end