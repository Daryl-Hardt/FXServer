local uiOpen = false

AddEventHandler('onClientResourceStart', function(resName)
    if resName == GetCurrentResourceName() then
        Citizen.Wait(1000)
        TriggerServerEvent('u_multichar:open')
    end
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
    cb('ok')
end)
