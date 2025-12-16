local AddOnName, Engine = ...

-- Lua 5.1 Caching (Performance Critical)
local _G = _G
local assert, type, unpack, select, tostring, tonumber = assert, type, unpack, select, tostring, tonumber
local next, pairs, ipairs, pcall = next, pairs, ipairs, pcall
local string_format, string_lower = string.format, string.lower
local bit_band, bit_bor = bit.band, bit.bor
local tinsert = table.insert
local max, min = math.max, math.min

-- WoW API Caching
local CreateFrame = CreateFrame
local GetBuildInfo = GetBuildInfo
local GetLocale = GetLocale
local GetPhysicalScreenSize = GetPhysicalScreenSize
local GetRealmName = GetRealmName
local InCombatLockdown = InCombatLockdown
local LibStub = LibStub
local SetCVar = SetCVar
local UIParent = UIParent
local UnitClass = UnitClass
local UnitFactionGroup = UnitFactionGroup
local UnitGUID = UnitGUID
local UnitLevel = UnitLevel
local UnitName = UnitName
local UnitRace = UnitRace
local UnitSex = UnitSex
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo

-- C_AddOns API
local C_AddOns = C_AddOns
local GetAddOnEnableState = C_AddOns.GetAddOnEnableState
local GetAddOnInfo = C_AddOns.GetAddOnInfo
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata
local GetNumAddOns = C_AddOns.GetNumAddOns

-- WoW Constants
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local BAG_ITEM_QUALITY_COLORS = BAG_ITEM_QUALITY_COLORS
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE

-- Combat Log Flags
local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
local COMBATLOG_OBJECT_AFFILIATION_PARTY = COMBATLOG_OBJECT_AFFILIATION_PARTY
local COMBATLOG_OBJECT_AFFILIATION_RAID = COMBATLOG_OBJECT_AFFILIATION_RAID
local COMBATLOG_OBJECT_CONTROL_PLAYER = COMBATLOG_OBJECT_CONTROL_PLAYER
local COMBATLOG_OBJECT_REACTION_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY
local COMBATLOG_OBJECT_TYPE_PET = COMBATLOG_OBJECT_TYPE_PET
local Enum = Enum

-- Initialize Engine Tables
Engine[1] = {} -- K: Core Functions
Engine[2] = {} -- C: Config
Engine[3] = {} -- L: Locales

local K, C, L = Engine[1], Engine[2], Engine[3]

--------------------------------------------------------------------------------
-- Library Initialization
--------------------------------------------------------------------------------
-- Note: Using 'or nil' is technically redundant but harmless for clarity.
K.LibEasyMenu = LibStub("LibEasyMenu-1.0-KkthnxUI", true)
K.LibBase64 = LibStub("LibBase64-1.0-KkthnxUI", true)
K.LibActionButton = LibStub("LibActionButton-1.0-KkthnxUI", true)
K.LibDeflate = LibStub("LibDeflate-KkthnxUI", true)
K.LibSharedMedia = LibStub("LibSharedMedia-3.0", true)
K.LibSerialize = LibStub("LibSerialize-KkthnxUI", true)
K.LibCustomGlow = LibStub("LibCustomGlow-1.0-KkthnxUI", true)
K.LibUnfit = LibStub("LibUnfit-1.0-KkthnxUI", true)

-- These references rely on load order in the TOC.
-- Ensure cargBags and oUF are loaded BEFORE KkthnxUI if they are embedded libraries.
K.cargBags = Engine.cargBags
K.oUF = Engine.oUF

--------------------------------------------------------------------------------
-- AddOn Metadata
--------------------------------------------------------------------------------
K.Title = GetAddOnMetadata(AddOnName, "Title")
K.Version = GetAddOnMetadata(AddOnName, "Version")
K.Noop = function() end

--------------------------------------------------------------------------------
-- Player & Realm Information
--------------------------------------------------------------------------------
K.Name = UnitName("player")
K.Class = select(2, UnitClass("player"))
K.Race = UnitRace("player")
K.Faction = UnitFactionGroup("player")
K.Level = UnitLevel("player")
K.Client = GetLocale()
K.Realm = GetRealmName()
K.Sex = UnitSex("player")
K.GUID = UnitGUID("player")

--------------------------------------------------------------------------------
-- Screen & Graphics Information
--------------------------------------------------------------------------------
K.ScreenWidth, K.ScreenHeight = GetPhysicalScreenSize()
K.Resolution = string_format("%dx%d", K.ScreenWidth, K.ScreenHeight)

