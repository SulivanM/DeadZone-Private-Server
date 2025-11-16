package config

import server.GameServer
import server.GameServerConfig
import server.PolicyFileServer
import server.PolicyFileServerConfig
import server.core.BroadcastServer
import server.core.BroadcastServerConfig
import server.core.Server

/**
 * Factory for creating server instances
 */
object ServerFactory {

    /**
     * Create all configured servers (Game, Broadcast, Policy)
     */
    fun createServers(config: AppConfiguration): List<Server> {
        return buildList {
            // Game Server (always enabled)
            add(
                GameServer(
                    GameServerConfig(
                        host = config.game.host,
                        port = config.game.port
                    )
                )
            )

            // Broadcast Server (optional)
            if (config.broadcast.enabled) {
                add(
                    BroadcastServer(
                        BroadcastServerConfig(
                            host = config.broadcast.host,
                            ports = config.broadcast.ports
                        )
                    )
                )
            }

            // Policy File Server (optional)
            if (config.broadcast.enablePolicyServer) {
                add(
                    PolicyFileServer(
                        PolicyFileServerConfig(
                            host = config.policy.host,
                            port = config.policy.port,
                            allowedPorts = config.broadcast.ports
                        )
                    )
                )
            }
        }
    }

    /**
     * Get the broadcast server from the list of servers (if exists)
     */
    fun getBroadcastServer(servers: List<Server>): BroadcastServer? {
        return servers.firstOrNull { it is BroadcastServer } as? BroadcastServer
    }
}
