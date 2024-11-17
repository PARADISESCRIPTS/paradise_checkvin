local QBCore = exports['qb-core']:GetCoreObject()
local checking = false

-- Function to get vehicle model name
local function GetVehicleModel(vehicle)
    local hash = GetEntityModel(vehicle)
    local modelName = GetLabelText(GetDisplayNameFromVehicleModel(hash))
    return modelName ~= "NULL" and modelName or "Unknown Model"
end

-- Function to show vehicle info in ox_lib context menu
local function ShowVehicleInfo(data)
    lib.registerContext({
        id = 'vehicle_info_menu',
        title = 'Vehicle Information',
        options = {
            {
                title = 'Vehicle Plate',
                description = data.plate or 'Unknown',
                icon = 'car'
            },
            {
                title = 'Vehicle Model',
                description = data.model or 'Unknown',
                icon = 'info-circle'
            },
            {
                title = 'Registered Owner',
                description = data.owner or 'Unknown',
                icon = 'user'
            },
            {
                title = 'Registration Status',
                description = data.status or 'Unknown',
                icon = 'clipboard-check'
            }
        }
    })
    
    lib.showContext('vehicle_info_menu')
end

-- Function to check if player is close enough to vehicle
local function IsNearVehicle()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = QBCore.Functions.GetClosestVehicle(coords)
    if vehicle ~= 0 and #(coords - GetEntityCoords(vehicle)) < Config.CheckDistance then
        return vehicle
    end
    return nil
end

-- Main check vehicle function
local function CheckVehicle()
    if checking then return end
    
    local vehicle = IsNearVehicle()
    if not vehicle then
        lib.notify({
            title = 'Error',
            description = Config.Notifications.noVehicle,
            type = 'error'
        })
        return
    end

    local Player = QBCore.Functions.GetPlayerData()
    if Player.job.name ~= Config.RequiredJob then
        lib.notify({
            title = 'Error',
            description = Config.Notifications.notCop,
            type = 'error'
        })
        return
    end

    checking = true
    local ped = PlayerPedId()
    
    -- Animation
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)
    
    if lib.progressBar({
        duration = Config.SearchTime,
        label = Config.Notifications.searching,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false
        },
    }) then
        -- Progress bar completed successfully
        ClearPedTasks(ped)
        checking = false
        
        local plate = GetVehicleNumberPlateText(vehicle)
        local model = GetVehicleModel(vehicle)
        TriggerServerEvent('paradsie_checkvin:checkVehicleInfo', plate, model)
    else
        -- Progress bar was cancelled
        ClearPedTasks(ped)
        checking = false
        lib.notify({
            title = 'Cancelled',
            description = 'Vehicle check cancelled',
            type = 'error'
        })
    end
end

-- Register command
RegisterCommand(Config.Command, function()
    CheckVehicle()
end)

-- Event handler for radial menu
RegisterNetEvent('paradsie_checkvin:checkVehicleRadial')
AddEventHandler('paradsie_checkvin:checkVehicleRadial', function()
    CheckVehicle()
end)

-- Initialize radial menu on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
end)

-- Callback event for vehicle info
RegisterNetEvent('paradsie_checkvin:receiveVehicleInfo')
AddEventHandler('paradsie_checkvin:receiveVehicleInfo', function(data)
    ShowVehicleInfo(data)
end)