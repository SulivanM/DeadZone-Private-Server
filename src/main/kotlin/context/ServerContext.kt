package context

import data.db.BigDB
import dev.deadzone.socket.tasks.ServerTaskRunner
import socket.core.OnlinePlayerRegistry
import socket.handler.save.SaveSubHandler
import socket.tasks.ServerTaskDispatcher
import user.PlayerAccountRepository
import user.auth.AuthProvider
import user.auth.SessionManager

data class ServerContext(
    val db: BigDB,
    val playerAccountRepository: PlayerAccountRepository,
    val sessionManager: SessionManager,
    val onlinePlayerRegistry: OnlinePlayerRegistry,
    val authProvider: AuthProvider,
    val taskDispatcher: ServerTaskDispatcher,
    val taskRunner: ServerTaskRunner,
    val playerContextTracker: PlayerContextTracker,
    val saveHandlers: List<SaveSubHandler>,
    val config: ServerConfig,
)

fun ServerContext.getPlayerContextOrNull(playerId: String): PlayerContext? =
    playerContextTracker.getContext(playerId)

fun ServerContext.requirePlayerContext(playerId: String): PlayerContext =
    getPlayerContextOrNull(playerId)
        ?: error("PlayerContext not found for pid=$playerId")

data class ServerConfig(
    val adminEnabled: Boolean,
    val useMaria: Boolean,
    val mariaUrl: String,
    val mariaUser: String,
    val mariaPassword: String,
    val isProd: Boolean,
)