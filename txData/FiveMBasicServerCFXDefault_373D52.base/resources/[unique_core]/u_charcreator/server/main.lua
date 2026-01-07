local function GetLicenseIdentifier(src)
  local identifiers = GetPlayerIdentifiers(src)
  for _, v in ipairs(identifiers) do
    if string.sub(v, 1, 7) == "license" then
      return v
    end
  end
  return nil
end

local function GetAccountId(src, cb)
  local identifier = GetLicenseIdentifier(src)
  if not identifier then return cb(nil) end

  exports['u_core']:GetAccountByIdentifier(identifier, function(account)
    if not account then return cb(nil) end
    cb(account.id)
  end)
end

local function OwnsCharacter(src, charId, cb)
  GetAccountId(src, function(accountId)
    if not accountId then return cb(false) end
    exports['u_core']:GetCharacterById(charId, function(character)
      if not character then return cb(false) end
      cb(character.account_id == accountId)
    end)
  end)
end

local function IsAdmin(src)
  local p = GetPlayer(src)
  if not p then return false end
  local g = p:GetGroup()
  return g == "admin" or g == "superadmin"
end

local function HasSkin(charId, cb)
  exports.oxmysql:scalar('SELECT 1 FROM character_skins WHERE char_id = ? LIMIT 1', { charId }, function(v)
    cb(v ~= nil)
  end)
end

local function GetSkin(charId, cb)
  exports.oxmysql:query('SELECT model, appearance FROM character_skins WHERE char_id = ? LIMIT 1', { charId }, function(rows)
    if not rows or not rows[1] then return cb(nil) end
    cb(rows[1])
  end)
end

local function InsertSkinIfMissing(charId, model, appearanceJson, cb)
  local q = [[
    INSERT INTO character_skins (char_id, model, appearance)
    SELECT ?, ?, ?
    FROM DUAL
    WHERE NOT EXISTS (
      SELECT 1 FROM character_skins WHERE char_id = ? LIMIT 1
    )
  ]]
  exports.oxmysql:update(q, { charId, model, appearanceJson, charId }, function(affected)
    cb(affected and affected > 0)
  end)
end

local function UpdateSkin(charId, model, appearanceJson, cb)
  exports.oxmysql:update(
    'UPDATE character_skins SET model = ?, appearance = ? WHERE char_id = ?',
    { model, appearanceJson, charId },
    function(affected)
      cb(affected and affected > 0)
    end
  )
end

RegisterNetEvent('u_charcreator:requestSkin')
AddEventHandler('u_charcreator:requestSkin', function(charId)
  local src = source
  charId = tonumber(charId)
  if not charId then return end

  OwnsCharacter(src, charId, function(ok)
    if not ok then return end
    GetSkin(charId, function(row)
      TriggerClientEvent('u_charcreator:applySkin', src, row)
    end)
  end)
end)

RegisterNetEvent('u_charcreator:saveSkin')
AddEventHandler('u_charcreator:saveSkin', function(charId, payload)
  local src = source
  charId = tonumber(charId)
  if not charId then return end
  if type(payload) ~= 'table' then return end
  if type(payload.appearance) ~= 'table' then return end

  OwnsCharacter(src, charId, function(ok)
    if not ok then
      TriggerClientEvent('u_charcreator:saveResult', src, false, 'not_owner')
      return
    end

    local model = tostring(payload.model or 'mp_m_freemode_01')
    local appearanceJson = json.encode(payload.appearance)

    HasSkin(charId, function(has)
      if has then
        if IsAdmin(src) then
          UpdateSkin(charId, model, appearanceJson, function(success)
            TriggerClientEvent('u_charcreator:saveResult', src, success, success and 'ok' or 'db_fail')
          end)
        else
          TriggerClientEvent('u_charcreator:saveResult', src, false, 'already_saved')
        end
        return
      end

      InsertSkinIfMissing(charId, model, appearanceJson, function(success)
        TriggerClientEvent('u_charcreator:saveResult', src, success, success and 'ok' or 'db_fail')
      end)
    end)
  end)
end)

RegisterCommand('editchar', function(src, args)
  if src == 0 then return end
  if not IsAdmin(src) then return end

  local charId = tonumber(args[1])
  if not charId then return end

  OwnsCharacter(src, charId, function(ok)
    if not ok then return end

    exports['u_core']:GetCharacterById(charId, function(character)
      if not character then return end

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

      TriggerClientEvent('u_charcreator:open', src, {
        charId = charId,
        spawn = spawn,
        gender = tonumber(character.gender) or 0
      })
    end)
  end)
end, false)
