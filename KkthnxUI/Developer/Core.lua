local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

K.Devs = {
	["Kkthnx-Valdrakken"] = true,
	["Informant-Valdrakken"] = true,
	-- Fenox Temp
	["Trittlendy-Valdrakken"] = true,
}

local function isDeveloper()
	return K.Devs[K.Name .. "-" .. K.Realm]
end
K.isDeveloper = isDeveloper()

if not K.isDeveloper then
	return
end

-- Your taintLog module
local taintLogModule = K:NewModule("TaintLog")

-- Function to toggle taintLog setting
function taintLogModule.ToggleTaintLog()
	local currentSetting = GetCVar("taintLog")

	if currentSetting == "0" then
		SetCVar("taintLog", "1")
		print("Taint log is now |cFF00FF00ON.|r") -- Green color for "ON"
	else
		SetCVar("taintLog", "0")
		print("Taint log is now |cFFFF0000OFF.|r") -- Red color for "OFF"
	end
end

-- Function to check and print taintLog status on login/reload
function taintLogModule.CheckTaintLogStatus()
	local currentSetting = GetCVar("taintLog")

	if currentSetting == "0" then
		print("Taint log is currently |cFFFF0000OFF.|r") -- Red color for "OFF"
	else
		print("Taint log is currently |cFF00FF00ON.|r") -- Green color for "ON"
	end

	-- Unregister the event after checking
	K:UnregisterEvent("PLAYER_ENTERING_WORLD", taintLogModule.CheckTaintLogStatus)
end

-- Add an OnEnable function
function taintLogModule:OnEnable()
	-- Register events for taintLog
	K:RegisterEvent("PLAYER_ENTERING_WORLD", taintLogModule.CheckTaintLogStatus)
	SLASH_TOGGLETAINTLOG1 = "/ttl"
	SlashCmdList["TOGGLETAINTLOG"] = taintLogModule.ToggleTaintLog
end

--------------------------------------------------------------------------------------
-- AutoDismount Me
--------------------------------------------------------------------------------------
local AutoDismount = K:NewModule("AutoDismount")

local ErrorsToCheckFor = {
	[SPELL_FAILED_NOT_SHAPESHIFT] = true,
	[SPELL_FAILED_NO_ITEMS_WHILE_SHAPESHIFTED] = true,
	[SPELL_NOT_SHAPESHIFTED] = true,
	[SPELL_NOT_SHAPESHIFTED_NOSPACE] = true,
	[ERR_CANT_INTERACT_SHAPESHIFTED] = true,
	[ERR_NOT_WHILE_SHAPESHIFTED] = true,
	[ERR_NO_ITEMS_WHILE_SHAPESHIFTED] = true,
	[ERR_TAXIPLAYERSHAPESHIFTED] = true,
	[ERR_MOUNT_SHAPESHIFTED] = true,
	[ERR_EMBLEMERROR_NOTABARDGEOSET] = true,
	[SPELL_FAILED_NOT_MOUNTED] = true,
	[ERR_ATTACK_MOUNTED] = true,
	[ERR_NOT_WHILE_MOUNTED] = true,
	-- Add any other error codes as needed
}

local function HandleDismountError()
	local ok, err = pcall(Dismount)
	if not ok then
		-- Handle or log the error
	end
end

local function OnErrorMessage(_, _, messageType)
	if ErrorsToCheckFor[messageType] and IsMounted() and not UnitAffectingCombat("player") then
		HandleDismountError()
	end
end

function AutoDismount:OnEnable()
	K:RegisterEvent("UI_ERROR_MESSAGE", OnErrorMessage)
end

