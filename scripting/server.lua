ESX = exports["es_extended"]:getSharedObject()

local function GetRandomName()
    local first = Config.RandomNames.firstNames[math.random(#Config.RandomNames.firstNames)]
    local last = Config.RandomNames.lastNames[math.random(#Config.RandomNames.lastNames)]
    return first .. ' ' .. last
end

RegisterNetEvent('paradsie_checkvin:checkVehicleInfo')
AddEventHandler('paradsie_checkvin:checkVehicleInfo', function(plate, model)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if xPlayer.job.name ~= Config.RequiredJob then
        return
    end
    
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(result)
        local vehicleInfo = {
            plate = plate,
            model = model,
            owner = "Unknown",
            status = "UNREGISTERED",
            insurance = "NONE",
            registration = "EXPIRED"
        }
        
        if result[1] then
            MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier', {
                ['@identifier'] = result[1].owner
            }, function(playerResult)
                if playerResult[1] then
                    vehicleInfo.owner = playerResult[1].firstname .. ' ' .. playerResult[1].lastname
                    vehicleInfo.status = "REGISTERED"
                    vehicleInfo.insurance = "VALID"
                    vehicleInfo.registration = "VALID"
                end
                TriggerClientEvent('paradsie_checkvin:receiveVehicleInfo', src, vehicleInfo)
            end)
        else
            vehicleInfo.owner = GetRandomName()
            TriggerClientEvent('paradsie_checkvin:receiveVehicleInfo', src, vehicleInfo)
        end
    end)
end)