Config.Recipes['materials'] = {
    label = 'Materials',
    icon = 'fa-solid fa-box-open',
    items = {
        {
            name = 'electronic_parts',
            label = 'Electronic Parts',
            description = 'Component for complex machines.',
            duration = 3000,
            level = 2,
            xp = 35,
            ingredients = {
                { item = 'wire', amount = 5 }
            },
            result = { item = 'electronic_parts', amount = 1 }
        }
    }
}
