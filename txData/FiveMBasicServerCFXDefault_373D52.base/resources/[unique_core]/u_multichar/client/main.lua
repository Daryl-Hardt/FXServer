local uiOpen = false
local tracking = false
local charCam = nil
local currentCharId = nil

local scenePeds = {}
local selectedChar = nil
local cachedCanCreate = false

local CAM_POS = vector3(-753.533, 316.482, 221.855)
local CAM_ROT = vector3(0.0, 0.0, 48.67)
local CAM_FOV = 60.0

local SEATS = {
  vector4(-757.821, 317.693, 221.376, 269.12),
  vector4(-757.808, 319.480, 221.376, 276.03),
  vector4(-757.817, 319.231, 221.376, 272.49),
  vector4(-757.826, 319.938, 221.376, 269.87),
  vector4(-757.479, 320.256, 221.376, 179.85),
  vector4(-756.788, 320.228, 221.376, 186.11),
  vector4(-755.964, 320.250, 221.376, 185.39),
  vector4(-755.322, 320.259, 221.376, 179.41)
}

local hoveredPed = 0
local hoveredCharId = nil

local function CleanupPeds()
  for _, p in pairs(scenePeds) do
    if DoesEntityExist(p.ped) then
      DeleteEntity(p.ped)
    end
  end
  scenePeds = {}
end

local function StartSceneCam()
  if charCam ~= nil then
    RenderScriptCams(false, false, 0, true, true)
    DestroyCam(charCam, false)
    charCam = nil
  end

  charCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
  SetCamCoord(charCam, CAM_POS.x, CAM_POS.y, CAM_POS.z)
  SetCamRot(charCam, CAM_ROT.x, CAM_ROT.y, CAM_ROT.z, 2)
  SetCamFov(charCam, CAM_FOV)
  SetCamActive(charCam, true)
  RenderScriptCams(true, false, 0, true, true)
end

local function StopSceneCam()
  if charCam ~= nil then
    RenderScriptCams(false, true, 600, true, true)
    DestroyCam(charCam, false)
    charCam = nil
  end
end

local function EnterSceneAt(seat)
  local ped = PlayerPedId()

  ShutdownLoadingScreenNui()
  ShutdownLoadingScreen()

  DoScreenFadeOut(250)
  local t = GetGameTimer() + 4000
  while not IsScreenFadedOut() and GetGameTimer() < t do Wait(0) end

  FreezeEntityPosition(ped, true)
  SetEntityVisible(ped, false, false)

  SetEntityCoordsNoOffset(ped, seat.x, seat.y, seat.z, false, false, false)
  SetEntityHeading(ped, seat.w)

  RequestCollisionAtCoord(seat.x, seat.y, seat.z)
  SetFocusPosAndVel(seat.x, seat.y, seat.z, 0.0, 0.0, 0.0)
  LoadScene(seat.x, seat.y, seat.z)

  local interior = GetInteriorAtCoords(seat.x, seat.y, seat.z)
  if interior ~= 0 then
    PinInteriorInMemory(interior)
    LoadInterior(interior)

    local readyTimeout = GetGameTimer() + 5000
    while not IsInteriorReady(interior) and GetGameTimer() < readyTimeout do
      Wait(0)
    end
  end

  local timeout = GetGameTimer() + 5000
  while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < timeout do
    Wait(0)
  end

  StartSceneCam()
  DoScreenFadeIn(400)
end

local function LoadModel(name)
  local hash = GetHashKey(name)
  RequestModel(hash)
  while not HasModelLoaded(hash) do Wait(0) end
  return hash
end

local function SpawnSeatPed(modelName, seat)
  local hash = LoadModel(modelName)
  local ped = CreatePed(4, hash, seat.x, seat.y, seat.z, seat.w, false, true)
  SetModelAsNoLongerNeeded(hash)

  SetEntityInvincible(ped, true)
  SetBlockingOfNonTemporaryEvents(ped, true)
  FreezeEntityPosition(ped, true)

  TaskStartScenarioAtPosition(ped, "PROP_HUMAN_SEAT_CHAIR", seat.x, seat.y, seat.z, seat.w, 0, true, true)

  return ped
end

