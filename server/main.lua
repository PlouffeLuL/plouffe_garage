CreateThread(function()
    MySQL.ready(function()
        GarageFnc:Init()
    end)
end)

RegisterNetEvent("plouffe_garage:sendConfig",function()
    local playerId = source
    local registred, key = Auth:Register(playerId)

    if registred then
        local cbArray = Garage
        cbArray.Utils.MyAuthKey = key
        TriggerClientEvent("plouffe_garage:getConfig",playerId,cbArray)
    else
        TriggerClientEvent("plouffe_garage:getConfig",playerId,nil)
    end
end)

RegisterNetEvent("plouffe_garage:setvehicleout",function(plate,zone,authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) == true then
        if Auth:Events(playerId,"plouffe_garage:setvehicleout") == true then
            GarageFnc:UpdateVehicleState(plate,zone)
        end
    end
end)

RegisterNetEvent("plouffe_garage:updatevehicleprops",function(props,authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) == true then
        if Auth:Events(playerId,"plouffe_garage:updatevehicleprops") == true then
            GarageFnc:RefreshVehicleProps(props,playerId)
        end
    end
end)