Config_death = {}

Config_death.Locales = {
    ['respawn_available_in'] = 'Réanimation d\'urgence possible dans ',
    ['respawn_bleedout_in'] = 'Vous allez succomber dans ',
    ['respawn_bleedout_prompt'] = 'Appuyez [E] pour être réanimé',
    ['respawn_bleedout_fine'] = 'Appuyez [E] pour être réanimé pour $',
    ['respawn_bleedout_fine_msg'] = 'Vous avez payé $',
    ['distress_send'] = 'Appuyez sur [G] pour envoyer un signal de détresse',
    ['distress_sent'] = 'Un signal a été envoyé à toutes les unités disponibles !',
}

Config_death.SaveDeathStatus            = true

Config_death.EarlyRespawnTimer          = 60 * 1000
Config_death.BleedoutTimer              = 5 * 60 * 1000

Config_death.RemoveWeaponsAfterRPDeath  = true
Config_death.RemoveCashAfterRPDeath     = true
Config_death.RemoveItemsAfterRPDeath    = true

Config_death.EarlyRespawnFine           = false
Config_death.EarlyRespawnFineAmount     = 0

Config_death.OxInventory                = ESX.GetConfig().OxInventory
Config_death.RespawnPoints = {
	{coords = vector3(341.0, -1397.3, 32.5), heading = 48.5}, -- Central Los Santos
	{coords = vector3(1836.03, 3670.99, 34.28), heading = 296.06} -- Sandy Shores
}