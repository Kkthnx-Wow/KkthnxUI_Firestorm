local K, C = KkthnxUI[1], KkthnxUI[2]

local table_insert = table.insert

table_insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	GameMenuButtonLogoutText:SetTextColor(1, 1, 0)
	GameMenuButtonQuitText:SetTextColor(1, 0, 0)
	GameMenuButtonContinueText:SetTextColor(0, 1, 0)

	-- ScriptErrorsFrame
	ScriptErrorsFrame:SetScale(UIParent:GetScale())

	-- TicketStatusFrame
	TicketStatusFrameButton:StripTextures()
	TicketStatusFrameButton:SkinButton()
end)
