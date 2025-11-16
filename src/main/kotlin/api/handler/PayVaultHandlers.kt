package api.handler

import api.message.payvault.*
import api.protocol.pioFraming
import context.ServerContext
import data.collection.PayVaultData
import data.collection.PayVaultItemData
import common.UUID
import common.logInput
import common.logOutput
import io.ktor.http.HttpStatusCode
import io.ktor.server.request.receiveChannel
import io.ktor.server.response.respond
import io.ktor.server.response.respondBytes
import io.ktor.server.routing.RoutingContext
import io.ktor.utils.io.toByteArray
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf

/**
 * Convert PayVaultData to PayVaultRefreshOutput
 */
private fun PayVaultData.toOutput(): PayVaultRefreshOutput {
    return PayVaultRefreshOutput(
        version = version,
        coins = coins,
        items = items.map { item ->
            PayVaultItem(
                id = item.id,
                itemKey = item.itemKey,
                purchaseDate = item.purchaseDate
            )
        }
    )
}

/**
 * Read PayVault transaction history
 * Endpoint 160
 */
@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.payVaultReadHistory(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    logInput("PayVaultReadHistory", disableLogging = true)

    // Return empty history for now
    val output = PayVaultRefreshOutput(
        version = System.currentTimeMillis().toString(),
        coins = 0,
        items = emptyList()
    )
    val encoded = ProtoBuf.encodeToByteArray(output)
    logOutput(encoded, disableLogging = true)
    call.respondBytes(encoded.pioFraming())
}

/**
 * Refresh PayVault to get current state
 * Endpoint 163
 */
@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.payVaultRefresh(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    val args = try {
        ProtoBuf.decodeFromByteArray<PayVaultRefreshArgs>(body)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_payload")
        return
    }

    logInput(args, disableLogging = false)

    // Get playerId from token
    val playerId = getPlayerIdFromToken(serverContext)
    if (playerId == null) {
        call.respond(HttpStatusCode.Unauthorized, "invalid_token")
        return
    }

    // Load actual PayVault data from database
    val payVault = serverContext.db.loadPayVault(playerId) ?: PayVaultData.empty(playerId)
    val output = payVault.toOutput()

    val encoded = ProtoBuf.encodeToByteArray(output)
    logOutput(encoded, disableLogging = false)
    call.respondBytes(encoded.pioFraming())
}

/**
 * Consume PayVault items
 * Endpoint 166
 */
@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.payVaultConsume(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    val args = try {
        ProtoBuf.decodeFromByteArray<PayVaultConsumeArgs>(body)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_payload")
        return
    }

    logInput(args, disableLogging = false)

    // Get playerId from token or use targetUserId
    val playerId = if (args.targetUserId.isNotEmpty()) {
        args.targetUserId
    } else {
        getPlayerIdFromToken(serverContext) ?: run {
            call.respond(HttpStatusCode.Unauthorized, "invalid_token")
            return
        }
    }

    // Consume items from vault
    val updatedVault = try {
        serverContext.db.consumeItems(playerId, args.ids)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, e.message ?: "consume_failed")
        return
    }

    val output = updatedVault.toOutput()
    val encoded = ProtoBuf.encodeToByteArray(output)
    logOutput(encoded, disableLogging = false)
    call.respondBytes(encoded.pioFraming())
}

/**
 * Credit coins to PayVault
 * Endpoint 169
 */
@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.payVaultCredit(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    val args = try {
        ProtoBuf.decodeFromByteArray<PayVaultCreditArgs>(body)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_payload")
        return
    }

    logInput(args, disableLogging = false)

    // Get playerId from token or use targetUserId
    val playerId = if (args.targetUserId.isNotEmpty()) {
        args.targetUserId
    } else {
        getPlayerIdFromToken(serverContext) ?: run {
            call.respond(HttpStatusCode.Unauthorized, "invalid_token")
            return
        }
    }

    // Credit coins to vault
    val updatedVault = try {
        serverContext.db.creditCoins(playerId, args.amount.toLong(), args.reason)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, e.message ?: "credit_failed")
        return
    }

    val output = updatedVault.toOutput()
    val encoded = ProtoBuf.encodeToByteArray(output)
    logOutput(encoded, disableLogging = false)
    call.respondBytes(encoded.pioFraming())
}

