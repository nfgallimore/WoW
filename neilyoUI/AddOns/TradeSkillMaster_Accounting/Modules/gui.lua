-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- create a local reference to the TradeSkillMaster_Crafting table and register a new module
local TSM = select(2, ...)
local GUI = TSM:NewModule("GUI", "AceEvent-3.0", "AceHook-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Accounting") -- loads the localization table

local ROW_HEIGHT = 16
local scrollingTables = {}
local defaultFilterFunc = function() return true end

function GUI:Load(parent)
	local simpleGroup = AceGUI:Create("SimpleGroup")
	simpleGroup:SetLayout("Fill")
	parent:AddChild(simpleGroup)

	local tabGroup = AceGUI:Create("TSMTabGroup")
	tabGroup:SetLayout("Fill")
	tabGroup:SetTabs({ { text = L["Revenue"], value = 1 }, { text = L["Expenses"], value = 2 }, { text = L["Failed Auctions"], value = 3 }, { text = L["Items"], value = 4 }, { text = L["Summary"], value = 5 }, { text = L["Player Gold"], value = 6 }, { text = L["Options"], value = 7 } })
	tabGroup:SetCallback("OnGroupSelected", function(self, _, value)
		tabGroup:ReleaseChildren()
		GUI:HideScrollingTables()
		if GUI.lineGraph then
			GUI.lineGraph:Hide()
		end
		if value == 1 then
			GUI:DrawRevenueTab(self)
		elseif value == 2 then
			GUI:DrawExpenseTab(self)
		elseif value == 3 then
			GUI:DrawFailedAucsTab(self)
		elseif value == 4 then
			GUI:DrawItemSummary(self)
		elseif value == 5 then
			GUI:DrawGoldSummary(self)
		elseif value == 6 then
			GUI:DrawGoldGraph(self)
		elseif value == 7 then
			GUI:DrawOptions(self)
		end
		tabGroup.children[1]:DoLayout()
	end)
	simpleGroup:AddChild(tabGroup)
	TSM.Data:PopulateDataCaches()
	tabGroup:SelectTab(1)

	GUI:HookScript(simpleGroup.frame, "OnHide", function()
		GUI:UnhookAll()
		GUI:HideScrollingTables()
		if GUI.lineGraph then
			GUI.lineGraph:Hide()
		end
	end)
end

function GUI:DrawRevenueTab(container)
	local simpleGroup = AceGUI:Create("SimpleGroup")
	simpleGroup:SetLayout("Fill")
	container:AddChild(simpleGroup)

	local tabGroup = AceGUI:Create("TSMTabGroup")
	tabGroup:SetLayout("Fill")
	tabGroup:SetTabs({ { text = L["Sales"], value = 1 }, { text = L["Other Income"], value = 2 }, { text = L["Resale"], value = 3 } })
	tabGroup:SetCallback("OnGroupSelected", function(self, _, value)
		tabGroup:ReleaseChildren()
		GUI:HideScrollingTables()
		if value == 1 then
			GUI:DrawSales(self)
		elseif value == 2 then
			GUI:DrawIncome(self)
		elseif value == 3 then
			GUI:DrawResaleSummary(self)
		end
		tabGroup.children[1]:DoLayout()
	end)
	simpleGroup:AddChild(tabGroup)
	TSM.Data:PopulateDataCaches()
	tabGroup:SelectTab(1)
end

function GUI:DrawExpenseTab(container)
	local simpleGroup = AceGUI:Create("SimpleGroup")
	simpleGroup:SetLayout("Fill")
	container:AddChild(simpleGroup)

	local tabGroup = AceGUI:Create("TSMTabGroup")
	tabGroup:SetLayout("Fill")
	tabGroup:SetTabs({ { text = L["Purchases"], value = 1 }, { text = L["Other"], value = 2 } })
	tabGroup:SetCallback("OnGroupSelected", function(self, _, value)
		tabGroup:ReleaseChildren()
		GUI:HideScrollingTables()
		if value == 1 then
			GUI:DrawPurchases(self)
		elseif value == 2 then
			GUI:DrawExpenses(self)
		end
		tabGroup.children[1]:DoLayout()
	end)
	simpleGroup:AddChild(tabGroup)
	TSM.Data:PopulateDataCaches()
	tabGroup:SelectTab(1)
end

function GUI:DrawFailedAucsTab(container)
	local simpleGroup = AceGUI:Create("SimpleGroup")
	simpleGroup:SetLayout("Fill")
	container:AddChild(simpleGroup)

	local tabGroup = AceGUI:Create("TSMTabGroup")
	tabGroup:SetLayout("Fill")
	tabGroup:SetTabs({ { text = L["Expired"], value = 1 }, { text = L["Cancelled"], value = 2 } })
	tabGroup:SetCallback("OnGroupSelected", function(self, _, value)
		tabGroup:ReleaseChildren()
		GUI:HideScrollingTables()
		if value == 1 then
			GUI:DrawExpired(self)
		elseif value == 2 then
			GUI:DrawCancelled(self)
		end
		tabGroup.children[1]:DoLayout()
	end)
	simpleGroup:AddChild(tabGroup)
	TSM.Data:PopulateDataCaches()
	tabGroup:SelectTab(1)
end

