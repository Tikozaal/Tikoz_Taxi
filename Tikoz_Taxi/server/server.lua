ESX = exports["es_extended"]:getSharedObject()

TriggerEvent('esx_society:registerSociety', 'taxi', 'taxi', 'society_taxi', 'society_taxi', 'society_taxi', {type = 'public'})

RegisterServerEvent('Tikoz:taxiAnnonce')
AddEventHandler('Tikoz:taxiAnnonce', function(etat, msgpersotaxi)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

		if etat == "ouvert" then
			TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], "Taxi", '~b~Annonce', 'Nous sommes ~g~ouvert~s~ !', 'CHAR_TAXI', 8)
		elseif etat == "fermer" then
			TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], "Taxi", '~b~Annonce', 'Nous sommes ~r~fermer~s~ !', 'CHAR_TAXI', 8)
		elseif etat == "perso" then
			TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], "Taxi", '~b~Annonce', msgpersotaxi, 'CHAR_TAXI', 8)
		end
	end
end)

ESX.RegisterServerCallback('Tikoz:taxiSalaire', function(source, cb)

    local xPlayer = ESX.GetPlayerFromId(source)
    local salairetaxi = {}

    MySQL.Async.fetchAll('SELECT * FROM job_grades', {

    }, function(result)

        for i=1, #result, 1 do

            table.insert(salairetaxi, {
				id = result[i].id,
                job_name = result[i].job_name,
                label = result[i].label,
                salary = result[i].salary,
            })
        end
        cb(salairetaxi)
    end)
end)

RegisterServerEvent("Tikoz:taxiNouveauSalaire")
AddEventHandler("Tikoz:taxiNouveauSalaire", function(id, label, amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    MySQL.Async.fetchAll("UPDATE job_grades SET salary = "..amount.." WHERE id = "..id,
	{
		['@id'] = id,
		['@salary'] = amount
	}, function (rowsChanged)
	end)
end)


ESX.RegisterServerCallback('Tikoz:getSocietyMoney', function(source, cb, societyName)
	if societyName ~= nil then
	  local society = "society_taxi"
	  TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
		cb(account.money)
	  end)
	else
	  cb(0)
	end
end)

ESX.RegisterServerCallback('Tikoz:taxiArgentEntreprise', function(source, cb)

    local xPlayer = ESX.GetPlayerFromId(source)
    local compteentreprise = {}


    MySQL.Async.fetchAll('SELECT * FROM addon_account_data WHERE account_name = "society_taxi"', {

    }, function(result)

        for i=1, #result, 1 do
            table.insert(compteentreprise, {
                account_name = result[i].account_name,
                money = result[i].money,
            })
        end
        cb(compteentreprise)
    end)
end)

RegisterServerEvent("Tikoz:taxidepotentreprise")
AddEventHandler("Tikoz:taxidepotentreprise", function(money)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local total = money
    local xMoney = xPlayer.getMoney()
    
    TriggerEvent('esx_addonaccount:getSharedAccount', "society_taxi", function (account)
        if xMoney >= total then
            account.addMoney(total)
            xPlayer.removeAccountMoney('bank', total)
            TriggerClientEvent('esx:showAdvancedNotification', source, 'Banque Société', "~b~taxi", "Vous avez déposé ~g~"..total.." $~s~ dans votre ~b~entreprise", 'CHAR_BANK_FLEECA', 9)
        else
            TriggerClientEvent('esx:showNotification', source, "<C>~r~Vous n'avez pas assez d'argent !")
        end
    end)   
end)

RegisterServerEvent("Tikoz:taxiRetraitEntreprise")
AddEventHandler("Tikoz:taxiRetraitEntreprise", function(money)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local total = money
	local xMoney = xPlayer.getAccount("bank").money
	
	TriggerEvent('esx_addonaccount:getSharedAccount', "society_taxi", function (account)
		if account.money >= total then
			account.removeMoney(total)
			xPlayer.addAccountMoney('bank', total)
			TriggerClientEvent('esx:showAdvancedNotification', source, 'Banque Société', "~b~taxi", "Vous avez retiré ~g~"..total.." $~s~ de votre ~b~entreprise", 'CHAR_BANK_FLEECA', 9)
		else
			TriggerClientEvent('esx:showAdvancedNotification', source, 'Banque Société', "~b~taxi", "Vous avez pas assez d'argent dans votre ~b~entreprise", 'CHAR_BANK_FLEECA', 9)
		end
	end)
end) 


ESX.RegisterServerCallback('Tikoz:taxiCoffrerecupweapon', function(source, cb)

    local xPlayer = ESX.GetPlayerFromId(source)
    local coffreweapon = {}

    MySQL.Async.fetchAll('SELECT * FROM tikoz_stockweapon', {

    }, function(result)

        for i=1, #result, 1 do
            table.insert(coffreweapon, {
                id = result[i].id,
				name = result[i].name,
				label = result[i].label,
                balle = result[i].balle,
                job = result[i].job,
				gang = result[i].gang,
            })
        end
        cb(coffreweapon)
    end)
end)

