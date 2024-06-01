local searching, showprompt, nearest = false, false, 0

RegisterNetEvent("vorp_crawfish:try_search", function()
	searching, nearest = false, 0
end)

RegisterNetEvent("vorp_crawfish:do_search", function(holeIndex, searchTime)
	local playerPed = PlayerPedId()
	TaskStartScenarioInPlaceHash(playerPed, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), searchTime, true, "", 0, false)
	exports['progressBars']:startUI(searchTime, _U("searching"))
	Wait(searchTime)
	ClearPedTasksImmediately(playerPed)
	nearest = 0
	searching = false
	TriggerServerEvent("vorp_crawfish:do_search", holeIndex)
end)

RegisterNetEvent("vorp_crawfish:harvest", function()
	local playerPed = PlayerPedId()
	local dict, anim = "mech_skin@chicken@field_dress", "success"
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Wait(0)
	end
	TaskPlayAnim(playerPed, dict, anim, 1.0, 1.0, 4000, 16, 0.0, false, 0, false, '', false)
	exports['progressBars']:startUI(5000, _U("harvesting"))
	Wait(5000)
	ClearPedTasksImmediately(playerPed)
	RemoveAnimDict(dict)
	TriggerServerEvent("vorp_crawfish:harvest")
end)

function RegisterPrompts()
	local _promptGroup = GetRandomIntInRange(0, 0xffffff)
	local _prompt = UiPromptRegisterBegin()
	UiPromptSetControlAction(_prompt, 0x760A9C6F) -- G key
	local str = CreateVarString(10, 'LITERAL_STRING', _U("hole"))
	UiPromptSetText(_prompt, str)
	UiPromptSetEnabled(_prompt, true)
	UiPromptSetStandardMode(_prompt, true)
	UiPromptSetGroup(_prompt, _promptGroup, 0)
	UiPromptRegisterEnd(_prompt)
	return _prompt, _promptGroup
end

CreateThread(function()
	repeat Wait(2000) until LocalPlayer.state.IsInSession
	local _prompt, _promptGroup = RegisterPrompts()

	while true do
		showprompt = false
		local sleep = 1000
		local pedID = PlayerPedId()
		local DeadOrDying = IsPedDeadOrDying(pedID, false)
		if (not searching) and (not DeadOrDying) then
			local coords = GetEntityCoords(pedID)
			for index, pos in ipairs(Config.CrawfishHoles) do
				local distance = #(coords - pos)
				if distance <= 1.5 then
					sleep = 0
					showprompt = true
					nearest = index
					break
				end
			end
		elseif searching and DeadOrDying then
			searching = false
			showprompt = false
			TriggerServerEvent("vorp_crawfish:abort_search")
		end
		if showprompt and (not searching) and (nearest > 0) and (not DeadOrDying) then
			sleep = 0
			local label = CreateVarString(10, 'LITERAL_STRING', _U("search_hole"))
			UiPromptSetActiveGroupThisFrame(_promptGroup, label, 0, 0, 0, 0)

			if UiPromptHasStandardModeCompleted(_prompt, 0) then
				searching = true
				TriggerServerEvent("vorp_crawfish:try_search", nearest)
			end
		end
		nearest = 0

		Wait(sleep)
	end
end)
