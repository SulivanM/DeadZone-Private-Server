package server.service

import core.model.game.data.BuildingLike
import core.model.game.data.Survivor
import core.model.game.data.destroyed
import core.model.game.data.id
import core.model.game.data.level
import core.model.game.data.repair
import core.model.game.data.resourceValue
import core.model.game.data.rotation
import core.model.game.data.tx
import core.model.game.data.ty
import core.model.game.data.type
import core.model.game.data.upgrade
import data.collection.PlayerObjects

/**
 * Utility for serializing compound data structures to send to AS3 client.
 */
object CompoundSerializer {

    /**
     * Serialize survivors list to AS3 format.
     */
    fun serializeSurvivors(survivors: List<Survivor>): Map<String, Any> {
        return survivors.associate { survivor ->
            survivor.id to mapOf(
                "id" to survivor.id,
                "title" to survivor.title,
                "firstName" to survivor.firstName,
                "lastName" to survivor.lastName,
                "gender" to survivor.gender,
                "classId" to survivor.classId,
                "voice" to survivor.voice,
                "level" to survivor.level,
                "xp" to survivor.xp,
                "missionId" to survivor.missionId,
                "assignmentId" to survivor.assignmentId,
                "morale" to survivor.morale,
                "injuries" to survivor.injuries.map { injury ->
                    val healTime = injury.timer?.let { it.start + it.length * 1000 } ?: 0L
                    mapOf(
                        "id" to injury.id,
                        "cause" to injury.type,
                        "healTime" to healTime
                    )
                },
                "accessories" to survivor.accessories,
                "maxClothingAccessories" to survivor.maxClothingAccessories
            )
        }
    }

    /**
     * Serialize buildings list to AS3 format.
     */
    fun serializeBuildings(buildings: List<BuildingLike>): Map<String, Any> {
        return buildings.associate { building ->
            building.id to mapOf(
                "id" to building.id,
                "buildingId" to building.type,
                "level" to building.level,
                "health" to building.resourceValue,
                "maxHealth" to 100,
                "tx" to building.tx,
                "ty" to building.ty,
                "rotation" to building.rotation,
                "destroyed" to building.destroyed,
                "upgradeTimer" to building.upgrade?.let {
                    mapOf(
                        "endTime" to (it.start + it.length * 1000),
                        "currentTime" to common.Time.now(),
                        "state" to "active"
                    )
                },
                "repairTimer" to building.repair?.let {
                    mapOf(
                        "endTime" to (it.start + it.length * 1000),
                        "currentTime" to common.Time.now(),
                        "state" to "active"
                    )
                }
            )
        }
    }

    /**
     * Serialize resources to AS3 format.
     */
    fun serializeResources(playerObjects: PlayerObjects): Map<String, Int> {
        return mapOf(
            "cash" to playerObjects.resources.cash,
            "food" to playerObjects.resources.food,
            "wood" to playerObjects.resources.wood,
            "metal" to playerObjects.resources.metal,
            "cloth" to playerObjects.resources.cloth,
            "water" to playerObjects.resources.water,
            "ammunition" to playerObjects.resources.ammunition
        )
    }

    /**
     * Serialize rally assignments to AS3 format.
     */
    fun serializeRallyAssignments(survivors: List<Survivor>): Map<String, String> {
        return survivors.filter { it.assignmentId != null }
            .associate { it.id to it.assignmentId!! }
    }

    /**
     * Serialize survivor loadouts (weapons/equipment) to AS3 format.
     */
    fun serializeLoadouts(survivors: List<Survivor>): Map<String, Any> {
        // TODO: Implement when weapon/equipment system is ready
        return emptyMap()
    }

    /**
     * Serialize research effects to AS3 format.
     */
    fun serializeResearchEffects(playerObjects: PlayerObjects): Map<String, Any> {
        // TODO: Implement when research system is ready
        return emptyMap()
    }
}
