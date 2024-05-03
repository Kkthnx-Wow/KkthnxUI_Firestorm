local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Chat")

local math_min = math.min
local gsub = string.gsub
local pairs, ipairs = pairs, ipairs
local tremove = table.remove

local IsGuildMember, IsFriend, IsGUIDInGroup = IsGuildMember, C_FriendList.IsFriend, IsGUIDInGroup
local Ambiguate, GetTime = Ambiguate, GetTime
local GetGameAccountInfoByGUID = C_BattleNet.GetGameAccountInfoByGUID

-- Filter Chat symbols
local msgSymbols = { "`", "～", "＠", "＃", "^", "＊", "！", "？", "。", "|", " ", "—", "——", "￥", "’", "‘", "“", "”", "【", "】", "『", "』", "《", "》", "〈", "〉", "（", "）", "〔", "〕", "、", "，", "：", ",", "_", "/", "~" }

local FilterList = {}
local WhiteFilterList = {}

function Module:UpdateFilterList()
	K.SplitList(FilterList, C["Chat"].ChatFilterList, true)
end

function Module:UpdateFilterWhiteList()
	K.SplitList(WhiteFilterList, C["Chat"].ChatFilterWhiteList, true)
end

function Module:CompareStrDiff(string_A, string_B)
	local length_A, length_B = #string_A, #string_B

	local last_table, this_table = {}, {}

	for j = 0, length_B do
		last_table[j + 1] = j
	end

	for i = 1, length_A do
		this_table[1] = i
		for j = 1, length_B do
			local cost = (string_A[i] == string_B[j]) and last_table[j] or (math_min(last_table[j + 1], this_table[j], last_table[j]) + 1)
			this_table[j + 1] = cost
		end

		-- Copying table elements
		for j = 0, length_B do
			last_table[j + 1] = this_table[j + 1]
		end
	end

	return this_table[length_B + 1] / math.max(length_A, length_B)
end

C.BadBoys = {} -- Debugging

local chatLines = {}
local prevLineID, filterResult = 0, false

function Module:UpdateChatFilter(event, msg, author, _, _, _, flag, _, _, _, _, lineID, guid)
	if lineID == prevLineID then
		return filterResult
	end

	prevLineID = lineID

	local name = Ambiguate(author, "none")
	filterResult = Module:GetFilterResult(event, msg, name, flag, guid)

	if filterResult and filterResult ~= 0 then
		C.BadBoys[name] = (C.BadBoys[name] or 0) + 1
	end

	if filterResult == 0 then
		filterResult = true
	end

	return filterResult
end

function Module:GetFilterResult(event, msg, name, flag, guid)
	if name == K.Name or (event == "CHAT_MSG_WHISPER" and flag == "GM") or flag == "DEV" then
		-- Ignore messages from self, GMs in whispers, and developers
		return
	elseif guid and (IsGuildMember(guid) or GetGameAccountInfoByGUID(guid) or IsFriend(guid) or IsGUIDInGroup(guid)) then
		-- Ignore messages from guild members, friends, and group members
		return
	end

	if C["Chat"].BlockStranger and event == "CHAT_MSG_WHISPER" then -- Block strangers
		Module.MuteCache[name] = GetTime()
		return true
	end

	if C["Chat"].BlockSpammer and C.BadBoys[name] and C.BadBoys[name] >= 5 then
		return true
	end

	local filterMsg = msg:gsub("|H.-|h(.-)|h", "%1")
	filterMsg = gsub(filterMsg, "|c%x%x%x%x%x%x%x%x", "")
	filterMsg = gsub(filterMsg, "|r", "")

	if filterMsg == "" then
		-- Ignore empty messages
		return
	end

	-- Trash Filter
	for _, symbol in ipairs(msgSymbols) do
		filterMsg = gsub(filterMsg, symbol, "")
	end

	if event == "CHAT_MSG_CHANNEL" then
		local matches = 0
		local found

		for keyword in pairs(WhiteFilterList) do
			if keyword ~= "" then
				found = true
				local _, count = gsub(filterMsg, keyword, "")
				if count > 0 then
					matches = matches + 1
				end
			end
		end

		if matches == 0 and found then
			return 0
		end
	end

	local matches = 0
	for keyword in pairs(FilterList) do
		if keyword ~= "" then
			local _, count = gsub(filterMsg, keyword, "")
			if count > 0 then
				matches = matches + 1
			end
		end
	end

	if matches >= C["Chat"].FilterMatches then
		return true
	end

	-- ECF Repeat Filter
	local msgTable = #chatLines >= 30 and tremove(chatLines, 1) or {}
	-- Clear table contents
	for k in pairs(msgTable) do
		msgTable[k] = nil
	end
	msgTable[1], msgTable[2], msgTable[3] = name, {}, GetTime()

	for i = 1, #filterMsg do
		msgTable[2][i] = filterMsg:byte(i)
	end

	local chatLinesSize = #chatLines
	chatLines[chatLinesSize + 1] = msgTable

	for i = 1, chatLinesSize do
		local line = chatLines[i]
		if line[1] == msgTable[1] and ((event == "CHAT_MSG_CHANNEL" and msgTable[3] - line[3] < 0.6) or Module:CompareStrDiff(line[2], msgTable[2]) <= 0.1) then
			tremove(chatLines, i)
			return true
		end
	end

	return
end

function Module:CreateChatFilter()
	if C_AddOns.IsAddOnLoaded("EnhancedChatFilter") then
		return
	end

	if C["Chat"].EnableFilter then
		self:UpdateFilterList()
		self:UpdateFilterWhiteList()
		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", self.UpdateChatFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", self.UpdateChatFilter)
	end
end
