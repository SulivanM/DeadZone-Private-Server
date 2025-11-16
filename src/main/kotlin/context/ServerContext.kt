package context

import data.db.BigDB
import server.core.OnlinePlayerRegistry
import server.handler.save.SaveSubHandler
import server.tasks.ServerTaskDispatcher
import user.PlayerAccountRepository
import user.auth.AuthProvider
import user.auth.SessionManager

/**
 * Central context object containing all server-wide services and state.
 *
 * ServerContext is initialized at application startup and provides access to:
 * - Database connections and repositories
 * - Authentication and session management
 * - Active player tracking
 * - Task scheduling
 * - Game save handlers
 * - Server configuration
 *
 * This context is passed to message handlers, API endpoints, and other
 * components that need access to shared server state.
 *
 * @property db BigDB database implementation for game data storage
 * @property playerAccountRepository Repository for player account data
 * @property sessionManager Manages player sessions and tokens
 * @property onlinePlayerRegistry Tracks currently connected players
 * @property authProvider Handles player authentication
 * @property taskDispatcher Schedules and manages asynchronous tasks
 * @property playerContextTracker Tracks individual player game states
 * @property saveHandlers List of registered save operation handlers
 * @property config Server configuration settings
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

/**
 * Retrieves the player context for a given player ID, if it exists.
 *
 * @param playerId Unique player identifier
 * @return Player context or null if player is not online or not loaded
 */
fun ServerContext.getPlayerContextOrNull(playerId: String): PlayerContext? =
    playerContextTracker.getContext(playerId)

/**
 * Retrieves the player context for a given player ID.
 *
 * @param playerId Unique player identifier
 * @return Player context
 * @throws IllegalStateException if player context is not found
 */
fun ServerContext.requirePlayerContext(playerId: String): PlayerContext =
    getPlayerContextOrNull(playerId)
        ?: error("PlayerContext not found for pid=$playerId")

/**
 * Server configuration loaded from application.yaml.
 *
 * Contains settings for database connections, network ports, and feature flags.
 *
 * @property adminEnabled Whether admin features are enabled
 * @property useMaria Whether to use MariaDB (currently always true)
 * @property mariaUrl JDBC connection string for MariaDB
 * @property mariaUser Database username
 * @property mariaPassword Database password
 * @property isProd Whether running in production mode
 * @property gameHost Game server bind address
 * @property gamePort Game server port (default: 7777)
 * @property broadcastEnabled Whether broadcast server is enabled
 * @property broadcastHost Broadcast server bind address
 * @property broadcastPorts List of broadcast server ports
 * @property broadcastPolicyServerEnabled Whether Flash policy server is enabled
 * @property policyHost Policy server bind address
 * @property policyPort Policy server port (default: 843)
 */
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