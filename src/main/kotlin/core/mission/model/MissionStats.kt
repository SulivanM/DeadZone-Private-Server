package core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
data class MissionStats(
    val zombieSpawned: Int = 0,
    val levelUps: Int = 0,
    val damageOutput: Double = 0.0,
    val damageTaken: Double = 0.0,
    val containersSearched: Int = 0,
    val survivorKills: Int = 0,
    val survivorsDowned: Int = 0,
    val survivorExplosiveKills: Int = 0,
    val humanKills: Int = 0,
    val humanExplosiveKills: Int = 0,
    val zombieKills: Int = 0,
    val zombieExplosiveKills: Int = 0,
    val hpHealed: Int = 0,
    val explosivesPlaced: Int = 0,
    val grenadesThrown: Int = 0,
    val grenadesSmokeThrown: Int = 0,
    val allianceFlagCaptured: Int = 0,
    val buildingsDestroyed: Int = 0,
    val buildingsLost: Int = 0,
    val buildingsExplosiveDestroyed: Int = 0,
    val trapsTriggered: Int = 0,
    val trapDisarmTriggered: Int = 0,
    val cashFound: Int = 0,
    val woodFound: Int = 0,
    val metalFound: Int = 0,
    val clothFound: Int = 0,
    val foodFound: Int = 0,
    val waterFound: Int = 0,
    val ammunitionFound: Int = 0,
    val ammunitionUsed: Int = 0,
    val weaponsFound: Int = 0,
    val gearFound: Int = 0,
    val junkFound: Int = 0,
    val medicalFound: Int = 0,
    val craftingFound: Int = 0,
    val researchFound: Int = 0,
    val researchNoteFound: Int = 0,
    val clothingFound: Int = 0,
    val cratesFound: Int = 0,
    val schematicsFound: Int = 0,
    val effectFound: Int = 0,
    val rareWeaponFound: Int = 0,
    val rareGearFound: Int = 0,
    val uniqueWeaponFound: Int = 0,
    val uniqueGearFound: Int = 0,
    val greyWeaponFound: Int = 0,
    val greyGearFound: Int = 0,
    val whiteWeaponFound: Int = 0,
    val whiteGearFound: Int = 0,
    val greenWeaponFound: Int = 0,
    val greenGearFound: Int = 0,
    val blueWeaponFound: Int = 0,
    val blueGearFound: Int = 0,
    val purpleWeaponFound: Int = 0,
    val purpleGearFound: Int = 0,
    val premiumWeaponFound: Int = 0,
    val premiumGearFound: Int = 0,
    val killData: Map<String, Int> = mapOf(),
    val customData: Map<String, Int> = mapOf()
)

/**
 * Combine two MissionStats by adding all their values together
 */
fun MissionStats.plus(other: MissionStats): MissionStats {
    return MissionStats(
        zombieSpawned = this.zombieSpawned + other.zombieSpawned,
        levelUps = this.levelUps + other.levelUps,
        damageOutput = this.damageOutput + other.damageOutput,
        damageTaken = this.damageTaken + other.damageTaken,
        containersSearched = this.containersSearched + other.containersSearched,
        survivorKills = this.survivorKills + other.survivorKills,
        survivorsDowned = this.survivorsDowned + other.survivorsDowned,
        survivorExplosiveKills = this.survivorExplosiveKills + other.survivorExplosiveKills,
        humanKills = this.humanKills + other.humanKills,
        humanExplosiveKills = this.humanExplosiveKills + other.humanExplosiveKills,
        zombieKills = this.zombieKills + other.zombieKills,
        zombieExplosiveKills = this.zombieExplosiveKills + other.zombieExplosiveKills,
        hpHealed = this.hpHealed + other.hpHealed,
        explosivesPlaced = this.explosivesPlaced + other.explosivesPlaced,
        grenadesThrown = this.grenadesThrown + other.grenadesThrown,
        grenadesSmokeThrown = this.grenadesSmokeThrown + other.grenadesSmokeThrown,
        allianceFlagCaptured = this.allianceFlagCaptured + other.allianceFlagCaptured,
        buildingsDestroyed = this.buildingsDestroyed + other.buildingsDestroyed,
        buildingsLost = this.buildingsLost + other.buildingsLost,
        buildingsExplosiveDestroyed = this.buildingsExplosiveDestroyed + other.buildingsExplosiveDestroyed,
        trapsTriggered = this.trapsTriggered + other.trapsTriggered,
        trapDisarmTriggered = this.trapDisarmTriggered + other.trapDisarmTriggered,
        cashFound = this.cashFound + other.cashFound,
        woodFound = this.woodFound + other.woodFound,
        metalFound = this.metalFound + other.metalFound,
        clothFound = this.clothFound + other.clothFound,
        foodFound = this.foodFound + other.foodFound,
        waterFound = this.waterFound + other.waterFound,
        ammunitionFound = this.ammunitionFound + other.ammunitionFound,
        ammunitionUsed = this.ammunitionUsed + other.ammunitionUsed,
        weaponsFound = this.weaponsFound + other.weaponsFound,
        gearFound = this.gearFound + other.gearFound,
        junkFound = this.junkFound + other.junkFound,
        medicalFound = this.medicalFound + other.medicalFound,
        craftingFound = this.craftingFound + other.craftingFound,
        researchFound = this.researchFound + other.researchFound,
        researchNoteFound = this.researchNoteFound + other.researchNoteFound,
        clothingFound = this.clothingFound + other.clothingFound,
        cratesFound = this.cratesFound + other.cratesFound,
        schematicsFound = this.schematicsFound + other.schematicsFound,
        effectFound = this.effectFound + other.effectFound,
        rareWeaponFound = this.rareWeaponFound + other.rareWeaponFound,
        rareGearFound = this.rareGearFound + other.rareGearFound,
        uniqueWeaponFound = this.uniqueWeaponFound + other.uniqueWeaponFound,
        uniqueGearFound = this.uniqueGearFound + other.uniqueGearFound,
        greyWeaponFound = this.greyWeaponFound + other.greyWeaponFound,
        greyGearFound = this.greyGearFound + other.greyGearFound,
        whiteWeaponFound = this.whiteWeaponFound + other.whiteWeaponFound,
        whiteGearFound = this.whiteGearFound + other.whiteGearFound,
        greenWeaponFound = this.greenWeaponFound + other.greenWeaponFound,
        greenGearFound = this.greenGearFound + other.greenGearFound,
        blueWeaponFound = this.blueWeaponFound + other.blueWeaponFound,
        blueGearFound = this.blueGearFound + other.blueGearFound,
        purpleWeaponFound = this.purpleWeaponFound + other.purpleWeaponFound,
        purpleGearFound = this.purpleGearFound + other.purpleGearFound,
        premiumWeaponFound = this.premiumWeaponFound + other.premiumWeaponFound,
        premiumGearFound = this.premiumGearFound + other.premiumGearFound,
        killData = combineIntMaps(this.killData, other.killData),
        customData = combineIntMaps(this.customData, other.customData)
    )
}

/**
 * Helper function to combine two maps of Int values
 */
private fun combineIntMaps(map1: Map<String, Int>, map2: Map<String, Int>): Map<String, Int> {
    val result = map1.toMutableMap()
    for ((key, value) in map2) {
        result[key] = (result[key] ?: 0) + value
    }
    return result
}