/**
 * Debit coins from PayVault
 * Endpoint 172
 */
@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.payVaultDebit(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    val args = try {
        ProtoBuf.decodeFromByteArray<PayVaultDebitArgs>(body)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_payload")
        return
    }

    logInput(args, disableLogging = false)

    // Get playerId from token or use targetUserId
    val playerId = if (args.targetUserId.isNotEmpty()) {
        args.targetUserId
    } else {
        getPlayerIdFromToken(serverContext) ?: run {
            call.respond(HttpStatusCode.Unauthorized, "invalid_token")
            return
        }
    }

    // Debit coins from vault
    val updatedVault = try {
        serverContext.db.debitCoins(playerId, args.amount.toLong(), args.reason)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, e.message ?: "debit_failed")
        return
    }

    val output = updatedVault.toOutput()
    val encoded = ProtoBuf.encodeToByteArray(output)
    logOutput(encoded, disableLogging = false)
    call.respondBytes(encoded.pioFraming())
}

/**
 * Buy items with PayVault coins
 * Endpoint 175
 */
@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.payVaultBuy(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    val args = try {
        ProtoBuf.decodeFromByteArray<PayVaultBuyArgs>(body)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_payload")
        return
    }

    logInput(args, disableLogging = false)

    // Get playerId from token
    val playerId = getPlayerIdFromToken(serverContext)
    if (playerId == null) {
        call.respond(HttpStatusCode.Unauthorized, "invalid_token")
        return
    }

    // Process purchase: create items to give
    val itemsToGive = args.items.map { buyInfo ->
        PayVaultItemData(
            id = UUID.new(),
            itemKey = buyInfo.itemKey,
            purchaseDate = System.currentTimeMillis()
        )
    }

    // Give items to vault (this also updates version)
    val updatedVault = try {
        serverContext.db.giveItems(playerId, itemsToGive)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, e.message ?: "buy_failed")
        return
    }

    val output = updatedVault.toOutput()
    val encoded = ProtoBuf.encodeToByteArray(output)
    logOutput(encoded, disableLogging = false)
    call.respondBytes(encoded.pioFraming())
}

/**
 * Give items to player (admin/promotional)
 * Endpoint 178
 */
@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.payVaultGive(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    val args = try {
        ProtoBuf.decodeFromByteArray<PayVaultGiveArgs>(body)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_payload")
        return
    }

    logInput(args, disableLogging = false)

    // Get playerId from token
    val playerId = getPlayerIdFromToken(serverContext)
    if (playerId == null) {
        call.respond(HttpStatusCode.Unauthorized, "invalid_token")
        return
    }

    // Create items to give
    val itemsToGive = args.items.map { item ->
        PayVaultItemData(
            id = UUID.new(),
            itemKey = item.itemKey,
            purchaseDate = System.currentTimeMillis()
        )
    }

    // Add items to vault
    val updatedVault = try {
        serverContext.db.giveItems(playerId, itemsToGive)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, e.message ?: "give_failed")
        return
    }

    val output = updatedVault.toOutput()
    val encoded = ProtoBuf.encodeToByteArray(output)
    logOutput(encoded, disableLogging = false)
    call.respondBytes(encoded.pioFraming())
}

/**
 * Use payment info (complete a payment flow)
 * Endpoint 184
 */
@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.payVaultUsePaymentInfo(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    logInput("PayVaultUsePaymentInfo", disableLogging = true)

    // Return updated vault after payment
    val output = PayVaultRefreshOutput(
        version = System.currentTimeMillis().toString(),
        coins = 0,
        items = emptyList()
    )
    val encoded = ProtoBuf.encodeToByteArray(output)
    logOutput(encoded, disableLogging = true)
    call.respondBytes(encoded.pioFraming())
}
