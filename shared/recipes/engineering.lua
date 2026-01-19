Config.Recipes['portable'] = {
    label = 'Engineering',
    icon = 'fa-solid fa-gears',
    items = {
        {
            name = Config.PortableTableItem,
            label = 'Portable Crafting Table',
            description = 'A portable bench for on-the-go engineering. Universal utility.',
            duration = 30000,
            level = 10,
            xp = 1000,
            ingredients = {
                { item = 'steel', amount = 100 },
                { item = 'electronic_parts', amount = 25 },
                { item = 'wood', amount = 20 },
                { item = 'wire', amount = 50 }
            },
            result = { item = Config.PortableTableItem, amount = 1 }
        }
    }
}
