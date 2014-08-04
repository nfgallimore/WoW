
SexyMap2DB = {
	["Darkrizen-Tichondrius"] = {
		["ping"] = {
			["showPing"] = true,
			["showAt"] = "map",
		},
		["coordinates"] = {
			["enabled"] = false,
			["fontColor"] = {
			},
			["borderColor"] = {
			},
			["locked"] = false,
			["backgroundColor"] = {
			},
		},
		["buttons"] = {
			["radius"] = 10,
			["lockDragging"] = false,
			["allowDragging"] = true,
			["visibilitySettings"] = {
				["MinimapZoomIn"] = "never",
				["MinimapZoneTextButton"] = "always",
				["TimeManagerClockButton"] = "always",
				["MiniMapMailFrame"] = "always",
				["MinimapZoomOut"] = "never",
				["MiniMapWorldMapButton"] = "never",
			},
			["dragPositions"] = {
				["MiniMapTracking"] = 149.3886175653299,
				["MiniMapRecordingButton"] = 181.4320781445433,
				["QueueStatusMinimapButton"] = 197.9164482426081,
				["OQ_MinimapButton"] = 232.5238519613555,
			},
			["controlVisibility"] = true,
		},
		["hudmap"] = {
			["scale"] = 1.4,
			["textColor"] = {
				["a"] = 1,
				["b"] = 0.5,
				["g"] = 1,
				["r"] = 0.5,
			},
			["alpha"] = 0.7,
			["hudColor"] = {
			},
		},
		["zonetext"] = {
			["bgColor"] = {
				["a"] = 1,
				["b"] = 0,
				["g"] = 0,
				["r"] = 0,
			},
			["fontColor"] = {
			},
			["borderColor"] = {
				["a"] = 1,
				["b"] = 0,
				["g"] = 0,
				["r"] = 0,
			},
			["xOffset"] = 0,
			["yOffset"] = 0,
		},
		["clock"] = {
			["bgColor"] = {
				["a"] = 1,
				["b"] = 0,
				["g"] = 0,
				["r"] = 0,
			},
			["fontColor"] = {
			},
			["borderColor"] = {
				["a"] = 1,
				["b"] = 0,
				["g"] = 0,
				["r"] = 0,
			},
			["xOffset"] = 0,
			["yOffset"] = 0,
		},
		["borders"] = {
			["applyPreset"] = false,
			["borders"] = {
				{
					["rotation"] = 225,
					["name"] = "Ring",
					["texture"] = "INTERFACE\\ADDONS\\SEXYMAP\\MEDIA\\MAP_OVERLAY.TGA",
					["height"] = 182,
					["blendMode"] = "BLEND",
					["scale"] = 1.45,
					["width"] = 364,
				}, -- [1]
				{
					["disableRotation"] = true,
					["name"] = "Gloss",
					["r"] = 0.9,
					["scale"] = 0.84,
					["g"] = 0.95,
					["texture"] = "INTERFACE\\ADDONS\\SEXYMAP\\MEDIA\\MAP_GLOSS.TGA",
				}, -- [2]
				{
					["b"] = 0,
					["scale"] = 0.84,
					["g"] = 0,
					["drawLayer"] = "OVERLAY",
					["name"] = "Inner Shadow",
					["r"] = 0,
					["disableRotation"] = true,
					["blendMode"] = "BLEND",
					["texture"] = "INTERFACE\\ADDONS\\SEXYMAP\\MEDIA\\MAP_INNERSHADOW.TGA",
				}, -- [3]
				{
					["a"] = 0.95,
					["rotSpeed"] = 60,
					["r"] = 0.18823529411765,
					["scale"] = 1.37,
					["g"] = 0.17254901960784,
					["drawLayer"] = "BACKGROUND",
					["name"] = "Cogwheel",
					["b"] = 0.13725490196078,
					["blendMode"] = "BLEND",
					["texture"] = "INTERFACE\\ADDONS\\SEXYMAP\\MEDIA\\ZAHNRAD.TGA",
				}, -- [4]
			},
			["backdrop"] = {
				["show"] = false,
				["textureColor"] = {
				},
				["settings"] = {
					["bgFile"] = "Interface\\Tooltips\\UI-Tooltip-Background",
					["edgeFile"] = "Interface\\Tooltips\\UI-Tooltip-Border",
					["tile"] = false,
					["edgeSize"] = 16,
					["insets"] = {
						["top"] = 4,
						["right"] = 4,
						["left"] = 4,
						["bottom"] = 4,
					},
				},
				["borderColor"] = {
				},
				["scale"] = 1,
			},
			["hideBlizzard"] = true,
		},
		["core"] = {
			["clamp"] = true,
			["lock"] = false,
			["northTag"] = true,
			["shape"] = "Interface\\AddOns\\SexyMap\\shapes\\circle.tga",
			["autoZoom"] = 5,
			["rightClickToConfig"] = true,
		},
		["movers"] = {
			["enabled"] = false,
			["framePositions"] = {
			},
			["lock"] = false,
		},
	},
	["presets"] = {
	},
}
