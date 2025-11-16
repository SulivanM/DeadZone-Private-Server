package core.data.resources

data class GlobalQuestResource(
    val id: String,
    val type: String,
    val startDate: String? = null,
    val endDate: String? = null,
    val service: String? = null,
    val goals: List<GlobalQuestGoal> = emptyList(),
    val rewards: List<GlobalQuestReward> = emptyList()
)

data class GlobalQuestGoal(
    val statId: String,
    val contributionMultiplier: Int = 1,
    val contributionAmount: Int,
    val goalValue: Int
)

data class GlobalQuestReward(
    val type: String,
    val itemType: String? = null,
    val quantity: Int? = null,
    val xpPercentage: Double? = null
)
