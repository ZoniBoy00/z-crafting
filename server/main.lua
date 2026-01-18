local portableTables = {}
local craftingSessions = {}

--------------------------------------------------------------------------------
-- Database Auto-Installation
-- Automatically creates required database tables on first startup
--------------------------------------------------------------------------------
CreateThread(function()
    Wait(1000) -- Ensure oxmysql is fully initialized
    
    if not MySQL then
        print('^1[z-crafting]^7 ERROR: MySQL not available. Ensure oxmysql is installed and running.')
        return
    end
    
    local resourceName = GetCurrentResourceName()
    local sqlFile = LoadResourceFile(resourceName, 'install.sql')
    
    if not sqlFile then
        print('^3[z-crafting]^7 WARNING: install.sql not found. Database tables may not exist.')
        return
    end
    
    -- Parse and execute SQL statements individually (MySQL.query doesn't support multi-statement)
    local queries = {}
    for query in sqlFile:gmatch("CREATE TABLE[^;]+;") do
        local trimmed = query:match("^%s*(.-)%s*$")
        if trimmed and #trimmed > 0 then
            table.insert(queries, trimmed)
        end
    end
    
    if #queries == 0 then
        print('^3[z-crafting]^7 WARNING: No CREATE TABLE statements found in install.sql')
        return
    end
    
    -- Execute each table creation query
    local completed = 0
    for i, query in ipairs(queries) do
        MySQL.query(query, {}, function(success)
            completed = completed + 1
            if not success then
                print('^1[z-crafting]^7 ERROR: Failed to create database table #'..i)
            end
            
            if completed == #queries then
                print('^2[z-crafting]^7 ✓ Database installation complete! ('..#queries..' tables verified)')
            end
        end)
    end
end)

--------------------------------------------------------------------------------
-- Portable Table System
--------------------------------------------------------------------------------

exports.ox_inventory:registerHook('createItem', function(payload)
end, {}) -- Placeholder if needed

-- Handle Portable Table Item Use
CreateThread(function()
    exports.qbx_core:CreateUseableItem(Config.PortableTableItem, function(source)
        TriggerClientEvent('z-crafting:client:deployTable', source)
    end)
end)

RegisterNetEvent('z-crafting:server:deployTable', function(coords, heading)
    local src = source
    if exports.ox_inventory:RemoveItem(src, Config.PortableTableItem, 1) then
        -- Generate simple incremental ID
        local tableId = #portableTables + 1
        portableTables[tableId] = { 
            coords = coords, 
            heading = heading, 
            owner = src 
        }
        
        -- Sync to all clients
        TriggerClientEvent('z-crafting:client:syncTable', -1, tableId, coords, heading)
    end
end)

RegisterNetEvent('z-crafting:server:pickupTable', function(tableId)
    local src = source
    if portableTables[tableId] then
        -- Remove from memory
        portableTables[tableId] = nil
        
        -- Sync removal to all clients
        TriggerClientEvent('z-crafting:client:removeTable', -1, tableId)
        
        -- Give item back
        exports.ox_inventory:AddItem(src, Config.PortableTableItem, 1)
        TriggerClientEvent('ox_lib:notify', src, { description = _('table_removed'), type = 'success' })
    end
end)

-- Sync existing tables for joining players
RegisterNetEvent('qbx_core:server:playerLoaded', function(player)
    local src = player.PlayerData.source
    for id, data in pairs(portableTables) do
        TriggerClientEvent('z-crafting:client:syncTable', src, id, data.coords, data.heading)
    end
end)

lib.callback.register('z-crafting:getPlayerInventory', function(source)
    local inventory = {}
    local inv = exports.ox_inventory:GetInventory(source)
    if inv and inv.items then
        for _, item in pairs(inv.items) do
            if item and item.name then
                inventory[item.name] = (inventory[item.name] or 0) + item.count
            end
        end
    end

    local player = exports.qbx_core:GetPlayer(source)
    local craftingLevel = player.PlayerData.metadata[Config.Leveling.Level_Metadata] or 1
    local craftingXP = player.PlayerData.metadata[Config.Leveling.XP_Metadata] or 0

    return {
        items = inventory,
        level = craftingLevel,
        xp = craftingXP,
        nextLevelXP = math.floor(Config.Leveling.BaseXP * (Config.Leveling.Multiplier ^ craftingLevel))
    }
end)

-- Crafting Logic
-- Secure callback to check ingredients and start crafting
lib.callback.register('z-crafting:craftItem', function(source, itemName, categoryName)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return false, "Player not found" end

    -- Find recipe
    local recipe = nil
    if not Config.Recipes[categoryName] then return false, "Invalid category" end
    
    for _, r in ipairs(Config.Recipes[categoryName].items) do
        if r.name == itemName then
            recipe = r
            break
        end
    end

    if not recipe then return false, "Recipe not found" end

    -- Level Check
    local currentLevel = player.PlayerData.metadata[Config.Leveling.Level_Metadata] or 1
    if recipe.level and currentLevel < recipe.level then
        return false, _('level_low', recipe.level)
    end

    -- Check for blueprints
    if recipe.blueprint then
        local hasBlueprint = exports.ox_inventory:GetItemCount(src, recipe.blueprint)
        if hasBlueprint <= 0 then
            return false, _('need_blueprint')
        end
    end

    -- Check ingredients
    for _, ingredient in ipairs(recipe.ingredients) do
        local count = exports.ox_inventory:GetItemCount(src, ingredient.item)
        if count < ingredient.amount then
            return false, _('need_ingredients')
        end
    end

    -- Mark session as active
    craftingSessions[src] = { itemName = itemName, categoryName = categoryName, startTime = os.time() }
    
    return true
end)

--------------------------------------------------------------------------------
-- Crafting Logic (Completion)
--------------------------------------------------------------------------------
RegisterNetEvent('z-crafting:giveItem', function(itemName, categoryName)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local session = craftingSessions[src]

    -- Security check: Validate active session
    if not session or session.itemName ~= itemName then
        print(('[Security] Player %s attempted to craft %s without valid session.'):format(src, itemName))
        return
    end

    local recipe = nil
    if not Config.Recipes[categoryName] then return end
    
    for _, r in ipairs(Config.Recipes[categoryName].items) do
        if r.name == itemName then
            recipe = r
            break
        end
    end

    if not recipe then return end

    -- Verify ingredients one last time before removal
    for _, ingest in ipairs(recipe.ingredients) do
        local count = exports.ox_inventory:GetItemCount(src, ingest.item)
        if count < ingest.amount then
            TriggerClientEvent('ox_lib:notify', src, { description = _('need_ingredients'), type = 'error' })
            return
        end
    end

    -- Transactional removal of materials
    for _, ingest in ipairs(recipe.ingredients) do
        exports.ox_inventory:RemoveItem(src, ingest.item, ingest.amount)
    end

    -- Deliver finished product
    if exports.ox_inventory:AddItem(src, recipe.result.item, recipe.result.amount) then
        TriggerClientEvent('ox_lib:notify', src, { description = _('success', recipe.label), type = 'success' })
        
        -- Award XP (QBox saves metadata to database automatically)
        if Config.Leveling.Enabled and recipe.xp then
            local currentXP = player.PlayerData.metadata[Config.Leveling.XP_Metadata] or 0
            local currentLevel = player.PlayerData.metadata[Config.Leveling.Level_Metadata] or 1
            
            -- Check if player is at max level
            if currentLevel >= Config.Leveling.MaxLevel then
                TriggerClientEvent('ox_lib:notify', src, { description = 'Max Crafting Level Reached!', type = 'inform', icon = 'fa-solid fa-trophy' })
            else
                local newXP = currentXP + recipe.xp
                local nextLevelXP = math.floor(Config.Leveling.BaseXP * (Config.Leveling.Multiplier ^ currentLevel))
                
                if newXP >= nextLevelXP and currentLevel < Config.Leveling.MaxLevel then
                    newXP = newXP - nextLevelXP
                    currentLevel = currentLevel + 1
                    
                    -- Ensure we don't exceed max level
                    if currentLevel > Config.Leveling.MaxLevel then
                        currentLevel = Config.Leveling.MaxLevel
                        newXP = 0
                    end
                    
                    player.Functions.SetMetaData(Config.Leveling.Level_Metadata, currentLevel)
                    TriggerClientEvent('ox_lib:notify', src, { description = _('level_up', currentLevel), type = 'success', icon = 'fa-solid fa-angles-up' })
                end
                
                player.Functions.SetMetaData(Config.Leveling.XP_Metadata, newXP)
                TriggerClientEvent('ox_lib:notify', src, { description = _('xp_gain', recipe.xp), type = 'inform' })
                
                -- Sync to dedicated database table for statistics
                MySQL.insert('INSERT INTO z_crafting_stats (citizenid, crafting_level, crafting_xp, total_crafted) VALUES (?, ?, ?, 1) ON DUPLICATE KEY UPDATE crafting_level = ?, crafting_xp = ?, total_crafted = total_crafted + 1', {
                    player.PlayerData.citizenid,
                    currentLevel,
                    newXP,
                    currentLevel,
                    newXP
                })
            end
        end
    end
    
    -- Close session
    craftingSessions[src] = nil
end)

RegisterNetEvent('z-crafting:cancelCrafting', function()
    craftingSessions[source] = nil
end)
