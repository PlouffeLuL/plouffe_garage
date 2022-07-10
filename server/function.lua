function GarageFnc:Init()
    MySQL.query("SELECT * FROM owned_vehicles", function(results)
        for k,v in ipairs(results) do
            if v.garage then
                local str = "gang_"..v.garage
                if Garage.Zones[str] then
                    MySQL.query("UPDATE owned_vehicles SET garage = @garage WHERE plate = @plate",{
                        ["@plate"] = v.plate,
                        ["@garage"] = str
                    })
                end
            end
        end
    end)
end

function GarageFnc:UpdateVehicleState(plate,zone,ignoreTime)
    if not ignoreTime then
        MySQL.query("UPDATE owned_vehicles SET garage = @garage, impoundtime = @impoundtime WHERE plate = @plate",{["@plate"] = plate, ["@garage"] = zone, ["@impoundtime"] = os.time()})
    else
        MySQL.query("UPDATE owned_vehicles SET garage = @garage WHERE plate = @plate",{["@plate"] = plate, ["@garage"] = zone})
    end
end

function GarageFnc:PutVehicleBack(props,garage,private)
    local result = MySQL.query.await("SELECT vehicle FROM owned_vehicles WHERE plate = @plate",{['@plate'] = props.plate})
    if result[1] then
        local jSonProps = json.encode(props)
        local originalProps = json.decode(result[1].vehicle)
        if originalProps.model == props.model then
            MySQL.query.await("UPDATE owned_vehicles SET vehicle=@vehicle, garage=@garage, storedhouse=@storedhouse, private_garage=@private_garage WHERE plate=@plate", {
                ["@vehicle"] = jSonProps,
                ["@garage"] = garage, 
                ["@storedhouse"] = nil,
                ["@private_garage"] = private,
                ["@plate"] = props.plate
            })
            exports.plouffe_vehicle:SaveVehicleFromPlate(props.plate)
            return true
        end
    end
    return false
end

function GarageFnc:SendVehicleToPoliceImpound(props, time, impound, type)
    local newtime = ((60 * 60) * tonumber(time)) + os.time()
    MySQL.query.await("UPDATE owned_vehicles SET vehicle = @vehicle, garage = @garage, storedhouse = @storedhouse, impoundtype = @impoundtype, impoundreleasetime = @impoundreleasetime WHERE plate = @plate", {
        ["@vehicle"] = json.encode(props),
        ["@garage"] = impound, 
        ["@storedhouse"] = nil,
        ["@impoundtype"] = type,
        ["@impoundreleasetime"] = newtime,
        ["@plate"] = props.plate
    })
    return true
end

function GarageFnc:SendVehicleToImpound(props,impound,type, playerId)
    MySQL.query.await("UPDATE owned_vehicles SET vehicle = @vehicle, garage = @garage, storedhouse = @storedhouse, impoundtype = @impoundtype, impoundprice = @impoundprice WHERE plate = @plate", {
        ["@vehicle"] = json.encode(props),
        ["@garage"] = impound, 
        ["@storedhouse"] = nil,
        ["@impoundtype"] = type,
        ["@plate"] = props.plate,
        ["@impoundprice"] = Garage.TowingImpoundPrice
    })
    
    exports.ooc_core:addItem(playerId, "money", 200)
    -- exports.plouffe_society:AddSocietyAccountMoney(nil,"society_tow", "bank", 100, function() end)
    
    return true
end

function GarageFnc:RequestTakeOut(playerId,plate)
    local result = MySQL.query.await("SELECT impoundprice, impoundTime FROM owned_vehicles WHERE plate = @plate",{["@plate"] = plate})
    local price = GarageFnc:GetPrice(result[1].impoundprice, os.time(), result[1].impoundTime)
    local money = exports.ooc_core:getItemCount(playerId,"money")
    if money >= price then
        exports.ooc_core:removeItem(playerId,"money",price)
        MySQL.query("UPDATE owned_vehicles SET impoundtype = @impoundtype, impoundtime = @impoundtime, impoundreleasetime = @impoundreleasetime, impoundprice = @impoundprice WHERE plate = @plate", {
            ["@impoundtype"] = "default",
            ["@impoundreleasetime"] = 0,
            ["@impoundtime"] = os.time(),
            ["@impoundprice"] = nil,
            ["@plate"] = plate
        })
        return true
    else
        return false
    end
end

function GarageFnc:GetPrice(price,servertime,impoundTime)
    if not price then price = Garage.DefaultImpoundPrice end
    local secondsPassed = servertime - impoundTime
    local deduction = math.floor(secondsPassed * Garage.ReductionPerSeconds)
    price = price - deduction
    if price < 0 then
        price = 0
    end
    return price
end

function GarageFnc:IsPlateTaken(plate)
    return MySQL.query.await("SELECT 1 FROM owned_vehicles WHERE plate = @plate",{["@plate"] = plate})[1] ~= nil
end

function GarageFnc:GeneratePlate()
    local availble = true
    local plate = ""
    
    while availble do
        local init = os.time()
        plate = ""
        repeat
            plate = plate..Server.PlatesStr[math.random(1,#Server.PlatesStr)]
        until plate:len() >= 8 or os.time() - init > 2
        availble = GarageFnc:IsPlateTaken(plate)
        Wait(0)
    end

	return plate
end

function GarageFnc:RefreshVehicleProps(props,_source)
    local vehicle = MySQL.scalar.await("SELECT vehicle FROM owned_vehicles WHERE plate = @plate",{['@plate'] = props.plate})
    if vehicle then
        local jsonProps = json.encode(props)
        local originalProps = json.decode(vehicle)
        if originalProps.model == props.model then
            MySQL.query("UPDATE owned_vehicles SET vehicle=@vehicle WHERE plate=@plate", {
                ["@vehicle"] = jsonProps,
                ["@plate"] = props.plate
            })
        end
    end
end

function GarageFnc:HasAcces(player,clubname,garage)
    if Garage.Zones[garage].acces then
        if Garage.Zones[garage].acces.jobs and Garage.Zones[garage].acces.jobs[player.job.name] and Garage.Zones[garage].acces.jobs[player.job.name][tostring(player.job.grade)] then
            return true
        elseif clubname and Garage.Zones[garage].acces.gangs and Garage.Zones[garage].acces.gangs[clubname] then
            return true
        else 
            return false
        end
    else
        return true
    end
end

function GarageFnc:CreateGarage(data)
    Garage.Zones[data.name] = data
    TriggerClientEvent("plouffe_garage:force_sync_new_garage", -1, data)
end

function CreateGarage(data)
    GarageFnc:CreateGarage(data)
end

function CreatePlate() 
    return GarageFnc:GeneratePlate()
end