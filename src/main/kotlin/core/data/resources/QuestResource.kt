package core.data.resources

data class QuestResource(
    val id: String,
    val type: String,
    val rarity: Int,
    val levelMin: Int,
    val levelMax: Int,
    val min: Int,
    val max: Int,
    val minLevelMultiplier: Double? = null,
    val maxLevelMultiplier: Double? = null,
    val xp: Double,
    val xpLevelMultiplier: Double? = null,
    val morale: Double,
    val moraleLevelMultiplier: Double? = null
)
