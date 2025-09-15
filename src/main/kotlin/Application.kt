package dev.deadzone

import com.mongodb.kotlin.client.coroutine.MongoClient
import dev.deadzone.api.routes.*
import dev.deadzone.context.GlobalContext
import dev.deadzone.context.PlayerContextTracker
import dev.deadzone.context.ServerConfig
import dev.deadzone.context.ServerContext
import dev.deadzone.core.auth.SessionManager
import dev.deadzone.core.data.BigDBMongoImpl
import dev.deadzone.core.data.GameDefinitions
import dev.deadzone.core.model.game.data.Building
import dev.deadzone.core.model.game.data.BuildingLike
import dev.deadzone.core.model.game.data.JunkBuilding
import dev.deadzone.data.db.BigDB
import dev.deadzone.data.db.CollectionName
import dev.deadzone.socket.core.OnlinePlayerRegistry
import dev.deadzone.socket.core.Server
import dev.deadzone.socket.handler.save.arena.ArenaSaveHandler
import dev.deadzone.socket.handler.save.bounty.BountySaveHandler
import dev.deadzone.socket.handler.save.chat.ChatSaveHandler
import dev.deadzone.socket.handler.save.command.CommandSaveHandler
import dev.deadzone.socket.handler.save.compound.building.BuildingSaveHandler
import dev.deadzone.socket.handler.save.compound.misc.CmpMiscSaveHandler
import dev.deadzone.socket.handler.save.compound.task.TaskSaveHandler
import dev.deadzone.socket.handler.save.crate.CrateSaveHandler
import dev.deadzone.socket.handler.save.item.ItemSaveHandler
import dev.deadzone.socket.handler.save.misc.MiscSaveHandler
import dev.deadzone.socket.handler.save.mission.MissionSaveHandler
import dev.deadzone.socket.handler.save.purchase.PurchaseSaveHandler
import dev.deadzone.socket.handler.save.quest.QuestSaveHandler
import dev.deadzone.socket.handler.save.raid.RaidSaveHandler
import dev.deadzone.socket.handler.save.survivor.SurvivorSaveHandler
import dev.deadzone.socket.tasks.ServerTaskDispatcher
import dev.deadzone.user.PlayerAccountRepository
import dev.deadzone.user.PlayerAccountRepositoryMongo
import dev.deadzone.user.auth.WebsiteAuthProvider
import dev.deadzone.utils.LogLevel
import dev.deadzone.utils.Logger
import dev.deadzone.websocket.WebsocketManager
import dev.deadzone.websocket.WsMessage
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
import org.bson.Document
import java.io.File
import kotlin.time.Duration.Companion.seconds

fun main(args: Array<String>) {
    EngineMain.main(args)
}

const val SERVER_HOST = "127.0.0.1"
const val FILE_SERVER_HOST = "127.0.0.1:8080"
const val API_SERVER_HOST = "127.0.0.1:8080"
const val SOCKET_SERVER_HOST = "127.0.0.1:7777"

const val FILE_SERVER_PORT = 8080
const val API_SERVER_PORT = 8080
const val SOCKET_SERVER_PORT = 7777

/**
 * Setup the server:
 *
 * 1. Install Ktor modules and configure them.
 * 2. Initialize contexts: [GlobalContext], [ServerContext].
 * 3. Initialize each [ServerContext] components.
 * 4. Inject dependency.
 */
suspend fun Application.module() {
    // 1. Configure Websockets
    install(WebSockets) {
        pingPeriod = 15.seconds
        timeout = 15.seconds
        masking = true
    }
    val wsManager = WebsocketManager()

    // 2. Configure Serialization
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

    // 3. Initialize GlobalContext
    GlobalContext.init(
        json = json,
        gameDefinitions = GameDefinitions(onResourceLoadComplete = {
            launch {
                wsManager.onResourceLoadComplete()
            }
        })
    )

    // 4. Create ServerConfig
    val config = ServerConfig(
        adminEnabled = environment.config.propertyOrNull("game.enableAdmin")?.getString()?.toBooleanStrictOrNull()
            ?: false,
        useMongo = true,
        mongoUrl = environment.config.propertyOrNull("mongo.url")?.getString() ?: "",
        isProd = developmentMode,
    )

    // 5. Configure Database
    Logger.info { "Configuring database..." }

    lateinit var database: BigDB

    try {
        val mongoc = MongoClient.create(config.mongoUrl)
        val db = mongoc.getDatabase("admin")
        val commandResult = db.runCommand(Document("ping", 1))
        Logger.info { "MongoDB connection successful: $commandResult" }
        database = BigDBMongoImpl(mongoc.getDatabase("tlsdz"), config.adminEnabled)
    } catch (e: Exception) {
        Logger.error { "MongoDB connection failed inside timeout: ${e.message}" }
    }

    // 6. Initialize ServerContext components
    val sessionManager = SessionManager()
    val playerAccountRepository: PlayerAccountRepository = if (config.useMongo) {
        PlayerAccountRepositoryMongo(
            userCollection = database.getCollection(CollectionName.PLAYER_ACCOUNT_COLLECTION)
        )
    } else {
        // substitute with something else
        PlayerAccountRepositoryMongo(
            userCollection = database.getCollection(CollectionName.PLAYER_ACCOUNT_COLLECTION)
        )
    }
    val onlinePlayerRegistry = OnlinePlayerRegistry()
    val authProvider = WebsiteAuthProvider(database, playerAccountRepository, sessionManager)
    val taskDispatcher = ServerTaskDispatcher()
    val playerContextTracker = PlayerContextTracker()
    val saveHandlers = listOf(
        ArenaSaveHandler(), BountySaveHandler(), ChatSaveHandler(),
        CommandSaveHandler(), BuildingSaveHandler(), CmpMiscSaveHandler(),
        TaskSaveHandler(), CrateSaveHandler(), ItemSaveHandler(),
        MiscSaveHandler(), MissionSaveHandler(), PurchaseSaveHandler(),
        QuestSaveHandler(), RaidSaveHandler(), SurvivorSaveHandler(),
    )

    // 7. Create ServerContext
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

    // 8. Configure HTTP
    install(CORS) {
        allowHost(API_SERVER_HOST, schemes = listOf("http"))
        allowHost(SOCKET_SERVER_HOST, schemes = listOf("http"))
        allowHeader(HttpHeaders.ContentType)
        allowMethod(HttpMethod.Get)
    }
    install(StatusPages) {
        exception<Throwable> { call, cause ->
            call.respondText(text = "500: $cause", status = HttpStatusCode.InternalServerError)
        }
    }

    // 9. Configure Logging
    install(CallLogging)
    Logger.level = LogLevel.DEBUG // use LogLevel.NOTHING to disable logging
    Logger.init { logMessage ->
        for ((clientId, session) in wsManager.getAllClients()) {
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
                println("Failed to send log to client $session: $e")
                wsManager.removeClient(clientId)
            }
        }
    }

    // 10. Configure API routes
    routing {
        fileRoutes()
        caseInsensitiveStaticResources("/game/data", File("static"))
        authRoutes(serverContext)
        apiRoutes(serverContext)
        debugLogRoutes(wsManager)
    }

    // 11. Start the game socket server
    val server = Server(context = serverContext)
    server.start()
    Runtime.getRuntime().addShutdownHook(Thread {
        server.shutdown()
    })
}
