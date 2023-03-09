ESX = exports["es_extended"]:getSharedObject()

local openmenu = false

function Keyboardput(TextEntry, ExampleText, MaxStringLength) 
    AddTextEntry('FMMC_KEY_TIP1', TextEntry .. ':')
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
    blockinput = true
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        blockinput = false
        return result
    else
        Citizen.Wait(500)
        blockinput = false
        return nil
    end
end

local function calculatedprice(nbkm)
    return (Config.Mission.PrixKm*nbkm)/1000
end

function toPercent(num)
    return (num * 100) / 1000
end

menumission = {
    Base = {Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {0, 215, 255}, Title = "Mission"},
    Data = {currentMenu = "Menu :"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)
            if btn.name == "Commencez les missions" then
                init_mission()
            end
        end,
},
    Menu = {
        ["Menu :"] = {
            b = {
                {name = "Commencez les missions", ask = "", askX = true},
            }
        }
    }
}

function init_mission()
    CloseMenu()
    ESX.ShowNotification("Vous êtes à la recherche d'un ~b~client")
    local wait = math.random(Config.Mission.WaitMin, Config.Mission.WaitMax)
    Wait(wait)
    ESX.ShowNotification("Client trouver !\nDirigez-vous vers lui")
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)   
    local spawnped = ClientPosition[math.random(1, #ClientPosition)]
    local pi = ListePnj[math.random(1, #ListePnj)]
    local po = GetHashKey(pi)
    RequestModel(po)
    while not HasModelLoaded(po) do Wait(0) end
    local pipo = CreatePed(6, po, spawnped.x, spawnped.y, spawnped.z, 12.21, true, false)
    local posped = GetEntityCoords(pipo)
    goclient = #(pos - posped)
    SetNewWaypoint(posped.x, posped.y)
    
    local blip = AddBlipForEntity(pipo)
    SetBlipSprite (blip, Config.Blip.Id)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, Config.Blip.Taille)
	SetBlipColour (blip, Config.Blip.Couleur)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Client taxi")
	EndTextCommandSetBlipName(blip)
    openmenu = true
    findclient(pipo, posped, blip, goclient)

end

function findclient(pipo, posped, blip, goclient)
    CreateThread(function()
        local msg = false
        local wait, dist = 0, nil
        while (function()
            wait = 1000
            dist = #(GetEntityCoords(PlayerPedId()) - posped)
            if dist > 10 then return true end 
                
                wait = 0 
                ESX.ShowHelpNotification("Appuie sur ~INPUT_CONTEXT~ pour appeler le ~b~client")
            
            if IsControlJustPressed(1, 51) then
                RemoveBlip(blip)
                local healtveh = GetEntityHealth(GetVehiclePedIsIn(PlayerPedId(), false))
                startmission(pipo, posped, blip, goclient, healtveh)
                return 
            end
            return true
        end)() do Wait(wait) end 

    end)
end

function startmission(pipo, posped, blip, goclient, healtveh)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local veh = GetVehiclePedIsIn(ped, false)
    TaskEnterVehicle(pipo, veh, 10000, 1, 1.0, 1)
    local destpos = ClientPosition[math.random(1, #ClientPosition)]
    SetNewWaypoint(destpos.x, destpos.y)
    local destination = vector3(destpos.x, destpos.y, destpos.z)

    local destblip = AddBlipForCoord(destination)
    SetBlipSprite (destblip, Config.Blip.Id)
	SetBlipDisplay(destblip, 4)
	SetBlipScale(destblip, Config.Blip.Taille)
	SetBlipColour (destblip, Config.Blip.Couleur)
	SetBlipAsShortRange(destblip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("~y~Taxi ~s~- Destination")
	EndTextCommandSetBlipName(destblip)
    CreateThread(function()

        local tikoz = #(pos - destination)
        while true do 

            local pos = GetEntityCoords(PlayerPedId())
            local dist = #(pos - destination)
            
            if dist <= 10 then
            
                ESX.ShowHelpNotification("Appuie sur ~INPUT_CONTEXT~ pour terminer la ~b~course~")

                if IsControlJustPressed(1,51) then
                    if Config.Mission.StartDegat then
                        acthealt = GetEntityHealth(GetVehiclePedIsIn(PlayerPedId(), false))
                        TaskWanderStandard(pipo, 10.0, 10)
                        RemoveBlip(destblip)
                        dif = toPercent(healtveh)-toPercent(acthealt)
                        if dif >= Config.Mission.DegatMax then
                            ESX.ShowAdvancedNotification("Taxi", "~r~Vous avez dégrader le véhicule", "Vous ne serez pas payer pour cette course : \nDébut de la course : ~b~"..toPercent(healtveh).."%~s~\nFin de la course : ~r~"..toPercent(acthealt).."%~s~\nVous avez abimer le véhicule de ~y~"..dif.."%", "CHAR_TAXI", 8)
                        else
                            local payeentreprise, pourcentage = Config.Mission.PayeEntreprise, Config.Mission.Pourcentage
                            TriggerServerEvent("Tikoz/TaxiBuyMission", Config.Mission.Paye, calculatedprice(tikoz), calculatedprice(goclient), payeentreprise, pourcentage)    
                        end
                        openmenu = false
                        return startmission
                    else
                        TaskWanderStandard(pipo, 10.0, 10)
                        RemoveBlip(destblip)
                        local payeentreprise, pourcentage = Config.Mission.PayeEntreprise, Config.Mission.Pourcentage
                        TriggerServerEvent("Tikoz/TaxiBuyMission", Config.Mission.Paye, calculatedprice(tikoz), calculatedprice(goclient), payeentreprise, pourcentage)    
                        openmenu = false
                        return startmission
                    end
                end
            else
                Wait(1000)
            end
            Wait(0)
        end
    end)
end

keyRegister("missiontaxi", "Mission taxi", "L", function()
    if ESX.PlayerData.job.name == "taxi" and not openmenu then
        if IsPedInAnyVehicle(PlayerPedId(), true) then
            CreateMenu(menumission)            
        end
    end
end)

menuappel = {
    Base = {Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {0, 215, 255}, Title = "Appeler un taxi"},
    Data = {currentMenu = 'Menu :'},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)
            if btn.name == "Commander un taxi" then
                apltaxi()
            end
        end,
},
    Menu = {
        ["Menu :"] = {
            b = {
                {name = "Commander un taxi", ask = "", askX = true},
            }
        }
    }
}

opentaxi = false

function apltaxi()  
    CreateThread(function()
        local prenom = Keyboardput("Quel est votre prénom ?", "", 15)
        local nom = Keyboardput("Quel est votre nom ?", "", 15)
        local num = Keyboardput("Quel est votre numéro ?", "", 15)
        local pos = GetEntityCoords(PlayerPedId())
        local idclient = GetPlayerServerId(PlayerId())
        TriggerServerEvent("Tikoz/CallTaxi", idclient, nom, prenom, num, json.encode(pos))
        ESX.ShowNotification("Vous avez appelez un ~b~taxi~s~\nVous receverez une notification si quelqu'un prend votre appel")
        Wait(Config.Time)
        opentaxi = true 
    end)
end

RegisterCommand("taxi", function()
    if not opentaxi then
        CreateMenu(menuappel)
    end
end, false)