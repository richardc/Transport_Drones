local on_player_selected_area = function(event)
    if event.item ~= 'transport-drones-selector-tool' then return end

    game.print("[TD] event "..serpent.line(event))

    game.print("[TD] area "..serpent.line(event.area))
    for _, entity in pairs(event.tiles) do
        game.print("[TD] tiles "..serpent.line(entity))
    end
    for _, entity in pairs(event.entities) do
        game.print("[TD] entity "..serpent.line(entity))
    end
end

local lib = {}
lib.events = {
    [defines.events.on_player_selected_area] = on_player_selected_area,
}
return lib