-----------------------------------------------------------------------------
-- Firestorm Chat Filter
-- Filters alot of annoying messages from chat.
-----------------------------------------------------------------------------
local function FirestormChatFilter(_, event, msg, ...)
	local filters = {
		"%-(.*)%%|T(.*)|t(.*)|c(.*)%%|r",
		"%[(.*)ARENA ANNOUNCER(.*)%]",
		"%[(.*)Announce by(.*)%]",
		"%[(.*)Autobroadcast(.*)%]",
		"%[(.*)BG Queue Announcer(.*)%]",
		"You are not mounted so you can't dismount",
		"Your pet has learned a new ability",
		"Teller says: The siege on Dragonbane Keep is about to begin!", -- He spams!
	}

	for _, pattern in pairs(filters) do
		if msg:match(pattern) then
			-- Debugging: Print the matched message and pattern
			-- print("Filtered message:", msg, "Pattern:", pattern, "Event:", event)
			return true -- Message matches one of the patterns, so filter it out
		end
	end

	return false, msg, ...
end

-- Hook the filtering function into chat message events
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", FirestormChatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", FirestormChatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_SAY", FirestormChatFilter)

-----------------------------------------------------------------------------
-- Class Pet Reminder
-- CPR (Class Pet Reminder) module for reminding players to summon their pets
-----------------------------------------------------------------------------
local CPR = K:NewModule("CPR")

local reminderTimer = nil
local REMINDER_INTERVAL = 10 -- seconds

-- Function to handle pet summoned event
local function OnPetSummoned()
	if reminderTimer then
		reminderTimer:Cancel()
		reminderTimer = nil
	end
end

-- Function to handle a pet that is not summoned
local function NotifyNotSummonedPet()
	local icon = "|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:20|t" -- Example pet icon (Skull)
	UIErrorsFrame:AddMessage(icon .. " Warning: Your pet is not summoned! Remember to summon it.", 1.0, 0.5, 0.5, 1.0)
end

-- Function to handle a dead pet
local function NotifyDeadPet()
	local icon = "|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:20|t" -- Example pet icon (Skull)
	UIErrorsFrame:AddMessage(icon .. " Warning: Your pet has died! Resummon or revive it.", 1.0, 0.5, 0.5, 1.0)
end

-- Function to create class pet reminder
local function CreateClassPetReminder(event)
	-- Function to check if the player meets the conditions to run the reminder
	local function CanRunReminder()
		return UnitAffectingCombat("player") and not UnitIsDeadOrGhost("player") and not IsMounted()
	end

	-- Function to check if pet is not summoned
	local function CheckNotSummonedPet()
		if CanRunReminder() then
			if K.Class == "HUNTER" or K.Class == "WARLOCK" then
				if not UnitExists("pet") then
					NotifyNotSummonedPet()
				end
			end
		end
	end

	-- Function to check if pet is dead
	local function CheckDeadPet()
		if CanRunReminder() then
			if K.Class == "HUNTER" or K.Class == "WARLOCK" then
				if UnitIsDead("pet") then
					NotifyDeadPet()
				end
			end
		end
	end

	-- Event handling based on event type
	if event == "PLAYER_REGEN_DISABLED" then
		CheckNotSummonedPet()
		CheckDeadPet()
		reminderTimer = C_Timer.NewTicker(REMINDER_INTERVAL, function()
			CheckNotSummonedPet()
			CheckDeadPet()
		end)
	elseif event == "PLAYER_REGEN_ENABLED" or event == "UNIT_PET" then
		OnPetSummoned()
	end
end

-- Function called when the module is enabled
function CPR:OnEnable()
	-- Registering events to trigger class pet reminder
	K:RegisterEvent("PLAYER_REGEN_DISABLED", CreateClassPetReminder)
	K:RegisterEvent("PLAYER_REGEN_ENABLED", CreateClassPetReminder)
	K:RegisterEvent("UNIT_PET", CreateClassPetReminder, "player")
end

-----------------------------------------------------------------------------
-- HunterGrowlReminder (HGR)
-- HunterGrowlReminder is a lightweight addon designed to help hunters remind
-- other hunters to disable their pet's Growl ability while in a group or raid
-----------------------------------------------------------------------------

