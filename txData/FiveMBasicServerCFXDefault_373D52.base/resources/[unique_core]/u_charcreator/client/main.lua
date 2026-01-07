local creatorOpen = false
local creatorCharId = nil
local creatorSpawn = nil
local lastAppearance = nil
local currentGender = 0

local camHandle = nil
local activeCamMode = 'body'

local genderSwitchInProgress = false
local genderSwitchToken = 0

local CREATOR_POS = vector4(402.919, -996.580, -99.000, 179.94)

local CAMERA = {
  face = { x = 402.92, y = -1000.72, z = -98.45, fov = 10.0 },
  body = { x = 402.92, y = -1000.72, z = -99.01, fov = 30.0 }
}

local function modelFromGender(g)
  if tonumber(g) == 1 then
    return 'mp_f_freemode_01'
  end
  return 'mp_m_freemode_01'
end

local function setModelByName(modelName)
  local hash = GetHashKey(modelName)
  RequestModel(hash)
  while not HasModelLoaded(hash) do Wait(0) end
  SetPlayerModel(PlayerId(), hash)
  SetPedDefaultComponentVariation(PlayerPedId())
  SetModelAsNoLongerNeeded(hash)
end

local function stopCam()
  if camHandle ~= nil then
    RenderScriptCams(false, true, 400, true, true)
    DestroyCam(camHandle, false)
    camHandle = nil
  end
end

local function getLookAt(mode)
  local z = (mode == 'face') and (CREATOR_POS.z + 0.62) or (CREATOR_POS.z + 0.28)
  local y = CREATOR_POS.y - 0.20
  return CREATOR_POS.x + 0.0, y + 0.0, z + 0.0
end

local function startCam(mode)
  local m = CAMERA[mode] and mode or 'body'
  activeCamMode = m

  if camHandle ~= nil then
    RenderScriptCams(false, false, 0, true, true)
    DestroyCam(camHandle, false)
    camHandle = nil
  end

  local cfg = CAMERA[m]
  camHandle = CreateCamWithParams(
    "DEFAULT_SCRIPTED_CAMERA",
    cfg.x + 0.0, cfg.y + 0.0, cfg.z + 0.0,
    0.0, 0.0, 0.0,
    cfg.fov + 0.0,
    false, 0
  )

  SetCamNearClip(camHandle, 0.05)
  SetCamActive(camHandle, true)
  RenderScriptCams(true, false, 0, true, true)

  local lx, ly, lz = getLookAt(m)
  PointCamAtCoord(camHandle, lx, ly, lz)
end

local function buildPalettes()
  local hair = {}
  local makeup = {}

  for i = 0, 63 do
    local r, g, b = GetPedHairRgbColor(i)
    hair[i] = { r = r, g = g, b = b }
  end

  for i = 0, 63 do
    local r, g, b = GetPedMakeupRgbColor(i)
    makeup[i] = { r = r, g = g, b = b }
  end

  return hair, makeup
end

local function getMetaForPed(ped)
  return { style = GetNumberOfPedDrawableVariations(ped, 2) }
end

local function applyHeadBlend(ped, dnaSelection, mix)
  local f1 = tonumber(dnaSelection.face1 or 0) or 0
  local f2 = tonumber(dnaSelection.face2 or 0) or 0
  local f3 = tonumber(dnaSelection.face3 or 0) or 0
  local s1 = tonumber(dnaSelection.skin1 or 0) or 0
  local s2 = tonumber(dnaSelection.skin2 or 0) or 0
  local s3 = tonumber(dnaSelection.skin3 or 0) or 0

  local shapeMix = tonumber(mix.head or 0.5) or 0.5
  local skinMix = tonumber(mix.skin or 0.5) or 0.5
  local thirdMix = tonumber(mix.third or 0.5) or 0.5

  SetPedHeadBlendData(ped, f1, f2, f3, s1, s2, s3, shapeMix, skinMix, thirdMix, false)
end

local function applyFaceFeatures(ped, features)
  if type(features) ~= 'table' then return end
  for i = 0, 19 do
    local v = tonumber(features[i + 1] or features[tostring(i)] or 0.0) or 0.0
    SetPedFaceFeature(ped, i, v)
  end
end

