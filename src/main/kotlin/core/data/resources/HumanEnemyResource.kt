package core.data.resources

data class HumanEnemyResource(
    val id: String,
    val type: String,
    val hp: Int? = null,
    val scale: Double? = null,
    val upper: String? = null,
    val lower: String? = null,
    val weapons: List<String> = emptyList(),
    val gear: List<String> = emptyList()
)

data class HumanEnemyWeapon(
    val id: String,
    val model: String? = null,
    val weaponClass: String? = null,
    val weaponType: String? = null,
    val anim: String? = null,
    val damageMin: Int? = null,
    val damageMax: Int? = null,
    val rate: Double? = null,
    val range: Int? = null,
    val rangeMinEffective: Int? = null,
    val accuracy: Double? = null,
    val capacity: Int? = null,
    val noise: Int? = null,
    val reloadTime: Double? = null,
    val sounds: Map<String, List<String>> = emptyMap()
)
