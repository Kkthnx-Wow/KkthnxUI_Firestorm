local K, C = KkthnxUI[1], KkthnxUI[2]
local tinsert = table.insert
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

-- Reskin header function
local function ReskinObjectiveHeader(header)
	if not header then
		return
	end

	if header.Background then
		header.Background:SetAtlas(nil)
	end

	if header.Text then
		header.Text:SetFontObject(K.UIFont)
		header.Text:SetFont(select(1, header.Text:GetFont()), 15, select(3, header.Text:GetFont()))
		header.Text:SetTextColor(K.r, K.g, K.b)
	end
end

-- Update minimize button function
local function UpdateMinimizeButton(button, collapsed)
	button:SetNormalTexture(0)
	button:SetPushedTexture(0)
	button:SetSize(16, 16)
	if collapsed then
		button.tex:SetTexture(C["Media"].Textures.ArrowTexture)
		button.tex:SetRotation(math.rad(180))
	else
		button.tex:SetTexture(C["Media"].Textures.ArrowTexture)
		button.tex:SetRotation(math.rad(0))
	end
end

-- Change tracker state function
local function ChangeTrackerState()
	local minimizeButton = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
	UpdateMinimizeButton(minimizeButton, _G.ObjectiveTrackerFrame.collapsed)
end

-- Register skinning functions
tinsert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	if C_AddOns.IsAddOnLoaded("!KalielsTracker") then
		return
	end

	local minimizeButton = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
	minimizeButton:SetNormalTexture(0)
	minimizeButton:SetPushedTexture(0)
	minimizeButton:SetSize(16, 16)
	minimizeButton:StripTextures()
	minimizeButton:SetHighlightTexture([[Interface\Buttons\UI-PlusButton-Hilight]], "ADD")
	minimizeButton.tex = minimizeButton:CreateTexture(nil, "OVERLAY")
	minimizeButton.tex:SetTexture(C["Media"].Textures.ArrowTexture)
	minimizeButton.tex:SetDesaturated(true)
	minimizeButton.tex:SetAllPoints()

	hooksecurefunc("ObjectiveTracker_Expand", ChangeTrackerState)
	hooksecurefunc("ObjectiveTracker_Collapse", ChangeTrackerState)

	-- Reskin Headers
	local headers = {
		_G.BONUS_OBJECTIVE_TRACKER_MODULE.Header,
		_G.ObjectiveTrackerBlocksFrame.AchievementHeader,
		_G.ObjectiveTrackerBlocksFrame.CampaignQuestHeader,
		_G.ObjectiveTrackerBlocksFrame.ProfessionHeader,
		_G.ObjectiveTrackerBlocksFrame.QuestHeader,
		_G.ObjectiveTrackerBlocksFrame.ScenarioHeader,
		_G.ObjectiveTrackerFrame.BlocksFrame.UIWidgetsHeader,
		_G.WORLD_QUEST_TRACKER_MODULE.Header,
	}
	for _, header in pairs(headers) do
		ReskinObjectiveHeader(header)

		local button = header.MinimizeButton
		if button then
			button:SetNormalTexture(0)
			button:SetPushedTexture(0)
			button:SetSize(16, 16)
			button.tex = button:CreateTexture(nil, "OVERLAY")
			button.tex:SetTexture(C["Media"].Textures.ArrowTexture)
			button.tex:SetRotation(math.rad(0))
			button.tex:SetAllPoints()

			hooksecurefunc(button, "SetCollapsed", UpdateMinimizeButton)
		end
	end
end)
