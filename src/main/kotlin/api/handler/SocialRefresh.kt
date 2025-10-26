package api.handler

import api.message.social.SocialProfile
import api.message.social.SocialRefreshOutput
import api.utils.pioFraming
import context.ServerContext
import core.data.AdminData
import utils.LogConfigAPIError
import utils.Logger
import utils.logInput
import utils.logOutput
import io.ktor.http.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.utils.io.*
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf

@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.socialRefresh(serverContext: ServerContext, token: String?) {
    if (token.isNullOrBlank()) {
        call.respond(HttpStatusCode.Unauthorized, "missing_token")
        return
    }

    val pid = runCatching { serverContext.sessionManager.getPlayerId(token) }.getOrNull()
    if (pid.isNullOrBlank()) {
        call.respond(HttpStatusCode.Unauthorized, "invalid_token")
        return
    }

    val profile = serverContext.playerAccountRepository.getProfileOfPlayerId(pid).getOrNull()
    if (profile == null) {
        Logger.error(LogConfigAPIError) { "Profile not found for playerId=$pid" }
        call.respond(HttpStatusCode.InternalServerError, "profile_missing")
        return
    }

    val output = if (pid == AdminData.PLAYER_ID) {
        SocialRefreshOutput.admin()
    } else {
        SocialRefreshOutput(
            myProfile = SocialProfile(
                userId = pid,
                displayName = profile.displayName,
                avatarUrl = profile.avatarUrl,
                lastOnline = profile.lastLogin,
                countryCode = profile.countryCode ?: "",
                userToken = token
            ),
            friends = emptyList(),
            blocked = ""
        )
    }

    val encoded = ProtoBuf.encodeToByteArray(output)
    logOutput(encoded, disableLogging = true)
    call.respondBytes(encoded.pioFraming())
}