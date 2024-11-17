local QBCore = exports['qb-core']:GetCoreObject()

local function GetRandomName()
    local first = Config.RandomNames.firstNames[math.random(#Config.RandomNames.firstNames)]
    local last = Config.RandomNames.lastNames[math.random(#Config.RandomNames.lastNames)]
    return first .. ' ' .. last
end

RegisterNetEvent('paradsie_checkvin:checkVehicleInfo')
AddEventHandler('paradsie_checkvin:checkVehicleInfo', function(plate, model)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.job.name ~= Config.RequiredJob then
        return
    end
    
    MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE plate = @plate', {
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
            MySQL.Async.fetchAll('SELECT * FROM players WHERE citizenid = @citizenid', {
                ['@citizenid'] = result[1].citizenid
            }, function(playerResult)
                if playerResult[1] then
                    local charinfo = json.decode(playerResult[1].charinfo)
                    vehicleInfo.owner = charinfo.firstname .. ' ' .. charinfo.lastname
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
