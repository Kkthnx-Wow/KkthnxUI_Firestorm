local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local CM = K:NewModule("Developer")

local _G = _G
local format = format
local gsub = gsub
local max = max
local pairs = pairs
local select = select
local strbyte = strbyte
local strfind = strfind
local strlower = strlower
local strsub = strsub
local tonumber = tonumber
local unpack = unpack
local wipe = wipe

local AbbreviateNumbers = AbbreviateNumbers
local BNGetNumFriends = BNGetNumFriends
local BNSendWhisper = BNSendWhisper
local CanGuildInvite = CanGuildInvite
local CloseDropDownMenus = CloseDropDownMenus
local CreateFrame = CreateFrame
local GetAverageItemLevel = GetAverageItemLevel
local GetCombatRatingBonus = GetCombatRatingBonus
local GetCritChance = GetCritChance
local GetHaste = GetHaste
local GetMasteryEffect = GetMasteryEffect
local GetRangedCritChance = GetRangedCritChance
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetSpellCritChance = GetSpellCritChance
local GetVersatilityBonus = GetVersatilityBonus
local GuildInvite = GuildInvite
local SendChatMessage = SendChatMessage
local UnitClass = UnitClass
local UnitHealthMax = UnitHealthMax
local UnitPlayerControlled = UnitPlayerControlled

local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local C_BattleNet_GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo
local C_BattleNet_GetFriendGameAccountInfo = C_BattleNet.GetFriendGameAccountInfo
local C_BattleNet_GetFriendNumGameAccounts = C_BattleNet.GetFriendNumGameAccounts
local C_Club_GetGuildClubId = C_Club.GetGuildClubId
local C_FriendList_AddFriend = C_FriendList.AddFriend
local C_FriendList_SendWho = C_FriendList.SendWho

local CR_VERSATILITY_DAMAGE_DONE = CR_VERSATILITY_DAMAGE_DONE
local HP = HP
local ITEM_LEVEL_ABBR = ITEM_LEVEL_ABBR
local STAT_CRITICAL_STRIKE = STAT_CRITICAL_STRIKE
local STAT_HASTE = STAT_HASTE
local STAT_MASTERY = STAT_MASTERY
local STAT_VERSATILITY = STAT_VERSATILITY
local TEXT_MODE_A_STRING_RESULT_CRITICAL = TEXT_MODE_A_STRING_RESULT_CRITICAL
local UIDROPDOWNMENU_MAXBUTTONS = UIDROPDOWNMENU_MAXBUTTONS

