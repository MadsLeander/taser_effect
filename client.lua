local stunnedCache = {}
local stunnedStack = 0

local function FadeOutStunnedTimecycle(from)
    local strength = from
    local increments = from / 100

    for _i = 1, 100 do
        Wait(50)
        strength = strength - increments

        if stunnedStack >= 1 then
            return
        end

        if strength <= 0 then
            break
        end

        SetTimecycleModifierStrength(strength)
    end

    SetTimecycleModifierStrength(0.0)
    ClearTimecycleModifier()
end

local function DoTaserEffect()
    stunnedStack = stunnedStack + 1
    SetTimecycleModifierStrength(0.5) -- The strength of the timecycle
    SetTimecycleModifier("dont_tazeme_bro") -- Other timecycles can for example be: hud_def_desat_Trevor, dont_tazeme_bro_b, drug_wobbly etc.
    -- ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 0.25) -- Uncomment this if you want the camera to shake (remember to do it below aswell)

    Wait(8000) -- Edit the length of the effect here. 8000 = 8 seconds
    stunnedStack = stunnedStack - 1
    if stunnedStack == 0 then
        FadeOutStunnedTimecycle(0.5)
        -- StopGameplayCamShaking(false) -- Uncomment this if you want the camera to shake
    end
end

-- Use game events to avoid unnecessary threads/loops
AddEventHandler('gameEventTriggered', function(event, args)
    if event == "CEventNetworkEntityDamage" then
        local playerPed = PlayerPedId()
        if playerPed == args[1] then
            local attacker = args[2]
            local weaponHash = args[7]

            -- If the attacker exists, and the weapon was WEAPON_STUNGUN or WEAPON_ELECTRIC_FENCE
            if attacker ~= -1 and (weaponHash == 911657153 or weaponHash == -1833087301) then
                -- Needed as weaponHash does not guarantee that we actually were stunned, and IsPedBeingStunned doesn't return true before a frame after beeing stunned
                SetTimeout(50, function()
                    local gameTimer = GetGameTimer()
                    -- If the player was stunned by the same source less them 2.8 seconds ago then ignore, this is to not spam the event when taking fall damage while beeing stunned
                    if stunnedCache[attacker] and stunnedCache[attacker] + 2800 > gameTimer then
                        return
                    end

                    if IsPedBeingStunned(playerPed, 0) then
                        stunnedCache[attacker] = gameTimer
                        DoTaserEffect()
                    end
                end)
            end
        end
    end
end)
