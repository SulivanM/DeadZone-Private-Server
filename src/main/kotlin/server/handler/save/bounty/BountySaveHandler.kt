package server.handler.save.bounty

import context.requirePlayerContext
import server.handler.save.SaveHandlerContext
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.handler.save.bounty.response.BountySpeedUpResponse
import server.handler.save.bounty.response.BountyNewResponse
import server.handler.save.bounty.response.BountyAbandonResponse
import server.handler.save.bounty.response.BountyAddResponse
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import common.JSON
import common.LogConfigSocketToClient
import common.Logger
import core.bounty.BountyGenerationService

class BountySaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.BOUNTY_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        when (type) {
            SaveDataMethod.BOUNTY_VIEW -> {
                Logger.info(LogConfigSocketToClient) { "Received 'BOUNTY_VIEW' message - marking bounty as viewed" }
                
                val playerContext = serverContext.requirePlayerContext(connection.playerId)
                val playerId = playerContext.playerId
                
                // Load current player objects to update bounty viewed status
                val playerObjects = serverContext.db.loadPlayerObjects(playerId)
                if (playerObjects != null && playerObjects.dzBounty != null) {
                    val updatedBounty = playerObjects.dzBounty!!.copy(viewed = true)
                    val updatedPlayerObjects = playerObjects.copy(dzBounty = updatedBounty)
                    serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)
                    Logger.info(LogConfigSocketToClient) { "Bounty marked as viewed for player $playerId" }
                }
            }

            SaveDataMethod.BOUNTY_SPEED_UP -> {
                Logger.info(LogConfigSocketToClient) { "Received 'BOUNTY_SPEED_UP' message - instantly completing bounty" }
                
                val playerContext = serverContext.requirePlayerContext(connection.playerId)
                val playerId = playerContext.playerId
                val svc = playerContext.services
                val playerFuel = svc.compound.getResources().cash
                val notEnoughCoinsErrorId = "55"
                
                // Calculate cost for instant completion
                val cost = 10 // Simple fixed cost for now
                
                if (playerFuel < cost) {
                    val response = BountySpeedUpResponse(
                        error = notEnoughCoinsErrorId,
                        success = false,
                        cost = cost,
                        bounty = null,
                        nextIssue = null
                    )
                    val responseJson = JSON.encode(response)
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return@with
                }
                
                try {
                    // Deduct cost
                    var resourceResponse: core.model.game.data.GameResources? = null
                    svc.compound.updateResource { resource ->
                        resourceResponse = resource.copy(cash = playerFuel - cost)
                        resourceResponse
                    }
                    
                    // Generate a new bounty to replace the completed one
                    val newBounty = BountyGenerationService.generateInfectedBounty(playerId)
                    val nextIssueTime = BountyGenerationService.calculateNextIssueTime()
                    
                    // Save the new bounty
                    val playerObjects = serverContext.db.loadPlayerObjects(playerId)
                    if (playerObjects != null) {
                        val updatedPlayerObjects = playerObjects.copy(
                            dzBounty = newBounty,
                            nextDZBountyIssue = nextIssueTime
                        )
                        serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)
                    }
                    
                    Logger.info(LogConfigSocketToClient) { "Bounty speedup completed for player $playerId, generated new bounty ${newBounty.id}" }
                    
                    val response = BountySpeedUpResponse(
                        error = "",
                        success = true,
                        cost = cost,
                        bounty = newBounty,
                        nextIssue = nextIssueTime
                    )
                    val responseJson = JSON.encode(response)
                    val resourceResponseJson = JSON.encode(resourceResponse)
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson, resourceResponseJson)))
                    
                    // Send fuel update if resources changed (successful bounty speed-up)
                    resourceResponse?.let { res ->
                        sendMessage(server.messaging.NetworkMessage.FUEL_UPDATE, res.cash)
                    }
                } catch (e: Exception) {
                    Logger.error(LogConfigSocketToClient) { "Error in bounty speedup: ${e.message}" }
                    
                    // Try to refund
                    try {
                        svc.compound.updateResource { resource ->
                            resource.copy(cash = playerFuel)
                        }
                    } catch (refundError: Exception) {
                        Logger.error(LogConfigSocketToClient) { "Error refunding: ${refundError.message}" }
                    }
                    
                    val response = BountySpeedUpResponse(
                        error = "Failed to complete speedup",
                        success = false,
                        cost = cost,
                        bounty = null,
                        nextIssue = null
                    )
                    val responseJson = JSON.encode(response)
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                }
            }

            SaveDataMethod.BOUNTY_NEW -> {
                Logger.info(LogConfigSocketToClient) { "Received 'BOUNTY_NEW' message - generating new bounty" }
                
                val playerContext = serverContext.requirePlayerContext(connection.playerId)
                val playerId = playerContext.playerId
                
                try {
                    // Generate a new bounty
                    val newBounty = BountyGenerationService.generateInfectedBounty(playerId)
                    val nextIssueTime = BountyGenerationService.calculateNextIssueTime()
                    
                    // Save the new bounty to the database
                    val playerObjects = serverContext.db.loadPlayerObjects(playerId)
                    if (playerObjects != null) {
                        val updatedPlayerObjects = playerObjects.copy(
                            dzBounty = newBounty,
                            nextDZBountyIssue = nextIssueTime
                        )
                        serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)
                    }
                    
                    Logger.info(LogConfigSocketToClient) { "Generated new bounty ${newBounty.id} for player $playerId" }
                    
                    val response = BountyNewResponse(
                        error = "",
                        success = true,
                        bounty = newBounty,
                        nextIssue = nextIssueTime
                    )
                    val responseJson = JSON.encode(response)
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                } catch (e: Exception) {
                    Logger.error(LogConfigSocketToClient) { "Error generating bounty: ${e.message}" }
                    val response = BountyNewResponse(
                        error = "Failed to generate bounty",
                        success = false,
                        bounty = null,
                        nextIssue = null
                    )
                    val responseJson = JSON.encode(response)
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                }
            }

            SaveDataMethod.BOUNTY_ABANDON -> {
                Logger.info(LogConfigSocketToClient) { "Received 'BOUNTY_ABANDON' message - abandoning current bounty" }
                
                val playerContext = serverContext.requirePlayerContext(connection.playerId)
                val playerId = playerContext.playerId
                
                try {
                    // Load current player objects to get the bounty
                    val playerObjects = serverContext.db.loadPlayerObjects(playerId)
                    if (playerObjects != null && playerObjects.dzBounty != null) {
                        val nextIssueTime = BountyGenerationService.calculateNextIssueTime()
                        
                        // Mark bounty as abandoned and set next issue time
                        val updatedBounty = playerObjects.dzBounty!!.copy(abandoned = true)
                        val updatedPlayerObjects = playerObjects.copy(
                            dzBounty = updatedBounty,
                            nextDZBountyIssue = nextIssueTime
                        )
                        serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)
                        
                        Logger.info(LogConfigSocketToClient) { "Bounty abandoned for player $playerId" }
                        
                        val response = BountyAbandonResponse(
                            error = "",
                            success = true,
                            bounty = updatedBounty,
                            nextIssue = nextIssueTime
                        )
                        val responseJson = JSON.encode(response)
                        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    } else {
                        val response = BountyAbandonResponse(
                            error = "Player data not found",
                            success = false,
                            bounty = null,
                            nextIssue = null
                        )
                        val responseJson = JSON.encode(response)
                        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    }
                } catch (e: Exception) {
                    Logger.error(LogConfigSocketToClient) { "Error abandoning bounty: ${e.message}" }
                    val response = BountyAbandonResponse(
                        error = "Failed to abandon bounty",
                        success = false,
                        bounty = null,
                        nextIssue = null
                    )
                    val responseJson = JSON.encode(response)
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                }
            }

            SaveDataMethod.BOUNTY_ADD -> {
                Logger.info(LogConfigSocketToClient) { "Received 'BOUNTY_ADD' message - adding bounty to player" }
                
                val userId = data["userId"] as? String
                val amount = (data["amount"] as? Number)?.toInt()
                
                if (userId == null || amount == null || amount <= 0) {
                    val response = BountyAddResponse(
                        error = "Invalid parameters",
                        success = false,
                        amount = 0,
                        total = 0
                    )
                    val responseJson = JSON.encode(response)
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return@with
                }
                
                val playerContext = serverContext.requirePlayerContext(connection.playerId)
                val playerId = playerContext.playerId
                val svc = playerContext.services
                val playerFuel = svc.compound.getResources().cash
                
                if (playerFuel < amount) {
                    val response = BountyAddResponse(
                        error = "55",  // Not enough coins error ID
                        success = false,
                        amount = 0,
                        total = 0
                    )
                    val responseJson = JSON.encode(response)
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return@with
                }
                
                try {
                    // Deduct fuel from the player adding the bounty
                    var resourceResponse: core.model.game.data.GameResources? = null
                    svc.compound.updateResource { resource ->
                        resourceResponse = resource.copy(cash = playerFuel - amount)
                        resourceResponse
                    }
                    
                    // Load target player's data
                    val targetPlayerObjects = serverContext.db.loadPlayerObjects(userId)
                    
                    if (targetPlayerObjects != null) {
                        val currentBountyCap = targetPlayerObjects.bountyCap
                        val newBountyCap = currentBountyCap + amount
                        
                        // Update target player's bounty cap
                        val updatedPlayerObjects = targetPlayerObjects.copy(bountyCap = newBountyCap)
                        serverContext.db.updatePlayerObjectsJson(userId, updatedPlayerObjects)
                        
                        Logger.info(LogConfigSocketToClient) { 
                            "Added bounty of $amount to player $userId (new total: $newBountyCap)" 
                        }
                        
                        val response = BountyAddResponse(
                            error = "",
                            success = true,
                            amount = amount,
                            total = newBountyCap
                        )
                        val responseJson = JSON.encode(response)
                        val resourceResponseJson = JSON.encode(resourceResponse)
                        send(PIOSerializer.serialize(buildMsg(saveId, responseJson, resourceResponseJson)))
                        
                        // Send fuel update if resources changed (successful bounty add)
                        resourceResponse?.let { res ->
                            sendMessage(server.messaging.NetworkMessage.FUEL_UPDATE, res.cash)
                        }
                    } else {
                        // Refund if target player not found
                        svc.compound.updateResource { resource ->
                            resource.copy(cash = playerFuel)
                        }
                        
                        val response = BountyAddResponse(
                            error = "Target player not found",
                            success = false,
                            amount = 0,
                            total = 0
                        )
                        val responseJson = JSON.encode(response)
                        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    }
                } catch (e: Exception) {
                    Logger.error(LogConfigSocketToClient) { "Error adding bounty: ${e.message}" }
                    
                    // Try to refund
                    try {
                        svc.compound.updateResource { resource ->
                            resource.copy(cash = playerFuel)
                        }
                    } catch (refundError: Exception) {
                        Logger.error(LogConfigSocketToClient) { "Error refunding: ${refundError.message}" }
                    }
                    
                    val response = BountyAddResponse(
                        error = "Failed to add bounty",
                        success = false,
                        amount = 0,
                        total = 0
                    )
                    val responseJson = JSON.encode(response)
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                }
            }
        }
    }
}
