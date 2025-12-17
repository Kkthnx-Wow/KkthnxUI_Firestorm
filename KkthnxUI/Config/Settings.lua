local K, C = KkthnxUI[1], KkthnxUI[2]

-- ============================================================================
-- DATABASE ENGINE
-- ============================================================================
-- This is the heart of the new database system. It handles profile management,
-- merging defaults, and saving per-character settings.
-- ============================================================================

local Database = {}
K.Database = Database

local type = type
local pairs = pairs
local next = next
local setmetatable = setmetatable
local time = time
local strsplit = strsplit

-- Convenience locals
local DB

-- Metadata keys that should not be treated as config groups
local META_GROUP_KEYS = {
	LastModified = true,
	CreatedAt = true,
	CreatedBy = true,
	ImportedAt = true,
	ImportedBy = true,
	ImportedFrom = true,
	ResetAt = true,
	ResetBy = true,
	RenamedFrom = true,
	RenamedAt = true,
	LastSwitched = true,
	SwitchedFrom = true,
}

-- Core function to ensure the DB exists
local function EnsureRoot()
	KkthnxUIDB = KkthnxUIDB or {}
	DB = KkthnxUIDB

	DB.Global = DB.Global or {}
	DB.ProfileKeys = DB.ProfileKeys or {}
	DB.Profiles = DB.Profiles or {}

	local Global = DB.Global

	-- Move legacy top-level persistent data into Global on first run
	if DB.Gold and not Global.Gold then
		Global.Gold = DB.Gold
		DB.Gold = nil
	end

	if DB.ChatHistory and not Global.ChatHistory then
		Global.ChatHistory = DB.ChatHistory
		DB.ChatHistory = nil
	end

	if DB.KeystoneInfo and not Global.KeystoneInfo then
		Global.KeystoneInfo = DB.KeystoneInfo
		DB.KeystoneInfo = nil
	end

	if DB.ProfilePortraits and not Global.ProfilePortraits then
		Global.ProfilePortraits = DB.ProfilePortraits
		DB.ProfilePortraits = nil
	end

	if DB.ShowSlots ~= nil and Global.ShowSlots == nil then
		Global.ShowSlots = DB.ShowSlots
		DB.ShowSlots = nil
	end

	if DB.DisabledAddOns and not Global.DisabledAddOns then
		Global.DisabledAddOns = DB.DisabledAddOns
		DB.DisabledAddOns = nil
	end

	if DB.ChangelogVersion and not Global.ChangelogVersion then
		Global.ChangelogVersion = DB.ChangelogVersion
		DB.ChangelogVersion = nil
	end

	if DB.ChangelogHighlightLatest ~= nil and Global.ChangelogHighlightLatest == nil then
		Global.ChangelogHighlightLatest = DB.ChangelogHighlightLatest
		DB.ChangelogHighlightLatest = nil
	end

	if DB.DetectedVersion and not Global.DetectedVersion then
		Global.DetectedVersion = DB.DetectedVersion
		DB.DetectedVersion = nil
	end

	Global.Gold = Global.Gold or {}
	Global.ChatHistory = Global.ChatHistory or {}
	Global.KeystoneInfo = Global.KeystoneInfo or {}
	Global.ProfilePortraits = Global.ProfilePortraits or {}
	Global.Characters = Global.Characters or {}
	Global.DisabledAddOns = Global.DisabledAddOns or {}
	Global.ShowSlots = Global.ShowSlots or false

	-- User Key for per-character data
	K.UserKey = K.UserKey or (K.Name .. " - " .. K.Realm)

	if not Global.Characters[K.UserKey] then
		Global.Characters[K.UserKey] = {
			InstallComplete = false,
			Tracking = { PvP = {}, PvE = {} },
			-- Default structures for complex modules
			AuraWatchList = {
				Switcher = {},
				IgnoreSpells = {},
			},
		}
	end

	-- Double check AuraWatchList exists (for older saves)
	if not Global.Characters[K.UserKey].AuraWatchList then
		Global.Characters[K.UserKey].AuraWatchList = { Switcher = {}, IgnoreSpells = {} }
	end
end

