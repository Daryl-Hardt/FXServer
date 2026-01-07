local radarAlwaysOff = true
local hudAlwaysOff = false

local function ApplyHudState(inVehicle)
  if radarAlwaysOff then
    DisplayRadar(inVehicle)
  end

  if hudAlwaysOff then
    DisplayHud(false)
  end
end

CreateThread(function()
  while true do
    local ped = PlayerPedId()
    local inVehicle = IsPedInAnyVehicle(ped, false)

    ApplyHudState(inVehicle)

    if inVehicle then
      Wait(250)
    else
      Wait(250)
    end
  end
end)
