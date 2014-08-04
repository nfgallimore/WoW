-- enUS localization file for HideInCombat

-- This is the default locale.

if GetLocale() then
	local L = HideInCombat.Locals

	L.CONFIG_ENABLED = "Enabled"
	L.CONFIG_HIDE_IN_SOLO = "Hide frames in Solo"
	L.CONFIG_HIDE_IN_PARTY = "Hide frames in Party"
	L.CONFIG_HIDE_IN_RAID = "Hide frames in Raid"
	L.CONFIG_HIDE_CHATWINDOW = "Hide Chat frame"
	L.CONFIG_HIDE_TOOLTIP = "Hide Tooltip frame"
	L.CONFIG_HIDE_MINIMAP = "Hide Minimap frame"
	L.CONFIG_ANNOUNCE = "Announce activation"
	L.CONFIG_ANNOUNCEMENT_ON = "HideInCombat hides my chat! I'll NOT read chat while in combat!"
	L.CONFIG_ANNOUNCEMENT_OFF = "My chat frame is visible once again!"
end