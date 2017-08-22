local levels = {}

local SPEED_MULTIPLER = 0.05
local JUMP_MULTIPLER = 0.01

function levels.update_stats(player_name)
  local player = minetest.get_player_by_name(player_name)

  local player_agi = tonumber(player:get_attribute("levels:agi") or 0)
  local player_str = tonumber(player:get_attribute("levels:str") or 0)
  local player_int = tonumber(player:get_attribute("levels:int") or 0)

  player:set_physics_override({
    speed = 1.0 + player_agi * SPEED_MULTIPLER,
    jump = 1.0 + player_agi * JUMP_MULTIPLER,
    gravity = 1.0,
    sneak = true,
    sneak_glitch = true
  })
end

function levels.show_ui(player_name)
  local player = minetest.get_player_by_name(player_name)
  if not player then
    return false
  end

  local player_agi = tonumber(player:get_attribute("levels:agi") or 0)
  local player_str = tonumber(player:get_attribute("levels:str") or 0)
  local player_int = tonumber(player:get_attribute("levels:int") or 0)

  local upgrade_points = tonumber(player:get_attribute("levels:points") or 0)

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
                    "label[0,0;Character level 29]" ..
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
                "label[0,0;Character level 29]" ..
                "label[0,3.5;Leftover points: " .. upgrade_points .. "]" ..
                "button_exit[0,4;2.75,1;exit;Done]"
  end

  minetest.show_formspec(player_name, "levels:levels_formspec", levels_ui)
end
minetest.register_on_joinplayer(function(player)
  player:set_attribute("levels:points", 20)
  player:hud_add({
    hud_elem_type = "image",
    scale = {x=2,y=2},
    text = "3.png",
    position = {x=0.5,y=0.5},
    offset = {x=0,y=0}
  })
  levels.update_stats(player:get_player_name())
end)
minetest.register_chatcommand("levels", {
	description = "Open levels UI",
	func = function(name, text)
    levels.show_ui(name)
		return true
	end,
})
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "levels:levels_formspec" then
    local player_agi = tonumber(player:get_attribute("levels:agi") or 0)
    local player_str = tonumber(player:get_attribute("levels:str") or 0)
    local player_int = tonumber(player:get_attribute("levels:int") or 0)

    local upgrade_points = tonumber(player:get_attribute("levels:points") or 0)

    if fields.upgrade_agi then
      player:set_attribute("levels:agi", player_agi + 1)
      player:set_attribute("levels:points", upgrade_points - 1)
      levels.update_stats(player:get_player_name())
      levels.show_ui(player:get_player_name())
    end
    if fields.upgrade_str then
      player:set_attribute("levels:str", player_str + 1)
      player:set_attribute("levels:points", upgrade_points - 1)
      levels.update_stats(player:get_player_name())
      levels.show_ui(player:get_player_name())
    end
    if fields.upgrade_int then
      player:set_attribute("levels:int", player_int + 1)
      player:set_attribute("levels:points", upgrade_points - 1)
      levels.update_stats(player:get_player_name())
      levels.show_ui(player:get_player_name())
    end
		minetest.chat_send_all("Player "..player:get_player_name().." submitted fields "..dump(fields))
	end
end)
