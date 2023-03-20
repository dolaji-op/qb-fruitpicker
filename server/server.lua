QBCore = nil

if Config.Object.usingexport then
    QBCore = exports[Config.Object.CoreName]:GetCoreObject()
else
    TriggerEvent(Config.Object.event, function(obj) QBCore = obj end)
end


local JobData = {}

QBCore.Functions.CreateUseableItem("fruit_basket", function(source, item)
	local Player = QBCore.Functions.GetPlayer(source)
	TriggerClientEvent("ds-fruitpicker:usebasket", source, item)
end)
QBCore.Functions.CreateUseableItem("orange", function(source, item)
	local Player = QBCore.Functions.GetPlayer(source)
    if Player.Functions.RemoveItem('orange',1, item.slot, { nonDecayed = true }) then
        TriggerClientEvent("ds-fruitpicker:eatfruit", source)
    end
end)

QBCore.Functions.CreateCallback('ds-fruitpicker:server:getdata', function(source, cb)
	local data = {}
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	local cid = Player.PlayerData.citizenid
	if JobData[cid] ~= nil then
    	data = JobData[cid]
	end
	cb(data)
end)

RegisterServerEvent("ds-fruitpicker:savebasket")
AddEventHandler("ds-fruitpicker:savebasket", function(itemInfo, id)
    local src = source

    local Player = QBCore.Functions.GetPlayer(src)
    local ItemSlot = Player.PlayerData.items[itemInfo.slot]

    if ItemSlot == nil then return end

    if ItemSlot.info.qty == nil then
		ItemSlot.info['qty'] = itemInfo.info.qty
	else
		ItemSlot.info.qty = itemInfo.info.qty
	end
	Player.Functions.SetInventory(Player.PlayerData.items)


	local Player = QBCore.Functions.GetPlayer(src)
	local jobrep = Player.PlayerData.metadata["jobrep"]
	if jobrep['fruitpeeker'] ~= nil then
		if jobrep['fruitpeeker'] > 40 then
			jobrep['fruitpeeker'] = jobrep['fruitpeeker'] + 0.05
		elseif jobrep['fruitpeeker'] > 30 then
			jobrep['fruitpeeker'] = jobrep['fruitpeeker'] + 0.10
		elseif jobrep['fruitpeeker'] > 20 then
			jobrep['fruitpeeker'] = jobrep['fruitpeeker'] + 0.15
		elseif jobrep['fruitpeeker'] > 10 then
			jobrep['fruitpeeker'] = jobrep['fruitpeeker'] + 0.20
		else
			jobrep['fruitpeeker'] = jobrep['fruitpeeker'] + 0.25
		end
	else
		jobrep['fruitpeeker'] = 0.25
	end
	Player.Functions.SetMetaData("jobrep", jobrep)
end)


RegisterServerEvent("ds-fruitpicker:addorg")
AddEventHandler("ds-fruitpicker:addorg", function(id)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	local cid = Player.PlayerData.citizenid
	if JobData[cid] ~= nil then
		JobData[cid][id] = true
	else
		JobData[cid] = {}
		JobData[cid][id] = true
	end
	TriggerClientEvent('ds-fruitpicker:updatedata',src, JobData[cid])
end)

RegisterServerEvent("ds-fruitpicker:removeorg")
AddEventHandler("ds-fruitpicker:removeorg", function(id)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	local cid = Player.PlayerData.citizenid
	if JobData[cid] ~= nil then
		JobData[cid][id] = false
	else
		JobData[cid] = {}
		JobData[cid][id] = false
	end
	TriggerClientEvent('ds-fruitpicker:updatedata', src, JobData[cid])
end)


RegisterServerEvent("ds-fruitpicker:removebasket")
AddEventHandler("ds-fruitpicker:removebasket", function(source)
    TriggerClientEvent("ds-fruitpicker:removebasket", source)
end)

RegisterServerEvent("ds-fruitpicker:getoranges")
AddEventHandler("ds-fruitpicker:getoranges", function(qty)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem('orange', qty,nil, nil, "ds-fruitpicker:getoranges")
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['orange'], 'add')
end)


RegisterServerEvent("ds-fruitpicker:selloranges")
AddEventHandler("ds-fruitpicker:selloranges", function(qty)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	local rand = math.random(Config.MinPay, Config.MaxPay)
    if qty > 0 then
		Player.Functions.AddMoney("cash",rand*qty)
	end
end)







