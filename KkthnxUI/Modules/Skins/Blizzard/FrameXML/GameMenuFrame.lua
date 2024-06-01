local K, C = KkthnxUI[1], KkthnxUI[2]

local table_insert = table.insert

table_insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	-- ScriptErrorsFrame
	ScriptErrorsFrame:SetScale(UIParent:GetScale())

	-- TicketStatusFrame
	TicketStatusFrameButton:StripTextures()
	TicketStatusFrameButton:SkinButton()
end)
