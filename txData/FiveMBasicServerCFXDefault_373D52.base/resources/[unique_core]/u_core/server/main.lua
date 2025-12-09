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
    local player = UCore.GetPlayer(src)
    if player then
        DB.execute("UPDATE characters SET pos_x = ?, pos_y = ?, pos_z = ?, heading = ? WHERE id = ?", {
            player.pos_x,
            player.pos_y,
            player.pos_z,
            player.heading,
            player.charId
        })
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

            local spawn = {}

            if character.pos_x == 0 and character.pos_y == 0 and character.pos_z == 0 then
                spawn.x = Config.InitialSpawn.x
                spawn.y = Config.InitialSpawn.y
                spawn.z = Config.InitialSpawn.z
                spawn.heading = Config.InitialSpawn.heading
            else
                spawn.x = character.pos_x
                spawn.y = character.pos_y
                spawn.z = character.pos_z
                spawn.heading = character.heading
            end

            local player = UCore.Player.new(src, account, character)

            if cb then cb(true, spawn) end
        end)
    end)
end

RegisterNetEvent('u_core:updatePosition')
AddEventHandler('u_core:updatePosition', function(x, y, z, heading)
    local src = source
    local player = UCore.GetPlayer(src)
    if not player then return end
    player.pos_x = x + 0.0
    player.pos_y = y + 0.0
    player.pos_z = z + 0.0
    player.heading = heading + 0.0
end)
