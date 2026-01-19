Config.Recipes['weapons'] = {
    label = 'Weapons',
    icon = 'fa-solid fa-gun',
    items = {
        {
            name = 'weapon_pistol',
            label = 'Pistol',
            description = 'Standard sidearm. Requires high-quality steel.',
            duration = 20000,
            blueprint = 'blueprint_pistol',
            level = 5,
            xp = 250,
            ingredients = {
                { item = 'steel', amount = 15 },
                { item = 'wood', amount = 5 }
            },
            result = { item = 'weapon_pistol', amount = 1 }
        }
    }
}
