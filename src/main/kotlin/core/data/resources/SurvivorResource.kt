package core.data.resources

data class SurvivorArrivalRequirement(
    val food: Int,
    val water: Int,
    val comfort: Int,
    val security: Int,
    val morale: Int,
    val buildingRequirements: List<BuildingRequirement> = emptyList(),
    val cost: Int
)
