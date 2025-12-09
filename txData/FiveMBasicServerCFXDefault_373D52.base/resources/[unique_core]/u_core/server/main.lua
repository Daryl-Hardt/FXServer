local function GetLicenseIdentifier(src)
    local identifiers = GetPlayerIdentifiers(src)
    for _, v in ipairs(identifiers) do
        if string.sub(v, 1, 7) == "license" then
            return v
        end
    end
    return nil
end

AddEventHandler("playerDropped", function(reason)
    local src = source
    if UCore.GetPlayer(src) then
        if Config.Debug then
            print("[u_core] Player entfernt: " .. tostring(src) .. " Grund: " .. tostring(reason))
        end
        UCore.RemovePlayer(src)
    end
end)


RegisterCommand("createchar", function(source, args, raw)
    local src = source
    if src == 0 then
        return
    end

    local firstname = args[1]
    local lastname = args[2]

    if not firstname or not lastname then
        TriggerClientEvent("chat:addMessage", src, { args = { "System", "Benutzung: /createchar Vorname Nachname" } })
        return
    end

    local identifier = GetLicenseIdentifier(src)
    if not identifier then
        return
    end

    GetAccountByIdentifier(identifier, function(account)
        if not account then
            TriggerClientEvent("chat:addMessage", src, { args = { "System", "Kein Account gefunden." } })
            return
        end

        CreateCharacter(account.id, firstname, lastname, 0, function(charId)
            TriggerClientEvent("chat:addMessage", src, {
                args = { "System", "Charakter erstellt: " .. firstname .. " " .. lastname .. " (ID " .. tostring(charId) .. ")" }
            })
        end)
    end)
end, false)

RegisterCommand("usechar", function(source, args, raw)
    local src = source
    if src == 0 then
        return
    end

    local charId = tonumber(args[1])
    if not charId then
        TriggerClientEvent("chat:addMessage", src, { args = { "System", "Benutzung: /usechar <CharID>" } })
        return
    end

    local identifier = GetLicenseIdentifier(src)
    if not identifier then
        return
    end

    GetAccountByIdentifier(identifier, function(account)
        if not account then
            TriggerClientEvent("chat:addMessage", src, { args = { "System", "Kein Account gefunden." } })
            return
        end

        GetCharacterById(charId, function(character)
            if not character or character.account_id ~= account.id then
                TriggerClientEvent("chat:addMessage", src, { args = { "System", "Dieser Charakter gehört nicht zu deinem Account." } })
                return
            end

            local player = UCore.Player.new(src, account, character)

            if Config.Debug then
                print("[u_core] Charakter geladen: " .. player:GetName() .. " für " .. account.name)
            end

            TriggerClientEvent("chat:addMessage", src, {
                args = { "System", "Du spielst jetzt: " .. player:GetName() .. " (CharID " .. tostring(player:GetCharId()) .. ")" }
            })
        end)
    end)
end, false)

function UseCharacter(src, charId, cb)
    local function GetLicenseIdentifier(localSrc)
        local identifiers = GetPlayerIdentifiers(localSrc)
        for _, v in ipairs(identifiers) do
            if string.sub(v, 1, 7) == "license" then
                return v
            end
        end
        return nil
    end

    local identifier = GetLicenseIdentifier(src)
    if not identifier then
        if cb then cb(false, "no_identifier") end
        return
    end

    GetAccountByIdentifier(identifier, function(account)
        if not account then
            if cb then cb(false, "no_account") end
            return
        end

        GetCharacterById(charId, function(character)
            if not character or character.account_id ~= account.id then
                if cb then cb(false, "invalid_character") end
                return
            end

            local player = UCore.Player.new(src, account, character)

            if cb then cb(true, player) end
        end)
    end)
end
