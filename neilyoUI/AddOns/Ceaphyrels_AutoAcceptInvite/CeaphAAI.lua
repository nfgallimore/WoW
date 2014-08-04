CeaphAAI = LibStub("AceAddon-3.0"):NewAddon("CeaphAAI", "AceEvent-3.0", "AceConsole-3.0")

local MAJOR_VERSION = "1"
local MINOR_VERSION = "2"
local VERSION_FIX   = "10"

local DEBUG = false

local L = LibStub("AceLocale-3.0"):GetLocale("CeaphAAI", true)

local function filter(self, event, msg, ...)
  if strfind(msg, L["filter1"]) then
    return true
  end
  if strfind(msg, L["filter2"]) then
    return true
  end
end

function tolower(str)
  local loc = GetLocale()

  if loc == "koKR" or loc == "zhCN" or loc == "zhTW" or loc == "ruRU" then
     return str
  end
    
  return strlower(str)
end

local options = {
  name = L["caai"],
	type = 'group',
	args = {
	  allow = {
	    name = L["behaviour"],
	    type = 'group',
	    order = 1,
	    args = {
	      alloweveryone = {
	        name = L["acceptall"],
	        desc = L["acceptall-desc"],
	        order = 10,
	        type = 'toggle',
	        set = function()
	          CeaphAAI.db.profile.settings.allowall=not(CeaphAAI.db.profile.settings.allowall) or nil
	        end,
	        get = function()
	          return CeaphAAI.db.profile.settings.allowall and true or false
	        end
	      },
	      allbutdeny = {
	        name = L["everyone"],
	        desc = L["everyone-desc"],
	        order = 11,
	        type = 'toggle',
	        disabled = function()
	          return (not CeaphAAI.db.profile.settings.allowall)
	        end,
	        set = function()
	          CeaphAAI.db.profile.settings.allowallbut=not(CeaphAAI.db.profile.settings.allowallbut) or nil
	        end,
	        get = function()
	          return CeaphAAI.db.profile.settings.allowallbut and true or false
	        end
	      },
	      friends = {
	      	name = L["friends"],
					desc = L["friends-desc"],
					order = 20,
					type = 'toggle',
					disabled = function()
	          return (CeaphAAI.db.profile.settings.allowall)
	        end,
					set = function()
						CeaphAAI.db.profile.settings.friend=not(CeaphAAI.db.profile.settings.friend) or nil
					end,
					get = function()
						return CeaphAAI.db.profile.settings.friend and true or false
					end
	      },
	      bnfriends = {
	      	name = L["bn-friends"],
					desc = L["bn-friends-desc"],
					order = 21,
					type = 'toggle',
					disabled = function()
	          return (CeaphAAI.db.profile.settings.allowall) or (not BNFeaturesEnabledAndConnected())
	        end,
	        hidden = function()
	          return (not BNFeaturesEnabledAndConnected())
					end,
					set = function()
						CeaphAAI.db.profile.settings.bnfriend=not(CeaphAAI.db.profile.settings.bnfriend) or nil
					end,
					get = function()
						return CeaphAAI.db.profile.settings.bnfriend and true or false
					end
	      },
	      guild = {
	        name = L["guild"],
					desc = L["guild-desc"],
					order = 30, 
					type = 'toggle',
					disabled = function()
	          return (CeaphAAI.db.profile.settings.allowall)
	        end,
	        hidden = function()
	          return not IsInGuild()
	        end,
					set = function()
						CeaphAAI.db.profile.settings.guild = not (CeaphAAI.db.profile.settings.guild) or nil
					end,
					get = function()
						return CeaphAAI.db.profile.settings.guild and true or false
					end
	      },
	      rank = {
	        name = L["guildrank"],
	        desc = L["guildrank-desc"],
	        order = 31,
	        type = 'toggle',
	        disabled = function()
	          return (not CeaphAAI.db.profile.settings.guild or CeaphAAI.db.profile.settings.allowall)
	        end,
	        hidden = function()
	          return not IsInGuild()
	        end,
	        set = function()
						CeaphAAI.db.profile.settings.rank = not(CeaphAAI.db.profile.settings.rank) or nil
					end,
					get = function()
						return CeaphAAI.db.profile.settings.rank and true or false
					end
	      },
	      officer = {
	        name= L["guildlowest"],
	        order= 32,
	        type= 'select',
	        style='dropdown',
	        disabled = function()
	          return (not (CeaphAAI.db.profile.settings.rank and CeaphAAI.db.profile.settings.guild) or CeaphAAI.db.profile.settings.allowall )
	        end,
	        hidden = function()
	          return not IsInGuild()
	        end,
	        values = function()
	          toreturn = {}
	          local num = GuildControlGetNumRanks()
	          local i = 1
	          while i <= num do
	            local key = tostring(i)
	            if i < 10 then
	              key = "0"..key
	            end
	            toreturn[key] = GuildControlGetRankName(i)
	            i = i + 1
	          end
	          return toreturn
	        end,
	        set = function(info, key)
	          CeaphAAI.db.profile.settings.officer = key
	        end,
	        get = function()
	          return CeaphAAI.db.profile.settings.officer
	        end
	      },
	      afk = {
	        name = L["whenafk"],
	        order = 50,
	        type = 'select',
	        style = 'radio',
	        values = {
            ["nothing"]  = L["opt-nothing"],
	          ["accept"]   = L["opt-accept"],
	          ["acceptw"]  = L["opt-acceptw"],
	          ["decline"]  = L["opt-decline"],
	          ["declinew"] = L["opt-declinew"]
          },
	        set = function(info, key)
	          CeaphAAI.db.profile.settings.afk = key
	        end,
	        get = function()
	          return CeaphAAI.db.profile.settings.afk
	        end
	      },
	      afkwhisper = {
	        name = L["whattowhisp"],
	        order = 51,
	        type = 'input',
	        width = 'full',
	        disabled = function()
	          return not (CeaphAAI.db.profile.settings.afk == "acceptw" or CeaphAAI.db.profile.settings.afk == "declinew")
	        end,
	        set = function(info, text)
	          CeaphAAI.db.profile.settings.afkwhisper = text
	        end,
	        get = function()
	          return CeaphAAI.db.profile.settings.afkwhisper
	        end
	      },
	      dnd = {
	        name = L["whendnd"],
	        order = 60,
	        type = 'select',
	        style = 'radio',
	        values = {
            ["nothing"]  = L["opt-nothing"],
	          ["accept"]   = L["opt-accept"],
	          ["acceptw"]  = L["opt-acceptw"],
	          ["decline"]  = L["opt-decline"],
	          ["declinew"] = L["opt-declinew"]
          },
	        set = function(info, key)
	          CeaphAAI.db.profile.settings.dnd = key
	        end,
	        get = function()
	          return CeaphAAI.db.profile.settings.dnd
	        end
	      },
	      dndwhisper = {
	        name = L["whattowhisp"],
	        order = 61,
	        type = 'input',
	        width = 'full',
	        disabled = function()
	          return not (CeaphAAI.db.profile.settings.dnd == "acceptw" or CeaphAAI.db.profile.settings.dnd == "declinew") 
	        end,
	        set = function(info, text)
	          CeaphAAI.db.profile.settings.dndwhisper = text
	        end,
	        get = function()
	          return CeaphAAI.db.profile.settings.dndwhisper
	        end
	      },
	      supaddon = {
				  name = L["suppress"],
				  desc = L["suppress-desc"],
				  order = 70,
				  type = 'toggle',
				  set = function()
				    CeaphAAI.db.profile.settings.supressaddon = not CeaphAAI.db.profile.settings.supressaddon or nil
				  end,
				  get = function()
				    return CeaphAAI.db.profile.settings.supressaddon and true or false
				  end, 
				},
				supwow = {
				  name = L["filter"],
				  desc = L["filter-desc"],
				  order = 71,
				  type = 'toggle',
				  set = function()
				    CeaphAAI.db.profile.settings.supresswow = not CeaphAAI.db.profile.settings.supresswow or nil
				    if CeaphAAI.db.profile.settings.supresswow then				    
	            ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", filter)
	          else
	            ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", filter)
	          end
				  end,
				  get = function()
				    return CeaphAAI.db.profile.settings.supresswow and true or false
				  end, 
				},
	    },
	  },
	  list = {
	    name = L["listmanagement"],
			order = 2,
			type = 'group',
			args = {
				accept = {
					name = L["allowlist"],
					desc = L["allowlist-desc"], 
					type = 'input', 
					usage = L["<name>"],
					order = 10,
					set = function(info, name)
						name=tolower(name)
						CeaphAAI.db.profile.accept[name]=1
						CeaphAAI.db.profile.deny[name]=nil
						CeaphAAI:Output(string.format(L["accepting"], name), false);
					end, 
					pattern = "^%w+$"
				},
				deny = {
					name = L["denylist"],
					desc = L["denylist-desc"], 
					type = 'input', 
					usage =L["<name>"],
					order = 20,
					set = function(info, name)
						name=tolower(name)
						CeaphAAI.db.profile.accept[name]=nil
						CeaphAAI.db.profile.deny[name]=1
						CeaphAAI:Output(string.format(L["denying"], name), false);
					end, 
					pattern = "^%w+$"
				},
        removelist = {
				  name = L["list"],
				  desc = L["list-desc"],
				  type = 'select',
				  order = 30, 
				  values = function()
				    local x = {}
				    for k in pairs(CeaphAAI.db.profile.accept) do
				      x[k] = k..L["allowed"]
				    end
            for k in pairs(CeaphAAI.db.profile.deny) do
				      x[k] = k..L["denied"]
					  end
					  return x					      					    
					end,
					set = function(info, key)
					  CeaphAAI.temp = key
					end,
					get = function()
					  return CeaphAAI.temp
					end
				},
				remove = {
				  name = L["remove"],
				  order = 40,
				  type = 'execute',
				  func = function()
            if CeaphAAI.temp then
				      CeaphAAI.db.profile.accept[CeaphAAI.temp] = nil
				      CeaphAAI.db.profile.deny[CeaphAAI.temp] = nil
				      CeaphAAI:Output(string.format(L["removed"], CeaphAAI.temp), false)
				      CeaphAAI.temp = nil
				    end
				  end,
				  confirm = function()
            if CeaphAAI.temp then
				      return string.format(L["removeinsurance"], CeaphAAI.temp)
            else
              return false
            end
				  end
				},
			},
	  },
	},
}

