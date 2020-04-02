local road_network = require("script/road_network")

local on_player_selected_area = function(event)
    if event.item ~= 'transport-drones-selector-tool' then return end

    game.print("[TD] event "..serpent.line(event))
    for _, thing in pairs(event.tiles, event.entities) do
        local node = road_network.get_node(thing.surface.index, thing.position.x, thing.position.y)
        local network = node and node["id"]
        game.print("[TD] "..serpent.block({
            surface = thing.surface.index,
            x = thing.position.x,
            y = thing.position.y,
            network = network,
        }))
    end
end

local lib = {}
lib.events = {
    [defines.events.on_player_selected_area] = on_player_selected_area,
}
return lib
