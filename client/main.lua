local activePortableTables = {}

--------------------------------------------------------------------------------
-- Crafting Menu Functions
--------------------------------------------------------------------------------

-- Opens the custom NUI crafting interface with player data
local function OpenCraftingMenu(categories)
    lib.callback('z-crafting:getPlayerInventory', false, function(inventory)
        -- Filter blueprints from inventory (used for unlock checks)
        local blueprints = {}
        for itemName in pairs(inventory.items or {}) do
            if itemName:find('blueprint_') then
                blueprints[#blueprints + 1] = itemName
            end
        end

        -- Open NUI with all required data
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'open',
            recipes = Config.Recipes,
            inventory = inventory,
            blueprints = blueprints,
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
    for _, r in ipairs(Config.Recipes[categoryName].items) do
        if r.name == itemName then
            recipe = r
            break
        end
    end

    if not recipe then return end

    -- Close NUI before starting progress bar
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })

    -- Trigger crafting process
    lib.callback('z-crafting:craftItem', false, function(success, reason)
        if success then
            if lib.progressBar({
                duration = recipe.duration,
                label = _('crafting_progress', recipe.label),
                useWhileDead = false,
                canCancel = true,
                disable = { move = true, car = true, combat = true, inventory = true },
                anim = { dict = 'amb@prop_human_bum_bin@base', clip = 'base' }
            }) then
                TriggerServerEvent('z-crafting:giveItem', recipe.name, categoryName)
            else
                TriggerServerEvent('z-crafting:cancelCrafting')
            end
        else
            lib.notify({ title = _('failed'), description = reason, type = 'error' })
        end
    end, itemName, categoryName)
    cb('ok')
end)

-- Initialize Static Tables & Blips
CreateThread(function()
    for i, tableData in ipairs(Config.CraftingTables) do
        -- Request and spawn the prop
        lib.requestModel(tableData.prop)
        local obj = CreateObject(tableData.prop, tableData.coords.x, tableData.coords.y, tableData.coords.z - 1.0, false, false, false)
        FreezeEntityPosition(obj, true)
        SetEntityHeading(obj, tableData.heading or 0.0)
        
        -- Add Ox Target Interaction
        exports.ox_target:addLocalEntity(obj, {
            {
                name = 'crafting_table_' .. i,
                label = tableData.label or _('menu_title'),
                icon = 'fa-solid fa-screwdriver-wrench',
                onSelect = function()
                    OpenCraftingMenu(tableData.categories)
                end,
                distance = 2.0
            }
        })
    end
end)

local function usePortableTable()
    local playerPed = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.0, 0.0)
    local heading = GetEntityHeading(playerPed)

    lib.requestAnimDict('amb@world_human_gardener_plant@male@base')

    if lib.progressBar({
        duration = 3000,
        label = _('deploy_table'),
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true },
        anim = { dict = 'amb@world_human_gardener_plant@male@base', clip = 'base' }
    }) then
        TriggerServerEvent('z-crafting:server:deployTable', coords, heading)
    end
end
exports('usePortableTable', usePortableTable)

-- Portable Table Deployment (Old event kept for compatibility if needed elsewhere)
RegisterNetEvent('z-crafting:client:deployTable', function()
    usePortableTable()
end)

-- Handle Spawning Portable Table Props
RegisterNetEvent('z-crafting:client:syncTable', function(tableId, coords, heading)
    -- Check if table already exists (prevent duplicates on restart)
    if activePortableTables[tableId] then
        return
    end
    
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
            label = _('portable_bench'),
            icon = 'fa-solid fa-hammer',
            onSelect = function()
                OpenCraftingMenu(Config.PortableCategories)
            end,
            distance = 2.0
        },
        {
            name = 'pickup_portable_table_' .. tableId,
            label = _('pickup_table'),
            icon = 'fa-solid fa-hand-holding',
            onSelect = function()
                lib.requestAnimDict('amb@world_human_gardener_plant@male@base')
                if lib.progressBar({
                    duration = 2500,
                    label = _('pickup_table'),
                    useWhileDead = false,
                    canCancel = true,
                    disable = { move = true, car = true },
                    anim = { dict = 'amb@world_human_gardener_plant@male@base', clip = 'base' }
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
        -- Request network control of the entity
        local netId = NetworkGetNetworkIdFromEntity(obj)
        NetworkRequestControlOfEntity(obj)
        
        -- Simple, direct deletion
        SetEntityAsMissionEntity(obj, true, true)
        DeleteEntity(obj)
        
        -- Mark as no longer needed
        SetEntityAsNoLongerNeeded(obj)
    end
    
    -- Clear from memory
    activePortableTables[tableId] = nil
end)
