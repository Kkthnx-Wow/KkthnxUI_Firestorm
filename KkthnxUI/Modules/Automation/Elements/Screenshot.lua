--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically takes a screenshot when the player earns a new achievement.
-- - Design: Hooks ACHIEVEMENT_EARNED and uses C_Timer.After for a clean 1-second delay.
-- - Events: ACHIEVEMENT_EARNED
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local Screenshot = Screenshot
local C_Timer_After = C_Timer.After

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function screenshotOnEvent(_, alreadyEarned)
	-- REASON: Only take screenshots for achievements earned for the first time by the character/account.
	if alreadyEarned then
		return
	end

	-- PERF: C_Timer.After replaces the old OnUpdate-based delay pattern, eliminating a hidden
	-- frame that ran every frame for 1 second just to fire a single Screenshot() call.
	C_Timer_After(1, Screenshot)
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
function Module:CreateAutoScreenshot()
	-- REASON: Feature entry point; registers for achievement events based on user configuration.
	if C["Automation"].AutoScreenshot then
		K:RegisterEvent("ACHIEVEMENT_EARNED", screenshotOnEvent)
	else
		K:UnregisterEvent("ACHIEVEMENT_EARNED", screenshotOnEvent)
	end
end
