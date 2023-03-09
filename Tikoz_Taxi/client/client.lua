ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

local Tikozaal = {}

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

function facturetaxi()
    local amount = Keyboardput("Entré le montant", "", 15)
    
    if not amount then
        ESX.ShowNotification('~r~Montant invalide')
    else
        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
  
        if closestPlayer == -1 or closestDistance > 3.0 then
          ESX.ShowNotification('Pas de joueurs à ~b~proximité')
        else
          local playerPed = PlayerPedId()
  
            Citizen.CreateThread(function()
           
              ClearPedTasks(playerPed)
              TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_taxi', "~b~Taxi", amount)
              ESX.ShowNotification("Vous avez bien envoyer la ~b~facture")
            end)
        end
    end
end

menutaxi = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {0, 251, 255}, Title = "Taxi"},
    Data = { currentMenu = "Menu :"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)

            if btn.name == "Annonce" then
                OpenMenu('Annonce')
            elseif btn.name == "Facture" then
                facturetaxi()
            end

            if btn.name == "Taxi ~b~ouvert" then
                local etat = "ouvert"
                TriggerServerEvent('Tikoz:taxiAnnonce', etat)
            elseif btn.name == "Taxi ~b~fermer" then
                local etat = "fermer"
                TriggerServerEvent('Tikoz:taxiAnnonce', etat)
            elseif btn.name == "Taxi ~b~personnaliser" then
                local etat = "perso"
                local msgpersoburger = Keyboardput("Quel est votre message ? ", "", 150)
                TriggerServerEvent('Tikoz:taxiAnnonce', etat, msgpersoburger)
            end

            if ESX.PlayerData.job.grade_name == "boss" and ESX.PlayerData.job.name == "taxi" then 
                if btn.name == "Gestion d'entreprise" then
                    menutaxi.Menu["Gestion"].b = {}
                    table.insert(menutaxi.Menu["Gestion"].b, { name = "Recruter", ask = "", askX = true})   
                    table.insert(menutaxi.Menu["Gestion"].b, { name = "Promouvoir", ask = "", askX = true})
                    table.insert(menutaxi.Menu["Gestion"].b, { name = "Destituer" , ask = "", askX = true})
                    table.insert(menutaxi.Menu["Gestion"].b, { name = "Virer", ask = "", askX = true})
                    OpenMenu('Gestion')
                end
            end
            if btn.name == "Recruter" then 
                if ESX.PlayerData.job.grade_name == 'boss'  then
                    Tikozaal.closestPlayer, Tikozaal.closestDistance = ESX.Game.GetClosestPlayer()
                    if Tikozaal.closestPlayer == -1 or Tikozaal.closestDistance > 3.0 then
                        ESX.ShowNotification('Aucun joueur à ~b~proximité')
                    else
                        TriggerServerEvent('Tikoz:taxiRecruter', GetPlayerServerId(Tikozaal.closestPlayer), ESX.PlayerData.job.name, 0)
                    end
                else
                    ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                end
            elseif btn.name == "Promouvoir" then
                if ESX.PlayerData.job.grade_name == 'boss' then
                    Tikozaal.closestPlayer, Tikozaal.closestDistance = ESX.Game.GetClosestPlayer()
                    if Tikozaal.closestPlayer == -1 or Tikozaal.closestDistance > 3.0 then
                        ESX.ShowNotification('Aucun joueur à ~b~proximité')
                    else
                        TriggerServerEvent('Tikoz:Promotiontaxi', GetPlayerServerId(Tikozaal.closestPlayer))
                    end
                else
                    ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                end
            elseif btn.name == "Virer" then 
                if ESX.PlayerData.job.grade_name == 'boss' then
                    Tikozaal.closestPlayer, Tikozaal.closestDistance = ESX.Game.GetClosestPlayer()
                    if Tikozaal.closestPlayer == -1 or Tikozaal.closestDistance > 3.0 then
                        ESX.ShowNotification('Aucun joueur à ~b~proximité')
                    else
                        TriggerServerEvent('Tikoz:taxiVirer', GetPlayerServerId(Tikozaal.closestPlayer))
                    end
                else
                    ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                end
            elseif btn.name == "Destituer" then 
                if ESX.PlayerData.job.grade_name == 'boss' then
                    Tikozaal.closestPlayer, Tikozaal.closestDistance = ESX.Game.GetClosestPlayer()
                    if Tikozaal.closestPlayer == -1 or Tikozaal.closestDistance > 3.0 then
                        ESX.ShowNotification('Aucun joueur à ~b~proximité')
                    else
                        TriggerServerEvent('Tikoz:taxiRetrograder', GetPlayerServerId(Tikozaal.closestPlayer))
                    end
                else
                    ESX.ShowNotification('Vous n\'avez pas les ~r~droits~w~')
                end
            end

            ESX.TriggerServerCallback("Tikoz:GetCallTaxi", function(calltaxi) 

                if btn.name == "Appel des clients" then
                    menutaxi.Menu["Appel des clients"].b = {}
                    for i=1, #calltaxi, 1 do 
                        table.insert(menutaxi.Menu["Appel des clients"].b, {name = calltaxi[i].prenom.." I "..calltaxi[i].nom, ask = "~b~"..calltaxi[i].num, askX = true})
                    end
                    OpenMenu("Appel des clients")
                end

                for i=1, #calltaxi, 1 do 
                    if btn.name == calltaxi[i].prenom.." I "..calltaxi[i].nom then
                        menutaxi.Menu["Détail de la course"].b = {}
                        idclient = calltaxi[i].idclient
                        idcourse = calltaxi[i].id 
                        nom = calltaxi[i].nom
                        prenom = calltaxi[i].prenom
                        poscourse = calltaxi[i].pos
                        table.insert(menutaxi.Menu['Détail de la course'].b, {name = "Nom : ", ask = "~b~"..calltaxi[i].nom, askX = true})
                        table.insert(menutaxi.Menu['Détail de la course'].b, {name = "Prénom : ", ask = "~b~"..calltaxi[i].prenom, askX = true})
                        table.insert(menutaxi.Menu['Détail de la course'].b, {name = "Numéro : ", ask = "~b~"..calltaxi[i].num, askX = true})
                        table.insert(menutaxi.Menu['Détail de la course'].b, {name = "~g~Accepter", ask = "", askX = true})
                        table.insert(menutaxi.Menu['Détail de la course'].b, {name = "~r~Supprimé la course", ask = "", askX = true})
                        OpenMenu("Détail de la course")
                    end
                end

                if btn.name == "~g~Accepter" then
                    CloseMenu()
                    SetNewWaypoint(poscourse.x, poscourse.y)
                    nametaxi = GetPlayerName(PlayerId())
                    TriggerServerEvent('Tikoz/Takecourse', nametaxi, nom, prenom, idclient)
                elseif btn.name == "~r~Supprimé la course" then
                    CloseMenu()
                    TriggerServerEvent('Tikoz/delcourse', idcourse)
                end

            end, args)
            
        end,
},
    Menu = {
        ["Menu :"] = {
            b = {
                {name = "Appel des clients", ask = ">", askX = true},
                {name = "Annonce", ask = ">", askX = true},
                {name = "Facture", ask = ">", askX = true},
                {name = "Gestion d'entreprise", ask = ">", askX = true},

            }
        },
        ["Annonce"] = {
            b = {
                {name = "Taxi ~b~ouvert", ask = "", askX = true},
                {name = "Taxi ~b~fermer", ask = "", askX = true},
                {name = "Taxi ~b~personnaliser", ask = "", askX = true},
            }
        },
        ["Gestion"] = {
            b = {
            }
        },
        ["Appel des clients"] = {
            b = {
            }
        },
        ["Détail de la course"] = {
            b = {
            }
        },
    }
}

keyRegister("opentaxi", "Menu F6", "F6", function()
    if ESX.PlayerData.job.name == "taxi" then
        CreateMenu(menutaxi)
    end
end)

CreateThread(function()
    if Config.Blip.UseBlip == true then
        local blip = AddBlipForCoord(Config.Blip.Pos)
        SetBlipSprite (blip, Config.Blip.Id)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.Blip.Taille)
        SetBlipColour (blip, Config.Blip.Couleur)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Blip.Nom)
        EndTextCommandSetBlipName(blip)
    end
end)