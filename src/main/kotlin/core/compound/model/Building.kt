package dev.deadzone.core.model.game.data

import dev.deadzone.core.items.model.Item
import dev.deadzone.utils.LogConfigSocketToClient
import dev.deadzone.utils.Logger
import dev.deadzone.utils.UUID
import kotlinx.serialization.DeserializationStrategy
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.Serializable
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.*

@OptIn(ExperimentalSerializationApi::class)
@Serializable(with = BuildingLikeSerializer::class)
@JsonClassDiscriminator("_t")
sealed class BuildingLike

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
    upgrade: TimerData? = null,
    repair: TimerData? = null,
    items: List<Item>? = null,
    pos: String? = null,
    rot: String? = null
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
        upgrade = upgrade ?: this.upgrade,
        repair = repair ?: this.repair
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
        upgrade = upgrade ?: this.upgrade,
        repair = repair ?: this.repair,
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
    val rotation: Int,
    val tx: Int,
    val ty: Int,
    val destroyed: Boolean = false,
    val resourceValue: Double = 0.0,
    val upgrade: TimerData? = null,
    val repair: TimerData? = null
) : BuildingLike()

object BuildingLikeSerializer : JsonContentPolymorphicSerializer<BuildingLike>(BuildingLike::class) {
    override fun selectDeserializer(element: JsonElement): DeserializationStrategy<BuildingLike> {
        val discriminator = element.jsonObject["_t"]?.jsonPrimitive?.contentOrNull

        return when (discriminator) {
            "dev.deadzone.core.model.game.data.Building" -> Building.serializer()
            "dev.deadzone.core.model.game.data.JunkBuilding" -> JunkBuilding.serializer()
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