--------------------------------------------------------------------------------
-- UI Elements & Assets
--------------------------------------------------------------------------------
K.TexCoords = { 0.08, 0.92, 0.08, 0.92 }
K.EasyMenu = CreateFrame("Frame", "KKUI_EasyMenu", UIParent, "UIDropDownMenuTemplate")
K.ScanTooltip = CreateFrame("GameTooltip", "KKUI_ScanTooltip", UIParent, "GameTooltipTemplate")
K.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")

--------------------------------------------------------------------------------
-- WoW Build Information
--------------------------------------------------------------------------------
K.WowPatch, K.WowBuild, K.WowRelease, K.TocVersion = GetBuildInfo()
K.WowBuild = tonumber(K.WowBuild)
K.IsNewPatch = K.WowBuild >= 110200 -- Patch 11.2.0+

--------------------------------------------------------------------------------
-- Colors & Fonts
--------------------------------------------------------------------------------
K.GreyColor = "|CFFC0C0C0"
K.InfoColor = "|CFF5C8BCF"
K.InfoColorTint = "|CFF93BAFF"
K.SystemColor = "|CFFFFCC66"

K.MediaFolder = "Interface\\AddOns\\KkthnxUI\\Media\\"

-- Ensure Fonts exist before querying, though usually safe in WoW environment
if _G.KkthnxUIFont then
	K.UIFont = "KkthnxUIFont"
	K.UIFontSize = select(2, _G.KkthnxUIFont:GetFont())
	K.UIFontStyle = select(3, _G.KkthnxUIFont:GetFont())
end

if _G.KkthnxUIFontOutline then
	K.UIFontOutline = "KkthnxUIFontOutline"
	K.UIFontSizeOutline = select(2, _G.KkthnxUIFontOutline:GetFont())
	K.UIFontStyleOutline = select(3, _G.KkthnxUIFontOutline:GetFont())
end

K.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t "
K.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:410|t "
K.ScrollButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t "

--------------------------------------------------------------------------------
-- Data Lists & Flags
--------------------------------------------------------------------------------
K.ClassList = {}
K.ClassColors = {}
K.QualityColors = {}
K.AddOns = {}
K.AddOnVersion = {}

K.PartyPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)
K.RaidPetFlags = bit_bor(COMBATLOG_OBJECT_AFFILIATION_RAID, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)

function K.IsMyPet(flags)
	return bit_band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
end

-- Populate Class Lists
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	K.ClassList[v] = k
end
for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
	K.ClassList[v] = k
end

-- Populate Class Colors
local colors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
for class, value in pairs(colors) do
	K.ClassColors[class] = {
		r = value.r,
		g = value.g,
		b = value.b,
		colorStr = value.colorStr,
	}
end

-- Cache Player Class Color
if K.ClassColors[K.Class] then
	K.r, K.g, K.b = K.ClassColors[K.Class].r, K.ClassColors[K.Class].g, K.ClassColors[K.Class].b
	K.MyClassColor = string_format("|cff%02x%02x%02x", K.r * 255, K.g * 255, K.b * 255)
end

-- Populate Item Quality Colors
local qualityColors = BAG_ITEM_QUALITY_COLORS
for index, value in pairs(qualityColors) do
	K.QualityColors[index] = { r = value.r, g = value.g, b = value.b }
end
K.QualityColors[-1] = { r = 1, g = 1, b = 1 } -- Fallback
K.QualityColors[Enum.ItemQuality.Poor] = { r = 0.61, g = 0.61, b = 0.61 }
K.QualityColors[Enum.ItemQuality.Common] = { r = 1, g = 1, b = 1 }

--------------------------------------------------------------------------------
-- Event Handling System
--------------------------------------------------------------------------------
local eventsFrame = CreateFrame("Frame")
local events = {}

local function SafeDispatch(func, event, ...)
	local ok, err = pcall(func, event, ...)
	if not ok then
		-- Standardize error output
		_G.geterrorhandler()(string_format("KkthnxUI: %s\nEvent: %s", tostring(err), tostring(event)))
	end
end

eventsFrame:SetScript("OnEvent", function(self, event, ...)
	local funcs = events[event]
	if not funcs then
		return
	end

	for func in pairs(funcs) do
		if event == "COMBAT_LOG_EVENT_UNFILTERED" then
			SafeDispatch(func, event, CombatLogGetCurrentEventInfo())
		else
			SafeDispatch(func, event, ...)
		end
	end
end)

function K:RegisterEvent(event, func, unit1, unit2)
	if event == "CLEU" then
		event = "COMBAT_LOG_EVENT_UNFILTERED"
	end

	if not events[event] then
		-- LEAK PREVENTION: Use weak keys so functions aren't held in memory if the module is destroyed
		-- events[event] = setmetatable({}, { __mode = "k" })
		events[event] = {}
		if unit1 then
			eventsFrame:RegisterUnitEvent(event, unit1, unit2)
		else
			eventsFrame:RegisterEvent(event)
		end
	end

	if not func or type(func) ~= "function" then
		print(string_format("|cffff0000KkthnxUI Error:|r Invalid callback for event '%s'.", tostring(event)))
		return
	end

	events[event][func] = true
