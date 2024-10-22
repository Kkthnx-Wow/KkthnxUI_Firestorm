local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- Auto opening of items in bag (kAutoOpen by Kellett)

local C_Container_GetContainerItemInfo = C_Container.GetContainerItemInfo
local C_Container_GetContainerItemLink = C_Container.GetContainerItemLink
local C_Container_GetContainerNumSlots = C_Container.GetContainerNumSlots
local C_Container_UseContainerItem = C_Container.UseContainerItem
local OPENING = OPENING

local openFrames = {} -- Table to store the state of open frames
local lastAttemptTime = 0 -- Last time an item open attempt was made
local cooldown = 1 -- Cooldown in seconds between attempts

local function BankOpened()
	openFrames.bank = true
end
local function BankClosed()
	openFrames.bank = false
end
local function GuildBankOpened()
	openFrames.guildBank = true
end
local function GuildBankClosed()
	openFrames.guildBank = false
end
local function MailOpened()
	openFrames.mail = true
end
local function MailClosed()
	openFrames.mail = false
end
local function MerchantOpened()
	openFrames.merchant = true
end
local function MerchantClosed()
	openFrames.merchant = false
end

local function ShouldDelay()
	-- Check if the bank, mail, or merchant frames are open
	if openFrames.bank or openFrames.mail or openFrames.merchant then
		return true
	end
	return false
end

local function BagDelayedUpdate()
	local now = GetTime()

	-- Throttle to prevent spamming attempts
	if now - lastAttemptTime < cooldown then
		return
	end
	lastAttemptTime = now

	-- Delay opening if in combat or relevant frames are open
	if ShouldDelay() then
		return
	end

	if InCombatLockdown() then
		-- Register to try again after combat ends
		K:RegisterEvent("PLAYER_REGEN_ENABLED", BagDelayedUpdate)
		K.Print("Waiting until combat ends to open items...")
		return
	end

	-- Loop through all the bags
	for bag = 0, 4 do
		for slot = 0, C_Container_GetContainerNumSlots(bag) do
			local cInfo = C_Container_GetContainerItemInfo(bag, slot)

			-- Check if the item has loot, is not locked, and has an itemID
			if cInfo and cInfo.hasLoot and not cInfo.isLocked and cInfo.itemID then
				-- Check if the item is in the auto-open list
				if C.AutoOpenItems[cInfo.itemID] then
					K.Print(K.SystemColor .. OPENING .. ":|r " .. C_Container_GetContainerItemLink(bag, slot))
					C_Container_UseContainerItem(bag, slot)
					return -- Stop after opening one item to avoid spamming
				end
			end
		end
	end
end

local events = {
	["BANKFRAME_OPENED"] = BankOpened,
	["BANKFRAME_CLOSED"] = BankClosed,
	["GUILDBANKFRAME_OPENED"] = GuildBankOpened,
	["GUILDBANKFRAME_CLOSED"] = GuildBankClosed,
	["MAIL_SHOW"] = MailOpened,
	["MAIL_CLOSED"] = MailClosed,
	["MERCHANT_SHOW"] = MerchantOpened,
	["MERCHANT_CLOSED"] = MerchantClosed,
	["BAG_UPDATE_DELAYED"] = BagDelayedUpdate,
}

function Module:CreateAutoOpenItems()
	if C["Automation"].AutoOpenItems then
		for event, func in pairs(events) do
			K:RegisterEvent(event, func)
		end
	end
end
