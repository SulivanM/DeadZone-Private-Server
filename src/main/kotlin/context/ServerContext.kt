package dev.deadzone.context

import dev.deadzone.core.auth.AuthProvider
import dev.deadzone.core.auth.SessionManager
import dev.deadzone.data.db.BigDB
import dev.deadzone.socket.core.OnlinePlayerRegistry
import dev.deadzone.socket.handler.save.SaveSubHandler
import dev.deadzone.socket.tasks.ServerTaskDispatcher
import dev.deadzone.user.PlayerAccountRepository

/**
 * Holds the global server components. Only single instance of this class is needed in the server.
 */
data class ServerContext(
    val db: BigDB,
    val playerAccountRepository: PlayerAccountRepository,
    val sessionManager: SessionManager,
    val onlinePlayerRegistry: OnlinePlayerRegistry,
    val authProvider: AuthProvider,
    val taskDispatcher: ServerTaskDispatcher,
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
    val useMongo: Boolean,
    val mongoUrl: String,
    val isProd: Boolean,
)
