local uiOpen = false
local tracking = false
local charCam = nil

local uiOpen = false
local tracking = false
local charCam = nil

local function StartCharSelectCam()
    local ped = PlayerPedId()

    ShutdownLoadingScreenNui()
    ShutdownLoadingScreen()

    DoScreenFadeOut(0)
    while not IsScreenFadedOut() do
        Citizen.Wait(0)
    end

    local spawnX, spawnY, spawnZ, spawnH = -710.33405, 4477.121, 17.451294, 0.0
    local camX, camY, camZ = -656.4, 4376.347, 58.80078
    local rotX, rotY, rotZ = 0.0, 0.0, -60.0

    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, false, false)

    SetEntityCoordsNoOffset(ped, spawnX, spawnY, spawnZ, false, false, false)
    SetEntityHeading(ped, spawnH)

    RequestCollisionAtCoord(spawnX, spawnY, spawnZ)
    SetFocusPosAndVel(spawnX, spawnY, spawnZ, 0.0, 0.0, 0.0)
    LoadScene(spawnX, spawnY, spawnZ)

    local timeout = GetGameTimer() + 5000
    while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < timeout do
        Citizen.Wait(0)
    end

    if charCam ~= nil then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(charCam, false)
        charCam = nil
    end

    charCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(charCam, camX, camY, camZ)
    SetCamRot(charCam, rotX, rotY, rotZ, 2)
    SetCamFov(charCam, 60.0)
    SetCamActive(charCam, true)
    RenderScriptCams(true, false, 0, true, true)

    DoScreenFadeIn(500)
end

local function StopCharSelectCam()
    local ped = PlayerPedId()

    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true, false)

    ClearFocus()

    if charCam ~= nil then
        RenderScriptCams(false, true, 1000, true, true)
        DestroyCam(charCam, false)
        charCam = nil
    end
end

AddEventHandler('onClientResourceStart', function(resName)
    if resName ~= GetCurrentResourceName() then
        return
    end

    Citizen.CreateThread(function()
        while not NetworkIsPlayerActive(PlayerId()) do
            Citizen.Wait(0)
        end

        StartCharSelectCam()
        Citizen.Wait(200)
        TriggerServerEvent('u_multichar:open')
    end)
end)

RegisterCommand("chars", function(source, args, raw)
    TriggerServerEvent('u_multichar:open')
end, false)

RegisterNetEvent('u_multichar:show')
AddEventHandler('u_multichar:show', function(data)
    uiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        characters = data.characters or {}
    })
end)

RegisterNetEvent('u_multichar:close')
AddEventHandler('u_multichar:close', function()
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end)

RegisterNUICallback('selectCharacter', function(data, cb)
    TriggerServerEvent('u_multichar:selectCharacter', data)
    cb('ok')
end)

RegisterNUICallback('createCharacter', function(data, cb)
    TriggerServerEvent('u_multichar:createCharacter', data)
    cb('ok')
end)

RegisterNUICallback('deleteCharacter', function(data, cb)
    TriggerServerEvent('u_multichar:deleteCharacter', data)
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    StopCharSelectCam()
    cb('ok')
end)


RegisterNetEvent('u_multichar:spawn')
AddEventHandler('u_multichar:spawn', function(data)
    if not data then return end

    local ped = PlayerPedId()

    local x = data.x + 0.0
    local y = data.y + 0.0
    local z = data.z + 0.0
    local heading = data.heading + 0.0

    SetEntityCoords(ped, x, y, z, false, false, false, true)
    SetEntityHeading(ped, heading)
    StopCharSelectCam()

    tracking = true

    Citizen.CreateThread(function()
        while tracking do
            local p = PlayerPedId()
            local px, py, pz = table.unpack(GetEntityCoords(p))
            local ph = GetEntityHeading(p)
            TriggerServerEvent('u_core:updatePosition', px, py, pz, ph)
            Citizen.Wait(5000)
        end
    end)
end)
