local Callback = exports.plouffe_lib:Get("Callback")
local Utils = exports.plouffe_lib:Get("Utils")

function GarageFnc:Start()
    TriggerEvent('ooc_core:getCore', function(Core)
        while not Core.Player:IsPlayerLoaded() do
            Wait(500)
        end

        Garage.Player = Core.Player:GetPlayerData()

        self:RegisterAllEvents()
        self:ExportsAllZones()
        self:CreateBlips()
    end)
end

function GarageFnc:ExportsAllZones()
    for k,v in pairs(Garage.Zones) do
        local this = v
        this.aditionalParams = {zone = k}
        exports.plouffe_lib:ValidateZoneData(this)
    end
end

function GarageFnc:RegisterAllEvents()
    AddEventHandler('plouffe_lib:setGroup', function(data)
        Garage.Player[data.type] = data
    end)

    RegisterNetEvent("plouffe_lib:inVehicle", function(inVehicle, vehicleId)
        Garage.Utils.inCar = inVehicle
        Garage.Utils.carId = vehicleId
    end)

    RegisterNetEvent('ooc_core:setgang', function(gang)
        Garage.Player.gang = gang
    end)

    RegisterNetEvent("plouffe_garage:open", function()
        GarageFnc:OpenGarageMenu()
    end)

    RegisterNetEvent("plouffe_garage:force_sync_new_garage", function(info)
        Garage.Zones[info.name] = info
        exports.plouffe_lib:ValidateZoneData(Garage.Zones[info.name])
    end)
end

function GarageFnc:IsAnyVehicleWithPlateNear(plate)
    local vehicles = Utils:GetVehicles()
    for k,v in pairs(vehicles) do
        if DoesEntityExist(v) then
			if GetVehicleNumberPlateText(v):upper() == plate:upper() then
                Utils:Notify('error', 'Votre véhicule est déjà sorti et traine dans une rue')
				return true
			end
		end
    end
    return false
end

function GarageFnc:CreateVehicle(props, plate)
    local vehicle = Utils:SpawnVehicle(props.model,Garage.Utils.pedCoords,GetEntityHeading(Garage.Utils.ped),true,true,true)
    Utils:SetVehicleProps(vehicle, props)

    plate = GetVehicleNumberPlateText(vehicle)

    TaskWarpPedIntoVehicle(Garage.Utils.ped, vehicle, -1)

    if DoesEntityExist(vehicle) then
        TriggerServerEvent('plouffe_garage:setvehicleout',plate,"sorti",Garage.Utils.MyAuthKey)
    end
end

function GarageFnc:SpawnVehicle(plate, props, price)
    local inGarage, garageIndex, label, isImpoud, isSociety, isHouse = IsInGarage()
    Garage.Utils.ped = PlayerPedId()
    Garage.Utils.pedCoords = GetEntityCoords(Garage.Utils.ped)
    if not GarageFnc:IsAnyVehicleWithPlateNear(plate) then
        if IsThisModelAHeli(props.model) or IsThisModelAPlane(props.model) then
            Utils:Notify('inform', 'Vous ne pouvez pas sortir ce genre de véhicule ici')
            return
        end
        if isImpoud then
            if price > 0 then
                Callback:Await("plouffe_garage:payforimpound", function(canpay)
                    if canpay then
                        GarageFnc:CreateVehicle(props, plate)
                    else
                        Utils:Notify("error", "Vous n'avez pas asser d'argent", 5000)
                    end
                end, plate, Garage.Utils.MyAuthKey)
            else
                GarageFnc:CreateVehicle(props, plate)
            end
        else
            GarageFnc:CreateVehicle(props, plate)
        end
    end
end

function GarageFnc:PutVehicleBack(private)
    local inGarage, garageIndex, label, isImpoud, isSociety, isHouse = IsInGarage()
    local vehicle = GetVehiclePedIsIn(Garage.Utils.ped)
    if not isImpoud then
        if vehicle ~= 0 and Utils:AssureEntityControl(vehicle) then
            Callback:Await("plouffe_garage:putvehicleback", function(setBack)
                if Utils:AssureEntityControl(vehicle) then
                    if setBack then
                        TaskLeaveVehicle(Garage.Utils.ped,vehicle,1)
                        while IsPedInVehicle(Garage.Utils.ped, vehicle, true) do
                            Wait(0)
                        end
                        Wait(1100)
                        DeleteEntity(vehicle)
                    end
                end
            end, Utils:GetVehicleProps(vehicle), garageIndex, private, Garage.Utils.MyAuthKey)
        end
    end