local defaults = {
	profile = {
		["accept"]={},
		["deny"]={},
		["settings"]={
		  ["afk"] = "accept",
		  ["dnd"] = "accept",
		  ["officer"] = "01",
		},
	},
}

function CeaphAAI:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("CeaphAAIVars", defaults)
	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	
	local version = MAJOR_VERSION.."."..MINOR_VERSION
  if tonumber(VERSION_FIX) > 0 then
    version = version.."."..VERSION_FIX
  end
	
	self:Print(string.format(L["loadedversion"], version))
end

function CeaphAAI:OnEnable()
  if IsInGuild() then
    GuildRoster()
	end
  self:RegisterEvent("PARTY_INVITE_REQUEST")
	
  if self.db.profile.settings.supresswow then
	  ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", filter)
	end
	
	self:Print(L["enabled"])
end

function CeaphAAI:OnDisable()
	self:UnregisterEvent("PARTY_INVITE_REQUEST")
	
  if self.db.profile.settings.supresswow then
	  ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", filter)
	end
	
	self:Print(L["disabled"])
end

function CeaphAAI:PARTY_INVITE_REQUEST(event, name)
  if name == nil then
    return
  end
  
  local lname = tolower(name)
	
	local afk = UnitIsAFK("player")
	local dnd = UnitIsDND("player")
	
	if (afk and self.db.profile.settings.afk == "nothing") or (dnd and self.db.profile.settings.dnd == "nothing") then
	  self:Output(string.format(L["request"], name), false)
	  return
	end
	
	if (afk and self.db.profile.settings.afk == "decline") or (dnd and self.db.profile.settings.dnd == "decline") then
	  DeclineGroup()
	  StaticPopup_Hide("PARTY_INVITE")
	  
	  self:Output(string.format(L["declined"], name), false) 
	  return
	end
	
	if afk and self.db.profile.settings.afk == "declinew" then
    DeclineGroup()
    StaticPopup_Hide("PARTY_INVITE")
		
    self:Output(string.format(L["declined"], name), false)
    
		if self.db.profile.settings.afkwhisper then
		  SendChatMessage(self.db.profile.settings.afkwhisper, "WHISPER", nil, name)
		end
	  return
	end
	
	if dnd and self.db.profile.settings.dnd == "declinew" then
	  DeclineGroup()
	  StaticPopup_Hide("PARTY_INVITE")
		
	  self:Output(string.format(L["declined"], name), false)
    
		if self.db.profile.settings.dndwhisper then
		  SendChatMessage(self.db.profile.settings.dndwhisper, "WHISPER", nil, name)
		end
	  return
	end
	
	if self.db.profile.settings.allowall and (not self.db.profile.settings.allowallbut) then
	  CeaphAAI:AcceptInvite()
	  
	  self:Output(string.format(L["accepted"], name), false)
	  
	  if afk and self.db.profile.settings.afk == "acceptw" and self.db.profile.settings.afkwhisper then
		  SendChatMessage(self.db.profile.settings.afkwhisper, "WHISPER", nil, name)
		end
    if dnd and self.db.profile.settings.dnd == "acceptw" and self.db.profile.settings.dndwhisper then
		  SendChatMessage(self.db.profile.settings.dndwhisper, "WHISPER", nil, name)
		end
	  
    return
	end
	
	if self.db.profile.deny[lname] then
		DeclineGroup()
		StaticPopup_Hide("PARTY_INVITE")
		
		self:Output(string.format(L["declined"], name), false)
    
		return
	end
	
	if self.db.profile.settings.allowallbut
		or self.db.profile.accept[lname]
		or (self.db.profile.settings.guild and CeaphAAI:IsGuildmate(name))
		or (self.db.profile.settings.friend and CeaphAAI:IsFriend(name))
		or (self.db.profile.settings.bnfriend and CeaphAAI:IsBNFriend(name)) then

		CeaphAAI:AcceptInvite()
	  
    self:Output(string.format(L["accepted"], name), false)
    
    if afk and self.db.profile.settings.afk == "acceptw" and self.db.profile.settings.afkwhisper then
		  SendChatMessage(self.db.profile.settings.afkwhisper, "WHISPER", nil, name)
		end
    if dnd and self.db.profile.settings.dnd == "acceptw" and self.db.profile.settings.dndwhisper then
		  SendChatMessage(self.db.profile.settings.dndwhisper, "WHISPER", nil, name)
		end
		
    return
	end
	
  self:Output(string.format(L["request"], name), false)

