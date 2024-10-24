local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
-- local Module = K:NewModule("Developer")

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

if K.IsFirestorm then
	-- Functions to Hide Specific Firestorm Elements
	local function HideStoreButton()
		if StoreMicroButton and StoreMicroButton:IsShown() then
			K.HideInterfaceOption(StoreMicroButton)
		end
	end

	local function HideWardrobeExtraButton()
		local newAppearancesButton = WardrobeCollectionFrameGetNewButton
		if newAppearancesButton then
			K.HideInterfaceOption(newAppearancesButton)
		end
	end

	local function HideCharacterTab()
		for i = 1, 4 do
			local tab = _G["PaperDollSidebarTab" .. i]
			if tab and i == 4 then
				K.HideInterfaceOption(tab)
				break
			end
		end
	end

	-- Hooks to Execute Hiding Functions
	hooksecurefunc("UpdateMicroButtons", function()
		C_Timer.After(1, HideStoreButton)
	end)

	-- Optimized hook for "ADDON_LOADED" event
	C_Timer.After(1, function()
		if C_AddOns.IsAddOnLoaded("Blizzard_Collections") then
			HideWardrobeExtraButton()
		else
			local frame = CreateFrame("Frame")
			frame:RegisterEvent("ADDON_LOADED")
			frame:SetScript("OnEvent", function(self, event, addonName)
				if addonName == "Blizzard_Collections" then
					HideWardrobeExtraButton()
					self:UnregisterEvent("ADDON_LOADED")
				end
			end)
		end
	end)

	hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", function()
		C_Timer.After(1, HideCharacterTab)
	end)
end
