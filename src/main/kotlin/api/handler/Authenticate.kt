package api.handler

import api.message.auth.AuthenticateArgs
import api.message.auth.AuthenticateOutput
import api.utils.pioFraming
import context.ServerContext
import core.data.AdminData
import dev.deadzone.SERVER_HOST
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
    val authenticateArgs = ProtoBuf.decodeFromByteArray<AuthenticateArgs>(
        call.receiveChannel().toByteArray()
    )

    logInput(authenticateArgs, disableLogging = true)

    val userToken = authenticateArgs
        .authenticationArguments
        .find { it.key == "userToken" }?.value

    if (userToken == null) {
        Logger.error { "Client-error: missing userToken in API 13 request" }
        call.respond(HttpStatusCode.BadRequest, "userToken is missing")
        return
    }

    val authenticateOutput = if (userToken == AdminData.TOKEN) {
        AuthenticateOutput.admin()
    } else {
        val isValidToken = serverContext.sessionManager.verify(userToken)
        if (isValidToken) {
            AuthenticateOutput(
                token = userToken,
                userId = serverContext.sessionManager.getPlayerId(userToken)!!,
                apiServerHosts = listOf(SERVER_HOST)
            )
        } else {
            call.respond(HttpStatusCode.Unauthorized, "token is invalid, try re-login")
            null
        }
    } ?: return

    val encodedOutput = ProtoBuf.encodeToByteArray<AuthenticateOutput>(
        authenticateOutput
    )

    logOutput(encodedOutput, disableLogging = true)

    call.respondBytes(encodedOutput.pioFraming())
}