end

function CeaphAAI:AcceptInvite()
  AcceptGroup()
  for i=1, STATICPOPUP_NUMDIALOGS do
    local dlg = _G["StaticPopup"..i]
    if dlg.which == "PARTY_INVITE" then
      dlg.inviteAccepted = 1
      break
    end
  end
  StaticPopup_Hide("PARTY_INVITE")
end

function CeaphAAI:IsGuildmate(name)
	if (IsInGuild()) then
		local ngm=GetNumGuildMembers()
		for i=1, ngm do
			n, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName = GetGuildRosterInfo(i);
			if tolower(n) == tolower(name) then
			  if self.db.profile.settings.rank then
			    if tonumber(self.db.profile.settings.officer) >= rankIndex then
			      return true
			    else
			      return false
			    end
			  end
			  return true
			end
		end
	end
end

function CeaphAAI:IsFriend(name)
	local nf=GetNumFriends()
	for i=1, nf do
		if (tolower((GetFriendInfo(i))) == tolower(name)) then
			return true
		end
	end
end

function CeaphAAI:IsBNFriend(name)
	if BNFeaturesEnabledAndConnected() then
		local bnf=BNGetNumFriends()
		local userRealm=GetRealmName()
		for i=1, bnf do
		  pID,_,_,_,_,client,isOnline = BNGetFriendInfo(i)
		  if (client == "WoW" and isOnline) then
		  	_,tName,_,realm,r = BNGetToonInfo(pID)
		  	if (realm == userRealm) then
					if (tolower(tName) == tolower(name)) then
						return true
					end
				end
			end
		end
	end
