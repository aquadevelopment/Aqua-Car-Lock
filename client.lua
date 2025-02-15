local isLocked = false


function GetClosestVehicleToPlayer()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    local closestVehicle
    local minDistance = Config.LockDistance + 5.0  

    for vehicle in EnumerateVehicles() do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(playerCoords - vehicleCoords)

        if distance < minDistance then
            closestVehicle = vehicle
            minDistance = distance
        end
    end

    return closestVehicle
end


function SendNotification(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(false, false)
end


RegisterCommand('toggleLock', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle == 0 then
        vehicle = GetClosestVehicleToPlayer()
    end

    if vehicle ~= 0 then
        local distance = #(GetEntityCoords(playerPed) - GetEntityCoords(vehicle))


        if distance <= Config.LockDistance then
            isLocked = not isLocked
            SetVehicleDoorsLocked(vehicle, isLocked and 2 or 1)


            RequestAnimDict(Config.AnimationDict)
            while not HasAnimDictLoaded(Config.AnimationDict) do
                Wait(100)
            end
            TaskPlayAnim(playerPed, Config.AnimationDict, Config.AnimationName, 8.0, -8.0, 800, 49, 0, false, false, false)


            local notifyText = isLocked and Config.LockNotify or Config.UnlockNotify
            SendNotification(notifyText)
        else

            SendNotification(Config.OutOfRangeNotify)
        end
    end
end, false)


CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, Config.LockKey) then
            ExecuteCommand('toggleLock')
        end
    end
end)


function EnumerateVehicles()
    return coroutine.wrap(function()
        local handle, vehicle = FindFirstVehicle()
        local success
        repeat
            coroutine.yield(vehicle)
            success, vehicle = FindNextVehicle(handle)
        until not success
        EndFindVehicle(handle)
    end)
end
