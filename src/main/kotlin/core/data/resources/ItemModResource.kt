package core.data.resources

data class ItemModResource(
    val id: String,
    val type: String,
    val damage: Int? = null,
    val accuracy: Double? = null,
    val range: Int? = null,
    val reloadTime: Double? = null,
    val capacity: Int? = null,
    val noise: Int? = null,
    val durability: Int? = null,
    val weight: Double? = null,
    val criticalChance: Double? = null,
    val criticalDamage: Double? = null
)
