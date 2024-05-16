local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Announcements")

local strlower = strlower

local C_Container_GetContainerItemID = C_Container.GetContainerItemID
local C_Container_GetContainerItemLink = C_Container.GetContainerItemLink
local C_Container_GetContainerNumSlots = C_Container.GetContainerNumSlots

local C_Item_IsItemKeystoneByID = C_Item.IsItemKeystoneByID
local C_MythicPlus_GetOwnedKeystoneChallengeMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID
local C_MythicPlus_GetOwnedKeystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel

local NUM_BAG_SLOTS = NUM_BAG_SLOTS

local function getKeystoneLink()
	for bagIndex = 0, NUM_BAG_SLOTS do
		for slotIndex = 1, C_Container_GetContainerNumSlots(bagIndex) do
			local itemID = C_Container_GetContainerItemID(bagIndex, slotIndex)
			if itemID and C_Item_IsItemKeystoneByID(itemID) then
				return C_Container_GetContainerItemLink(bagIndex, slotIndex)
			end
		end
	end
end

function Module.Keystone(event)
	-- K.Print("KkthnxUI: Keystone event fired:", event)
	local mapID = C_MythicPlus_GetOwnedKeystoneChallengeMapID()
	local keystoneLevel = C_MythicPlus_GetOwnedKeystoneLevel()

	if event == "PLAYER_ENTERING_WORLD" then
		Module.keystoneCache.mapID = mapID
		Module.keystoneCache.keystoneLevel = keystoneLevel
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.Keystone)
	elseif event == "CHALLENGE_MODE_COMPLETED" or event == "ITEM_CHANGED" then
		if Module.keystoneCache.mapID ~= mapID or Module.keystoneCache.keystoneLevel ~= keystoneLevel then
			Module.keystoneCache.mapID = mapID
			Module.keystoneCache.keystoneLevel = keystoneLevel

			local link = getKeystoneLink()
			if link then
				local message = string.gsub("My new keystone is %keystone%.", "%%keystone%%", link)
				-- K.Print("Sending chat message:", message)
				C_Timer.After(1, function()
					if IsPartyLFG() then
						SendChatMessage(message, "INSTANCE_CHAT")
					elseif IsInGroup() then
						SendChatMessage(message, "PARTY")
					end
				end)
			end
		end
	end
end

function Module.KeystoneLink(message, sender)
	-- K.Print("KkthnxUI: KeystoneLink event fired: " .. message .. " Text: " .. sender)
	if strlower(sender) == "!keys" then
		local channel
		if message == "CHAT_MSG_PARTY" or message == "CHAT_MSG_PARTY_LEADER" then
			channel = "PARTY"
		elseif message == "CHAT_MSG_GUILD" then
			channel = "GUILD"
		end

		if channel then
			local link = getKeystoneLink()
			if link then
				-- K.Print("Sending chat message:", link, "Channel:", channel)
				C_Timer.After(1, function()
					SendChatMessage(link, channel)
				end)
			end
		end
	end
end

function Module:CreateKeystoneAnnounce()
	if not C["Announcements"].KeystoneAlert then
		return
	end
	-- K.Print("Module enabled.")
	Module.keystoneCache = Module.keystoneCache or {} -- ???

	K:RegisterEvent("CHAT_MSG_PARTY", Module.KeystoneLink)
	K:RegisterEvent("CHAT_MSG_PARTY_LEADER", Module.KeystoneLink)
	K:RegisterEvent("CHAT_MSG_GUILD", Module.KeystoneLink)
	K:RegisterEvent("ITEM_CHANGED", Module.Keystone)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.Keystone)
	K:RegisterEvent("CHALLENGE_MODE_COMPLETED", Module.Keystone)
end
