package core.model.game.data

import core.items.model.Item
import dev.deadzone.core.model.game.data.TimerData
import common.LogConfigSocketToClient
import common.Logger
import common.UUID
import kotlinx.serialization.DeserializationStrategy
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.Serializable
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.*

@OptIn(ExperimentalSerializationApi::class)
@Serializable(with = BuildingLikeSerializer::class)
@JsonClassDiscriminator("_t")
sealed class BuildingLike

private object Unspecified {
    override fun toString() = "Unspecified"
}

fun BuildingLike.toBuilding(): Building {
    return this as Building
}

val BuildingLike.id: String
    get() = when (this) {
        is Building -> this.id
        is JunkBuilding -> this.id
    }

val BuildingLike.type: String
    get() = when (this) {
        is Building -> this.type
        is JunkBuilding -> this.type
    }

val BuildingLike.level: Int
    get() = when(this) {
        is Building -> this.level
        is JunkBuilding -> this.level
    }

val BuildingLike.upgrade: TimerData?
    get() = when (this) {
        is Building -> this.upgrade
        is JunkBuilding -> this.upgrade
    }

val BuildingLike.repair: TimerData?
    get() = when (this) {
        is Building -> this.repair
        is JunkBuilding -> this.repair
    }

val BuildingLike.tx: Int
    get() = when (this) {
        is Building -> this.tx
        is JunkBuilding -> this.tx
    }

val BuildingLike.ty: Int
    get() = when (this) {
        is Building -> this.ty
        is JunkBuilding -> this.ty
    }

val BuildingLike.rotation: Int
    get() = when (this) {
        is Building -> this.rotation
        is JunkBuilding -> this.rotation
    }

val BuildingLike.destroyed: Boolean
    get() = when (this) {
        is Building -> this.destroyed
        is JunkBuilding -> this.destroyed
    }

val BuildingLike.resourceValue: Double
    get() = when (this) {
        is Building -> this.resourceValue
        is JunkBuilding -> this.resourceValue
    }

fun BuildingLike.copy(
    id: String? = null,
    name: String? = null,
    type: String? = null,
    level: Int? = null,
    rotation: Int? = null,
    tx: Int? = null,
    ty: Int? = null,
    destroyed: Boolean? = null,
    resourceValue: Double? = null,
    upgrade: Any? = Unspecified,
    repair: Any? = Unspecified,
    items: List<Item>? = null,
    pos: String? = null,
    rot: String? = null,
    assignedSurvivors: Any? = Unspecified
): BuildingLike = when (this) {
    is Building -> this.copy(
        id = id ?: this.id,
        name = name ?: this.name,
        type = type ?: this.type,
        level = level ?: this.level,
        rotation = rotation ?: this.rotation,
        tx = tx ?: this.tx,
        ty = ty ?: this.ty,
        destroyed = destroyed ?: this.destroyed,
        resourceValue = resourceValue ?: this.resourceValue,
        upgrade = if (upgrade === Unspecified) this.upgrade else upgrade as TimerData?,
        repair = if (repair === Unspecified) this.repair else repair as TimerData?,
        assignedSurvivors = if (assignedSurvivors === Unspecified) this.assignedSurvivors else assignedSurvivors as List<String?>?
    )

    is JunkBuilding -> this.copy(
        id = id ?: this.id,
        name = name ?: this.name,
        type = type ?: this.type,
        level = level ?: this.level,
        rotation = rotation ?: this.rotation,
        tx = tx ?: this.tx,
        ty = ty ?: this.ty,
        destroyed = destroyed ?: this.destroyed,
        resourceValue = resourceValue ?: this.resourceValue,
        upgrade = if (upgrade === Unspecified) this.upgrade else upgrade as TimerData?,
        repair = if (repair === Unspecified) this.repair else repair as TimerData?,
        items = items ?: this.items,
        pos = pos ?: this.pos,
        rot = rot ?: this.rot
    )
}


@Serializable
data class Building(
    val id: String = UUID.new(),    // building's unique ID
    val name: String? = null,
    val type: String,  // building's ID in buildings.xml, not to be confused with type in XML
    val level: Int = 0,
    val rotation: Int = 0,
    val tx: Int = 0,
    val ty: Int = 0,
    val destroyed: Boolean = false,
    val resourceValue: Double = 0.0,
    val upgrade: TimerData? = null,
    val repair: TimerData? = null,
    val assignedSurvivors: List<String?>? = null  // List of survivor IDs assigned to rally points (null = empty slot)
) : BuildingLike()

fun Building.toCompactString(): String {
    return "Building(id=$id, type=$type, level=$level, upgrade=$upgrade, repair=$repair, resourceValue=$resourceValue)"
}

object BuildingLikeSerializer : JsonContentPolymorphicSerializer<BuildingLike>(BuildingLike::class) {
    override fun selectDeserializer(element: JsonElement): DeserializationStrategy<BuildingLike> {
        return when (val discriminator = element.jsonObject["_t"]?.jsonPrimitive?.contentOrNull) {
            "core.model.game.data.Building" -> Building.serializer()
            "core.model.game.data.JunkBuilding" -> JunkBuilding.serializer()
            null -> {
                val obj = element.jsonObject
                return when {
                    obj.containsKey("items") && obj.containsKey("pos") && obj.containsKey("rot") ->
                        JunkBuilding.serializer()

                    else ->
                        Building.serializer()
                }
            }

            else -> {
                Logger.error(
                    LogConfigSocketToClient,
                    forceLogFull = true
                ) { "Error during serialization of BuildingLike type: $element" }
                throw SerializationException("Unknown type: '$discriminator'")
            }
        }
    }
}
