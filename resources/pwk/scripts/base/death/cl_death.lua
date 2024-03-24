local firstSpawn = true

local isDead, isSearched, medic = false, false, 0

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
  ESX.PlayerLoaded = false
  firstSpawn = true
end)

AddEventHandler('esx:onPlayerSpawn', function()
  isDead = false
  ClearTimecycleModifier()
  SetPedMotionBlur(PlayerPedId(), false)
  ClearExtraTimecycleModifier()
  EndDeathCam()
  if firstSpawn then
    firstSpawn = false

    if Config_death.SaveDeathStatus then
      while not ESX.PlayerLoaded do
        Wait(1000)
      end

      ESX.TriggerServerCallback('pwk_death:getDeathStatus', function(shouldDie)
        if shouldDie then
          Wait(1000)
          SetEntityHealth(PlayerPedId(), 0)
        end
      end)
    end
  end
end)

function OnPlayerDeath()
  isDead = true
  ESX.CloseContext()
  ClearTimecycleModifier()
  SetTimecycleModifier("REDMIST_blend")
  SetTimecycleModifierStrength(0.7)
  SetExtraTimecycleModifier("fp_vig_red")
  SetExtraTimecycleModifierStrength(1.0)
  SetPedMotionBlur(PlayerPedId(), true)
  TriggerServerEvent('pwk_death:setDeathStatus', true)
  StartDeathTimer()
  StartDeathCam()
  StartDistressSignal()
end

function StartDistressSignal()
    CreateThread(function()
        local timer = Config_death.BleedoutTimer

        while timer > 0 and isDead do
            Wait(0)
            timer = timer - 30

            SetTextFont(4)
            SetTextScale(0.5, 0.5)
            SetTextColour(200, 50, 50, 255)
            SetTextDropshadow(0.1, 3, 27, 27, 255)
            BeginTextCommandDisplayText('STRING')
            AddTextComponentSubstringPlayerName(Config_death.Locales['distress_send'])
            EndTextCommandDisplayText(0.40, 0.48)

            if IsControlJustReleased(0, 47) then
                SendDistressSignal()
                break
            end
        end
    end)
end

function SendDistressSignal()
  local playerPed = PlayerPedId()
  local coords = GetEntityCoords(playerPed)

  ESX.ShowNotification(Config_death.Locales['distress_sent'])
  TriggerServerEvent('pwk_death:onPlayerDistress')
end

function DrawGenericTextThisFrame()
    SetTextFont(4)
    SetTextScale(0.5, 0.5)
    SetTextColour(200, 50, 50, 255)
    SetTextDropshadow(0.1, 3, 27, 27, 255)
    SetTextOutline()
    SetTextCentre(true)
end

function StartDeathTimer()
    local canPayFine = false

    if Config_death.EarlyRespawnFine then
        ESX.TriggerServerCallback('pwk_death:checkBalance', function(canPay)
            canPayFine = canPay
        end)
    end

    local earlySpawnTimer = ESX.Math.Round(Config_death.EarlyRespawnTimer / 1000)
    local bleedoutTimer = ESX.Math.Round(Config_death.BleedoutTimer / 1000)

    CreateThread(function()
        -- early respawn timer
        while earlySpawnTimer > 0 and isDead do
            Wait(1000)

            if earlySpawnTimer > 0 then
                earlySpawnTimer = earlySpawnTimer - 1
            end
            end

            -- bleedout timer
            while bleedoutTimer > 0 and isDead do
            Wait(1000)

            if bleedoutTimer > 0 then
                bleedoutTimer = bleedoutTimer - 1
            end
        end
    end)

    CreateThread(function()
        local text

        -- early respawn timer
        while earlySpawnTimer > 0 and isDead do
            Wait(0)
            text = Config_death.Locales['respawn_available_in'] .. earlySpawnTimer .. ' sec'

            DrawGenericTextThisFrame()
            BeginTextCommandDisplayText('STRING')
            AddTextComponentSubstringPlayerName(text)
            EndTextCommandDisplayText(0.51, 0.53)
        end

        -- bleedout timer
        while bleedoutTimer > 0 and isDead do
            Wait(0)
            text = Config_death.Locales['respawn_bleedout_in'] .. bleedoutTimer .. ' sec'

            if not Config_death.EarlyRespawnFine then
                text = text .. '\n' ..Config_death.Locales['respawn_bleedout_prompt']

                if IsControlPressed(0, 38)then
                    RemoveItemsAfterRPDeath()
                    break
                end
            elseif Config_death.EarlyRespawnFine and canPayFine then
                text = text .. '\n' .. Config_death.Locales['respawn_bleedout_fine']

                if IsControlPressed(0, 38) then
                    TriggerServerEvent('pwk_death:payFine')
                    RemoveItemsAfterRPDeath()
                    break
                end
            end

            DrawGenericTextThisFrame()
            BeginTextCommandDisplayText('STRING')
            AddTextComponentSubstringPlayerName(text)
            EndTextCommandDisplayText(0.51, 0.53)
        end

        if bleedoutTimer < 1 and isDead then
            RemoveItemsAfterRPDeath()
        end
    end)
end

function GetClosestRespawnPoint()
  local plyCoords = GetEntityCoords(PlayerPedId())
  local closestDist, closestHospital 

  for i=1, #Config_death.RespawnPoints do 
      local dist = #(plyCoords - Config_death.RespawnPoints[i].coords) 

      if not closestDist or dist <= closestDist then
          closestDist, closestHospital = dist, Config_death.RespawnPoints[i] 
      end 
  end 
  
  return closestHospital
