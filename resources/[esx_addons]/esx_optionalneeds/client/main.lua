local IsAlreadyDrunk = false
local DrunkLevel     = -1

function EthylicComa(playerPed)
  SetEntityHealth(playerPed, 0)
  LocalPlayer.state:set('deathCause', 'ethylic_coma', true)
end

function Drunk(level, start)
  
  CreateThread(function()

    local playerPed = PlayerPedId()

    if start then
      DoScreenFadeOut(800)
      Wait(1000)
    end

    if level == -1 then

      ResetPedMovementClipset(playerPed)

    elseif level == 0 then

      RequestAnimSet("move_m@drunk@slightlydrunk")
      
      while not HasAnimSetLoaded("move_m@drunk@slightlydrunk") do
        Wait(0)
      end

      SetPedMovementClipset(playerPed, "move_m@drunk@slightlydrunk", true)

    elseif level == 1 then

      RequestAnimSet("move_m@drunk@moderatedrunk")
      
      while not HasAnimSetLoaded("move_m@drunk@moderatedrunk") do
        Wait(0)
      end

      SetPedMovementClipset(playerPed, "move_m@drunk@moderatedrunk", true)

    elseif level == 2 then

      RequestAnimSet("move_m@drunk@verydrunk")
      
      while not HasAnimSetLoaded("move_m@drunk@verydrunk") do
        Wait(0)
      end

      SetPedMovementClipset(playerPed, "move_m@drunk@verydrunk", true)

    elseif level == 3 then

      EthylicComa(playerPed)

    end

    SetTimecycleModifier("spectator5")
    SetPedMotionBlur(playerPed, true)
    SetPedIsDrunk(playerPed, true)

    if start then
      DoScreenFadeIn(800)
    end

  end)

end

function Reality()

  CreateThread(function()

    local playerPed = PlayerPedId()

    DoScreenFadeOut(800)
    Wait(1000)

    ClearTimecycleModifier()
    ResetScenarioTypesEnabled()
    ResetPedMovementClipset(playerPed, 0)
    SetPedIsDrunk(playerPed, false)
    SetPedMotionBlur(playerPed, false)

    DoScreenFadeIn(800)

  end)

end

AddEventHandler('esx_status:loaded', function(status)

  TriggerEvent('esx_status:registerStatus', 'drunk', 0, '#8F15A5', 
    function(status)
      if status.val > 0 then
        return true
      else
        return false
      end
    end,
    function(status)
      status.remove(0.005)
    end
  )

	CreateThread(function()

		while true do

			Wait(Config.TickTime)

			TriggerEvent('esx_status:getStatus', 'drunk', function(status)

				if status.val > 0 then
					
          local start = true

          if IsAlreadyDrunk then
            start = false
          end

          local level = -1

          if status.val <= 0.2 then
            level = -1
          elseif status.val <= 0.5 then
            level = 0
          elseif status.val <= 0.8 then
            level = 1
          elseif status.val <= 3.0 then
            level = 2
          else
            level = 3
          end

          if level ~= DrunkLevel then
            Drunk(level, start)
          end

          IsAlreadyDrunk = true
          DrunkLevel     = level
				end

				if status.val == 0 then
          
          if IsAlreadyDrunk then
            Reality()
          end

          IsAlreadyDrunk = false
          DrunkLevel     = -1

				end

			end)

		end

	end)

end)