--[[
	Copyright (C) 2006-2007 Nymbia
	Copyright (C) 2010 Hendrik "Nevcairiel" Leppkes < h.leppkes@gmail.com >
	Copyright (C) 2012-2013 Katharina

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program; if not, write to the Free Software Foundation, Inc.,
	51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
]]
local Quartz3 = LibStub("AceAddon-3.0"):GetAddon("Quartz3")
local L = LibStub("AceLocale-3.0"):GetLocale("Quartz3")
local media = LibStub("LibSharedMedia-3.0")

local MODNAME = "Power"
local powertype = 1
local powertype2 = 0
local Power = Quartz3:NewModule(MODNAME, "AceEvent-3.0")
local primebox, powerbar
local showstatus = 1


----------------------------
-- Upvalues
-- GLOBALS: PowerBarFrame

local db,db2, getOptions

local defaults = {
	profile = Quartz3:Merge(Quartz3.CastBarTemplate.defaults,
	{
		hideblizz = true,
		
		--x =  -- applied automatically in :ApplySettings()
		y = 300,
		h = 18,
		w = 200,
		texture = "LiteStep",
		powercolor = {1, 0.7, 0},
		barcolor = {1, 0.7, 0},


		
	})

	--if select( 2, UnitClass( "player" ) )== "MONK" then
	--powercolor = {0, 0.7, 0.5}
	--end
	--if select( 2, UnitClass( "player" ) )== "ROGUE" then
	--powercolor = unpack({0, 0.8, 0}
	--end
}

do
	local function setOpt(info, value)
		db[info[#info]] = value
		Power:ApplySettings()
	end

	local function getColor(info)
		return unpack(getOpt(info))
	end

	local function setColor(info, r, g, b, a)
		setOpt(info, {r, g, b, a})
	end

	local function getOpt(info)
		return db[info[#info]]
	end

	local options
	function getOptions()
		if not options then
			options = Power.Bar:CreateOptions()

			--options.args.hideblizz = {
			--	type = "toggle",
			--	name = L["Disable Blizzard Cast Bar"],
			--	desc = L["Disable and hide the default UI's casting bar"],
			--	set = setOpt,
			--	order = 101,
			--}

			options.args.showtarget = {
				type = "toggle",
				name = "Show Primary Power",
				desc = "Show this castbar, if Primary Power should be shown too.",
				order = 101,
			}
			options.args.showcombat = {
				type = "toggle",
				name = "Show out of Combat",
				desc = "Show this castbar out of combat?",
				order = 102,
			}
			options.args.switch = {
				type = "toggle",
				name = "Switch bars",
				desc = "This switches the primary with the secondary bar. Requires Reload!",
				order = 103,
			}
			options.args.barcolor = {
				type = "color",
				name = "Power Color",
				desc = "Set the color of your power bar! Requires Reload!",
				set = function(info, ...)
					db.barcolor = {...}
				end,
				get = function()
					return unpack(db.barcolor)
				end,
				order = 104,
			}
			options.args.powercolor = {
				type = "color",
				name = "Secondary Power Color",
				desc = "Set the color of your secondary power bar! Requires Reload!",
				set = function(info, ...)
					db.powercolor = {...}

				end,
				get = function()
					return unpack(db.powercolor)
				end,
				order = 105,
			}
			options.args.noInterruptGroup = nil
		end
		return options
	end
end



function Power:OnInitialize()
	self.db = Quartz3.db:RegisterNamespace(MODNAME, defaults)
	db = self.db.profile

	self:SetEnabledState(Quartz3:GetModuleEnabled(MODNAME))
	Quartz3:RegisterModuleOptions(MODNAME, getOptions, "Power")

	self.Bar = Quartz3.CastBarTemplate:new(self, "player", MODNAME, "Power", db)
	
	powerbar = self.Bar.Bar

	self.Bar.Bar.primebox=self.Bar.Bar:CreateTexture(nil, "BACKGROUND")
	self.Bar.Bar.primebox:SetTexture(media:Fetch("statusbar", db.texture))

end

function Power:OnEnable()
	--self.Bar:RegisterEvents()
	self:RegisterEvent("UNIT_POWER","UnitPowerUpdate")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED","SpecChange")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "BarShow")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "BarHide")

	self.Bar:SetConfig(db)
	self:ApplySettings()
	

end

function Power:BarHide()
showstatus = 0 
end

function Power:BarShow()
showstatus = 1
end


function Power:OnDisable()
	self.Bar:UnregisterEvents()
	self.Bar:Hide()
end

function Power:ApplySettings()
	db = self.db.profile

	self.Bar.Bar:SetStatusBarTexture(media:Fetch("statusbar", db.texture))

	self.Bar:SetConfig(db)
	if self:IsEnabled() then
		self.Bar:ApplySettings()
	end

	self:SpecChange()

	

	self.Bar.Bar:SetStatusBarTexture(media:Fetch("statusbar", db.texture))
	self.Bar.Bar:SetStatusBarColor(unpack(db.powercolor))


	local side = "LEFT"

	self.Bar.Bar.primebox:SetDrawLayer(side == "LEFT" and "OVERLAY" or "BACKGROUND")
	self.Bar.Bar.primebox:SetPoint(side, self.Bar.Bar, 0, db.h/2+4) 
	self.Bar.Bar.primebox:SetWidth(200)
	self.Bar.Bar.primebox:SetHeight(db.h/2)
	self.Bar.Bar.primebox:SetVertexColor(unpack(db.barcolor))
	self.Bar.Bar.primebox:SetAlpha(0.6)

	





end

local function OnShow(frame)
	frame:SetScript("OnUpdate", OnUpdate)
end

local function OnHide(frame)
	frame:SetScript("OnUpdate", nil)
end




function Power:UnitPowerUpdate(event, unit, spell)
	
	local maxpower = 1
	local maxpower2 = 1
	local powers = 0
	local perc =0 
	local powers2 = 0 




	if powertype==-1  then

	maxpower = 5
	powers = GetComboPoints("player", "target")	
	powers2 = UnitPower( "player", 3)
	maxpower2 = UnitPowerMax("player", 3)

	elseif powertype==-2 then

	maxpower = UnitPowerMax("player", powertype2)
	powers = UnitPower( "player", powertype2 )
	powers2 = 0
	maxpower2 = 1
	self.Bar.Bar.primebox:SetAlpha(0.0)

	elseif powertype==-3 then

	maxpower2 = UnitPowerMax("player", powertype2)
	powers2 = UnitPower( "player", powertype2 )
	local VENG_NAME = (GetSpellInfo(93098))
	local pHealth = UnitHealthMax("player")*0.25
	local n,_,_,_,_,dur,expi,_,_,_,id,_,_,_,val1,val2,val3 = UnitAura("player", VENG_NAME, nil, "HELPFUL")
	local vengval
	vengval = val1 or 0
	powers = vengval      --define vengeance here
	maxpower = pHealth
	if powers> maxpower then maxpower = powers end
	--self.Bar.Bar.primebox:SetAlpha(0.0)

	elseif powertype == -4 then

	-- pala inqui
	local VENG_NAME = (GetSpellInfo(84963))
	local n,_,_,_,_,dur,expi,_,_,_,id,_,_,_,val1,val2,val3 = UnitAura("player", VENG_NAME, nil, "HELPFUL")
	maxpower2 =  60
	if expi== nil then expi= 0. end
	powers2 = expi-GetTime()
	if powers2 > 60 then powers2 = 59 end

	maxpower = UnitPowerMax("player", powertype2)
	powers = UnitPower( "player", powertype2)
	if maxpower2==powers2 then self.Bar.Bar.primebox:SetAlpha(0.0) else self.Bar.Bar.primebox:SetAlpha(0.6) end


	elseif powertype == -5 then

	-- DK dark infusion
	local VENG_NAME = (GetSpellInfo(91342))
	local n,_,_,cnt,_,dur,expi,_,_,_,id,_,_,_,val1,val2,val3 = UnitAura("player", VENG_NAME, nil, "HELPFUL")
	maxpower2 =  5
	if cnt == nil then cnt = 0.1 end
	powers2 = cnt
	if powers2 > 5 then powers2 = 5 end

	maxpower = UnitPowerMax("player", powertype2)
	powers = UnitPower( "player", powertype2)
	if maxpower2==powers2 then self.Bar.Bar.primebox:SetAlpha(0.0) else self.Bar.Bar.primebox:SetAlpha(0.6) end

	else  

	if powertype2 >-1 then

	maxpower = UnitPowerMax("player", powertype)
	powers = UnitPower( "player", powertype )
	powers2 = UnitPower( "player", powertype2)
	maxpower2 = UnitPowerMax("player", powertype2)
	if maxpower2==powers2 then self.Bar.Bar.primebox:SetAlpha(0.0) else self.Bar.Bar.primebox:SetAlpha(0.6) end

	elseif powertype2 ==-3 then

	maxpower = UnitPowerMax("player", powertype)
	powers = UnitPower( "player", powertype)

	local VENG_NAME = (GetSpellInfo(93098))
	local pHealth = UnitHealthMax("player")*0.25
	local n,_,_,_,_,dur,expi,_,_,_,id,_,_,_,val1,val2,val3 = UnitAura("player", VENG_NAME, nil, "HELPFUL")
	if val1 == nil then val1 = 1 end
	powers2 = val1    --define vengeance here
	maxpower2 = pHealth
	if powers2 > maxpower2 then maxpower2 = powers2 end
	--self.Bar.Bar.primebox:SetAlpha(0.0)

	elseif powertype2 == -4 then

	-- pala inquif
	local VENG_NAME = (GetSpellInfo(84963))
	local n,_,_,_,_,dur,expi,_,_,_,id,_,_,_,val1,val2,val3 = UnitAura("player", VENG_NAME, nil, "HELPFUL")

	maxpower =  60
	if expi== nil then expi= 0 end
	powers = expi-GetTime()
	if powers > 60 then powers = 59 end	
	
	maxpower2 = UnitPowerMax("player", powertype)
	powers2 = UnitPower( "player", powertype )

	elseif powertype2 == -5 then

	-- DK dark infusion
	local VENG_NAME = (GetSpellInfo(91342))
	local n,_,_,cnt,_,dur,expi,_,_,_,id,_,_,_,val1,val2,val3 = UnitAura("player", VENG_NAME, nil, "HELPFUL")
	maxpower =  5
	if cnt== nil then cnt= 0 end
	powers = cnt
	if powers > 5 then powers = 5 end

	maxpower2 = UnitPowerMax("player", powertype)
	powers2 = UnitPower( "player", powertype)
	if maxpower2==powers2 then self.Bar.Bar.primebox:SetAlpha(0.0) else self.Bar.Bar.primebox:SetAlpha(0.6) end


	elseif powertype2 ==-1  then

	maxpower2 = 5
	powers2 = GetComboPoints("player", "target")	
	powers = UnitPower( "player", 3)
	maxpower = UnitPowerMax("player", 3)

	elseif powertype2 ==-2 then

	maxpower2 = UnitPowerMax("player", powertype2)
	powers2 = UnitPower( "player", powertype2 )
	powers = 0
	maxpower = 1
	--self.Bar.Bar.primebox:SetAlpha(0.0)

	end


	
	end
	
	perc = self.Bar.Bar:GetWidth()*powers2/maxpower2
	
	self.Bar.Bar:SetMinMaxValues(0,maxpower)
	self.Bar.Bar:SetValue(powers)
	
	self.Bar.TimeText:SetText(strjoin("/",powers,maxpower))
	self.Bar.Bar.primebox:SetWidth(perc)
	self.Bar.Bar.primebox:Show() 

	self.Bar:Unlock() 
	self.Bar.Icon:SetTexture(nil)
	self.Bar.Bar:Show()
	self.Bar:EnableMouse(false)
	self.Bar.Text:SetText("")

	if db.showcombat==false then 
	if showstatus==0 then self.Bar:Lock() end
	end	

	if db.showtarget==false then self.Bar.Bar.primebox:Hide() end
	



	
end

function Power:Unlock()
	self.Bar:Unlock()
end

function Power:Lock()
	self.Bar:Lock()
end



function Power:SpecChange()

local spec, name, description, icon, background, role

if (UnitLevel("player")>9) then

spec, name, description, icon, background, role = GetSpecializationInfo(GetSpecialization())

else 
spec=267
end

	--warlock
			 if spec == 267 then powertype = 14 powertype2 = 0 end
		         if spec == 265 then powertype =  7 powertype2 = 0 end
		         if spec == 266 then powertype =  15 powertype2 = 0 end

		--priest
			 if spec == 256 then powertype = -2 powertype2 = 0 end
		         if spec == 257 then powertype = -2 powertype2 = 0 end
		         if spec == 258 then powertype = 13 end

--pala
 		if spec == 65 then  powertype =  0 powertype2 = 9 end
 		if spec == 66 then powertype =  -3  powertype2 = 9 end
 		if spec == 70 then powertype =  -4 powertype2 = 9 end

-- dk	
	if spec == 250	then powertype =  6 powertype2 = -3 end   --blood
	if spec == 251	then powertype =  6 powertype2 = -2 end
	if spec == 252  then powertype =  6	powertype2 = -5 end

--druid
        		if spec == 102 then powertype = 8
			end
		         if spec == 103 then powertype =  -1 powertype2 = 3 
			end
		         if spec == 104 then powertype =  1
			end
		         if spec == 105 then powertype =  0
			end
-- hunter
	if spec == 253  then   	powertype =  2	end
	if spec == 254 then    	powertype =  2	end
	if spec == 255 then    	powertype =  2	end

-- mage
	if spec == 64 then powertype =  0 end
	if spec == 63 then 	powertype =  0 end
	if spec == 62 then     	powertype =  0
	end

--shaman

	if spec == 262 then     
        	powertype = -2 powertype2 = 0 
	end
	if spec == 263 then     
        	powertype =  -2 powertype2 = 0 
	end
	if spec == 264 then     
        	powertype =  -2 powertype2 = 0 
	end

--rogue
	if spec == 259 then     
        	powertype =  -1 
	end
	if spec == 260 then     
        	powertype =  -1
	end
	if spec == 261 then     
        	powertype =  -1
	end

--warrior
	if spec == 71 then     
        	powertype =  1 
	end
	if spec == 72 then     
        	powertype =  1 
	end
	if spec == 73 then     
        	powertype2 =  1 powertype2 = 1
	end
--monk
	if spec == 268 then powertype =  12 powertype2 = -3 end
	if spec == 269 then powertype =  12 end
	if spec == 270 then powertype =  12 end


	if db.switch == true then
	local temppower = powertype
	powertype = powertype2
	powertype2 = temppower
	end

end