end

function GarageFnc:OpenGarageMenu()
    Garage.Utils.ped = PlayerPedId()
    local inGarage, garageIndex, label, isImpoud, isSociety, isHouse = IsInGarage()
    local foundVehicle = IsPedInAnyVehicle(Garage.Utils.ped)
    local data = {}

    if not foundVehicle or foundVehicle == 0 then
        table.insert(data,{
            id = 1,
            header = "Sortir un véhicule",
            txt = "Vous permet d'acceder a vos véhicules",
            params = {
                event = "",
                args = {
                    action = "takeout"
                }
            }
        })
    end

    if foundVehicle and foundVehicle ~= 0 and not isImpoud then
        table.insert(data,
            {
                id = 2,
                header = "Ranger le vehicule",
                txt = "Ranger votre véhicule dans ce garage",
                params = {
                    event = "",
                    args = {
                        action = "putin"
                    }
                }
            }
        )
    elseif foundVehicle and foundVehicle ~= 0 and isImpoud then
        table.insert(data,
            {
                id = 2,
                header = "Envoyer a la fourrière",
                txt = "Envoyer ce véhicule a la fourrière",
                params = {
                    event = "",
                    args = {
                        action = "impound"
                    }
                }
            }
        )
    end

    if #data > 0 then
        exports.ooc_menu:Open(data, function(params)
            if not params then
                return
            end

            if params.action == "takeout" then
                GarageFnc:OpenCarsGarageMenu()
            elseif params.action == "putin" then
                if isSociety then
                    if GarageFnc:HasAcces(garageIndex) then
                        local menuData = {
                            {
                                id = 1,
                                header = "Ranger dans le garage publique",
                                txt = "Tout ceux qui ont accès a ce garage vont avoir accès a votre véhicule",
                                params = {
                                    event = "",
                                    args = {
                                        private = 0
                                    }
                                }
                            },
                            {
                                id = 2,
                                header = "Ranger dans votre garage personel",
                                txt = "Seulement vous aurez accès a votre véhicule",
                                params = {
                                    event = "",
                                    args = {
                                        private = 1
                                    }
                                }
                            }
                        }
                        exports.ooc_menu:Open(menuData, function(params)
                            if not params then
                                return
                            end

                            GarageFnc:PutVehicleBack(params.private)
                        end)
                    else
                        Utils:Notify("error", "Vous n'avez pas accès a ce garage", 5000)
                    end
                elseif isHouse then
                    if exports.plouffe_housing:HasGArageAcces(Garage.Zones[garageIndex].houseId) then
                        GarageFnc:PutVehicleBack(1)
                    else
                        Utils:Notify("error", "Vous n'avez pas accès a ce garage", 5000)
                    end
                else
                    GarageFnc:PutVehicleBack(1)
                end
            elseif params.action == "impound" then
                GarageFnc:ImpoundMenu(GarageFnc:IsPolice())
            end
        end)
    end
end

function GarageFnc:FormatTimeLeft(seconds)
    if seconds <= 0 then
        return "00:00:00"
    else
        local days = string.format("%02.f", math.floor(seconds / 86400))
        local hours = string.format("%02.f", math.floor(seconds / 3600 - (days * 24)))
        local mins = string.format("%02.f", math.floor(seconds / 60 - (days * 1440) - (hours * 60)))
        return days .. "j " .. hours .. "h " .. mins .. "m"
    end
end