local PredefinedType = {
	GUILD_INVITE = {
		name = "Guild Invite",
		supportTypes = {
			PARTY = true,
			PLAYER = true,
			RAID_PLAYER = true,
			RAID = true,
			FRIEND = true,
			BN_FRIEND = true,
			CHAT_ROSTER = true,
			TARGET = true,
			FOCUS = true,
			COMMUNITIES_WOW_MEMBER = true,
			RAF_RECRUIT = true,
		},
		func = function(frame)
			if frame.bnetIDAccount then
				local numBNOnlineFriend = select(2, BNGetNumFriends())
				for i = 1, numBNOnlineFriend do
					local accountInfo = C_BattleNet_GetFriendAccountInfo(i)
					if accountInfo and accountInfo.bnetAccountID == frame.bnetIDAccount and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.isOnline then
						local numGameAccounts = C_BattleNet_GetFriendNumGameAccounts(i)
						if numGameAccounts and numGameAccounts > 0 then
							for j = 1, numGameAccounts do
								local gameAccountInfo = C_BattleNet_GetFriendGameAccountInfo(i, j)
								if gameAccountInfo.clientProgram and gameAccountInfo.clientProgram == "WoW" and gameAccountInfo.wowProjectID == 1 and gameAccountInfo.factionName == K.Faction then
									GuildInvite(gameAccountInfo.characterName .. "-" .. gameAccountInfo.realmName)
								end
							end
						elseif accountInfo.gameAccountInfo.clientProgram == "WoW" and accountInfo.gameAccountInfo.wowProjectID == 1 and accountInfo.gameAccountInfo.factionName == K.Faction then
							GuildInvite(accountInfo.gameAccountInfo.characterName .. "-" .. accountInfo.gameAccountInfo.realmName)
						end
						return
					end
				end
			elseif frame.chatTarget then
				GuildInvite(frame.chatTarget)
			elseif frame.name then
				local playerName = frame.name
				if frame.server and frame.server ~= K.Realm then
					playerName = playerName .. "-" .. frame.server
				end
				GuildInvite(playerName)
			else
				K.Print("debug", "Cannot get the name.")
			end
		end,
		isHidden = function(frame)
			-- 无邀请权限时不显示
			if not CanGuildInvite() then
				return true
			end

			-- 公会频道不需要这个功能
			if frame.communityClubID then
				if tonumber(frame.communityClubID) == tonumber(C_Club_GetGuildClubId()) then
					return true
				end
			end

			-- 目标为 NPC 时不显示
			if frame.unit and frame.unit == "target" then
				if not UnitPlayerControlled("target") then
					return true
				end
			end

			-- 焦点为 NPC 时不显示
			if frame.unit and frame.unit == "focus" then
				if not UnitPlayerControlled("focus") then
					return true
				end
			end

			-- 忽略自己
			if frame.name == K.Name then
				if not frame.server or frame.server == K.Realm then
					return true
				end
			end

			return false
		end,
	},
	WHO = {
		name = _G.WHO,
		supportTypes = {
			PARTY = true,
			PLAYER = true,
			RAID_PLAYER = true,
			RAID = true,
			FRIEND = true,
			GUILD = true,
			GUILD_OFFLINE = true,
			CHAT_ROSTER = true,
			TARGET = true,
			ARENAENEMY = true,
			FOCUS = true,
			WORLD_STATE_SCORE = true,
			COMMUNITIES_WOW_MEMBER = true,
			COMMUNITIES_GUILD_MEMBER = true,
			RAF_RECRUIT = true,
		},
		func = function(frame)
			if frame.chatTarget then
				C_FriendList_SendWho(frame.chatTarget)
			elseif frame.name then
				local playerName = frame.name
				if frame.server and frame.server ~= K.Realm then
					playerName = playerName .. "-" .. frame.server
				end
				C_FriendList_SendWho(playerName)
			else
				K.Print("debug", "Cannot get the name.")
			end
		end,
		isHidden = function(frame)
			-- 目标为 NPC 时不显示
			if frame.unit and frame.unit == "target" then
				if not UnitPlayerControlled("target") then
					return true
				end
			end

			-- 焦点为 NPC 时不显示
			if frame.unit and frame.unit == "focus" then
				if not UnitPlayerControlled("focus") then
					return true
				end
			end

			-- 忽略自己
			if frame.name == K.Name then
				if not frame.server or frame.server == K.Realm then
					return true
				end
			end

			return false
		end,
	},
	ADDFRIEND = {
		name = _G.ADD_FRIEND,
		supportTypes = {
			PARTY = true,
			PLAYER = true,
			RAID_PLAYER = true,
			RAID = true,
			FRIEND = true,
			GUILD = true,
			GUILD_OFFLINE = true,
			CHAT_ROSTER = true,
			TARGET = true,
			FOCUS = true,
			WORLD_STATE_SCORE = true,
			COMMUNITIES_WOW_MEMBER = true,
			COMMUNITIES_GUILD_MEMBER = true,
			RAF_RECRUIT = true,
		},
		func = function(frame)
			if frame.chatTarget then
				C_FriendList_AddFriend(frame.chatTarget)
			elseif frame.name then
				local playerName = frame.name
				if frame.server and frame.server ~= K.Realm then
					playerName = playerName .. "-" .. frame.server
				end
				C_FriendList_AddFriend(playerName)
			else
				K.Print("debug", "Cannot get the name.")
			end
		end,
		isHidden = function(frame)
			-- 目标为 NPC 时不显示
			if frame.unit and frame.unit == "target" then
				if not UnitPlayerControlled("target") then
					return true
				end
			end

			-- 焦点为 NPC 时不显示
			if frame.unit and frame.unit == "focus" then
				if not UnitPlayerControlled("focus") then
					return true
				end
			end

			-- 忽略自己
			if frame.name == K.Name then
				if not frame.server or frame.server == K.Realm then
					return true
				end
			end

			return false
		end,
	},
	REPORT_STATS = {
		name = "Report Stats",
		supportTypes = {
			PARTY = true,
			PLAYER = true,
			RAID_PLAYER = true,
			FRIEND = true,
			BN_FRIEND = true,
			GUILD = true,
			CHAT_ROSTER = true,
			TARGET = true,
			FOCUS = true,
			COMMUNITIES_WOW_MEMBER = true,
			COMMUNITIES_GUILD_MEMBER = true,
			RAF_RECRUIT = true,
		},
		func = function(frame)
			local name
			local SendChatMessage = SendChatMessage

			if frame.bnetIDAccount then
				SendChatMessage = function(message)
					BNSendWhisper(frame.bnetIDAccount, message)
				end
				name = "BN"
			elseif frame.chatTarget then
				name = frame.chatTarget
			elseif frame.name then
				name = frame.name
				if frame.server and frame.server ~= K.Realm then
					name = name .. "-" .. frame.server
				end
			end

			if not name then
				K.Print("debug", "Cannot get the name.")
				return
			end

			local CRITICAL = gsub(TEXT_MODE_A_STRING_RESULT_CRITICAL or STAT_CRITICAL_STRIKE, "[()]", "")

			C_Timer.After(0.1, function()
				SendChatMessage(format("(%s) %s: %.1f %s: %s", select(2, GetSpecializationInfo(GetSpecialization())) .. select(1, UnitClass("player")), ITEM_LEVEL_ABBR, select(2, GetAverageItemLevel()), HP, AbbreviateNumbers(UnitHealthMax("player"))), "WHISPER", nil, name)
			end)

			-- 致命
			C_Timer.After(0.3, function()
				SendChatMessage(format(" - %s: %.2f%%", CRITICAL, max(GetRangedCritChance(), GetCritChance(), GetSpellCritChance(2))), "WHISPER", nil, name)
			end)
			-- 加速
			C_Timer.After(0.5, function()
				SendChatMessage(format(" - %s: %.2f%%", STAT_HASTE, GetHaste()), "WHISPER", nil, name)
			end)
			-- 精通
			C_Timer.After(0.7, function()
				SendChatMessage(format(" - %s: %.2f%%", STAT_MASTERY, GetMasteryEffect()), "WHISPER", nil, name)
			end)

			-- 臨機應變
			C_Timer.After(0.9, function()
				SendChatMessage(format(" - %s: %.2f%%", STAT_VERSATILITY, GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)), "WHISPER", nil, name)
			end)
			-- 汲取
			--SendChatMessage(format(" - %s:%.2f%%", STAT_LIFESTEAL, GetLifesteal()), "WHISPER", nil, name)
		end,
		isHidden = function(frame)
			-- 目标为 NPC 时不显示
			if frame.unit and frame.unit == "target" then
				if not UnitPlayerControlled("target") then
					return true
				end
			end

			-- 焦点为 NPC 时不显示
			if frame.unit and frame.unit == "focus" then
				if not UnitPlayerControlled("focus") then
					return true
				end
			end

			-- 忽略自己
			if frame.name == K.Name then
				if not frame.server or frame.server == K.Realm then
					return true
				end
			end

			return false
		end,
	},
}

