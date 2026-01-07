local function Notify(msg)
  TriggerServerEvent("u_commands:server:notify", msg)
end

local function GetGroundZ(x, y, zHint)
  local found, z = GetGroundZFor_3dCoord(x + 0.0, y + 0.0, (zHint or 1000.0) + 0.0, false)
  if found then return z end
  for i = 1, 15 do
    local h = 50.0 * i
    local ok, zz = GetGroundZFor_3dCoord(x + 0.0, y + 0.0, h + 0.0, false)
    if ok then return zz end
  end
  return (zHint or 100.0)
end

local function HasAce(cmd)
  if not Config.RequireAceFor[cmd] then return true end
  return IsPlayerAceAllowed(PlayerId(), string.format("%s.%s", Config.AcePrefix, cmd))
end

RegisterNetEvent("u_commands:client:copyToClipboard", function(text)
  SendNUIMessage({ type = "copy", text = text })
  Notify("Position kopiert.")
end)

RegisterCommand("pos", function()
  if not HasAce("pos") then Notify("Keine Rechte.") return end

  local ped = PlayerPedId()
  local c = GetEntityCoords(ped)
  local h = GetEntityHeading(ped)
  local out = string.format(Config.PosFormat, c.x, c.y, c.z, h)

  TriggerServerEvent("u_commands:server:copyPos", out)
  Notify(out)
end, false)

RegisterCommand("tp", function(_, args)
  if not HasAce("tp") then Notify("Keine Rechte.") return end
  if #args < 3 then
    Notify("Nutzung: /tp x y z")
    return
  end

  local x = tonumber(args[1])
  local y = tonumber(args[2])
  local z = tonumber(args[3])
  if not x or not y or not z then
    Notify("Ungültige Koordinaten.")
    return
  end

  TriggerServerEvent("u_commands:server:requestTpTo", x, y, z)
end, false)

RegisterCommand("tpm", function()
  if not HasAce("tpm") then Notify("Keine Rechte.") return end

  local blip = GetFirstBlipInfoId(8)
  if not DoesBlipExist(blip) then
    Notify("Kein Waypoint gesetzt.")
    return
  end

  local coord = GetBlipInfoIdCoord(blip)
  local z = GetGroundZ(coord.x, coord.y, 1000.0)

  local ped = PlayerPedId()
  SetEntityCoords(ped, coord.x + 0.0, coord.y + 0.0, z + 1.0, false, false, false, true)
end, false)

RegisterCommand("car", function(_, args)
  if not HasAce("car") then Notify("Keine Rechte.") return end
  local modelName = args[1]
  if not modelName or modelName == "" then
    Notify("Nutzung: /car modelname")
    return
  end

  local model = joaat(modelName)
  if not IsModelInCdimage(model) or not IsModelAVehicle(model) then
    Notify("Ungültiges Fahrzeugmodell.")
    return
  end

  RequestModel(model)
  while not HasModelLoaded(model) do Wait(0) end

  local ped = PlayerPedId()
  local c = GetEntityCoords(ped)
  local h = GetEntityHeading(ped)

  local veh = CreateVehicle(model, c.x, c.y, c.z + 1.0, h, true, false)
  SetPedIntoVehicle(ped, veh, -1)
  SetEntityAsMissionEntity(veh, true, true)
  SetModelAsNoLongerNeeded(model)
end, false)

RegisterCommand("dv", function()
  if not HasAce("dv") then Notify("Keine Rechte.") return end

  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  if veh == 0 then
    local c = GetEntityCoords(ped)
    veh = GetClosestVehicle(c.x, c.y, c.z, 6.0, 0, 70)
  end

  if veh ~= 0 and DoesEntityExist(veh) then
    SetEntityAsMissionEntity(veh, true, true)
    DeleteVehicle(veh)
  else
    Notify("Kein Fahrzeug gefunden.")
  end
end, false)

RegisterCommand("heal", function(_, args)
  if not HasAce("heal") then Notify("Keine Rechte.") return end
  local ped = PlayerPedId()
  local amount = tonumber(args[1]) or 200
  SetEntityHealth(ped, math.min(amount, 200))
end, false)

RegisterCommand("armor", function(_, args)
  if not HasAce("armor") then Notify("Keine Rechte.") return end
  local ped = PlayerPedId()
  local amount = tonumber(args[1]) or 100
  SetPedArmour(ped, math.max(0, math.min(amount, 100)))
end, false)
