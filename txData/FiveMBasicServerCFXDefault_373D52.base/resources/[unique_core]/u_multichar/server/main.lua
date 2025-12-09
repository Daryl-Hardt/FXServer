local function GetLicenseIdentifier(src)
    local identifiers = GetPlayerIdentifiers(src)
    for _, v in ipairs(identifiers) do
        if string.sub(v, 1, 7) == "license" then
            return v
        end
    end
    return nil
end

local function SendCharacterList(src)
    local identifier = GetLicenseIdentifier(src)
    if not identifier then return end

    exports['u_core']:GetAccountByIdentifier(identifier, function(account)
        if not account then return end

        exports['u_core']:GetCharactersByAccountId(account.id, function(chars)
            TriggerClientEvent('u_multichar:show', src, {
                accountId = account.id,
                characters = chars
            })
        end)
    end)
end

RegisterNetEvent('u_multichar:open')
AddEventHandler('u_multichar:open', function()
    local src = source
    SendCharacterList(src)
end)

RegisterNetEvent('u_multichar:createCharacter')
AddEventHandler('u_multichar:createCharacter', function(data)
    local src = source
    if type(data) ~= "table" then return end

    local firstname = tostring(data.firstname or "") or ""
    local lastname = tostring(data.lastname or "") or ""
    local gender = tonumber(data.gender) or 0

    if firstname == "" or lastname == "" then
        TriggerClientEvent('chat:addMessage', src, { args = { "System", "Vorname und Nachname eingeben." } })
        return
    end

    local identifier = GetLicenseIdentifier(src)
    if not identifier then return end

    exports['u_core']:GetAccountByIdentifier(identifier, function(account)
        if not account then return end

        exports['u_core']:CreateCharacter(account.id, firstname, lastname, gender, function()
            SendCharacterList(src)
        end)
    end)
end)

RegisterNetEvent('u_multichar:selectCharacter')
AddEventHandler('u_multichar:selectCharacter', function(data)
    local src = source
    local charId = tonumber(data.id)
    if not charId then return end

    exports['u_core']:UseCharacter(src, charId, function(success, result)
        if success then
            TriggerClientEvent('u_multichar:close', src)
            TriggerClientEvent('chat:addMessage', src, {
                args = { "System", "Charakter geladen." }
            })
        else
            TriggerClientEvent('chat:addMessage', src, {
                args = { "System", "Charakter konnte nicht geladen werden." }
            })
        end
    end)
end)

RegisterNetEvent('u_multichar:deleteCharacter')
AddEventHandler('u_multichar:deleteCharacter', function(data)
    local src = source
    local charId = tonumber(data.id)
    if not charId then return end

    local identifier = GetLicenseIdentifier(src)
    if not identifier then return end

    exports['u_core']:GetAccountByIdentifier(identifier, function(account)
        if not account then return end

        exports['u_core']:GetCharacterById(charId, function(character)
            if not character or character.account_id ~= account.id then
                return
            end

            exports['u_core']:DeleteCharacter(charId, function()
                SendCharacterList(src)
            end)
        end)
    end)
end)
