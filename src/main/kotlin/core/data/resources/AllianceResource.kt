package core.data.resources

data class AllianceResource(
    val services: List<AllianceService> = emptyList(),
    val individualTiers: List<AllianceIndividualTier> = emptyList(),
    val rewards: AllianceRewards? = null,
    val effectCostPerDayMember: Double? = null,
    val effectSets: List<AllianceEffectSet> = emptyList(),
    val taskSets: List<AllianceTaskSet> = emptyList()
)

data class AllianceService(
    val id: String,
    val zeroDay: String,
    val days: Int,
    val graceHours: Int,
    val active: Boolean
)

data class AllianceIndividualTier(
    val score: Int,
    val image: String? = null,
    val items: List<AllianceRewardItem> = emptyList()
)

data class AllianceRewards(
    val memberCount: Int,
    val distribution: List<Int> = emptyList()
)

data class AllianceRewardItem(
    val type: String,
    val quantity: Int = 1
)

data class AllianceEffectSet(
    val effects: List<String> = emptyList()
)

data class AllianceTaskSet(
    val tasks: List<String> = emptyList()
)
