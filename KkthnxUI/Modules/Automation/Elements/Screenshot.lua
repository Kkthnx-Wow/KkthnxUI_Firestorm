local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local screenshotFrame

local function onAchievementEarned()
	screenshotFrame.delay = 1
	screenshotFrame:Show()
end

local function onUpdate(self, elapsed)
	if self.delay then
		self.delay = self.delay - elapsed
		if self.delay < 0 then
			Screenshot()
			self:Hide()
		end
	end
end

function Module:CreateAutoScreenshot()
	if not screenshotFrame then
		screenshotFrame = CreateFrame("Frame")
		screenshotFrame:Hide()
		screenshotFrame:SetScript("OnUpdate", onUpdate)
	end

	if C["Automation"].AutoScreenshot then
		K:RegisterEvent("ACHIEVEMENT_EARNED", onAchievementEarned)
		screenshotFrame:Show()
	else
		K:UnregisterEvent("ACHIEVEMENT_EARNED", onAchievementEarned)
		screenshotFrame:Hide()
	end
end