-- local HGR_L = {
-- 	enUS = ", please disable your pet's Growl ability while in a group.",
-- 	deDE = ", bitte deaktiviere die Fähigkeit 'Knurren' deines Begleiters, während du in einer Gruppe bist.",
-- 	esES = ", por favor, desactiva la habilidad de Rugido de tu mascota mientras estás en un grupo.",
-- 	esMX = ", por favor, desactiva la habilidad Rugido de tu mascota mientras estás en un grupo.",
-- 	frFR = ", veuillez désactiver l'aptitude Growl de votre familier pendant que vous êtes en groupe.",
-- 	itIT = ", per favore disattiva l'abilità Ringhio del tuo famiglio mentre sei in gruppo.",
-- 	ptBR = ", por favor, desative a habilidade Rugido do seu ajudante enquanto estiver em grupo.",
-- 	ptPT = ", por favor, desativa a habilidade Rugido do teu ajudante enquanto estiveres em grupo.",
-- 	ruRU = ", пожалуйста, отключите способность Грозный рык вашего питомца, находясь в группе.",
-- 	koKR = ", 파티에 있는 동안 반려동물의 유혹 능력을 비활성화 해주세요.",
-- 	zhCN = "，请在组队时关闭你的宠物的咆哮技能。",
-- 	zhTW = "，請在團隊中關閉你的寵物的咆哮技能。",
-- }

-- local function IsPlayerHunter()
-- 	local _, class = UnitClass("player")
-- 	return class == "HUNTER"
-- end

-- local function IsPlayerInGroup()
-- 	return IsInGroup()
-- end

-- local function IsPlayerInRaid()
-- 	return IsInRaid()
-- end

-- local function SendReminderMessage(playerName)
-- 	local inPartyLFG = IsPartyLFG()
-- 	local inRaid = IsPlayerInRaid()
-- 	local _, instanceType = GetInstanceInfo()

-- 	local locale = GetLocale()
-- 	local msg = HGR_L[locale] or HGR_L["enUS"]
-- 	msg = playerName .. msg

-- 	if IsPlayerInGroup() then
-- 		if IsPlayerInRaid() then
-- 			SendChatMessage(msg, inPartyLFG and "INSTANCE_CHAT" or "RAID")
-- 		else
-- 			SendChatMessage(msg, inPartyLFG and "INSTANCE_CHAT" or "PARTY")
-- 		end
-- 	elseif instanceType == "raid" then
-- 		SendChatMessage(msg, "RAID")
-- 	elseif instanceType == "party" then
-- 		SendChatMessage(msg, "INSTANCE_CHAT")
-- 	end
-- end

-- local function OnCombatLogEvent(_, _, eventType, _, _, sourceName, _, _, destName, _, _, spellID)
-- 	if IsPlayerHunter() and eventType == "SPELL_CAST_SUCCESS" and spellID == 2649 and destName == UnitName("player") then
-- 		SendReminderMessage(sourceName)
-- 	end
-- end

-- local frame = CreateFrame("Frame")
-- frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
-- frame:SetScript("OnEvent", OnCombatLogEvent)

