package core.data.resources

data class SkillResource(
    val id: String,
    val levels: List<SkillLevel> = emptyList()
) {
    fun getLevel(levelNumber: Int): SkillLevel? = levels.getOrNull(levelNumber)

    fun requireLevel(levelNumber: Int): SkillLevel =
        levels.getOrNull(levelNumber) ?: throw IllegalArgumentException("Level $levelNumber not found for skill $id")
}

data class SkillLevel(
    val number: Int,
    val xp: Int,
    val craftXp: Int? = null,
    val craftCost: Int? = null
)
