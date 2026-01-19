--------------------------------------------------------------------------------
-- Z-Crafting Configuration
-- Author: ZoniBoy00
-- Framework: QBox
--------------------------------------------------------------------------------

Config = {}

--------------------------------------------------------------------------------
-- General Settings
--------------------------------------------------------------------------------

Config.Debug = true
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

Config.Recipes = {}

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