--------------------------------------------------------------------------
C["ExtraMapIcons"] = {

	----------------------------------------------------------------------
	--	World Of Warcraft: Eastern Kingdoms
	----------------------------------------------------------------------

	--[[Tirisfal Glades]]
	[18] = {
		{ "PortalH", 61.9, 59.0, "Stranglethorn Vale", "Portal" },
		{ "PortalH", 60.7, 58.7, "Orgrimmar", "Portal" },
		{ "PortalH", 59.1, 58.9, "Howling Fjord", "Portal" },
		{ "PortalH", 59.4, 67.4, "Silvermoon City", "Orb of Translocation" },
	},

	--[[Northern Stranglethorn]]
	[50] = {
		{ "PortalH", 37.6, 51.0, "Undercity", "Portal" },
	},

	--[[Stormwind City]]
	[84] = {
		{ "PortalA", 74.4, 18.4, "Eastern Earthshrine", "Deepholm, Hyjal, Tol Barad, Twilight Highlands, Uldum, Vashj'ir" },
	},

	--[[Undercity]]
	[90] = {
		{ "PortalH", 85.3, 17.1, "Hellfire Peninsula", "Portal" },
	},

	----------------------------------------------------------------------
	--	World Of Warcraft: Kalimdor
	----------------------------------------------------------------------

	--[[Teldrassil]]
	[57] = {
		{ "PortalA", 55.0, 93.7, "Stormwind", "Portal" },
		{ "PortalA", 52.3, 89.5, "Exodar", "Portal" },
	},

	--[[Caverns of Time: The Spiral]]
	[74] = {
		{ "PortalA", 59.0, 26.8, "Stormwind", "Portal" },
		{ "PortalH", 58.2, 26.7, "Orgrimmar", "Portal" },
	},

	--[[Silithus]]
	[81] = {
		{ "PortalN", 43.2, 44.5, "Chamber of Heart", "Titan Translocator" },
		{ "PortalA", 41.5, 44.9, "Tiragarde Sound", "Portal" },
		{ "PortalH", 41.6, 45.2, "Zuldazar", "Portal" },
	},

	--[[Orgrimmar: Main City]]
	[85] = {
		{ "PortalH", 50.1, 37.8, "Western Earthshrine", "Deepholm, Hyjal, Twilight Highlands, Uldum, Vashj'ir" },
		{ "PortalH", 47.4, 39.3, "Tol Barad", "Portal" },
		{ "PortalH", 43.0, 65.0, "Zeppelin to Thunder Bluff, Mulgore", "" },
		{ "PortalH", 50.7, 55.5, "Undercity", "Portal" },
	},

	--[[Orgrimmar: The Cleft Of Shadow]]
	[86] = {
		{ "PortalH", 50.1, 37.8, "Western Earthshrine", "Deepholm, Hyjal, Twilight Highlands, Uldum, Vashj'ir" },
		{ "PortalH", 47.4, 39.3, "Tol Barad", "Portal" },
		{ "PortalH", 43.0, 65.0, "Zeppelin to Thunder Bluff, Mulgore", "" },
		{ "PortalH", 50.7, 55.5, "Undercity", "Portal" },
	},

	--[[Thunder Bluff]]
	[88] = {
		{ "PortalH", 14.6, 26.4, "Zeppelin to Orgrimmar, Durotar", "" },
	},

	--[[Darnassus]]
	[89] = {
		{ "PortalA", 44.1, 78.5, "Temple of the Moon", "Exodar, Hellfire Peninsula" },
	},

	--[[Azuremyst Isle]]
	[97] = {
		{ "PortalA", 20.4, 54.1, "Darnassus", "Portal" },
	},

	--[[Ruins of Ahn'Qiraj]]
	[247] = {
		{ "Chest", 59.3, 28.7, "Scarab Coffer", "Chest" },
		{ "Chest", 60.8, 51.0, "Scarab Coffer", "Chest" },
		{ "Chest", 73.0, 66.4, "Scarab Coffer", "Chest" },
		{ "Chest", 57.4, 78.3, "Scarab Coffer", "Chest" },
		{ "Chest", 54.8, 87.5, "Scarab Coffer", "Chest" },
		{ "Chest", 41.0, 76.9, "Scarab Coffer", "Chest" },
		{ "Chest", 34.0, 53.0, "Scarab Coffer", "Chest" },
		{ "Chest", 41.1, 32.2, "Scarab Coffer", "Chest" },
		{ "Chest", 41.6, 46.3, "Scarab Coffer", "Chest" },
		{ "Chest", 46.7, 42.0, "Scarab Coffer", "Chest" },
	},

	--[[Temple of Ahn'Qiraj]]
	[319] = {
		{ "Chest", 33.1, 48.4, "Large Scarab Coffer", "Chest" },
		{ "Chest", 64.5, 25.5, "Large Scarab Coffer", "Chest" },
		{ "Chest", 58.4, 49.9, "Large Scarab Coffer", "Chest" },
		{ "Chest", 47.5, 54.7, "Large Scarab Coffer", "Chest" },
		{ "Chest", 56.2, 66.0, "Large Scarab Coffer", "Chest" },
		{ "Chest", 50.7, 78.1, "Large Scarab Coffer", "Chest" },
		{ "Chest", 51.4, 83.2, "Large Scarab Coffer", "Chest" },
		{ "Chest", 48.4, 85.4, "Large Scarab Coffer", "Chest" },
		{ "Chest", 48.0, 81.1, "Large Scarab Coffer", "Chest" },
		{ "Chest", 34.2, 83.5, "Large Scarab Coffer", "Chest" },
		{ "Chest", 39.2, 68.4, "Large Scarab Coffer", "Chest" },
	},

	----------------------------------------------------------------------
	--	The Burning Crusade
	----------------------------------------------------------------------

	--[[Hellfire Peninsula]]
	[100] = {
		{ "PortalH", 88.6, 47.7, "Orgrimmar", "Portal" },
		{ "PortalA", 88.6, 52.8, "Stormwind", "Portal" },
	},

	--[[The Exodar]]
	[103] = {
		{ "PortalA", 48.3, 62.9, "Stormwind", "Portal" },
	},

	--[[Silvermoon City]]
	[110] = {
		{ "PortalH", 58.5, 18.7, "Orgrimmar", "Portal" },
		{ "PortalH", 49.5, 14.8, "Undercity", "Orb of Translocation" },
		{ "PortalH", 58.5, 18.7, "Orgrimmar", "Portal" },
	},

	--[[Shattrath City]]
	[111] = {
		{ "PortalN", 48.5, 42.0, "Isle of Quel'Danas", "Portal" },
		{ "PortalH", 56.8, 48.9, "Orgrimmar", "Portal" },
		{ "PortalA", 57.2, 48.3, "Stormwind", "Portal" },
	},

	--[[Tol Barad Peninsula]]
	[245] = {
		{ "PortalH", 56.3, 79.7, "Orgrimmar", "Portal" },
		{ "PortalA", 75.3, 58.8, "Stormwind", "Portal" },
	},

	----------------------------------------------------------------------
	--	Wrath Of The Lich King
	----------------------------------------------------------------------

	--[[Borean Tundra]]
	[114] = {
		{ "PortalN", 78.9, 53.7, "Boat to Moa'ki Harbor, Dragonblight" },
	},

	--[[Dragonblight]]
	[115] = {
		{ "PortalN", 49.6, 78.4, "Boat to Kamagua, Howling Fjord" },
		{ "PortalN", 47.9, 78.7, "Boat to Unu'pe, Borean Tundra" },
	},

	--[[Howling Fjord]]
	[117] = {
		{ "PortalN", 23.5, 57.8, "Boat to Moa'ki Harbor, Dragonblight" },
	},

	--[[Dalaran]]
	[125] = {
		{ "PortalA", 40.1, 62.8, "Stormwind", "Portal" },
		{ "PortalH", 55.3, 25.4, "Orgrimmar", "Portal" },
	},

	----------------------------------------------------------------------
	--	Cataclysm
	----------------------------------------------------------------------

	----------------------------------------------------------------------
	--	Mists of Pandaria
	----------------------------------------------------------------------

	--[[Shrine of Two Moons]]
	[392] = {
		{ "PortalH", 73.3, 42.8, "Orgrimmar", "Portal" },
	},

	--[[Shrine of Seven Stars]]
	[394] = {
		{ "PortalA", 71.6, 36.0, "Stormwind", "Portal" },
	},

	----------------------------------------------------------------------
	--	Warlords of Draenor
	----------------------------------------------------------------------

	--[[Stormshield]]
	[622] = {
		{ "PortalA", 60.8, 38.0, "Stormwind", "Portal" },
		{ "PortalA", 36.4, 41.1, "Lion's Watch", "Portal", 0, 38445 },
	},

	--[[Warspear]]
	[624] = {
		{ "PortalH", 60.6, 51.6, "Orgrimmar", "Portal" },
		{ "PortalH", 53.0, 43.9, "Vol'mar", "Portal", 0, 37935 },
	},

	----------------------------------------------------------------------
	--	Legion
	----------------------------------------------------------------------

	--[[Dalaran]]
	[627] = {
		{ "PortalA", 39.6, 63.2, "Stormwind", "Portal" },
		{ "PortalH", 55.2, 23.9, "Orgrimmar", "Portal" },
	},

	--[[Felsoul Hold]]
	[682] = {
		{ "PortalN", 53.6, 36.8, "Shal'Aran", "Portal", 0, 41575 },
	},

	--[[Shattered Locus]]
	[684] = {
		{ "PortalN", 40.9, 13.7, "Shal'Aran", "Portal", 0, 42230 },
	},

	--[[Suramar]]
	[680] = {
		{ "PortalN", 21.6, 28.5, "Falanaar", "Portal", 0, 42230 },
		{ "PortalN", 39.7, 76.2, "Felsoul Hold", "Portal", 0, 41575 },
		{ "PortalN", 30.8, 11.0, "Moon Guard Stronghold", "Portal", 0, 43808 },
		{ "PortalN", 43.7, 79.2, "Lunastre Estate", "Portal", 0, 43811 },
		{ "PortalN", 36.1, 47.2, "Ruins of Elune'eth", "Portal", 0, 40956 },
		{ "PortalN", 52.0, 78.8, "Evermoon Terrace", "Portal", 0, 42889 },
		{ "PortalN", 43.4, 60.6, "Sanctum of Order", "Portal", 0, 43813 },
		{ "PortalN", 42.0, 35.2, "Tel'anor", "Portal", 0, 43809 },
		{ "PortalN", 64.0, 60.4, "Twilight Vineyards", "Portal", 0, 44084 },
		{ "PortalN", 54.5, 69.4, "Astravar Harbor", "Portal", 0, 44740 },
		{ "PortalN", 47.7, 81.4, "The Waning Crescent", "Portal", 0, 42487, 38649 },
	},

	--[[Dungeon: Court of Stars]]
	[761] = {

		{ "Arrow", 42.5, 76.8, "Step 1", "Start here.", 5.5 },
		{ "Arrow", 42.4, 65.2, "Step 2", "Enter this building and go upstairs.", 0.1 },
		{ "Arrow", 41.3, 53.0, "Step 3", "Click the Arcane Beacon then go across the bridge to the left.", 0.7 },
		{ "Arrow", 36.2, 47.1, "Step 4", "Kill the Construct then turn left before the bridge.", 1.1 },
		{ "Arrow", 32.0, 41.2, "Step 5", "Go over this bridge.", 5.9 },
		{ "Arrow", 33.5, 30.8, "Step 6", "Pull Patrol Captain Gerdo here and kill.", 6.1 },
		{ "Arrow", 38.5, 24.5, "Step 7", "Go up these steps.", 4.5 },
		{ "Arrow", 42.6, 26.7, "Step 8", "Enter this building and go up the stairs.", 4.5 },
		{ "Arrow", 46.4, 34.9, "Step 9", "Enter this building and go down the stairs.", 2.7 },
		{ "Arrow", 48.4, 39.7, "Step 10", "Look at the map.  Find and kill 3 Enforcers (yellow dots).|nAfter each Enforcer, wait and kill the Covenant.|n|nThen kill Talixae Flamewreath.", 5.9 },
		{ "Arrow", 60.4, 61.6, "Step 11", "After killing Talixae, talk to Ly'leth Lunastre to get a disguise.", 4.0 },
		{ "Arrow", 64.0, 67.0, "Step 12", "Enter this building and talk to Chatty Rumormongers to get a description of the spy.", 4.0 },
	},

	--[[Dungeon: Court of Stars (The Balconies)]]
	[763] = {
		{ "Arrow", 27.1, 77.8, "Step 13 (1)", "Once identified, kill the spy either here or at the opposite side.|nThen pick up the Arcane Keys.", 2.3 },
		{ "Arrow", 66.7, 18.7, "Step 13 (2)", "Once identified, kill the spy either here or at the opposite side.|nThen pick up the Arcane Keys.", 5.5 },
		{ "Arrow", 60.0, 69.3, "Step 14", "Unlock the Skyward Terrace doors using the Arcane Keys.|nKill Advisor Melandrus.", 4.0 },
	},

	----------------------------------------------------------------------
	--	Battle For Azeroth
	----------------------------------------------------------------------

	--[[Boralus Harbor]]
	[1161] = {
		{ "PortalA", 70.4, 17.7, "Sanctum of the Sages", "Exodar, Ironforge, Nazjatar, Silithus, Stormwind" },
	},

	--[[Dazar'alor (inside)]]
	[1163] = {
		{ "PortalH", 60.5, 70.3, "Hall of Ancient Paths", "Nazjatar, Orgrimmar, Silithus, Silvermoon City, Thunder Bluff" },
	},

	--[[Chamber of Heart]]
	[1473] = {
		{ "PortalN", 50.1, 30.4, "Silithus", "Titan Translocator" },
	},

	----------------------------------------------------------------------
	--	Shadowlands
	----------------------------------------------------------------------

	--[[Oribos]]
	[1670] = {
		{ "PortalH", 20.9, 54.8, "Orgrimmar", "Portal" },
		{ "PortalA", 20.9, 45.9, "Stormwind", "Portal" },
	},

	--[[Korthia]]
	[1961] = {
		{ "PortalN", 64.5, 24.1, "Oribos", "Portal" },
		{ "TaxiN", 49.3, 63.9, "Flayedwing Transporter", "Taxi to Scholar's Den" },
		{ "TaxiN", 60.8, 28.5, "Flayedwing Transporter", "Taxi to Vault of Secrets" },
	},

	--[[Zereth Mortis]]
	[1970] = {
		{ "TaxiN", 34.9, 45.7, "Exile's Hollow", "Sanctuary" },
		{ "TaxiN", 61.9, 58.9, "Synthesis Forge", "Pet Crafting" },
		{ "TaxiN", 68.5, 30.2, "Protoform Repository", "Mount Crafting" },
	},

	----------------------------------------------------------------------
	--	Dragonflight
	----------------------------------------------------------------------

	--[[Ohn'ahran Plains]]
	[2023] = {
		{ "PortalN", 18.5, 52.1, "Emerald Dream", "Portal" },
	},

	--[[Valdrakken]]
	[2112] = {
		{ "PortalN", 53.9, 55.0, "Valdrakken Portals" },
		{ "PortalH", 56.6, 38.4, "Orgrimmar", "Portal" },
		{ "PortalA", 59.7, 41.8, "Stormwind", "Portal" },
		{ "PortalN", 62.6, 57.3, "Emerald Dream", "Portal" },
		{ "PortalN", 26.1, 40.9, "Badlands", "Portal" },
	},

	--[[Emerald Dream]]
	[2200] = {
		{ "PortalN", 72.8, 52.9, "Ohn'ahran Plains", "Portal" },
	},

	--[[Amirdrassil]]
	[2239] = {
		{ "PortalN", 89.3, 38.7, "Emerald Dream", "Portal" },
	},
}

local frame = CreateFrame("FRAME")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
	-- Add Caverns of Time portal to Shattrath if reputation with Keepers of Time is revered or higher
	local _, _, standingID = GetFactionInfoByID(989)
	if standingID and standingID >= 7 then
		C["ExtraMapIcons"][111] = C["ExtraMapIcons"][111] or {}
		tinsert(C["ExtraMapIcons"][111], { "PortalN", 74.7, 31.4, "Caverns of Time", "Portal from Zephyr" })
	end
end)

-------------------------------------------------------------------------

-- Get table from file
local PinData = C["ExtraMapIcons"]

-- Create table
local EMIMix = CreateFromMixins(MapCanvasDataProviderMixin)

function EMIMix:RefreshAllData()
	-- Remove all pins created by Leatrix Maps
	self:GetMap():RemoveAllPinsByTemplate("ExtraMapIconsGlobalPinTemplate")

	-- Show new pins if option is enabled
	do
		-- Make new pins
		local pMapID = WorldMapFrame.mapID
		if PinData[pMapID] then
			local count = #PinData[pMapID]
			for i = 1, count do
				-- Do nothing if pinInfo has no entry for zone we are looking at
				local pinInfo = PinData[pMapID][i]
				if not pinInfo then
					return nil
				end

				local myPOI = {}

				-- Portal - Horde
				if pinInfo[1] == "PortalH" and K.Faction == "Horde" then
					myPOI["atlasName"] = "TaxiNode_Continent_Horde"
					if pinInfo[7] and not C_QuestLog.IsQuestFlaggedCompleted(pinInfo[7]) then
						myPOI["atlasName"] = nil
					end -- Do nothing if first quest not completed
					if pinInfo[8] and C_QuestLog.IsQuestFlaggedCompleted(pinInfo[8]) then
						myPOI["atlasName"] = nil
					end -- Do nothing if second quest is completed

				-- Portal - Alliance
				elseif pinInfo[1] == "PortalA" and K.Faction == "Alliance" then
					myPOI["atlasName"] = "TaxiNode_Continent_Alliance"
					if pinInfo[7] and not C_QuestLog.IsQuestFlaggedCompleted(pinInfo[7]) then
						myPOI["atlasName"] = nil
					end -- Do nothing if first quest not completed
					if pinInfo[8] and C_QuestLog.IsQuestFlaggedCompleted(pinInfo[8]) then
						myPOI["atlasName"] = nil
					end -- Do nothing if second quest is completed

				-- Portal - Neutral
				elseif pinInfo[1] == "PortalN" then
					myPOI["atlasName"] = "TaxiNode_Continent_Neutral"
					if pinInfo[7] and not C_QuestLog.IsQuestFlaggedCompleted(pinInfo[7]) then
						myPOI["atlasName"] = nil
					end -- Do nothing if first quest not completed
					if pinInfo[8] and C_QuestLog.IsQuestFlaggedCompleted(pinInfo[8]) then
						myPOI["atlasName"] = nil
					end -- Do nothing if second quest is completed

				-- Chest
				elseif pinInfo[1] == "Chest" then
					myPOI["atlasName"] = "ChallengeMode-icon-chest"

				-- Arrow
				elseif pinInfo[1] == "Arrow" then
					myPOI["atlasName"] = "Garr_LevelUpgradeArrow"
					myPOI["journalID"] = pinInfo[7]

				-- Taxi - Neutral (as used in Korthia for Flayedwing Transporter)
				elseif pinInfo[1] == "TaxiN" then
					myPOI["atlasName"] = "warfront-neutralhero-gold"
				end

				-- Mandatory fields
				myPOI["position"] = CreateVector2D(pinInfo[2] / 100, pinInfo[3] / 100)
				myPOI["name"] = pinInfo[4]
				myPOI["description"] = pinInfo[5]

				-- Acquire the pin if it has a texture
				if myPOI["atlasName"] then
					local pin = self:GetMap():AcquirePin("ExtraMapIconsGlobalPinTemplate", myPOI)
					pin.Texture:SetRotation(0)
					pin.HighlightTexture:SetRotation(0)
					if pinInfo[1] == "Arrow" then
						pin.Texture:SetRotation(pinInfo[6])
						pin.HighlightTexture:SetRotation(pinInfo[6])
					elseif pinInfo[1] == "TaxiN" then
						pin:SetSize(28, 28)
						pin.Texture:SetSize(28, 28)
						pin.HighlightTexture:SetSize(28, 28)
					end
				end
			end
		end
	end
end

_G.ExtraMapIconsGlobalPinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE")
_G.ExtraMapIconsGlobalPinMixin.SetPassThroughButtons = function() end

function ExtraMapIconsGlobalPinMixin:OnAcquired(myInfo)
	BaseMapPoiPinMixin.OnAcquired(self, myInfo)
	self.journalID = myInfo.journalID
end

WorldMapFrame:AddDataProvider(EMIMix)
