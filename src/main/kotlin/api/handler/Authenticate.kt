package api.handler

import api.message.auth.AuthenticateArgs
import api.message.auth.AuthenticateOutput
import api.utils.pioFraming
import context.ServerContext
import core.data.AdminData
import dev.deadzone.AppConfig
import utils.Logger
import utils.logInput
import utils.logOutput
import io.ktor.http.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.utils.io.*
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf

@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.authenticate(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        Logger.error { "authenticate: failed to read request body: ${e.message}" }
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    val authenticateArgs = try {
        ProtoBuf.decodeFromByteArray<AuthenticateArgs>(body)
    } catch (e: Exception) {
        Logger.error { "authenticate: failed to decode args: ${e.message}" }
        call.respond(HttpStatusCode.BadRequest, "invalid_payload")
        return
    }

    logInput(authenticateArgs, disableLogging = true)

    val userToken = authenticateArgs
        .authenticationArguments
        .find { it.key == "userToken" }?.value

    if (userToken.isNullOrBlank()) {
        Logger.error { "Client-error: missing userToken in API 13 request" }
        call.respond(HttpStatusCode.BadRequest, "userToken is missing")
        return
    }

    val authenticateOutput = if (userToken == AdminData.TOKEN) {
        AuthenticateOutput.admin()
    } else {
        val isValid = try {
            serverContext.sessionManager.verify(userToken)
        } catch (e: Exception) {
            Logger.error { "authenticate: session verification failed: ${e.message}" }
            false
        }

        if (!isValid) {
            call.respond(HttpStatusCode.Unauthorized, "token is invalid, try re-login")
            return
        }

        val playerId = try {
            serverContext.sessionManager.getPlayerId(userToken)
        } catch (e: Exception) {
            Logger.error { "authenticate: failed to get playerId from session: ${e.message}" }
            null
        }

        if (playerId.isNullOrBlank()) {
            call.respond(HttpStatusCode.InternalServerError, "failed to resolve player")
            return
        }

        AuthenticateOutput(
            token = userToken,
            userId = playerId,
            apiServerHosts = listOf(AppConfig.gameHost)
        )
    }

    val encodedOutput = try {
        ProtoBuf.encodeToByteArray(authenticateOutput)
    } catch (e: Exception) {
        Logger.error { "authenticate: failed to encode output: ${e.message}" }
        call.respond(HttpStatusCode.InternalServerError, "encode_error")
        return
    }

    logOutput(encodedOutput, disableLogging = true)

    call.respondBytes(encodedOutput.pioFraming())
}
