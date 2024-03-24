Config = {
    Locale = GetConvar('esx:locale', 'fr'),
    HudResource = 'esx_hud',
    Cruise = {
        Enable = true,
        Key = "CAPITAL",
        Export = function (state)
            exports[Config.HudResource]:CruiseControlState(state)
        end,
    },
    Seatbelt = {
        Enable = true,
        Key = "B",
        EjectCheckSpeed = 45, -- MPH
        RagdollTime = 20000, -- MS
        Export = function (state)
            exports[Config.HudResource]:SeatbeltState(state)
        end
    }
}