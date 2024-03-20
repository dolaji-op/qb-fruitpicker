QBCore = nil

if Config.Object.usingexport then
    QBCore = exports[Config.Object.CoreName]:GetCoreObject()
else
    TriggerEvent(Config.Object.event, function(obj) QBCore = obj end)
end

Peddata = {}

local Createfruits = {}
local basket = nil
local currentbasket = nil
local JobData = nil
local JobDataTime = {}
local basketdropped = false
local drawtextData = {}


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local pedcoo = GetEntityCoords(GetPlayerPed(-1))
        if #(pedcoo - Config.Blip['selling'].coords) < 100.0 then
			if Peddata[1] ~= nil then
				if not DoesEntityExist(Peddata[1]) then
					RequestModel(GetHashKey(Config.PedModel))
					while not HasModelLoaded(GetHashKey(Config.PedModel)) do
						RequestModel(GetHashKey(Config.PedModel))
						Wait(100)
					end
					Peddata[1] = CreatePed(4, GetHashKey(Config.PedModel), Config.Blip['selling'].coords,Config.Blip['selling'].heading, false, false)
					createdPed = Peddata[1]
					ClearPedTasks(createdPed)
					ClearPedSecondaryTask(createdPed)
					TaskSetBlockingOfNonTemporaryEvents(createdPed, true)
					SetPedFleeAttributes(createdPed, 0, 0)
					SetPedCombatAttributes(createdPed, 17, 1)
					SetPedSeeingRange(createdPed, 0.0)
					SetPedHearingRange(createdPed, 0.0)
					SetPedAlertness(createdPed, 0)
					SetPedKeepTask(createdPed, true)
					Wait(1000)
					FreezeEntityPosition(createdPed, true)
					SetEntityInvincible(createdPed, true)

				else
					local ccd = GetEntityCoords(Peddata[1])
					if #(ccd - Config.Blip['selling'].coords) > 5 then
						DeleteEntity(Peddata[1])
						RequestModel(GetHashKey(Config.PedModel))
						while not HasModelLoaded(GetHashKey(Config.PedModel)) do
							RequestModel(GetHashKey(Config.PedModel))
							Wait(100)
						end
						Peddata[1] = CreatePed(4, GetHashKey(Config.PedModel), Config.Blip['selling'].coords,Config.Blip['selling'].heading, false, false)
						createdPed = Peddata[1]
						ClearPedTasks(createdPed)
						ClearPedSecondaryTask(createdPed)
						TaskSetBlockingOfNonTemporaryEvents(createdPed, true)
						SetPedFleeAttributes(createdPed, 0, 0)
						SetPedCombatAttributes(createdPed, 17, 1)
						SetPedSeeingRange(createdPed, 0.0)
						SetPedHearingRange(createdPed, 0.0)
						SetPedAlertness(createdPed, 0)
						SetPedKeepTask(createdPed, true)
						Wait(1000)
						FreezeEntityPosition(createdPed, true)
						SetEntityInvincible(createdPed, true)

					end
				end
			else
				RequestModel(GetHashKey(Config.PedModel))
				while not HasModelLoaded(GetHashKey(Config.PedModel)) do
					RequestModel(GetHashKey(Config.PedModel))
					Wait(100)
				end
				Peddata[1] = CreatePed(4, GetHashKey(Config.PedModel), Config.Blip['selling'].coords, Config.Blip['selling'].heading, false, false)
				createdPed = Peddata[1]
				ClearPedTasks(createdPed)
				ClearPedSecondaryTask(createdPed)
				TaskSetBlockingOfNonTemporaryEvents(createdPed, true)
				SetPedFleeAttributes(createdPed, 0, 0)
				SetPedCombatAttributes(createdPed, 17, 1)
				SetPedSeeingRange(createdPed, 0.0)
				SetPedHearingRange(createdPed, 0.0)
				SetPedAlertness(createdPed, 0)
				SetPedKeepTask(createdPed, true)
				Wait(1000)
				FreezeEntityPosition(createdPed, true)
				SetEntityInvincible(createdPed, true)

			end
		end
    end
end)


RegisterNetEvent("ds-fruitpicker:buystuff")
AddEventHandler("ds-fruitpicker:buystuff", function()
	if not CheckJob() then
		QBCore.Functions.Notify(Language['no_job'], "error")
		return
	end
    local ShopItems = {}
    ShopItems.label = Language['shop']
    ShopItems.items = Config.ShopItems
    ShopItems.slots = #Config.ShopItems
    TriggerServerEvent("inventory:server:OpenInventory", "shop", "FruitMarket_"..math.random(1, 99), ShopItems)
end)


