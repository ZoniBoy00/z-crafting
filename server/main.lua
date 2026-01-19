local portableTables = {}
local craftingSessions = {}

--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------

local function L(key, ...)
    local lang = Config.Locale or 'en'
    return Config.Locales[lang][key] and string.format(Config.Locales[lang][key], ...) or key
end

local function Notify(src, msg, type)
    TriggerClientEvent('ox_lib:notify', src, { description = msg, type = type or 'inform' })
end

--------------------------------------------------------------------------------
-- Database Auto-Installation
--------------------------------------------------------------------------------

CreateThread(function()
    Wait(1000)
    local sqlFile = LoadResourceFile(GetCurrentResourceName(), 'install.sql')
    if not sqlFile then return end
    
    local queries = {}
    for query in sqlFile:gmatch("CREATE TABLE[^;]+;") do
        local trimmed = query:match("^%s*(.-)%s*$")
        if trimmed and #trimmed > 0 then table.insert(queries, trimmed) end
    end
    
    for i, query in ipairs(queries) do
        MySQL.query(query, {}, function(success)
            if not success then
                print('^1[z-crafting]^7 ERROR: Failed to create database table #'..i)
            elseif i == #queries then
                print('^2[z-crafting]^7 ✓ Database installation verified!')
            end
        end)
    end
end)

--------------------------------------------------------------------------------
-- Portable Table System
--------------------------------------------------------------------------------

CreateThread(function()
    exports.qbx_core:CreateUseableItem(Config.PortableTableItem, function(source)
        TriggerClientEvent('z-crafting:client:deployTable', source)
    end)
end)

RegisterNetEvent('z-crafting:server:deployTable', function(coords, heading)
    local src = source
    if exports.ox_inventory:RemoveItem(src, Config.PortableTableItem, 1) then
        local tableId = #portableTables + 1
        portableTables[tableId] = { coords = coords, heading = heading, owner = src }
        TriggerClientEvent('z-crafting:client:syncTable', -1, tableId, coords, heading)
    end
end)

RegisterNetEvent('z-crafting:server:pickupTable', function(tableId)
    local src = source
    if portableTables[tableId] then
        portableTables[tableId] = nil
        TriggerClientEvent('z-crafting:client:removeTable', -1, tableId)
        exports.ox_inventory:AddItem(src, Config.PortableTableItem, 1)
        Notify(src, L('table_removed'), 'success')
    end
end)

AddEventHandler('qbx_core:server:playerLoaded', function(player)
    local src = player.PlayerData.source
    for id, data in pairs(portableTables) do
        TriggerClientEvent('z-crafting:client:syncTable', src, id, data.coords, data.heading)
    end
end)

--------------------------------------------------------------------------------
-- Crafting Logic
--------------------------------------------------------------------------------

local function GetNextLevelXP(level)
    -- More standard curve: Level 1 -> 100 XP, Level 2 -> 120 XP, etc.
    return math.floor(Config.Leveling.BaseXP * (Config.Leveling.Multiplier ^ (level - 1)))
end

lib.callback.register('z-crafting:getPlayerInventory', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return { items = {}, level = 1, xp = 0, nextLevelXP = 100 } end

    local inv = exports.ox_inventory:GetInventory(source)
    local items = {}
    if inv and inv.items then
        for _, item in pairs(inv.items) do
            if item and item.name then
                items[item.name] = (items[item.name] or 0) + item.count
            end
        end
    end

    local citizenid = player.PlayerData.citizenid
    local level = player.PlayerData.metadata[Config.Leveling.Level_Metadata] or 1
    local xp = player.PlayerData.metadata[Config.Leveling.XP_Metadata] or 0

    -- Database Fallback if metadata is empty/reset
    if level == 1 and xp == 0 then
        local result = MySQL.single.await('SELECT crafting_level, crafting_xp FROM z_crafting_stats WHERE citizenid = ?', {citizenid})
        if result then
            level = result.crafting_level or 1
            xp = result.crafting_xp or 0
            player.Functions.SetMetaData(Config.Leveling.Level_Metadata, level)
            player.Functions.SetMetaData(Config.Leveling.XP_Metadata, xp)
        end
    end

    if Config.Debug then
        print(string.format('^3[z-crafting]^7 Sending Player Data: %s | Level: %s | XP: %s', citizenid, level, xp))
    end

    return {
        items = items,
        level = level,
        xp = xp,
        nextLevelXP = GetNextLevelXP(level)
    }
end)

