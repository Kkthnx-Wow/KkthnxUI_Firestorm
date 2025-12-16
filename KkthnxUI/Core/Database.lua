local K, C = KkthnxUI[1], KkthnxUI[2]

local type = type
local pairs = pairs
local print = print
local setmetatable = setmetatable
local next = next
local time = time

local Database = {}
K.Database = Database

-- Convenience locals that will be refreshed on Initialize
local DB

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

local function EnsureRoot()
	KkthnxUIDB = KkthnxUIDB or {}
	DB = KkthnxUIDB

	-- Core containers
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

	-- Convenience user key ("Name - Realm")
	K.UserKey = K.UserKey or (K.Name .. " - " .. K.Realm)

	if not Global.Characters[K.UserKey] then
		Global.Characters[K.UserKey] = {
			InstallComplete = false,
			Tracking = { PvP = {}, PvE = {} },
			-- ADDED: Default AuraWatchList structure for per-character saved vars
			AuraWatchList = {
				Switcher = {},
				IgnoreSpells = {},
			},
		}
	end
end

function Database:GetCurrentProfileName()
	EnsureRoot()

	-- ISOLATION LOGIC: If this character has no profile key, give them a unique one.
	-- This ensures new alts get fresh settings by default.
	if not DB.ProfileKeys[K.UserKey] then
		DB.ProfileKeys[K.UserKey] = K.UserKey
	end

	local profileName = DB.ProfileKeys[K.UserKey]

	-- Ensure the profile table exists (empty table = 100% defaults)
	if not DB.Profiles[profileName] then
		DB.Profiles[profileName] = {}
	end

	return profileName
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

function Database:GetCurrentProfileTable()
	EnsureRoot()
	local profileName = self:GetCurrentProfileName()
	return DB.Profiles[profileName], profileName
end

-- Apply profile data on top of defaults into C
local function ApplyProfileToConfig(profileTable)
	if not K.Defaults or type(K.Defaults) ~= "table" then
		-- Fallback: build defaults from current C if needed
		K.Defaults = K.Defaults or {}
		for group, options in pairs(C) do
			if type(options) == "table" then
				K.Defaults[group] = K.Defaults[group] or {}
				for option, value in pairs(options) do
					K.Defaults[group][option] = value
				end
			end
		end
	end

	-- Start from clean copy of defaults
	K.CopyTable(K.Defaults, C)

	if not profileTable or type(profileTable) ~= "table" then
		-- Still apply metatables so missing keys fall back to defaults
		for group, defaults in pairs(K.Defaults) do
			if type(defaults) == "table" and type(C[group]) == "table" then
				setmetatable(C[group], { __index = defaults })
			end
		end
		return
	end

	for group, options in pairs(profileTable) do
		if not META_GROUP_KEYS[group] and type(options) == "table" and C[group] then
			for option, value in pairs(options) do
				-- Allow profiles to define options that aren't in K.Defaults
				-- as long as the group exists. This is needed for things like
				-- WorldMap.RevealWorldMap which intentionally has no default.
				C[group][option] = value
			end
		end
	end

	-- Finally, ensure every config group falls back to defaults via metatable
	for group, defaults in pairs(K.Defaults) do
		if type(defaults) == "table" and type(C[group]) == "table" then
			setmetatable(C[group], { __index = defaults })
		end
	end
end

-- Public helper used by Profile switching
function Database:ApplyCurrentProfile()
	local profileTable, profileName = self:GetCurrentProfileTable()
	ApplyProfileToConfig(profileTable)
	K.ActiveProfile = profileName
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

	-- Ensure there is always an active profile
	local profileName = self:GetCurrentProfileName()
	local profileTable = DB.Profiles[profileName]

	-- Apply profile settings onto runtime config with defaults
	ApplyProfileToConfig(profileTable)
	K.ActiveProfile = profileName
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
