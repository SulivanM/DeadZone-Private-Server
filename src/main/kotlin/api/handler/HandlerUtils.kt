package api.handler

import context.ServerContext
import io.ktor.server.routing.RoutingContext

/**
 * Utility functions for API handlers
 */

/**
 * Extract player ID from the playertoken in the request
 * Returns null if token is invalid or missing
 */
suspend fun RoutingContext.getPlayerIdFromToken(serverContext: ServerContext): String? {
    val playerToken = call.request.queryParameters["playertoken"]
        ?: call.request.headers["playertoken"]
        ?: return null

    return try {
        serverContext.sessionManager.getPlayerId(playerToken)
    } catch (e: Exception) {
        null
    }
}