RegisterServerEvent("Tikoz:taxiDeposeWeapon")
AddEventHandler("Tikoz:taxiDeposeWeapon", function(name, label, balle, job)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.removeWeapon(name, balle)

	MySQL.Async.execute("INSERT INTO tikoz_stockweapon (name, label, balle, job, gang) VALUES (@name, @label, @balle, @job, @gang)",
	{['@name'] = name, ['@label'] = label, ["@balle"] = balle, ["@job"] = job, ["@gang"] = "null"})

end)

RegisterServerEvent("Tikoz:taxiCoffreRetirerWeapon")
AddEventHandler("Tikoz:taxiCoffreRetirerWeapon", function(id, name, label, balle, job)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.addWeapon(name, balle)

	MySQL.Async.execute('DELETE FROM tikoz_stockweapon WHERE id = '..id, {
        ["@id"] = id
    }, function()
    end)
end)

ESX.RegisterServerCallback('Tikoz:Inventairetaxi', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory

	cb({items = items})
end)

RegisterServerEvent("Tikoz:CoffreDeposetaxi")
AddEventHandler("Tikoz:CoffreDeposetaxi", function(itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_taxi', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showNotification', _source, "Vous avez déposé ~y~x"..count.." ~b~"..inventoryItem.label)
		else
			TriggerClientEvent('esx:showNotification', _source, "quantité invalide")
		end
	end)
end)

ESX.RegisterServerCallback('Tikoz:CoffreSocietytaxi', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_taxi', function(inventory)
		cb(inventory.items)
	end)
end)

RegisterNetEvent('Tikoz:RetireCoffretaxi')
AddEventHandler('Tikoz:RetireCoffretaxi', function(itemName, count, itemLabel)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_taxi', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		if count > 0 and inventoryItem.count >= count then
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('esx:showNotification', _source, "Vous avez retiré ~y~x"..count.." ~b~"..itemLabel)
		else
			TriggerClientEvent('esx:showNotification', _source, "Quantité invalide")
		end
	end)
end)

RegisterServerEvent('Tikoz:taxiRecruter')
AddEventHandler('Tikoz:taxiRecruter', function(target, job, grade)
	local _source = source
	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	targetXPlayer.setJob(job, grade)
	TriggerClientEvent('esx:showNotification', _source, "Vous avez ~g~recruté " .. targetXPlayer.name .. "~w~.")
	TriggerClientEvent('esx:showNotification', target, "Vous avez été ~g~embauché par " .. sourceXPlayer.name .. "~w~.")
end)

RegisterServerEvent('Tikoz:Promotiontaxi')
AddEventHandler('Tikoz:Promotiontaxi', function(target)
	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if (targetXPlayer.job.grade == 3) then
		TriggerClientEvent('esx:showNotification', _source, "Vous ne pouvez pas plus ~b~promouvoir~w~ d'avantage.")
	else
		if (sourceXPlayer.job.name == targetXPlayer.job.name) then
			local grade = tonumber(targetXPlayer.job.grade) + 1
			local job = targetXPlayer.job.name

			targetXPlayer.setJob(job, grade)

			TriggerClientEvent('esx:showNotification', _source, "Vous avez ~b~promu " .. targetXPlayer.name .. "~w~.")
			TriggerClientEvent('esx:showNotification', target, "Vous avez été ~b~promu~s~ par " .. sourceXPlayer.name .. "~w~.")
		end
	end
end)


RegisterServerEvent('Tikoz:taxiRetrograder')
AddEventHandler('Tikoz:taxiRetrograder', function(target)
	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if (targetXPlayer.job.grade == 0) then
		TriggerClientEvent('esx:showNotification', _source, "Vous ne pouvez pas plus ~r~rétrograder~w~ d'avantage.")
	else
		if (sourceXPlayer.job.name == targetXPlayer.job.name) then
			local grade = tonumber(targetXPlayer.job.grade) - 1
			local job = targetXPlayer.job.name

			targetXPlayer.setJob(job, grade)

			TriggerClientEvent('esx:showNotification', _source, "Vous avez ~r~rétrogradé " .. targetXPlayer.name .. "~w~.")
			TriggerClientEvent('esx:showNotification', target, "Vous avez été ~r~rétrogradé par " .. sourceXPlayer.name .. "~w~.")
		else
			TriggerClientEvent('esx:showNotification', _source, "Vous n'avez pas ~r~l'autorisation~w~.")
		end
	end
end)

RegisterServerEvent('Tikoz:taxiVirer')
AddEventHandler('Tikoz:taxiVirer', function(target)
	local _source = source
	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	local job = "unemployed"
	local grade = "0"
	if (sourceXPlayer.job.name == targetXPlayer.job.name) then
		targetXPlayer.setJob(job, grade)
		TriggerClientEvent('esx:showNotification', _source, "Vous avez ~r~viré " .. targetXPlayer.name .. "~w~.")
		TriggerClientEvent('esx:showNotification', target, "Vous avez été ~g~viré par " .. sourceXPlayer.name .. "~w~.")
	else
		TriggerClientEvent('esx:showNotification', _source, "Vous n'avez pas ~r~l'autorisation~w~.")
	end
end)

