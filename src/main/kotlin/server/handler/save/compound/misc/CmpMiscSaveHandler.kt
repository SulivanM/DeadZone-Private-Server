package server.handler.save.compound.misc

import context.requirePlayerContext
import core.model.game.data.copy
import core.model.game.data.toBuilding
import server.handler.save.SaveHandlerContext
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.handler.save.compound.misc.response.RallyAssignmentResponse
import server.handler.save.compound.misc.response.CraftUpgradeResponse
import core.data.GameDefinition
import core.items.model.ItemQualityType
import core.model.game.data.GameResources
import kotlin.math.floor
import kotlin.math.max
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import common.JSON
import common.LogConfigSocketError
import common.LogConfigSocketToClient
import core.survivor.XpLevelService
import common.Logger

/**
 * Handler for compound miscellaneous save operations.
 * Manages crafting, upgrades, rally assignments, and other compound-related actions.
 */
class CmpMiscSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.COMPOUND_MISC_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        when (type) {
            SaveDataMethod.CRAFT_ITEM -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CRAFT_ITEM' message [not implemented]" }
            }

            SaveDataMethod.CRAFT_UPGRADE -> {
                val playerId = connection.playerId
                val ctx = serverContext.requirePlayerContext(playerId)
                val inventorySvc = ctx.services.inventory
                val compoundSvc = ctx.services.compound

                val itemId = (data["id"] as? String)?.uppercase() ?: run {
                    Logger.error(LogConfigSocketError) { "CRAFT_UPGRADE: Missing item ID" }
                    val response = CraftUpgradeResponse(success = false, error = "MissingItemId")
                    send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))
                    return
                }

                val kitId = (data["kitId"] as? String)?.uppercase() ?: ""

                Logger.info(LogConfigSocketToClient) { "CRAFT_UPGRADE for itemId=$itemId, kitId=$kitId, playerId=$playerId" }

                // Find the item in inventory
                val inventory = inventorySvc.getInventory()
                val item = inventory.find { it.id == itemId }

                if (item == null) {
                    Logger.error(LogConfigSocketError) { "CRAFT_UPGRADE: Item $itemId not found in inventory" }
                    val response = CraftUpgradeResponse(success = false, error = "ItemNotFound")
                    send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))
                    return
                }

                // Get item definition
                val itemDef = GameDefinition.findItem(item.type)
                if (itemDef == null) {
                    Logger.error(LogConfigSocketError) { "CRAFT_UPGRADE: Item definition not found for type=${item.type}" }
                    val response = CraftUpgradeResponse(success = false, error = "ItemDefinitionNotFound")
                    send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))
                    return
                }

                // Check if item can be upgraded
                val maxLevel = itemDef.levelMax ?: 0
                if (item.level >= maxLevel && maxLevel > 0) {
                    Logger.warn(LogConfigSocketError) { "CRAFT_UPGRADE: Item $itemId already at max level ${item.level}" }
                    val response = CraftUpgradeResponse(success = false, error = "MaxLevel")
                    send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))
                    return
                }

                val inventoryChanges = mutableMapOf<String, Int>()
                var cashCost = 0

                // Handle upgrade kit if provided
                if (kitId.isNotEmpty()) {
                    val kit = inventory.find { it.id == kitId }
                    if (kit == null) {
                        Logger.error(LogConfigSocketError) { "CRAFT_UPGRADE: Kit $kitId not found in inventory" }
                        val response = CraftUpgradeResponse(success = false, error = "KitNotFound")
                        send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))
                        return
                    }

                    // Get kit definition
                    val kitDef = GameDefinition.findItem(kit.type)
                    if (kitDef == null || kitDef.kit == null) {
                        Logger.error(LogConfigSocketError) { "CRAFT_UPGRADE: Invalid kit definition for type=${kit.type}" }
                        val response = CraftUpgradeResponse(success = false, error = "InvalidKit")
                        send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))
                        return
                    }

                    // Validate kit can be used on this item
                    val kitInfo = kitDef.kit

                    // Check quality compatibility (kit quality must be >= item quality)
                    val kitQuality = kit.quality ?: 0
                    val itemQuality = item.quality ?: 0
                    if (kitQuality < itemQuality) {
                        Logger.warn(LogConfigSocketError) { "CRAFT_UPGRADE: Kit quality $kitQuality < item quality $itemQuality" }
                        val response = CraftUpgradeResponse(success = false, error = "KitQualityTooLow")
                        send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))
                        return
                    }

                    // Check level range
                    if (item.level < kitInfo.itemLevelMin || item.level > kitInfo.itemLevelMax) {
                        Logger.warn(LogConfigSocketError) { "CRAFT_UPGRADE: Item level ${item.level} not in kit range [${kitInfo.itemLevelMin}, ${kitInfo.itemLevelMax}]" }
                        val response = CraftUpgradeResponse(success = false, error = "KitLevelMismatch")
                        send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))
                        return
                    }

                    // Consume the kit
                    inventoryChanges[kit.type] = -1
                } else {
                    // Calculate upgrade cost
                    // Simplified formula: baseCost * (level + 1) * qualityMultiplier
                    val baseCost = 100
                    val costPerLevel = 50
                    val qualityMultiplier = when (item.quality ?: 0) {
                        0 -> 1.0  // white
                        1 -> 1.5  // green
                        2 -> 2.0  // blue
                        3 -> 2.5  // purple
                        50 -> 3.0 // rare
                        51 -> 4.0 // unique
                        else -> 1.0
                    }

                    cashCost = max(baseCost, floor((item.level + 1) * costPerLevel * qualityMultiplier).toInt())

                    // Check if player has enough cash
                    val currentCash = compoundSvc.getResources().cash
                    if (currentCash < cashCost) {
                        Logger.warn(LogConfigSocketError) { "CRAFT_UPGRADE: Not enough cash. Required=$cashCost, Available=$currentCash" }
                        val response = CraftUpgradeResponse(success = false, error = "NotEnoughCoins")
                        send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))
                        return
                    }

                    // Deduct cash
                    val resourceUpdateResult = compoundSvc.updateResource { resources ->
                        resources.copy(cash = resources.cash - cashCost)
                    }

                    if (resourceUpdateResult.isFailure) {
                        Logger.error(LogConfigSocketError) { "CRAFT_UPGRADE: Failed to deduct cash: ${resourceUpdateResult.exceptionOrNull()?.message}" }
                        val response = CraftUpgradeResponse(success = false, error = "ResourceUpdateFailed")
                        send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))
                        return
                    }
                }

                // Upgrade the item
                val newLevel = item.level + 1
                val isMaxLevel = maxLevel > 0 && newLevel >= maxLevel

                val updateResult = inventorySvc.updateInventory { inv ->
                    inv.map { invItem ->
                        if (invItem.id == itemId) {
                            invItem.copy(level = newLevel, new = true)
                        } else if (kitId.isNotEmpty() && invItem.id == kitId) {
                            // Remove or decrease kit quantity
                            if (invItem.qty > 1u) {
                                invItem.copy(qty = invItem.qty - 1u)
                            } else {
                                null // Remove item
                            }
                        } else {
                            invItem
                        }
                    }.filterNotNull()
                }

                if (updateResult.isFailure) {
                    Logger.error(LogConfigSocketError) { "CRAFT_UPGRADE: Failed to update inventory: ${updateResult.exceptionOrNull()?.message}" }
                    // Refund cash if it was deducted
                    if (cashCost > 0) {
                        compoundSvc.updateResource { it.copy(cash = it.cash + cashCost) }
                    }
                    val response = CraftUpgradeResponse(success = false, error = "InventoryUpdateFailed")
                    send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))
                    return
                }

                // Grant XP for crafting upgrade using centralized service
                val craftXp = (newLevel * 10).coerceAtMost(100) // 10 XP per level, max 100
                val survivorSvc = ctx.services.survivor
                val leader = survivorSvc.getSurvivorLeader()

                try {
                    val playerObjects = serverContext.db.loadPlayerObjects(playerId)
                    if (playerObjects != null) {
                        // Use centralized XP service for consistent level calculation and rested XP bonus
                        val (updatedLeader, updatedPlayerObjects) = XpLevelService.addXpToLeader(
                            survivor = leader,
                            playerObjects = playerObjects,
                            earnedXp = craftXp
                        )

                        val oldLevel = leader.level
                        val newLeaderLevel = updatedLeader.level

                        // Update survivor in database
                        val xpUpdateResult = survivorSvc.updateSurvivor(leader.id) { _ ->
                            updatedLeader
                        }

                        // Update PlayerObjects with new levelPts and consumed restXP
                        serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)

                        if (xpUpdateResult.isFailure) {
                            Logger.error(LogConfigSocketError) { "CRAFT_UPGRADE: Failed to grant XP: ${xpUpdateResult.exceptionOrNull()?.message}" }
                        } else {
                            Logger.info(LogConfigSocketToClient) {
                                "CRAFT_UPGRADE: Granted $craftXp XP to player leader for item upgrade. " +
                                "Level: $oldLevel->$newLeaderLevel, XP: ${leader.xp}->${updatedLeader.xp}"
                            }
                        }
                    } else {
                        Logger.error(LogConfigSocketError) { "CRAFT_UPGRADE: Failed to load PlayerObjects for playerId=$playerId" }
                    }
                } catch (e: Exception) {
                    Logger.error(LogConfigSocketError) { "CRAFT_UPGRADE: Failed to grant XP: ${e.message}" }
                }

                Logger.info(LogConfigSocketToClient) { "CRAFT_UPGRADE: Successfully upgraded item $itemId to level $newLevel" }

                val response = CraftUpgradeResponse(
                    success = true,
                    item = itemId,
                    level = newLevel,
                    change = if (inventoryChanges.isNotEmpty()) inventoryChanges else null,
                    winmaxlevel = if (isMaxLevel) true else null
                )
                send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))
            }

            SaveDataMethod.CRAFT_SCHEMATIC -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CRAFT_SCHEMATIC' message [not implemented]" }
            }

            SaveDataMethod.EFFECT_SET -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'EFFECT_SET' message [not implemented]" }
            }

            SaveDataMethod.RESEARCH_START -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'RESEARCH_START' message [not implemented]" }
            }

            SaveDataMethod.AH_EVENT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'AH_EVENT' message [not implemented]" }
            }

            SaveDataMethod.CULL_NEIGHBORS -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CULL_NEIGHBORS' message [not implemented]" }
            }

            SaveDataMethod.RALLY_ASSIGNMENT -> {
                val playerId = connection.playerId
                val ctx = serverContext.requirePlayerContext(playerId)
                val compoundSvc = ctx.services.compound
                val survivorSvc = ctx.services.survivor

                val buildingId = data["id"] as? String ?: run {
                    Logger.error(LogConfigSocketError) { "RALLY_ASSIGNMENT: Missing building ID for playerId=$playerId" }
                    val response = RallyAssignmentResponse(success = false)
                    send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))
                    return
                }

                val survivors = data["survivors"] as? List<*> ?: run {
                    Logger.error(LogConfigSocketError) { "RALLY_ASSIGNMENT: Missing survivors list for playerId=$playerId" }
                    val response = RallyAssignmentResponse(success = false)
                    send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))
                    return
                }

                Logger.info(LogConfigSocketToClient) { "RALLY_ASSIGNMENT: Building=$buildingId, Survivors=${survivors.size} for playerId=$playerId" }

                // Convert survivors list to List<String?> (null for empty slots)
                val survivorIds = survivors.map { it as? String }

                // Get the building
                val building = compoundSvc.getBuilding(buildingId)
                if (building == null) {
                    Logger.error(LogConfigSocketError) { "RALLY_ASSIGNMENT: Building bldId=$buildingId not found for playerId=$playerId" }
                    val response = RallyAssignmentResponse(success = false)
                    send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))
                    return
                }

                // Validate building is assignable by checking XML definition
                val buildingData = building.toBuilding()
                val buildingDef = GameDefinition.findBuilding(buildingData.type)
                val isAssignable = buildingDef?.assignable == true
                val maxAssignSlots = buildingDef?.assignPositions?.size ?: 0

                if (!isAssignable || maxAssignSlots == 0) {
                    Logger.error(LogConfigSocketError) { "RALLY_ASSIGNMENT: Building type=${buildingData.type} is not assignable or has no assign positions for playerId=$playerId" }
                    val response = RallyAssignmentResponse(success = false)
                    send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))
                    return
                }

                // Validate number of survivors doesn't exceed max slots
                if (survivorIds.size > maxAssignSlots) {
                    Logger.error(LogConfigSocketError) { "RALLY_ASSIGNMENT: Too many survivors (${survivorIds.size}) for building bldId=$buildingId (max slots=$maxAssignSlots) for playerId=$playerId" }
                    val response = RallyAssignmentResponse(success = false)
                    send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))
                    return
                }

                // Validate all non-null survivors exist
                val nonNullSurvivorIds = survivorIds.filterNotNull()
                for (srvId in nonNullSurvivorIds) {
                    val survivor = survivorSvc.getSurvivor(srvId)
                    if (survivor == null) {
                        Logger.error(LogConfigSocketError) { "RALLY_ASSIGNMENT: Survivor srvId=$srvId not found for playerId=$playerId" }
                        val response = RallyAssignmentResponse(success = false)
                        send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))
                        return
                    }
                }

                // Get previously assigned survivors from THIS building
                val previouslyAssigned = building.toBuilding().assignedSurvivors?.filterNotNull() ?: emptyList()

                // STEP 1: Clear ALL rally assignments for survivors being assigned to this building
                // This prevents a survivor from being assigned to multiple buildings
                for (srvId in nonNullSurvivorIds) {
                    val survivor = survivorSvc.getSurvivor(srvId) ?: continue

                    // If survivor was assigned to a different building, clear that building's assignment
                    if (survivor.assignmentId != null && survivor.assignmentId != buildingId) {
                        val oldBuildingId = survivor.assignmentId!!
                        val oldBuilding = compoundSvc.getBuilding(oldBuildingId)

                        if (oldBuilding != null) {
                            val oldBuildingData = oldBuilding.toBuilding()
                            val updatedAssignments = oldBuildingData.assignedSurvivors?.map { assignedId ->
                                if (assignedId == srvId) null else assignedId
                            }

                            val updateOldBuildingResult = compoundSvc.updateBuilding(oldBuildingId) { bld ->
                                bld.copy(assignedSurvivors = updatedAssignments)
                            }

                            if (updateOldBuildingResult.isFailure) {
                                Logger.warn(LogConfigSocketError) { "RALLY_ASSIGNMENT: Failed to clear survivor srvId=$srvId from old building bldId=$oldBuildingId: ${updateOldBuildingResult.exceptionOrNull()?.message}" }
                            } else {
                                Logger.info(LogConfigSocketToClient) { "RALLY_ASSIGNMENT: Cleared survivor srvId=$srvId from old building bldId=$oldBuildingId" }
                            }
                        }
                    }
                }

                // STEP 2: Update the target building with new assignments
                val updateBuildingResult = compoundSvc.updateBuilding(buildingId) { bld ->
                    bld.copy(assignedSurvivors = survivorIds)
                }

                if (updateBuildingResult.isFailure) {
                    Logger.error(LogConfigSocketError) { "RALLY_ASSIGNMENT: Failed to update building bldId=$buildingId for playerId=$playerId: ${updateBuildingResult.exceptionOrNull()?.message}" }
                    val response = RallyAssignmentResponse(success = false)
                    send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))
                    return
                }

                // STEP 3: Update survivors that were previously assigned to THIS building but are now unassigned
                for (srvId in previouslyAssigned) {
                    if (!nonNullSurvivorIds.contains(srvId)) {
                        val updateResult = survivorSvc.updateSurvivor(srvId) { srv ->
                            srv.copy(assignmentId = null)
                        }
                        if (updateResult.isFailure) {
                            Logger.warn(LogConfigSocketError) { "RALLY_ASSIGNMENT: Failed to clear assignment for survivor srvId=$srvId: ${updateResult.exceptionOrNull()?.message}" }
                        } else {
                            Logger.info(LogConfigSocketToClient) { "RALLY_ASSIGNMENT: Cleared assignment for survivor srvId=$srvId" }
                        }
                    }
                }

                // STEP 4: Set assignment for all newly assigned survivors
                for (srvId in nonNullSurvivorIds) {
                    val updateResult = survivorSvc.updateSurvivor(srvId) { srv ->
                        srv.copy(assignmentId = buildingId)
                    }
                    if (updateResult.isFailure) {
                        Logger.error(LogConfigSocketError) { "RALLY_ASSIGNMENT: Failed to set assignment for survivor srvId=$srvId to building bldId=$buildingId: ${updateResult.exceptionOrNull()?.message}" }
                    } else {
                        Logger.info(LogConfigSocketToClient) { "RALLY_ASSIGNMENT: Assigned survivor srvId=$srvId to building bldId=$buildingId" }
                    }
                }

                val response = RallyAssignmentResponse(success = true)
                send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))

                Logger.info(LogConfigSocketToClient) { "RALLY_ASSIGNMENT: Successfully completed for building bldId=$buildingId with ${nonNullSurvivorIds.size} survivors" }
            }
        }
    }
}
