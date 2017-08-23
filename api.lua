levels_api = {}

function levels_api.get_player_attribute(name, attr)
  local player = minetest.get_player_by_name(name)
  if not player then
    return false
  end
  return tonumber(player:get_attribute(attr) or 0)
end

function levels_api.set_player_attribute(name, attr, value)
  local player = minetest.get_player_by_name(name)
  if not player then
    return false
  end
  return tonumber(player:set_attribute(attr, value) or 0)
end

function levels_api.increment_attribute(name, attr)
  levels_api.set_player_attribute(name, attr, levels_api.get_player_attribute(name, attr) + 1)
  return true
end

function levels_api.decrement_attribute(name, attr)
  levels_api.set_player_attribute(name, attr, levels_api.get_player_attribute(name, attr) - 1)
  return true
end
function levels_api.upgrade_attribute(name, attr)
  levels_api.increment_attribute(name, attr)
  levels_api.decrement_attribute(name, "levels:points")
  levels.update_stats(name)
  levels.show_ui(name)
end
