local depot = require("script/depot_common")
local data =
{
  gui_frames = {},
  button_actions = {},
}


local debug_print = false
local print = function(string)
  if not debug_print then return end
  game.print(string)
  log(string)
end

local clear_gui = function(frame)
  if not (frame and frame.valid) then return end
  util.deregister_gui(frame, data.button_actions)
  frame.clear()
end
  
local close_gui = function(frame)
  if not (frame and frame.valid) then return end
  util.deregister_gui(frame, data.button_actions)
  frame.destroy()
end

local get_gui_frame = function(frame)
  local frame = data.gui_frames[player.index]
  if frame and frame.valid then return frame end
  data.gui_frames[player.index] = nil
end

local make_gui = function(player, source)
  local location
  local gui_frame = get_gui_frame(player)
  if gui_frame then
    location = gui_frame.location
    print("Frame already exists")
    close_gui(gui_frame)
    player.opened = nil
  end
  
  print("Making new frame")
  
  if not (source and source.valid and not data.to_be_removed[source.unit_number]) then
    --unlink_teleporter(player)
    return
  end
  
  local gui = player.gui.screen
  local frame = gui.add{type = "frame", direction = "vertical", ignored_by_interaction = false}
  if location then
    frame.location = location
  else
    frame.auto_center = true
  end

  player.opened = frame
  data.gui_frames[player.index] = frame
  frame.ignored_by_interaction = false
  local title_flow = frame.add{type = "flow", direction = "horizontal"}
  title_flow.style.vertical_align = "center"
  local title = title_flow.add{type = "label", style = "heading_1_label"}
  title.drag_target = frame
  local rename_button = title_flow.add{type = "sprite-button", sprite = "utility/rename_icon_small", style = "small_picture_slot_button", visible = source.force == player.force}
  local pusher = title_flow.add{type = "empty-widget", direction = "horizontal", style = "draggable_space_header"}
  pusher.style.horizontally_stretchable = true
  pusher.style.vertically_stretchable = true
  pusher.drag_target = frame
  -- local search_box = title_flow.add{type = "textfield", visible = false}
  -- local search_button = title_flow.add{type = "sprite-button", style = "tool_button", sprite = "utility/search_icon", tooltip = {"gui.search-with-focus", {"search"}}}
  -- util.register_gui(data.button_actions, search_button, {type = "search_button", box = search_box})
  -- data.search_boxes[player.index] = search_box
  local inner = frame.add{type = "frame", style = "inside_deep_frame"}
  local scroll = inner.add{type = "scroll-pane", direction = "vertical"}
  scroll.style.maximal_height = player.display_resolution.height * 0.8
  local table = scroll.add{type = "table", column_count = 4}
  util.register_gui(data.button_actions, search_box, {type = "search_text_changed", parent = table})
  table.style.horizontal_spacing = 2
  table.style.vertical_spacing = 2
  local any = false
  --print(table_size(network))
  local chart = player.force.chart
  --for name,  in spairs (network, get_sort_function()) do
  --   local teleporter_entity = teleporter.teleporter
  --   if not (teleporter_entity.valid) then
  --     clear_teleporter_data(teleporter)
  --   elseif teleporter_entity == source then
  --     title.caption = name
  --     util.register_gui(data.button_actions, rename_button, {type = "rename_button", caption = name})
  --   else
  --     local position = teleporter_entity.position
  --     local area = {{position.x - preview_size / 2, position.y - preview_size / 2}, {position.x + preview_size / 2, position.y + preview_size / 2}}
  --     chart(teleporter_entity.surface, area)
  --     local button = table.add{type = "button", name = "_"..name}
  --     button.style.height = preview_size + 32 + 8
  --     button.style.width = preview_size + 8
  --     button.style.left_padding = 0
  --     button.style.right_padding = 0
  --     local inner_flow = button.add{type = "flow", direction = "vertical", ignored_by_interaction = true}
  --     inner_flow.style.vertically_stretchable = true
  --     inner_flow.style.horizontally_stretchable = true
  --     inner_flow.style.horizontal_align = "center"
  --     local map = inner_flow.add
  --     {
  --       type = "minimap",
  --       surface_index = teleporter_entity.surface.index,
  --       zoom = 1,
  --       force = teleporter_entity.force.name,
  --       position = position,
  --     }
  --     map.ignored_by_interaction = true
  --     map.style.height = preview_size
  --     map.style.width = preview_size
  --     map.style.horizontally_stretchable = true
  --     map.style.vertically_stretchable = true
  --     local label = inner_flow.add{type = "label", caption = name}
  --     label.style.horizontally_stretchable = true
  --     label.style.font = "default-dialog-button"
  --     label.style.font_color = {}
  --     label.style.horizontally_stretchable = true
  --     label.style.maximal_width = preview_size
  --     util.register_gui(data.button_actions, button, {type = "teleport_button", param = teleporter})
  --     any = true
  --   end
  -- end
  if not any then
      table.add{type = "label", caption = {"no-transport-depots"}}
  end
end  

local on_gui_action = function(event)
  local element = event.element
  if not (element and element.valid) then return end
  local player_data = data.button_actions[event.player_index]
  if not player_data then return end
  local action = player_data[element.index]
  if action then
      gui_actions[action.type](event, action)
      return true
  end
end

local on_gui_closed = function(event)
  --print("CLOSED "..event.tick)
  local element = event.element
  if not element then return end

  local player = game.get_player(event.player_index)

  local gui_frame = get_gui_frame(player)
  if gui_frame and gui_frame == element and not gui_frame.ignored_by_interaction then
    close_gui(gui_frame)
    print("Frame unlinked")
    return
  end  
end

local on_player_removed = function(event)
  local player = game.get_player(event.player_index)
  close_gui(get_gui_frame(player))
end


local lib = {}
lib.events = {
  [defines.events.on_gui_click] = on_gui_action,
  [defines.events.on_gui_text_changed] = on_gui_action,
  [defines.events.on_gui_confirmed] = on_gui_action,
  [defines.events.on_gui_closed] = on_gui_closed,

  [defines.events.on_player_died] = on_player_removed,
  [defines.events.on_player_left_game] = on_player_removed,
  [defines.events.on_player_changed_force] = on_player_removed,
}
return lib
