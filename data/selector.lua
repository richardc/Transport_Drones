data:extend(
{
    {
        type = 'selection-tool',
        name = 'transport-drones-selector-tool',
        icon = "__base__/graphics/icons/blueprint.png",
        icon_size = 32,
        flags = {'only-in-cursor', 'hidden'},
        stack_size = 1,
        stackable = false,
        selection_color = { g = 1 },
        selection_mode = {'any-entity','any-tile'},
        alt_selection_color = { g = 1, b = 1 },
        alt_selection_mode = {'nothing'},
        selection_cursor_box_type = 'copy',
        alt_selection_cursor_box_type = 'copy',
        always_include_tiles = true,
        tile_filter_mode = 'whitelist',
        tile_filters = {'transport-drone-road'},
        entity_filter_mode = 'whitelist',
        entity_filters = {'request-depot', 'supply-depot', 'fuel-depot', 'fluid-depot'},
    },
})
