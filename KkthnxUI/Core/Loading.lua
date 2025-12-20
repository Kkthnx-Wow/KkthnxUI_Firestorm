local K, C = _G.KkthnxUI[1], _G.KkthnxUI[2]

--========================================================
-- Locals (perf)
--========================================================
local _G = _G
local CreateFrame = CreateFrame
local pairs = pairs
local tostring = tostring
local debugprofilestop = debugprofilestop
local string_format = string.format

--========================================================
-- Loader state
--========================================================
local Loader = CreateFrame("Frame")
local modulesEnabled = false

--========================================================
-- Dev timing helpers (cheap when disabled)
--========================================================
local function DevStart()
	return (K.isDeveloper and debugprofilestop()) or nil
end

local function DevEnd(t0, label)
	if t0 then
		K.Print(string_format("[KKUI_DEV] %s %.3f ms", label, debugprofilestop() - t0))
	end
end

--========================================================
-- DB helpers
--========================================================
local function Ensure(t, k, default)
	local v = t[k]
	if v == nil then
		v = default
		t[k] = v
	end
	return v
end

local function VerifyDatabase()
	-- This is your SavedVariables global
	local db = Ensure(_G, "KkthnxUIDB", {})

	-- Character scoped
	local vars = Ensure(db, "Variables", {})
	local realmVars = Ensure(vars, K.Realm, {})
	local charVars = Ensure(realmVars, K.Name, {})

	Ensure(charVars, "AuraWatchList", { Switcher = {}, IgnoreSpells = {} })
	Ensure(charVars, "AuraWatchMover", {})
	Ensure(charVars, "AutoQuest", false)
	Ensure(charVars, "AutoQuestIgnoreNPC", {})
	Ensure(charVars, "BindType", 1)
	Ensure(charVars, "CustomItems", {})
	Ensure(charVars, "CustomJunkList", {})
	Ensure(charVars, "CustomNames", {})
	Ensure(charVars, "InternalCD", {})
	Ensure(charVars, "Mover", {})
	Ensure(charVars, "RevealWorldMap", false)
	Ensure(charVars, "SplitCount", 1)
	Ensure(charVars, "TempAnchor", {})
	Ensure(charVars, "Tracking", { PvP = {}, PvE = {} })
	Ensure(charVars, "QueueTimer", { PVEPopTime = {}, PVEQueuedTime = {} })

	-- Settings scoped
	local settings = Ensure(db, "Settings", {})
	local realmSettings = Ensure(settings, K.Realm, {})
	Ensure(realmSettings, K.Name, {})

	-- Account / shared
	Ensure(db, "ChatHistory", {})
	Ensure(db, "Gold", {})
	Ensure(db, "ProfilePortraits", {})
	Ensure(db, "ShowSlots", false)
	Ensure(db, "KeystoneInfo", {})
	Ensure(db, "DisabledAddOns", {})
	Ensure(db, "ChangelogHighlightLatest", false)

	-- These are intentionally nil-able; don't force defaults beyond "exists"
	if db.ChangelogVersion == nil then
		db.ChangelogVersion = nil
	end
	if db.DetectedVersion == nil then
		db.DetectedVersion = nil
	end
end

--========================================================
-- Defaults + settings overrides
--========================================================
local function CreateDefaults()
	local defaults = {}
	K.Defaults = defaults

	for group, options in pairs(C) do
		local dst = defaults[group]
		if not dst then
			dst = {}
			defaults[group] = dst
		end
		for opt, val in pairs(options) do
			dst[opt] = val
		end
	end
end

local function LoadCustomSettings()
	local Settings = _G.KkthnxUIDB.Settings[K.Realm][K.Name]
	if not Settings then
		return
	end

	-- Migration: Automation.AutoSkipCinematic -> Automation.ConfirmCinematicSkip
	local Automation = Settings.Automation
	if Automation and Automation.AutoSkipCinematic ~= nil and Automation.ConfirmCinematicSkip == nil then
		Automation.ConfirmCinematicSkip = Automation.AutoSkipCinematic
		Automation.AutoSkipCinematic = nil
	end

	-- Apply + prune
	for group, options in pairs(Settings) do
		local cfgGroup = C[group]
		if not cfgGroup then
			Settings[group] = nil
		else
			local changed = 0
			for option, value in pairs(options) do
				local cur = cfgGroup[option]
				if cur == nil then
					options[option] = nil -- remove unknown option
				elseif cur == value then
					options[option] = nil -- remove redundant
				else
					changed = changed + 1
					cfgGroup[option] = value
				end
			end

			if changed == 0 then
				Settings[group] = nil
			end
		end
	end
end

local function LoadVariables()
	CreateDefaults()
	LoadCustomSettings()
end

--========================================================
-- Modules enable (once, no pcall)
--========================================================
local function EnableModulesOnce()
	if modulesEnabled then
		return
	end
	modulesEnabled = true

	local t0 = DevStart()

	-- Main GUI: support K.GUI:Enable() or K.GUI.GUI:Enable()
	local GUI = K.GUI
	if GUI then
		local enable = GUI.Enable
		if enable then
			enable(GUI)
		elseif GUI.GUI and GUI.GUI.Enable then
			GUI.GUI:Enable()
		end
	end

	-- Extra GUI + attach
	local ExtraGUI = K.ExtraGUI
	if ExtraGUI and ExtraGUI.Enable then
		ExtraGUI:Enable()

		-- Attach extra buttons if present (prefer direct, fallback nested)
		if GUI then
			if GUI.AttachExtraCogwheels then
				GUI:AttachExtraCogwheels()
			elseif GUI.GUI and GUI.GUI.AttachExtraCogwheels then
				GUI.GUI:AttachExtraCogwheels()
			end
		end
	end

	-- Profile GUI
	if K.ProfileGUI and K.ProfileGUI.Enable then
		K.ProfileGUI:Enable()
	end

	DevEnd(t0, "EnableModulesOnce")
end

--========================================================
-- Event driver
--========================================================
local function OnEvent(_, event, addonName)
	if event == "ADDON_LOADED" then
		if addonName ~= "KkthnxUI" then
			return
		end

		local t0 = DevStart()

		-- Core boot: fail loudly if something is wrong
		VerifyDatabase()
		LoadVariables()
		K:SetupUIScale(true)

		DevEnd(t0, "ADDON_LOADED")
		return
	end

	-- PLAYER_LOGIN
	EnableModulesOnce()

	-- Register PEW callback once (wrapper avoids nil-ref if load order changes)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", function()
		local fn = K.UpdateProfileTimestamp
		if fn then
			fn()
		elseif K.isDeveloper then
			print("|cffff9900KkthnxUI:|r UpdateProfileTimestamp not ready at PLAYER_ENTERING_WORLD")
		end
	end)

	Loader:UnregisterEvent("PLAYER_LOGIN")
	Loader:UnregisterEvent("ADDON_LOADED")
end

Loader:RegisterEvent("ADDON_LOADED")
Loader:RegisterEvent("PLAYER_LOGIN")
Loader:SetScript("OnEvent", OnEvent)
