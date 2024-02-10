ESX = exports["es_extended"]:getSharedObject()


menugarage = {
    Base = {Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {0, 251, 255}, Title = "Garage"},
    Data = {currentMenu = "Quel véhicule voulez-vous ?"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)
            for i=1, #Listecar, 1 do 
                if btn.name == Listecar[i].name then
                    CloseMenu()
                    local name = Listecar[i].name 
                    local label = Listecar[i].model 
                    local hash = GetHashKey(label) 
                    RequestModel(hash)
                    while not HasModelLoaded(hash) do Wait(0) end
                    local car = CreateVehicle(hash, Config.Pos.SpawnVeh, true, false)
                    SetPedIntoVehicle(PlayerPedId(), car, -1)
                    SetVehRadioStation(car, "OFF")
                    SetVehicleFuelLevel(car, 100.0)
                    ESX.ShowNotification("Vous avez fait spawn : ~b~"..name)
                    spawncar(name, label)
                end
            end
        end,
},
    Menu = {
        ["Quel véhicule voulez-vous ?"] = {
            b = {
            }
        }
    }
}

function spawncar(name, label)

    CreateThread(function()        
        while true do 
                    
            ped = PlayerPedId()
            pos = GetEntityCoords(ped)
            menu = Config.Pos.Delcar
            dist = #(pos - menu)

            if IsPedInAnyVehicle(ped, false) then
                if dist <= 2 and ESX.PlayerData.job.name == "taxi" then

                    ESX.ShowHelpNotification("Appuies sur ~INPUT_CONTEXT~ pour garer le ~b~véhicule")

                    if IsControlJustPressed(1,51) then
                        veh = GetVehiclePedIsIn(PlayerPedId(), false)
                        DeleteVehicle(veh)
                    end
                else
                    Wait(1000)
                end
            else
                Wait(1000)
            
            end
            Wait(0)
        end
    end)
end

CreateThread(function()

    for i=1, #Listecar, 1 do 
        table.insert(menugarage.Menu["Quel véhicule voulez-vous ?"].b, {name = Listecar[i].name, ask = "", askX = true})
    end

    while true do 

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local menu = Config.Pos.Garage
        local dist =  #(pos - menu)
    
        if dist <= 2 and ESX.PlayerData.job.name == "taxi" then

            ESX.ShowHelpNotification("Appuie sur ~INPUT_CONTEXT~ pour ouvrir le ~b~garage")
            DrawMarker(6, menu, nil, nil, nil, -90, nil, nil, 0.7, 0.7, 0.7, 0, 251, 255, 200, false, true, 2, false, false, false, false)

            if IsControlJustPressed(1,51) then
                CreateMenu(menugarage)
            end
        else
            Wait(1000)
        end
        Wait(0)
    end
end)