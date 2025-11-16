package core.data.resources

data class ArenaResource(
    val id: String,
    val levelMin: Int? = null,
    val survivorMin: Int? = null,
    val survivorMax: Int? = null,
    val pointsPerSurvivor: Int? = null,
    val resources: List<String> = emptyList(),
    val audio: ArenaAudio? = null,
    val rewards: List<ArenaRewardTier> = emptyList()
)

data class ArenaAudio(
    val ambient: List<String> = emptyList(),
    val timerWarning: List<String> = emptyList(),
    val survivorDeath: List<String> = emptyList(),
    val zombieExplode: List<String> = emptyList(),
    val score: List<String> = emptyList(),
    val win: List<String> = emptyList(),
    val lose: List<String> = emptyList(),
    val zombieDeath: List<String> = emptyList()
)

data class ArenaRewardTier(
    val score: Int,
    val items: List<ArenaRewardItem> = emptyList()
)

data class ArenaRewardItem(
    val type: String,
    val quantity: Int = 1
)
