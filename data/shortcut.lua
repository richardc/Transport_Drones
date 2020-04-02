data:extend(
{
    {
        type = 'shortcut',
        name = 'transport-drones-selector',
        localised_name = 'transport-drones-selector',
        order = "a[transport-drones]",
        action = 'create-blueprint-item',
        technology_to_unlock = shared.transport_system_technology,
        item_to_create = 'transport-drones-selector-tool',
        style = 'green',
        icon = {
            filename = util.path('data/shortcut/grid-x32-white.png'),
            priority = 'extra-high-no-scale',
            size = 32,
            scale = 1,
            flags = {'icon'},
        },
        small_icon = {
            filename = util.path('data/shortcut/grid-x24.png'),
            priority = 'extra-high-no-scale',
            size = 24,
            scale = 1,
            flags = {'icon'},
        },
        disabled_small_icon = {
            filename = util.path('data/shortcut/grid-x24-white.png'),
            priority = 'extra-high-no-scale',
            size = 24,
            scale = 1,
            flags = {'icon'},
        },
    },
})

