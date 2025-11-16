package config

import io.ktor.server.application.*

/**
 * Application configuration loaded from application.conf
 */
data class AppConfiguration(
    val logger: LoggerConfig,
    val database: DatabaseConfig,
    val game: GameConfig,
    val broadcast: BroadcastConfig,
    val policy: PolicyConfig,
    val isDevelopment: Boolean
)

data class LoggerConfig(
    val level: String,
    val colorful: Boolean
)

data class DatabaseConfig(
    val url: String,
    val user: String,
    val password: String
)

data class GameConfig(
    val host: String,
    val port: Int,
    val enableAdmin: Boolean
)

data class BroadcastConfig(
    val enabled: Boolean,
    val host: String,
    val ports: List<Int>,
    val enablePolicyServer: Boolean
)

data class PolicyConfig(
    val host: String,
    val port: Int
)

/**
 * Loads application configuration from Ktor environment
 */
fun ApplicationEnvironment.loadConfiguration(): AppConfiguration {
    return AppConfiguration(
        logger = LoggerConfig(
            level = config.propertyOrNull("logger.level")?.getString() ?: "0",
            colorful = config.propertyOrNull("logger.colorful")?.getString()?.toBooleanStrictOrNull() ?: true
        ),
        database = DatabaseConfig(
            url = config.propertyOrNull("maria.url")?.getString() ?: "jdbc:mariadb://localhost:3306/deadzone",
            user = config.propertyOrNull("maria.user")?.getString() ?: "root",
            password = config.propertyOrNull("maria.password")?.getString() ?: ""
        ),
        game = GameConfig(
            host = config.propertyOrNull("game.host")?.getString() ?: "127.0.0.1",
            port = config.propertyOrNull("game.port")?.getString()?.toIntOrNull() ?: 7777,
            enableAdmin = config.propertyOrNull("game.enableAdmin")?.getString()?.toBooleanStrictOrNull() ?: false
        ),
        broadcast = BroadcastConfig(
            enabled = config.propertyOrNull("broadcast.enabled")?.getString()?.toBooleanStrictOrNull() ?: true,
            host = config.propertyOrNull("broadcast.host")?.getString() ?: "0.0.0.0",
            ports = config.propertyOrNull("broadcast.ports")?.getString()?.split(",")
                ?.mapNotNull { it.trim().toIntOrNull() } ?: listOf(2121, 2122, 2123),
            enablePolicyServer = config.propertyOrNull("broadcast.enablePolicyServer")?.getString()
                ?.toBooleanStrictOrNull() ?: true
        ),
        policy = PolicyConfig(
            host = config.propertyOrNull("policy.host")?.getString() ?: "0.0.0.0",
            port = config.propertyOrNull("policy.port")?.getString()?.toIntOrNull() ?: 843
        ),
        isDevelopment = config.propertyOrNull("ktor.development")?.getString()?.toBooleanStrictOrNull() ?: false
    )
}