end

function RemoveItemsAfterRPDeath()
  TriggerServerEvent('pwk_death:setDeathStatus', false)

  CreateThread(function()
    ESX.TriggerServerCallback('pwk_death:removeItemsAfterRPDeath', function()
      local ClosestHospital = GetClosestRespawnPoint()

      ESX.SetPlayerData('loadout', {})

      DoScreenFadeOut(800)
      RespawnPed(PlayerPedId(), ClosestHospital.coords, ClosestHospital.heading)
      while not IsScreenFadedOut() do
        Wait(0)
      end
      DoScreenFadeIn(800)
    end)
  end)
end

function RespawnPed(ped, coords, heading)
  SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
  NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
  SetPlayerInvincible(ped, false)
  ClearPedBloodDamage(ped)

  TriggerEvent('esx_basicneeds:resetStatus')
  TriggerServerEvent('esx:onPlayerSpawn')
  TriggerEvent('esx:onPlayerSpawn')
  TriggerEvent('playerSpawned')
end

AddEventHandler('esx:onPlayerDeath', function(data)
  OnPlayerDeath()
end)

RegisterNetEvent('pwk_death:revive')
AddEventHandler('pwk_death:revive', function()
  local playerPed = PlayerPedId()
  local coords = GetEntityCoords(playerPed)
  TriggerServerEvent('pwk_death:setDeathStatus', false)

  DoScreenFadeOut(800)

  while not IsScreenFadedOut() do
    Wait(50)
  end

  local formattedCoords = {x = ESX.Math.Round(coords.x, 1), y = ESX.Math.Round(coords.y, 1), z = ESX.Math.Round(coords.z, 1)}

  RespawnPed(playerPed, formattedCoords, 0.0)
  isDead = false
  ClearTimecycleModifier()
  SetPedMotionBlur(playerPed, false)
  ClearExtraTimecycleModifier()
  EndDeathCam()
  DoScreenFadeIn(800)
end)

local cam = nil

local isDead = false

local angleY = 0.0

local angleZ = 0.0

-------------------------------------------------------

-----------------DEATH CAMERA FUNCTIONS ---------------

--------------------------------------------------------

-- initialize camera

function StartDeathCam()
  ClearFocus()
  local playerPed = PlayerPedId()
  cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", GetEntityCoords(playerPed), 0, 0, 0, GetGameplayCamFov())
  SetCamActive(cam, true)
  RenderScriptCams(true, true, 1000, true, false)
end

-- destroy camera

function EndDeathCam()
  ClearFocus()
  RenderScriptCams(false, false, 0, true, false)
  DestroyCam(cam, false)
  cam = nil
end
-- process camera controls
function ProcessCamControls()
  local playerPed = PlayerPedId()
  local playerCoords = GetEntityCoords(playerPed)
  -- disable 1st person as the 1st person camera can cause some glitches
  DisableFirstPersonCamThisFrame()
  -- calculate new position
  local newPos = ProcessNewPosition()
  SetFocusArea(newPos.x, newPos.y, newPos.z, 0.0, 0.0, 0.0)
  -- set coords of cam
  SetCamCoord(cam, newPos.x, newPos.y, newPos.z)
  -- set rotation
  PointCamAtCoord(cam, playerCoords.x, playerCoords.y, playerCoords.z + 0.5)
end

function ProcessNewPosition()
  local mouseX = 0.0
  local mouseY = 0.0
  -- keyboard
  if (IsInputDisabled(0)) then
    -- rotation
    mouseX = GetDisabledControlNormal(1, 1) * 8.0

    mouseY = GetDisabledControlNormal(1, 2) * 8.0
    -- controller
  else
    mouseX = GetDisabledControlNormal(1, 1) * 1.5

    mouseY = GetDisabledControlNormal(1, 2) * 1.5
  end

  angleZ = angleZ - mouseX -- around Z axis (left / right)

  angleY = angleY + mouseY -- up / down
  -- limit up / down angle to 90°

  if (angleY > 89.0) then
    angleY = 89.0
  elseif (angleY < -89.0) then
    angleY = -89.0
  end
  local pCoords = GetEntityCoords(PlayerPedId())
  local behindCam = {x = pCoords.x + ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * (5.5 + 0.5),

                     y = pCoords.y + ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * (5.5 + 0.5),

                     z = pCoords.z + ((Sin(angleY))) * (5.5 + 0.5)}
  local rayHandle = StartShapeTestRay(pCoords.x, pCoords.y, pCoords.z + 0.5, behindCam.x, behindCam.y, behindCam.z, -1, PlayerPedId(), 0)

  local a, hitBool, hitCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

  local maxRadius = 1.9
  if (hitBool and Vdist(pCoords.x, pCoords.y, pCoords.z + 0.5, hitCoords) < 5.5 + 0.5) then
    maxRadius = Vdist(pCoords.x, pCoords.y, pCoords.z + 0.5, hitCoords)
  end

  local offset = {x = ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * maxRadius,
                  y = ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * maxRadius, z = ((Sin(angleY))) * maxRadius}

  local pos = {x = pCoords.x + offset.x, y = pCoords.y + offset.y, z = pCoords.z + offset.z}

  return pos
end