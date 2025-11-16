package api.routes

import api.handler.*
import context.ServerContext
import common.LogConfigAPIError
import common.Logger
import io.ktor.http.HttpStatusCode
import io.ktor.server.response.respond
import io.ktor.server.routing.Route
import io.ktor.server.routing.RoutingContext
import io.ktor.server.routing.get
import io.ktor.server.routing.post

/**
 * API endpoint mapping with authentication requirements
 */
enum class ApiEndpoint(val path: String, val requiresAuth: Boolean) {
    AUTHENTICATE("13", false),
    CREATE_JOIN_ROOM("27", true),
    LIST_ROOMS("30", true),
    WRITE_ERROR("50", false),
    CREATE_OBJECTS("82", true),
    LOAD_OBJECTS("85", true),
    DELETE_OBJECTS("91", true), // Fixed: was 86, should be 91
    LOAD_MATCHING_OBJECTS("94", true),
    SAVE_OBJECT_CHANGES("88", true),
    LOAD_INDEX_RANGE("97", true),
    DELETE_INDEX_RANGE("100", true),
    LOAD_MY_PLAYER_OBJECT("103", true),
    PAYVAULT_READ_HISTORY("160", true),
    PAYVAULT_REFRESH("163", true),
    PAYVAULT_CONSUME("166", true),
    PAYVAULT_CREDIT("169", true),
    PAYVAULT_DEBIT("172", true),
    PAYVAULT_BUY("175", true),
    PAYVAULT_GIVE("178", true),
    PAYVAULT_PAYMENT_INFO("181", false),
    PAYVAULT_USE_PAYMENT_INFO("184", true),
    ACHIEVEMENTS_PROGRESS_SET("277", true),
    ACHIEVEMENTS_PROGRESS_ADD("280", true),
    ACHIEVEMENTS_PROGRESS_MAX("283", true),
    ACHIEVEMENTS_PROGRESS_COMPLETE("286", true),
    SOCIAL_REFRESH("601", true);

    companion object {
        private val pathMap = entries.associateBy { it.path }
        fun fromPath(path: String): ApiEndpoint? = pathMap[path]
    }
}

/**
 * API route dispatcher
 */
private suspend fun RoutingContext.handleApiRequest(
    endpoint: ApiEndpoint,
    serverContext: ServerContext,
    playerToken: String?
) {
    when (endpoint) {
        ApiEndpoint.AUTHENTICATE -> authenticate(serverContext)
        ApiEndpoint.SOCIAL_REFRESH -> socialRefresh(serverContext, playerToken!!)
        ApiEndpoint.CREATE_JOIN_ROOM -> createJoinRoom(serverContext)
        ApiEndpoint.LIST_ROOMS -> listRooms()
        ApiEndpoint.WRITE_ERROR -> writeError()

        // BigDB Operations
        ApiEndpoint.CREATE_OBJECTS -> createObjects(serverContext)
        ApiEndpoint.LOAD_OBJECTS -> loadObjects(serverContext)
        ApiEndpoint.DELETE_OBJECTS -> deleteObjects(serverContext)
        ApiEndpoint.LOAD_MATCHING_OBJECTS -> loadMatchingObjects(serverContext)
        ApiEndpoint.SAVE_OBJECT_CHANGES -> saveObjectChanges(serverContext)
        ApiEndpoint.LOAD_INDEX_RANGE -> loadIndexRange(serverContext)
        ApiEndpoint.DELETE_INDEX_RANGE -> deleteIndexRange(serverContext)
        ApiEndpoint.LOAD_MY_PLAYER_OBJECT -> loadMyPlayerObject(serverContext)

        // PayVault Operations
        ApiEndpoint.PAYVAULT_READ_HISTORY -> payVaultReadHistory(serverContext)
        ApiEndpoint.PAYVAULT_REFRESH -> payVaultRefresh(serverContext)
        ApiEndpoint.PAYVAULT_CONSUME -> payVaultConsume(serverContext)
        ApiEndpoint.PAYVAULT_CREDIT -> payVaultCredit(serverContext)
        ApiEndpoint.PAYVAULT_DEBIT -> payVaultDebit(serverContext)
        ApiEndpoint.PAYVAULT_BUY -> payVaultBuy(serverContext)
        ApiEndpoint.PAYVAULT_GIVE -> payVaultGive(serverContext)
        ApiEndpoint.PAYVAULT_PAYMENT_INFO -> payVaultPaymentInfo()
        ApiEndpoint.PAYVAULT_USE_PAYMENT_INFO -> payVaultUsePaymentInfo(serverContext)

        // Achievement Operations
        ApiEndpoint.ACHIEVEMENTS_PROGRESS_SET -> achievementsProgressSet(serverContext)
        ApiEndpoint.ACHIEVEMENTS_PROGRESS_ADD -> achievementsProgressAdd(serverContext)
        ApiEndpoint.ACHIEVEMENTS_PROGRESS_MAX -> achievementsProgressMax(serverContext)
        ApiEndpoint.ACHIEVEMENTS_PROGRESS_COMPLETE -> achievementsProgressComplete(serverContext)
    }
}

fun Route.apiRoutes(serverContext: ServerContext) {
    get("/api/status") {
        call.respond(HttpStatusCode.OK, mapOf("status" to "online"))
    }

    post("/api/{path}") {
        val path = call.parameters["path"] ?: return@post call.respond(HttpStatusCode.BadRequest)

        val endpoint = ApiEndpoint.fromPath(path)
        if (endpoint == null) {
            Logger.error(LogConfigAPIError) { "Unimplemented API route: $path" }
            return@post call.respond(HttpStatusCode.NotFound, "Unimplemented API: $path")
        }

        val playerToken = if (endpoint.requiresAuth) {
            call.request.queryParameters["playertoken"]
                ?: call.request.headers["playertoken"]
                ?: return@post call.respond(HttpStatusCode.Unauthorized, "Missing playertoken")
        } else {
            null
        }

        handleApiRequest(endpoint, serverContext, playerToken)
    }
}
