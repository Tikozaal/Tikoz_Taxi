ESX = exports["es_extended"]:getSharedObject()

CreateThread(function()
    if ESX.IsPlayerLoaded() then
		ESX.PlayerData = ESX.GetPlayerData()
    end
    ESX.PlayerData = ESX.GetPlayerData()
    WeaponData = ESX.GetWeaponList()
    for i = 1, #WeaponData, 1 do
        if WeaponData[i].name == 'WEAPON_UNARMED' then
            WeaponData[i] = nil
        else
            WeaponData[i].hash = GetHashKey(WeaponData[i].name)
        end
    end
end)

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

menucoffre = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {0, 251 ,255}, Title = "Coffre"},
    Data = { currentMenu = "Menu :"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)

            ESX.TriggerServerCallback("Tikoz:Inventairetaxi", function(inventory) 
                if btn.name == "Déposé" then
                    menucoffre.Menu["Déposé"].b = {}
                    for i=1, #inventory.items, 1 do 
                        local item = inventory.items[i]
                        if item.count > 0 then
                            table.insert(menucoffre.Menu["Déposé"].b, { name = "~s~"..item.label, ask = "~b~x"..item.count, askX = true})
                        end
                    end
                    OpenMenu("Déposé")
                end

                for i=1, #inventory.items, 1 do 
                    local item = inventory.items[i]
                    if btn.name == "~s~"..item.label then
                        count = Keyboardput("Combien voulez vous déposé ? ", "", 15)
                        TriggerServerEvent('Tikoz:CoffreDeposetaxi', item.name, tonumber(count))
                        OpenMenu("Menu :")
                    end
                end
            end)

            ESX.TriggerServerCallback("Tikoz:CoffreSocietytaxi", function(items)
                
               itemstock = {} 
               itemstock = items

               if btn.name == "Retiré" then
                    menucoffre.Menu["Retiré"].b = {}

                    for i=1, #itemstock, 1 do

                        if itemstock[i].count > 0 then
                            table.insert(menucoffre.Menu["Retiré"].b, { name = itemstock[i].label, ask = "~b~x"..itemstock[i].count, askX = true})
                        end
                    end
                    OpenMenu("Retiré")
                end

                for i=1, #itemstock, 1 do 
                
                    if btn.name == itemstock[i].label then
                    
                        itemLabel = itemstock[i].label
                        count = Keyboardput("Combien voulez vous déposé ? ", "", 15)
                        TriggerServerEvent('Tikoz:RetireCoffretaxi', itemstock[i].name, tonumber(count), itemLabel)
                        OpenMenu("Menu :")
                    end

                end

            end)

            if btn.name == "Déposé arme" then
                ESX.PlayerData = ESX.GetPlayerData()
                menucoffre.Menu["Déposé arme"].b = {}
                    if #WeaponData > 0 then
                        for i = 1, #WeaponData, 1 do
                            if (HasPedGotWeapon(PlayerPedId(), WeaponData[i].hash, false)) then
                                local currentAmmo = GetAmmoInPedWeapon(PlayerPedId(), WeaponData[i].hash)
                                table.insert(menucoffre.Menu["Déposé arme"].b, { name = WeaponData[i].label, ask = "~b~x"..currentAmmo, askX = true})
                            end
                        end
                    end
                OpenMenu('Déposé arme')
            end

           for i=1, #WeaponData, 1 do 
                if btn.name == WeaponData[i].label then
                    local name = WeaponData[i].name
                    local label = WeaponData[i].label
                    local balle = GetAmmoInPedWeapon(PlayerPedId(), WeaponData[i].hash)
                    local job = "taxi" 
                    TriggerServerEvent('Tikoz:taxiDeposeWeapon', name, label, balle, job)
                    OpenMenu('Menu :')
                end
            end

            ESX.TriggerServerCallback("Tikoz:taxiCoffrerecupweapon", function(coffreweapon) 
                
                if btn.name == "Retiré arme" then
                    menucoffre.Menu["Retiré arme"].b = {}
                    for i=1, #coffreweapon, 1 do 
                        if coffreweapon[i].job == "taxi" then
                            table.insert(menucoffre.Menu["Retiré arme"].b, { name = "~s~"..coffreweapon[i].label, ask = "~b~x"..coffreweapon[i].balle, askX = true})
                        end
                    end
                    OpenMenu("Retiré arme")
                end

                for i=1, #coffreweapon, 1 do
                    if btn.name == "~s~"..coffreweapon[i].label then
                        local id = coffreweapon[i].id
                        local name = coffreweapon[i].name
                        local label = coffreweapon[i].label
                        local balle = coffreweapon[i].balle
                        local job = coffreweapon[i].job
                        local gang = coffreweapon[i].gang
                        TriggerServerEvent('Tikoz:taxiCoffreRetirerWeapon', id, name, label, balle, job, gang)
                        OpenMenu("Menu :")
                    end
                end

            end)

        end,
},
    Menu = {
        ["Menu :"] = {
            b = {
                {name = "Déposé", ask = ">", askX = true},
                {name = "Retiré", ask = ">", askX = true},
                {name = "", ask = "", askX = true},
                {name = "Déposé arme", ask = ">", askX = true},
                {name = "Retiré arme", ask = ">", askX = true},
            }
        },
        ["Déposé"] = {
            b = {
            }
        },
        ["Retiré"] = {
            b = {
            }
        },
        ["Déposé arme"] = {
            b = {
            }
        },
        ["Retiré arme"] = {
            b = {
            }
        },
    }
}

CreateThread(function()

    while true do 
       
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local menu = Config.Pos.Coffre 
        local dist = #(pos - menu)

        if dist <= 2 and ESX.PlayerData.job.name == "taxi" then

            ESX.ShowHelpNotification("Appuie sur ~INPUT_CONTEXT~ pour ouvrir le ~b~menu")
            DrawMarker(6, menu, nil, nil, nil, -90, nil, nil, 0.7, 0.7, 0.7, 0, 251, 255, 200, false, true, 2, false, false, false, false)

            if IsControlJustPressed(1, 51) then
                CreateMenu(menucoffre)
            end

        else 
            Wait(1000)
        end
        Wait(0)
    end
end)