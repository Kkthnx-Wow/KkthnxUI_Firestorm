local C, L = KkthnxUI[2], KkthnxUI[3]

C.WorldMapPinIcons = {

	----------------------------------------------------------------------
	--	World Of Warcraft: Eastern Kingdoms
	----------------------------------------------------------------------

	--[[Tirisfal Glades]]
	[18] = {
		{ "PortalH", 61.9, 59.0, L["Stranglethorn Vale"], L["Portal"] },
		{ "PortalH", 60.7, 58.7, L["Orgrimmar"], L["Portal"] },
		{ "PortalH", 59.1, 58.9, L["Howling Fjord"], L["Portal"] },
		{ "PortalH", 59.4, 67.4, L["Silvermoon City"], L["Orb of Translocation"] },
	},

	--[[Northern Stranglethorn]]
	[50] = {
		{ "PortalH", 37.6, 51.0, L["Undercity"], L["Portal"] },
	},

	--[[Stormwind City]]
	[84] = {
		{ "PortalA", 74.4, 18.4, L["Eastern Earthshrine"], L["Deepholm"] .. ", " .. L["Hyjal"] .. ", " .. L["Tol Barad"] .. ", " .. L["Twilight Highlands"] .. ", " .. L["Uldum"] .. ", " .. L["Vashj'ir"] },
	},

	--[[Undercity]]
	[90] = {
		{ "PortalH", 85.3, 17.1, L["Hellfire Peninsula"], L["Portal"] },
	},

	----------------------------------------------------------------------
	--	World Of Warcraft: Kalimdor
	----------------------------------------------------------------------

	--[[Teldrassil]]
	[57] = {
		{ "PortalA", 55.0, 93.7, L["Stormwind"], L["Portal"] },
		{ "PortalA", 52.3, 89.5, L["Exodar"], L["Portal"] },
	},

	--[[Caverns of Time: The Spiral]]
	[74] = {
		{ "PortalA", 59.0, 26.8, L["Stormwind"], L["Portal"] },
		{ "PortalH", 58.2, 26.7, L["Orgrimmar"], L["Portal"] },
	},

	--[[Silithus]]
	[81] = {
		{ "PortalN", 43.2, 44.5, L["Chamber of Heart"], L["Titan Translocator"] },
		{ "PortalA", 41.5, 44.9, L["Tiragarde Sound"], L["Portal"] },
		{ "PortalH", 41.6, 45.2, L["Zuldazar"], L["Portal"] },
	},

	--[[Orgrimmar: Main City]]
	[85] = {
		{ "PortalH", 50.1, 37.8, L["Western Earthshrine"], L["Deepholm"] .. ", " .. L["Hyjal"] .. ", " .. L["Twilight Highlands"] .. ", " .. L["Uldum"] .. ", " .. L["Vashj'ir"] },
		{ "PortalH", 47.4, 39.3, L["Tol Barad"], L["Portal"] },
		{ "PortalH", 43.0, 65.0, L["Zeppelin to"] .. " " .. L["Thunder Bluff"] .. ", " .. L["Mulgore"], "" },
		{ "PortalH", 50.7, 55.5, L["Undercity"], L["Portal"] },
	},

	--[[Orgrimmar: The Cleft Of Shadow]]
	[86] = {
		{ "PortalH", 50.1, 37.8, L["Western Earthshrine"], L["Deepholm"] .. ", " .. L["Hyjal"] .. ", " .. L["Twilight Highlands"] .. ", " .. L["Uldum"] .. ", " .. L["Vashj'ir"] },
		{ "PortalH", 47.4, 39.3, L["Tol Barad"], L["Portal"] },
		{ "PortalH", 43.0, 65.0, L["Zeppelin to"] .. " " .. L["Thunder Bluff"] .. ", " .. L["Mulgore"], "" },
		{ "PortalH", 50.7, 55.5, L["Undercity"], L["Portal"] },
	},

	--[[Thunder Bluff]]
	[88] = {
		{ "PortalH", 14.6, 26.4, L["Zeppelin to"] .. " " .. L["Orgrimmar"] .. ", " .. L["Durotar"], "" },
	},

	--[[Darnassus]]
	[89] = {
		{ "PortalA", 44.1, 78.5, L["Temple of the Moon"], L["Exodar"] .. ", " .. L["Hellfire Peninsula"] },
	},

	--[[Azuremyst Isle]]
	[97] = {
		{ "PortalA", 20.4, 54.1, L["Darnassus"], L["Portal"] },
	},

	--[[Ruins of Ahn'Qiraj]]
	[247] = {
		{ "Chest", 59.3, 28.7, L["Scarab Coffer"], L["Chest"] },
		{ "Chest", 60.8, 51.0, L["Scarab Coffer"], L["Chest"] },
		{ "Chest", 73.0, 66.4, L["Scarab Coffer"], L["Chest"] },
		{ "Chest", 57.4, 78.3, L["Scarab Coffer"], L["Chest"] },
		{ "Chest", 54.8, 87.5, L["Scarab Coffer"], L["Chest"] },
		{ "Chest", 41.0, 76.9, L["Scarab Coffer"], L["Chest"] },
		{ "Chest", 34.0, 53.0, L["Scarab Coffer"], L["Chest"] },
		{ "Chest", 41.1, 32.2, L["Scarab Coffer"], L["Chest"] },
		{ "Chest", 41.6, 46.3, L["Scarab Coffer"], L["Chest"] },
		{ "Chest", 46.7, 42.0, L["Scarab Coffer"], L["Chest"] },
	},

	--[[Temple of Ahn'Qiraj]]
	[319] = {
		{ "Chest", 33.1, 48.4, L["Large Scarab Coffer"], L["Chest"] },
		{ "Chest", 64.5, 25.5, L["Large Scarab Coffer"], L["Chest"] },
		{ "Chest", 58.4, 49.9, L["Large Scarab Coffer"], L["Chest"] },
		{ "Chest", 47.5, 54.7, L["Large Scarab Coffer"], L["Chest"] },
		{ "Chest", 56.2, 66.0, L["Large Scarab Coffer"], L["Chest"] },
		{ "Chest", 50.7, 78.1, L["Large Scarab Coffer"], L["Chest"] },
		{ "Chest", 51.4, 83.2, L["Large Scarab Coffer"], L["Chest"] },
		{ "Chest", 48.4, 85.4, L["Large Scarab Coffer"], L["Chest"] },
		{ "Chest", 48.0, 81.1, L["Large Scarab Coffer"], L["Chest"] },
		{ "Chest", 34.2, 83.5, L["Large Scarab Coffer"], L["Chest"] },
		{ "Chest", 39.2, 68.4, L["Large Scarab Coffer"], L["Chest"] },
	},

	----------------------------------------------------------------------
	--	The Burning Crusade
	----------------------------------------------------------------------

	--[[Hellfire Peninsula]]
	[100] = {
		{ "PortalH", 88.6, 47.7, L["Orgrimmar"], L["Portal"] },
		{ "PortalA", 88.6, 52.8, L["Stormwind"], L["Portal"] },
	},

	--[[The Exodar]]
	[103] = {
		{ "PortalA", 48.3, 62.9, L["Stormwind"], L["Portal"] },
	},

	--[[Silvermoon City]]
	[110] = {
		{ "PortalH", 58.5, 18.7, L["Orgrimmar"], L["Portal"] },
		{ "PortalH", 49.5, 14.8, L["Undercity"], L["Orb of Translocation"] },
		{ "PortalH", 58.5, 18.7, L["Orgrimmar"], L["Portal"] },
	},

	--[[Shattrath City]]
	[111] = {
		{ "PortalN", 48.5, 42.0, L["Isle of Quel'Danas"], L["Portal"] },
		{ "PortalH", 56.8, 48.9, L["Orgrimmar"], L["Portal"] },
		{ "PortalA", 57.2, 48.3, L["Stormwind"], L["Portal"] },
	},

	--[[Tol Barad Peninsula]]
	[245] = {
		{ "PortalH", 56.3, 79.7, L["Orgrimmar"], L["Portal"] },
		{ "PortalA", 75.3, 58.8, L["Stormwind"], L["Portal"] },
	},

	----------------------------------------------------------------------
	--	Wrath Of The Lich King
	----------------------------------------------------------------------

	--[[Borean Tundra]]
	[114] = {
		{ "PortalN", 78.9, 53.7, L["Boat to"] .. " " .. L["Moa'ki Harbor"] .. ", " .. L["Dragonblight"] },
	},

	--[[Dragonblight]]
	[115] = {
		{ "PortalN", 49.6, 78.4, L["Boat to"] .. " " .. L["Kamagua"] .. ", " .. L["Howling Fjord"] },
		{ "PortalN", 47.9, 78.7, L["Boat to"] .. " " .. L["Unu'pe"] .. ", " .. L["Borean Tundra"] },
	},

	--[[Howling Fjord]]
	[117] = {
		{ "PortalN", 23.5, 57.8, L["Boat to"] .. " " .. L["Moa'ki Harbor"] .. ", " .. L["Dragonblight"] },
	},

	--[[Dalaran]]
	[125] = {
		{ "PortalA", 40.1, 62.8, L["Stormwind"], L["Portal"] },
		{ "PortalH", 55.3, 25.4, L["Orgrimmar"], L["Portal"] },
	},

	----------------------------------------------------------------------
	--	Cataclysm
	----------------------------------------------------------------------

	----------------------------------------------------------------------
	--	Mists of Pandaria
	----------------------------------------------------------------------

	--[[Shrine of Two Moons]]
	[392] = {
		{ "PortalH", 73.3, 42.8, L["Orgrimmar"], L["Portal"] },
	},

	--[[Shrine of Seven Stars]]
	[394] = {
		{ "PortalA", 71.6, 36.0, L["Stormwind"], L["Portal"] },
	},

	----------------------------------------------------------------------
	--	Warlords of Draenor
	----------------------------------------------------------------------

	--[[Stormshield]]
	[622] = {
		{ "PortalA", 60.8, 38.0, L["Stormwind"], L["Portal"] },
		{ "PortalA", 36.4, 41.1, L["Lion's Watch"], L["Portal"], 0, 38445 },
	},

	--[[Warspear]]
	[624] = {
		{ "PortalH", 60.6, 51.6, L["Orgrimmar"], L["Portal"] },
		{ "PortalH", 53.0, 43.9, L["Vol'mar"], L["Portal"], 0, 37935 },
	},

	----------------------------------------------------------------------
	--	Legion
	----------------------------------------------------------------------

	--[[Dalaran]]
	[627] = {
		{ "PortalA", 39.6, 63.2, L["Stormwind"], L["Portal"] },
		{ "PortalH", 55.2, 23.9, L["Orgrimmar"], L["Portal"] },
	},

	--[[Felsoul Hold]]
	[682] = {
		{ "PortalN", 53.6, 36.8, L["Shal'Aran"], L["Portal"], 0, 41575 },
	},

	--[[Shattered Locus]]
	[684] = {
		{ "PortalN", 40.9, 13.7, L["Shal'Aran"], L["Portal"], 0, 42230 },
	},

	--[[Suramar]]
	[680] = {
		{ "PortalN", 21.6, 28.5, L["Falanaar"], L["Portal"], 0, 42230 },
		{ "PortalN", 39.7, 76.2, L["Felsoul Hold"], L["Portal"], 0, 41575 },
		{ "PortalN", 30.8, 11.0, L["Moon Guard Stronghold"], L["Portal"], 0, 43808 },
		{ "PortalN", 43.7, 79.2, L["Lunastre Estate"], L["Portal"], 0, 43811 },
		{ "PortalN", 36.1, 47.2, L["Ruins of Elune'eth"], L["Portal"], 0, 40956 },
		{ "PortalN", 52.0, 78.8, L["Evermoon Terrace"], L["Portal"], 0, 42889 },
		{ "PortalN", 43.4, 60.6, L["Sanctum of Order"], L["Portal"], 0, 43813 },
		{ "PortalN", 42.0, 35.2, L["Tel'anor"], L["Portal"], 0, 43809 },
		{ "PortalN", 64.0, 60.4, L["Twilight Vineyards"], L["Portal"], 0, 44084 },
		{ "PortalN", 54.5, 69.4, L["Astravar Harbor"], L["Portal"], 0, 44740 },
		{ "PortalN", 47.7, 81.4, L["The Waning Crescent"], L["Portal"], 0, 42487, 38649 },
	},

	--[[Dungeon: Court of Stars]]
	[761] = {

		{ "Arrow", 42.5, 76.8, L["Step 1"], L["Start here."], 5.5 },
		{ "Arrow", 42.4, 65.2, L["Step 2"], L["Enter this building and go upstairs."], 0.1 },
		{ "Arrow", 41.3, 53.0, L["Step 3"], L["Click the Arcane Beacon then go across the bridge to the left."], 0.7 },
		{ "Arrow", 36.2, 47.1, L["Step 4"], L["Kill the Construct then turn left before the bridge."], 1.1 },
		{ "Arrow", 32.0, 41.2, L["Step 5"], L["Go over this bridge."], 5.9 },
		{ "Arrow", 33.5, 30.8, L["Step 6"], L["Pull Patrol Captain Gerdo here and kill."], 6.1 },
		{ "Arrow", 38.5, 24.5, L["Step 7"], L["Go up these steps."], 4.5 },
		{ "Arrow", 42.6, 26.7, L["Step 8"], L["Enter this building and go up the stairs."], 4.5 },
		{ "Arrow", 46.4, 34.9, L["Step 9"], L["Enter this building and go down the stairs."], 2.7 },
		{ "Arrow", 48.4, 39.7, L["Step 10"], L["Look at the map.  Find and kill 3 Enforcers (yellow dots).|nAfter each Enforcer, wait and kill the Covenant.|n|nThen kill Talixae Flamewreath."], 5.9 },
		{ "Arrow", 60.4, 61.6, L["Step 11"], L["After killing Talixae, talk to Ly'leth Lunastre to get a disguise."], 4.0 },
		{ "Arrow", 64.0, 67.0, L["Step 12"], L["Enter this building and talk to Chatty Rumormongers to get a description of the spy."], 4.0 },
	},

	--[[Dungeon: Court of Stars (The Balconies)]]
	[763] = {
		{ "Arrow", 27.1, 77.8, L["Step 13 (1)"], L["Once identified, kill the spy either here or at the opposite side.|nThen pick up the Arcane Keys."], 2.3 },
		{ "Arrow", 66.7, 18.7, L["Step 13 (2)"], L["Once identified, kill the spy either here or at the opposite side.|nThen pick up the Arcane Keys."], 5.5 },
		{ "Arrow", 60.0, 69.3, L["Step 14"], L["Unlock the Skyward Terrace doors using the Arcane Keys.|nKill Advisor Melandrus."], 4.0 },
	},

	----------------------------------------------------------------------
	--	Battle For Azeroth
	----------------------------------------------------------------------

	--[[Boralus Harbor]]
	[1161] = {
		{ "PortalA", 70.4, 17.7, L["Sanctum of the Sages"], L["Exodar"] .. ", " .. L["Ironforge"] .. ", " .. L["Nazjatar"] .. ", " .. L["Silithus"] .. ", " .. L["Stormwind"] },
	},

	--[[Dazar'alor (inside)]]
	[1163] = {
		{ "PortalH", 60.5, 70.3, L["Hall of Ancient Paths"], L["Nazjatar"] .. ", " .. L["Orgrimmar"] .. ", " .. L["Silithus"] .. ", " .. L["Silvermoon City"] .. ", " .. L["Thunder Bluff"] },
	},

	--[[Chamber of Heart]]
	[1473] = {
		{ "PortalN", 50.1, 30.4, L["Silithus"], L["Titan Translocator"] },
	},

	----------------------------------------------------------------------
	--	Shadowlands
	----------------------------------------------------------------------

	--[[Oribos]]
	[1670] = {
		{ "PortalH", 20.9, 54.8, L["Orgrimmar"], L["Portal"] },
		{ "PortalA", 20.9, 45.9, L["Stormwind"], L["Portal"] },
	},

	--[[Korthia]]
	[1961] = {
		{ "PortalN", 64.5, 24.1, L["Oribos"], L["Portal"] },
		{ "TaxiN", 49.3, 63.9, L["Flayedwing Transporter"], L["Taxi to Scholar's Den"] },
		{ "TaxiN", 60.8, 28.5, L["Flayedwing Transporter"], L["Taxi to Vault of Secrets"] },
	},

	--[[Zereth Mortis]]
	[1970] = {
		{ "TaxiN", 34.9, 45.7, L["Exile's Hollow"], L["Sanctuary"] },
		{ "TaxiN", 61.9, 58.9, L["Synthesis Forge"], L["Pet Crafting"] },
		{ "TaxiN", 68.5, 30.2, L["Protoform Repository"], L["Mount Crafting"] },
	},

	----------------------------------------------------------------------
	--	Dragonflight
	----------------------------------------------------------------------

	--[[Ohn'ahran Plains]]
	[2023] = {
		{ "PortalN", 18.5, 52.1, L["Emerald Dream"], L["Portal"] },
	},

	--[[Valdrakken]]
	[2112] = {
		{ "PortalN", 53.9, 55.0, L["Valdrakken Portals"] },
		{ "PortalH", 56.6, 38.4, L["Orgrimmar"], L["Portal"] },
		{ "PortalA", 59.7, 41.8, L["Stormwind"], L["Portal"] },
		{ "PortalN", 62.6, 57.3, L["Emerald Dream"], L["Portal"] },
		{ "PortalN", 26.1, 40.9, L["Badlands"], L["Portal"] },
	},

	--[[Emerald Dream]]
	[2200] = {
		{ "PortalN", 72.8, 52.9, L["Ohn'ahran Plains"], L["Portal"] },
	},

	--[[Amirdrassil]]
	[2239] = {
		{ "PortalN", 89.3, 38.7, L["Emerald Dream"], L["Portal"] },
	},
}

local WorldMapPinIconsFrame = CreateFrame("FRAME")
WorldMapPinIconsFrame:RegisterEvent("PLAYER_LOGIN")
WorldMapPinIconsFrame:SetScript("OnEvent", function()
	-- Add Caverns of Time portal to Shattrath if reputation with Keepers of Time is revered or higher
	local _, _, standingID = GetFactionInfoByID(989)
	if standingID and standingID >= 7 then
		C.WorldMapPinIcons[111] = C.WorldMapPinIcons[111] or {}
		tinsert(C.WorldMapPinIcons[111], { "PortalN", 74.7, 31.4, L["Caverns of Time"], L["Portal from Zephyr"] })
	end
end)