end

function CeaphAAI:Output(message, dbg)
  if DEBUG then
    if self.db.profile.settings.supressaddon and not dbg then
      CeaphAAI:Print("SUPPRESSED:", message)
      return
    end
    if dbg then
      CeaphAAI:Print("DEBUG:", message)
      return
    end
    CeaphAAI:Print(message)
    return
  end
  
  if not self.db.profile.settings.supressaddon and not dbg then
    CeaphAAI:Print(message)
    return
  end
end

function CeaphAAI:OpenConfig(input)
  if input == "disable" then
    CeaphAAI:Disable()
    return
  end
  
  if input == "enable" then
    CeaphAAI:Enable()
    return
  end
  
  if input == "debug" then
    DEBUG = not DEBUG
    if DEBUG then
      self:Print("Debug mode: ON")
    else
      self:Print("Debug mode: OFF")
    end
    return
  end
  
	if input == "config" or not InterfaceOptionsFrame:IsResizable() then
		InterfaceOptionsFrame:Hide()
		LibStub("AceConfigDialog-3.0"):SetDefaultSize("CeaphAAI", 500, 550)
		LibStub("AceConfigDialog-3.0"):Open("CeaphAAI")
	else
		InterfaceOptionsFrame_OpenToCategory(CeaphAAI.optionsFrame)
	end
end

CeaphAAI.options = options	
LibStub("AceConfig-3.0"):RegisterOptionsTable("CeaphAAI", options)
CeaphAAI.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CeaphAAI", L["caai"])

CeaphAAI:RegisterChatCommand("ceaphyrelsautoacceptinvite", "OpenConfig")
CeaphAAI:RegisterChatCommand("caai", "OpenConfig")
