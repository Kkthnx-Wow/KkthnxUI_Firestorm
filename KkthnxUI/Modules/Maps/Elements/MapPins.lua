local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("WorldMap")

-- Get table from file
local PinData = C.WorldMapPinIcons

function Module:CreateWorldMapPins()
	-- Create table
	local KKUI_Mix = CreateFromMixins(MapCanvasDataProviderMixin)

	function KKUI_Mix:RefreshAllData()
		-- Remove all pins created by Leatrix Maps
		self:GetMap():RemoveAllPinsByTemplate("KKUI_MapsGlobalPinTemplate")

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
						local pin = self:GetMap():AcquirePin("KKUI_MapsGlobalPinTemplate", myPOI)
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

	_G.KKUI_MapsGlobalPinTemplateMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE")
	_G.KKUI_MapsGlobalPinTemplateMixin.SetPassThroughButtons = K.Noop

	function KKUI_MapsGlobalPinTemplateMixin:OnAcquired(myInfo)
		BaseMapPoiPinMixin.OnAcquired(self, myInfo)
		self.journalID = myInfo.journalID
	end

	WorldMapFrame:AddDataProvider(KKUI_Mix)
end
