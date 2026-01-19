local activePortableTables = {}
local staticTableProps = {}

--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------

local function L(key, ...)
    return Config.Locales[Config.Locale][key] and string.format(Config.Locales[Config.Locale][key], ...) or key
end

--------------------------------------------------------------------------------
-- Crafting Menu Functions
--------------------------------------------------------------------------------

-- Opens the custom NUI crafting interface with player data
local function OpenCraftingMenu(categories)
    lib.callback('z-crafting:getPlayerInventory', false, function(data)
        if not data then return end

        -- Open NUI with all required data
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'open',
            recipes = Config.Recipes,
            inventory = data.items,
            level = data.level,
            xp = data.xp,
            nextLevelXP = data.nextLevelXP,
            allowedCategories = categories or {'tools', 'materials'}
        })
    end)
end

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({action = 'close'})
    cb('ok')
end)

RegisterNUICallback('craft', function(data, cb)
    local itemName = data.item
    local categoryName = data.category
    
    local recipe = nil
    if Config.Recipes[categoryName] then
        for _, r in ipairs(Config.Recipes[categoryName].items) do
            if r.name == itemName then
                recipe = r
                break
            end
        end
    end

    if not recipe then return cb('ok') end

    -- Close NUI before starting progress bar
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })

    -- Trigger crafting process
    lib.callback('z-crafting:craftItem', false, function(success, reason)
        if success then
            local progress = lib.progressBar({
                duration = recipe.duration,
                label = L('crafting_progress', recipe.label),
                useWhileDead = false,
                canCancel = true,
                disable = { move = true, car = true, combat = true, inventory = true },
                anim = { dict = 'amb@prop_human_bum_bin@base', clip = 'base' }
            })

            if progress then
                TriggerServerEvent('z-crafting:giveItem', recipe.name, categoryName)
            else
                TriggerServerEvent('z-crafting:cancelCrafting')
            end
        else
            lib.notify({ title = L('failed'), description = reason, type = 'error' })
        end
    end, itemName, categoryName)
    cb('ok')
end)

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

-- Initialize Static Tables
CreateThread(function()
    for i, tableData in ipairs(Config.CraftingTables) do
        lib.requestModel(tableData.prop)
        local obj = CreateObject(tableData.prop, tableData.coords.x, tableData.coords.y, tableData.coords.z - 1.0, false, false, false)
        FreezeEntityPosition(obj, true)
        SetEntityHeading(obj, tableData.heading or 0.0)
        
        staticTableProps[#staticTableProps + 1] = obj

        exports.ox_target:addLocalEntity(obj, {
            {
                name = 'crafting_table_' .. i,
                label = tableData.label or L('menu_title'),
                icon = 'fa-solid fa-screwdriver-wrench',
                onSelect = function()
                    OpenCraftingMenu(tableData.categories)
                end,
                distance = 2.0
            }
        })
    end
end)

-- Portable Table Logic
local function usePortableTable()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then return end

    local coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.2, 0.0)
    local heading = GetEntityHeading(playerPed)

    if lib.progressBar({
        duration = 3000,
        label = L('deploy_table'),
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true },
        anim = { dict = 'amb@prop_human_bum_bin@base', clip = 'base' }
    }) then
        TriggerServerEvent('z-crafting:server:deployTable', coords, heading)
    end
end
exports('usePortableTable', usePortableTable)

RegisterNetEvent('z-crafting:client:deployTable', function()
    usePortableTable()
end)

-- Sync Portable Tables
RegisterNetEvent('z-crafting:client:syncTable', function(tableId, coords, heading)
    if activePortableTables[tableId] then return end
    
    local model = Config.PortableTableProp
    lib.requestModel(model)
    local obj = CreateObject(model, coords.x, coords.y, coords.z - 1.0, false, false, false)
    PlaceObjectOnGroundProperly(obj)
    SetEntityHeading(obj, heading)
    FreezeEntityPosition(obj, true)
    
    activePortableTables[tableId] = obj

    exports.ox_target:addLocalEntity(obj, {
        {
            name = 'portable_crafting_table_' .. tableId,
            label = L('portable_bench'),
            icon = 'fa-solid fa-hammer',
            onSelect = function()
                OpenCraftingMenu(Config.PortableCategories)
            end,
            distance = 2.0
        },
        {
            name = 'pickup_portable_table_' .. tableId,
            label = L('pickup_table'),
            icon = 'fa-solid fa-hand-holding',
            onSelect = function()
                if lib.progressBar({
                    duration = 2500,
                    label = L('pickup_table'),
                    useWhileDead = false,
                    canCancel = true,
                    disable = { move = true, car = true },
                    anim = { dict = 'anim@mp_snowball', clip = 'pickup_snowball' }
                }) then
                    TriggerServerEvent('z-crafting:server:pickupTable', tableId)
                end
            end,
            distance = 2.0
        }
    })
end)

RegisterNetEvent('z-crafting:client:removeTable', function(tableId)
    local obj = activePortableTables[tableId]
    if obj and DoesEntityExist(obj) then
        DeleteEntity(obj)
    end
    activePortableTables[tableId] = nil
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    for _, obj in pairs(activePortableTables) do
        if DoesEntityExist(obj) then DeleteEntity(obj) end
    end
    
    for _, obj in ipairs(staticTableProps) do
        if DoesEntityExist(obj) then DeleteEntity(obj) end
    end
end)
