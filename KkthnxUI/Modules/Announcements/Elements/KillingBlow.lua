local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Announcements")

-- Sourced: ElvUI Shadow & Light (Darth_Predator, Repooc)

local bit_band = bit.band
local math_random = math.random
local table_wipe = table.wipe

local BossBanner_BeginAnims = BossBanner_BeginAnims
local COMBATLOG_OBJECT_TYPE_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local DoEmote = DoEmote
local GetAchievementInfo = GetAchievementInfo
local GetBattlefieldScore = GetBattlefieldScore
local GetNumBattlefieldScores = GetNumBattlefieldScores
local PlaySoundFile = PlaySoundFile
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local TopBannerManager_Show = TopBannerManager_Show
local UnitGUID = UnitGUID
local hooksecurefunc = hooksecurefunc

local pvpEmoteList = {
	"ANGRY",
	"BARK",
	"BECKON",
	"BITE",
	"BONK",
	"BURP",
	"BYE",
	"CACKLE",
	"CALM",
	"CHUCKLE",
	"COMFORT",
	"CRACK",
	"CUDDLE",
	"CURTSEY",
	"FLEX",
	"GIGGLE",
	"GLOAT",
	"GRIN",
	"GROWL",
	"GUFFAW",
	"INSULT",
	"LAUGH",
	"LICK",
	"MOCK",
	"MOO",
	"MOON",
	"MOURN",
	"NO",
	"NOSEPICK",
	"PITY",
	"RASP",
	"ROAR",
	"ROFL",
	"RUDE",
	"SCRATCH",
	"SHOO",
	"SIGH",
	"SLAP",
	"SMIRK",
	"SNARL",
	"SNICKER",
	"SNIFF",
	"SNUB",
	"SOOTHE",
	"TAP",
	"TAUNT",
	"TEASE",
	"THANK",
	"THREATEN",
	"TICKLE",
	"VETO",
	"VIOLIN",
	"YAWN",
}

local battlegroundOpponents = {} -- Table to store opponents in the battleground

-- Builds opponents table for boss banner
function Module:BuildOpponentsTable()
	wipe(battlegroundOpponents)
	for index = 1, GetNumBattlefieldScores() do
		local name, _, _, _, _, faction, _, _, classToken = GetBattlefieldScore(index)
		if (K.Faction == "Horde" and faction == 1) or (K.Faction == "Alliance" and faction == 0) then
			battlegroundOpponents[name] = classToken -- Saving opponent's class to use for coloring
		end
	end
end

function Module:HandleCombatLog()
	-- Get the current combat log event info
	local _, subEvent, _, _, caster, _, _, _, targetName, targetFlags = CombatLogGetCurrentEventInfo()

	-- Check if the event is a party kill and the source of the kill is the player
	if subEvent == "PARTY_KILL" then
		local mask = bit_band(targetFlags, COMBATLOG_OBJECT_TYPE_PLAYER)
		-- If this is my kill and target is a player (world) or in the opponents table (BGs)
		if caster == K.Name and (battlegroundOpponents[targetName] or mask > 0) then
			if mask > 0 and battlegroundOpponents[targetName] then
				targetName = "|c" .. RAID_CLASS_COLORS[battlegroundOpponents[targetName]].colorStr .. targetName .. "|r"
			end -- Color name into class color, only for BGs

			if C["Announcements"].KillingBlow then
				TopBannerManager_Show(_G["BossBanner"], { name = targetName, mode = "KKUI_PVPKILL" }) -- Show boss banner with own mode and a dead person's name instead of boss name if C["Announcements"].KillingBlow
			end

			if C["Announcements"].PvPEmote then
				-- Check if the player has earned the "Make Love, Not Warcraft" achievement (ID: 247)
				local _, _, _, completed = GetAchievementInfo(247)
				if completed then
					-- Fire off random emote to keep it interesting
					DoEmote(pvpEmoteList[math_random(1, #pvpEmoteList)], targetName)
				else
					-- Emote hug if the achievement is not completed
					DoEmote("hug", targetName)
				end
			end
		end
	end
end

function Module:SetupKillingBlow()
	-- Hook to Blizzard function for boss kill banner
	hooksecurefunc(_G["BossBanner"], "PlayBanner", function(self, data)
		if data then
			if data.mode == "KKUI_PVPKILL" then
				self.Title:SetText(data.name)
				self.Title:Show()
				self.SubTitle:Hide()
				self:Show()
				BossBanner_BeginAnims(self)
				PlaySound(SOUNDKIT.UI_RAID_BOSS_DEFEATED)
			end
		end
	end)
	K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.HandleCombatLog)
	K:RegisterEvent("UPDATE_BATTLEFIELD_SCORE", self.BuildOpponentsTable)
end
