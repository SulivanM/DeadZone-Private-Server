package server.handler.save.purchase

import context.requirePlayerContext
import server.handler.save.SaveHandlerContext
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import common.JSON
import common.LogConfigSocketToClient
import common.Logger
import common.toJsonElement

class PurchaseSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.PURCHASE_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        when (type) {
            SaveDataMethod.RESOURCE_BUY -> {
                handleResourceBuy(ctx)
            }

            SaveDataMethod.PROTECTION_BUY -> {
                handleProtectionBuy(ctx)
            }

            SaveDataMethod.PAYVAULT_BUY -> {
                handlePayvaultBuy(ctx)
            }

            SaveDataMethod.CLAIM_PROMO_CODE -> {
                handleClaimPromoCode(ctx)
            }

            SaveDataMethod.BUY_PACKAGE -> {
                handleBuyPackage(ctx)
            }

            SaveDataMethod.CHECK_APPLY_DIRECT_PURCHASE -> {
                handleCheckApplyDirectPurchase(ctx)
            }

            SaveDataMethod.HAS_PAYVAULT_ITEM -> {
                handleHasPayvaultItem(ctx)
            }

            SaveDataMethod.INCREMENT_PURCHASE_COUNT -> {
                handleIncrementPurchaseCount(ctx)
            }

