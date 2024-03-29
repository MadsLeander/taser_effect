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

local function DoTaserEffect(effectLength)
    stunnedStack = stunnedStack + 1
    SetTimecycleModifierStrength(Config.TimecycleStrength)
    SetTimecycleModifier("dont_tazeme_bro")

    if Config.CameraShake then
        ShakeGameplayCam(Config.CameraShakeName, Config.CameraShakeIntensity)
    end

    Wait(effectLength)
    stunnedStack = stunnedStack - 1
    if stunnedStack == 0 then
        FadeOutStunnedTimecycle(0.5)
        if Config.CameraShake then
            StopGameplayCamShaking(false)
        end
    end
end

local function OnLocalPlayerStunned(playerPed, attacker)
    -- This usually won't effect the player ped the first time the get stunned.
    local groundTime = Config.MinGroundTime == Config.MaxGroundTime and Config.MinGroundTime or math.random(Config.MinGroundTime, Config.MaxGroundTime)
    SetPedMinGroundTimeForStungun(playerPed, groundTime)

    -- Needed as weaponHash does not guarantee that we actually were stunned, and IsPedBeingStunned doesn't return true before a frame after beeing stunned
    SetTimeout(50, function()
        local gameTimer = GetGameTimer()
        -- If the player was stunned by the same source less them 2.8 seconds ago then ignore, this is to not spam the event when taking fall damage while beeing stunned
        if stunnedCache[attacker] and stunnedCache[attacker] + 2800 > gameTimer then
            return
        end

        if IsPedBeingStunned(playerPed, 0) then
            stunnedCache[attacker] = gameTimer
            DoTaserEffect(groundTime)
        end
    end)
end

local function OnNPCStunned(args)
    local ped = args[1]

    if Config.DisableNPCWrithe then
        SetPedConfigFlag(ped, 281, true) -- Disable Writhe
    end

    if Config.NPCDropWeapon then
        Wait(400)
        local visible, _currentWeapon = GetCurrentPedWeapon(ped, true)
        if visible then
            SetPedDropsWeapon(ped)
        end
    end
end

-- Use game events to avoid unnecessary threads/loops
AddEventHandler('gameEventTriggered', function(event, args)
    if event == "CEventNetworkEntityDamage" then
        local playerPed = PlayerPedId()
        local attacker = args[2]
        local weaponHash = args[7]

        if playerPed == args[1] and attacker ~= -1 and (weaponHash == 911657153 or weaponHash == -1833087301) then
            OnLocalPlayerStunned(playerPed, attacker)
        elseif IsEntityAPed(args[1]) and not IsPedAPlayer(args[1]) and NetworkHasControlOfEntity(args[1]) and (weaponHash == 911657153 or weaponHash == -1833087301) then
            OnNPCStunned(args)
        end
    end
end)
