package dev.deadzone
import dev.deadzone.api.routes.*
import dev.deadzone.context.GlobalContext
import context.PlayerContextTracker
import dev.deadzone.context.ServerConfig
import dev.deadzone.context.ServerContext
import user.auth.SessionManager
import dev.deadzone.core.data.GameDefinitions
import dev.deadzone.core.model.game.data.Building
import dev.deadzone.core.model.game.data.BuildingLike
import dev.deadzone.core.model.game.data.JunkBuilding
import dev.deadzone.data.db.BigDBMariaImpl
import socket.core.OnlinePlayerRegistry
import socket.core.Server
import dev.deadzone.socket.handler.save.arena.ArenaSaveHandler
import dev.deadzone.socket.handler.save.bounty.BountySaveHandler
import dev.deadzone.socket.handler.save.chat.ChatSaveHandler
import dev.deadzone.socket.handler.save.command.CommandSaveHandler
import dev.deadzone.socket.handler.save.compound.building.BuildingSaveHandler
import dev.deadzone.socket.handler.save.compound.misc.CmpMiscSaveHandler
import dev.deadzone.socket.handler.save.crate.CrateSaveHandler
import dev.deadzone.socket.handler.save.item.ItemSaveHandler
import dev.deadzone.socket.handler.save.misc.MiscSaveHandler
import dev.deadzone.socket.handler.save.mission.MissionSaveHandler
import dev.deadzone.socket.handler.save.purchase.PurchaseSaveHandler
import dev.deadzone.socket.handler.save.quest.QuestSaveHandler
import dev.deadzone.socket.handler.save.raid.RaidSaveHandler
import dev.deadzone.socket.handler.save.survivor.SurvivorSaveHandler
import dev.deadzone.socket.tasks.ServerTaskDispatcher
import user.PlayerAccountRepositoryMaria
import user.auth.WebsiteAuthProvider
import utils.LogLevel
import utils.Logger
import websocket.WebsocketManager
import websocket.WsMessage
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
import io.ktor.websocket.*
import kotlinx.coroutines.launch
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.encodeToJsonElement
import kotlinx.serialization.modules.SerializersModule
import kotlinx.serialization.modules.polymorphic
import kotlinx.serialization.protobuf.ProtoBuf
import org.jetbrains.exposed.sql.Database
import socket.handler.save.compound.task.TaskSaveHandler
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
    Logger.info("🚀 Starting DeadZone server")
    val wsManager = WebsocketManager()
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
            launch { wsManager.onResourceLoadComplete() }
            Logger.info("🎮 Game resources loaded")
        })
    )
    val config = ServerConfig(
        adminEnabled = environment.config.propertyOrNull("game.enableAdmin")?.getString()?.toBooleanStrictOrNull() ?: false,
        useMaria = true,
        mariaUrl = environment.config.propertyOrNull("maria.url")?.getString() ?: "jdbc:mariadb://localhost:3306/deadzone",
        mariaUser = environment.config.propertyOrNull("maria.user")?.getString() ?: "root",
        mariaPassword = environment.config.propertyOrNull("maria.password")?.getString() ?: "",
        isProd = !developmentMode,
    )
    Logger.info("🗃️ Connecting to MariaDB...")
    val database = try {
        val mariaDb = Database.connect(
            url = config.mariaUrl,
            driver = "org.mariadb.jdbc.Driver",
            user = config.mariaUser,
            password = config.mariaPassword
        )
        Logger.info("🟢 MariaDB connected")
        BigDBMariaImpl(mariaDb, config.adminEnabled)
    } catch (e: Exception) {
        Logger.error("🔴 MariaDB connection failed: ${e.message}")
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
            Logger.error("⚠️ Server error: ${cause.message}")
            call.respondText(text = "500: ${cause.message}", status = HttpStatusCode.InternalServerError)
        }
    }
    Logger.level = LogLevel.DEBUG
    install(CallLogging)
    Logger.init { logMessage ->
        wsManager.getAllClients().forEach { (clientId, session) ->
            try {
                val logJson = Json.encodeToJsonElement(logMessage)
                session.send(
                    Frame.Text(
                        Json.encodeToString(
                            WsMessage(
                                type = "log",
                                payload = logJson
                            )
                        )
                    )
                )
            } catch (e: Exception) {
                Logger.error("📡 Failed to send log to client $clientId: ${e.message}")
                wsManager.removeClient(clientId)
            }
        }
    }
    routing {
        fileRoutes()
        caseInsensitiveStaticResources("/game/data", File("static"))
        authRoutes(serverContext)
        apiRoutes(serverContext)
        debugLogRoutes(wsManager)
    }
    val server = Server(context = serverContext).also { it.start() }
    Logger.info("🎉 Server started successfully")
    Logger.info("📡 Socket server listening on $SERVER_HOST:$SOCKET_SERVER_PORT")
    Logger.info("🌐 API server available at $SERVER_HOST:$API_SERVER_PORT")
    Runtime.getRuntime().addShutdownHook(Thread {
        server.shutdown()
        Logger.info("🛑 Server shutdown complete")
    })
}