local function applyHair(ped, hair, hairOverlay)
  if type(hair) == 'table' then
    local style = tonumber(hair.style or 0) or 0
    SetPedComponentVariation(ped, 2, style, 0, 0)

    local c = tonumber(hair.color or 0) or 0
    local h = tonumber(hair.highlight or 0) or 0
    SetPedHairColor(ped, c, h)
  end

  if type(hairOverlay) == 'table' then
    local function applyOverlay(overlayId, data, colorType)
      if type(data) ~= 'table' then return end
      local idx = tonumber(data.index or 0) or 0
      local op = tonumber(data.opacity or 0.0) or 0.0
      local col = tonumber(data.color or 0) or 0
      SetPedHeadOverlay(ped, overlayId, idx, op)
      SetPedHeadOverlayColor(ped, overlayId, colorType, col, col)
    end

    applyOverlay(1, hairOverlay.beard, 1)
    applyOverlay(2, hairOverlay.eyebrows, 1)
    applyOverlay(10, hairOverlay.chest, 1)
  end
end

local function applyOverlays(ped, overlays)
  if type(overlays) ~= 'table' then return end
  for _, ov in pairs(overlays) do
    if type(ov) == 'table' then
      local overlayId = tonumber(ov.overlayId or -1)
      if overlayId and overlayId >= 0 then
        local idx = tonumber(ov.index or 0) or 0
        local op = tonumber(ov.opacity or 0.0) or 0.0
        SetPedHeadOverlay(ped, overlayId, idx, op)

        if ov.hasColor then
          local colorType = tonumber(ov.colorType or 0) or 0
          local col = tonumber(ov.color or 0) or 0
          SetPedHeadOverlayColor(ped, overlayId, colorType, col, col)
        end
      end
    end
  end
end

local function applyFace(ped, face)
  if type(face) ~= 'table' then return end
  local eye = tonumber(face.eyeColor or 0) or 0
  SetPedEyeColor(ped, eye)
end

local function sanitizeAppearance(data)
  if type(data) ~= 'table' then return {} end
  data.clothes = nil
  return data
end

local function applyAppearanceData(ped, data)
  if type(data) ~= 'table' then return end
  if data.dnaSelection and data.mix then
    applyHeadBlend(ped, data.dnaSelection, data.mix)
  end
  applyFaceFeatures(ped, data.features)
  applyHair(ped, data.hair, data.hairOverlay)
  applyOverlays(ped, data.overlays)
  applyFace(ped, data.face)
end

local function placeCreatorPed()
  local ped = PlayerPedId()

  RequestCollisionAtCoord(CREATOR_POS.x, CREATOR_POS.y, CREATOR_POS.z)
  SetFocusPosAndVel(CREATOR_POS.x, CREATOR_POS.y, CREATOR_POS.z, 0.0, 0.0, 0.0)
  LoadScene(CREATOR_POS.x, CREATOR_POS.y, CREATOR_POS.z)

  local timeout = GetGameTimer() + 5000
  while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < timeout do
    Wait(0)
  end

  FreezeEntityPosition(ped, false)
  SetEntityCollision(ped, true, true)
  SetEntityVisible(ped, true, false)
  SetEntityAlpha(ped, 255, false)

  SetEntityCoordsNoOffset(ped, CREATOR_POS.x + 0.0, CREATOR_POS.y + 0.0, CREATOR_POS.z + 0.0, false, false, false)
  SetEntityHeading(ped, CREATOR_POS.w + 0.0)

  for _ = 1, 10 do
    PlaceObjectOnGroundProperly(ped)
    Wait(0)
  end

  ClearPedTasksImmediately(ped)
  FreezeEntityPosition(ped, true)
end

RegisterNetEvent('u_charcreator:open')
AddEventHandler('u_charcreator:open', function(payload)
  creatorCharId = payload.charId
  creatorSpawn = payload.spawn
  creatorOpen = true
  lastAppearance = nil
  currentGender = tonumber(payload.gender) or 0

  genderSwitchInProgress = false
  genderSwitchToken = 0

  DoScreenFadeOut(300)
  while not IsScreenFadedOut() do Wait(0) end

  setModelByName(modelFromGender(currentGender))
  Wait(0)

  placeCreatorPed()
  startCam('body')

  DoScreenFadeIn(600)

  SetNuiFocus(true, true)
  SendNUIMessage({ action = 'open', gender = currentGender })

  local hairPal, makeupPal = buildPalettes()
  SendNUIMessage({ type = 'cc:palette', hair = hairPal, makeup = makeupPal })

  local ped = PlayerPedId()
  local hairMax = getMetaForPed(ped)
  SendNUIMessage({ type = 'cc:meta', hairMax = hairMax })
end)

RegisterNetEvent('u_charcreator:deny')
AddEventHandler('u_charcreator:deny', function()
  creatorOpen = false
  genderSwitchInProgress = false
  SetNuiFocus(false, false)
  SendNUIMessage({ action = 'close' })
  FreezeEntityPosition(PlayerPedId(), false)
  stopCam()
  ClearFocus()
end)