lib.callback.register('z-crafting:craftItem', function(source, itemName, categoryName)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player or not Config.Recipes[categoryName] then return false, "Invalid request" end

    local recipe = nil
    for _, r in ipairs(Config.Recipes[categoryName].items) do
        if r.name == itemName then
            recipe = r
            break
        end
    end

    if not recipe then return false, "Recipe not found" end

    -- Level & Blueprint Check
    local level = player.PlayerData.metadata[Config.Leveling.Level_Metadata] or 1
    if recipe.level and level < recipe.level then return false, L('level_low', recipe.level) end
    if recipe.blueprint and exports.ox_inventory:GetItemCount(src, recipe.blueprint) <= 0 then
        return false, L('need_blueprint')
    end

    -- Ingredient Check
    for _, ingest in ipairs(recipe.ingredients) do
        if exports.ox_inventory:GetItemCount(src, ingest.item) < ingest.amount then
            return false, L('need_ingredients')
        end
    end

    craftingSessions[src] = { itemName = itemName, categoryName = categoryName }
    return true
end)

RegisterNetEvent('z-crafting:giveItem', function(itemName, categoryName)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    local session = craftingSessions[src]

    if not player or not session or session.itemName ~= itemName then return end

    local recipe = nil
    for _, r in ipairs(Config.Recipes[categoryName].items) do
        if r.name == itemName then recipe = r; break end
    end
    if not recipe then return end

    -- Verify & Remove Ingredients
    for _, ingest in ipairs(recipe.ingredients) do
        if exports.ox_inventory:GetItemCount(src, ingest.item) < ingest.amount then
            Notify(src, L('need_ingredients'), 'error')
            return
        end
    end

    for _, ingest in ipairs(recipe.ingredients) do
        exports.ox_inventory:RemoveItem(src, ingest.item, ingest.amount)
    end

    if exports.ox_inventory:AddItem(src, recipe.result.item, recipe.result.amount) then
        Notify(src, L('success', recipe.label), 'success')
        
        -- XP System
        if Config.Leveling.Enabled and recipe.xp then
            local xp = player.PlayerData.metadata[Config.Leveling.XP_Metadata] or 0
            local lvl = player.PlayerData.metadata[Config.Leveling.Level_Metadata] or 1
            
            if lvl < Config.Leveling.MaxLevel then
                xp = xp + recipe.xp
                local nextXP = GetNextLevelXP(lvl)
                
                while xp >= nextXP and lvl < Config.Leveling.MaxLevel do
                    xp = xp - nextXP
                    lvl = lvl + 1
                    nextXP = GetNextLevelXP(lvl)
                    Notify(src, L('level_up', lvl), 'success')
                end
                
                player.Functions.SetMetaData(Config.Leveling.Level_Metadata, lvl)
                player.Functions.SetMetaData(Config.Leveling.XP_Metadata, xp)
                
                if Config.Debug then
                    print(string.format('^3[z-crafting]^7 Player %s updated: Level %s, XP %s', player.PlayerData.citizenid, lvl, xp))
                end

                Notify(src, L('xp_gain', recipe.xp), 'inform')
                
                MySQL.insert('INSERT INTO z_crafting_stats (citizenid, crafting_level, crafting_xp, total_crafted) VALUES (?, ?, ?, 1) ON DUPLICATE KEY UPDATE crafting_level = ?, crafting_xp = ?, total_crafted = total_crafted + 1', {
                    player.PlayerData.citizenid, lvl, xp, lvl, xp
                })
            end
        end
    end
    craftingSessions[src] = nil
end)

RegisterNetEvent('z-crafting:cancelCrafting', function()
    craftingSessions[source] = nil
end)
