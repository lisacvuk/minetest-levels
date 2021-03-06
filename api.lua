levels_api = {}
levels_api.player_hud_ids = {}
local ADDED_XP_PER_LEVEL = 100

function levels_api.get_player_attribute(name, attr, defval)
  minetest.debug(name)
  local player = minetest.get_player_by_name(name)
  if not player then
    return false
  end
  return tonumber(player:get_attribute(attr) or defval)
end

function levels_api.set_player_attribute(name, attr, value)
  local player = minetest.get_player_by_name(name)
  if not player then
    return false
  end
  player:set_attribute(attr, value)
end

function levels_api.increment_attribute(name, attr)
  local current_attr = levels_api.get_player_attribute(name, attr, 0) or 0
  levels_api.set_player_attribute(name, attr, current_attr + 1)
  return true
end

function levels_api.decrement_attribute(name, attr)
  local current_attr = levels_api.get_player_attribute(name, attr, 0)
  levels_api.set_player_attribute(name, attr, current_attr - 1)
  return true
end
function levels_api.get_needed_xp(name)
  local current_level = levels_api.get_player_attribute(name, "levels:level", 1)
  local current_xp = levels_api.get_player_attribute(name, "levels:xp", 0)
  local needed_xp = ADDED_XP_PER_LEVEL * current_level
  return needed_xp
end
function levels_api.update_hud(name)
  local current_level = levels_api.get_player_attribute(name, "levels:level", 1)
  local current_xp = levels_api.get_player_attribute(name, "levels:xp", 0)
  local player = minetest.get_player_by_name(name)
  if levels_api.player_hud_ids[name] then
    player:hud_remove(levels_api.player_hud_ids[name])
  end
  levels_api.player_hud_ids[name] = player:hud_add({
    hud_elem_type = "text",
    text = current_xp .. " / " .. levels_api.get_needed_xp(name),
    position = {x=0.5,y=0.5},
    number = 0xFFFFFF,
  })
end
function levels_api.update_level(name)
  local current_level = levels_api.get_player_attribute(name, "levels:level", 1)
  local current_xp = levels_api.get_player_attribute(name, "levels:xp", 0)
  local needed_xp = ADDED_XP_PER_LEVEL * current_level
  while current_xp >= needed_xp do
    minetest.chat_send_player(name, "You have leveled up!")
    minetest.chat_send_player(name, "You have received 1 more attribute point.")
    current_level = current_level + 1
    current_xp = current_xp - needed_xp
    levels_api.increment_attribute(name, "levels:points")
    needed_xp = ADDED_XP_PER_LEVEL * current_level
  end
  levels_api.set_player_attribute(name, "levels:level", current_level)
  levels_api.set_player_attribute(name, "levels:xp", current_xp)
  levels_api.update_hud(name)
end
