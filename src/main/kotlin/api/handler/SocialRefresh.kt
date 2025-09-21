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
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.utils.io.*
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf

@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.socialRefresh(serverContext: ServerContext, token: String) {
    val socialRefreshArgs = call.receiveChannel().toByteArray() // Actually no input is given
    logInput(socialRefreshArgs.decodeToString())
    val pid = serverContext.sessionManager.getPlayerId(token)!!
    val result = serverContext.playerAccountRepository.getProfileOfPlayerId(pid)
    result.onFailure {
        Logger.error(LogConfigAPIError) { "Failure on getProfileOfPlayerId for playerId=$pid: ${it.message}" }
    }
    val userProfile = requireNotNull(result.getOrThrow()) {
        "getProfileOfPlayerId succeed but returned profile is null"
    }
    val socialRefreshOutput = if (pid == AdminData.PLAYER_ID) {
        SocialRefreshOutput.admin()
    } else {
        SocialRefreshOutput(
            myProfile = SocialProfile(
                userId = pid,
                displayName = userProfile.displayName,
                avatarUrl = userProfile.avatarUrl,
                lastOnline = userProfile.lastLogin,
                countryCode = userProfile.countryCode ?: "",
                userToken = token,
            ),
            friends = emptyList(),
            blocked = ""
        )
    }
    val encodedOutput = ProtoBuf.encodeToByteArray(socialRefreshOutput)
    logOutput(encodedOutput)
    call.respondBytes(encodedOutput.pioFraming())
}