function Database:GetProfile()
	EnsureRoot()

	-- ISOLATION LOGIC: If this character has no profile key, give them a unique one.
	-- This ensures new alts get fresh settings by default.
	if not DB.ProfileKeys[K.UserKey] then
		DB.ProfileKeys[K.UserKey] = K.UserKey
	end

	local key = DB.ProfileKeys[K.UserKey]

	-- Create profile if missing (empty table = 100% defaults)
	if not DB.Profiles[key] then
		DB.Profiles[key] = {}
	end

	K.ActiveProfile = key
	return DB.Profiles[key]
end

function Database:GetCurrentProfileName()
	EnsureRoot()
	local profile = self:GetProfile()
	return K.ActiveProfile
end

function Database:GetCurrentProfileTable()
	EnsureRoot()
	local profileName = self:GetCurrentProfileName()
	return DB.Profiles[profileName], profileName
end

function Database:SetCurrentProfile(profileName)
	if not profileName or profileName == "" then
		return
	end

	EnsureRoot()

	DB.Profiles[profileName] = DB.Profiles[profileName] or {}
	DB.ProfileKeys[K.UserKey] = profileName
	K.ActiveProfile = profileName
end

-- Merges Defaults + User Profile into 'C'
local function MergeConfig(defaults, profile, target)
	-- Note: Defaults are already in 'C' from the pre-population at the end of this file.
	-- This function only needs to apply saved profile overrides.

	-- Apply User Profile Overrides
	if profile then
		for group, options in pairs(profile) do
			if not META_GROUP_KEYS[group] and target[group] and type(options) == "table" then
				for key, value in pairs(options) do
					target[group][key] = value
				end
			end
		end
	end

	-- Apply metatables so missing keys fall back to defaults
	for group, defaults in pairs(defaults) do
		if type(defaults) == "table" and type(target[group]) == "table" then
			setmetatable(target[group], { __index = defaults })
		end
	end
end

-- Migration from old Settings/Variables layout into Profiles/Global.*
function Database:Migrate()
	EnsureRoot()
	local Global = DB.Global

	if Global.Migrated then
		return
	end

	-- 1. Try to create an imported profile from the old per-character settings
	if DB.Settings then
		local oldSettings = DB.Settings[K.Realm] and DB.Settings[K.Realm][K.Name]
		local oldVariables = DB.Variables and DB.Variables[K.Realm] and DB.Variables[K.Realm][K.Name]

		if oldSettings then
			local profileName = K.Name .. " (Import)"
			DB.Profiles[profileName] = K.CopyTable(oldSettings)

			-- Merge old Variables (Movers, etc) into the new Profile
			if oldVariables then
				if oldVariables.Mover then
					DB.Profiles[profileName].Movers = K.CopyTable(oldVariables.Mover)
				end

				-- World map reveal flag -> WorldMap.RevealWorldMap
				if oldVariables.RevealWorldMap ~= nil then
					DB.Profiles[profileName].WorldMap = DB.Profiles[profileName].WorldMap or {}
					DB.Profiles[profileName].WorldMap.RevealWorldMap = oldVariables.RevealWorldMap and true or false
				end

				-- Automation.AutoQuest flag
				if oldVariables.AutoQuest ~= nil then
					DB.Profiles[profileName].Automation = DB.Profiles[profileName].Automation or {}
					DB.Profiles[profileName].Automation.AutoQuest = oldVariables.AutoQuest and true or false
				end

				-- Per-profile AuraWatch mover positions
				if oldVariables.AuraWatchMover then
					DB.Profiles[profileName].AuraWatchMover = K.CopyTable(oldVariables.AuraWatchMover)
				end
			end

			-- Track per-character metadata
			local charMeta = Global.Characters[K.UserKey] or {}
			if oldVariables then
				if oldVariables.Tracking then
					charMeta.Tracking = K.CopyTable(oldVariables.Tracking)
				end
				if oldVariables.InstallComplete ~= nil then
					charMeta.InstallComplete = oldVariables.InstallComplete and true or false
				end
			end
			Global.Characters[K.UserKey] = charMeta

			-- Link this character to the imported profile
			DB.ProfileKeys[K.UserKey] = profileName

			print("KkthnxUI: Migration successful. Profile '" .. profileName .. "' created.")
		end
	end

	-- 2. Mark as migrated so this doesn't run again
	Global.Migrated = true
end

