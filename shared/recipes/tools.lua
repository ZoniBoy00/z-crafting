Config.Recipes['tools'] = {
    label = 'Tools',
    icon = 'fa-solid fa-wrench',
    items = {
        {
            name = 'lockpick',
            label = 'Lockpick',
            description = 'Essential for illegal activities.',
            duration = 5000,
            level = 1,
            xp = 50,
            ingredients = {
                { item = 'steel', amount = 2 },
                { item = 'plastic', amount = 1 }
            },
            result = { item = 'lockpick', amount = 1 }
        },
        {
            name = 'weapon_crowbar',
            label = 'Crowbar',
            description = 'Heavy duty prying tool.',
            duration = 8000,
            level = 3,
            xp = 120,
            ingredients = {
                { item = 'steel', amount = 10 }
            },
            result = { item = 'weapon_crowbar', amount = 1 }
        }
    }
}