local function ContextMenu_OnShow(menu)
	local parent = menu:GetParent() or menu
	local width = parent:GetWidth()
	local height = 16
	for i = 1, #menu.buttons do
		local button = menu.buttons[i]
		if button:IsShown() then
			button:SetWidth(width - 32)
			height = height + 16
		end
	end
	menu:SetHeight(height)
	return height
end

local function ContextMenuButton_OnEnter(button)
	_G[button:GetName() .. "Highlight"]:Show()
end

local function ContextMenuButton_OnLeave(button)
	_G[button:GetName() .. "Highlight"]:Hide()
end

function CM:SkinDropDownList(frame)
	local Backdrop = _G[frame:GetName() .. "Backdrop"]
	local menuBackdrop = _G[frame:GetName() .. "MenuBackdrop"]

	if Backdrop then
		Backdrop:Kill()
	end

	if menuBackdrop then
		menuBackdrop:Kill()
	end
end

function CM:SkinButton(button)
	local highlight = _G[button:GetName() .. "Highlight"]
	highlight:SetColorTexture(K.r, K.g, K.b, 0.25)
	highlight:SetBlendMode("BLEND")
	highlight:SetDrawLayer("BACKGROUND")
	highlight:SetPoint("TOPLEFT", -12, 0)
	highlight:SetPoint("BOTTOMRIGHT", 12, 0)

	button:SetScript("OnEnter", ContextMenuButton_OnEnter)
	button:SetScript("OnLeave", ContextMenuButton_OnLeave)

	_G[button:GetName() .. "Check"]:SetAlpha(0)
	_G[button:GetName() .. "UnCheck"]:SetAlpha(0)
	_G[button:GetName() .. "Icon"]:SetAlpha(0)
	_G[button:GetName() .. "ColorSwatch"]:SetAlpha(0)
	_G[button:GetName() .. "ExpandArrow"]:SetAlpha(0)
	_G[button:GetName() .. "InvisibleButton"]:SetAlpha(0)
