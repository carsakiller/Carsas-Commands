VERSION = 1.02
ABOUT = {
	{title="Add-On Name:", text="Carsa's Commands"},
	{title="Version:", text=VERSION},
	{title="More Info:", text="Look on the Steam Workshop for this script's page"}
}

PREFERENCE_DEFAULTS = {
	auth_all = true,
	cheats = true,
	equip_on_respawn = true,
	keep_inventory = false,
	remove_vehicle_on_leave = true,
	start_equipment = {15, 6, 11},
	welcome_new = "Welcome to my server. Here are some rules:",
	welcome_returning = "Welcome back to my server"
}

PLAYER_DATA_DEFAULTS = {
	owner = false,
	admin = false,
	auth = false
}

DEFAULT_RULES = {
	"Be kind to others",
	"Please do not purposely lag the server"
}

STEAM_ID_MIN = "76561197960265729"
CAREER_SETTINGS = {true, true, true, true, true, true, false, false, false, false, true, false, false, false, true, nil, nil, nil, false, false, false, false, false, true, false, false, false, false, true, false, true, true, true, false}
CREATIVE_SETTINGS = {true, true, true, true, true, true, true, true, false, true, true, true, true, true, true, true, nil, nil, nil, true, true, false, false, true, true, true, false, true, true, true, true, false, false, true}
CHEAT_SETTINGS = {3, 4, 5, 6, 7, 8, 10, 11, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 34}
LINE = "---------------------------------------------------------------------------"
IS_NEW_SAVE = false
MAKE_DS_OWNER = false

GAME_SETTING_OPTIONS = {
	"third_person",
	"third_person_vehicle",
	"vehicle_damage",
	"player_damage",
	"npc_damage",
	"sharks",
	"fast_travel",
	"teleport_vehicle",
	"rogue_mode",
	"auto_refuel",
	"megalodon",
	"map_show_players",
	"map_show_vehicles",
	"show_3d_waypoints",
	"show_name_plates",
	nil, -- day/night length
	nil, -- sunrise
	nil, -- sunset
	"infinite_money",
	"settings_menu",
	"unlock_all_islands",
	"infinite_batteries",
	"infinite_fuel",
	"engine_overheating",
	"no_clip",
	"map_teleport",
	"cleanup_vehicle",
	"clear_fow",
	"vehicle_spawning",
	"photo_mode",
	"respawning",
	"settings_menu_lock",
	"despawn_on_leave",
	"unlock_all_components"
}
-- 1 = clothing, 2 = large, 3 = small
EQUIPMENT_SLOTS = {2, 3, 3, 3, 3, 1}

EQUIPMENT_DATA = {
	{name="diving suit", size=1, charges=0, ammo=100},
	{name="firefighter", size=1, charges=0, ammo=0},
	{name="scuba suit", size=1, charges=0, ammo=100},
	{name="parachute", size=1, charges=1, ammo=0},
	{name="parka", size=1, charges=0, ammo=0},
	{name="binoculars", size=3, charges=0, ammo=0},
	{name="cable", size=2, charges=0, ammo=0},
	{name="compass", size=3, charges=0, ammo=0},
	{name="defibrillator", size=2, charges=4, ammo=0},
	{name="fire extinguisher", size=2, charges=0, ammo=9},
	{name="first aid", size=3, charges=4, ammo=0},
	{name="flare", size=3, charges=4, ammo=0},
	{name="flaregun", size=3, charges=1, ammo=0},
	{name="flaregun ammo", size=3, charges=4, ammo=0},
	{name="flashlight", size=3, charges=0, ammo=100},
	{name="hose", size=2, charges=0, ammo=0},
	{name="night vision binoculars", size=3, charges=0, ammo=100},
	{name="oxygen mask", size=3, charges=0, ammo=100},
	{name="radio", size=3, charges=0, ammo=100},
	{name="radio signal locator", size=2, charges=0, ammo=100},
	{name="remote control", size=3, charges=0, ammo=100},
	{name="rope", size=2, charges=0, ammo=0},
	{name="strobe light", size=3, charges=0, ammo=100},
	{name="strobe light infrared", size=3, charges=0, ammo=100},
	{name="transponder", size=3, charges=0, ammo=100},
	{name="underwater welding torch", size=2, charges=0, ammo=250},
	{name="welding torch", size=2, charges=0, ammo=400},
	{name="coal", size=3, charges=0, ammo=0},
	{name="hazmat", size=1, charges=0, ammo=0},
	{name="radiation detector", size=3, charges=0, ammo=100}
}

function clamp(v,low,high)
	return math.min(math.max(v,low),high)
end

function numberToBool(n)
	local t = {true , false}
	return t[n] or nil
end

function stringToBool(value)
	local stringToBool = {["true"] = true, ["false"] = false, ["1"] = true, ["0"] = false}
	return stringToBool[value]
end

-- converts strings to round integers
function toInteger(n)
	local num = tonumber(n)
	if type(num) == "number" then
		return math.floor(num)
	else
		return nil
	end
end

-- returns the player's name and id formatted nicely
function playerName(peer_id)
	return (server.getPlayerName(peer_id)).."("..string.format("%.0f", peer_id)..")"
end

function getSteamID(peer_id)
	return PLAYER_LIST[peer_id].steam_id or nil
end

-- reformats server.getPlayerList() to be useful
function reformatPlayerList(list)
	local player_list = {}
	for k, v in pairs(list) do
		player_list[v.id] = {steam_id = tostring(v.steam_id), name = v.name}
	end
	return player_list
end

-- general error reporting
function throwError(errorMessage, peer_id)
	server.announce("ERROR", errorMessage..". Please visit the workshop page for this script to see how you can file a bug report.", peer_id or -1)
end

-- warn of non-critical issue
function throwWarning(warningMessage, peer_id)
	server.announce("WARNING", warningMessage, peer_id or -1)
end

-- report bad inputs to user
function invalidArgument(peer_id, place, text)
	server.announce("FAILED", "Argument "..place.." must be "..text, peer_id)
end

-- checks user input type and throws generic error if not valid
function validateInput(peer_id, input, place, accepts)
	local text = ""
	if type(accepts) == "table" then
		for k, v in ipairs(accepts) do
			if type(input) == v then
				return true
			end
			if k > 1 then
				text = text..", "..v
			else
				text = v
			end
		end
	else
		if type(input) == accepts then
			return true
		end
		text = accepts
	end
	invalidArgument(peer_id, place, text)
	return false
end

-- refreshes vehicle popups
function refreshVehicleUI()
	for peer_index, peer_id in ipairs(ID_VIEWERS) do
		for vehicle_id, vehicle_data in pairs(VEHICLE_LIST) do
			local vehicle_pos, found = server.getVehiclePos(vehicle_id)
			if found then
				server.setPopup(peer_id, vehicle_data.ui_id, "", true, vehicle_id.."\n"..playerName(vehicle_data.owner), vehicle_pos[13], vehicle_pos[14], vehicle_pos[15], 50)
			else
				server.removePopup(peer_id, vehicle_data.ui_id)
			end
		end
	end
end

-- refreshes popups to indicate the user is blocking teleports
function drawDenyTeleportUI(peer_id)
	local data = PLAYER_DATA[getSteamID(peer_id)]
	if data.deny_tp then
		data.deny_tp_ui_id = server.getMapID()
		server.setPopupScreen(peer_id, data.deny_tp_ui_id, "deny_tp", true, "Denying Teleports", 0.34, -0.88)
	else
		if data.deny_tp_ui_id then
			server.removeMapID(peer_id, data.deny_tp_ui_id)
		end
	end
end

-- sorts a table by it's values' first value
function quicksort(A, lo, hi)
	if lo < hi then
		local p = partition(A, lo, hi)
		quicksort(A, lo, p - 1)
		quicksort(A, p + 1, hi)
	end
	return A
end
-- part of the quicksort algorithm
function partition(A, lo, hi)
	local pivot = A[hi][1]
	local i = lo
	for j = lo, hi do
		if A[j][1] < pivot then
			A[i], A[j] = A[j], A[i]
			i = i + 1
		end
	end
	A[i], A[hi] = A[hi], A[i]
	return i
end

-- sorts a table by it's keys
function sortByKeys(t)
	local numbered_table = {}
	for k, v in pairs(t) do
		table.insert(numbered_table, k)
	end
	table.sort(numbered_table)
	return numbered_table
end

