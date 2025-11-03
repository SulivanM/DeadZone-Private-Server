package server.handler.save.bounty

import context.requirePlayerContext
import dev.deadzone.socket.handler.save.SaveHandlerContext
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.handler.save.bounty.response.BountySpeedUpResponse
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import utils.JSON
import utils.LogConfigSocketToClient
import utils.Logger
import utils.SpeedUpCostCalculator

class BountySaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.BOUNTY_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        when (type) {
            SaveDataMethod.BOUNTY_VIEW -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'BOUNTY_VIEW' message [not implemented]" }
            }

            SaveDataMethod.BOUNTY_SPEED_UP -> {
                val bountyId = data["id"] as? String
                val option = data["option"] as? String

                if (bountyId == null || option == null) {
                    val responseJson = JSON.encode(
                        BountySpeedUpResponse(error = "Missing parameters", success = false, cost = 0)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return@with
                }

                Logger.info(LogConfigSocketToClient) { "'BOUNTY_SPEED_UP' message for bountyId=$bountyId with option=$option" }

                val svc = serverContext.requirePlayerContext(connection.playerId).services
                val playerFuel = svc.compound.getResources().cash
                val notEnoughCoinsErrorId = "55"

                val defaultRemainingSeconds = 3600
                val cost = SpeedUpCostCalculator.calculateCost(option, defaultRemainingSeconds)

                val response: BountySpeedUpResponse
                var resourceResponse: core.model.game.data.GameResources? = null

                if (playerFuel < cost) {
                    response = BountySpeedUpResponse(error = notEnoughCoinsErrorId, success = false, cost = cost)
                } else {
                    svc.compound.updateResource { resource ->
                        resourceResponse = resource.copy(cash = playerFuel - cost)
                        resourceResponse
                    }
                    response = BountySpeedUpResponse(error = "", success = true, cost = cost)
                    Logger.info(LogConfigSocketToClient) { "Bounty speedup processed successfully" }
                }

                val responseJson = JSON.encode(response)
                val resourceResponseJson = JSON.encode(resourceResponse)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson, resourceResponseJson)))
            }

            SaveDataMethod.BOUNTY_NEW -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'BOUNTY_NEW' message [not implemented]" }
            }

            SaveDataMethod.BOUNTY_ABANDON -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'BOUNTY_ABANDON' message [not implemented]" }
            }

            SaveDataMethod.BOUNTY_ADD -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'BOUNTY_ADD' message [not implemented]" }
            }
        }
    }
}