end

function CM:CreateMenu()
	if self.menu then
		return
	end

	local frame = CreateFrame("Button", "KKUI_ContextMenu", UIParent, "UIDropDownListTemplate")
	self:SkinDropDownList(frame)
	frame:Hide()

	frame:SetScript("OnShow", ContextMenu_OnShow)
	frame:SetScript("OnHide", nil)
	frame:SetScript("OnClick", nil)
	frame:SetScript("OnUpdate", nil)

	frame.buttons = {}

	for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
		local button = _G["KKUI_ContextMenuButton" .. i]
		if not button then
			button = CreateFrame("Button", "KKUI_ContextMenuButton" .. i, frame, "UIDropDownMenuButtonTemplate")
		end

		local text = _G[button:GetName() .. "NormalText"]
		text:ClearAllPoints()
		text:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
		text:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
		button.Text = text

		button:SetScript("OnEnable", nil)
		button:SetScript("OnDisable", nil)
		button:SetScript("OnClick", nil)

		self:SkinButton(button)
		button:Hide()

		frame.buttons[i] = button
	end

	self.menu = frame
end

function CM:UpdateButton(index, config, closeAfterFunction)
	local button = self.menu.buttons[index]
	if not button then
		return
	end

	button.Text:SetText(config.name)
	button.Text:Show()

	button.supportTypes = config.supportTypes
	button.isHidden = config.isHidden

	button:SetScript("OnClick", function()
		config.func(self.cache)
		if closeAfterFunction then
			CloseDropDownMenus()
		end
	end)
end

function CM:UpdateMenu()
	local buttonIndex = 1

	self:UpdateButton(buttonIndex, PredefinedType.ADDFRIEND, true)
	buttonIndex = buttonIndex + 1

	self:UpdateButton(buttonIndex, PredefinedType.GUILD_INVITE, true)
	buttonIndex = buttonIndex + 1

	self:UpdateButton(buttonIndex, PredefinedType.REPORT_STATS, true)
	buttonIndex = buttonIndex + 1

	self:UpdateButton(buttonIndex, PredefinedType.WHO, true)
	buttonIndex = buttonIndex + 1

	for i, button in pairs(self.menu.buttons) do
		if i >= buttonIndex then
			button:SetScript("OnClick", nil)
			button.Text:Hide()
			button.supportTypes = nil
		end
	end
