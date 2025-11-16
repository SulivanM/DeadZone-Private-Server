package server.handler.save.alliance

import server.handler.save.SaveHandlerContext
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import common.JSON
import common.LogConfigSocketToClient
import common.Logger
import common.toJsonElement

class AllianceSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.ALLIANCE_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        when (type) {
            SaveDataMethod.ALLIANCE_CREATE -> {
                handleAllianceCreate(ctx)
            }

            SaveDataMethod.ALLIANCE_COLLECT_WINNINGS -> {
                handleAllianceCollectWinnings(ctx)
            }

            SaveDataMethod.ALLIANCE_QUERY_WINNINGS -> {
                handleAllianceQueryWinnings(ctx)
            }

            SaveDataMethod.ALLIANCE_GET_PREV_ROUND_RESULT -> {
                handleAllianceGetPrevRoundResults(ctx)
            }

            SaveDataMethod.ALLIANCE_EFFECT_UPDATE -> {
                handleAllianceEffectUpdate(ctx)
            }

            SaveDataMethod.ALLIANCE_INFORM_ABOUT_LEAVE -> {
                handleAllianceInformAboutLeave(ctx)
            }

            SaveDataMethod.ALLIANCE_GET_LIFETIMESTATS -> {
                handleAllianceGetLifetimeStats(ctx)
            }
        }
    }

    private suspend fun handleAllianceCreate(ctx: SaveHandlerContext) = with(ctx) {
        Logger.info(LogConfigSocketToClient) { "Received 'ALLIANCE_CREATE' message" }

        val playerId = connection.playerId
        val allianceName = data["name"] as? String
        val allianceTag = data["tag"] as? String
        val bannerBytes = data["bannerBytes"] as? String
        val thumbImage = data["thumbImage"] as? String

        if (allianceName == null || allianceTag == null || bannerBytes == null || thumbImage == null) {
            Logger.error(LogConfigSocketToClient) { "ALLIANCE_CREATE: Missing required parameters" }
            val responseData = mapOf(
                "success" to false,
                "nameSuccess" to false,
                "tagSuccess" to false,
                "error" to "Missing required parameters"
            )
            val responseJson = JSON.encode(responseData.toJsonElement())
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            return@with
        }

        // Check if name already exists
        val nameExists = serverContext.db.allianceNameExists(allianceName)
        val tagExists = serverContext.db.allianceTagExists(allianceTag)

        if (nameExists || tagExists) {
            Logger.info(LogConfigSocketToClient) { "ALLIANCE_CREATE: Name or tag already exists (name=$nameExists, tag=$tagExists)" }
            val responseData = mapOf(
                "success" to false,
                "nameSuccess" to !nameExists,
                "tagSuccess" to !tagExists
            )
            val responseJson = JSON.encode(responseData.toJsonElement())
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            return@with
        }

        // Generate alliance ID
        val allianceId = common.UUID.new()

        // Create alliance in database
        val created = serverContext.db.createAlliance(
            allianceId = allianceId,
            name = allianceName,
            tag = allianceTag,
            bannerBytes = bannerBytes,
            thumbImage = thumbImage,
            creatorPlayerId = playerId
        )

        if (!created) {
            Logger.error(LogConfigSocketToClient) { "ALLIANCE_CREATE: Failed to create alliance in database" }
            val responseData = mapOf(
                "success" to false,
                "nameSuccess" to true,
                "tagSuccess" to true,
                "error" to "Failed to create alliance"
            )
            val responseJson = JSON.encode(responseData.toJsonElement())
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            return@with
        }

        // Update player's alliance info
        val playerObjects = serverContext.db.loadPlayerObjects(playerId)
        if (playerObjects != null) {
            val updatedPlayerObjects = playerObjects.copy(
                allianceId = allianceId,
                allianceTag = allianceTag
            )
            serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)
        }

        Logger.info(LogConfigSocketToClient) { "ALLIANCE_CREATE: Successfully created alliance $allianceName ($allianceTag) with ID $allianceId" }

        // Return success response with alliance info
        val responseData = mapOf(
            "success" to true,
            "nameSuccess" to true,
            "tagSuccess" to true,
            "allianceId" to allianceId,
            "allianceTag" to allianceTag
        )
        val responseJson = JSON.encode(responseData.toJsonElement())
        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
    }

    private suspend fun handleAllianceCollectWinnings(ctx: SaveHandlerContext) = with(ctx) {
        Logger.info(LogConfigSocketToClient) { "Received 'ALLIANCE_COLLECT_WINNINGS' message" }

        val playerId = connection.playerId
        val playerObjects = serverContext.db.loadPlayerObjects(playerId)

        if (playerObjects == null) {
            Logger.error(LogConfigSocketToClient) { "PlayerObjects not found for playerId=$playerId" }
            val responseData = mapOf(
                "success" to false,
                "error" to "Player data not found"
            )
            val responseJson = JSON.encode(responseData.toJsonElement())
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            return@with
        }

        val winnings = playerObjects.allianceWinnings
        if (winnings.uncollected <= 0) {
            val responseData = mapOf(
                "success" to false,
                "error" to "No winnings to collect"
            )
            val responseJson = JSON.encode(responseData.toJsonElement())
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            return@with
        }

        // Add the uncollected winnings to player's cash
        val updatedResources = playerObjects.resources.copy(
            cash = playerObjects.resources.cash + winnings.uncollected
        )

        // Reset uncollected winnings to 0
        val updatedWinnings = winnings.copy(uncollected = 0)

        val updatedPlayerObjects = playerObjects.copy(
            resources = updatedResources,
            allianceWinnings = updatedWinnings
        )

        // Save to database
        serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)

        val responseData = mapOf(
            "success" to true,
            "amount" to winnings.uncollected
        )
        val responseJson = JSON.encode(responseData)
        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
    }

    private suspend fun handleAllianceQueryWinnings(ctx: SaveHandlerContext) = with(ctx) {
        Logger.info(LogConfigSocketToClient) { "Received 'ALLIANCE_QUERY_WINNINGS' message" }

        val playerId = connection.playerId
        val playerObjects = serverContext.db.loadPlayerObjects(playerId)

        if (playerObjects == null) {
            Logger.error(LogConfigSocketToClient) { "PlayerObjects not found for playerId=$playerId" }
            val responseData = mapOf(
                "uncollected" to 0,
                "lifetime" to 0
            )
            val responseJson = JSON.encode(responseData.toJsonElement())
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            return@with
        }

        val winnings = playerObjects.allianceWinnings
        val responseData = mapOf(
            "uncollected" to winnings.uncollected,
            "lifetime" to winnings.lifetime
        )
        val responseJson = JSON.encode(responseData)
        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
    }

    private suspend fun handleAllianceGetPrevRoundResults(ctx: SaveHandlerContext) = with(ctx) {
        Logger.info(LogConfigSocketToClient) { "Received 'ALLIANCE_GET_PREV_ROUND_RESULT' message" }

        // Alliance PvP rounds not yet implemented - return empty results
        // Client expects: { available: boolean, list: Array }
        val responseData = mapOf(
            "available" to false,
            "list" to emptyList<Any>()
        )
        val responseJson = JSON.encode(responseData)
        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
    }

    private suspend fun handleAllianceEffectUpdate(ctx: SaveHandlerContext) = with(ctx) {
        val allianceId = data["id"] as? String
        Logger.info(LogConfigSocketToClient) { "Received 'ALLIANCE_EFFECT_UPDATE' for allianceId=$allianceId" }

        // Alliance effects system not yet fully implemented
        // For now, acknowledge the update without error to avoid blocking the client
        // In a full implementation, this would save the alliance effect state to the database

        val responseData = mapOf(
            "success" to true
        )
        val responseJson = JSON.encode(responseData)
        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
    }

    private suspend fun handleAllianceInformAboutLeave(ctx: SaveHandlerContext) = with(ctx) {
        val allianceId = data["allianceId"] as? String
        Logger.info(LogConfigSocketToClient) { "Received 'ALLIANCE_INFORM_ABOUT_LEAVE' for allianceId=$allianceId" }

        val playerId = connection.playerId
        val playerObjects = serverContext.db.loadPlayerObjects(playerId)

        if (playerObjects == null) {
            Logger.error(LogConfigSocketToClient) { "PlayerObjects not found for playerId=$playerId" }
            val responseData = mapOf(
                "success" to false,
                "error" to "Player data not found"
            )
            val responseJson = JSON.encode(responseData.toJsonElement())
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            return@with
        }

        // Remove player from alliance (clear allianceId and allianceTag)
        // Keep allianceWinnings so player can still collect any pending rewards
        val updatedPlayerObjects = playerObjects.copy(
            allianceId = null,
            allianceTag = null
        )

        // Save to database
        serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)

        Logger.info(LogConfigSocketToClient) {
            "Player $playerId successfully left alliance $allianceId"
        }

        val responseData = mapOf(
            "success" to true
        )
        val responseJson = JSON.encode(responseData)
        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
    }

    private suspend fun handleAllianceGetLifetimeStats(ctx: SaveHandlerContext) = with(ctx) {
        Logger.info(LogConfigSocketToClient) { "Received 'ALLIANCE_GET_LIFETIMESTATS' message" }

        val playerId = connection.playerId
        val playerObjects = serverContext.db.loadPlayerObjects(playerId)

        if (playerObjects == null) {
            Logger.error(LogConfigSocketToClient) { "PlayerObjects not found for playerId=$playerId" }
            // Return default stats if player not found
            val responseJson = JSON.encode(mapOf(
                "available" to true,
                "points" to 0,
                "wins" to 0,
                "losses" to 0,
                "abandons" to 0,
                "defWins" to 0,
                "defLosses" to 0,
                "pointsAttack" to 0,
                "pointsDefend" to 0,
                "missionSuccess" to 0,
                "missionFail" to 0,
                "missionAbandon" to 0,
                "pointsMission" to 0
            ).toJsonElement())
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            return@with
        }

        // Get lifetime stats from player data, or use defaults if not available
        val stats = playerObjects.allianceLifetimeStats
        val responseJson = if (stats != null) {
            JSON.encode(mapOf(
                "available" to true,
                "points" to stats.points,
                "wins" to stats.wins,
                "losses" to stats.losses,
                "abandons" to stats.abandons,
                "defWins" to stats.defWins,
                "defLosses" to stats.defLosses,
                "pointsAttack" to stats.pointsAttack,
                "pointsDefend" to stats.pointsDefend,
                "missionSuccess" to stats.missionSuccess,
                "missionFail" to stats.missionFail,
                "missionAbandon" to stats.missionAbandon,
                "pointsMission" to stats.pointsMission
            ).toJsonElement())
        } else {
            // Return default stats if player has no alliance stats yet
            JSON.encode(mapOf(
                "available" to true,
                "points" to 0,
                "wins" to 0,
                "losses" to 0,
                "abandons" to 0,
                "defWins" to 0,
                "defLosses" to 0,
                "pointsAttack" to 0,
                "pointsDefend" to 0,
                "missionSuccess" to 0,
                "missionFail" to 0,
                "missionAbandon" to 0,
                "pointsMission" to 0
            ).toJsonElement())
        }

        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
    }
}
