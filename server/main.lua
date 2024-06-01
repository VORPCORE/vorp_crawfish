local Core = exports.vorp_core:GetCore()
local holes_searched = {}
local holes_searching = {}

local function InventoryCheck(_source, item, count)
	local canCarry = exports.vorp_inventory:canCarryItem(_source, item, count)
	if not canCarry then
		Core.NotifyObjective(_source, _U("inv_nospace"), 5000)
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
RegisterServerEvent("vorp_crawfish:try_search", function(holeIndex)
	local _source = source
	local allow = true
	local curtime = os.time()
	if holes_searching[holeIndex] then
		Core.NotifyObjective(_source, _U("searching_current"), 5000)
		return
	end
	holes_searching[holeIndex] = _source
	if holes_searched[holeIndex] then
		if curtime < (holes_searched[holeIndex] + Config.SearchDelay) then
			Core.NotifyObjective(_source, _U("search_recent"), 5000)
			allow = false
		end
	end
	if allow then
		local count
		if type(Config.SearchRewardCount) == "table" then
			count = math.max(1, Config.SearchRewardCount[1])
		else
			count = Config.SearchRewardCount
		end
		allow = InventoryCheck(_source, Config.CrawfishItemName, count)
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

RegisterServerEvent("vorp_crawfish:do_search", function(holeIndex)
	local _source = source
	if (holes_searching[holeIndex] or 0) ~= _source then
		TriggerClientEvent("vorp_crawfish:try_search", _source)
		return
	end
	holes_searching[holeIndex] = false
	local count
	if type(Config.SearchRewardCount) == "table" then
		count = math.random(Config.SearchRewardCount[1], Config.SearchRewardCount[2])
	else
		count = Config.SearchRewardCount
	end
	if not InventoryCheck(_source, Config.CrawfishItemName, count) then
		holes_searched[holeIndex] = false
		TriggerClientEvent("vorp_crawfish:try_search", _source)
		return
	end
	exports.vorp_inventory:addItem(_source, Config.CrawfishItemName, count)
	Core.NotifyObjective(_source, _UP("search_found", { count = count, item = Config.CrawfishItemLabel }), 5000)
end)

RegisterServerEvent("vorp_crawfish:abort_search", function()
	AbortSearch(source)
end)

local harvesting = {}
RegisterServerEvent("vorp_crawfish:harvest", function()
	local _source = source
	if not harvesting[_source] then return end
	exports.vorp_inventory:addItem(_source, Config.CrawfishGivenItemName, harvesting[_source])
	Core.NotifyObjective(_source, _UP("harvested", { count = harvesting[_source], item = Config.CrawfishGivenItemLabel }),
		5000)
	harvesting[_source] = nil
end)

if not Config.CrawfishCustomUseFunction then
	exports.vorp_inventory:registerUsableItem(Config.CrawfishItemName, function(data)
		if harvesting[data.source] then return end
		local count
		if type(Config.CrawfishGivenItemAmount) == "table" then
			count = math.random(Config.CrawfishGivenItemAmount[1], Config.CrawfishGivenItemAmount[2])
		else
			count = Config.CrawfishGivenItemAmount
		end
		exports.vorp_inventory:subItem(data.source, Config.CrawfishItemName, 1)
		if not InventoryCheck(data.source, Config.CrawfishGivenItemName, count) then
			exports.vorp_inventory:addItem(data.source, Config.CrawfishItemName, 1)
			return
		end
		harvesting[data.source] = count
		TriggerClientEvent("vorp_crawfish:harvest", data.source)
	end)
end

AddEventHandler("playerDropped", function(reason)
	AbortSearch(source)
end)

AddEventHandler("onResourceStart", function(resourceName)
	if resourceName == GetCurrentResourceName() then
		for k, v in ipairs(Config.CrawfishHoles) do
			holes_searched[k] = false
			holes_searching[k] = false
		end
	end
end)