Citizen.CreateThread(function()
	if Config.UseDrawText and CheckJob() then
		while true do
			Wait(3)
			local pedpos = GetEntityCoords(PlayerPedId())
			if #drawtextData > 0 then
				for k,v in pairs(drawtextData) do
					if #(pedpos - v.coords) < 2.0 and CheckJob() then
						DrawText3Ds(v.coords.x, v.coords.y, v.coords.z, '~g~[E] ~w~'..Language['pluck_orange'])
						if IsControlJustReleased(0, 38) then
							TriggerEvent('ds-fruitpicker:stealorange', v)
							Wait(1000)
						end
					end
				end
			end
			if basketdropped and currentbasket ~= nil and currentbasket.info.qty > 0 then
				local fruitbas = GetClosestObjectOfType(pedpos.x, pedpos.y, pedpos.z, 2.0, GetHashKey('prop_fruit_basket'), 0,0,0)
				if fruitbas and basket == fruitbas then
					local fpos = GetEntityCoords(fruitbas)
					if #(pedpos - fpos) < 2.0 then
						DrawText3Ds(fpos.x, fpos.y, fpos.z, '~g~[E] ~w~'..Language['pickup_fruit'])
						if IsControlJustReleased(0, 38) then
							TriggerEvent('ds-fruitpicker:pickupfruit')
						end
					end
				end
			end
		end
	end
end)

Citizen.CreateThread(function()

	for wtf, info in pairs(Config.Blip) do
		if info.enable then
			info.blip = AddBlipForCoord(info.coords.x, info.coords.y, info.coords.z)
			SetBlipSprite(info.blip, info.Sprite)
			SetBlipDisplay(info.blip, 4)
			SetBlipScale(info.blip, info.Scale)
			SetBlipColour(info.blip, info.Color)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(info.Label)
			EndTextCommandSetBlipName(info.blip)
		end
	end

	if Config.UseDrawText then
		while true do
			Wait(3)
			local pedpos = GetEntityCoords(PlayerPedId())
			if #(pedpos - Config.Blip['selling'].coords) < 2.0 and CheckJob() then
				DrawText3Ds(Config.Blip['selling'].coords.x, Config.Blip['selling'].coords.y, Config.Blip['selling'].coords.z, '~g~[E] ~w~'..Language['buy_stuff'])
				DrawText3Ds(Config.Blip['selling'].coords.x, Config.Blip['selling'].coords.y, Config.Blip['selling'].coords.z-0.2, '~g~[G] ~w~'..Language['sell_fruit'])
				if IsControlJustReleased(0, 38) then
					TriggerEvent('ds-fruitpicker:buystuff')
				elseif IsControlJustReleased(0, 47) then
					TriggerEvent('ds-fruitpicker:sellorange')
				end
			else
				Wait(1000)
			end
		end
	end
end)


function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end


function CheckJob()
	local check = false
	if Config.RequireJob then
		if PlayerJob ~= nil and PlayerJob.name == Config.JobName then
			check = true
		end
	else
		check = true
	end
	return check
end

RegisterCommand('fpk', function()
	QBCore.Functions.TriggerCallback('ds-fruitpicker:server:getdata', function(data)
		JobData = data
	end)
	if not Config.UseDrawText then
		AddTargets('orange')
		AddTargets('store',  Config.Blip['selling'])
	end

	if Config.UseXp then
		local PlayerData = QBCore.Functions.GetPlayerData()
		local jobnrep = PlayerData.metadata["jobrep"]
		local taskadded = 0
		if jobnrep['fruitpeeker'] ~= nil then
			for k,v in pairs(Config.Xp) do
				if jobnrep['fruitpeeker'] <= v.xp then
					for a,b in pairs(Config.Orange) do
						if taskadded < v.enabletree then
							local data = {
								coords = b,
								name = 'orange'..a
							}
							if Config.UseDrawText then
								drawtextData[a] = data
							else
								AddTargets('fruittree', data)
							end
							taskadded = taskadded + 1
						end
					end
				end
				break
			end
		else
			for a,b in pairs(Config.Orange) do
				if taskadded < 10 then
					local data = {
						coords = b,
						name = 'orange'..a
					}
					if Config.UseDrawText then
						drawtextData[a] = data
					else
						AddTargets('fruittree', data)
					end
					taskadded = taskadded + 1
				end
			end
		end
	else
		for k,v in pairs(Config.Orange) do
			local data = {
				coords = v,
				name = 'orange'..k
			}
			if Config.UseDrawText then
				drawtextData[k] = data
			else
				AddTargets('fruittree', data)
			end
		end
	end
end)


RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
	QBCore.Functions.TriggerCallback('ds-fruitpicker:server:getdata', function(data)
		JobData = data
	end)
	if not Config.UseDrawText then
		AddTargets('orange')
		AddTargets('store',  Config.Blip['selling'])
	end

	if Config.UseXp then
		local PlayerData = QBCore.Functions.GetPlayerData()
		local jobnrep = PlayerData.metadata["jobrep"]
		local taskadded = 0
		if jobnrep['fruitpeeker'] ~= nil then
			for k,v in pairs(Config.Xp) do
				if jobnrep['fruitpeeker'] <= v.xp then
					for a,b in pairs(Config.Orange) do
						if taskadded < v.enabletree then
							local data = {
								coords = b,
								name = 'orange'..a
							}
							if Config.UseDrawText then
								drawtextData[a] = data
							else
								AddTargets('fruittree', data)
							end
							taskadded = taskadded + 1
						end
					end
				end
				break
			end
		else
			for a,b in pairs(Config.Orange) do
				if taskadded < 10 then
					local data = {
						coords = b,
						name = 'orange'..a
					}
					if Config.UseDrawText then
						drawtextData[a] = data
					else
						AddTargets('fruittree', data)
					end
					taskadded = taskadded + 1
				end
			end
		end
	else
		for k,v in pairs(Config.Orange) do
			local data = {
				coords = v,
				name = 'orange'..k
			}
			if Config.UseDrawText then
				drawtextData[k] = data
			else
				AddTargets('fruittree', data)
			end
		end
	end
end)


function GetID(num)
    if num == math.floor(num) then
        return math.floor(num / (10 ^ (math.floor(math.log10(num)) - 3)))
    else
        local wholePart = math.floor(num)
        local digitsInWhole = wholePart > 0 and math.floor(math.log10(wholePart)) + 1 or 1
        if digitsInWhole >= 3 then
            return math.floor(num * 10) / 10
        else
            local factor = 10 ^ (4 - digitsInWhole)
            return math.floor(num * factor) / factor
        end
    end
end




RegisterNetEvent('ds-fruitpicker:stealorange')
AddEventHandler('ds-fruitpicker:stealorange', function(data)
	if CheckJob() then
		if currentbasket ~= nil and basket ~= nil then
			if not JobData[GetID(data.coords.x)] then
				TriggerServerEvent('ds-fruitpicker:addorg', GetID(data.coords.x))
				local ped = PlayerPedId()
				local treecoords = data.coords
				TaskTurnPedToFaceCoord(ped, treecoords.x,treecoords.y,treecoords.z,1000)
				Wait(1000)
				loadAnimDict('pickup_object')
				TaskPlayAnim(GetPlayerPed(-1), "pickup_object", "pickup_low", 4.0, 4.0, -1, 16, 0, false, false, false)
				Wait(1000)
				DetachEntity(basket)
				ClearPedTasks(GetPlayerPed(-1))
				QBCore.Functions.Progressbar("open_locker_qbll", Language['pick_prog'], 5500, false, true, {
					disableMovement = true,
					disableCarMovement = true,
					disableMouse = false,
					disableCombat = true,
				}, {
					animDict = 'amb@prop_human_movie_bulb@idle_a',
					anim = 'idle_a',
					flags = 2,
				}, {}, {}, function() -- Done
					ClearPedTasks(GetPlayerPed(-1))
					loadAnimDict('pickup_object')
					TaskPlayAnim(GetPlayerPed(-1), "pickup_object", "pickup_low", 4.0, 4.0, -1, 16, 0, false, false, false)
					Wait(1000)
					ClearPedTasks(GetPlayerPed(-1))
					AttachBasket(ped)
					QBCore.Functions.Notify(Language['pickup_success'], "success")
					Addbasketfruit(currentbasket.info.qty + 1, GetID(data.coords.x))
				end, function() -- Cancel
					ClearPedTasks(GetPlayerPed(-1))
					loadAnimDict('pickup_object')
					TaskPlayAnim(GetPlayerPed(-1), "pickup_object", "pickup_low", 4.0, 4.0, -1, 16, 0, false, false, false)
					Wait(1000)
					ClearPedTasks(GetPlayerPed(-1))
					AttachBasket(ped)
					QBCore.Functions.Notify("Canceled..", "error")
					TriggerServerEvent('ds-fruitpicker:removeorg', GetID(data.coords.x))
				end)
			else
				QBCore.Functions.Notify(Language['no_more'], "error")
			end
		else
			QBCore.Functions.Notify(Language['no_basket'], "error")
		end
	else
		QBCore.Functions.Notify(Language['no_job'], "error")
	end
end)