function Database:Initialize()
	EnsureRoot()

	-- Run one-time migration from legacy layout
	self:Migrate()

	-- Get or create the active profile
	local profile = self:GetProfile()

	-- Ensure K.Defaults exists (populated below in this file)
	K.Defaults = K.Defaults or {}

	-- Merge everything into 'C' (The runtime config table)
	MergeConfig(K.Defaults, profile, C)

	-- Fire a callback for modules waiting on DB
	if K.OnDatabaseLoaded then
		K:OnDatabaseLoaded()
	end
end

-- Helper to save a setting
function Database:Set(group, option, value)
	local profile = self:GetProfile()

	if not profile[group] then
		profile[group] = {}
	end

	-- If value matches default, nil it out to save space
	local default = K.Defaults[group] and K.Defaults[group][option]
	if value == default then
		profile[group][option] = nil
		-- Clean up empty groups
		if not next(profile[group]) then
			profile[group] = nil
		end
	else
		profile[group][option] = value
	end

	-- Update Runtime C immediately
	if C[group] then
		C[group][option] = value
	end

	profile.LastModified = time()
end

-- Path-based helper for GUI and modules to write into the active profile.
-- Expects paths like "Group.Option" (e.g., "WorldMap.RevealWorldMap").
function Database:SetConfigPath(path, value)
	if not path or type(path) ~= "string" then
		return
	end

	EnsureRoot()
	local profile, profileName = self:GetCurrentProfileTable()
	if not profile then
		profile = {}
		DB.Profiles[profileName] = profile
	end

	local keys = { strsplit(".", path) }
	if #keys < 2 then
		return
	end

	local group = keys[1]
	local option = keys[2]

	-- Update runtime config table (allow options that don't exist in defaults)
	if not C[group] then
		C[group] = {}
	end
	C[group][option] = value

	-- Ensure profile group container
	profile[group] = profile[group] or {}
	local groupTable = profile[group]

	local defaults = (K.Defaults and K.Defaults[group]) or {}
	local defaultValue = defaults[option]

	if value == defaultValue then
		-- Value matches default, do not store in profile
		groupTable[option] = nil
	else
		groupTable[option] = value
	end

	-- Clean empty group tables
	if not next(groupTable) then
		profile[group] = nil
	end

	-- Touch metadata
	profile.LastModified = time()
end

-- Public helper used by Profile switching
function Database:ApplyCurrentProfile()
	local profileTable, profileName = self:GetCurrentProfileTable()
	K.Defaults = K.Defaults or {}
	MergeConfig(K.Defaults, profileTable, C)
	K.ActiveProfile = profileName
end

-- ============================================================================
-- CONFIGURATION DEFAULTS
-- ============================================================================
-- All default settings are defined here. The Database engine above will
-- merge these with saved profile data to populate the runtime C table.
-- ============================================================================

K.Defaults = K.Defaults or {}
local Defaults = K.Defaults

-- Actionbar
Defaults["ActionBar"] = {
	Enable = true,
	Hotkeys = true,
	Macro = true,
	Grid = true,
	Cooldown = true,
	MmssTH = 60,
	TenthTH = 3,
	OverrideWA = false,
	MicroMenu = true,
	FadeMicroMenu = false,
	ShowStance = true,
	EquipColor = false,
	KeyDown = true,
	ButtonLock = true,
	VehButtonSize = 34,

	Bar1 = true,
	Bar1Flyout = 1,
	Bar1Size = 38,
	Bar1Font = 12,
	Bar1Num = 12,
	Bar1PerRow = 12,
	Bar1Fade = false,

	Bar2 = true,
	Bar2Flyout = 1,
	Bar2Size = 38,
	Bar2Font = 12,
	Bar2Num = 12,
	Bar2PerRow = 12,
	Bar2Fade = false,

	Bar3 = true,
	Bar3Flyout = 1,
	Bar3Size = 38,
	Bar3Font = 12,
	Bar3Num = 12,
	Bar3PerRow = 12,
	Bar3Fade = false,

	Bar4 = true,
	Bar4Flyout = 3,
	Bar4Size = 38,
	Bar4Font = 12,
	Bar4Num = 12,
	Bar4PerRow = 1,
	Bar4Fade = true,

	Bar5 = true,
	Bar5Flyout = 3,
	Bar5Size = 38,
	Bar5Font = 12,
	Bar5Num = 12,
	Bar5PerRow = 1,
	Bar5Fade = false,

	BarPetSize = 28,
	BarPetFont = 12,
	BarPetPerRow = 10,
	BarPetFade = false,

	BarStanceSize = 30,
	BarStanceFont = 12,
	BarStancePerRow = 10,
	BarStanceFade = false,

	Bar6 = false,
	Bar6Flyout = 1,
	Bar6Size = 34,
	Bar6Font = 12,
	Bar6Num = 12,
	Bar6PerRow = 12,
	Bar6Fade = false,

	Bar7 = false,
	Bar7Flyout = 1,
	Bar7Size = 34,
	Bar7Font = 12,
	Bar7Num = 12,
	Bar7PerRow = 12,
	Bar7Fade = false,

	Bar8 = false,
	Bar8Flyout = 1,
	Bar8Size = 34,
	Bar8Font = 12,
	Bar8Num = 12,
	Bar8PerRow = 12,
	Bar8Fade = false,

	BarFadeGlobal = true,
	BarFadeAlpha = 0.1,
	BarFadeDelay = 0,
	BarFadeCombat = true,
	BarFadeTarget = true,
	BarFadeCasting = true,
	BarFadeHealth = true,
	BarFadeVehicle = true,
}

-- Announcements
Defaults["Announcements"] = {
	AlertInChat = false,
	AlertInWild = false,
	KeystoneAlert = false,
	BrokenAlert = false,
	DispellAlert = false,
	HealthAlert = false,
	InstAlertOnly = true,
	InterruptAlert = false,
	ItemAlert = false,
	KillingBlow = false,
	OnlyCompleteRing = false,
	OwnDispell = true,
	OwnInterrupt = true,
	PullCountdown = true,
	PvPEmote = false,
	QuestNotifier = false,
	QuestProgress = false,
	RareAlert = false,
	ResetInstance = true,
	SaySapped = false,
	AlertChannel = 2,
	QuestProgressEveryNth = 1,
	AnnounceWorldQuests = false,
}

-- Automation
Defaults["Automation"] = {
	AutoKeystone = false,
	-- AutoCollapse = false,
	AutoDeclineDuels = false,
	AutoDeclinePetDuels = false,
	AutoGoodbye = false,
	AutoInvite = false,
	AutoPartySync = false,
	AutoQuest = false,
	AutoRelease = false,
	AutoResurrect = false,
	AutoResurrectThank = false,
	AutoReward = false,
	AutoScreenshot = false,
	AutoSetRole = false,
	ConfirmCinematicSkip = false,
	AutoSummon = false,
	NoBadBuffs = false,
	WhisperInvite = "inv+",
	WhisperInviteRestriction = true, -- Testing
}

Defaults["Inventory"] = {
	AutoSell = true,
	BagBar = true,
	BagBarMouseover = false,
	BagBarSize = 32,
	BagsBindOnEquip = false,
	BagsItemLevel = false,
	BagsPerRow = 6,
	BagsWidth = 10,
	BankPerRow = 10,
	BankWidth = 12,
	DeleteButton = true,
	Enable = true,
	FilterAOE = true,
	FilterAnima = true,
	FilterAzerite = false,
	FilterCollection = true,
	FilterConsumable = true,
	FilterCustom = true,
	FilterEquipSet = false,
	FilterEquipment = true,
	FilterGoods = false,
	FilterJunk = true,
	FilterLegendary = true,
	FilterLower = true,
	FilterLegacy = false,
	FilterQuest = true,
	FilterStone = true,
	FilterKeystone = true,
	GatherEmpty = false,
	IconSize = 36,
	ItemFilter = true,
	JustBackpack = false,
	PetTrash = true,
	ReverseSort = false,
	ShowNewItem = true,
	SpecialBagsColor = false,
	UpgradeIcon = true,
	iLvlToShow = 1,
	GrowthDirection = 1,
	SortDirection = 2,
	AutoRepair = 2,
	ColorUnusableItems = true,
}

-- Buffs & Debuffs
Defaults["Auras"] = {
	BuffSize = 32,
	BuffsPerRow = 16,
	DebuffSize = 34,
	DebuffsPerRow = 16,
	Enable = true,
	HideBlizBuff = false,
	Reminder = false,
	ReverseBuffs = false,
	ReverseDebuffs = false,
	TotemSize = 32,
	Totems = true,
	VerticalTotems = false,
}

-- Chat
Defaults["Chat"] = {
	Background = true,
	ChatItemLevel = true,
	ChatMenu = true,
	ConfigButton = true,
	CopyButton = true,
	Emojis = false,
	Enable = true,
	Fading = true,
	FadingTimeVisible = 100,
	Freedom = true,
	Height = 170,
	Lock = true,
	LogMax = 0,
	OldChatNames = false,
	RollButton = true,
	Sticky = false,
	WhisperColor = true,
	Width = 400,
	TimestampFormat = 1,
}

-- Datatext
Defaults["DataText"] = {
	Coords = false,
	Friends = false,
	Gold = false,
	Guild = false,
	GuildSortBy = 1,
	GuildSortOrder = true,
	HideText = false,
	IconColor = { 102 / 255, 157 / 255, 255 / 255 },
	Latency = true,
	Location = true,
	Spec = false,
	System = true,
	Time = true,
}

Defaults["AuraWatch"] = {
	Enable = true,
	ClickThrough = false,
	IconScale = 1,
	DeprecatedAuras = false,
}

-- General
Defaults["General"] = {
	AutoScale = true,
	ColorTextures = false,
	MinimapIcon = false,
	MissingTalentAlert = true,
	MoveBlizzardFrames = false,
	NoErrorFrame = false,
	NoTutorialButtons = false,
	TexturesColor = { 1, 1, 1 },
	UIScale = 0.71,
	UseGlobal = false,
	Texture = "KkthnxUI",
	SmoothAmount = 0.25,
	BorderStyle = "KkthnxUI",
	NumberPrefixStyle = 1,
	GlowMode = 3,
	VersionCheck = true,
}

-- Loot
Defaults["Loot"] = {
	AutoConfirm = false,
	AutoGreed = false,
	Enable = true,
	FastLoot = false,
	GroupLoot = true,
}

-- Minimap
Defaults["Minimap"] = {
	Calendar = true,
	EasyVolume = false,
	Enable = true,
	MailPulse = true,
	QueueStatusText = false,
	ShowRecycleBin = true,
	Size = 210,
	RecycleBinPosition = 1,
	LocationText = 3,
}

-- Miscellaneous
Defaults["Misc"] = {
	RaidTool = true,
	RMRune = false,
	DBMCount = "10",
	MarkerBarSize = 22,
	AFKCamera = false,
	AutoBubbles = false,
	ColorPicker = false,
	EnhancedFriends = false,
	EnhancedMail = false,
	ExpRep = true,
	GemEnchantInfo = false,
	HideBanner = false,
	HideBossEmote = false,
	ImprovedStats = false,
	ItemLevel = false,
	MDGuildBest = false,
	MaxCameraZoom = 2.6,
	MuteSounds = true,
	NoTalkingHead = false,
	QuestTool = false,
	QueueTimers = false,
	QueueTimerAudio = true,
	QueueTimerWarning = true,
	QueueTimerHideOtherTimers = true,
	QuickJoin = false,
	QuickMenuList = true,
	ShowWowHeadLinks = false,
	SlotDurability = false,
	TradeTabs = false,
	EasyMarking = false,
	YClassColors = true,
	EasyMarkKey = 1,
	ShowMarkerBar = 4,
}

Defaults["Nameplate"] = {
	ColorByDot = false, -- This is not ready
	DotColor = { 1, 0.5, 0.2 },
	DotSpellList = {
		Spells = {},
	},
	AKSProgress = false,
	AuraSize = 28,
	CastTarget = false,
	CastbarGlow = true,
	ClassIcon = false,
	ColoredTarget = true,
	CustomColor = { 0, 0.8, 0.3 },
	CustomUnitColor = true,
	CustomUnitList = "",
	DPSRevertThreat = false,
	-- Distance = 42,
	Enable = true,
	ExecuteRatio = 0,
	FriendPlate = false,
	FriendlyCC = false,
	FullHealth = false,
	HealthTextSize = 13,
	HostileCC = true,
	InsecureColor = { 1, 0, 0 },
	InsideView = true,
	MaxAuras = 5,
	MinAlpha = 0.6,
	MinScale = 1,
	CVarOnlyNames = false,
	CVarShowNPCs = false,
	NameOnly = true,
	NameTextSize = 13,
	NameplateClassPower = true,
	OffTankColor = { 0.2, 0.7, 0.5 },
	PPGCDTicker = true,
	PPPowerText = true,
	HarmWidth = 200,
	HarmHeight = 62,
	EnemyThru = false,
	FriendlyThru = false,
	HelpWidth = 200,
	HelpHeight = 62,
	PPHeight = 10,
	PPHideOOC = true,
	PPIconSize = 32,
	PPOnFire = false,
	PPPHeight = 8,
	PlateAuras = true,
	PlateHeight = 18,
	PlateWidth = 200,
	PowerUnitList = "",
	QuestIndicator = true,
	SecureColor = { 1, 0, 1 },
	SelectedScale = 1.1,
	ShowPlayerPlate = false,
	Smooth = false,
	TankMode = false,
	TargetColor = { 0, 0.6, 1 },
	TargetIndicatorColor = { 1, 1, 0 },
	TransColor = { 1, 0.8, 0 },
	VerticalSpacing = 0.7,
	AuraFilter = 3,
	TargetIndicator = 4,
	TargetIndicatorTexture = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonBlueArrow",
}

-- Skins
Defaults["Skins"] = {
	Bartender4 = false,
	BigWigs = false,
	BlizzardFrames = true,
	ButtonForge = false,
	ChatBubbleAlpha = 0.9,
	ChatBubbles = true,
	ChocolateBar = false,
	DeadlyBossMods = false,
	Details = false,
	Dominos = false,
	Hekili = false,
	RareScanner = false,
	Skada = false,
	Spy = false,
	TalkingHeadBackdrop = true,
	TellMeWhen = false,
	TitanPanel = false,
	WeakAuras = false,
	ObjectiveFontSize = 12,
	QuestFontSize = 11,
}

-- Tooltip
Defaults["Tooltip"] = {
	ClassColor = false,
	CombatHide = false,
	Cursor = false,
	Enable = true,
	FactionIcon = false,
	HideJunkGuild = true,
	HideRank = true,
	HideRealm = true,
	HideTitle = true,
	Icons = true,
	LFDRole = false,
	MDScore = true,
	ShowIDs = false,
	ShowMount = false,
	SpecLevelByShift = true,
	TargetBy = true,
	CursorMode = 1,
	TipAnchor = 4,
}

-- Unitframe
Defaults["Unitframe"] = {
	AdditionalPower = false,
	AllTextScale = 1, -- Testing
	AutoAttack = true,
	CastClassColor = false,
	CastReactionColor = false,
	CastbarLatency = true,
	ClassResources = true,
	CombatFade = false,
	CombatText = false,
	DebuffHighlight = true,
	Enable = true,
	FCTOverHealing = false,
	GlobalCooldown = true,
	HotsDots = true,
	OnlyShowPlayerDebuff = false,
	Range = true,

	-- Player
	PlayerBuffs = false,
	PlayerBuffsPerRow = 6,
	PlayerCastbar = true,
	PlayerCastbarHeight = 28,
	PlayerCastbarIcon = true,
	PlayerCastbarWidth = 268,
	PlayerDebuffs = false,
	PlayerDebuffsPerRow = 7,
	PlayerHealthHeight = 34,
	PlayerHealthWidth = 200,
	PlayerPowerHeight = 16,

	PvPIndicator = true,
	ResurrectSound = false,
	ShowHealPrediction = true,
	ShowPlayerLevel = true,
	HideMaxPlayerLevel = false,
	Smooth = false,
	Stagger = true,

	SwingBar = false,
	SwingWidth = 274,
	SwingHeight = 14,
	SwingTimer = true,
	OffOnTop = false,

	-- Target
	TargetHealthHeight = 34,
	TargetHealthWidth = 200,
	TargetPowerHeight = 16,
	TargetBuffs = true,
	TargetBuffsPerRow = 7,
	TargetCastbar = true,
	TargetCastbarIcon = true,
	TargetCastbarHeight = 34,
	TargetCastbarWidth = 268,
	TargetDebuffs = true,
	TargetDebuffsPerRow = 6,

	-- Focus
	FocusBuffs = true,
	FocusCastbar = true,
	FocusCastbarHeight = 24,
	FocusCastbarIcon = true,
	FocusCastbarWidth = 208,
	FocusDebuffs = true,
	FocusHealthHeight = 32,
	FocusHealthWidth = 180,
	FocusPowerHeight = 14,

	-- TargetOfTarget
	TargetTargetHealthHeight = 18,
	TargetTargetHealthWidth = 100,
	TargetTargetPowerHeight = 10,
	HideTargetOfTargetLevel = false,
	HideTargetOfTargetName = false,
	HideTargetofTarget = false,

	-- Pet
	PetHealthHeight = 18,
	PetHealthWidth = 100,
	PetPowerHeight = 10,
	HidePetLevel = false,
	HidePetName = false,
	HidePet = false,

	-- FocusTarget
	FocusTargetHealthHeight = 18,
	FocusTargetHealthWidth = 100,
	FocusTargetPowerHeight = 10,
	HideFocusTargetLevel = false,
	HideFocusTargetName = false,
	HideFocusTarget = false,
	HealthbarColor = 1,
	PortraitStyle = 1,
}

Defaults["Party"] = {
	CastbarIcon = false,
	Castbars = false,
	Enable = true,
	HealthHeight = 22,
	HealthWidth = 150,
	PortraitTimers = false,
	PowerHeight = 12,
	ShowBuffs = false,
	ShowHealPrediction = true,
	ShowPartySolo = false,
	ShowPet = false,
	ShowPlayer = true,
	Smooth = false,
	TargetHighlight = false,
	HealthbarColor = 1,
}

-- SimpleParty (Raid-style compact party frames)
Defaults["SimpleParty"] = {
	Enable = false,
	HealthbarColor = 1,
	HealthHeight = 44,
	HealthWidth = 70,
	HorizonParty = false,
	ManabarShow = false,
	PowerBarShow = false,
	PowerBarHeight = 5,
	RaidBuffsStyle = 2,
	RaidBuffs = 1,
	ShowHealPrediction = true,
	Smooth = false,
	TargetHighlight = false,
	AuraTrackIcons = true,
	AuraTrackSpellTextures = true,
	AuraTrackThickness = 5,
	DebuffWatch = true,
	DebuffWatchDefault = true,
}

Defaults["Boss"] = {
	CastbarIcon = true,
	Castbars = true,
	Enable = true,
	Smooth = false,
	HealthHeight = 24,
	HealthWidth = 150,
	PowerHeight = 12,
	YOffset = 54,
	HealthbarColor = 1,
}

Defaults["Arena"] = {
	CastbarIcon = true,
	Castbars = true,
	Enable = true,
	Smooth = false,
	HealthHeight = 20,
	HealthWidth = 134,
	PowerHeight = 10,
	YOffset = 54,
	HealthbarColor = 1,
}

-- Raidframe
Defaults["Raid"] = {
	DebuffWatch = true,
	DebuffWatchDefault = true,
	DesaturateBuffs = false,
	Enable = true,
	Height = 44,
	HorizonRaid = false,
	MainTankFrames = true,
	PowerBarShow = false,
	ManabarShow = false,
	NumGroups = 6,
	RaidUtility = true,
	ReverseRaid = false,
	ShowHealPrediction = true,
	ShowNotHereTimer = true,
	ShowRaidSolo = false,
	ShowTeamIndex = false,
	Smooth = false,
	TargetHighlight = false,
	Width = 70,
	RaidBuffsStyle = 2,
	RaidBuffs = 1,
	AuraTrack = true,
	AuraTrackIcons = true,
	AuraTrackSpellTextures = true,
	AuraTrackThickness = 5,
	HealthbarColor = 1,
	HealthFormat = 1,
	UseRaidForParty = false,
}

-- Worldmap
Defaults["WorldMap"] = {
	AlphaWhenMoving = 0.35,
	Coordinates = true,
	FadeWhenMoving = true,
	MapRevealGlow = true,
	SmallWorldMap = true,
	-- Waypoint options
	AutoOpenWaypoint = true,
}

-- ============================================================================
-- CRITICAL FIX: Pre-populate C immediately during file loading
-- ============================================================================
-- This ensures 'C' has data immediately during file loading (for Border.lua, etc.)
-- The Database will overwrite/merge this again at PLAYER_LOGIN with saved variables.
-- This prevents nil errors when files like Border.lua try to access C["General"]
-- during the loading screen, before PLAYER_LOGIN fires.
-- ============================================================================
do
	for group, options in pairs(Defaults) do
		if type(options) == "table" then
			C[group] = C[group] or {}
			for key, value in pairs(options) do
				C[group][key] = value
			end
		else
			C[group] = options
		end
	end
end
