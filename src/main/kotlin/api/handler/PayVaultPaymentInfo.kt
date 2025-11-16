package api.handler

import api.message.payvault.PayVaultPaymentInfoArgs
import api.message.payvault.PayVaultPaymentInfoOutput
import api.protocol.pioFraming
import io.ktor.http.HttpStatusCode
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.utils.io.*
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf
import common.Logger
import common.logInput
import common.logOutput

@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.payVaultPaymentInfo() {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        Logger.error { "payVaultPaymentInfo: failed to read request body: ${e.message}" }
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    val payVaultPaymentInfoArgs = try {
        ProtoBuf.decodeFromByteArray<PayVaultPaymentInfoArgs>(body)
    } catch (e: Exception) {
        Logger.error { "payVaultPaymentInfo: failed to decode args: ${e.message}" }
        call.respond(HttpStatusCode.BadRequest, "invalid_payload")
        return
    }

    logInput(payVaultPaymentInfoArgs, disableLogging = true)

    // For now, return a dummy response as PayVault is not fully implemented
    val payVaultPaymentInfoOutput = PayVaultPaymentInfoOutput.dummy()

    val encodedOutput = try {
        ProtoBuf.encodeToByteArray(payVaultPaymentInfoOutput)
    } catch (e: Exception) {
        Logger.error { "payVaultPaymentInfo: failed to encode output: ${e.message}" }
        call.respond(HttpStatusCode.InternalServerError, "encode_error")
        return
    }

    logOutput(encodedOutput, disableLogging = true)

    call.respondBytes(encodedOutput.pioFraming())
}
