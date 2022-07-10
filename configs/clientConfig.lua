Garage = {}
GarageFnc = {} 
TriggerServerEvent("plouffe_garage:sendConfig")

RegisterNetEvent("plouffe_garage:getConfig",function(list)
	if list == nil then
		CreateThread(function()
			while true do
				Wait(0)
				Garage = nil
				GarageFnc = nil
			end
		end)
	else
		Garage = list
		GarageFnc:Start()
	end
end)