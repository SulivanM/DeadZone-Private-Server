package core.data.resources

data class RaidResource(
    val id: String,
    val levelMin: Int? = null,
    val levelMax: Int? = null,
    val survivorMin: Int? = null,
    val survivorMax: Int? = null,
    val raidPointsPerSurvivor: Int? = null,
    val stages: List<RaidStage> = emptyList(),
    val rewards: List<RaidRewardTier> = emptyList()
)

data class RaidStage(
    val id: String,
    val level: Int? = null,
    val time: Int? = null,
    val maps: List<RaidMap> = emptyList()
)

data class RaidMap(
    val uri: String,
    val tag: String? = null,
    val objectives: List<RaidObjective> = emptyList()
)

data class RaidObjective(
    val id: String,
    val langKey: String? = null,
    val raidPoints: Int? = null,
    val triggers: Map<String, Int> = emptyMap()
)

data class RaidRewardTier(
    val score: Int,
    val items: List<RaidRewardItem> = emptyList()
)

data class RaidRewardItem(
    val type: String,
    val quantity: Int = 1
)
