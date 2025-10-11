package dev.deadzone

import api.routes.apiRoutes
import api.routes.authRoutes
import api.routes.caseInsensitiveStaticResources
import api.routes.fileRoutes
import context.GlobalContext
import context.PlayerContextTracker
import context.ServerConfig
import context.ServerContext
import core.data.GameDefinitions
import core.model.game.data.Building
import core.model.game.data.BuildingLike
import core.model.game.data.JunkBuilding
import data.db.BigDBMariaImpl
import utils.Emoji
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
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.json.Json
import kotlinx.serialization.modules.SerializersModule
import kotlinx.serialization.modules.polymorphic
import kotlinx.serialization.protobuf.ProtoBuf
import org.jetbrains.exposed.sql.Database
import socket.core.OnlinePlayerRegistry
import socket.core.Server
import socket.handler.save.arena.ArenaSaveHandler
import socket.handler.save.bounty.BountySaveHandler
import socket.handler.save.chat.ChatSaveHandler
import socket.handler.save.command.CommandSaveHandler
import socket.handler.save.compound.building.BuildingSaveHandler
import socket.handler.save.compound.misc.CmpMiscSaveHandler
import socket.handler.save.compound.task.TaskSaveHandler
import socket.handler.save.crate.CrateSaveHandler
import socket.handler.save.item.ItemSaveHandler
import socket.handler.save.misc.MiscSaveHandler
import socket.handler.save.mission.MissionSaveHandler
import socket.handler.save.purchase.PurchaseSaveHandler
import socket.handler.save.quest.QuestSaveHandler
import socket.handler.save.raid.RaidSaveHandler
import socket.handler.save.survivor.SurvivorSaveHandler
import socket.tasks.ServerTaskDispatcher
import user.PlayerAccountRepositoryMaria
import user.auth.SessionManager
import user.auth.WebsiteAuthProvider
import utils.Logger
import java.io.File
import kotlin.time.Duration.Companion.seconds

fun main(args: Array<String>) = EngineMain.main(args)

const val SERVER_HOST = "127.0.0.1"
const val API_SERVER_PORT = 8080
const val SOCKET_SERVER_PORT = 7777

fun Application.module() {
    install(WebSockets) {
        pingPeriod = 15.seconds
        timeout = 15.seconds
        masking = true
    }

    Logger.setLevel(level = environment.config.propertyOrNull("logger.level")?.getString() ?: "0")
    Logger.enableColorfulLog(
        useColor = environment.config.propertyOrNull("logger.colorful")?.getString()?.toBooleanStrictOrNull() ?: true
    )
    Logger.info("${Emoji.Rocket} Starting DeadZone server")

    val module = SerializersModule {
        polymorphic(BuildingLike::class) {
            subclass(Building::class, Building.serializer())
            subclass(JunkBuilding::class, JunkBuilding.serializer())
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
    GlobalContext.init(
        json = json,
        gameDefinitions = GameDefinitions(onResourceLoadComplete = {
            Logger.info("${Emoji.Gaming} Game resources loaded")
        })
    )

    val config = ServerConfig(
        adminEnabled = environment.config.propertyOrNull("game.enableAdmin")?.getString()?.toBooleanStrictOrNull()
            ?: false,
        useMaria = true,
        mariaUrl = environment.config.propertyOrNull("maria.url")?.getString()
            ?: "jdbc:mariadb://localhost:3306/deadzone",
        mariaUser = environment.config.propertyOrNull("maria.user")?.getString() ?: "root",
        mariaPassword = environment.config.propertyOrNull("maria.password")?.getString() ?: "",
        isProd = !developmentMode,
    )
    Logger.info("${Emoji.Database} Connecting to MariaDB...")
    val database = try {
        val mariaDb = Database.connect(
            url = config.mariaUrl,
            driver = "org.mariadb.jdbc.Driver",
            user = config.mariaUser,
            password = config.mariaPassword
        )
        Logger.info("${Emoji.Green} MariaDB connected")
        BigDBMariaImpl(mariaDb, config.adminEnabled)
    } catch (e: Exception) {
        Logger.error("${Emoji.Red} MariaDB connection failed: ${e.message}")
        throw e
    }
    val sessionManager = SessionManager()
    val playerAccountRepository = PlayerAccountRepositoryMaria(database.database)
    val onlinePlayerRegistry = OnlinePlayerRegistry()
    val authProvider = WebsiteAuthProvider(database, playerAccountRepository, sessionManager)
    val taskDispatcher = ServerTaskDispatcher()
    val playerContextTracker = PlayerContextTracker()
    val saveHandlers = listOf(
        ArenaSaveHandler(), BountySaveHandler(), ChatSaveHandler(), CommandSaveHandler(),
        BuildingSaveHandler(), CmpMiscSaveHandler(), TaskSaveHandler(), CrateSaveHandler(),
        ItemSaveHandler(), MiscSaveHandler(), MissionSaveHandler(), PurchaseSaveHandler(),
        QuestSaveHandler(), RaidSaveHandler(), SurvivorSaveHandler()
    )
    val serverContext = ServerContext(
        db = database,
        playerAccountRepository = playerAccountRepository,
        sessionManager = sessionManager,
        onlinePlayerRegistry = onlinePlayerRegistry,
        authProvider = authProvider,
        taskDispatcher = taskDispatcher,
        playerContextTracker = playerContextTracker,
        saveHandlers = saveHandlers,
        config = config,
    )
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
    install(StatusPages) {
        exception<Throwable> { call, cause ->
            Logger.error("Server error: ${cause.message}")
            call.respondText(text = "500: ${cause.message}", status = HttpStatusCode.InternalServerError)
        }
    }
    install(CallLogging)
    routing {
        fileRoutes()
        caseInsensitiveStaticResources("/game/data", File("static"))
        authRoutes(serverContext)
        apiRoutes(serverContext)
    }
    val server = Server(context = serverContext).also { it.start() }
    Logger.info("${Emoji.Party} Server started successfully")
    Logger.info("${Emoji.Satellite} Socket server listening on $SERVER_HOST:$SOCKET_SERVER_PORT")
    Logger.info("${Emoji.Internet} API server available at $SERVER_HOST:$API_SERVER_PORT")
    Runtime.getRuntime().addShutdownHook(Thread {
        server.shutdown()
        Logger.info("${Emoji.Red} Server shutdown complete")
    })
}