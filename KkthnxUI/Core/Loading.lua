local K, C = KkthnxUI[1], KkthnxUI[2]
local KKUI_AddonLoader = CreateFrame("Frame")
local KKUI_ModulesEnabled = false
local pcall = pcall
local pairs = pairs
local print = print
local debugprofilestop = debugprofilestop

local function KKUI_EnableModulesOnce()
	local t0
	if K.isDeveloper then
		t0 = debugprofilestop()
	end
	if KKUI_ModulesEnabled then
		return
	end
	KKUI_ModulesEnabled = true

	-- 1) Main GUI
	if K.GUI and K.GUI.GUI and K.GUI.GUI.Enable then
		pcall(function()
			K.GUI.GUI:Enable()
		end)
	elseif K.GUI and K.GUI.Enable then
		pcall(function()
			K.GUI:Enable()
		end)
	end

	-- 2) ExtraGUI
	if K.ExtraGUI and K.ExtraGUI.Enable then
		local ok = pcall(function()
			K.ExtraGUI:Enable()
		end)
		if ok and K.GUI and K.GUI.AttachExtraCogwheels then
			pcall(function()
				K.GUI:AttachExtraCogwheels()
			end)
		elseif ok and K.GUI and K.GUI.GUI and K.GUI.GUI.AttachExtraCogwheels then
			pcall(function()
				K.GUI.GUI:AttachExtraCogwheels()
			end)
		end
	end

	-- 3) ProfileGUI
	if K.ProfileGUI and K.ProfileGUI.Enable then
		pcall(function()
			K.ProfileGUI:Enable()
		end)
	end

	if K.isDeveloper and t0 then
		local dt = debugprofilestop() - t0
		K.Print(string.format("[KKUI_DEV] EnableModulesOnce %.3f ms", dt))
	end
end

local function KKUI_OnEvent(_, event, addonName)
	if event == "ADDON_LOADED" and addonName == "KkthnxUI" then
		local t0
		if K.isDeveloper then
			t0 = debugprofilestop()
		end
		local success, err = pcall(function()
			if K.Database and K.Database.Initialize then
				K.Database:Initialize()
			end
			K:SetupUIScale(true)

			-- Initialize subsystems later on PLAYER_LOGIN for smoother load
		end)

		if not success then
			print("|cffFF0000KkthnxUI ERROR:|r Critical error during loading: " .. tostring(err))
			print("|cffFF0000KkthnxUI ERROR:|r Please check your installation and try again.")
		elseif K.isDeveloper and t0 then
			local dt = debugprofilestop() - t0
			K.Print(string.format("[KKUI_DEV] ADDON_LOADED %.3f ms", dt))
		end
	elseif event == "PLAYER_LOGIN" then
		-- Ensure subsystems are enabled exactly once
		KKUI_EnableModulesOnce()

		-- Defer profile timestamp update to PLAYER_ENTERING_WORLD, but only when the helper is available.
		local function UpdateProfileTimestampOnPEW()
			if K.UpdateProfileTimestamp then
				K.UpdateProfileTimestamp()
				K:UnregisterEvent("PLAYER_ENTERING_WORLD", UpdateProfileTimestampOnPEW)
			end
		end
		K:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateProfileTimestampOnPEW)
		K:UnregisterEvent(event, KKUI_OnEvent)
	end
end

KKUI_AddonLoader:RegisterEvent("ADDON_LOADED")
KKUI_AddonLoader:RegisterEvent("PLAYER_LOGIN")
KKUI_AddonLoader:SetScript("OnEvent", KKUI_OnEvent)
