package core.data.resources

data class InjuryResource(
    val type: String,
    val causes: List<String> = emptyList(),
    val rarity: Int,
    val locations: List<InjuryLocation> = emptyList()
)

data class InjuryLocation(
    val id: String,
    val severities: List<InjurySeverity> = emptyList()
)

data class InjurySeverity(
    val type: String,
    val combatMelee: Double? = null,
    val combatProjectile: Double? = null,
    val combatImprovised: Double? = null,
    val recipe: List<MedicalIngredient> = emptyList()
)

data class MedicalIngredient(
    val id: String,
    val grade: Int
)

data class SeverityConfig(
    val type: String,
    val max: Int,
    val severityLevels: List<SeverityLevel> = emptyList()
)

data class SeverityLevel(
    val type: String,
    val rarity: Int,
    val cost: Int,
    val level: Int,
    val damage: Double,
    val morale: Int,
    val time: Int
)