RegisterNetEvent('u_charcreator:spawnAndApply')
AddEventHandler('u_charcreator:spawnAndApply', function(payload)
  TriggerEvent('u_multichar:spawn', payload.spawn)
  Wait(0)
  TriggerServerEvent('u_charcreator:requestSkin', payload.charId)
end)

RegisterNetEvent('u_charcreator:applySkin')
AddEventHandler('u_charcreator:applySkin', function(row)
  if not row then return end

  local model = tostring(row.model or 'mp_m_freemode_01')
  setModelByName(model)
  Wait(0)

  local ped = PlayerPedId()
  local appearance = {}

  if row.appearance and type(row.appearance) == 'string' then
    appearance = json.decode(row.appearance) or {}
  end

  appearance = sanitizeAppearance(appearance)
  applyAppearanceData(ped, appearance)
end)

RegisterNetEvent('u_charcreator:saveResult')
AddEventHandler('u_charcreator:saveResult', function(ok, reason)
  SendNUIMessage({ type = 'cc:saveResult', ok = ok, reason = reason })
  if not ok then return end

  SetNuiFocus(false, false)
  SendNUIMessage({ action = 'close' })

  stopCam()
  ClearFocus()

  local ped = PlayerPedId()
  FreezeEntityPosition(ped, false)

  if creatorSpawn and creatorCharId then
    TriggerEvent('u_multichar:spawn', creatorSpawn)
    Wait(0)
    TriggerServerEvent('u_charcreator:requestSkin', creatorCharId)
  end

  creatorOpen = false
  genderSwitchInProgress = false
end)

RegisterNUICallback('cc_requestMeta', function(_, cb)
  local ped = PlayerPedId()
  cb({ hairMax = getMetaForPed(ped) })
end)

RegisterNUICallback('cc_setGender', function(data, cb)
  if not creatorOpen then cb({ ok = false }); return end
  if genderSwitchInProgress then
    cb({ ok = true, gender = currentGender })
    return
  end

  local g = tonumber(data.gender)
  if g == nil then cb({ ok = false }); return end

  genderSwitchInProgress = true
  genderSwitchToken = genderSwitchToken + 1
  local token = genderSwitchToken

  currentGender = g
  SendNUIMessage({ type = 'cc:gender', gender = currentGender, locked = true })
  cb({ ok = true, gender = currentGender })

  CreateThread(function()
    Wait(80)
    if not creatorOpen or token ~= genderSwitchToken then
      genderSwitchInProgress = false
      return
    end

    local keepMode = activeCamMode
    setModelByName(modelFromGender(currentGender))
    Wait(0)

    if not creatorOpen or token ~= genderSwitchToken then
      genderSwitchInProgress = false
      return
    end

    placeCreatorPed()
    startCam(keepMode)

    if type(lastAppearance) == 'table' then
      applyAppearanceData(PlayerPedId(), lastAppearance)
    end

    SendNUIMessage({ type = 'cc:gender', gender = currentGender, locked = false })
    genderSwitchInProgress = false
  end)
end)

RegisterNUICallback('cc_update', function(data, cb)
  if not creatorOpen then cb({ ok = false }); return end
  data = sanitizeAppearance(data)
  lastAppearance = data
  applyAppearanceData(PlayerPedId(), data)
  cb({ ok = true })
end)

RegisterNUICallback('cc_finish', function(_, cb)
  if not creatorOpen or not creatorCharId or type(lastAppearance) ~= 'table' then
    cb({ ok = false })
    return
  end

  local payload = {
    model = modelFromGender(currentGender),
    appearance = sanitizeAppearance(lastAppearance)
  }

  TriggerServerEvent('u_charcreator:saveSkin', creatorCharId, payload)
  cb({ ok = true })
end)

RegisterNUICallback('cc_close', function(_, cb)
  SetNuiFocus(false, false)
  SendNUIMessage({ action = 'close' })

  stopCam()
  ClearFocus()

  local ped = PlayerPedId()
  FreezeEntityPosition(ped, false)

  creatorOpen = false
  genderSwitchInProgress = false
  cb({ ok = true })
end)

exports('ApplySkinToPed', function(ped, row)
  if not ped or ped == 0 then return end
  if not DoesEntityExist(ped) then return end
  if not row then return end

  local appearance = {}
  if row.appearance and type(row.appearance) == 'string' then
    appearance = json.decode(row.appearance) or {}
  end

  appearance = sanitizeAppearance(appearance)
  applyAppearanceData(ped, appearance)
end)
