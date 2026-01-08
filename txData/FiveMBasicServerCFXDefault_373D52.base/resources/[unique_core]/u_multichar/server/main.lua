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
      chars = chars or {}

      local maxChars = tonumber(account.max_chars) or Config.DefaultMaxChars

      local ids = {}
      for i = 1, #chars do
        ids[#ids + 1] = tonumber(chars[i].id)
      end

      if #ids == 0 then
        TriggerClientEvent('u_multichar:sceneData', src, { characters = {}, maxChars = maxChars })
        return
      end

      local placeholders = {}
      for i = 1, #ids do placeholders[i] = '?' end

      local q = 'SELECT char_id, model, appearance FROM character_skins WHERE char_id IN (' .. table.concat(placeholders, ',') .. ')'
      exports.oxmysql:query(q, ids, function(rows)
        local skinById = {}
        for i = 1, #(rows or {}) do
          skinById[tonumber(rows[i].char_id)] = rows[i]
        end

        for i = 1, #chars do
          local cid = tonumber(chars[i].id)
          chars[i].skin = skinById[cid]
        end

        TriggerClientEvent('u_multichar:sceneData', src, { characters = chars, maxChars = maxChars })
      end)
    end)
  end)
end

RegisterNetEvent('u_multichar:open')
AddEventHandler('u_multichar:open', function()
  SendCharacterList(source)
end)

RegisterNetEvent('u_multichar:beginCreate')
AddEventHandler('u_multichar:beginCreate', function()
  local src = source

  local identifier = GetLicenseIdentifier(src)
  if not identifier then return end

  exports['u_core']:GetAccountByIdentifier(identifier, function(account)
    if not account then return end

    exports['u_core']:GetCharactersByAccountId(account.id, function(chars)
      chars = chars or {}
      local maxChars = tonumber(account.max_chars)
      local count = #chars

      if count >= maxChars then
        TriggerClientEvent('chat:addMessage', src, { args = { "System", "Du hast keine freien Charakter-Slots." } })
        SendCharacterList(src)
        return
      end

      exports['u_core']:CreateCharacter(account.id, "", "", 0, function(newCharId)
        if not newCharId then
          TriggerClientEvent('chat:addMessage', src, { args = { "System", "Charakter konnte nicht erstellt werden." } })
          SendCharacterList(src)
          return
        end

        local spawn = Config.InitialSpawn
        TriggerClientEvent('u_charcreator:open', src, { charId = newCharId, spawn = spawn, gender = 0 })
      end)
    end)
  end)
end)

RegisterNetEvent('u_multichar:createCharacter')
AddEventHandler('u_multichar:createCharacter', function(data)
    local src = source
    if type(data) ~= "table" then return end

    local firstname = tostring(data.firstname or "")
    local lastname = tostring(data.lastname or "")
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

    exports['u_core']:UseCharacter(src, charId, function(success, spawn)
        if not success then
            TriggerClientEvent('chat:addMessage', src, { args = { "System", "Charakter konnte nicht geladen werden." } })
            return
        end

        TriggerClientEvent('u_multichar:close', src)

        exports.oxmysql:scalar('SELECT 1 FROM character_skins WHERE char_id = ? LIMIT 1', { charId }, function(v)
            if v ~= nil then
                TriggerClientEvent('u_multichar:spawn', src, spawn)
                return
            end

            exports['u_core']:GetCharacterById(charId, function(character)
                local gender = 0
                if character and character.gender ~= nil then
                    gender = tonumber(character.gender) or 0
                end
                TriggerClientEvent('u_charcreator:open', src, { charId = charId, spawn = spawn, gender = gender })
            end)
        end)
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
                exports.oxmysql:update('DELETE FROM character_skins WHERE char_id = ?', { charId })
                SendCharacterList(src)
            end)
        end)
    end)
end)
