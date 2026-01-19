# z-crafting 🛠️

A premium, modular crafting system designed for the **QBox Framework**. Features a leveling system, portable workbenches, static crafting stations, and a modular recipe system for easy management.

## ✨ Features

- **Modular Recipes**: Recipes are separated into their own files (`shared/recipes/*.lua`) for ultimate organization.
- **Leveling & XP System**: Players gain experience from crafting, unlocking higher-tier recipes as they level up.
- **Portable Workbenches**: Deployable crafting tables that can be placed anywhere and picked back up.
- **Static Crafting Stations**: Specialized locations with restricted crafting categories (e.g., Mechanical Workshop, Black Market Armory).
- **Blueprint System**: Option to require specific blueprint items to unlock certain recipes.
- **Database Statistics**: Tracks total items crafted and level progress in the database.
- **Modern UI**: Clean NUI interface for browsing and crafting items.
- **Performance Optimized**: Using `ox_lib` and `ox_target` for efficient interactions.

## 📋 Dependencies

- [qbx_core](https://github.com/Qbox-Project/qbx_core)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [ox_target](https://github.com/overextended/ox_target)
- [oxmysql](https://github.com/overextended/oxmysql)

## 🚀 Installation

1. **Download & Place**: Drag the `z-crafting` folder into your resources directory.
2. **Database**: The script handles auto-installation! Just ensure `oxmysql` is running. 
    - *Optional*: You can manually run `install.sql` if auto-install is disabled.
3. **Inventory Items**: Add the following items to your `ox_inventory/data/items.lua`:

```lua
['portable_crafting_table'] = {
    label = 'Portable Crafting Table',
    weight = 15000,
    stack = false,
    client = {
        export = 'z-crafting.usePortableTable'
    }
},
['blueprint_pistol'] = {
    label = 'Pistol Blueprint',
    weight = 100,
},
-- Example Materials
['steel'] = { label = 'Steel', weight = 100 },
['wood'] = { label = 'Wood', weight = 500 },
['wire'] = { label = 'Wire', weight = 50 },
['electronic_parts'] = { label = 'Electronic Parts', weight = 100 },
```

4. **Start Resource**: Add `ensure z-crafting` to your `server.cfg`.

## ⚙️ Configuration

### General Settings (`shared/config.lua`)
- `Config.Debug`: Enable/disable debug prints.
- `Config.Locale`: Set language ('en' or 'fi').
- `Config.Leveling`: Configure max level, XP multipliers, and metadata keys.

### Recipes (`shared/recipes/*.lua`)
Adding a new recipe is easy! Create a new `.lua` file in `shared/recipes/` and follow this structure:

```lua
Config.Recipes['category_id'] = {
    label = 'Category Label',
    icon = 'fa-solid fa-icon-name', -- FontAwesome 6
    items = {
        {
            name = 'item_name',
            label = 'Item Label',
            description = 'Short description',
            duration = 5000, -- Crafting time in ms
            level = 1,      -- Required level (optional)
            xp = 50,         -- XP gain (optional)
            blueprint = 'blueprint_item', -- Required item (optional)
            ingredients = {
                { item = 'material_1', amount = 10 },
                { item = 'material_2', amount = 5 }
            },
            result = { item = 'item_name', amount = 1 }
        }
    }
}
```

## 🛠️ Developers

### API Exports
You can trigger the portable table deployment via export:
```lua
exports['z-crafting']:usePortableTable()
```

## 📄 License
This resource was created by **ZoniBoy00** for the QBox community. Feel free to modify and use it in your server!
