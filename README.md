# z-crafting 🛠️

A premium, immersive crafting system designed for **QBox Framework**. Featuring a custom "Workbench" themed NUI, portable crafting stations, specialized map locations, blueprint-based progression, and a complete XP/Leveling system.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Framework](https://img.shields.io/badge/framework-QBox-orange.svg)

## ✨ Features

- **Custom Workbench UI**: A unique, immersive interface with a physical blueprint aesthetic and rounded card designs
- **Specialized Stations**: Map-specific crafting tables (e.g., Black Market Armory, Mechanical Workshop) that only craft specific categories
- **Portable Crafting Table**: A deployable/retrievable item that allows crafting any category anywhere, balanced by a high crafting cost
- **Blueprint System**: Lock specific items behind physical blueprint items. Locked items are visible but non-craftable until the blueprint is acquired
- **Progressive XP & Leveling**: 
  - 50 Level progression system with XP rewards
  - Visual level indicator and XP bar in the UI sidebar
  - Level requirements for advanced recipes
  - Automatic database persistence for player stats
- **Progressive Requirements**: Visual tracking of components with real-time progress bars in the UI
- **Exploit Prevention**: Inventory and combat are disabled during the crafting process
- **Dual Localization**: Full support for English and Finnish out of the box
- **Immersive Animations**: Realistic kneeling animations for deploying, picking up, and using workbenches
- **Auto-Database Install**: SQL tables are automatically created on first startup

## 📋 Dependencies

- [qbx_core](https://github.com/Qbox-Project/qbx_core)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [oxmysql](https://github.com/overextended/oxmysql)

## 🚀 Installation

1. **Download & Place**: Move the `z-crafting` folder into your resources directory.

2. **Database**: The script automatically creates the required database tables on first startup. No manual SQL import needed!

3. **Item Registration**: Add the following item to your `ox_inventory/data/items.lua`:

```lua
    ['portable_crafting_table'] = {
        label = 'Portable Crafting Table',
        weight = 15000,
        stack = false,
        client = {
            export = 'z-crafting.usePortableTable'
        }
    },
```

4. **Images**: Add item icons (`.png`) to `ox_inventory/web/images/`.
5. **Config**: Adjust locations and recipes in `shared/config.lua`.
6. **Start**: Add `ensure z-crafting` to your `server.cfg`.

## 🛠️ Usage

### Static Workbenches
Visit specialized locations around Los Santos. Each bench has its own set of allowed categories (Tools, Weapons, Materials, etc.). These do not show up on the map by default to encourage exploration.

**Available Stations:**
- **Mechanical Workshop** - Tools & Materials
- **Black Market Armory** - Weapons
- **Sandy Shores Tech Station** - Materials & Portable items
- **Remote Supply Outpost** - Weapons & Tools

### Portable Workbench
1. Acquire a `portable_crafting_table` item.
2. **Use** the item from your inventory to start the deployment process.
3. Once placed, you can use it to craft any available item in the game.
4. To move, use the **Target** interaction to dismantle it and return it to your inventory.

**Note:** Portable tables are **session-based** and will disappear on server/script restart. This is intentional to prevent clutter and maintain server performance.

### Leveling System
- Gain XP by crafting items (each recipe has specific XP rewards)
- Level up to unlock advanced crafting recipes
- Max level: **50**
- Progress is saved to the database and persists across server restarts
- View your current level and XP in the UI sidebar

## ⚙️ Configuration

The system is highly flexible via `shared/config.lua`:

### Static Tables
Define coordinates, heading, prop model, and allowed categories for each workbench location.

### Recipes
Create complex recipes with:
- Multiple ingredients
- Custom durations
- Blueprint requirements
- Level requirements
- XP rewards

Example:
```lua
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
```

### Leveling System
```lua
Config.Leveling = {
    Enabled = true,
    MaxLevel = 50,
    BaseXP = 100,
    Multiplier = 1.2,
    XP_Metadata = 'crafting_xp',
    Level_Metadata = 'crafting_level'
}
```

### Portable Table
Customize its crafting cost and which categories it can access.

## 📊 Database Tables

The script automatically creates:
- `z_crafting_stats` - Player progression (level, XP, total crafted items)

## 🎨 UI Features

- Rounded, modern card design with smooth transitions
- Real-time XP bar with smooth gradient animations
- Level-locked items shown with dashed borders and level requirements
- Blueprint-locked items shown with lock icons
- Responsive ingredient progress bars
- Clean, professional "Workbench" aesthetic
- Item images properly positioned and sized

## 🔒 Security Features

- Server-side validation for all crafting actions
- Session tracking to prevent exploits
- Inventory and combat disabled during crafting
- Blueprint verification before allowing crafts
- Level requirement checks

## 🎯 Performance

- Optimized code structure with minimal performance impact
- Session-based portable tables (no persistent database queries)
- Efficient UI updates and animations
- Smart entity management for spawned props

## 🐛 Troubleshooting

**Portable table not deploying?**
- Ensure you have the item in your inventory
- Check that you're not in a vehicle
- Make sure the area is clear

**UI not opening?**
- Check F8 console for errors
- Ensure ox_lib is started before z-crafting
- Verify NUI files are present

**XP not saving?**
- Confirm oxmysql is running
- Check database connection in server console
- Ensure QBox metadata system is functional

## 👨‍💻 Credits
Developed by **ZoniBoy00**

## 📝 Version History

**v1.0.0**
- Initial release
- Full crafting system with specialized stations
- XP/Leveling progression (50 levels)
- Blueprint system
- Portable crafting tables (session-based)
- Custom Workbench UI theme
- English & Finnish localization
