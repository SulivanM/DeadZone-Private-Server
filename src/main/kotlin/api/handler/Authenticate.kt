package dev.deadzone.api.handler

import dev.deadzone.API_SERVER_HOST
import dev.deadzone.api.message.auth.AuthenticateArgs
import dev.deadzone.api.message.auth.AuthenticateOutput
import dev.deadzone.api.utils.pioFraming
import dev.deadzone.context.ServerContext
import dev.deadzone.core.data.AdminData
import dev.deadzone.utils.Logger
import dev.deadzone.utils.logInput
import dev.deadzone.utils.logOutput
import io.ktor.http.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.utils.io.*
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf

/**
 * Authenticate (API 13)
 *
 * Input: `AuthenticateArgs`
 *
 * Output: `AuthenticateOutput`
 */
@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.authenticate(serverContext: ServerContext) {
    val authenticateArgs = ProtoBuf.decodeFromByteArray<AuthenticateArgs>(
        call.receiveChannel().toByteArray()
    )

    logInput(authenticateArgs)

    val userToken = authenticateArgs
        .authenticationArguments
        .find { it.key == "userToken" }?.value

    if (userToken == null) {
        Logger.error { "Missing userToken in API 13 request" }
        call.respond(HttpStatusCode.BadRequest, "userToken is missing")
        return
    }

    val authenticateOutput = if (userToken == AdminData.TOKEN) {
        Logger.info { "auth by admin" }
        AuthenticateOutput.admin()
    } else {
        val isValidToken = serverContext.sessionManager.verify(userToken)
        if (isValidToken) {
            AuthenticateOutput(
                token = userToken,
                userId = serverContext.sessionManager.getPlayerId(userToken)!!,
                apiServerHosts = listOf(API_SERVER_HOST)
            )
        } else {
            call.respond(HttpStatusCode.Unauthorized, "token is invalid")
            null
        }
    } ?: return

    val encodedOutput = ProtoBuf.encodeToByteArray<AuthenticateOutput>(
        authenticateOutput
    )

    logOutput(encodedOutput)

    call.respondBytes(encodedOutput.pioFraming())
}
