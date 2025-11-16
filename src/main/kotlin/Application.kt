package dev.deadzone

import api.routes.apiRoutes
import api.routes.authRoutes
import api.routes.broadcastRoutes
import api.routes.caseInsensitiveStaticResources
import api.routes.fileRoutes
import config.ServiceFactory
import config.ServerFactory
import config.loadConfiguration
import core.data.GameDefinition
import core.metadata.model.ByteArrayAsBase64Serializer
import core.model.game.data.Building
import core.model.game.data.BuildingLike
import core.model.game.data.JunkBuilding
import server.broadcast.BroadcastService
import server.ServerContainer
import common.Emoji
import common.JSON
import common.Logger
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.serialization.kotlinx.protobuf.*
import io.ktor.server.application.*
import io.ktor.server.netty.*
import io.ktor.server.plugins.calllogging.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.server.plugins.cors.routing.*
import io.ktor.server.plugins.statuspages.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.server.websocket.*
import kotlinx.coroutines.runBlocking
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.json.Json
import kotlinx.serialization.modules.SerializersModule
import kotlinx.serialization.modules.polymorphic
import kotlinx.serialization.protobuf.ProtoBuf
import java.io.File
import kotlin.time.Duration.Companion.seconds

/**
 * Entry point for the DeadZone server application.
 */
fun main(args: Array<String>) = EngineMain.main(args)

/**
 * Configures and initializes the Ktor application module.
 * Sets up database connections, server components, routing, and starts all services.
 */
@Suppress("unused")
fun Application.module() {
    // Load configuration
    val config = environment.loadConfiguration()

    // Configure logger
    Logger.setLevel(level = config.logger.level)
    Logger.enableColorfulLog(useColor = config.logger.colorful)
    Logger.info("${Emoji.Rocket} Starting DeadZone server")

    // Configure Ktor plugins
    configureWebSockets()
    configureSerialization()
    configureCORS()
    configureErrorHandling()
    install(CallLogging)

    // Initialize game data
    val json = JSON.json
    GameDefinition.initialize()
    AppConfig.initialize(host = config.game.host, port = config.game.port)

    // Initialize game services
    server.service.BadWordFilterService.initialize()
    Logger.info("${Emoji.Gaming} Game services initialized")

    // Initialize services and context
    val database = ServiceFactory.initializeDatabase(config)
    val serverContext = ServiceFactory.createServerContext(config, database, json)

    // Configure HTTP routes
    routing {
        fileRoutes()
        caseInsensitiveStaticResources("/game/data", File("static"))
        authRoutes(serverContext)
        apiRoutes(serverContext)
        broadcastRoutes(serverContext)
    }

    // Create and start game servers
    val servers = ServerFactory.createServers(config)
    val broadcastServer = ServerFactory.getBroadcastServer(servers)
    val container = ServerContainer(servers, serverContext)

    runBlocking {
        container.initializeAll()
        container.startAll()
    }

    // Initialize broadcast service
    broadcastServer?.let { BroadcastService.initialize(it) }

    // Log startup success
    Logger.info("${Emoji.Party} Server started successfully")
    Logger.info("${Emoji.Satellite} Socket server listening on ${config.game.host}:${config.game.port}")
    Logger.info("${Emoji.Internet} API server available at ${config.game.host}:${environment.config.property("ktor.deployment.port").getString()}")

    // Register shutdown hook
    Runtime.getRuntime().addShutdownHook(Thread {
        runBlocking {
            container.shutdownAll()
        }
        Logger.info("${Emoji.Red} Server shutdown complete")
    })
}

/**
 * Configure WebSocket support
 */
private fun Application.configureWebSockets() {
    install(WebSockets) {
        pingPeriod = 15.seconds
        timeout = 15.seconds
        masking = true
    }
}

/**
 * Configure JSON and ProtoBuf serialization
 */
private fun Application.configureSerialization() {
    val module = SerializersModule {
        polymorphic(BuildingLike::class) {
            subclass(Building::class, Building.serializer())
            subclass(JunkBuilding::class, JunkBuilding.serializer())
            contextual(ByteArray::class, ByteArrayAsBase64Serializer)
        }
    }
    val json = Json {
        serializersModule = module
        classDiscriminator = "_t"
        prettyPrint = true
        isLenient = true
        ignoreUnknownKeys = true
        encodeDefaults = true
    }

    @OptIn(ExperimentalSerializationApi::class)
    install(ContentNegotiation) {
        json(json)
        protobuf(ProtoBuf)
    }

    JSON.initialize(json)
}

/**
 * Configure CORS
 */
private fun Application.configureCORS() {
    install(CORS) {
        anyHost()
        allowHeader(HttpHeaders.ContentType)
        allowHeaders { true }
        allowMethod(HttpMethod.Get)
        allowMethod(HttpMethod.Post)
        allowMethod(HttpMethod.Put)
        allowMethod(HttpMethod.Delete)
        allowMethod(HttpMethod.Options)
    }
}

/**
 * Configure error handling
 */
private fun Application.configureErrorHandling() {
    install(StatusPages) {
        exception<Throwable> { call, cause ->
            Logger.error("Server error: ${cause.message}")
            call.respondText(text = "500: ${cause.message}", status = HttpStatusCode.InternalServerError)
        }
    }
}