            SaveDataMethod.DEATH_MOBILE_RENAME -> {
                handleDeathMobileRename(ctx)
            }
        }
    }

    private suspend fun handleResourceBuy(ctx: SaveHandlerContext) = with(ctx) {
        val option = data["option"] as? String
        Logger.info(LogConfigSocketToClient) { "RESOURCE_BUY: option=$option [placeholder - requires payment integration]" }

        // Placeholder - requires payment gateway integration
        val responseData = mapOf(
            "success" to false,
            "error" to "Payment system not available"
        )
        val responseJson = JSON.encode(responseData.toJsonElement())
        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
    }

    private suspend fun handleProtectionBuy(ctx: SaveHandlerContext) = with(ctx) {
        val protection = data["protection"] as? String
        Logger.info(LogConfigSocketToClient) { "PROTECTION_BUY: protection=$protection [placeholder - requires payment integration]" }

        // Placeholder - requires payment gateway integration
        val responseData = mapOf(
            "success" to false,
            "error" to "Payment system not available"
        )
        val responseJson = JSON.encode(responseData.toJsonElement())
        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
    }

    private suspend fun handlePayvaultBuy(ctx: SaveHandlerContext) = with(ctx) {
        Logger.info(LogConfigSocketToClient) { "PAYVAULT_BUY: [placeholder - requires payment integration]" }

        // Placeholder - requires PayVault integration
        val responseData = mapOf(
            "success" to false,
            "error" to "Payment system not available"
        )
        val responseJson = JSON.encode(responseData.toJsonElement())
        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
    }

    private suspend fun handleClaimPromoCode(ctx: SaveHandlerContext) = with(ctx) {
        val code = data["code"] as? String
        Logger.info(LogConfigSocketToClient) { "CLAIM_PROMO_CODE: code=$code [placeholder implementation]" }

        // Placeholder - promo code system not implemented
        val responseData = mapOf(
            "success" to false,
            "error" to "code_not_found"
        )
        val responseJson = JSON.encode(responseData.toJsonElement())
        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
    }

    private suspend fun handleBuyPackage(ctx: SaveHandlerContext) = with(ctx) {
        val packId = data["pack"] as? String

        if (packId == null) {
            Logger.error(LogConfigSocketToClient) { "BUY_PACKAGE: Missing 'pack' parameter" }
            val responseData = mapOf(
                "success" to false,
                "error" to "Missing package ID"
            )
            val responseJson = JSON.encode(responseData.toJsonElement())
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            return
        }

        try {
            val playerId = connection.playerId
            val services = serverContext.requirePlayerContext(playerId).services

            // Get the offer from OfferService
            val offer = server.service.OfferService.getAllOffers().find { it.id == packId }

            if (offer == null) {
                Logger.error(LogConfigSocketToClient) { "BUY_PACKAGE: Offer not found: $packId" }
                val responseData = mapOf(
                    "success" to false,
                    "error" to "Offer not found"
                )
                val responseJson = JSON.encode(responseData.toJsonElement())
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                return
            }

            // Get current resources
            val currentResources = services.compound.getResources()
            val priceCoins = offer.PriceCoins ?: 0
            val fuel = offer.fuel ?: 0

            // Check if player has enough coins (if offer requires coins)
            if (priceCoins > 0) {
                if (currentResources.cash < priceCoins) {
                    Logger.info(LogConfigSocketToClient) { "BUY_PACKAGE: Not enough coins for $packId (has: ${currentResources.cash}, needs: $priceCoins)" }
                    val responseData = mapOf(
                        "success" to false,
                        "error" to "NotEnoughCoins"
                    )
                    val responseJson = JSON.encode(responseData.toJsonElement())
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }
            }

            // Deduct coins and add fuel (NO bonus items for fuel dialogue)
            services.compound.updateResource { resources ->
                resources.copy(
                    cash = resources.cash - priceCoins + fuel
                )
            }

            // Get the updated resources to send fuel update to client
            val updatedResources = services.compound.getResources()

            // Build dbItem (offer metadata that client needs)
            val dbItem = buildMap<String, Any> {
                put("type", offer.type)
                put("key", offer.id)
                offer.priority?.let { put("priority", it) }
                offer.image?.let { put("image", it) }
            }

            Logger.info(LogConfigSocketToClient) { "BUY_PACKAGE: Successfully purchased $packId for $priceCoins coins, new fuel balance: ${updatedResources.cash}" }

            // Build response matching AS3 client expectations
            // NO ITEMS - Removed bonus items for fuel dialogue as requested
            val responseData = buildMap<String, Any> {
                put("success", true)
                put("dbItem", dbItem)
                put("items", emptyList<Any>()) // No bonus items for fuel dialogue

                // Optional fields
                offer.oneTime?.let { put("oneTime", it) }
                // cooldown would be added here if needed (Base64 encoded)
            }

            val responseJson = JSON.encode(responseData.toJsonElement())
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

            // Send fuel update message to client so the UI updates immediately
            sendMessage(server.messaging.NetworkMessage.FUEL_UPDATE, updatedResources.cash)

        } catch (e: Exception) {
            Logger.error(LogConfigSocketToClient) { "BUY_PACKAGE: Error processing purchase: ${e.message}" }
            e.printStackTrace()

            val responseData = mapOf(
                "success" to false,
                "error" to "Purchase failed"
            )
            val responseJson = JSON.encode(responseData.toJsonElement())
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        }
    }

    private suspend fun handleCheckApplyDirectPurchase(ctx: SaveHandlerContext) = with(ctx) {
        Logger.info(LogConfigSocketToClient) { "CHECK_APPLY_DIRECT_PURCHASE: [placeholder implementation]" }

        // Placeholder
        val responseData = mapOf(
            "success" to false
        )
        val responseJson = JSON.encode(responseData.toJsonElement())
        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
    }

    private suspend fun handleHasPayvaultItem(ctx: SaveHandlerContext) = with(ctx) {
        val key = data["key"] as? String
        Logger.info(LogConfigSocketToClient) { "HAS_PAYVAULT_ITEM: key=$key [placeholder implementation]" }

        // Placeholder - PayVault not implemented
        val responseData = mapOf(
            "has" to false,
            "error" to null
        )
        val responseJson = JSON.encode(responseData.toJsonElement())
        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
    }

    private suspend fun handleIncrementPurchaseCount(ctx: SaveHandlerContext) = with(ctx) {
        val playerId = connection.playerId
        Logger.info(LogConfigSocketToClient) { "INCREMENT_PURCHASE_COUNT: playerId=$playerId" }

        try {
            // Increment purchase count in player metadata
            val services = serverContext.requirePlayerContext(playerId).services
            // This would need a purchase counter field in player data
            // For now, just acknowledge the request

            val responseData = mapOf(
                "success" to true
            )
            val responseJson = JSON.encode(responseData.toJsonElement())
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        } catch (e: Exception) {
            Logger.error(LogConfigSocketToClient) { "INCREMENT_PURCHASE_COUNT: Error: ${e.message}" }
            val responseData = mapOf(
                "success" to false
            )
            val responseJson = JSON.encode(responseData.toJsonElement())
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        }
    }

    private suspend fun handleDeathMobileRename(ctx: SaveHandlerContext) = with(ctx) {
        Logger.info(LogConfigSocketToClient) { "DEATH_MOBILE_RENAME: [placeholder implementation]" }

        // Placeholder - Death Mobile feature not implemented
        val responseData = mapOf(
            "success" to false,
            "error" to "Feature not available"
        )
        val responseJson = JSON.encode(responseData.toJsonElement())
        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
    }
}
