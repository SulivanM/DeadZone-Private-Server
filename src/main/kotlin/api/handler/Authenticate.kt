package api.handler
import dev.deadzone.SERVER_HOST
import api.message.auth.AuthenticateArgs
import api.message.auth.AuthenticateOutput
import dev.deadzone.api.utils.pioFraming
import dev.deadzone.context.ServerContext
import dev.deadzone.core.data.AdminData
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
                apiServerHosts = listOf(SERVER_HOST)
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