--------------------------------------------------------------------------------
-- Z-Crafting Configuration
-- Author: ZoniBoy00
-- Framework: QBox
--------------------------------------------------------------------------------

Config = {}

--------------------------------------------------------------------------------
-- General Settings
--------------------------------------------------------------------------------

Config.Debug = false
Config.Locale = GetConvar('qbx:locale', 'en') -- Supported: 'en', 'fi'

--------------------------------------------------------------------------------
-- Portable Crafting Table Settings
--------------------------------------------------------------------------------

Config.PortableTableItem = 'portable_crafting_table'
Config.PortableTableProp = `prop_tool_bench02`
Config.PortableCategories = {'weapons', 'tools', 'materials', 'portable'} -- Universal access

--------------------------------------------------------------------------------
-- Static Crafting Table Locations
-- Each table is specialized for specific categories
--------------------------------------------------------------------------------

Config.CraftingTables = {
    {
        coords = vec3(1125.26, -1238.05, 21.36),
        heading = 307.39,
        prop = `prop_tool_bench02`,
        label = 'Mechanical Workshop',
        categories = {'tools', 'materials'}
    },
    {
        coords = vec3(896.5715, -934.8975, 27.8576),
        heading = 270.3,
        prop = `prop_tool_bench02`,
        label = 'Black Market Armory',
        categories = {'weapons'}
    },
    {
        coords = vec3(471.84, 2598.89, 43.27),
        heading = 185.23,
        prop = `prop_tool_bench02`,
        label = 'Sandy Shores Tech Station',
        categories = {'materials', 'portable'}
    },
    {
        coords = vec3(3803.30, 4438.04, 4.13),
        heading = 275.62,
        prop = `prop_tool_bench02`,
        label = 'Remote Supply Outpost',
        categories = {'weapons', 'tools'}
    }
}

--------------------------------------------------------------------------------
-- Leveling & XP System
-- Control player progression through crafting
--------------------------------------------------------------------------------

Config.Leveling = {
    Enabled = true,
    MaxLevel = 50,
    BaseXP = 100,        -- XP required to reach level 2
    Multiplier = 1.2,    -- Exponential growth: XP = BaseXP * (Multiplier ^ CurrentLevel)
    XP_Metadata = 'crafting_xp',
    Level_Metadata = 'crafting_level'
}

--------------------------------------------------------------------------------
-- Crafting Recipes
-- Define all craftable items with ingredients, requirements, and rewards
--------------------------------------------------------------------------------

Config.Recipes = {
    ['weapons'] = {
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
    },
    ['tools'] = {
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
    },
    ['materials'] = {
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
    },
    ['portable'] = {
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
}

Config.Locales = {
    ['en'] = {
        ['menu_title'] = 'WORKBENCH',
        ['crafting_progress'] = 'ASSEMBLING: %s...',
        ['need_ingredients'] = 'Missing required components!',
        ['need_blueprint'] = 'Valid schematic required for this object!',
        ['success'] = 'Successfully assembled %s.',
        ['failed'] = 'Assembly process failed!',
        ['deploy_table'] = 'Deploying workbench...',
        ['pickup_table'] = 'Dismantle workbench',
        ['portable_bench'] = 'Portable Workbench',
        ['table_removed'] = 'Workbench dismantled and stored.',
        ['blip_name'] = 'Crafting Station',
        ['level_low'] = 'Crafting Level %s Required!',
        ['xp_gain'] = 'You gained %s crafting XP!',
        ['level_up'] = 'Your crafting level increased to %s!',
    },
    ['fi'] = {
        ['menu_title'] = 'NIKKAROINTIPÖYTÄ',
        ['crafting_progress'] = 'VALMISTETAAN: %s...',
        ['need_ingredients'] = 'Tarvittavia osia puuttuu!',
        ['need_blueprint'] = 'Tarvitset piirustukset tähän esineeseen!',
        ['success'] = 'Valmistit esineen: %s.',
        ['failed'] = 'Valmistus epäonnistui!',
        ['deploy_table'] = 'Asetetaan työpöytää...',
        ['pickup_table'] = 'Pura työpöytä',
        ['portable_bench'] = 'Kannettava työpöytä',
        ['table_removed'] = 'Työpöytä purettu ja otettu talteen.',
        ['blip_name'] = 'Nikkarointipiste',
        ['level_low'] = 'Tarvitset tason %s nikkaroinnissa!',
        ['xp_gain'] = 'Sait %s nikkarointi-kokemusta!',
        ['level_up'] = 'Nikkarointi-tasosi on nyt %s!',
    }
}