function AttachBasket(ped)
    AttachEntityToEntity(basket, ped, GetPedBoneIndex(ped, 28422), 0.22+0.05, -0.3+0.22, 0.0+0.16, 160.0, 90.0, 125.0, true, true, false, true, 1, true)
end


RegisterNetEvent('dropbasket')
AddEventHandler('dropbasket', function()
    if currentbasket ~= nil and basket ~= nil then
        if basketdropped then
            local ped = PlayerPedId()
            AttachBasket(ped)
            basketdropped = false
        else
            DetachEntity(basket)
            basketdropped = true
        end
    end
end)


RegisterNetEvent('ds-fruitpicker:sellorange')
AddEventHandler('ds-fruitpicker:sellorange', function()
	if CheckJob() then
		if currentbasket ~= nil and basket ~= nil then
			TriggerEvent('db-fruit:selloption')
		else
			QBCore.Functions.Notify(Language['no_basket'], "error")
		end
	else
		QBCore.Functions.Notify(Language['no_job'], "error")
	end
end)


RegisterNetEvent('db-fruit:selloption')
AddEventHandler('db-fruit:selloption', function(data)
    local number = InsertValue(Language['sell_header'], Language['amount'], 5)
    number = tonumber(number)
    if number ~= nil and number > 0 then
        if currentbasket ~= nil and basket ~= nil then
            if currentbasket.info.qty >= number then
                currentbasket.info.qty = currentbasket.info.qty - number
                TriggerServerEvent('ds-fruitpicker:savebasket', currentbasket)
                for i = 1, number do
                    DetachEntity(Createfruits[#Createfruits])
                    DeleteEntity(Createfruits[#Createfruits])
                    table.remove(Createfruits, #Createfruits)
                end
                TriggerServerEvent("ds-fruitpicker:selloranges", number)
            else
                QBCore.Functions.Notify(Language['no_fruit'], "error")
            end
        end
    end
end)


RegisterNetEvent('ds-fruitpicker:pickupfruit')
AddEventHandler('ds-fruitpicker:pickupfruit', function()
    local ped = PlayerPedId()
    if currentbasket ~= nil and basket ~= nil then
        TaskTurnPedToFaceEntity(ped, basket,1000)
        Wait(1000)
        local number = InsertValue(Language['pickup_fruit'], Language['amount'], 5)
        number = tonumber(number)
        if number ~= nil and number > 0 then
            loadAnimDict('pickup_object')
            TaskPlayAnim(GetPlayerPed(-1), "pickup_object", "pickup_low", 4.0, 4.0, -1, 16, 0, false, false, false)
            Removebasketfruit(tonumber(number))
        end
    else
        QBCore.Functions.Notify(Language['not_own'], "error")
    end
end)




RegisterNetEvent('ds-fruitpicker:eatfruit')
AddEventHandler('ds-fruitpicker:eatfruit', function()
    local ped = PlayerPedId()
    attachModel = GetHashKey('orange')
    boneNumber = 28422
    local bone = GetPedBoneIndex(PlayerPedId(), 28422)
    RequestModel(attachModel)
    while not HasModelLoaded(attachModel) do
        Citizen.Wait(100)
    end
    attachedProp = CreateObject(attachModel, 1.0, 1.0, 1.0, 1, 1, 0)
    AttachEntityToEntity(attachedProp, PlayerPedId(), bone, 0.05, 0.0, -0.03, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
    SetModelAsNoLongerNeeded(attachModel)
    loadAnimDict('mp_missheist_countrybank@nervous')

    TaskPlayAnim(ped, "mp_missheist_countrybank@nervous", "nervous_idle", 8.0, 1.0, -1, 16, 0, 0, 0, 0 )
    Citizen.Wait(100)
    AttachEntityToEntity(attachedProp, ped, GetPedBoneIndex(ped, 18905), 0.12, 0.05, 0.04, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
    Citizen.Wait(1000)
    loadAnimDict('mp_player_inteat@burger')
    TaskPlayAnim(ped, "mp_player_inteat@burger", "mp_player_int_eat_burger", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
    Citizen.Wait(5000)
    TriggerServerEvent("QBCore:Server:SetMetaData", "hunger", QBCore.Functions.GetPlayerData().metadata["hunger"] + math.random(5, 10))
    ClearPedTasks(ped)
    DetachEntity(attachedProp, true, true)
    DeleteObject(attachedProp)
end)

exports("Checkbasket", function()
	if basket ~= nil then
		if basketdropped then
            return 'pickup'
        else
            return 'drop'
        end
	else
		return false
	end
end)


RegisterNetEvent('ds-fruitpicker:usebasket')
AddEventHandler('ds-fruitpicker:usebasket', function(item)
    if basket == nil then
        local qty = item.info.qty
        if qty == nil then
            item.info['qty'] = 0
            qty = 0
        end
        currentbasket = item
        Setupbasketfruits(qty, item)
    else
        for k,v in pairs(Createfruits) do
            DetachEntity(v)
            DeleteEntity(v)
        end
        DetachEntity(basket)
        DeleteEntity(basket)
        basket = nil
        Createfruits = {}
        currentbasket = nil
    end
end)


RegisterNetEvent('ds-fruitpicker:removebasket')
AddEventHandler('ds-fruitpicker:removebasket', function()
    if basket ~= nil then
        for k,v in pairs(Createfruits) do
            DetachEntity(v)
            DeleteEntity(v)
        end
        DetachEntity(basket)
        DeleteEntity(basket)
        basket = nil
        Createfruits = {}
        currentbasket = nil
    end
end)

RegisterNetEvent('ds-fruitpicker:updatedata')
AddEventHandler('ds-fruitpicker:updatedata', function(data)
    JobData = data
end)

CreateThread(function()
	while true do
		Wait(5000)
		if Config.UseTimeout then
			if JobData ~= nil then
				for k,v in pairs(JobData) do
					if v then
						if JobDataTime[k] then
							JobDataTime[k] = JobDataTime[k] + 5000
							if JobDataTime[k] >= Config.Timeout then
								TriggerServerEvent('ds-fruitpicker:removeorg', k)
								JobDataTime[k] = 0
							end
						else
							JobDataTime[k] = 5000
						end
					end
				end
			end
		end
	end
end)

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(0)
    end
end

function LoadModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(1)
    end
end

function Setupbasketfruits(qty)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    if basket == nil then
        basket = CreateObject(GetHashKey('prop_fruit_basket'), pos.x, pos.y, pos.z,  true,  true, true)
        AttachBasket(ped)
    end
    if qty ~= 0 then
        local model = GetHashKey("orange")
        LoadModel(model)
        for i = 1, qty do
            if not Createfruits[i] then
                local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(basket, 0.0-1.0, 0.0, 0.0))
                local fruit = CreateObject(model, x,y,z, true, false, true)
                AttachEntityToEntity(fruit, basket, -1, Config.FruitLoc[i].x,Config.FruitLoc[i].y,Config.FruitLoc[i].z, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                Createfruits[i] = fruit
            end
        end
    end
end

function Addbasketfruit(qty, id)
    if currentbasket ~= nil and basket ~= nil then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        if qty <= #Config.FruitLoc then
            if qty ~= 0 then
                local model = GetHashKey("orange")
                LoadModel(model)
                for i = 1, qty do
                    if not Createfruits[i] then
                        local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(basket, 0.0-1.0, 0.0, 0.0))
                        local fruit = CreateObject(model, x,y,z, true, false, true)
                        AttachEntityToEntity(fruit, basket, -1, Config.FruitLoc[i].x,Config.FruitLoc[i].y,Config.FruitLoc[i].z, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                        Createfruits[i] = fruit
                        currentbasket.info.qty = currentbasket.info.qty + 1
                        TriggerServerEvent('ds-fruitpicker:savebasket', currentbasket, id)
                    end
                end
            end
        else
            QBCore.Functions.Notify(Language['basket_full'], "error")
        end
    else
        QBCore.Functions.Notify(Language['no_basket'], "error")
    end
end

function Removebasketfruit(qty)
    if currentbasket ~= nil and basket ~= nil then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        if currentbasket.info.qty >= qty then
            currentbasket.info.qty = currentbasket.info.qty - qty
            TriggerServerEvent('ds-fruitpicker:savebasket', currentbasket)
            for i = 1, qty do
                DetachEntity(Createfruits[#Createfruits])
                DeleteEntity(Createfruits[#Createfruits])
                table.remove(Createfruits, #Createfruits)
            end
            TriggerServerEvent("ds-fruitpicker:getoranges", qty)
        else
            QBCore.Functions.Notify(Language['no_fruit'], "error")
        end
    else
        QBCore.Functions.Notify(Language['no_basket'], "error")
    end
end