end

function CM:DisplayButtons()
	-- 自动隐藏不符合条件的按钮
	local buttonOrder = 0
	for _, button in pairs(self.menu.buttons) do
		if button.supportTypes and button.supportTypes[self.cache.which] then
			if not button.isHidden(self.cache) then
				buttonOrder = buttonOrder + 1
				button:Show()
				button:ClearAllPoints()
				button:SetPoint("TOPLEFT", self.menu, "TOPLEFT", 16, -16 * buttonOrder)
			else
				button:Hide()
			end
		else
			button:Hide()
		end
	end

	return buttonOrder > 0
end

function CM:ShowMenu(frame)
	local dropdown = frame.dropdown
	-- if not dropdown or not self.db.enable then
	-- 	return
	-- end

	if not dropdown then
		return
	end

	-- 预组队伍右键
	-- dropdown.Button == _G.LFGListFrameDropDownButton

	-- E:Dump(dropdown)
	wipe(self.cache)
	self.cache = {
		which = dropdown.which,
		name = dropdown.name,
		unit = dropdown.unit,
		server = dropdown.server,
		chatTarget = dropdown.chatTarget,
		communityClubID = dropdown.communityClubID,
		bnetIDAccount = dropdown.bnetIDAccount,
	}

	if self.cache.which then
		if self:DisplayButtons() then
			self.menu:SetParent(frame)
			self.menu:SetFrameStrata(frame:GetFrameStrata())
			self.menu:SetFrameLevel(frame:GetFrameLevel() + 2)

			local menuHeight = ContextMenu_OnShow(self.menu)
			frame:SetHeight(frame:GetHeight() + menuHeight)

			self.menu:ClearAllPoints()
			local offset = 16
			if C_AddOns_IsAddOnLoaded("RaiderIO") then
				for _, child in pairs({ _G.DropDownList1:GetChildren() }) do
					local name = child:IsShown() and child:GetName()
					if name and strfind(name, "^LibDropDownExtensionCustomDropDown") then
						offset = 47
					end
				end
			end

			self.menu:SetPoint("BOTTOMLEFT", 0, offset)
			self.menu:SetPoint("BOTTOMRIGHT", 0, offset)
			self.menu:Show()
		end
	end
end

function CM:CloseMenu()
	if self.menu then
		self.menu:Hide()
	end
end

function CM:OnEnable()
	-- self.db = E.db.WT.social.contextMenu
	-- if not self.db.enable or self.initialized then
	-- 	return
	-- end

	self.cache = {}
	self:CreateMenu()
	self:UpdateMenu()

	-- Hook the OnShow script of DropDownList1
	_G.DropDownList1:HookScript("OnShow", function(self)
		-- Call your ShowMenu function
		CM:ShowMenu(self)
	end)

	-- Hook the OnHide script of DropDownList1
	_G.DropDownList1:HookScript("OnHide", function()
		-- Call your CloseMenu function
		CM:CloseMenu()
	end)

	self.tempButton = CreateFrame("Button", "KKUI_ContextMenuTempButton", UIParent, "SecureActionButtonTemplate")
	self.tempButton:SetAttribute("type1", "macro")
end

K.Devs = {
	["Kkthnx-Valdrakken"] = true,
	["Informant-Valdrakken"] = true,
	-- Fenox Temp
	["Trittlendy-Valdrakken"] = true,
}

local function isDeveloper()
	return K.Devs[K.Name .. "-" .. K.Realm]
end
K.isDeveloper = isDeveloper

if not K.isDeveloper() then
	return
end
