local path = minetest.get_modpath("levels")
dofile(path .. "/api.lua")

local levels = {}

local ores = {
  {"default:stone_with_coal", 5},
  {"default:stone_with_iron", 10},
  {"default:stone_with_copper", 10},
  {"default:stone_with_tin", 15},
  {"default:stone_with_gold", 25},
  {"default:stone_with_mese", 30},
  {"default:stone_with_diamond", 30}
}

local SPEED_MULTIPLER = 0.05
local JUMP_MULTIPLER = 0.01

function levels.update_stats(player_name)
  local player = minetest.get_player_by_name(player_name)

  local player_agi = levels_api.get_player_attribute(player_name, "levels:agi", 0)
  local player_str = levels_api.get_player_attribute(player_name, "levels:str", 0)
  local player_int = levels_api.get_player_attribute(player_name, "levels:int", 0)

  player:set_physics_override({
    speed = 1.0 + player_agi * SPEED_MULTIPLER,
    jump = 1.0 + player_agi * JUMP_MULTIPLER,
    gravity = 1.0,
    sneak = true,
    sneak_glitch = true
  })
end

function levels.show_ui(player_name)
  local player_agi = levels_api.get_player_attribute(player_name, "levels:agi", 0)
  local player_str = levels_api.get_player_attribute(player_name, "levels:str", 0)
  local player_int = levels_api.get_player_attribute(player_name, "levels:int", 0)

  local player_lvl = levels_api.get_player_attribute(player_name, "levels:level", 1)

  local upgrade_points = levels_api.get_player_attribute(player_name, "levels:points", 0)

  local levels_ui = "size[3,5;]" ..
                    "button[1,0.5;1,1;upgrade_agi;+]" ..
                    "button[1,1.5;1,1;upgrade_str;+]" ..
                    "button[1,2.5;1,1;upgrade_int;+]" ..
                    "label[0,0.75;AGI]" ..
                    "label[0,1.75;STR]" ..
                    "label[0,2.75;INT]" ..
                    "label[2,0.75;" .. player_agi .. "]" ..
                    "label[2,1.75;" .. player_str .. "]" ..
                    "label[2,2.75;" .. player_int .. "]" ..
                    "label[0,0;Character level " .. player_lvl .. "]" ..
                    "label[0,3.5;Leftover points: " .. upgrade_points .. "]" ..
                    "button_exit[0,4;2.75,1;exit;Done]"
  if upgrade_points == 0 then
    levels_ui = "size[3,5;]" ..
                "label[0,0.75;AGI]" ..
                "label[0,1.75;STR]" ..
                "label[0,2.75;INT]" ..
                "label[2,0.75;" .. player_agi .. "]" ..
                "label[2,1.75;" .. player_str .. "]" ..
                "label[2,2.75;" .. player_int .. "]" ..
                "label[0,0;Character level " .. player_lvl .. "]" ..
                "label[0,3.5;Leftover points: " .. upgrade_points .. "]" ..
                "button_exit[0,4;2.75,1;exit;Done]"
  end

  minetest.show_formspec(player_name, "levels:levels_formspec", levels_ui)
end
minetest.register_on_joinplayer(function(player)
  levels.update_stats(player:get_player_name())
  levels_api.update_hud(player:get_player_name())
end)
minetest.register_on_newplayer(function(player)
	levels_api.increment_attribute(player:get_player_name(), "levels:points")
end)
minetest.register_chatcommand("levels", {
	description = "Open levels UI",
	func = function(name, text)
    levels.show_ui(name)
		return true
	end,
})
minetest.register_chatcommand("givexp", {
	description = "Give yourself some nice XP!",
	func = function(name, text)
    levels_api.set_player_attribute(name, "levels:xp", levels_api.get_player_attribute(name, "levels:xp", 0) + text)
    levels_api.update_level(name)
    return true
	end,
})
minetest.register_chatcommand("getxp", {
	description = "How much XP have we got here?",
	func = function(name, text)
		return true, levels_api.get_player_attribute(name, "levels:xp", 0)
	end,
})
function levels.upgrade_attribute(name, attr)
  levels_api.increment_attribute(name, attr)
  levels_api.decrement_attribute(name, "levels:points")
  levels.update_stats(name)
  levels.show_ui(name)
end
minetest.register_on_player_receive_fields(function(player, formname, fields)
  player_name = player:get_player_name()
	if formname == "levels:levels_formspec" then
    if fields.upgrade_agi then
      levels.upgrade_attribute(player_name, "levels:agi")
    end
    if fields.upgrade_str then
      levels.upgrade_attribute(player_name, "levels:str")
    end
    if fields.upgrade_int then
      levels.upgrade_attribute(player_name, "levels:int")
    end
  end
end)
minetest.register_on_dignode(function(pos, oldnode, player)
  local name = oldnode.name
  for key,value in pairs(ores) do
    if value[1] == name then
      levels_api.set_player_attribute(player:get_player_name(), "levels:xp", levels_api.get_player_attribute("singleplayer","levels:xp", 0) + value[2])
      levels_api.update_level(player:get_player_name())
    end
  end
end)