local function RaycastEntity(dist)
  local camCoord = GetGameplayCamCoord()
  local camRot = GetGameplayCamRot(2)
  local rx = math.rad(camRot.x)
  local rz = math.rad(camRot.z)

  local dir = vector3(-math.sin(rz) * math.cos(rx), math.cos(rz) * math.cos(rx), math.sin(rx))
  local dest = camCoord + dir * dist

  local ray = StartShapeTestRay(camCoord.x, camCoord.y, camCoord.z, dest.x, dest.y, dest.z, 12, PlayerPedId(), 0)
  local _, hit, _, _, ent = GetShapeTestResult(ray)
  if hit ~= 1 then return 0 end
  return ent or 0
end

local function FindCharByPed(ped)
  for _, entry in pairs(scenePeds) do
    if entry.ped == ped then
      return entry.char
    end
  end
  return nil
end

local function DrawArrowMarkerAbovePed(ped)
  if ped == 0 or not DoesEntityExist(ped) then return end
  local x, y, z = table.unpack(GetEntityCoords(ped))
  DrawMarker(2, x, y, z + 1.15, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.22, 0.22, 0.22, 255, 0, 85, 200, false, true, 2, false, nil, nil, false)
end

local function RotationToDirection(rot)
  local z = math.rad(rot.z)
  local x = math.rad(rot.x)
  local num = math.abs(math.cos(x))
  return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

local function Cross(a, b)
  return vector3(
    a.y * b.z - a.z * b.y,
    a.z * b.x - a.x * b.z,
    a.x * b.y - a.y * b.x
  )
end

local function Normalize(v)
  local len = math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
  if len == 0.0 then return vector3(0.0, 0.0, 0.0) end
  return v / len
end

local function CursorRaycast(dist)
  local px, py = GetNuiCursorPosition()
  local w, h = GetActiveScreenResolution()
  if w <= 0 or h <= 0 then return 0 end

  -- 0..1
  local sx = px / w
  local sy = py / h

  local camPos = GetFinalRenderedCamCoord()
  local camRot = GetFinalRenderedCamRot(2)
  local fov = GetFinalRenderedCamFov()

  -- Camera basis
  local forward = Normalize(RotationToDirection(camRot))
  local worldUp = vector3(0.0, 0.0, 1.0)
  local right = Normalize(Cross(forward, worldUp))
  local up = Normalize(Cross(right, forward))

  -- Screen space to camera ray
  local aspect = w / h
  local tanFov = math.tan(math.rad(fov) / 2.0)

  local dx = (sx * 2.0 - 1.0) * aspect * tanFov
  local dy = (1.0 - sy * 2.0) * tanFov

  local dir = Normalize(forward + right * dx + up * dy)

  local from = camPos
  local to = camPos + dir * dist

  local ray = StartShapeTestRay(from.x, from.y, from.z, to.x, to.y, to.z, 12, PlayerPedId(), 0)
  local _, hit, _, _, ent = GetShapeTestResult(ray)
  if hit ~= 1 then return 0 end
  return ent or 0
end

local function SelectChar(ch)
  if not ch then return end
  selectedChar = ch
  currentCharId = tonumber(ch.id)
  SendOpenUI(ch, cachedCanCreate)
end

local function DrawArrowMarkerAbovePed(ped)
  if ped == 0 or not DoesEntityExist(ped) then return end

  local x, y, z = table.unpack(GetEntityCoords(ped))
  local height = 1.15
  local mx, my, mz = x, y, z + height

  DrawMarker(
    2,
    mx, my, mz,
    0.0, 0.0, 0.0,
    0.0, 0.0, 0.0,
    0.22, 0.22, 0.22,
    255, 0, 85, 200,
    false, true, 2, false, nil, nil, false
  )
end

local function SendOpenUI(char, canCreate)
  uiOpen = true
  SetNuiFocus(true, true)
  SetNuiFocusKeepInput(true)

  SendNUIMessage({
    action = 'open',
    canCreate = canCreate == true,
    character = {
      id = char.id,
      firstname = char.firstname,
      lastname = char.lastname,
      birthdate = char.birthdate,
      job = char.job,
      position = char.position
    }
  })
end

