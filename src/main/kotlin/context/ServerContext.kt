package context

import data.db.BigDB
import server.core.OnlinePlayerRegistry
import server.handler.save.SaveSubHandler
import server.tasks.ServerTaskDispatcher
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
    val gameHost: String = "127.0.0.1",
    val gamePort: Int = 7777,
    val broadcastEnabled: Boolean = true,
    val broadcastHost: String = "0.0.0.0",
    val broadcastPorts: List<Int> = listOf(2121, 2122, 2123),
    val broadcastPolicyServerEnabled: Boolean = true,
    val policyHost: String = "0.0.0.0",
    val policyPort: Int = 843,
)