-- converts multiple table values into one string
function concatTable(t, seperator)
	local text = ""
	for k, v in ipairs(t) do
		if #text > 0 then
			text = text..(seperator or " ")
		end
		text = text..tostring(v)
	end
	return text
end

-- returns a character's inventory as a table
function getInventory(character_id)
	local inventory = {}
	for i=1, #EQUIPMENT_SLOTS do
		local equipment_id, is_success = server.getCharacterItem(character_id, i)
		if not is_success then
			throwWarning("Could not get character's inventory. Defaulting to empty.")
		end
		table.insert(inventory, (is_success and equipment_id) or 0)
	end
	return inventory
end

-- looks at a player's inventory and gives equipment where it fits.
function equipPlayer(peer_id, equipment_list, first_spawn)
	local character_id, success = server.getPlayerCharacterID(peer_id)
	if success then
		-- get current inventory and find empty slots
		local inventory = getInventory(character_id)
		local open_slots = {}
		for k, v in ipairs(EQUIPMENT_SLOTS) do
			if not open_slots[v] then
				open_slots[v] = {}
			end
			if (not first_spawn and inventory[k] == 0) or first_spawn then
				table.insert(open_slots[v], k)
			end
		end
		-- index requested equipment by size
		local requested_inventory = {}
		local new_inventory = {}
		for i=1, clamp(#equipment_list, 0, #EQUIPMENT_SLOTS) do
			local equipment_id = tonumber(equipment_list[i])
			if equipment_id >= 0 or equipment_id <= #EQUIPMENT_SLOTS then
				local size = EQUIPMENT_DATA[equipment_id].size
				if not requested_inventory[size] then
					requested_inventory[size] = {}
				end
				table.insert(requested_inventory[size], equipment_id)
			end
		end
		-- assign slots for requested equipment
		for slot_number, size in ipairs(EQUIPMENT_SLOTS) do
			if requested_inventory[size] then
				if #requested_inventory[size] < 1 then
					requested_inventory[size] = nil
				else
					local equipment_id = table.remove(requested_inventory[size], 1)
					if #open_slots[size] > 0 then
						local slot = table.remove(open_slots[size], 1)
						table.insert(new_inventory, {slot = slot, id = equipment_id, charges = EQUIPMENT_DATA[equipment_id]["charges"], ammo = EQUIPMENT_DATA[equipment_id]["ammo"]})
					else
						table.insert(new_inventory, {slot = slot_number, id = equipment_id, charges = EQUIPMENT_DATA[equipment_id]["charges"], ammo = EQUIPMENT_DATA[equipment_id]["ammo"]})
					end
				end
			end
		end
		-- give player requested equipment
		for k, v in ipairs(new_inventory) do
			local is_success = server.setCharacterItem(character_id, v.slot, v.id, false, v.charges, v.ammo)
			if not is_success then
				throwWarning(string.format("%s %.0f %s %.0f %s %.0f", "Failed to give character", character_id, "equipment", v.id, "in slot", v.slot))
			end
		end
	end
end

-- CALLBACK FUNCTIONS --
function onCreate(is_new)
	-- construct weapon equipment list if weapon DLC active
	if server.dlcWeapons() then
		EQUIPMENT_DATA[31] = {name="C4", size=3, charges=1, ammo=0}
		EQUIPMENT_DATA[32] = {name="C4 detonator", size=3, charges=0, ammo=0}
		EQUIPMENT_DATA[33] = {name="speargun", size=3, charges=1, ammo=0}
		EQUIPMENT_DATA[34] = {name="speargun ammo", size=3, charges=8, ammo=0}
		EQUIPMENT_DATA[35] = {name="pistol", size=3, charges=17, ammo=0}
		EQUIPMENT_DATA[36] = {name="pistol ammo", size=3, charges=17, ammo=0}
		EQUIPMENT_DATA[37] = {name="smg", size=3, charges=40, ammo=0}
		EQUIPMENT_DATA[38] = {name="smg ammo", size=3, charges=40, ammo=0}
		EQUIPMENT_DATA[39] = {name="rifle", size=3, charges=30, ammo=0}
		EQUIPMENT_DATA[40] = {name="rifle ammo", size=3, charges=30, ammo=0}
		EQUIPMENT_DATA[41] = {name="grenade", size=3, charges=1, ammo=0}
		EQUIPMENT_DATA[42] = {name="machine gun ammo kinetic", size=3, charges=50, ammo=0}
		EQUIPMENT_DATA[43] = {name="machine gun ammo high explosive", size=3, charges=50, ammo=0}
		EQUIPMENT_DATA[44] = {name="machine gun ammo fragmentation", size=3, charges=50, ammo=0}
		EQUIPMENT_DATA[45] = {name="machine gun ammo armour piercing", size=3, charges=50, ammo=0}
		EQUIPMENT_DATA[46] = {name="machine gun ammo incendiary", size=3, charges=50, ammo=0}
		EQUIPMENT_DATA[47] = {name="light ammo kinetic", size=3, charges=50, ammo=0}
		EQUIPMENT_DATA[48] = {name="light ammo high explosive", size=3, charges=50, ammo=0}
		EQUIPMENT_DATA[49] = {name="light ammo fragmentation", size=3, charges=50, ammo=0}
		EQUIPMENT_DATA[50] = {name="light ammo armour piercing", size=3, charges=50, ammo=0}
		EQUIPMENT_DATA[51] = {name="light ammo incendiary", size=3, charges=50, ammo=0}
		EQUIPMENT_DATA[52] = {name="rotary ammo kinetic", size=3, charges=25, ammo=0}
		EQUIPMENT_DATA[53] = {name="rotary ammo high explosive", size=3, charges=25, ammo=0}
		EQUIPMENT_DATA[54] = {name="rotary ammo fragmentation", size=3, charges=25, ammo=0}
		EQUIPMENT_DATA[55] = {name="rotary ammo armour piercing", size=3, charges=25, ammo=0}
		EQUIPMENT_DATA[56] = {name="rotary ammo incendiary", size=3, charges=25, ammo=0}
		EQUIPMENT_DATA[57] = {name="heavy ammo kinetic", size=3, charges=10, ammo=0}
		EQUIPMENT_DATA[58] = {name="heavy ammo high explosive", size=3, charges=10, ammo=0}
		EQUIPMENT_DATA[59] = {name="heavy ammo fragmentation", size=3, charges=10, ammo=0}
		EQUIPMENT_DATA[60] = {name="heavy ammo armour piercing", size=3, charges=10, ammo=0}
		EQUIPMENT_DATA[61] = {name="heavy ammo incendiary", size=3, charges=10, ammo=0}
		EQUIPMENT_DATA[62] = {name="battle shell kinetic", size=3, charges=1, ammo=0}
		EQUIPMENT_DATA[63] = {name="battle shell high explosive", size=3, charges=1, ammo=0}
		EQUIPMENT_DATA[64] = {name="battle shell fragmentation", size=3, charges=1, ammo=0}
		EQUIPMENT_DATA[65] = {name="battle shell armour piercing", size=3, charges=1, ammo=0}
		EQUIPMENT_DATA[66] = {name="battle shell incendiary", size=3, charges=1, ammo=0}
		EQUIPMENT_DATA[67] = {name="artillery shell kinetic", size=3, charges=1, ammo=0}
		EQUIPMENT_DATA[68] = {name="artillery shell high explosive", size=3, charges=1, ammo=0}
		EQUIPMENT_DATA[69] = {name="artillery shell fragmentation", size=3, charges=1, ammo=0}
		EQUIPMENT_DATA[70] = {name="artillery shell armour piercing", size=3, charges=1, ammo=0}
		EQUIPMENT_DATA[71] = {name="artillery shell incendiary", size=3, charges=1, ammo=0}
	end
	IS_NEW_SAVE = is_new
	first_to_join = true
	-- check version
	if g_savedata.version then
		local data_version = tonumber(g_savedata.version)
		if data_version > VERSION then
			invalid_version = true
			server.announce("WARNING", "Your code is older than your save data and may not be processed correctly. Please update the script to the latest version. This script will refuse to execute commands in order to protect your data.")
		elseif data_version < VERSION then
			server.announce("UPDATING", "Updating persistent data if necessary.")
			for k, v in pairs(PREFERENCE_DEFAULTS) do
				if not g_savedata.preferences[k] then
					g_savedata.preferences[k] = v
				end
			end
			server.announce("COMPLETE", "Update complete")
		end
	end

	if not invalid_version then
		g_savedata.version = string.format("%0.3f", VERSION)
		-- define if undefined
		g_savedata.vehicle_list = g_savedata.vehicle_list or {}
		g_savedata.object_list = g_savedata.object_list or {}
		g_savedata.player_data = g_savedata.player_data or {}
		g_savedata.banned = g_savedata.banned or {}
		g_savedata.preferences = g_savedata.preferences or PREFERENCE_DEFAULTS
		g_savedata.rules = g_savedata.rules or DEFAULT_RULES
		g_savedata.game_settings = g_savedata.game_settings or {}

		-- create references
		VEHICLE_LIST = g_savedata.vehicle_list
		OBJECT_LIST = g_savedata.object_list -- Not in use yet
		PLAYER_DATA = g_savedata.player_data
		BANNED = g_savedata.banned
		PREFERENCES = g_savedata.preferences
		RULES = g_savedata.rules
		GAME_SETTINGS = g_savedata.game_settings
		PLAYER_LIST = reformatPlayerList(server.getPlayers())
		JOIN_QUEUE = {}
		TELEPORT_QUEUE = {}
		ID_VIEWERS = {}

		-- get game settings, check gamemode, set game settings
		if is_new then
			local game_settings = server.getGameSettings()
			creative_mode = game_settings.settings_menu
			for k, v in pairs(game_settings) do
				local setting_value = (CREATIVE_SETTINGS[k] and creative_mode) or CAREER_SETTINGS[k]
				if setting_value ~= nil then
					server.setGameSetting(k, setting_value)
				end
			end
			GAME_SETTINGS = (CREATIVE_SETTINGS and creative_mode) or CAREER_SETTINGS
		end

		-- get telport zones and index them by name
		TELEPORT_ZONES = {}
		local zones = server.getZones("cc_teleport_zone")
		if #zones > 0 then
			for k, v in pairs(zones) do
				for index, tag in ipairs(v.tags) do
					local front, back, label_type = tag:find("map_label=([^,])")
					if label_type then
						TELEPORT_ZONES[v.name] = {transform = v.transform, ui_id = server.getMapID(), label_type = label_type}
					else
						TELEPORT_ZONES[v.name] = {transform = v.transform, tags = v.tags}
					end
				end
			end
		else
			throwWarning("No teleport zones could be found. You will not be able to use the ?tp command to teleport to named locations.")
		end
	end
end

function onPlayerJoin(steam_id, name, peer_id, admin, auth)
	local first_join
	if invalid_version and (first_to_join and peer_id == 0) or (PLAYER_DATA[steam_id] and PLAYER_DATA[steam_id].permissions and PLAYER_DATA[steam_id].permissions.owner) then -- delay version warnings for when an owner joins
		server.announce("WARNING", "Your code is older than your save data and cannot be processed correctly. Please update the script to the latest version.", peer_id)
	end
	if not invalid_version then
		for k, v in pairs(PLAYER_LIST) do -- in case player crashed and was not logged out properly
			if v.steam_id == steam_id then
				server.announce("Error", "Did your game crash recently? You appear to already be logged on to this server. You have been logged off and on again.", peer_id)
				PLAYER_LIST[k] = nil
				break
			end
		end
		if PLAYER_DATA[steam_id] and PLAYER_DATA[steam_id].permissions then -- if returning player
			local player = PLAYER_DATA[steam_id]
			player.name = name -- refresh name

			if player.permissions.banned then
				server.kickPlayer(peer_id)
			end
		else
			first_join = true
			-- add new player's data to persistent data table
			PLAYER_DATA[tostring(steam_id)] = {
				name = name,
				permissions = {
					owner = peer_id < 1,
					admin = false,
					auth = false
				}
			}
		end
		-- add map labels for some teleport zones
		for k, v in pairs(TELEPORT_ZONES) do
			if v.ui_id then
				server.addMapLabel(peer_id, v.ui_id, v.label_type, k, v.transform[13], v.transform[15]+5)
			end
		end
		if PLAYER_DATA[tostring(steam_id)].deny_tp then
			PLAYER_DATA[tostring(steam_id)].deny_tp_ui_id = server.getMapID()
			drawDenyTeleportUI(peer_id)
		end
		-- add user data to non-persistent table
		PLAYER_LIST[peer_id] = {
			steam_id = tostring(steam_id),
			name = name
		}
		-- add to JOIN_QUEUE to handle equiping and welcome messages
		table.insert(JOIN_QUEUE, {id = peer_id, steam_id = tostring(steam_id), new = first_join})
	end
end

function onPlayerLeave(steam_id, name, peer_id, is_admin, is_auth)
	if not invalid_version then
		if PREFERENCES.remove_vehicle_on_leave then
			for i=#VEHICLE_LIST, 1, -1 do
				if VEHICLE_LIST[i].owner == peer_id then
					server.despawnVehicle(i, false) -- despawn vehicle when unloaded
					table.remove(VEHICLE_LIST, i)
				end
			end
		end
		PLAYER_LIST[peer_id] = nil
	end
end

function onPlayerDie(steam_id, name, peer_id, is_admin, is_auth)
	if not invalid_version then
		if PREFERENCES.keep_inventory then
			local character_id = server.getPlayerCharacterID(peer_id)
			PLAYER_DATA[tostring(steam_id)].inventory = getInventory(character_id)
		end
	end
end

function onPlayerRespawn(peer_id)
	if not invalid_version then
		if PREFERENCES.keep_inventory then
			local steam_id = getSteamID(peer_id)
			if PLAYER_DATA[steam_id].inventory then
				equipPlayer(peer_id, PLAYER_DATA[steam_id].inventory)
				local character_id = server.getPlayerCharacterID(peer_id)
				return
			end
		end
		if PREFERENCES.equip_on_respawn then
			equipPlayer(peer_id, PREFERENCES.start_equipment)
		end
	end
end

function onVehicleSpawn(vehicle_id, peer_id, x, y, z, cost)
	if not invalid_version then
		if peer_id > -1 then
			VEHICLE_LIST[vehicle_id] = {owner = peer_id, ui_id = server.getMapID()}
		end
	end
end

function onVehicleDespawn(vehicle_id, peer_id)
	if not invalid_version then
		if VEHICLE_LIST[vehicle_id] then
			server.removeMapID(-1, VEHICLE_LIST[vehicle_id].ui_id)
			VEHICLE_LIST[vehicle_id] = nil
		end
	end
end

local count = 0
function onTick()
	if not invalid_version then

		-- Make first player to join a DS an owner
		if IS_NEW_SAVE then
			local player_pos, is_success = server.getPlayerPos(0)
			if is_success then
				if player_pos[13] == 0 and player_pos[14] == 0 and player_pos[15] == 0 then
					MAKE_DS_OWNER = true
				else
				end
				IS_NEW_SAVE = false
			end
		end

		refreshVehicleUI()
		if count >= 60 then
			for k, v in ipairs(JOIN_QUEUE) do --check if player has moved or looked around when joining
				local peer_id = v.id
				local player_matrix, success = server.getPlayerPos(peer_id)
				if success then
					local look_x, look_y, look_z, success = server.getPlayerLookDirection(peer_id)
					local look_direction = {look_x, look_y, look_z}
					if success then
						local not_moving = true
						local not_looking = true
						if PLAYER_LIST[peer_id].last_position and PLAYER_LIST[peer_id].last_look_direction then
							if matrix.distance(PLAYER_LIST[peer_id].last_position, player_matrix) > 0.2 then
								not_moving = false
							end
							for h, c in ipairs(look_direction) do
								if PLAYER_LIST[peer_id].last_look_direction[h] - c > 0.01 then
									not_looking = false
								end
							end
						end
						if not_looking and not_moving then
							PLAYER_LIST[peer_id].last_position = player_matrix
							PLAYER_LIST[peer_id].last_look_direction = look_direction
						else
							if MAKE_DS_OWNER then
								PLAYER_DATA[getSteamID(peer_id)].permissions.owner = true
								MAKE_DS_OWNER = false
							end
							-- Display welcome message
							if v.new then
								if PREFERENCES.welcome_new then
									server.announce("Welcome", PREFERENCES.welcome_new, peer_id) -- custom welcome message for new players
								end
								if #RULES > 0 then
									printRules(peer_id)
								end
								-- Give player starting equipment as defined in preferences
								local character_id, is_success = server.getPlayerCharacterID(peer_id)
								for i=1, #EQUIPMENT_SLOTS do
									server.setCharacterItem(character_id, i, 0, false)
								end
								equipPlayer(peer_id, PREFERENCES.start_equipment, true)
							else
								if PREFERENCES.welcome_returning then
									server.announce("Welcome", PREFERENCES.welcome_returning, peer_id) -- custom welcome message for returning players
								end
							end
							if PREFERENCES.auth_all then
								server.addAuth(peer_id)
							end
							-- assign privilages
							if PLAYER_DATA[v.steam_id] and PLAYER_DATA[v.steam_id].permissions then
								if PLAYER_DATA[v.steam_id].permissions.admin then
									server.addAdmin(peer_id)
								end
								if PLAYER_DATA[v.steam_id].permissions.auth then
									server.addAuth(peer_id)
								end
							else
								throwError("Persistent data for "..playerName(peer_id).." could not be found. It is either not defined or corrupted.")
							end
							table.remove(JOIN_QUEUE, k)
						end
					end
				end
			end
			count = 0
		else
			count = count + 1
		end

		-- Re-teleport players to prevent them falling through the ground O_o
		for i=#TELEPORT_QUEUE, 1, -1 do
			local v = TELEPORT_QUEUE[i]
			if v.time <= 0 then
				server.setPlayerPos(v.peer_id, v.target_matrix)
				table.remove(TELEPORT_QUEUE, i)
			else
				v.time = v.time - 1
			end
		end
	end
end

-- ADMIN FUNCTIONS --

function banPlayer(...)
	local args = {...}
	local peer_id = table.remove(args, 1)
	for k, v in ipairs(args) do
		v = toInteger(v)
		local valid = validateInput(peer_id, v, k, "number")
		if valid then
			if v == 0 then
				server.announce("Failed", "The peer id 0 cannot be banned", peer_id)
			else
				if PLAYER_LIST[v] then
					local target_steam_id = getSteamID(v)
					if getSteamID(peer_id) ~= target_steam_id then
						if PLAYER_DATA[target_steam_id] then
							if not PLAYER_DATA[target_steam_id].permissions.admin then
									PLAYER_DATA[target_steam_id].permissions.banned = true
									BANNED[target_steam_id] = getSteamID(peer_id)
									server.kickPlayer(v)
									server.announce("Success", playerName(v) .. " has been banned from the server.", peer_id)
							else
								server.announce("Failed", "You cannot ban an admin.", peer_id)
							end
						end
					else
						server.announce("Failed", "You cannot ban yourself.", peer_id)
					end
				else
					server.announce("Failed", "That player is not on the server.", peer_id)
				end
			end
		end
	end
end

function unbanPlayer(...)
	local args = {...}
	local peer_id = table.remove(args, 1)
	for k, v in ipairs(args) do
		if #v >= #STEAM_ID_MIN then
			if PLAYER_DATA[v] then
				if PLAYER_DATA[v].permissions.banned then
					PLAYER_DATA[v].permissions.banned = false
					BANNED[v] = nil
					server.announce("Success", v.. " has been unbannned.", peer_id)
				else
					server.announce("Failed", v.." is not banned or the steam id is incorrect.", peer_id)
				end
			else
				server.announce("Failed", v.." is not banned", peer_id)
			end
		else
			server.announce("Failed", "Argument must be a steam id", peer_id)
		end
	end
end

function authorizePlayer(...)
	local args = {...}
	local peer_id = table.remove(args, 1)
	for k, v in ipairs(args) do
		v = toInteger(v)
		local valid = validateInput(peer_id, v, k, "number")
		if valid then
			if PLAYER_LIST[v] then
				local target_steam_id = getSteamID(v)
				PLAYER_DATA[target_steam_id].permissions.auth = true
				server.addAuth(v)
				server.notify(v, "Permission Granted", "You were authorized", 4)
				server.announce("Success", playerName(v).." was authorized.", peer_id)
			else
				server.announce("Failed", "That player is not on the server.", peer_id)
			end
		end
	end
end

function deauthorizePlayer(...)
	local args = {...}
	local peer_id = table.remove(args, 1)
	for k, v in ipairs(args) do
		v = toInteger(v)
		local valid = validateInput(peer_id, v, k, "number")
		if valid then
			if PLAYER_LIST[v] then
				local target_steam_id = getSteamID(v)
				PLAYER_DATA[target_steam_id].permissions.auth = false
				server.removeAuth(v)
				server.notify(v, "Permission Lost", "You are no longer authorized", 2)
				server.announce("Success", playerName(v).." is no longer authorized.", peer_id)
			else
				server.announce("Failed", "That player is not on the server.", peer_id)
			end
		end
	end
end

function adminPlayer(...)
	local args = {...}
	local peer_id = table.remove(args, 1)
	for k, v in ipairs(args) do
		v = toInteger(v)
		local valid = validateInput(peer_id, v, k, "number")
		if valid then
			if PLAYER_LIST[v] then
				local target_steam_id = getSteamID(v)
				PLAYER_DATA[target_steam_id].permissions.admin = true
				if not PLAYER_DATA[target_steam_id].permissions.auth then
					authorizePlayer(peer_id)
				end
				server.addAdmin(v)
				server.notify(v, "Permission Granted", "You were made an admin", 4)
				server.announce("Success", playerName(v).." was made an admin.", peer_id)
			else
				server.announce("Failed", "That player is not on the server.", peer_id)
			end
		end
	end
end

function deAdminPlayer(...)
	local args = {...}
	local peer_id = table.remove(args, 1)
	for k, v in ipairs(args) do
		v = toInteger(v)
		local valid = validateInput(peer_id, v, k, "number")
		if valid then
			if PLAYER_LIST[v] then
				local target_steam_id = getSteamID(v)
				PLAYER_DATA[target_steam_id].permissions.admin = false
				server.removeAdmin(v)
				server.notify(v, "Permission Lost", "You are no longer an admin", 2)
				server.announce("Success", playerName(v).." is no longer an admin.", peer_id)
			else
				server.announce("Failed", "That player is not on the server.", peer_id)
			end
		end
	end
end

function addOwner(...)
	local args = {...}
	local peer_id = table.remove(args, 1)
	for k, v in ipairs(args) do
		v = toInteger(v)
		local valid = validateInput(peer_id, v, k, "number")
		if valid then
			if PLAYER_LIST[v] then
				local target_steam_id = getSteamID(v)
				PLAYER_DATA[target_steam_id].permissions.owner = true
				server.addAdmin(v)
				server.notify(v, "Permission Granted", "You were made an owner", 4)
				server.announce("Success", playerName(v).. " was made an owner.", peer_id)
			else
				server.announce("Failed", "That player is not on the server.", peer_id)
			end
		end
	end
end

function removeOwner(...)
	local args = {...}
	local peer_id = table.remove(args, 1)
	for k, v in ipairs(args) do
		v = toInteger(v)
		local valid = validateInput(peer_id, v, k, "number")
		if valid then
			if v ~= 0 then
				if PLAYER_LIST[v] then
					local target_steam_id = getSteamID(v)
					PLAYER_DATA[target_steam_id].permissions.owner = false
					server.notify(v, "Permission Lost", "You are no longer an owner", 2)
					server.announce("Success", playerName(v).. " is no longer an owner.", peer_id)
				else
					server.announce("Failed", "That player is not on the server.", peer_id)
				end
			else
				server.announce("Failed", "You cannot remove ownership status from peer 0.", peer_id)
			end
		end
	end
end

function removeVehicle(...)
	local args = {...}
	local peer_id = table.remove(args, 1)
	local target_id
	local is_success
	if #args > 0 then
		for k, v in ipairs(args) do
			v = toInteger(v)
			valid = validateInput(peer_id, v, k, "number")
			if valid then
				if VEHICLE_LIST[v] then
					target_id = v
				else
					server.announce("Warning", "The vehicle with the id of "..v.." does not exist", peer_id)
					return
				end
			end
		end
	else
		local player_matrix = server.getPlayerPos(peer_id)
		local matrices = {}
		for k,v in pairs(VEHICLE_LIST) do
			table.insert(matrices, {matrix.distance(player_matrix, (server.getVehiclePos(k))), id=k})
		end
		matrices = quicksort(matrices, 1, #matrices)
		target_id = matrices[1].id
	end
	if target_id then
		is_success = server.despawnVehicle(target_id, true)
	end
	if not is_success then
		server.announce("Success", string.format("%s %.0f %s", "Vehicle", target_id, "could not be removed."), peer_id)
	end
end

function setVehicleEditable(peer_id, vehicle_id, state)
	vehicle_id = toInteger(vehicle_id)
	state = (state and stringToBool(state)) or false
	local id_valid = validateInput(peer_id, vehicle_id, 1, "number")
	local state_valid = validateInput(peer_id, state, 2, "boolean")
	if id_valid and state_valid then
		if VEHICLE_LIST[vehicle_id] then
			server.setVehicleEditable(vehicle_id, state)
			server.notify(peer_id, "Success", "Vehicle "..vehicle_id.." has been set to "..((state and "editable") or "non-editable"), 4)
		else
			server.announce("Failed", "The vehicle with the id of "..vehicle_id.." does not exist.", peer_id)
		end
	end
end

function tpPlayerToPlayer(...)
	local args = {...}
	local peer_id = table.remove(args, 1)
	local peer_pos, success = server.getPlayerPos(peer_id)
	if success then
		for k, v in ipairs(args) do
			if v == "*" then
				for k, v in pairs(PLAYER_LIST) do
					if k ~= peer_id then
						local is_success = server.setPlayerPos(k, peer_pos)
						if is_success then
							server.announce("Success", "Telported "..playerName(k).." to your position.", peer_id)
						else
							server.announce("Failed", "Could not teleport "..playerName(k).." to your position.", peer_id)
						end
					end
				end
				server.announce("Success", "Teleported all players to your position.", peer_id)
				return
			else
				v = toInteger(v)
				local valid = validateInput(peer_id, v, k, "number")
				if valid then
					if PLAYER_LIST[v] then
						local is_success = server.setPlayerPos(v, peer_pos)
						if is_success then
							server.announce("Success", "Telported "..playerName(k).." to your position.", peer_id)
						else
							server.announce("Failed", "Could not teleport "..playerName(k).." to your position.", peer_id)
						end
					else
						server.announce("Warning", "The player with the id of "..v.." is not on this server.", peer_id)
					end
				end
			end
		end
	else
		server.announce("Failed", "Something went wrong, please try again.", peer_id)
	end
end

function printVehicleList(peer_id)
	server.announce(" ", "--------------------------  VEHICLE LIST  --------------------------", peer_id)
	for k, v in pairs(VEHICLE_LIST) do
		local vehicle_pos, is_success = server.getVehiclePos(k)
		if not is_success then -- if null vehicle (removed by clean all vehicles / one of the other weird bugs)
			if VEHICLE_LIST[vehicle_id] then
				server.removeMapID(-1, VEHICLE_LIST[vehicle_id].ui_id)
				VEHICLE_LIST[vehicle_id] = nil
			end
		else
			local vehicle_name, is_success = server.getVehicleName(k)
			server.announce(" ", k.." | "..(is_success and vehicle_name or "unknown").." | "..playerName(v.owner), peer_id)
		end
	end
	server.announce(" ", LINE, peer_id)
end

function printPlayerPermissions(peer_id, target_id)
	target_id = toInteger(target_id)
	local valid = validateInput(peer_id, target_id, 1, "number")
	if valid then
		if PLAYER_LIST[target_id] then
			local steam_id = PLAYER_LIST[target_id].steam_id
			local permissions = PLAYER_DATA[steam_id].permissions
			local text = ""
			for k, v in pairs(permissions) do
				if #text > 0 and v and v ~= "" then
					text = text..", "
				end
				if v then
					text = text..k
				end
			end
			server.announce(playerName(target_id), text, peer_id)
		else
			server.announce("Failed", "The player with the id of "..target_id.." is not on this server.", peer_id)
		end
	end
end

function printBannedPlayers(peer_id, page)
	local page_length = 2
	page = toInteger(page) or 1
	page = math.floor(page)
	local valid = validateInput(peer_id, page, 1, "number")
	if valid then
		local numbered_list = {}
		for k, v in pairs(BANNED) do
			table.insert(numbered_list, {k, v})
		end
		if #numbered_list > 0 then
			server.announce(" ", "----------------------  BANNED PLAYERS  -----------------------", peer_id)
			local limit = clamp(page_length*page, 0, #numbered_list)
			for i = clamp((page-1)*(page_length + 1), 1, #numbered_list), limit do
				server.announce(numbered_list[i][1], "Banned by: "..(PLAYER_DATA[numbered_list[i][2]].name), peer_id)
			end
			server.announce(" ", "Page "..math.ceil(page).." of "..math.max(math.ceil(#numbered_list/page_length), 1))
			server.announce(" ", LINE, peer_id)
		else
			server.announce("Ban List", "No one has been banned", peer_id)
		end
	end
end

function addRule(...)
	local args = {...}
	local peer_id = table.remove(args, 1)
	local position
	if tonumber(args[#args]) then
		position = toInteger(table.remove(args))
	else
		position = toInteger(#RULES+1)
	end
	local text = concatTable(args)
	local valid = validateInput(peer_id, position, #args, "number")
	if valid then
		if position > 0 and position <= #RULES + 1 then
			table.insert(RULES, position, text)
			server.announce("Success", "Rule#"..position.." added", peer_id)
		else
			server.announce("Failed", position.." is not a valid position in the rules list.", peer_id)
		end
	end
	printRules(peer_id)
end

function removeRules(...)
	local args = {...}
	local peer_id = table.remove(args, 1)
	for i=#args, 1, -1 do
		v = toInteger(args[i])
		local valid = validateInput(peer_id, v, i, "number")
		if valid then
			if not RULES[v] then
				table.remove(args, i)
				server.announce("Failed", "Rule #"..v.." does not exist", peer_id)
			end
		else
			table.remove(args, i)
		end
	end
	table.sort(args, function(a, b) return a > b end)
	for k, v in ipairs(args)do
		table.remove(RULES, v)
		server.announce("Success", "Removed Rule #"..v, peer_id)
	end
	printRules(peer_id)
end

-- PREFERENCE COMMANDS --

function resetPreferences(peer_id)
	PREFERENCES = PREFERENCE_DEFAULTS
	server.announce("Success", "Preferences have been reset to default values.", peer_id)
end

function setBoolPreference(peer_id, preference, state)
	state = stringToBool(state)
	local valid = validateInput(peer_id, state, 1, "boolean")
	if valid then
		PREFERENCES[preference] = state
		server.announce("Success", preference.." has been set to "..tostring(state), peer_id)
	end
end

function setStringPreference(...)
	local args = {...}
	local peer_id = table.remove(args, 1)
	local preference = table.remove(args, 1)
	local text = concatTable(args)
	PREFERENCES[preference] = text
	server.announce("Success", preference.." has been set to:\n"..text, peer_id)
end

function setPreference(...)
	local redirects = {start_equipment = setStartingEquipment, cheats = setCheats}
	local args = {...}
	local peer_id = table.remove(args, 1)
	local preference = table.remove(args, 1)
	local target_type
	-- redirects passthrough for preferences with custom functions
	if redirects[preference] then
		redirects[preference](peer_id, table.unpack(args))
		return
	end
	-- set preferences
	if PREFERENCES[preference] ~= nil then
		local target_preference = PREFERENCES[preference]
		if type(target_preference) == "table" then
			target_type = type(target_preference[1])
			local t = {}
			for k, v in ipairs(args) do
				local valid = validateInput(peer_id, v, k, target_type)
				if valid then
					table.insert(t, v)
				end
			end
			target_preference = t
			if #t > 1 then
				server.announce("Success", "Set "..preference.." to "..table.concat(t, ", "), peer_id)
			end
		else
			target_type = type(target_preference)
			if target_type == "boolean" then
				setBoolPreference(peer_id, preference, args[1])
			elseif target_type == "string" then
				setStringPreference(peer_id, preference, table.unpack(args))
			end
		end
	else
		server.announce("Failed", "The preference \""..preference.."\" does not exist.", peer_id)
	end
end

function setStartingEquipment(...)
	local args = {...}
	local peer_id = table.remove(args, 1)
	local equipment = {}
	if #args > #EQUIPMENT_SLOTS then
		server.announce("Warning", "You entered more ids for equipment than a player can hold ("..#EQUIPMENT_SLOTS.."). The extras will be ignored.", peer_id)
	end
	for k, v in ipairs(EQUIPMENT_SLOTS) do
		if args[k] then
			local equipment_id = toInteger(args[k])
			if EQUIPMENT_DATA[equipment_id] then
				local size = EQUIPMENT_DATA[equipment_id].size
				if type(equipment_id) == "number" and (equipment_id > 0 and equipment_id <= 27) then
						table.insert(equipment, equipment_id)
				else
					invalidArgument(peer_id, k, "a number between 1 and 27.")
					return
				end
			else
				server.announce("Warning", "The equipment with the id of "..equipment_id.." does not exist", peer_id)
			end
		end
	end
	PREFERENCES.start_equipment = equipment
	server.announce("Success", "Starting equipment set to "..table.concat(equipment,", "), peer_id)
end

function printPreferences(peer_id)
	local text = ""
	local sorted_preferences = sortByKeys(PREFERENCES)
	server.announce("", "--------------------------  PREFERENCES  --------------------------", peer_id)
	for index, key in ipairs(sorted_preferences) do
		local preference = PREFERENCES[key]
		local text = ""
		if type(preference) == "table" then
			text = table.concat(preference,", ")
		else
			text = tostring(preference)
		end
		server.announce(tostring(key), text, peer_id)
	end
	server.announce("", LINE, peer_id)
end

-- GENERAL COMMANDS --

function printRules(peer_id)
	if #RULES > 0 then
		server.announce(" ", "-------------------------------  RULES  ------------------------------", peer_id)
		for k, v in ipairs(RULES) do
			server.announce("Rule #"..k, v, peer_id)
		end
		server.announce(" ", LINE, peer_id)
	else
		server.announce("Rules", "There are no rules.", peer_id)
	end
end

function printAbout(peer_id)
	server.announce(" ", "-------------------------------  ABOUT  ------------------------------", peer_id)
	for k, v in ipairs(ABOUT) do
		server.announce(v.title, v.text, peer_id)
	end
	server.announce(" ", LINE, peer_id)
end

function killPlayer(peer_id, target_id)
	if target_id then
		local target_id = toInteger(target_id)
		local valid = validateInput(peer_id, target_id, 1, "number")
		if valid then
			if not PLAYER_LIST[peer_id] then
				server.announce("Failed", "That player does not exist", peer_id)
				return
			end
			local steam_id = getSteamID(peer_id)
			local permissions = PLAYER_DATA[steam_id].permissions
			if not (permissions.admin or permissions.owner) then
				server.announce("Failed", "You cannot kill other players because you are not an admin.", peer_id)
				return
			else
				local character_id = server.getPlayerCharacterID(target_id)
				server.killCharacter(character_id)
				server.announce("Success", target_id.. " was killed", peer_id)
			end
		else
			server.announce("Failed", target_id.." is not a valid peer_id.", peer_id)
		end
	else
		local character_id = server.getPlayerCharacterID(peer_id)
		server.killCharacter(character_id)
	end
end

function whisper(...)
	local args = {...}
	local peer_id = table.remove(args, 1)
	local target_id = toInteger(table.remove(args, 1))
	local valid = validateInput(peer_id, target_id, 1, "number")
	if valid then
		local message = ""
		for k, v in ipairs(args) do
			if k > 1 then
				message = message.." "
			end
				message = message..v
		end
		server.announce(playerName(peer_id).." (whisper)", message, target_id)
		server.announce("You -> "..playerName(peer_id).." (whisper)", message, peer_id)
	end
end

-- CHEAT COMMANDS --

function setCheats(peer_id, state)
	local state = stringToBool(state)
	local valid = validateInput(peer_id, state, 1, "boolean")
	if valid then
		PREFERENCES.cheats = state
		server.announce("Success", "Cheats set to "..tostring(state), peer_id)
		server.setGameSetting("settings_menu", true)
		if not state then
			for k, v in ipairs(CHEAT_SETTINGS) do
				server.setGameSetting(GAME_SETTING_OPTIONS[v], CAREER_SETTINGS[v])
			end
		end
	end
end

function setGameSetting(...)
	local args = {...}
	local peer_id = table.remove(args, 1)
	local game_setting = table.remove(args, 1):lower()
	local setting_value = stringToBool(table.remove(args, 1))
	local valid = validateInput(peer_id, setting_value, 2, "boolean")
	if valid then
		if not PREFERENCES.cheats then
			for k, v in ipairs(CHEAT_SETTINGS) do
				if v == game_setting then
					server.announce("Denied", "Cheats are currently disabled on this save.", peer_id)
					return
				end
			end
		end
		for k, v in pairs(GAME_SETTING_OPTIONS) do
			if v == game_setting then
				if v == nil then
					server.announce("Failed", "You are not able to edit that setting (game limitation).", peer_id)
					return
				end
				server.setGameSetting(game_setting, setting_value)
				server.announce("Success", game_setting.." has been set to ".. tostring(setting_value), peer_id)
				return
			end
		end
		server.announce("Failed", "The game setting "..game_setting.." does not exist.", peer_id)
	end
end

function printGameSettings(peer_id)
	local text = ""
	local sorted_table = {}
	for k, v in pairs(GAME_SETTING_OPTIONS) do
		table.insert(sorted_table, v)
	end
	table.sort(sorted_table)
	server.notify(peer_id, concatTable(sorted_table, "\n"), "", 1)
end

function equipPlayerCommand(...)
	local args = {...}
	local peer_id = table.remove(args, 1)
	local target_id = toInteger(table.remove(args, 1))
	local valid = validateInput(peer_id, target_id, 2, "number")
	if valid then
		if not PLAYER_LIST[target_id] then
			server.announce("Failed", "The player with the peer id of "..target_id.." does not exist", peer_id)
			return
		end
		if #args > 6 then
			server.announce("Warning", "A player can only hold a max of 6 items. The first six have been equipped.", peer_id)
			for i=#args, 7, -1 do
				table.remove(args, i)
			end
		end
		for i=#args, 1, -1 do
			local equipment_id = toInteger(args[i])
			local valid = validateInput(peer_id, toInteger(equipment_id), i, "number")
			if valid then
				if not (equipment_id > 0 and equipment_id <= #EQUIPMENT_DATA) then
					server.announce("Warning", "The equipment with the id of "..equipment_id.." does not exist. It will be ignored", peer_id)
					table.remove(args, i)
				end
			else
				table.remove(args, i)
			end
		end
		equipPlayer(target_id, args)
		server.announce("Success", PLAYER_LIST[target_id].name .. " was given:", peer_id)
		for k, v in ipairs(args) do
			server.announce(" ", tostring(EQUIPMENT_DATA[toInteger(v)].name), peer_id)
		end
	end
end

function printEquipmentIDs(peer_id)
	local text = ""
	for k, v in ipairs(EQUIPMENT_DATA) do
		text = text..((k == 1 and "["..k.."]="..v.name) or ("\n".."["..k.."]="..v.name))
	end
	server.notify(peer_id, text, "", 1)
end

function announceEquipmentIDs(peer_id)
	local text = ""
	for k, v in ipairs(EQUIPMENT_DATA) do
		text = text..((k == 1 and "["..k.."]="..v.name) or ("\n".."["..k.."]="..v.name))
	end
	server.announce("", "Equipment IDs", peer_id)
	server.announce("", text, peer_id)
end

function levenshteinDistance(v1, v2)
	v1 = v1:lower()
	v2 = v2:lower()
	local len1 = string.len(v1)
	local len2 = string.len(v2)
	local d = {}
	local substitution = 0
	if v1 == v2 then --if string is exact match
		return 0
	end
	if v1 == nil then
		return #v2
	elseif v2 == nil then
		return #v1
	end
	-- create matrix for levenshtein algorithm
	for i=0, len1 do
		d[i] = {}
		d[i][0] = i
	end
	for j=0, len2 do
		d[0][j] = j
	end
	-- perform levenshtein algorithm
	for i=1, len1 do
		for j=1, len2 do
			if v1:byte(i) == v2:byte(j) then
				substitution = 0
			else
				substitution = 1
			end
			d[i][j] = math.min(d[i-1][j] + 1, d[i][j-1] + 1, d[i-1][j-1] + substitution)
		end
	end
	-- return edit distance between strings
	return d[len1][len2]
end

function similarStringInTable(s, t)
	local most_similar = {}
	for k, v in pairs(t) do
		local distance = levenshteinDistance(s, v)
		if distance <= math.max(#s//3, 2) then
			table.insert(most_similar, {distance, id=k})
		end
	end
	for k, v in ipairs(most_similar) do
		quicksort(most_similar, 1, #most_similar)
	end
	if #most_similar > 0 then
		return most_similar[1].id
	else
		return nil
	end
end

function teleportPlayer(...)
	local args = {...}
	local peer_id = table.remove(args, 1)
	local target_matrix = {}
	local re_teleport = true -- prevent player from falling through the ground
	local as_num = toInteger(args[1])
	local permissions = PLAYER_DATA[getSteamID(peer_id)].permissions
	if server.getGameSettings().map_teleport or permissions.admin or permissions.owner then -- prevent teleport unless "Allow teleport" is enabled or owner/admin
		if type(as_num) == "number" then
			if #args == 1 then
				if PLAYER_DATA[getSteamID(as_num)] then
					if PLAYER_DATA[getSteamID(as_num)].deny_tp then -- and not (permissions.admin or permissions.owner)
						server.announce("Denied", "That player has blocked teleports", peer_id)
						return
					end
					target_matrix, found = server.getPlayerPos(as_num)
					if not found then
						server.announce("Failed", "Could not find a player with the id of "..args[1], peer_id)
						return
					end
				end
			elseif #args >= 3 then
				target_matrix = matrix.translation(as_num, tonumber(args[2]), tonumber(args[3]))
			end
		else
			local location = concatTable(args, " "):lower()
			local teleport_names = {}
			for k, v in pairs(TELEPORT_ZONES) do
				table.insert(teleport_names, k)
			end
			local location_name = teleport_names[similarStringInTable(location, teleport_names)]
			if location_name == nil then
				server.announce("Failed", "Could not find the location \""..location.."\"", peer_id)
				return
			else
				target_matrix = TELEPORT_ZONES[location_name].transform
				local player_pos, is_success = server.getPlayerPos(peer_id)
				if is_success then
					local distance = matrix.distance(player_pos, target_matrix)
					if distance < 1000 then
						re_teleport = false
					end
				end
			end
		end
		if #target_matrix > 1 then
			server.setPlayerPos(peer_id, target_matrix)
			if re_teleport then
				table.insert(TELEPORT_QUEUE, {peer_id = peer_id, target_matrix = target_matrix, time = 40})
			end
		end
	else
		server.announce("Denied", "\"map_teleport\" (\"Allow Teleport\" in custom options menu) is disabled.", peer_id)
	end
end

function printTeleportLocations(peer_id)
	local text = ""
	local sorted_table = sortByKeys(TELEPORT_ZONES)
	server.announce(" ", "--------------------------  TP LOCATIONS  ------------------------", peer_id)
	server.announce(" ", concatTable(sorted_table, ",   "), peer_id)
	server.announce(" ", LINE, peer_id)
end

function denyTeleport(peer_id)
	local data = PLAYER_DATA[getSteamID(peer_id)]
	if data.deny_tp then
		data.deny_tp = false
	else
		data.deny_tp = true
	end
	drawDenyTeleportUI(peer_id)
end

function toggleIDs(peer_id)
	for k, v in ipairs(ID_VIEWERS) do
		if v == peer_id then
			table.remove(ID_VIEWERS, k)
			for k, v in pairs(VEHICLE_LIST) do
				server.removePopup(peer_id, v.ui_id)
			end
			server.announce("Success", "IDs have been toggled off.", peer_id)
			return
		end
	end
	-- if not in table and now removed
	table.insert(ID_VIEWERS, peer_id)
	server.announce("Success", "IDs have been toggled on.", peer_id)
end

function teleportVehicle(peer_id, vehicle_id)
	vehicle_id = toInteger(vehicle_id)
	local valid = validateInput(peer_id, vehicle_id, 1, "number")
	if valid then
		if VEHICLE_LIST[vehicle_id] then
			local player_pos = server.getPlayerPos(peer_id)
			player_pos[14] = player_pos[14] + 3
			local success = server.setVehiclePos(vehicle_id, player_pos)
			if success then
				server.announce("Success", "Teleported "..vehicle_id.." to your position.", peer_id)
			else
				server.announce("Failed", "Could not teleport "..vehicle_id.." to your location. Please try again.", peer_id)
			end
		else
			server.announce("Failed", "The vehicle with the id of "..vehicle_id.." does not exist", peer_id)
		end
	end
end

function healPlayer(peer_id, target_id, amount)
	target_id = toInteger(target_id)
	local valid_target = validateInput(peer_id, target_id, 1, "number")
	local valid_amount
	if amount then
		amount = tonumber(amount)
		 valid_amount = validateInput(peer_id, amount, 2, "number")
	end
	-- catch invalid inputs
	if (amount and not valid_amount) or not valid_target then
		return
	end
	if PLAYER_LIST[target_id] then
		local character_id = server.getPlayerCharacterID(target_id)
		local c_data = server.getCharacterData(character_id)
		local hp = c_data["hp"]
		local is_incapacitated = c_data["incapacitated"]
		local is_dead = c_data["dead"]
		if is_dead or is_incapacitated then
			server.reviveCharacter(character_id)
		end
		local hp = clamp(amount and (hp + amount) or 100, 0, 100)
		server.setCharacterData(character_id, hp, false, false)
		server.announce("Success", "Healed "..playerName(target_id).." to "..string.format("%.0f%%", math.floor(hp)), peer_id)
	else
		server.announce("Failed", "The player with the peer_id of "..target_id.." does not exist on this server.", peer_id)
	end
end

function giveMoney(peer_id, amount)
	amount = toInteger(amount)
	local valid = validateInput(peer_id, amount, 1, "number")
	if valid then
		local money = server.getCurrency()
		local research = server.getResearchPoints()
		server.setCurrency(math.min(money + amount, 999999999), research)
		server.announce("Success", "You were given $"..math.min(amount, 999999999), peer_id)
	end
end

function printHelp(peer_id)
	local sorted = sortByKeys(COMMANDS)
	local permissions = PLAYER_DATA[getSteamID(peer_id)].permissions
	server.announce(" ", "---------------------------------  HELP  -------------------------------", peer_id)
	server.announce(" ", "[ ] = optional                                        ... = repeatable", peer_id)
	for k, v in ipairs(sorted) do
		local data = COMMANDS[v]
		local disallowed = true

		if data.access then
			-- if admin permissions required
			if data.access[2] and permissions.admin then
				disallowed = false
			end
			-- if authorized permissions required
			if data.access[1] and permissions.auth then
				disallowed = false
			end
		else
			disallowed = false
		end
		-- deny cheat commands
		if data.cheat and not PREFERENCES.cheats and not (permissions.admin) then
			disallowed = true
		end
		-- if owner permissions granted
		if permissions.owner then
			disallowed = false
		end
		-- print function if player has access
		if not disallowed then
			printCommandToChat(v, peer_id)
			if k < #sorted then
				server.announce(" ", "\n", peer_id)
			end
		end
	end
	server.announce("", LINE, peer_id)
end

-- list of all commands
-- access: authorized, admin
COMMANDS = {
	-- Moderation Commands --
	ban_player = {
		func = banPlayer,
		access = {false, true},
		args = {req = {"peer_id"}, "..."},
		description = "Bans a player so that when they join they are immediately kicked. Replacement for vanilla perma-ban (?ban)."
	},
	unban = {
		func = unbanPlayer,
		access = {false, true},
		args = {req = {"steam_id"}, "..."},
		description = "Unbans a player from the server."
	},
	auth = {
		func = authorizePlayer,
		access = {false, true},
		args = {req = {"peer_id"}, "..."},
		description = "Authorizes a player to spawn vehicles and edit unlocked settings."
	},
	de_auth = {
		func = deauthorizePlayer,
		access = {false, true},
		args = {req = {"peer_id"}, "..."},
		description = "Deauthorizes a player."
	},
	admin = {
		func = adminPlayer,
		access = {false, false},
		args = {req = {"peer_id"}, "..."},
		description = "Gives a player admin permissions."
	},
	de_admin = {
		func = deAdminPlayer,
		access = {false, false},
		args = {req= {"peer_id"}, "..."},
		description = "Removes a player's admin permissions."
	},
	add_owner = {
		func = addOwner,
		access = {false, false},
		args = {req = {"peer_id"}, "..."},
		description = "Gives a player owner permissions. An owner has access to all commands and can admin others."
	},
	remove_owner = {
		func = removeOwner,
		access = {false, false},
		args = {req = {"peer_id"}, "..."},
		description = "Removes a player's owner permissions."
	},
	remove_vehicle = {
		func = removeVehicle,
		access = {false, true},
		args = {"vehicle_id", "..."},
		description = "Removes vehicles by their id. If no ids are given, it will remove the nearest vehicle."
	},
	set_editable = {
		func = setVehicleEditable,
		access = {false, true},
		args = {req={"vehicle_id", "true/false/1/0"}},
		description = "Sets a vehicle to either be editable or non-editable."
	},
	tp2me = {
		func = tpPlayerToPlayer,
		access = {false, true},
		args = {req={"peer_id"}, "..."},
		description = "Teleports specified player(s) to you. Use * to teleport all players to you."
	},
	vehicle_list = {
		func = printVehicleList,
		access = {false, true},
		description = "Lists all the vehicles that the server is tracking."
	},
	player_perms = {
		func = printPlayerPermissions,
		access = {false, true},
		args = {req={"peer_id"}},
		description = "Shows the permissions that the specified player has."
	},
	banned = {
		func = printBannedPlayers,
		access = {false, true},
		args = {"page"},
		description = "Shows the list of banned players."
	},
	add_rule = {
		func = addRule,
		access = {false, true},
		args = {req={"rule"}, "position"},
		description = "Adds a rule to the rule list. If last word is not a number (assumed to be position) then position will default to end of rule list."
	},
	remove_rule = {
		func = removeRules,
		access = {false, true},
		args = {req={"rule#"}, "..."},
		description = "Removes the specified rule(s) from the list."
	},
	reset_preferences = {
		func = resetPreferences,
		access = {false, true},
		description = "Resets the preferences to the defaults."
	},

	-- Preferences edit Commands --
	set_preference = {
		func = setPreference,
		access = {false, true},
		args = {req={"preference", "state"}},
		description = "Sets the specified preference to the given value/state. Use ?preferences to see the options."
	},
	preferences = {
		func = printPreferences,
		access = {false, true},
		description = "Shows the preferences and their states."
	},

	-- General commands --
	about = {
		func = printAbout,
		description = "Shows info about this script."
	},
	rules = {
		func = printRules,
		description = "Shows the rules of this server."
	},
	kill = {
		func = killPlayer,
		args = {"peer_id"},
		description = "Kills yourself. If admin, can be used to kill others."
	},
	whisper = {
		func = whisper,
		args = {req={"peer_id", "message"}},
		description = "Whispers your message to the specified player."
	},
	help = {
		func = printHelp,
		description = "Shows help for all the commands you have access to."
	},

	-- Cheat commands --
	cheats = {
		func = setCheats,
		access = {false, true},
		args = {req = {"true/false/1/0"}},
		description = "Disables cheats such as unlimited money, teleport, etc."
	},
	set_game_setting = {
		func = setGameSetting,
		cheat = true,
		access = {false, true},
		args = {req = {"game_setting_name", "state"}},
		description = "Changes the game settings for this save. Cheats may need to be enabled for some settings."
	},
	game_settings = {
		func = printGameSettings,
		cheat = true,
		access = {false, true},
		description = "Displays the various game settings."
	},
	equip = {
		func = equipPlayerCommand,
		cheat = true,
		access = {true},
		args = {req = {"peer_id", "equipment_id"}, "..."},
		description = "Gives the selected player equipment."
	},
	equipment_ids = {
		func = printEquipmentIDs,
		cheat = true,
		access = {true},
		description = "Displays the ids for equipment."
	},
	equipment_ids_chat = {
		func = announceEquipmentIDs,
		cheat = true,
		access = {true},
		description = "Displays the ids for equipment in the chat box."
	},
	tp = {
		func = teleportPlayer,
		cheat = true,
		access = {true},
		args = {req={"peer_id/location_name/coordinates(x y z)"}},
		description = "Teleports you to the specified player/location/coordinates."
	},
	tp_locations = {
		func = printTeleportLocations,
		cheat = true,
		access = {true},
		description = "Displays the locations you can telport to."
	},
	deny_tp = {
		func = denyTeleport,
		cheat = true,
		access = {},
		description = "Denies attempts to teleport to you while enabled."
	},
	toggle_ids = {
		func = toggleIDs,
		cheat = true,
		access = {true},
		description = "Toggles showing vehicle IDs for nearby vehicles."
	},
	tp_vehicle = {
		func = teleportVehicle,
		cheat = true,
		access = {false, true},
		args = {req={"vehicle_id"}},
		description = "Teleports a vehicle to your current location."
	},
	heal = {
		func = healPlayer,
		cheat = true,
		access = {false, true},
		args = {req={"peer_id"},"1-100"},
		description = "Heals the target player by x%. Defaults to 100%."
	},
	bailout = {
		func = giveMoney,
		cheat = true,
		access = {false, true},
		args = {req={"$amount"}},
		description = "Gives the \"player\" the specified amount of money."
	}
}

function printCommandToChat(command, peer_id)
	local data = COMMANDS[command]
	local perms = ""
	local args = " "
	local perm_levels = {"authorized", "admin", "owner"}
	-- prepare arguments string
	if data.args then
		if data.args.req then
			for i=1, #data.args.req do
				if #args > 1 then
					args = args..string.format(", %s", data.args.req[i])
				else
					args = data.args.req[i]
				end
			end
		end
		for i=1, #data.args do
			if #args > 1 then
				args = args..string.format(" [, %s]", data.args[i])
			else
				args = string.format("[%s]", data.args[i])
			end
		end
	else
		args = ""
	end
	server.announce("?"..command, args..(#args > 0 and "\n" or "")..data.description, peer_id)
end

function switch(peer_id, permissions, command, args)
	if COMMANDS[command] then
		local data = COMMANDS[command]
		-- throw errors if perms are not correct
		local disallowed = true

		if data.access then
			-- if admin permissions required
			if data.access[2] and permissions[2] then
				disallowed = false
			elseif data.access[2] and not permissions[2] then
				server.announce("Denied", "You are not an admin and do not have access to that command.", peer_id)
			end
			-- if authorized permissions required
			if data.access[1] and permissions[1] then
				disallowed = false
			elseif data.access[1] and not permissions[1] then
				server.announce("Denied", "You are not authorized and do not have access to that command.", peer_id)
			end
		else
			disallowed = false
		end
		-- deny cheat commands
		if data.cheat and not PREFERENCES.cheats and not (permissions[3] or permissions[2]) then
			server.announce("Denied", "Cheats are not enabled.", peer_id)
			disallowed = true
		end
		-- if owner permissions granted
		if permissions[3] then
			disallowed = false
		end
		-- return if not allowed to call command
		if disallowed then
			return
		end
		-- throw an error if too few arguments given
		if data.args and data.args.req and #args < #data.args.req then
			server.announce("Failed", "?"..command.." requires "..#data.args.req.." arguments.", peer_id)
			server.announce(" ", "---------------------------------  HELP  -------------------------------", peer_id)
			server.announce(" ", "[ ] = optional                                        ... = repeatable", peer_id)
			printCommandToChat(command, peer_id)
			server.announce(" ", LINE, peer_id)
			return
		end
		-- pass pre-defined values
		local passed = {}
		if data.pass then
			for k, v in ipairs(data.pass) do
				table.insert(passed, v)
			end
		end
		-- call function
		if #passed > 0 then
			data.func(peer_id, table.unpack(passed), table.unpack(args))
		else
			data.func(peer_id, table.unpack(args))
		end
	end
end

function onCustomCommand(message, peer_id, admin, auth, command, ...)
	if invalid_version then
		server.announce("WARNING", "Your code is older than your save data and cannot be processed correctly. Please update the script to the latest version.", peer_id)
	else
		local args = {...}
		local steam_id = getSteamID(peer_id)
		if not PLAYER_DATA[steam_id] or not PLAYER_DATA[steam_id].permissions then
			throwError("Persistent data for "..playerName(peer_id).." could not be found. It is either not defined or corrupted.")
			onPlayerJoin(steam_id, server.getPlayerName(peer_id), peer_id)
		end
		local owner = PLAYER_DATA[steam_id].permissions.owner or false
		local permissions = {auth, admin, owner}
		command = command:sub(2)
		switch(peer_id, permissions, command, args)
	end
end
