local function AceAllowed(src, perm)
  if src == 0 then return true end
  return IsPlayerAceAllowed(src, perm)
end

local function PermFor(cmd)
  return string.format("%s.%s", Config.AcePrefix, cmd)
end

RegisterNetEvent("u_commands:server:copyPos", function(text)
  local src = source
  TriggerClientEvent("u_commands:client:copyToClipboard", src, text)
end)

RegisterNetEvent("u_commands:server:notify", function(msg)
  local src = source
  TriggerClientEvent("chat:addMessage", src, { args = { "u_commands", msg } })
end)

RegisterNetEvent("u_commands:server:requestTpTo", function(x, y, z)
  local src = source
  if Config.RequireAceFor.tp and not AceAllowed(src, PermFor("tp")) then
    TriggerClientEvent("chat:addMessage", src, { args = { "u_commands", "Keine Rechte." } })
    return
  end

  local ped = GetPlayerPed(src)
  if ped == 0 then return end

  local px, py, pz = table.unpack(GetEntityCoords(ped))
  local dist = #(vector3(px, py, pz) - vector3(x, y, z))
  if Config.MaxTpDistance and dist > Config.MaxTpDistance then
    TriggerClientEvent("chat:addMessage", src, { args = { "u_commands", "Ziel zu weit entfernt." } })
    return
  end

  SetEntityCoords(ped, x + 0.0, y + 0.0, z + 0.0, false, false, false, true)
end)