end

function K:UnregisterEvent(event, func)
	if event == "CLEU" then
		event = "COMBAT_LOG_EVENT_UNFILTERED"
	end

	local funcs = events[event]
	if funcs and funcs[func] then
		funcs[func] = nil
		if not next(funcs) then
			events[event] = nil
			eventsFrame:UnregisterEvent(event)
		end
	end
end

--------------------------------------------------------------------------------
-- Module System
--------------------------------------------------------------------------------
local modules = {}
local modulesQueue = {}

function K:NewModule(name)
	if modules[name] then
		-- Using internal print to avoid confusion
		print(string_format("|cffff9900KkthnxUI:|r Module '%s' already registered.", name))
		return modules[name]
	end

	local module = {}
	module.name = name
	module.Enabled = false
	modules[name] = module
	tinsert(modulesQueue, module)
	return module
end

function K:GetModule(name)
	return modules[name]
end

--------------------------------------------------------------------------------
-- UIScale Management
--------------------------------------------------------------------------------
local isScaling = false
local pendingScaleApply = false

local function GetBestScale()
	local scale = max(0.4, min(1.15, 768 / K.ScreenHeight))
	return K.Round(scale, 2)
end

local function ApplyScaleAfterCombat()
	if InCombatLockdown() then
		return
	end -- Safety check
	K:UnregisterEvent("PLAYER_REGEN_ENABLED", ApplyScaleAfterCombat)
	pendingScaleApply = false
	K:SetupUIScale()
end

function K:SetupUIScale(init)
	-- Guard against missing config during early load
	if not C or not C["General"] then
		return
	end

	if C["General"].AutoScale then
		C["General"].UIScale = GetBestScale()
	end

	local scale = C["General"].UIScale

	if init then
		local pixel = 1
		local ratio = 768 / K.ScreenHeight
		K.Mult = (pixel / scale) - ((pixel - ratio) / scale)
	else
		if InCombatLockdown() then
			if not pendingScaleApply then
				pendingScaleApply = true
				K:RegisterEvent("PLAYER_REGEN_ENABLED", ApplyScaleAfterCombat)
			end
			return
		end

		UIParent:SetScale(scale)
	end
end

local function UpdatePixelScale(event)
	if isScaling then
		return
	end
	if InCombatLockdown() then
		if not pendingScaleApply then
			pendingScaleApply = true
			K:RegisterEvent("PLAYER_REGEN_ENABLED", ApplyScaleAfterCombat)
		end
		return
	end

	isScaling = true

	if event == "UI_SCALE_CHANGED" then
		K.ScreenWidth, K.ScreenHeight = GetPhysicalScreenSize()
	end

	K:SetupUIScale(true)
	K:SetupUIScale()

	isScaling = false
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------
K:RegisterEvent("PLAYER_LOGIN", function()
	-- Set CVars safely
	if not InCombatLockdown() then
		SetCVar("ActionButtonUseKeyDown", 1)
	end

	K:SetupUIScale()

	K:RegisterEvent("UI_SCALE_CHANGED", UpdatePixelScale)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", UpdatePixelScale)

	-- Set smoothing amount if API exists
	if K.SetSmoothingAmount and C["General"] then
		K:SetSmoothingAmount(C["General"].SmoothAmount)
	end

	if K.LibCustomGlow then
		K.ShowOverlayGlow = K.LibCustomGlow.ShowOverlayGlow
		K.HideOverlayGlow = K.LibCustomGlow.HideOverlayGlow
	end

	-- Enable modules
	for _, module in ipairs(modulesQueue) do
		if module.OnEnable and not module.Enabled then
			local success, err = pcall(module.OnEnable, module)
			if success then
				module.Enabled = true
			else
				print(string_format("|cffff0000KkthnxUI Module Error:|r %s: %s", module.name, tostring(err)))
			end
		end
	end

	K.Modules = modules

	if K.InitCallback then
		K:InitCallback()
	end
end)

K:RegisterEvent("PLAYER_LEVEL_UP", function(_, level)
	K.Level = level
end)

-- Cache AddOn List
for i = 1, GetNumAddOns() do
	local name, _, _, _, reason = GetAddOnInfo(i)
	if name then
		local lowerName = string_lower(name)
		K.AddOns[lowerName] = GetAddOnEnableState(K.Name, name) == 2 and (not reason or reason ~= "DEMAND_LOADED")
		K.AddOnVersion[lowerName] = GetAddOnMetadata(name, "Version")
	end
end

-- Globals
_G.KkthnxUI = Engine