function GarageFnc:OpenCarsGarageMenu()
    local inGarage, garageIndex, label, isImpoud, isSociety, isHouse = IsInGarage()

    if not isImpoud and not isSociety and not isHouse then
        Callback:Await("plouffe_garage:fetchmycarsfromgarage", function(mycars)
            if #mycars > 0 then
                local data = {}

                for i = 1, #mycars, 1 do
                    local props = json.decode(mycars[i].vehicle)
                    local name = GetDisplayNameFromVehicleModel(props.model)
                    -- local nameLabel = name:sub(1,1):upper()..""..name:sub(2, name:len()):lower()
                    local nameLabel = GetLabelText(name)

                    table.insert(data,{
                        id = i,
                        header = "Model: "..nameLabel.." || Plaque: "..mycars[i].plate,
                        txt = "Moteur: "..string.format("%.00f", tostring(((props.engineHealth or 1000) - 300) / 7)).." %".." Essence: "..string.format("%.00f",tostring((props.fuelLevel or 1000))).." %",
                        params = {
                            event = "",
                            args = {
                                plate = mycars[i].plate,
                                props = props
                            }
                        }
                    })
                end

                exports.ooc_menu:Open(data, function(params)
                    if not params then
                        return
                    end

                    GarageFnc:SpawnVehicle(params.plate,params.props,0)
                end)
            else
                Utils:Notify("error", "Vous n'avez pas de véhicule ici", 5000)
            end
        end, garageIndex, Garage.Utils.MyAuthKey)
    elseif isImpoud then
        Callback:Await("plouffe_garage:fetchmycarsfromimpound", function(mycars,servertime)
            if #mycars > 0 then
                local data = {}

                for i = 1, #mycars, 1 do
                    local props = json.decode(mycars[i].vehicle)
                    local name = GetDisplayNameFromVehicleModel(props.model)
                    -- local nameLabel = name:sub(1,1):upper()..""..name:sub(2, name:len()):lower()
                    local nameLabel = GetLabelText(name)
                    local header = Garage.Labels[mycars[i].impoundtype]
                    local txt = "Model: "..nameLabel.." || Plaque: "..mycars[i].plate
                    local cantakeback = true
                    local price = GarageFnc:GetPrice(mycars[i].impoundprice,servertime,mycars[i].impoundtime)

                    if mycars[i].impoundtype == "police" then
                        header = header.." || "..GarageFnc:FormatTimeLeft(mycars[i].impoundreleasetime - servertime)
                        if mycars[i].impoundreleasetime - servertime > 0 then
                            cantakeback = false
                        end
                    else
                        header = header.." || "..tostring(price).." $"
                    end

                    table.insert(data,{
                        id = i,
                        header = header,
                        txt = txt,
                        params = {
                            event = "",
                            args = {
                                plate = mycars[i].plate,
                                props = props,
                                canTakeBack = cantakeback,
                                price = price
                            }
                        }
                    })
                end

                exports.ooc_menu:Open(data, function(params)
                    if not params then
                        return
                    end

                    if params.canTakeBack then
                        GarageFnc:SpawnVehicle(params.plate, params.props, params.price)
                    else
                        Utils:Notify("error", "Vous ne pouvez pas sortir ce véhicule présentement")
                    end
                end)
            else
                Utils:Notify("error", "Vous n'avez pas de véhicule ici", 5000)
            end
        end, garageIndex, Garage.Utils.MyAuthKey)
    elseif isSociety then
        if GarageFnc:HasAcces(garageIndex) then
            local menuData = {
                {
                    id = 1,
                    header = Garage.Zones[garageIndex].label,
                    txt = "Choisir une action",
                    params = {
                        event = "",
                        args = {
                            action = "return"
                        }
                    }
                },
                {
                    id = 2,
                    header = "Ouvrir le garage publique",
                    txt = "Voir tous les véhicule dans le garage publique",
                    params = {
                        event = "",
                        args = {
                            action = "public"
                        }
                    }
                },
                {
                    id = 3,
                    header = "Ouvrir votre garage personel",
                    txt = "Voir tous les véhicule de votre garage",
                    params = {
                        event = "",
                        args = {
                            action = "personnal"
                        }
                    }
                }
            }
            exports.ooc_menu:Open(menuData, function(params)
                if not params then
                    return
                end

                if params.action == "public" then
                    Callback:Await("plouffe_garage:getAllVehiclesInSocietyGarage", function(mycars,servertime)
                        if #mycars > 0 then
                            local data = {}

                            for i = 1, #mycars, 1 do
                                local props = json.decode(mycars[i].vehicle)
                                local name = GetDisplayNameFromVehicleModel(props.model)
                                -- local nameLabel = name:sub(1,1):upper()..""..name:sub(2, name:len()):lower()
                                local nameLabel = GetLabelText(name)

                                table.insert(data,{
                                    id = i,
                                    header = "Model: "..nameLabel.." || Plaque: "..mycars[i].plate,
                                    txt = "Moteur: "..string.format("%.00f", tostring(props.engineHealth / 10)).." %".." Essence: "..string.format("%.00f",tostring(props.fuelLevel)).." %",
                                    params = {
                                        event = "",
                                        args = {
                                            plate = mycars[i].plate,
                                            props = props
                                        }
                                    }
                                })
                            end

                            exports.ooc_menu:Open(data, function(params)
                                if not params then
                                    return
                                end

                                GarageFnc:SpawnVehicle(params.plate,params.props,0)
                            end)
                        else
                            Utils:Notify("error", "Il n'y a pas de véhicule ici", 5000)
                        end
                    end, garageIndex, Garage.Utils.MyAuthKey)
                elseif params.action == "personnal" then
                    Callback:Await("plouffe_garage:fetchmycarsfromgarage", function(mycars)
                        if #mycars > 0 then
                            local data = {}

                            for i = 1, #mycars, 1 do
                                local props = json.decode(mycars[i].vehicle)
                                local name = GetDisplayNameFromVehicleModel(props.model)
                                -- local nameLabel = name:sub(1,1):upper()..""..name:sub(2, name:len()):lower()
                                local nameLabel = GetLabelText(name)

                                table.insert(data,{
                                    id = i,
                                    header = "Model: "..nameLabel.." || Plaque: "..mycars[i].plate,
                                    txt = "Moteur: "..string.format("%.00f", tostring(props.engineHealth / 10)).." %".." Essence: "..string.format("%.00f",tostring(props.fuelLevel)).." %",
                                    params = {
                                        event = "",
                                        args = {
                                            plate = mycars[i].plate,
                                            props = props
                                        }
                                    }
                                })
                            end

                            exports.ooc_menu:Open(data, function(params)
                                if not params then
                                    return
                                end

                                GarageFnc:SpawnVehicle(params.plate,params.props,0)
                            end)
                        else
                            Utils:Notify("error", "Vous n'avez pas de véhicule ici", 5000)
                        end
                    end, garageIndex, Garage.Utils.MyAuthKey)
                else
                    GarageFnc:OpenCarsGarageMenu()
                end
            end)
        else
            Utils:Notify("error", "Vous n'avez pas accès a ce garage", 5000)
        end
    elseif isHouse then
        if exports.plouffe_housing:HasGArageAcces(Garage.Zones[garageIndex].houseId) then
            Callback:Await("plouffe_garage:fetchmycarsfromgarage", function(mycars)
                if #mycars > 0 then
                    local data = {}

                    for i = 1, #mycars, 1 do
                        local props = json.decode(mycars[i].vehicle)
                        local name = GetDisplayNameFromVehicleModel(props.model)
                        -- local nameLabel = name:sub(1,1):upper()..""..name:sub(2, name:len()):lower()
                        local nameLabel = GetLabelText(name)

                        table.insert(data,{
                            id = i,
                            header = "Model: "..nameLabel.." || Plaque: "..mycars[i].plate,
                            txt = "Moteur: "..string.format("%.00f", tostring((props.engineHealth - 300) / 7)).." %".." Essence: "..string.format("%.00f",tostring(props.fuelLevel)).." %",
                            params = {
                                event = "",
                                args = {
                                    plate = mycars[i].plate,
                                    props = props
                                }
                            }
                        })
                    end

                    exports.ooc_menu:Open(data, function(params)
                        if not params then
                            return
                        end

                        GarageFnc:SpawnVehicle(params.plate,params.props,0)
                    end)
                else
                    Utils:Notify("error", "Vous n'avez pas de véhicule ici", 5000)
                end
            end, garageIndex, Garage.Utils.MyAuthKey)
        else
            Utils:Notify("error", "Vous n'avez pas accès a ce garage", 5000)
        end
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