RegisterNetEvent('u_multichar:sceneData')
AddEventHandler('u_multichar:sceneData', function(data)
  CreateThread(function()
    local ok, err = pcall(function()
      data = data or {}
      local chars = data.characters or {}
      local maxChars = tonumber(data.maxChars) or 0
      cachedCanCreate = (#chars < maxChars)

      CleanupPeds()

      local anchor = SEATS[1] or vector4(0.0, 0.0, 0.0, 0.0)
      EnterSceneAt(anchor)

      local count = math.min(#chars, #SEATS)
      for i = 1, count do
        local ch = chars[i]
        local skin = ch.skin

        local model = 'mp_m_freemode_01'
        if skin and skin.model and tostring(skin.model) ~= '' then
          model = tostring(skin.model)
        else
          if tonumber(ch.gender) == 1 then model = 'mp_f_freemode_01' end
        end

        local ped = SpawnSeatPed(model, SEATS[i])

        if skin and skin.appearance then
          exports['u_charcreator']:ApplySkinToPed(ped, skin)
        end

        scenePeds[#scenePeds + 1] = { ped = ped, char = ch }
      end

      if #chars > 0 then
        selectedChar = chars[1]
        currentCharId = tonumber(selectedChar.id)
        SendOpenUI(selectedChar, cachedCanCreate)
      else
        selectedChar = nil
        currentCharId = nil
        uiOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'openEmpty', canCreate = cachedCanCreate })
      end
    end)

    if not ok then
      print('[u_multichar] sceneData error: ' .. tostring(err))
      DoScreenFadeIn(0)
      local ped = PlayerPedId()
      FreezeEntityPosition(ped, false)
      SetEntityVisible(ped, true, false)
      ClearFocus()
    end
  end)
end)

RegisterNUICallback('play', function(data, cb)
  local id = tonumber(data and data.id) or (selectedChar and tonumber(selectedChar.id)) or nil
  if id then
    currentCharId = id
    TriggerServerEvent('u_multichar:selectCharacter', { id = id })
  end
  cb('ok')
end)

RegisterNUICallback('create', function(_, cb)
  TriggerServerEvent('u_multichar:beginCreate')
  cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
  uiOpen = false
  SetNuiFocus(false, false)
  SetNuiFocusKeepInput(false)
  SendNUIMessage({ action = 'close' })
  cb('ok')
end)

CreateThread(function()
  while true do
    if next(scenePeds) ~= nil and uiOpen then
      local ent = CursorRaycast(50.0)

      if ent ~= 0 then
        local ch = FindCharByPed(ent)
        if ch then
          hoveredPed = ent
          hoveredCharId = tonumber(ch.id)
          DrawArrowMarkerAbovePed(ent)

          local cx, cy = GetNuiCursorPosition()
          local w, h = GetActiveScreenResolution()
          local ny = (h > 0) and (cy / h) or 1.0

          if IsControlJustPressed(0, 24) and ny < 0.78 then
            selectedChar = ch
            currentCharId = tonumber(ch.id)
            SendOpenUI(ch, cachedCanCreate)
          end
        else
          hoveredPed = 0
          hoveredCharId = nil
        end
      else
        hoveredPed = 0
        hoveredCharId = nil
      end
    end

    Wait(0)
  end
end)

RegisterNetEvent('u_multichar:spawn')
AddEventHandler('u_multichar:spawn', function(data)
  if not data then return end

  CleanupPeds()
  StopSceneCam()

  uiOpen = false
  SetNuiFocus(false, false)
  SetNuiFocusKeepInput(false)
  SendNUIMessage({ action = 'close' })

  local ped = PlayerPedId()
  SetEntityCoords(ped, data.x + 0.0, data.y + 0.0, data.z + 0.0, false, false, false, true)
  SetEntityHeading(ped, data.heading + 0.0)

  FreezeEntityPosition(ped, false)
  SetEntityVisible(ped, true, false)
  ClearFocus()

  if currentCharId then
    TriggerServerEvent('u_charcreator:requestSkin', currentCharId)
  end

  tracking = true
  CreateThread(function()
    while tracking do
      local p = PlayerPedId()
      local px, py, pz = table.unpack(GetEntityCoords(p))
      local ph = GetEntityHeading(p)
      TriggerServerEvent('u_core:updatePosition', px, py, pz, ph)
      Wait(5000)
    end
  end)
end)

AddEventHandler('onClientResourceStart', function(resName)
  if resName ~= GetCurrentResourceName() then return end
  CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Wait(0) end
    TriggerServerEvent('u_multichar:open')
  end)
end)
