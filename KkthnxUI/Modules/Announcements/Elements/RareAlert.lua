local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- Cache frequently used API functions locally for performance
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_Texture_GetAtlasInfo = C_Texture.GetAtlasInfo
local C_VignetteInfo_GetVignetteInfo = C_VignetteInfo.GetVignetteInfo
local C_VignetteInfo_GetVignettePosition = C_VignetteInfo.GetVignettePosition
local GetInstanceInfo = GetInstanceInfo
local UIErrorsFrame = UIErrorsFrame
local date = date

-- Cache for rare alerts
local RareAlertCache = {}
local ignoredZones = {
	[1153] = true, -- Horde Garrison
	[1159] = true, -- Alliance Garrison
	[1803] = true, -- Ashran
	[1876] = true, -- Horde Seething Shore
	[1943] = true, -- Alliance Seething Shore
	[2111] = true, -- Darkshore Warfront
}
local ignoredVignetteIDs = {
	[5485] = true, -- Walrus Tool Box
}

-- Function to check if the vignette atlas is useful
local function isUsefulAtlas(info)
	local atlas = info.atlasName
	return atlas and (string.find(atlas, "[Vv]ignette") or atlas == "nazjatar-nagaevent")
end

-- Function to handle rare alerts
function Module:RareAlert_Update(id)
	if id and not RareAlertCache[id] then
		local info = C_VignetteInfo_GetVignetteInfo(id)
		if not info or not isUsefulAtlas(info) or ignoredVignetteIDs[info.vignetteID] then
			return
		end

		local atlasInfo = C_Texture_GetAtlasInfo(info.atlasName)
		if not atlasInfo then
			return
		end

		local textureStr = K.GetTextureStrByAtlas(atlasInfo)
		if not textureStr then
			return
		end

		UIErrorsFrame:AddMessage(K.InfoColor .. L["Rare Spotted"] .. textureStr .. (info.name or ""))

		if C["Announcements"].AlertInChat then
			local currentTime = C["Chat"].TimestampFormat.Value == 1 and "|cff00ff00[" .. date("%H:%M:%S") .. "]|r" or ""
			local nameString
			local mapID = C_Map_GetBestMapForUnit("player")
			local position = mapID and C_VignetteInfo_GetVignettePosition(info.vignetteGUID, mapID)
			if position then
				local x, y = position:GetXY()
				nameString = string.format(Module.RareString, mapID, x * 10000, y * 10000, info.name, x * 100, y * 100, "")
			end
			print(currentTime .. " -> " .. textureStr .. K.InfoColor .. (nameString or info.name or ""))
		end

		if not C["Announcements"].AlertInWild or Module.RareInstType == "none" then
			PlaySound(23404, "master")
		end

		RareAlertCache[id] = true
	end

	if #RareAlertCache > 666 then
		wipe(RareAlertCache)
	end
end

-- Function to check the instance type for rare alerts
function Module:RareAlert_CheckInstance()
	local _, instanceType, _, _, maxPlayers, _, _, instanceID = GetInstanceInfo()
	if (instanceID and ignoredZones[instanceID]) or (instanceType == "scenario" and (maxPlayers == 3 or maxPlayers == 6)) then
		K:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
	else
		K:RegisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
	end
	Module.RareInstType = instanceType
end

-- Function to create rare announcements
function Module:CreateRareAnnounce()
	Module.RareString = "|Hworldmap:%d+:%d+:%d+|h[%s (%.1f, %.1f)%s]|h|r"

	if C["Announcements"].RareAlert then
		Module:RareAlert_CheckInstance()
		K:RegisterEvent("UPDATE_INSTANCE_INFO", Module.RareAlert_CheckInstance)
	else
		-- Clear cache and unregister events if rare alerts are disabled
		table.wipe(RareAlertCache)
		K:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
		K:UnregisterEvent("UPDATE_INSTANCE_INFO", Module.RareAlert_CheckInstance)
	end
end