function GarageFnc:ImpoundMenu(isPolice)
    if isPolice and GarageFnc:IsPolice() then
        if Garage.Player and Garage.Player.job and Garage.ImpoundAcces[Garage.Player.job.name] then
            local data = {}
            local i = 1
            if Garage.ImpoundAcces[Garage.Player.job.name][tostring(Garage.Player.job.grade)] then
                for k,v in pairs(Garage.ImpoundAcces[Garage.Player.job.name][tostring(Garage.Player.job.grade)]) do
                    local txt = tostring(v).." heurs"
                    table.insert(data,{
                        id = i,
                        header = "Envoyer a la fourrière",
                        txt =txt,
                        params = {
                            event = "",
                            args = {
                                time = v
                            }
                        }
                    })
                    i = i + 1
                end
                exports.ooc_menu:Open(data, function(params)
                    if not params then
                        return
                    end

                    GarageFnc:ImpoundVehicle(params.time,GarageFnc:IsPolice())
                end)
            end
        end
    else
        GarageFnc:ImpoundVehicle(0,false)
    end
end

function GarageFnc:ImpoundVehicle(time, isPolice)
    if isPolice and GarageFnc:IsPolice() then
        local inGarage, garageIndex, label, isImpoud, isSociety, isHouse = IsInGarage()
        local vehicle = GetVehiclePedIsIn(Garage.Utils.ped)
        if vehicle ~= 0 and vehicle then
            if isImpoud then
                if GarageFnc:IsPolice() and GarageFnc:ValidateTime(time) then
                    Callback:Await("plouffe_garage:policeimpound", function(setBack)
                        if Utils:AssureEntityControl(vehicle) then
                            if setBack then
                                TaskLeaveVehicle(Garage.Utils.ped,vehicle,1)
                                while IsPedInVehicle(Garage.Utils.ped, vehicle, true) do
                                    Wait(0)
                                end
                                Wait(1100)
                                DeleteEntity(vehicle)
                            end
                        end
                    end, Utils:GetVehicleProps(vehicle), time, garageIndex, "police", Garage.Utils.MyAuthKey)
                end
            else
                Utils:Notify("error","Vous devez etre a la fourrière pour faire ca")
            end
        end
    else
        local inGarage, garageIndex, label, isImpoud, isSociety, isHouse = IsInGarage()
        local vehicle = GetVehiclePedIsIn(Garage.Utils.ped)
        if vehicle ~= 0 and vehicle then
            if isImpoud then
                if GetPedInVehicleSeat(vehicle, -1) ~= Garage.Utils.ped then
                    return
                end

                -- TaskLeaveVehicle(Garage.Utils.ped,vehicle,1)
                -- while IsPedInVehicle(Garage.Utils.ped, vehicle, true) do
                --     Wait(0)
                -- end
                -- Wait(1100)

                Callback:Await("plouffe_garage:towingimpound", function(setBack)

                end, Utils:GetVehicleProps(vehicle), garageIndex, Garage.Utils.MyAuthKey)
            else
                Utils:Notify("error","Vous devez etre a la fourrière pour faire ca")
            end
        end
    end
