package core.data.resources

import core.model.game.data.GameResources

data class BuildingResource(
    val id: String,
    val type: String,
    val max: Int = 1,
    val indoor: Boolean = false,
    val outdoor: Boolean = false,
    val scav: Boolean = false,
    val assignable: Boolean = false,
    val destroy: Boolean = false,
    val connect: Boolean = false,
    val size: BuildingSize = BuildingSize(1, 1),
    val model: String? = null,
    val damagedModel: String? = null,
    val image: String? = null,
    val health: Int? = null,
    val sounds: BuildingSounds? = null,
    val resources: GameResources? = null,
    val resourceMultiplier: Double = 1.0,
    val craft: List<String> = emptyList(),
    val store: String? = null,
    val cover: Int? = null,
    val assignPositions: List<BuildingAssignPosition> = emptyList(),
    val levels: List<BuildingLevel> = emptyList()
) {
    fun getLevel(levelNumber: Int): BuildingLevel? = levels.getOrNull(levelNumber)

    fun requireLevel(levelNumber: Int): BuildingLevel =
        levels.getOrNull(levelNumber) ?: throw IllegalArgumentException("Level $levelNumber not found for building $id")
}

data class BuildingSize(
    val x: Int,
    val y: Int
)

data class BuildingSounds(
    val death: List<String> = emptyList()
)

data class BuildingAssignPosition(
    val x: Int,
    val y: Int
)

data class BuildingLevel(
    val number: Int,
    val cover: Int? = null,
    val xp: Int? = null,
    val time: Int? = null,
    val model: String? = null,
    val image: String? = null,
    val comfort: Int? = null,
    val security: Int? = null,
    val capacity: Int? = null,
    val maxUpgradeLevel: Int? = null,
    val production: BuildingProduction? = null,
    val requirements: BuildingRequirements? = null,
    val items: List<BuildingLevelItem> = emptyList()
)

data class BuildingProduction(
    val rate: Double? = null,
    val cap: Int? = null,
    val capacity: Int? = null
)

data class BuildingRequirements(
    val buildings: List<BuildingRequirement> = emptyList(),
    val items: List<ItemRequirement> = emptyList(),
    val level: Int? = null
)

data class BuildingRequirement(
    val id: String,
    val level: Int,
    val quantity: Int = 1
)

data class ItemRequirement(
    val id: String,
    val quantity: Int = 1
)

data class BuildingLevelItem(
    val type: String,
    val level: Int,
    val quantity: Int,
    val mod1: String? = null
)
