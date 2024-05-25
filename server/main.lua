local VORP_INV = exports.vorp_inventory:vorp_inventoryApi()

RegisterServerEvent("vorp_crawfish:try_search")
RegisterServerEvent("vorp_crawfish:do_search")
RegisterServerEvent("vorp_crawfish:abort_search")
RegisterServerEvent("vorp_crawfish:harvest")

local holes_searched = {}
local holes_searching = {}
local holes_usage = {}

local function InventoryCheck(_source, item, count)
	local itemsAvailable = true
	local done = false
	TriggerEvent("vorpCore:canCarryItem", _source, item, count, function(canCarryItem)
		if canCarryItem ~= true then
			itemsAvailable = false
		end
		done = true
	end)
	while done == false do
		Wait(500)
	end
	if not itemsAvailable then
		TriggerClientEvent("vorp:Tip", _source, _U("inv_nospace"), 5000)
		return false
	end
	if not VORP_INV.canCarryItems(_source, count) then
		TriggerClientEvent("vorp:Tip", _source, _U("inv_nospace"), 5000)
		return false
	end
	return true
end

local function AbortSearch(_source)
	for k, v in ipairs(holes_searching) do
		if v then
			if v == _source then
				holes_searching[k] = false
			end
		end
	end
end

local function GetSearchRewardCount()
	if type(Config.SearchRewardCount) == "table" then
		return math.random(Config.SearchRewardCount[1], Config.SearchRewardCount[2])
	else
		return Config.SearchRewardCount
	end
end

local function GetHoleUsageLimit()
	return math.random(Config.HoleUsageLimits[1], Config.HoleUsageLimits[2])
end

AddEventHandler("vorp_crawfish:try_search", function(holeIndex)
	local _source = source
	local allow = true
	local curtime = os.time()
	if holes_searching[holeIndex] then
		TriggerClientEvent("vorp:Tip", _source, _U("search_current"), 5000)
		return
	end
	holes_searching[holeIndex] = _source
	if holes_searched[holeIndex] then
		if curtime < (holes_searched[holeIndex] + Config.SearchDelay) then
			TriggerClientEvent("vorp:Tip", _source, _U("search_recent"), 5000)
			allow = false
		end
	end
	if not holes_usage[holeIndex] then
		holes_usage[holeIndex] = GetHoleUsageLimit()
	end
	if holes_usage[holeIndex] <= 0 then
		TriggerClientEvent("vorp:Tip", _source, _U("hole_empty"), 5000)
		allow = false
	end
	if allow then
		local count = GetSearchRewardCount()
		allow = InventoryCheck(_source, Config.CrawfishGivenItemName, count)
	end
	if not allow then
		holes_searching[holeIndex] = false
		TriggerClientEvent("vorp_crawfish:try_search", _source)
		return
	end
	holes_searched[holeIndex] = curtime
	local searchTime = math.random(Config.SearchTimeMin, Config.SearchTimeMax)
	TriggerClientEvent("vorp_crawfish:do_search", _source, holeIndex, searchTime)
end)

AddEventHandler("vorp_crawfish:do_search", function(holeIndex)
	local _source = source
	if (holes_searching[holeIndex] or 0) ~= _source then
		TriggerClientEvent("vorp_crawfish:try_search", _source)
		return
	end
	holes_searching[holeIndex] = false
	holes_usage[holeIndex] = holes_usage[holeIndex] - 1

	local foundItem = false
	if math.random() < Config.NothingFoundChance then
		TriggerClientEvent("vorp:Tip", _source, _U("search_nothing"), 5000)
	else
		for _, v in ipairs(Config.Items) do
			if math.random() < v.chance then
				foundItem = true
				local count = GetSearchRewardCount()
				if not InventoryCheck(_source, v.name, count) then
					holes_searched[holeIndex] = false
					TriggerClientEvent("vorp_crawfish:try_search", _source)
					return
				end
				VORP_INV.addItem(_source, v.name, count)
				TriggerClientEvent("vorp:Tip", _source, _U("search_found", v.name), 5000)
				break
			end
		end
	end

	if not foundItem then
		TriggerClientEvent("vorp:Tip", _source, _U("search_nothing"), 5000)
	end

	if holes_usage[holeIndex] <= 0 then
		holes_searched[holeIndex] = os.time() + Config.SearchDelay
	end
end)

AddEventHandler("vorp_crawfish:abort_search", function()
	AbortSearch(source)
end)

local harvesting = {}
AddEventHandler("vorp_crawfish:harvest", function()
	local _source = source
	if not harvesting[_source] then return end
	local count = harvesting[_source]
	VORP_INV.addItem(_source, Config.CrawfishGivenItemName, count)
	TriggerClientEvent("vorp:Tip", _source, _U("harvested", count), 5000)
	harvesting[_source] = nil
end)

if not Config.CrawfishCustomUseFunction then
	for _, item in ipairs(Config.Items) do
		VORP_INV.RegisterUsableItem(item.name, function(data)
			if harvesting[data.source] then return end
			local count = math.random(Config.CrawfishGivenItemAmount[1], Config.CrawfishGivenItemAmount[2])
			VORP_INV.subItem(data.source, item.name, 1)
			if not InventoryCheck(data.source, Config.CrawfishGivenItemName, count) then
				VORP_INV.addItem(data.source, item.name, 1)
				return
			end
			harvesting[data.source] = count
			TriggerClientEvent("vorp_crawfish:harvest", data.source)
		end)
	end
end

AddEventHandler("playerDropped", function(reason)
	AbortSearch(source)
end)

AddEventHandler("onResourceStart", function(resourceName)
	if resourceName == GetCurrentResourceName() then
		for k, v in ipairs(Config.CrawfishHoles) do
			holes_searched[k] = false
			holes_searching[k] = false
			holes_usage[k] = GetHoleUsageLimit()
		end
	end
end)