end

function GarageFnc:ValidateTime(time)
    for k,v in pairs(Garage.ImpoundAcces[Garage.Player.job.name][tostring(Garage.Player.job.grade)]) do
        if tonumber(time) == tonumber(v) then
            return true
        end
    end
    return false
end

function GarageFnc:IsPolice()
    return Garage.Player ~= nil and Garage.Player.job ~= nil and Garage.Player.job.name == "police"
end

function GarageFnc:CreateBlips()
	for k,v in pairs(Garage.Zones) do
        if v.useBlip then
            -- if not v.isImpound then
            --     local blip = AddBlipForCoord(v.coords)
            --     SetBlipSprite(blip, 357)
            --     SetBlipDisplay(blip, 4)
            --     SetBlipScale(blip, 0.65)
            --     SetBlipColour(blip, 54)
            --     SetBlipAsShortRange(blip, true)
            --     BeginTextCommandSetBlipName("STRING")
            --     AddTextComponentString("Garage")
            --     EndTextCommandSetBlipName(blip)
            -- else
            --     local blip = AddBlipForCoord(v.coords)
            --     SetBlipSprite(blip, 68)
            --     SetBlipDisplay(blip, 4)
            --     SetBlipScale(blip, 0.65)
            --     SetBlipColour(blip, 54)
            --     SetBlipAsShortRange(blip, true)
            --     BeginTextCommandSetBlipName("STRING")
            --     AddTextComponentString("Fourrière")
            --     EndTextCommandSetBlipName(blip)
            -- end
        end
	end
end

