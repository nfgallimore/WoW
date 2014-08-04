-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains code for scanning the auction house
local TSM = select(2, ...)
local private = {}


function TSMAPI:GetAuctionQueryInfo(itemString)
	local name, _, rarity, _, minLevel, class, subClass, _, equipLoc = TSMAPI:GetSafeItemInfo(itemString)
	if not name then return end
	return {name=name, minLevel=minLevel, maxLevel=minLevel, invType=0, class=class, subClass=subClass, quality=rarity}
end

local function GetCommonQueryInfo(name, items)
	local resultQuery = TSMAPI:GetAuctionQueryInfo(items[1])
	resultQuery.name = name
	for i=2, #items do
		local itemQuery = TSMAPI:GetAuctionQueryInfo(items[i])
		resultQuery.minLevel = min(resultQuery.minLevel, itemQuery.minLevel)
		resultQuery.maxLevel = max(resultQuery.maxLevel, itemQuery.maxLevel)
		resultQuery.quality = min(resultQuery.quality, itemQuery.quality)
		if resultQuery.class ~= itemQuery.class then resultQuery.class = nil end
		if resultQuery.subClass ~= itemQuery.subClass then resultQuery.subClass = nil end
	end
	return resultQuery
end

local function GreatestSubstring(str1, str2)
	local parts1 = {(" "):split(str1)}
	local parts2 = {(" "):split(str2)}
	for i=1, #parts1 do
		if parts1[i] ~= parts2[i] then
			local subStr = table.concat(parts1, " ", 1, i-1)
			return subStr ~= "" and subStr
		end
	end
	return table.concat(parts1, " ")
end

local function ReduceStrings(strList)
	local didReduction = true
	while didReduction do
		didReduction = false
		for i=1, #strList-1 do
			if i > #strList-1 then break end
			local subStr = GreatestSubstring(strList[i], strList[i+1])
			if subStr then
				strList[i] = subStr
				tremove(strList, i+1)
				didReduction = true
			end
		end
		if not private.thread then return end
		private.thread:Yield()
	end
	return true
end

local function NumPagesCallback(event, numPages)
	if event == "NUM_PAGES" then
		local skippedItems = {}
		if numPages > #private.combinedQueries[1].items then
			for _, itemString in ipairs(private.combinedQueries[1].items) do
				local query = TSMAPI:GetAuctionQueryInfo(itemString)
				query.items = {itemString}
				tinsert(private.queries, query)
			end
		elseif numPages == 0 then
			for _, itemString in ipairs(private.combinedQueries[1].items) do
				tinsert(skippedItems, itemString)
			end
		else
			-- use the common search term
			tinsert(private.queries, private.combinedQueries[1])
		end
		tremove(private.combinedQueries, 1)
		private.callback("QUERY_UPDATE", private.totalQueries-#private.combinedQueries, private.totalQueries, skippedItems)
	end
	private:CheckNextCombinedQuery()
end

function private:CheckNextCombinedQuery()
	if not private.isScanning then return end
	
	if #private.combinedQueries == 0 then
		-- we're done
		sort(private.queries, function(a, b) return a.name < b.name end)
		TSM:StopGeneratingQueries()
		TSMAPI:CreateTimeDelay("queryUtilCallbackDelay", 0.05, function() private.callback("QUERY_COMPLETE", private.queries) end)
		return
	end
	
	for _, itemString in ipairs(private.combinedQueries[1].items) do
		if strlower(private.combinedQueries[1].name) == strlower(TSMAPI:GetSafeItemInfo(itemString)) then
			-- One of the items in this combined query is the same as the common search term,
			-- so it's always worth using this common search term.
			NumPagesCallback("NUM_PAGES", 1)
			return
		end
	end
	
	TSMAPI.AuctionScan:GetNumPages(private.combinedQueries[1], NumPagesCallback)
end

local function GenerateSearchTerms(names, itemList, isReversed)
	sort(names)
	if not ReduceStrings(names) then return end -- run the reduction
	
	-- create a table associating all the reduced names to a list of items
	local temp = {}
	for i, filterName in ipairs(names) do
		for j, itemString in ipairs(itemList) do
			local itemName = TSMAPI:GetSafeItemInfo(itemString)
			itemName = itemName and isReversed and strrev(itemName) or itemName -- reverse item name if necessary
			if itemName and strfind(itemName, "^"..TSMAPI:StrEscape(filterName)) then
				temp[filterName] = temp[filterName] or {}
				tinsert(temp[filterName], itemString)
			end
		end
		if not private.thread then return end
		private.thread:Yield()
	end
	
	return temp
end

local function GenerateQueriesThread(self)
	private.thread = self
	local function GenerateFilters(reverse)
		-- create a list of all item names
		local names = {}
		for i, itemString in ipairs(private.itemList) do
			local name = TSMAPI:GetSafeItemInfo(itemString)
			if name then
				tinsert(names, reverse and strrev(name) or name)
			end
		end

		local filters, tempFilters, tempItems  = {}, {}, {}
		local numFilters = 0
		local tbl = GenerateSearchTerms(names, private.itemList, reverse)
		if not tbl then return end
		for filterName, items in pairs(tbl) do
			if #items > 1 then
				filters[reverse and strrev(filterName) or filterName] = items
				numFilters = numFilters + 1
			else
				tinsert(tempFilters, strrev(filterName)) -- reverse name for second pass
				for _, itemString in ipairs(items) do
					tinsert(tempItems, itemString)
				end
			end
		end
		
		-- try to find common search terms of reversed item names
		local tbl = GenerateSearchTerms(tempFilters, tempItems, not reverse)
		if not tbl then return end
		for filterName, items in pairs(tbl) do
			filters[reverse and filterName or strrev(filterName)] = items
			numFilters = numFilters + 1
		end
		
		return filters, numFilters
	end
	local filters1, num1 = GenerateFilters()
	local filters2, num2 = GenerateFilters(true)
	if not filters1 or not filters2 then return end
	local filters = num2 < num1 and filters2 or filters1
	
	-- create the actual queries
	local queries, combinedQueries = {}, {}
	for filterName, items in pairs(filters) do
		local query = GetCommonQueryInfo(filterName, items)
		query.items = items
		if #query.items > 1 then
			tinsert(combinedQueries, query)
		else
			tinsert(queries, query)
		end
	end
	
	private.isScanning = true
	private.queries = queries
	private.combinedQueries = combinedQueries
	private.totalQueries = #combinedQueries
end

function TSMAPI:GenerateQueries(itemList, callback)
	if private.thread then return end
	private.itemList = itemList
	private.callback = callback
	
	local function ThreadDone()
		if private.thread then
			private.thread = nil
			private:CheckNextCombinedQuery()
		end
	end
	TSMAPI.Threading:Start(GenerateQueriesThread, 0.5, ThreadDone)
end

function TSM:StopGeneratingQueries()
	private.thread = nil
	private.isScanning = nil
end