function GUI:DrawSales(container)
	GUI:CreateTopWidgetsPlayer(container, "sale", function(...) return TSM.Data:GetSTData("sales", ...) end)
	local stParent = container.children[1].children[#container.children[1].children].frame

	if not scrollingTables.sale then
		local stCols = {
			{
				name = L["Item Name"],
				width = 0.34,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Player"],
				width = 0.1,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Source"],
				width = 0.06,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Stack"],
				width = 0.05,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Aucs"],
				width = 0.05,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Price Per Item"],
				width = 0.12,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Total Sale Price"],
				width = 0.13,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Last Sold"],
				width = 0.14,
				align = "LEFT",
				headAlign = "LEFT",
			},
		}
		local handlers = {
			OnClick = function(_, data, self)
				if not data then return end
				GUI:HideScrollingTables()
				GUI:DrawItemLookup(container, data.itemString, 1, 1)
				container.children[1]:DoLayout()
			end,
			OnEnter = function(_, data, self)
				if not data then return end

				GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
				GameTooltip:SetText(L["Click for a detailed report on this item."], 1, .82, 0, 1)
				GameTooltip:Show()
			end,
			OnLeave = function()
				GameTooltip:ClearLines()
				GameTooltip:Hide()
			end
		}
		TSMAPI:CreateTimeDelay(0, function()
				scrollingTables.sale = TSMAPI:CreateScrollingTable(stParent, stCols, handlers)
				scrollingTables.sale:EnableSorting(true, -8)
				scrollingTables.sale:DisableSelection(true)
				scrollingTables.sale:Show()
				scrollingTables.sale:SetParent(stParent)
				scrollingTables.sale:SetAllPoints()
				scrollingTables.sale:SetData(TSM.Data:GetSTData("sales"))
			end)
	else
		scrollingTables.sale:Show()
		scrollingTables.sale:SetParent(stParent)
		scrollingTables.sale:SetAllPoints()
		scrollingTables.sale:SetData(TSM.Data:GetSTData("sales"))
	end
end

function GUI:DrawPurchases(container)
	GUI:CreateTopWidgetsPlayer(container, "buy", function(...) return TSM.Data:GetSTData("buys", ...) end)
	local stParent = container.children[1].children[#container.children[1].children].frame

	if not scrollingTables.buy then
		local stCols = {
			{
				name = L["Item Name"],
				width = 0.34,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Player"],
				width = 0.1,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Source"],
				width = 0.06,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Stack"],
				width = 0.05,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Aucs"],
				width = 0.05,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Price Per Item"],
				width = 0.12,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Total Buy Price"],
				width = 0.13,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Last Purchase"],
				width = 0.14,
				align = "LEFT",
				headAlign = "LEFT",
			},
		}
		local handlers = {
			OnClick = function(_, data, self)
				if not data then return end
				GUI:HideScrollingTables()
				GUI:DrawItemLookup(container, data.itemString, 2, 1)
				container.children[1]:DoLayout()
			end,
			OnEnter = function(_, data, self)
				if not data then return end

				GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
				GameTooltip:SetText(L["Click for a detailed report on this item."], 1, .82, 0, 1)
				GameTooltip:Show()
			end,
			OnLeave = function()
				GameTooltip:ClearLines()
				GameTooltip:Hide()
			end
		}
		TSMAPI:CreateTimeDelay(0, function()
				scrollingTables.buy = TSMAPI:CreateScrollingTable(stParent, stCols, handlers)
				scrollingTables.buy:EnableSorting(true, -8)
				scrollingTables.buy:DisableSelection(true)
				scrollingTables.buy:Show()
				scrollingTables.buy:SetParent(stParent)
				scrollingTables.buy:SetAllPoints()
				scrollingTables.buy:SetData(TSM.Data:GetSTData("buys"))
			end)
	else
		scrollingTables.buy:Show()
		scrollingTables.buy:SetParent(stParent)
		scrollingTables.buy:SetAllPoints()
		scrollingTables.buy:SetData(TSM.Data:GetSTData("buys"))
	end
end

function GUI:DrawItemSummary(container)
	GUI:CreateTopWidgetsItem(container, "itemSummary", function(...) return TSM.Data:GetItemSummaryData(...) end)
	local stParent = container.children[1].children[#container.children[1].children].frame

	if not scrollingTables.itemSummary then
		local stCols = {
			{
				name = L["Item Name"],
				width = 0.38,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Market Value"],
				width = 0.15,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Sold"],
				width = 0.06,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = TSM.db.factionrealm.priceFormat == "avg" and L["Avg Sell Price"] or L["Total Sale Price"],
				width = 0.15,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Bought"],
				width = 0.07,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = TSM.db.factionrealm.priceFormat == "avg" and L["Avg Buy Price"] or L["Total Buy Price"],
				width = 0.15,
				align = "LEFT",
				headAlign = "LEFT",
			},
		}
		local handlers = {
			OnClick = function(_, data, self)
				if not data then return end
				GUI:HideScrollingTables()
				GUI:DrawItemLookup(container, data.itemString, 4)
				container.children[1]:DoLayout()
			end,
			OnEnter = function(_, data, self)
				if not data then return end

				GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
				GameTooltip:SetText(L["Click for a detailed report on this item."], 1, .82, 0, 1)
				GameTooltip:Show()
			end,
			OnLeave = function()
				GameTooltip:ClearLines()
				GameTooltip:Hide()
			end
		}
		TSMAPI:CreateTimeDelay(0, function()
				scrollingTables.itemSummary = TSMAPI:CreateScrollingTable(stParent, stCols, handlers)
				scrollingTables.itemSummary:EnableSorting(true, 1)
				scrollingTables.itemSummary:DisableSelection(true)
				scrollingTables.itemSummary:Show()
				scrollingTables.itemSummary:SetParent(stParent)
				scrollingTables.itemSummary:SetAllPoints()
				scrollingTables.itemSummary:SetData(TSM.Data:GetItemSummaryData())
			end)
	else
		scrollingTables.itemSummary:Show()
		scrollingTables.itemSummary:SetParent(stParent)
		scrollingTables.itemSummary:SetAllPoints()
		scrollingTables.itemSummary:SetData(TSM.Data:GetItemSummaryData())
	end
end

function GUI:DrawResaleSummary(container)
	GUI:CreateTopWidgets(container, "resale", function(...) return TSM.Data:GetResaleSummaryData(...) end)
	local stParent = container.children[1].children[#container.children[1].children].frame

	if not scrollingTables.resale then
		local stCols = {
			{
				name = L["Item Name"],
				width = 0.37,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Sold"],
				width = 0.06,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = TSM.db.factionrealm.priceFormat == "avg" and L["Avg Sell Price"] or L["Total Sale Price"],
				width = 0.14,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Bought"],
				width = 0.07,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = TSM.db.factionrealm.priceFormat == "avg" and L["Avg Buy Price"] or L["Total Buy Price"],
				width = 0.14,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Avg Resale Profit"],
				width = 0.21,
				align = "LEFT",
				headAlign = "LEFT",
			},
		}
		local handlers = {
			OnClick = function(_, data, self)
				if not data then return end
				GUI:HideScrollingTables()
				GUI:DrawItemLookup(container, data.itemString, 1, 3)
				container.children[1]:DoLayout()
			end,
			OnEnter = function(_, data, self)
				if not data then return end

				GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
				GameTooltip:SetText(L["Click for a detailed report on this item."], 1, .82, 0, 1)
				GameTooltip:Show()
			end,
			OnLeave = function()
				GameTooltip:ClearLines()
				GameTooltip:Hide()
			end
		}
		TSMAPI:CreateTimeDelay(0, function()
				scrollingTables.resale = TSMAPI:CreateScrollingTable(stParent, stCols, handlers)
				scrollingTables.resale:EnableSorting(true, -6)
				scrollingTables.resale:DisableSelection(true)
				scrollingTables.resale:Show()
				scrollingTables.resale:SetParent(stParent)
				scrollingTables.resale:SetAllPoints()
				scrollingTables.resale:SetData(TSM.Data:GetResaleSummaryData())
			end)
	else
		scrollingTables.resale:Show()
		scrollingTables.resale:SetParent(stParent)
		scrollingTables.resale:SetAllPoints()
		scrollingTables.resale:SetData(TSM.Data:GetResaleSummaryData())
	end
end

function GUI:DrawItemLookup(container, itemString, returnTab, returnSubTab)
	container:ReleaseChildren()
	local itemID = TSMAPI:GetItemID(itemString)
	local itemData = TSM.Data:GetItemData(itemString)

	local color, color2 = TSMAPI.Design:GetInlineColor("link2"), TSMAPI.Design:GetInlineColor("category2")

	local buyers, sellers = {}, {}
	for name, quantity in pairs(itemData.buyers) do
		tinsert(buyers, { name = name, quantity = quantity })
	end
	for name, quantity in pairs(itemData.sellers) do
		tinsert(sellers, { name = name, quantity = quantity })
	end
	sort(buyers, function(a, b) return a.quantity > b.quantity end)
	sort(sellers, function(a, b) return a.quantity > b.quantity end)

	local buyersText, sellersText = "", ""
	for i = 1, min(#buyers, 5) do
		buyersText = buyersText .. "|cffffffff" .. buyers[i].name .. "|r" .. color .. "(" .. buyers[i].quantity .. ")|r, "
	end
	for i = 1, min(#sellers, 5) do
		sellersText = sellersText .. "|cffffffff" .. sellers[i].name .. "|r" .. color .. "(" .. sellers[i].quantity .. ")|r, "
	end

	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			children = {
				{
					type = "SimpleGroup",
					layout = "Flow",
					children = {
						{
							type = "Label",
							relativeWidth = 0.1,
						},
						{
							type = "InteractiveLabel",
							text = select(2, TSMAPI:GetSafeItemInfo(itemString)) or TSM.Data.items[itemString].name,
							fontObject = GameFontNormalLarge,
							relativeWidth = 0.4,
							callback = function() SetItemRef("item:" .. itemID, itemID) end,
							tooltip = itemID,
						},
						{
							type = "Label",
							relativeWidth = 0.1,
						},
						{
							type = "Button",
							text = L["Back to Previous Page"],
							relativeWidth = 0.29,
							callback = function()
								if returnSubTab then
									local topTabGroup = container.parent.parent
									-- not sure why, but sometimes the details get displayed within the top tabgroup, rather than the sub-tabgroup
									if topTabGroup.type == "TSMMainFrame" then
										topTabGroup = container
									end
									if topTabGroup.localstatus.selected ~= returnTab then
										topTabGroup:SelectTab(returnTab)
									end
									TSMAPI:CreateTimeDelay("accountingReturnDelay", 0, function() container:SelectTab(returnSubTab) end)
								else
									container:SelectTab(returnTab)
								end
							end,
						},
					},
				},
				{
					type = "HeadingLine",
				},
				{
					type = "InlineGroup",
					title = L["Sale Data"],
					layout = "Flow",
					backdrop = true,
					children = {},
				},
				{
					type = "InlineGroup",
					title = L["Purchase Data"],
					layout = "Flow",
					backdrop = true,
					children = {},
				},
				{
					type = "Spacer",
					quantity = 2,
				},
				{
					type = "ScrollFrame",
					layout = "Flow",
					fullHeight = true,
				},
			},
		},
	}

	local sellWidgets, buyWidgets
	if itemData.avgTotalSell then
		sellWidgets = {
			{
				type = "MultiLabel",
				labelInfo = {
					{ text = color2 .. L["Average Prices:"], relativeWidth = 0.19 },
					{ text = color .. L["Total:"] .. " |r" .. (TSMAPI:FormatTextMoney(itemData.avgTotalSell) or "---"), relativeWidth = 0.22 },
					{ text = color .. L["Last 30 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(itemData.avgMonthSell) or "---"), relativeWidth = 0.29 },
					{ text = color .. L["Last 7 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(itemData.avgWeekSell) or "---"), relativeWidth = 0.29 }
				},
				relativeWidth = 1,
			},
			{
				type = "MultiLabel",
				labelInfo = {
					{ text = color2 .. L["Quantity Sold:"], relativeWidth = 0.19 },
					{ text = color .. L["Total:"] .. " |r|cffffffff" .. itemData.totalSellNum, relativeWidth = 0.22 },
					{ text = color .. L["Last 30 Days:"] .. " |r|cffffffff" .. itemData.monthSellNum, relativeWidth = 0.29 },
					{ text = color .. L["Last 7 Days:"] .. " |r|cffffffff" .. itemData.weekSellNum, relativeWidth = 0.29 }
				},
				relativeWidth = 1,
			},
			{
				type = "MultiLabel",
				labelInfo = {
					{ text = color2 .. L["Gold Earned:"], relativeWidth = 0.19 },
					{ text = color .. L["Total:"] .. " |r" .. (TSMAPI:FormatTextMoney(itemData.avgTotalSell * itemData.totalSellNum) or "---"), relativeWidth = 0.22 },
					{ text = color .. L["Last 30 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(itemData.avgMonthSell * itemData.monthSellNum) or "---"), relativeWidth = 0.29 },
					{ text = color .. L["Last 7 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(itemData.avgWeekSell * itemData.weekSellNum) or "---"), relativeWidth = 0.29 }
				},
				relativeWidth = 1,
			},
			{
				type = "Label",
				relativeWidth = 1,
				text = color2 .. L["Top Buyers:"] .. " |r" .. buyersText,
			},
		}
	else
		sellWidgets = {
			{
				type = "Label",
				relativeWidth = 1,
				text = "|cffffffff" .. L["There is no sale data for this item."] .. "|r",
			},
		}
	end

	if itemData.avgTotalBuy then
		buyWidgets = {
			{
				type = "MultiLabel",
				labelInfo = {
					{ text = color2 .. L["Average Prices:"], relativeWidth = 0.19 },
					{ text = color .. L["Total:"] .. " |r" .. (TSMAPI:FormatTextMoney(itemData.avgTotalBuy) or "---"), relativeWidth = 0.22 },
					{ text = color .. L["Last 30 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(itemData.avgMonthBuy) or "---"), relativeWidth = 0.29 },
					{ text = color .. L["Last 7 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(itemData.avgWeekBuy) or "---"), relativeWidth = 0.29 }
				},
				relativeWidth = 1,
			},
			{
				type = "MultiLabel",
				labelInfo = {
					{ text = color2 .. L["Quantity Bought:"], relativeWidth = 0.19 },
					{ text = color .. L["Total:"] .. " |r|cffffffff" .. itemData.totalBuyNum, relativeWidth = 0.22 },
					{ text = color .. L["Last 30 Days:"] .. " |r|cffffffff" .. itemData.monthBuyNum, relativeWidth = 0.29 },
					{ text = color .. L["Last 7 Days:"] .. " |r|cffffffff" .. itemData.weekBuyNum, relativeWidth = 0.29 }
				},
				relativeWidth = 1,
			},
			{
				type = "MultiLabel",
				labelInfo = {
					{ text = color2 .. L["Total Spent:"], relativeWidth = 0.19 },
					{ text = color .. L["Total:"] .. " |r" .. (TSMAPI:FormatTextMoney(itemData.avgTotalBuy * itemData.totalBuyNum) or "---"), relativeWidth = 0.22 },
					{ text = color .. L["Last 30 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(itemData.avgMonthBuy * itemData.monthBuyNum) or "---"), relativeWidth = 0.29 },
					{ text = color .. L["Last 7 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(itemData.avgWeekBuy * itemData.weekBuyNum) or "---"), relativeWidth = 0.29 }
				},
				relativeWidth = 1,
			},
			{
				type = "Label",
				relativeWidth = 1,
				text = color2 .. L["Top Sellers:"] .. " |r" .. sellersText,
			},
		}
	else
		buyWidgets = {
			{
				type = "Label",
				relativeWidth = 1,
				text = "|cffffffff" .. L["There is no purchase data for this item."] .. "|r",
			},
		}
	end

	local index
	for i = 2, #page[1].children do
		if page[1].children[i].type == "InlineGroup" then
			index = i
			break
		end
	end

	for i = 1, #sellWidgets do
		tinsert(page[1].children[index].children, sellWidgets[i])
	end
	for i = 1, #buyWidgets do
		tinsert(page[1].children[index + 1].children, buyWidgets[i])
	end

	TSMAPI:BuildPage(container, page)

	local stParent = container.children[1].children[#container.children[1].children].frame
	if not scrollingTables.itemDetail then
		local stCols = {
			{
				name = L["Activity Type"],
				width = 0.15,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Source"],
				width = 0.14,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Buyer/Seller"],
				width = 0.15,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Quantity"],
				width = 0.1,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Price Per Item"],
				width = 0.15,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Total Price"],
				width = 0.15,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Time"],
				width = 0.15,
				align = "LEFT",
				headAlign = "LEFT",
			},
		}
		local handlers = {
			OnClick = function(_, data, self, button)
				if not data then return end
				if button == "RightButton" and IsShiftKeyDown() then
					if data.type == "Sale" then
						for i, v in ipairs(TSM.Data.items[itemString].sales) do
							if v == data.record then
								tremove(TSM.Data.items[itemString].sales, i)
								break
							end
						end
					elseif data.type == "Purchase" then
						for i, v in ipairs(TSM.Data.items[itemString].buys) do
							if v == data.record then
								tremove(TSM.Data.items[itemString].buys, i)
								break
							end
						end
					end
					for i, v in ipairs(itemData.stData) do
						if v == data then
							tremove(itemData.stData, i)
							break
						end
					end
					scrollingTables.itemDetail:SetData(itemData.stData)
					TSM:Print(L["Removed record."])
				end
			end,
			OnEnter = function(_, data, self)
				if not data then return end

				GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
				GameTooltip:SetText(L["Shift-Right-Click to delete this record."], 1, .82, 0, 1)
				GameTooltip:Show()
			end,
			OnLeave = function()
				GameTooltip:ClearLines()
				GameTooltip:Hide()
			end
		}
		TSMAPI:CreateTimeDelay(0, function()
				scrollingTables.itemDetail = TSMAPI:CreateScrollingTable(stParent, stCols, handlers)
				scrollingTables.itemDetail:EnableSorting(true, -7)
				scrollingTables.itemDetail:DisableSelection(true)
				scrollingTables.itemDetail:Show()
				scrollingTables.itemDetail:SetParent(stParent)
				scrollingTables.itemDetail:SetAllPoints()
				scrollingTables.itemDetail:SetData(itemData.stData)
			end)
	else
		scrollingTables.itemDetail:Show()
		scrollingTables.itemDetail:SetParent(stParent)
		scrollingTables.itemDetail:SetAllPoints()
		scrollingTables.itemDetail:SetData(itemData.stData)
	end
end

function GUI:DrawIncome(container)
	GUI:CreateTopWidgetsMoney(container, "income", function(...) return TSM.Data:GetMoneyData("income", ...) end)
	local stParent = container.children[1].children[#container.children[1].children].frame

	if not scrollingTables.income then
		local stCols = {
			{
				name = L["Type"],
				width = 0.3,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Player"],
				width = 0.2,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Source"],
				width = 0.2,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Income"],
				width = 0.14,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Time"],
				width = 0.15,
				align = "LEFT",
				headAlign = "LEFT",
			},
		}
		local handlers = {
			OnClick = function(_, data, self)
				if not data then return end
			end,
		}
		TSMAPI:CreateTimeDelay(0, function()
				scrollingTables.income = TSMAPI:CreateScrollingTable(stParent, stCols, handlers)
				scrollingTables.income:EnableSorting(true, -5)
				scrollingTables.income:DisableSelection(true)
				scrollingTables.income:Show()
				scrollingTables.income:SetParent(stParent)
				scrollingTables.income:SetAllPoints()
				scrollingTables.income:SetData(TSM.Data:GetMoneyData("income"))
			end)
	else
		scrollingTables.income:Show()
		scrollingTables.income:SetParent(stParent)
		scrollingTables.income:SetAllPoints()
		scrollingTables.income:SetData(TSM.Data:GetMoneyData("income"))
	end
end

function GUI:DrawExpenses(container)
	GUI:CreateTopWidgetsMoney(container, "expense", function(...) return TSM.Data:GetMoneyData("expense", ...) end)
	local stParent = container.children[1].children[#container.children[1].children].frame

	if not scrollingTables.expense then
		local stCols = {
			{
				name = L["Type"],
				width = 0.3,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Player"],
				width = 0.2,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Target"],
				width = 0.2,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Cost"],
				width = 0.14,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Time"],
				width = 0.15,
				align = "LEFT",
				headAlign = "LEFT",
			},
		}
		local handlers = {
			OnClick = function(_, data, self)
				if not data then return end
			end,
		}
		TSMAPI:CreateTimeDelay(0, function()
				scrollingTables.expense = TSMAPI:CreateScrollingTable(stParent, stCols, handlers)
				scrollingTables.expense:EnableSorting(true, -5)
				scrollingTables.expense:DisableSelection(true)
				scrollingTables.expense:Show()
				scrollingTables.expense:SetParent(stParent)
				scrollingTables.expense:SetAllPoints()
				scrollingTables.expense:SetData(TSM.Data:GetMoneyData("expense"))
			end)
	else
		scrollingTables.expense:Show()
		scrollingTables.expense:SetParent(stParent)
		scrollingTables.expense:SetAllPoints()
		scrollingTables.expense:SetData(TSM.Data:GetMoneyData("expense"))
	end
end

function GUI:DrawExpired(container)
	GUI:CreateTopWidgetsAuctions(container, "expired", function(...) return TSM.Data:GetAucData("expired", ...) end)
	local stParent = container.children[1].children[#container.children[1].children].frame

	if not scrollingTables.expired then
		local stCols = {
			{
				name = L["Item Name"],
				width = 0.4,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Player"],
				width = 0.2,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Stack"],
				width = 0.1,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Aucs"],
				width = 0.1,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Time"],
				width = 0.19,
				align = "LEFT",
				headAlign = "LEFT",
			},
		}
		local handlers = {
			OnEnter = function(_, data, self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				TSMAPI:SafeTooltipLink(data.itemString)
				GameTooltip:Show()
			end,
			OnLeave = function()
				GameTooltip:ClearLines()
				GameTooltip:Hide()
			end
		}
		TSMAPI:CreateTimeDelay(0, function()
				scrollingTables.expired = TSMAPI:CreateScrollingTable(stParent, stCols, handlers)
				scrollingTables.expired:EnableSorting(true, -5)
				scrollingTables.expired:DisableSelection(true)
				scrollingTables.expired:Show()
				scrollingTables.expired:SetParent(stParent)
				scrollingTables.expired:SetAllPoints()
				scrollingTables.expired:SetData(TSM.Data:GetAucData("expired"))
			end)
	else
		scrollingTables.expired:Show()
		scrollingTables.expired:SetParent(stParent)
		scrollingTables.expired:SetAllPoints()
		scrollingTables.expired:SetData(TSM.Data:GetAucData("expired"))
	end
end

function GUI:DrawCancelled(container)
	GUI:CreateTopWidgetsAuctions(container, "cancelled", function(...) return TSM.Data:GetAucData("cancelled", ...) end)
	local stParent = container.children[1].children[#container.children[1].children].frame

	if not scrollingTables.cancelled then
		local stCols = {
			{
				name = L["Item Name"],
				width = 0.4,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Player"],
				width = 0.2,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Stack"],
				width = 0.1,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Aucs"],
				width = 0.1,
				align = "LEFT",
				headAlign = "LEFT",
			},
			{
				name = L["Time"],
				width = 0.19,
				align = "LEFT",
				headAlign = "LEFT",
			},
		}
		local handlers = {
			OnEnter = function(_, data, self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				TSMAPI:SafeTooltipLink(data.itemString)
				GameTooltip:Show()
			end,
			OnLeave = function()
				GameTooltip:ClearLines()
				GameTooltip:Hide()
			end
		}
		TSMAPI:CreateTimeDelay(0, function()
				scrollingTables.cancelled = TSMAPI:CreateScrollingTable(stParent, stCols, handlers)
				scrollingTables.cancelled:EnableSorting(true, -5)
				scrollingTables.cancelled:DisableSelection(true)
				scrollingTables.cancelled:Show()
				scrollingTables.cancelled:SetParent(stParent)
				scrollingTables.cancelled:SetAllPoints()
				scrollingTables.cancelled:SetData(TSM.Data:GetAucData("cancelled"))
			end)
	else
		scrollingTables.cancelled:Show()
		scrollingTables.cancelled:SetParent(stParent)
		scrollingTables.cancelled:SetAllPoints()
		scrollingTables.cancelled:SetData(TSM.Data:GetAucData("cancelled"))
	end
end

local goldSummaryFilters = {group=nil, player=nil}
function GUI:DrawGoldSummary(container)
	if goldSummaryFilters.isReloading then
		goldSummaryFilters.isReloading = nil
	else
		goldSummaryFilters = {group=nil, player="all"}
	end
	
	local data = TSM.Data:GetGoldData(goldSummaryFilters)
	local color, color2 = TSMAPI.Design:GetInlineColor("link2"), TSMAPI.Design:GetInlineColor("category2")

	local topSellGoldLink = data.topSellGold.itemString and (select(2, TSMAPI:GetSafeItemInfo(data.topSellGold.itemString)) or TSM.Data.items[data.topSellGold.itemString].name) or L["none"]
	local topSellQuantityLink = data.topSellQuantity.itemString and (select(2, TSMAPI:GetSafeItemInfo(data.topSellQuantity.itemString)) or TSM.Data.items[data.topSellQuantity.itemString].name) or L["none"]
	local topBuyGoldLink = data.topBuyGold.itemString and (select(2, TSMAPI:GetSafeItemInfo(data.topBuyGold.itemString)) or TSM.Data.items[data.topBuyGold.itemString].name) or L["none"]
	local topBuyQuantityLink = data.topBuyQuantity.itemString and (select(2, TSMAPI:GetSafeItemInfo(data.topBuyQuantity.itemString)) or TSM.Data.items[data.topBuyQuantity.itemString].name) or L["none"]

	local ddpList = {["all"]=L["All"]}
	if TSM.Data.playerDataCache then
		for _, player in pairs(TSM.Data.playerDataCache) do
			ddpList[player] = player
		end
	end
	
	local page = {
		{
			type = "ScrollFrame",
			layout = "Flow",
			children = {
				{
					type = "SimpleGroup",
					layout = "Flow",
					children = {
						{
							type = "GroupBox",
							label = L["Group"],
							relativeWidth = 0.5,
							value = TSMAPI:FormatGroupPath(goldSummaryFilters.group),
							callback = function(_, _, value)
								goldSummaryFilters.group = value
								goldSummaryFilters.isReloading = true
								container:ReloadTab()
							end,
						},
						{
							type = "Dropdown",
							label = L["Player(s)"],
							relativeWidth = 0.49,
							list = ddpList,
							value = goldSummaryFilters.player,
							callback = function(_, _, value)
								goldSummaryFilters.player = value
								goldSummaryFilters.isReloading = true
								container:ReloadTab()
							end,
						},
					},
				},
				{
					type = "HeadingLine",
				},
				{
					type = "InlineGroup",
					layout = "Flow",
					title = L["Sales"],
					backdrop = true,
					children = {
						{
							type = "MultiLabel",
							labelInfo = {
								{ text = color2 .. L["Gold Earned:"], relativeWidth = 0.19 },
								{ text = color .. L["Total:"] .. " |r" .. (TSMAPI:FormatTextMoney(data.totalSale) or "---"), relativeWidth = 0.22 },
								{ text = color .. L["Last 30 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(data.monthSale) or "---"), relativeWidth = 0.29 },
								{ text = color .. L["Last 7 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(data.weekSale) or "---"), relativeWidth = 0.29 }
							},
							relativeWidth = 1,
						},
						{
							type = "MultiLabel",
							labelInfo = {
								{ text = color2 .. L["Earned Per Day:"], relativeWidth = 0.19 },
								{ text = color .. L["Total:"] .. " |r" .. (TSMAPI:FormatTextMoney(floor(data.totalSale / data.totalTime + 0.5)) or "---"), relativeWidth = 0.22 },
								{ text = color .. L["Last 30 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(floor(data.monthSale / data.monthTime + 0.5)) or "---"), relativeWidth = 0.29 },
								{ text = color .. L["Last 7 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(floor(data.weekSale / data.weekTime + 0.5)) or "---"), relativeWidth = 0.29 }
							},
							relativeWidth = 1,
						},
						{
							type = "Label",
							relativeWidth = 0.28,
							text = color2 .. L["Top Item by Gold / Quantity:"] .. "|r",
						},
						{
							type = "InteractiveLabel",
							text = topSellGoldLink .. " (" .. (TSMAPI:FormatTextMoney(data.topSellGold.price) or "---") .. ")",
							relativeWidth = 0.36,
							callback = function() SetItemRef("item:" .. data.topSellGold.itemID, data.topSellGold.itemID) end,
							tooltip = data.topSellGold.itemID,
						},
						{
							type = "InteractiveLabel",
							text = topSellQuantityLink .. " (" .. (data.topSellQuantity.num or "---") .. ")",
							relativeWidth = 0.36,
							callback = function() SetItemRef("item:" .. data.topSellQuantity.itemID, data.topSellQuantity.itemID) end,
							tooltip = data.topSellQuantity.itemID,
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "Flow",
					title = L["Other Income"],
					backdrop = true,
					children = {
						{
							type = "MultiLabel",
							labelInfo = {
								{ text = color2 .. L["Gold Earned:"], relativeWidth = 0.19 },
								{ text = color .. L["Total:"] .. " |r" .. (TSMAPI:FormatTextMoney(data.totalIncome) or "---"), relativeWidth = 0.22 },
								{ text = color .. L["Last 30 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(data.monthIncome) or "---"), relativeWidth = 0.29 },
								{ text = color .. L["Last 7 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(data.weekIncome) or "---"), relativeWidth = 0.29 }
							},
							relativeWidth = 1,
						},
						{
							type = "MultiLabel",
							labelInfo = {
								{ text = color2 .. L["Earned Per Day:"], relativeWidth = 0.19 },
								{ text = color .. L["Total:"] .. " |r" .. (TSMAPI:FormatTextMoney(floor(data.totalIncome / data.totalTime + 0.5)) or "---"), relativeWidth = 0.22 },
								{ text = color .. L["Last 30 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(floor(data.monthIncome / data.monthTime + 0.5)) or "---"), relativeWidth = 0.29 },
								{ text = color .. L["Last 7 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(floor(data.weekIncome / data.weekTime + 0.5)) or "---"), relativeWidth = 0.29 }
							},
							relativeWidth = 1,
						},
						{
							type = "Label",
							relativeWidth = 0.28,
							text = color2 .. L["Top Income by Gold / Quantity:"] .. "|r",
						},
						{
							type = "Label",
							text = (data.topIncomeGold.type or L["none"]) .. " (" .. (TSMAPI:FormatTextMoney(data.topIncomeGold.amount) or "---") .. ")",
							relativeWidth = 0.36,
						},
						{
							type = "Label",
							text = (data.topIncomeQuantity.type or L["none"]) .. " (" .. (data.topIncomeQuantity.num or "---") .. ")",
							relativeWidth = 0.36,
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "Flow",
					title = L["Purchases"],
					backdrop = true,
					children = {
						{
							type = "MultiLabel",
							labelInfo = {
								{ text = color2 .. L["Gold Spent:"], relativeWidth = 0.19 },
								{ text = color .. L["Total:"] .. " |r" .. (TSMAPI:FormatTextMoney(data.totalBuy) or "---"), relativeWidth = 0.22 },
								{ text = color .. L["Last 30 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(data.monthBuy) or "---"), relativeWidth = 0.29 },
								{ text = color .. L["Last 7 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(data.weekBuy) or "---"), relativeWidth = 0.29 }
							},
							relativeWidth = 1,
						},
						{
							type = "MultiLabel",
							labelInfo = {
								{ text = color2 .. L["Spent Per Day:"], relativeWidth = 0.19 },
								{ text = color .. L["Total:"] .. " |r" .. (TSMAPI:FormatTextMoney(floor(data.totalBuy / data.totalTime + 0.5)) or "---"), relativeWidth = 0.22 },
								{ text = color .. L["Last 30 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(floor(data.monthBuy / data.monthTime + 0.5)) or "---"), relativeWidth = 0.29 },
								{ text = color .. L["Last 7 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(floor(data.weekBuy / data.weekTime + 0.5)) or "---"), relativeWidth = 0.29 }
							},
							relativeWidth = 1,
						},
						{
							type = "Label",
							relativeWidth = 0.28,
							text = color2 .. L["Top Item by Gold / Quantity:"] .. "|r",
						},
						{
							type = "InteractiveLabel",
							text = topBuyGoldLink .. " (" .. (TSMAPI:FormatTextMoney(data.topBuyGold.price) or "---") .. ")",
							relativeWidth = 0.36,
							callback = function() SetItemRef("item:" .. data.topBuyGold.itemID, data.topBuyGold.itemID) end,
							tooltip = data.topBuyGold.itemID,
						},
						{
							type = "InteractiveLabel",
							text = topBuyQuantityLink .. " (" .. (data.topBuyQuantity.num or "---") .. ")",
							relativeWidth = 0.36,
							callback = function() SetItemRef("item:" .. data.topBuyQuantity.itemID, data.topBuyQuantity.itemID) end,
							tooltip = data.topBuyQuantity.itemID,
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "Flow",
					title = L["Expenses"],
					backdrop = true,
					children = {
						{
							type = "MultiLabel",
							labelInfo = {
								{ text = color2 .. L["Gold Spent:"], relativeWidth = 0.19 },
								{ text = color .. L["Total:"] .. " |r" .. (TSMAPI:FormatTextMoney(data.totalExpense) or "---"), relativeWidth = 0.22 },
								{ text = color .. L["Last 30 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(data.monthExpense) or "---"), relativeWidth = 0.29 },
								{ text = color .. L["Last 7 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(data.weekExpense) or "---"), relativeWidth = 0.29 }
							},
							relativeWidth = 1,
						},
						{
							type = "MultiLabel",
							labelInfo = {
								{ text = color2 .. L["Spent Per Day:"], relativeWidth = 0.19 },
								{ text = color .. L["Total:"] .. " |r" .. (TSMAPI:FormatTextMoney(floor(data.totalExpense / data.totalTime + 0.5)) or "---"), relativeWidth = 0.22 },
								{ text = color .. L["Last 30 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(floor(data.monthExpense / data.monthTime + 0.5)) or "---"), relativeWidth = 0.29 },
								{ text = color .. L["Last 7 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(floor(data.weekExpense / data.weekTime + 0.5)) or "---"), relativeWidth = 0.29 }
							},
							relativeWidth = 1,
						},
						{
							type = "Label",
							relativeWidth = 0.28,
							text = color2 .. L["Top Expense by Gold / Quantity:"] .. "|r",
						},
						{
							type = "Label",
							text = (data.topExpenseGold.type or L["none"]) .. " (" .. (TSMAPI:FormatTextMoney(data.topExpenseGold.amount) or "---") .. ")",
							relativeWidth = 0.36,
						},
						{
							type = "Label",
							text = (data.topExpenseQuantity.type or L["none"]) .. " (" .. (data.topExpenseQuantity.num or "---") .. ")",
							relativeWidth = 0.36,
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "Flow",
					title = L["Balance"],
					backdrop = true,
					children = {
						{
							type = "MultiLabel",
							labelInfo = {
								{ text = color2 .. L["Profit:"], relativeWidth = 0.19 },
								{ text = color .. L["Total:"] .. " |r" .. (TSMAPI:FormatTextMoney((data.totalSale + data.totalIncome) - (data.totalBuy + data.totalExpense)) or "---"), relativeWidth = 0.22 },
								{ text = color .. L["Last 30 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney((data.monthSale + data.monthIncome) - (data.monthBuy + data.monthExpense)) or "---"), relativeWidth = 0.29 },
								{ text = color .. L["Last 7 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney((data.weekSale + data.weekIncome) - (data.weekBuy + data.weekExpense)) or "---"), relativeWidth = 0.29 }
							},
							relativeWidth = 1,
						},
						{
							type = "MultiLabel",
							labelInfo = {
								{ text = color2 .. L["Profit Per Day:"], relativeWidth = 0.19 },
								{ text = color .. L["Total:"] .. " |r" .. (TSMAPI:FormatTextMoney(floor(((data.totalSale + data.totalIncome) - (data.totalBuy + data.totalExpense)) / data.totalTime + 0.5)) or "---"), relativeWidth = 0.22 },
								{ text = color .. L["Last 30 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(floor(((data.monthSale + data.monthIncome) - (data.monthBuy + data.monthExpense)) / data.monthTime + 0.5)) or "---"), relativeWidth = 0.29 },
								{ text = color .. L["Last 7 Days:"] .. " |r" .. (TSMAPI:FormatTextMoney(floor(((data.weekSale + data.weekIncome) - (data.weekBuy + data.weekExpense)) / data.weekTime + 0.5)) or "---"), relativeWidth = 0.29 }
							},
							relativeWidth = 1,
						},
					},
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end

local function GetGoldGraphPoints(goldLog)
	if not goldLog or #goldLog < 3 then return end
	local minY, maxY = math.huge, 0
	local minX, maxX = math.huge, 0
	local data = {}
	for _, info in ipairs(goldLog) do
		local x1, x2 = info.startMinute, info.endMinute
		local y = info.copper / COPPER_PER_GOLD / 1000
		minX = min(minX, x1)
		maxX = max(maxX, x2)
		minY = min(minY, floor(y))
		maxY = max(maxY, ceil(y))
		tinsert(data, {x1, y})
		tinsert(data, {x2, y})
	end
	return data, minX, maxX, minY, maxY
end
local function GetGoldGraphSumData()
	local currentMinute = floor(time() / 60)
	local players = {}
	local starts = {}
	for _, playerData in pairs(TSM.db.factionrealm.goldLog) do
		if #playerData > 2 then
			local data = CopyTable(playerData)
			for i=1, #data do
				if i > 1 then
					data[i].startMinute = data[i-1].endMinute+1
				end
				data[i].copper = TSM:Round(data[i].copper, COPPER_PER_GOLD*1000)
			end
			tinsert(players, data)
			tinsert(starts, data[1].startMinute)
		end
	end
	if #players == 0 then return end
	
	local indicies = {}
	local absStartMinute = min(unpack(starts))
	for i=1, #players do
		indicies[i] = 1
	end
	
	local temp = {}
	local staticCopper = 0
	for t=absStartMinute, currentMinute do
		local copper = staticCopper
		for i=#players, 1, -1 do
			if starts[i] <= t then
				local playerData = players[i]
				local index = indicies[i]
				while true do
					if index >= #playerData then
						index = #playerData
						tremove(players, i)
						staticCopper = staticCopper + playerData[index].copper
						copper = copper + playerData[index].copper
						break
					end
					if t > playerData[index].endMinute then
						-- move to the next datapoint for this player
						index = index + 1
					else
						-- we are in the range
						copper = copper + playerData[index].copper
						break
					end
				end
				indicies[i] = index
			end
		end
		local j = #temp+1
		if j > 1 and temp[j-1].copper == copper then
			temp[j-1].endMinute = t
		else
			tinsert(temp, {startMinute=t, endMinute=t, copper=copper})
		end
	end
	if #temp == 0 then return end
	return GetGoldGraphPoints(temp)
end
function GUI:DrawGoldGraph(container)
	TSM.db.factionrealm.goldGraphCharacter = TSM.db.factionrealm.goldGraphCharacter or UnitName("player")
	local player = TSM.db.factionrealm.goldGraphCharacter
	local data, minX, maxX, minY, maxY
	if player == "<ALL>" then
		data, minX, maxX, minY, maxY = GetGoldGraphSumData()
	else
		data, minX, maxX, minY, maxY = GetGoldGraphPoints(TSM.db.factionrealm.goldLog[player])
	end
	
	local dropdownList = {["<ALL>"]="Sum of All Characters"}
	for player in pairs(TSM.db.factionrealm.goldLog) do
		dropdownList[player] = player
	end
	
	if not data then
		local page = {
			{
				type = "SimpleGroup",
				layout = "Flow",
				children = {
					{
						type = "Label",
						text = L["Accounting has not yet collected enough information for this tab. This is likely due to not having recorded enough data points or not seeing any significant fluctuations (over 1k gold) in your gold on hand."],
						relativeWidth = 1,
					},
					{
						type = "Spacer",
					},
					{
						type = "Dropdown",
						label = "Character to Graph",
						settingInfo = {TSM.db.factionrealm, "goldGraphCharacter"},
						relativeWidth = 0.5,
						list = dropdownList,
						callback = function() container:ReloadTab() end,
						tooltip = "",
					},
				},
			},
		}
		TSMAPI:BuildPage(container, page)
		return
	end

	local startDate, endDate
	if TSM.db.factionrealm.timeFormat == "eudate" then
		startDate = date("%d/%m/%y %H:%M", minX * 60)
		endDate = date("%d/%m/%y %H:%M", maxX * 60)
	elseif TSM.db.factionrealm.timeFormat == "aidate" then
		startDate = date("%y/%m/%d %H:%M", minX * 60)
		endDate = date("%y/%m/%d %H:%M", maxX * 60)
	else
		startDate = date("%m/%d/%y %H:%M", minX * 60)
		endDate = date("%m/%d/%y %H:%M", maxX * 60)
	end

	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			children = {
				{
					type = "Label",
					text = format(L["Below is a graph of the your character's gold on hand over time.\n\nThe x-axis is time and goes from %s to %s\nThe y-axis is thousands of gold."], startDate, endDate),
					relativeWidth = 1,
				},
				{
					type = "Spacer",
				},
				{
					type = "Dropdown",
					label = L["Character to Graph"],
					settingInfo = {TSM.db.factionrealm, "goldGraphCharacter"},
					relativeWidth = 0.5,
					list = dropdownList,
					callback = function() container:ReloadTab() end,
				},
				{
					type = "HeadingLine"
				},
				{
					type = "ScrollFrame",
					fullHeight = true,
					layout = "flow"
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)

	local parent = container.children[1].children[#container.children[1].children].frame

	if not GUI.lineGraph then
		local graph = LibStub("LibGraph-2.0"):CreateGraphLine(nil, parent, "CENTER", nil, nil, nil, parent:GetWidth(), parent:GetHeight())
		graph:SetGridColor({ 0.8, 0.8, 0.8, 0.6 })
		graph:SetYLabels(true)
		GUI.lineGraph = graph
	end
	GUI.lineGraph:Show()
	GUI.lineGraph:SetParent(parent)
	GUI.lineGraph:ClearAllPoints()
	GUI.lineGraph:SetAllPoints(parent)

	GUI.lineGraph:ResetData()
	local ySpacing = max(ceil((maxY - minY) / 20), 0.5)
	GUI.lineGraph:SetGridSpacing(nil, ySpacing)
	local xBuffer = (maxX-minX)*0.05
	local yBuffer = (maxY-minY)*0.03
	GUI.lineGraph:SetXAxis(minX-xBuffer, maxX)
	GUI.lineGraph:SetYAxis(minY-yBuffer, maxY+yBuffer)
	GUI.lineGraph:AddDataSeries(data, {1, 0.83, 0, 1})
	GUI.lineGraph:RefreshGraph()
end

function GUI:DrawOptions(container)
	local mvSources = TSMAPI:GetPriceSources()
	local daysOld = 45

	local page = {
		{
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					title = L["General Options"],
					layout = "Flow",
					children = {
						{
							type = "Dropdown",
							label = L["Time Format"],
							settingInfo = {TSM.db.factionrealm, "timeFormat"},
							relativeWidth = 0.5,
							list = { ["ago"] = L["_ Hr _ Min ago"], ["usdate"] = L["MM/DD/YY HH:MM"], ["aidate"] = L["YY/MM/DD HH:MM"], ["eudate"] = L["DD/MM/YY HH:MM"] },
							tooltip = L["Select what format Accounting should use to display times in applicable screens."],
						},
						{
							type = "Dropdown",
							label = L["Market Value Source"],
							settingInfo = {TSM.db.factionrealm, "mvSource"},
							relativeWidth = 0.49,
							list = mvSources,
							tooltip = L["Select where you want Accounting to get market value info from to show in applicable screens."],
						},
						{
							type = "Dropdown",
							label = "Items/Resale Price Format",
							settingInfo = {TSM.db.factionrealm, "priceFormat"},
							relativeWidth = 0.49,
							list = { ["avg"] = L["Price Per Item"], ["total"] = L["Total Value"] },
							tooltip = L["Select how you would like prices to be shown in the \"Items\" and \"Resale\" tabs; either average price per item or total value."],
						},
						{
							type = "Label",
							relativeWidth = .49
						},
						{
							type = "CheckBox",
							label = L["Track sales/purchases via trade"],
							settingInfo = { TSM.db.factionrealm, "trackTrades" },
							callback = function() container:ReloadTab() end,
							tooltip = L["If checked, whenever you buy or sell any quantity of a single item via trade, Accounting will display a popup asking if you want it to record that transaction."],
						},
						{
							type = "CheckBox",
							label = L["Don't prompt to record trades"],
							settingInfo = { TSM.db.factionrealm, "autoTrackTrades" },
							disabled = not TSM.db.factionrealm.trackTrades,
							tooltip = L["If checked, you won't get a popup confirmation about whether or not to track trades."],
						},
						{
							type = "CheckBox",
							label = L["Display Grey Items in Sales"],
							settingInfo = { TSM.db.factionrealm, "displayGreys" },
							tooltip = L["If checked, poor quality items will be shown in sales data. They will still be included in gold earned totals on the summary tab regardless of this setting"],
						},
						{
							type = "CheckBox",
							label = L["Display Money Transfers in Income/Expense/Summary"],
							settingInfo = { TSM.db.factionrealm, "displayTransfers" },
							tooltip = L["If checked, Money Transfers will be included in income / expense and summary. Accounting will still track these if disabled but will not show them."],
						},
						{
							type = "CheckBox",
							label = L["Use smart average for purchase price"],
							settingInfo = { TSM.db.factionrealm, "smartBuyPrice" },
							tooltip = L["If checked, the average purchase price that shows in the tooltip will be the average price for the most recent X you have purchased, where X is the number you have in your bags / bank / gbank using data from the ItemTracker module. Otherwise, a simple average of all purchases will be used."],
						},
					},
				},
				{
					type = "InlineGroup",
					title = L["Clear Old Data"],
					layout = "Flow",
					children = {
						{
							type = "Label",
							text = L["You can use the options below to clear old data. It is recommened to occasionally clear your old data to keep Accounting running smoothly. Select the minimum number of days old to be removed in the dropdown, then click the button.\n\nNOTE: There is no confirmation."],
							relativeWidth = 1,
						},
						{
							type = "HeadingLine",
						},
						{
							type = "Dropdown",
							label = L["Days:"],
							relativeWidth = 0.4,
							list = { "30", "45", "60", "75", "90" },
							value = 2,
							callback = function(_, _, value) daysOld = (tonumber(value) + 1) * 15 end,
							tooltip = L["Data older than this many days will be deleted when you click on the button to the right."],
						},
						{
							type = "Button",
							text = L["Remove Old Data (No Confirmation)"],
							relativeWidth = 0.59,
							callback = function() TSM.Data:RemoveOldData(daysOld) end,
							tooltip = L["Click this button to permanently remove data older than the number of days selected in the dropdown."],
						},
					},
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end

function GUI:LoadTooltipOptions(container)
	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			fullHeight = true,
			children = {
				{
					type = "CheckBox",
					label = L["Show sale info in item tooltips"],
					settingInfo = { TSM.db.factionrealm.tooltip, "sale" },
					tooltip = L["If checked, the number you have sold and the average sale price will show up in an item's tooltip."],
				},
				{
					type = "CheckBox",
					label = L["Show Expired Auctions as Failed Auctions since Last Sale in item tooltips"],
					settingInfo = { TSM.db.factionrealm, "expiredAuctions" },
					relativeWidth = 1,
					tooltip = L["If checked, the number of expired auctions since the last sale will show as up as failed auctions in an item's tooltip. if no sales then the total number of expired auctions will be shown."],
				},
				{
					type = "CheckBox",
					label = L["Show Cancelled Auctions as Failed Auctions since Last Sale in item tooltips"],
					settingInfo = { TSM.db.factionrealm, "cancelledAuctions" },
					relativeWidth = 1,
					tooltip = L["If checked, the number of cancelled auctions since the last sale will show as up as failed auctions in an item's tooltip. if no sales then the total number of cancelled auctions will be shown."],
				},
				{
					type = "CheckBox",
					label = L["Show Sale Rate in item tooltips"],
					settingInfo = { TSM.db.factionrealm, "saleRate" },
					relativeWidth = 1,
					tooltip = L["If checked, the sale rate will be shown in item tooltips. sale rate is calculated as total sold / (total sold + total expired + total cancelled)."],
				},
				{
					type = "CheckBox",
					label = L["Show purchase info in item tooltips"],
					settingInfo = { TSM.db.factionrealm.tooltip, "purchase" },
					tooltip = L["If checked, the number you have purchased and the average purchase price will show up in an item's tooltip."],
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end

function GUI:HideScrollingTables()
	for _, st in pairs(scrollingTables) do
		st:Hide()
		st:SetData({})
	end
end

function GUI:CreateTopWidgetsPlayer(container, stName, dataFunc)
	local rarityList = {}
	for i = 1, 4 do
		rarityList[tostring(i)] = _G[format("ITEM_QUALITY%d_DESC", i)]
	end
	rarityList["none"] = L["None"]
	local ddpList = { ["all"] = L["All"] }
	local filter, rarity, ddpSelection, group

	if TSM.Data.playerDataCache then
		for _, player in pairs(TSM.Data.playerDataCache) do
			ddpList[player] = player
		end
	end

	local function UpdateFilter()
		local rarityFilterFunction = function(link) return (not rarity or rarity == "none") or (link and (select(3, GetItemInfo(link)) or 0) == tonumber(rarity)) end

		local searchFilterFunction = defaultFilterFunc
		if filter and filter ~= "" then
			searchFilterFunction = function(name) return strfind(strlower(name or ""), filter) end
		end

		local updatePlayerFilter = function(player)
			return not player or not ddpSelection or ddpSelection == "all" or ddpSelection == player
		end
		
		local groupFilterFunction = defaultFilterFunc
		if group then
			groupFilterFunction = function(link)
				local itemString = TSMAPI:GetItemString(link) or link
				if not itemString then return end
				local groupPath = TSMAPI:GetGroupPath(itemString)
				return groupPath and strfind(groupPath, "^"..TSMAPI:StrEscape(group))
			end
		end

		local st
		if type(stName) == "string" then
			st = scrollingTables[stName]
		else
			st = stName
		end
		st:SetData(dataFunc(function(name, link, player) return groupFilterFunction(link) and searchFilterFunction(name) and rarityFilterFunction(link) and updatePlayerFilter(player) end))
	end

	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			children = {
				{
					type = "EditBox",
					label = L["Search"],
					relativeWidth = 0.24,
					onTextChanged = true,
					callback = function(_, _, value)
						filter = strlower(value:trim())
						UpdateFilter()
					end,
				},
				{
					type = "GroupBox",
					label = L["Group"],
					relativeWidth = 0.25,
					callback = function(_, _, value)
						group = value
						UpdateFilter()
					end,
				},
				{
					type = "Dropdown",
					label = L["Rarity"],
					relativeWidth = 0.25,
					list = rarityList,
					value = "none",
					callback = function(_, _, key)
						rarity = key
						UpdateFilter()
					end,
				},
				{
					type = "Dropdown",
					label = L["Player(s)"],
					relativeWidth = 0.25,
					list = ddpList,
					value = "all",
					callback = function(_, _, value)
						ddpSelection = value
						UpdateFilter()
					end,
				},
				{
					type = "ScrollFrame",
					fullHeight = true,
					layout = "flow"
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end

function GUI:CreateTopWidgetsAuctions(container, stName, dataFunc)
	local ddpList = { ["all"] = L["All"] }
	local filter, ddpSelection, group

	if TSM.Data.playerDataCache then
		for _, player in pairs(TSM.Data.playerDataCache) do
			ddpList[player] = player
		end
	end

	local function UpdateFilter()
		local searchFilterFunction = defaultFilterFunc
		if filter and filter ~= "" then
			searchFilterFunction = function(name) return strfind(strlower(name or ""), filter) end
		end

		local updatePlayerFilter = function(player)
			return not player or not ddpSelection or ddpSelection == "all" or ddpSelection == player
		end
		
		local groupFilterFunction = defaultFilterFunc
		if group then
			groupFilterFunction = function(itemString)
				if not itemString then return end
				local groupPath = TSMAPI:GetGroupPath(itemString)
				return groupPath and strfind(groupPath, "^"..TSMAPI:StrEscape(group))
			end
		end

		local st
		if type(stName) == "string" then
			st = scrollingTables[stName]
		else
			st = stName
		end
		st:SetData(dataFunc(function(name, itemString, player) return groupFilterFunction(itemString) and searchFilterFunction(name) and updatePlayerFilter(player) end))
	end

	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			children = {
				{
					type = "EditBox",
					label = L["Search"],
					relativeWidth = 0.34,
					onTextChanged = true,
					callback = function(_, _, value)
						filter = strlower(value:trim())
						UpdateFilter()
					end,
				},
				{
					type = "GroupBox",
					label = L["Group"],
					relativeWidth = 0.35,
					callback = function(_, _, value)
						group = value
						UpdateFilter()
					end,
				},
				{
					type = "Dropdown",
					label = L["Player(s)"],
					relativeWidth = 0.30,
					list = ddpList,
					value = "all",
					callback = function(_, _, value)
						ddpSelection = value
						UpdateFilter()
					end,
				},
				{
					type = "ScrollFrame",
					fullHeight = true,
					layout = "flow"
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end

function GUI:CreateTopWidgets(container, stName, dataFunc)
	local rarityList = {}
	for i = 1, 4 do
		rarityList[tostring(i)] = _G[format("ITEM_QUALITY%d_DESC", i)]
	end
	rarityList["none"] = L["None"]
	local filter, rarity, group

	local function UpdateFilter()
		local rarityFilterFunction = function(link) return (not rarity or rarity == "none") or (link and (select(3, GetItemInfo(link)) or 0) == tonumber(rarity)) end

		local searchFilterFunction = defaultFilterFunc
		if filter and filter ~= "" then
			searchFilterFunction = function(name) return strfind(strlower(name or ""), filter) end
		end
		
		local groupFilterFunction = defaultFilterFunc
		if group then
			groupFilterFunction = function(link)
				local itemString = TSMAPI:GetItemString(link) or link
				if not itemString then return end
				local groupPath = TSMAPI:GetGroupPath(itemString)
				return groupPath and strfind(groupPath, "^"..TSMAPI:StrEscape(group))
			end
		end

		local st
		if type(stName) == "string" then
			st = scrollingTables[stName]
		else
			st = stName
		end

		st:SetData(dataFunc(function(name, link) return groupFilterFunction(link) and searchFilterFunction(name) and rarityFilterFunction(link) end))
	end

	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			children = {
				{
					type = "EditBox",
					label = L["Search"],
					relativeWidth = 0.34,
					onTextChanged = true,
					callback = function(_, _, value)
						filter = strlower(value:trim())
						UpdateFilter()
					end,
				},
				{
					type = "GroupBox",
					label = L["Group"],
					relativeWidth = 0.35,
					callback = function(_, _, value)
						group = value
						UpdateFilter()
					end,
				},
				{
					type = "Dropdown",
					label = L["Rarity"],
					relativeWidth = 0.30,
					list = rarityList,
					value = "none",
					callback = function(_, _, key)
						rarity = key
						UpdateFilter()
					end,
				},
				{
					type = "SimpleGroup",
					fullHeight = true,
					layout = "flow"
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end

function GUI:CreateTopWidgetsItem(container, stName, dataFunc)
	local rarityList = {}
	for i = 1, 4 do
		rarityList[tostring(i)] = _G[format("ITEM_QUALITY%d_DESC", i)]
	end
	rarityList["none"] = L["None"]
	local timeList = { [99] = L["All"], [0] = L["Today"], [1] = L["Yesterday"], [7] = L["Last 7 Days"], [14] = L["Last 14 Days"], [30] = L["Last 30 Days"], [60] = L["Last 60 Days"] }
	local filter, group, timeSelection

	local function UpdateFilter()
		local rarityFilterFunction = function(link) return (not rarity or rarity == "none") or (link and (select(3, GetItemInfo(link)) or 0) == tonumber(rarity)) end

		local searchFilterFunction = defaultFilterFunc
		if filter and filter ~= "" then
			searchFilterFunction = function(name) return strfind(strlower(name or ""), filter) end
		end

		local timeFilterFunction = defaultFilterFunc
		local SECONDS_PER_DAY = 24 * 60 * 60
		if timeSelection and timeSelection ~= 99 then
			if timeSelection == 0 then -- today
				timeFilterFunction = function(rTime) return date("%x", rTime) == date("%x") end
			elseif timeSelection == 1 then -- yesterday
				local yesterday = time() - 86400
				timeFilterFunction = function(rTime) return date("%x", rTime) == date("%x", yesterday) end
			else
				timeFilterFunction = function(rTime) return (time() - rTime) < (SECONDS_PER_DAY * tonumber(timeSelection)) end
			end
		end
		
		local groupFilterFunction = defaultFilterFunc
		if group then
			groupFilterFunction = function(link)
				local itemString = TSMAPI:GetItemString(link) or link
				if not itemString then return end
				local groupPath = TSMAPI:GetGroupPath(itemString)
				return groupPath and strfind(groupPath, "^"..TSMAPI:StrEscape(group))
			end
		end

		local st
		if type(stName) == "string" then
			st = scrollingTables[stName]
		else
			st = stName
		end

		st:SetData(dataFunc(function(name, link, rTime) return groupFilterFunction(link) and searchFilterFunction(name) and rarityFilterFunction(link) and timeFilterFunction(rTime) end))
	end

	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			children = {
				{
					type = "EditBox",
					label = L["Search"],
					relativeWidth = 0.24,
					onTextChanged = true,
					callback = function(_, _, value)
						filter = strlower(value:trim())
						UpdateFilter()
					end,
				},
				{
					type = "GroupBox",
					label = L["Group"],
					relativeWidth = 0.25,
					callback = function(_, _, value)
						group = value
						UpdateFilter()
					end,
				},
				{
					type = "Dropdown",
					label = L["Rarity"],
					relativeWidth = 0.25,
					list = rarityList,
					value = "none",
					callback = function(_, _, key)
						rarity = key
						UpdateFilter()
					end,
				},
				{
					type = "Dropdown",
					label = L["Timeframe Filter"],
					relativeWidth = 0.25,
					list = timeList,
					value = 99,
					callback = function(_, _, value)
						timeSelection = value
						UpdateFilter()
					end,
				},
				{
					type = "SimpleGroup",
					fullHeight = true,
					layout = "flow"
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end

function GUI:CreateTopWidgetsMoney(container, stName, dataFunc)
	local ddtList = { ["all"] = L["All"] }
	local ddpList = { ["all"] = L["All"] }
	local filter, ddtSelection, ddpSelection

	if TSM.Data.playerDataCache then
		for _, player in pairs(TSM.Data.playerDataCache) do
			ddpList[player] = player
		end
	end

	for type, _ in pairs(TSM.Data.money) do
		ddtList[type] = type
	end

	local function UpdateFilter()
		local updateTypeFilter = function(type)
			return not type or not ddtSelection or ddtSelection == "all" or ddtSelection == type
		end

		local updatePlayerFilter = function(player)
			return not player or not ddpSelection or ddpSelection == "all" or ddpSelection == player
		end

		local st
		if type(stName) == "string" then
			st = scrollingTables[stName]
		else
			st = stName
		end
		st:SetData(dataFunc(function(type, player) return updateTypeFilter(type) and updatePlayerFilter(player) end))
	end

	local page = {
		{
			type = "SimpleGroup",
			layout = "Flow",
			children = {
				{
					type = "Dropdown",
					label = L["Type"],
					relativeWidth = 0.29,
					list = ddtList,
					value = "none",
					callback = function(_, _, value)
						ddtSelection = value
						UpdateFilter()
					end,
				},
				{
					type = "GroupBox",
					label = L["Group"],
					relativeWidth = 0.35,
					callback = function(_, _, value)
						group = value
						UpdateFilter()
					end,
				},
				{
					type = "Dropdown",
					label = L["Player(s)"],
					relativeWidth = 0.30,
					list = ddpList,
					value = "all",
					callback = function(_, _, value)
						ddpSelection = value
						UpdateFilter()
					end,
				},
				{
					type = "ScrollFrame",
					fullHeight = true,
					layout = "flow"
				},
			},
		},
	}

	TSMAPI:BuildPage(container, page)
end