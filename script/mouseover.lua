local depot = require("script/depot_common")

local on_selected_entity_changed = function(event)
    -- game.print("[TD] on_selected_entity_changed "..serpent.line(event))
    local selected = game.players[event.player_index].selected
    -- game.print("[TD] selected "..serpent.line(selected))
    if not selected then return end

    local depot = depot.get_depot(selected)
    if not depot then return end

    game.print("[TD] depot selected: " ..serpent.line(depot))
end

local lib = {}
lib.events = {
    [defines.events.on_selected_entity_changed] = on_selected_entity_changed,
}
return lib
