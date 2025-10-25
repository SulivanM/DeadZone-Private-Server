package core.data.resources

import core.model.game.data.GameResources

data class ItemResource(
    val id: String,
    val type: String,
    val quality: String? = null,
    val rarity: Double? = null,
    val image: String? = null,
    val model: String? = null,
    val levelMin: Int? = null,
    val levelMax: Int? = null,
    val quantityMin: Int? = null,
    val quantityMax: Int? = null,
    val stack: Int = 1,
    val lootLocations: List<String> = emptyList(),
    val resources: GameResources? = null,
    val kit: UpgradeKit? = null,
    val weapon: WeaponData? = null,
    val gear: GearData? = null
)

data class UpgradeKit(
    val itemLevelMin: Int,
    val itemLevelMax: Int,
    val maxUpgradeChance: Double
)

data class WeaponData(
    val weaponClass: String? = null,
    val weaponType: List<String> = emptyList(),
    val animation: String? = null,
    val swingAnimations: List<String> = emptyList(),
    val damageMin: Double? = null,
    val damageMax: Double? = null,
    val damageLevelMultiplier: Double? = null,
    val rate: Double? = null,
    val range: Double? = null,
    val capacity: Int? = null,
    val accuracy: Double? = null,
    val reloadTime: Double? = null,
    val damageToBuild: Double? = null,
    val knockback: Double? = null,
    val sounds: WeaponSounds? = null
)

data class WeaponSounds(
    val hit: List<String> = emptyList(),
    val fire: List<String> = emptyList(),
    val reload: List<String> = emptyList()
)

data class GearData(
    val slot: String? = null,
    val armor: Double? = null,
    val storage: Int? = null
)
