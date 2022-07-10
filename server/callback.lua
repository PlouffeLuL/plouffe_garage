Callback:RegisterServerCallback("plouffe_garage:fetchmycarsfromgarage", function(source, cb, garage, authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) == true then
        if Auth:Events(playerId,"plouffe_garage:fetchmycarsfromgarage") == true then
            if exports.plouffe_society:IsPlayerDisabled(playerId) then
                Utils:Notify(playerId,"Vos dernier paiment de garage on été refuser par la banque vous n'avez donc pas accès a ce garage","error",10000)
            else
                local player = exports.ooc_core:getPlayerFromId(playerId)
                local result = MySQL.query.await("SELECT plate, vehicle FROM owned_vehicles WHERE state_id = @state_id AND garage = @garage", {
                    ["@state_id"] = player.state_id,
                    ["@garage"] = garage
                })
                cb(result)
            end
        end
    end
end)

Callback:RegisterServerCallback("plouffe_garage:getAllVehiclesInSocietyGarage", function(source, cb, garage, authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) == true then
        if Auth:Events(playerId,"plouffe_garage:getAllVehiclesInSocietyGarage") == true then
            local result = {}
            local player = exports.ooc_core:getPlayerFromId(playerId)

            if exports.plouffe_society:IsPlayerDisabled(playerId) then
                Utils:Notify(playerId,"Vos dernier paiment de garage on été refuser par la banque vous n'avez donc pas accès a ce garage","error",10000)
                cb(result)
            elseif GarageFnc:HasAcces(player,player.gang.name,garage) then
                MySQL.query("SELECT plate, vehicle FROM owned_vehicles WHERE garage = @garage AND private_garage = @private_garage", {
                    ["@garage"] = garage,
                    ["@private_garage"] = 0
                }, function(result)
                    cb(result)
                end)
            else
                cb(result)
            end
        end
    end
end)

Callback:RegisterServerCallback("plouffe_garage:putvehicleback", function(source,cb,props,garage,private,authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) == true then
        if Auth:Events(playerId,"plouffe_delivery:fetchmycarsfromgarage") == true then
            cb(GarageFnc:PutVehicleBack(props,garage,private))
        end
    end
end)

Callback:RegisterServerCallback("plouffe_garage:fetchmycarsfromimpound", function(source, cb, impound, authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) == true then
        if Auth:Events(playerId,"plouffe_garage:fetchmycarsfromimpound") == true then
            local result = {}

            if exports.plouffe_society:IsPlayerDisabled(playerId) then
                Utils:Notify(playerId,"Vos dernier paiment de fourriere on été refuser par la banque vous n'avez donc pas accès a la fourriere","error",10000)
            else
                local player = exports.ooc_core:getPlayerFromId(playerId)
                result = MySQL.query.await("SELECT plate, vehicle, impoundtype, impoundprice, impoundtime, impoundreleasetime FROM owned_vehicles WHERE state_id = @state_id AND (garage = @garage OR garage = 'sorti')", {
                    ["@state_id"] = player.state_id,
                    ["@garage"] = impound
                })
            end
            cb(result,os.time())
        end
    end
end)

Callback:RegisterServerCallback("plouffe_garage:policeimpound", function(source, cb, props, time, impound, type, authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) == true then
        if Auth:Events(playerId,"plouffe_garage:policeimpound") == true then
            local player = exports.ooc_core:getPlayerFromId(playerId)
            if type == "police" and player.job.name == "police" then
                cb(GarageFnc:SendVehicleToPoliceImpound(props, time, impound, type))
            else
                cb(false)
            end
        end
    end
end)

Callback:RegisterServerCallback("plouffe_garage:towingimpound", function(source, cb, props, impound, authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) and Auth:Events(playerId,"plouffe_garage:towingimpound") then
        local ped = GetPlayerPed(playerId)
        local vehicle = GetVehiclePedIsIn(ped)

        DeleteEntity(vehicle)

        cb(GarageFnc:SendVehicleToImpound(props, impound, "towed", playerId))
    end
end)

Callback:RegisterServerCallback("plouffe_garage:payforimpound", function(source, cb, plate, authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) == true then
        if Auth:Events(playerId,"plouffe_garage:payforimpound") == true then
            cb(GarageFnc:RequestTakeOut(playerId,plate))
        end
    end
end)

Callback:RegisterServerCallback("plouffe_garage:gang:putvehicleback", function(source,cb,props,garage,private)
    local playerId = source
    cb(GarageFnc:PutVehicleBack(props,garage,private))
end)

Callback:RegisterServerCallback("plouffe_garage:gang:fetchmycarsfromgarage", function(source, cb, garage)
    local playerId = source
    local player = exports.ooc_core:getPlayerFromId(playerId)
    local result = MySQL.query.await("SELECT plate, vehicle FROM owned_vehicles WHERE state_id = @state_id AND garage = @garage", {
        ["@state_id"] = player.state_id,
        ["@garage"] = garage
    })
    cb(result)
end)
