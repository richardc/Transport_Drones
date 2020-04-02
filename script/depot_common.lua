local road_network = require("script/road_network")

local depot_names =
{
  ["request-depot"] = require("script/depots/request_depot"),
  ["supply-depot"] = require("script/depots/supply_depot"),
  ["supply-depot-chest"] = require("script/depots/supply_depot"),
  ["fuel-depot"] = require("script/depots/fuel_depot"),
  ["mining-depot"] = require("script/depots/mining_depot"),
  ["fluid-depot"] = require("script/depots/fluid_depot")
}

local script_data = 
{
  depots = {},
  update_order = {},
  last_update_index = 0
}

local get_depot = function(entity)
  return script_data.depots[tostring(entity.unit_number)]
end

local get_corpse_position = function(entity, corpse_offsets)

  local position = entity.position
  local direction = entity.direction
  local offset = corpse_offsets[direction]
  return {position.x + offset[1], position.y + offset[2]}

end

local refund_tile_placement = function(surface, event, position)
  local insert = event.robot and event.robot.get_inventory(defines.inventory.robot_cargo).insert or event.player_index and game.get_player(event.player_index).insert
  if not insert then return end
  local tile = surface.get_tile(position)
  local mineable_properties = tile.prototype.mineable_properties
  if not mineable_properties.minable then return end
  for k, product in pairs (mineable_properties.products) do
    if product.amount >= 1 then
      insert{name = product.name, count = product.amount}
    end
  end
end

local attempt_to_place_node = function(entity, depot_lib, event)
  local corpse_position = get_corpse_position(entity, depot_lib.corpse_offsets)
  local surface = entity.surface

  if not surface.can_place_entity(
    {
      name = "road-tile-collision-proxy",
      position = corpse_position,
      build_check_type = defines.build_check_type.manual
    }) then
    surface.create_entity{name = "flying-text", text = "Road placement blocked", position = corpse_position}
    return
  end

  
  local node_position = {math.floor(corpse_position[1]), math.floor(corpse_position[2])}
  refund_tile_placement(surface, event, node_position)
  surface.set_tiles
  {
    {name = "transport-drone-road", position = node_position}
  }

  road_network.add_node(surface.index, node_position[1], node_position[2])
  return true
end

local refund_build = function(event, item_name)
  if event.player_index then
    game.get_player(event.player_index).insert{name = item_name, count = 1}
    return
  end

  if event.robot and event.robot.valid then
    event.robot.get_inventory(defines.inventory.robot_cargo).insert({name = item_name, count = 1})
    return
  end
end

local on_created_entity = function(event)
  local entity = event.entity or event.created_entity
  if not (entity and entity.valid) then return end

  local depot_lib = depot_names[entity.name]
  if not depot_lib then
    return
  end

  if not attempt_to_place_node(entity, depot_lib, event) then
    --refund
    refund_build(event, entity.name)
    entity.destroy()
    return
  end
  
  local depot = depot_lib.new(entity)
  script_data.depots[depot.index] = depot
  script_data.update_order[#script_data.update_order + 1] = depot.index
end

local on_entity_removed = function(event)
  local entity = event.entity

  if not (entity and entity.valid) then return end

  local depot = get_depot(entity)
  if depot then
    script_data.depots[depot.index] = nil
    depot:on_removed()
  end

end

local get_lib = function(depot)
  local name = depot.entity.name
  return depot_names[name]
end

local load_depot = function(depot)
  local lib = get_lib(depot)
  if lib.load then lib.load(depot) end
end

local config_changed_depot = function(depot)
  local lib = get_lib(depot)
  if lib.config_changed then lib.config_changed(depot) end
end

local migrate_depots = function()

  local depots = {}
  local update_order = {}

  local count = 1

  local request_depots = global.request_depots.request_depots
  for k, v in pairs (request_depots) do
    depots[k] = v
    update_order[count] = k
    count = count + 1
  end
  global.request_depots = nil
  
  local supply_depots = global.supply_depots.supply_depots
  for k, v in pairs (supply_depots) do
    depots[k] = v
    update_order[count] = k
    count = count + 1
  end
  global.supply_depots = nil
  
  script_data.depots = depots
  script_data.update_order = update_order

  
  for k, depot in pairs (script_data.depots) do
    load_depot(depot)
  end

  for k, force in pairs (game.forces) do
    force.reset_technology_effects()
  end

  game.print("Transport drones 0.2.0 update:")
  game.print("I added fuel depots and fluid depots. The transport drones now need petroleum to work properly, sorry for any inconvenience.")
  game.print("Thanks for playing with my mod.")

end

local shuffle_table = util.shuffle_table
local update_next_depot = function()
  local index = script_data.last_update_index
  local depots = script_data.update_order

  local depot_index = depots[index]
  if not depot_index then
    shuffle_table(depots)
    script_data.last_update_index = 1
    return
  end
  
  local depot = script_data.depots[depot_index]
  if not depot then
    local last = #depots
    if index == last then
      depots[index] = nil
    else
      depots[index], depots[last] = depots[last], nil
    end
    return
  end
  
  depot:update()
  script_data.last_update_index = index + 1
end

local on_tick = function(event)
  update_next_depot()
end

local lib = {}

lib.events = 
{
  [defines.events.on_built_entity] = on_created_entity,
  [defines.events.on_robot_built_entity] = on_created_entity,
  [defines.events.script_raised_built] = on_created_entity,
  [defines.events.script_raised_revive] = on_created_entity,

  [defines.events.on_entity_died] = on_entity_removed,
  [defines.events.on_robot_mined_entity] = on_entity_removed,
  [defines.events.script_raised_destroy] = on_entity_removed,
  [defines.events.on_player_mined_entity] = on_entity_removed,

  [defines.events.on_tick] = on_tick
}

lib.on_init = function()
  global.transport_depots = global.transport_depots or script_data
end

lib.on_load = function()
  script_data = global.transport_depots or script_data
  for k, depot in pairs (script_data.depots) do
    load_depot(depot)
  end
end

lib.on_configuration_changed = function()

  global.transport_depots = global.transport_depots or script_data

  if global.request_depots then
    migrate_depots()
  end

  for k, depot in pairs (script_data.depots) do
    depot:remove_from_network()
    depot:add_to_network()
    config_changed_depot(depot)
  end

end

lib.get_depot = function(entity)
  return script_data.depots[tostring(entity.unit_number)]
end

lib.get_all_depots = function()
  -- Seems a little encapsulation breaky.  Maybe return an array of indexes?
  return script_data.depots
end

return lib