RegisterServerEvent("Tikoz/CallTaxi")
AddEventHandler("Tikoz/CallTaxi", function(idclient, nom, prenom, num, pos)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers = ESX.GetPlayers()

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == "taxi" then
			TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], "Taxi", "~b~Appel d'un client", 'Vous avez reçu une ~b~commande~s~ !', 'CHAR_TAXI', 8)
		end
	end
	MySQL.Async.execute("INSERT INTO tikoz_calltaxi (idclient, nom, prenom, num, pos) VALUES (@idclient, @nom, @prenom, @num, @pos)",
	{["@idclient"] = idclient, ['@nom'] = nom, ['@prenom'] = prenom, ["@num"] = num, ["@pos"] = pos})
end)

RegisterServerEvent("Tikoz/delcourse")
AddEventHandler("Tikoz/delcourse", function(id)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	MySQL.Async.execute('DELETE FROM tikoz_calltaxi WHERE id = ?', {
		id
    }, function()
    end) 
end)

RegisterServerEvent("Tikoz/Takecourse")
AddEventHandler("Tikoz/Takecourse", function(nametaxi, nom, prenom, idclient)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)  
	local xPlayers	= ESX.GetPlayers()
	TriggerClientEvent('esx:showAdvancedNotification', idclient, "Taxi", "~g~Course valider", "Un chauffeur a accepter votre course", 'CHAR_TAXI', 8)
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == "taxi" then
			TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], "Taxi", "~b~Information", "~y~"..nametaxi.."~s~ à accepter la course :\n\nClient : ~b~"..nom.." "..prenom, 'CHAR_TAXI', 8)
		end
	end
end)

ESX.RegisterServerCallback('Tikoz:GetCallTaxi', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local calltaxi = {}
    MySQL.Async.fetchAll('SELECT * FROM tikoz_calltaxi', {
    }, function(result)
        for i=1, #result, 1 do
            table.insert(calltaxi, {
				id = result[i].id,
				idclient = result[i].idclient,
                nom = result[i].nom,
                prenom = result[i].prenom,
				num = result[i].num,
                pos = json.decode(result[i].pos),
            })
        end
        cb(calltaxi)
    end)
end)

RegisterServerEvent('Tikoz/TaxiBuyMission')
AddEventHandler('Tikoz/TaxiBuyMission', function(paye, price, goclient, PayeEntreprise, Pourcentage)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local amount = price+goclient
	price = math.ceil(amount)

	payetaxerent = price*Pourcentage/100
	payetaxe = math.ceil(payetaxerent)
	TriggerEvent('esx_addonaccount:getSharedAccount', "society_taxi", function (account)
		if PayeEntreprise == true then
			if paye == "cash" then
				account.addMoney(payetaxe)
				xPlayer.addMoney(price)
				TriggerClientEvent('esx:showAdvancedNotification', _source, "Taxi", '~b~Mission terminer', ' Vous avez gagner : ~g~'..price.."$\n\n~s~L'entreprise a gagner : ~g~"..payetaxe.."$", 'CHAR_TAXI', 8)
			elseif paye == "bank" then
				account.addMoney(payetaxe)
				xPlayer.addAccountMoney('bank', price)
				TriggerClientEvent('esx:showAdvancedNotification', _source, "Taxi", '~b~Mission terminer', ' Vous avez gagner : ~y~'..price.."$\n\n~s~L'entreprise a gagner : ~g~"..payetaxe.."$", 'CHAR_TAXI', 8)
			elseif paye == "sale" then
				account.addMoney(payetaxe)
				xPlayer.addAccountMoney('black_money', price)
				TriggerClientEvent('esx:showAdvancedNotification', _source, "Taxi", '~b~Mission terminer', ' Vous avez gagner : ~r~'..price.."$\n\n~s~L'entreprise a gagner : ~g~"..payetaxe.."$", 'CHAR_TAXI', 8)
			end
		else
			if paye == "cash" then
				xPlayer.addMoney(price)
				TriggerClientEvent('esx:showAdvancedNotification', _source, "Taxi", '~b~Mission terminer', ' Vous avez gagner : ~g~'..price.."$", 'CHAR_TAXI', 8)
			elseif paye == "bank" then
				xPlayer.addAccountMoney('bank', price)
				TriggerClientEvent('esx:showAdvancedNotification', _source, "Taxi", '~b~Mission terminer', ' Vous avez gagner : ~y~'..price.."$", 'CHAR_TAXI', 8)
			elseif paye == "sale" then
				xPlayer.addAccountMoney('black_money', price)
				TriggerClientEvent('esx:showAdvancedNotification', _source, "Taxi", '~b~Mission terminer', ' Vous avez gagner : ~r~'..price.."$", 'CHAR_TAXI', 8)
			end
		end
	end)
end)