function GarageFnc:OpenCarsGarageMenuCustom(garage)
    if garage then
        Callback:Await("plouffe_garage:fetchmycarsfromgarage", function(mycars)
            if #mycars > 0 then
                local data = {}

                for i = 1, #mycars, 1 do
                    local props = json.decode(mycars[i].vehicle)
                    local name = GetDisplayNameFromVehicleModel(props.model)
                    -- local nameLabel = name:sub(1,1):upper()..""..name:sub(2, name:len()):lower()
                    local nameLabel = GetLabelText(name)

                    table.insert(data,{
                        id = i,
                        header = "Model: "..nameLabel.." || Plaque: "..mycars[i].plate,
                        txt = "Moteur: "..string.format("%.00f", tostring(props.engineHealth / 10)).." %".." Essence: "..string.format("%.00f",tostring(props.fuelLevel)).." %",
                        params = {
                            event = "",
                            args = {
                                plate = mycars[i].plate,
                                props = props
                            }
                        }
                    })
                end

                exports.ooc_menu:Open(data, function(params)
                    if not params then
                        return
                    end

                    GarageFnc:SpawnVehicle(params.plate,params.props,0)
                end)
            end
        end, garage, Garage.Utils.MyAuthKey)
    end
end

function GarageFnc:PutVehicleBackCustom(garage)
    local vehicle = GetVehiclePedIsIn(Garage.Utils.ped)
    if garage then
        if vehicle ~= 0 and Utils:AssureEntityControl(vehicle) then
            Callback:Await("plouffe_garage:putvehicleback", function(setBack)
                if Utils:AssureEntityControl(vehicle) then
                    if setBack then
                        TaskLeaveVehicle(Garage.Utils.ped,vehicle,1)
                        while IsPedInVehicle(Garage.Utils.ped, vehicle, true) do
                            Wait(0)
                        end
                        Wait(1100)
                        DeleteEntity(vehicle)
                    end
                end
            end, Utils:GetVehicleProps(vehicle), garage, 1,Garage.Utils.MyAuthKey)
        end
    end
end

function GarageFnc:HasAcces(garage)
    if Garage.Zones[garage].access then
        if Garage.Zones[garage].access.jobs and Garage.Zones[garage].access.jobs[Garage.Player.job.name] and Garage.Zones[garage].access.jobs[Garage.Player.job.name][tostring(Garage.Player.job.grade)] then
            return true
        elseif Garage.Zones[garage].access.gangs and Garage.Zones[garage].access.gangs[Garage.Player.gang.name] and Garage.Zones[garage].access.gangs[Garage.Player.gang.name][tostring(Garage.Player.gang.grade)] then
            return true
        else
            return false
        end
    else
        return true
    end
end

function GarageFnc:RecoverVehicle()
    local menuData = {
        {
            id = 1,
            header = "Ranger dans le garage publique",
            txt = "Tout ceux qui ont accès a ce garage vont avoir accès a votre véhicule",
            params = {
                event = "",
                args = {
                    private = 0
                }
            }
        },
        {
            id = 2,
            header = "Ranger dans votre garage personel",
            txt = "Seulement vous aurez accès a votre véhicule",
            params = {
                event = "",
                args = {
                    private = 1
                }
            }
        }
    }
    exports.ooc_menu:Open(menuData, function(params)
        if not params then
            return
        end

        GarageFnc:PutVehicleBack(params.private)
    end)
end

function IsInGarage()
    Garage.Utils.ped = PlayerPedId()
    Garage.Utils.pedCoords = GetEntityCoords(Garage.Utils.ped)
    for k,v in pairs(Garage.Zones) do
        if not v.box then
            local dstCheck = #(Garage.Utils.pedCoords - v.coords)
            if dstCheck <= v.maxDst and ((Garage.Utils.pedCoords.z - v.coords.z > - 1.0 and Garage.Utils.pedCoords.z - v.coords.z < 1.0 ) ) then
                return true, k, v.label, v.isImpound, v.isSociety, v.isHouse
            end
        else
            if exports.plouffe_lib:IsInZone(k) then
                return true, k, v.label, v.isImpound, v.isSociety, v.isHouse
            end
        end
    end
    return false, nil
end

function CustomFetchGarage(garage)
    GarageFnc:OpenCarsGarageMenuCustom(garage)
end

function CustomPuInGarage(garage)
    GarageFnc:PutVehicleBackCustom(garage)
end

function UpdateCurrentVehicle()
    if exports.ooc_bennys:IsInBennys(true) then
        TriggerServerEvent("plouffe_garage:updatevehicleprops", Utils:GetVehicleProps(GetVehiclePedIsIn(PlayerPedId())), Garage.Utils.MyAuthKey)
    end
end

function GetGarageInfo(index)
    if Garage.Zones[index] then
        return Garage.Zones[index]
    end
end
