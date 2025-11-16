package server

import context.ServerContext
import server.messaging.HandlerContext
import server.tasks.impl.MissionReturnStopParameter
import server.messaging.SocketMessage
import server.messaging.SocketMessageDispatcher
import server.protocol.PIODeserializer
import common.Logger
import common.UUID
import common.sanitizedString
import io.ktor.network.selector.*
import io.ktor.network.sockets.*
import io.ktor.util.date.*
import io.ktor.utils.io.*
import kotlinx.coroutines.*
import server.core.Connection
import server.core.Server
import server.handler.*
import server.tasks.TaskCategory
import server.tasks.impl.BatchRecycleCompleteStopParameter
import server.tasks.impl.BuildingCreateStopParameter
import server.tasks.impl.BuildingRepairStopParameter
import server.tasks.impl.JunkRemovalStopParameter
import java.net.SocketException
import kotlin.system.measureTimeMillis

data class GameServerConfig(
    val host: String = "127.0.0.1",
    val port: Int = 7777
)

class GameServer(private val config: GameServerConfig) : Server {
    override val name: String = "GameServer"

    private lateinit var gameServerScope: CoroutineScope
    private lateinit var serverContext: ServerContext
    private val socketDispatcher = SocketMessageDispatcher()

    private var running = false
    override fun isRunning(): Boolean = running

    override suspend fun initialize(scope: CoroutineScope, context: ServerContext) {
        this.gameServerScope = CoroutineScope(scope.coroutineContext + SupervisorJob() + Dispatchers.IO)
        this.serverContext = context

        with(context) {
            // Core handlers
            socketDispatcher.register(JoinHandler(this))
            socketDispatcher.register(AuthHandler())
            socketDispatcher.register(InitCompleteHandler(this))
            socketDispatcher.register(ChatMessageHandler(this))
            socketDispatcher.register(ChatRoomMessageHandler(this))

            // Game state handlers
            socketDispatcher.register(QuestProgressHandler(this))
            socketDispatcher.register(SaveHandler(this))
            socketDispatcher.register(FlagChangedHandler(this))

            // Combat and interaction handlers
            socketDispatcher.register(ZombieAttackHandler())
            socketDispatcher.register(PlayerAttackRequestHandler(this))
            socketDispatcher.register(PlayerAttackResponseHandler(this))
            socketDispatcher.register(HelpPlayerHandler(this))

            // Player data handlers
            socketDispatcher.register(RequestSurvivorCheckHandler(this))
            socketDispatcher.register(GetPlayerSurvivorHandler(this))
            socketDispatcher.register(PlayerViewRequestHandler(this))
            socketDispatcher.register(GetNeighborStatesHandler(this))

            // Economy handlers
            socketDispatcher.register(PurchaseCoinsHandler(this))

            // Mission tracking handlers
            socketDispatcher.register(ScavStartedHandler(this))
            socketDispatcher.register(ScavEndedHandler(this))

            // Utility handlers
            socketDispatcher.register(DebugHandler(this))
            socketDispatcher.register(LongSessionValidationHandler(this))
            socketDispatcher.register(RpcResponseHandler(this))

            context.taskDispatcher.registerStopId(
                category = TaskCategory.TimeUpdate,
                stopInputFactory = {},
                deriveId = { playerId, category, _ ->
                    // "TU-playerId123"
                    "${category.code}-$playerId"
                }
            )
            context.taskDispatcher.registerStopId(
                category = TaskCategory.Building.Create,
                stopInputFactory = { BuildingCreateStopParameter() },
                deriveId = { playerId, category, stopInput ->
                    // "BLD-CREATE-bldId123-playerId123"
                    "${category.code}-${stopInput.buildingId}-$playerId"
                }
            )
            context.taskDispatcher.registerStopId(
                category = TaskCategory.Building.Repair,
                stopInputFactory = { BuildingRepairStopParameter() },
                deriveId = { playerId, category, stopInput ->
                    // "BLD-REPAIR-bldId123-playerId123"
                    "${category.code}-${stopInput.buildingId}-$playerId"
                }
            )
            context.taskDispatcher.registerStopId(
                category = TaskCategory.Mission.Return,
                stopInputFactory = { MissionReturnStopParameter() },
                deriveId = { playerId, category, stopInput ->
                    // "MIS-RETURN-missionId123-playerId123"
                    "${category.code}-${stopInput.missionId}-$playerId"
                }
            )
            context.taskDispatcher.registerStopId(
                category = TaskCategory.Task.JunkRemoval,
                stopInputFactory = { JunkRemovalStopParameter() },
                deriveId = { playerId, category, stopInput ->
                    // "TASK-JUNK-taskId123-playerId123"
                    "${category.code}-${stopInput.taskId}-$playerId"
                }
            )
            context.taskDispatcher.registerStopId(
                category = TaskCategory.BatchRecycle.Complete,
                stopInputFactory = { BatchRecycleCompleteStopParameter() },
                deriveId = { playerId, category, stopInput ->
                    // "BATCH-RECYCLE-jobId123-playerId123"
                    "${category.code}-${stopInput.jobId}-$playerId"
                }
            )
        }
    }

    override suspend fun start() {
        if (running) {
            Logger.warn("Game server is already running")
            return
        }
        running = true

        gameServerScope.launch {
            try {
                val selectorManager = SelectorManager(Dispatchers.IO)
                val serverSocket = aSocket(selectorManager).tcp().bind(config.host, config.port)

                while (isActive) {
                    val socket = serverSocket.accept()

                    val connection = Connection(
                        connectionId = UUID.new(),
                        remoteAddress = socket.remoteAddress.toString(),
                        connectionScope = CoroutineScope(gameServerScope.coroutineContext + SupervisorJob() + Dispatchers.Default),
                        input = socket.openReadChannel(),
                        output = socket.openWriteChannel(autoFlush = true),
                    )
                    Logger.info { "New client: ${connection.remoteAddress}" }
                    handleClient(connection)
                }
            } catch (e: Exception) {
                Logger.error { "ERROR on server: $e" }
                shutdown()
            }
        }
    }

    private fun handleClient(connection: Connection) {
        connection.connectionScope.launch {
            try {
                val buffer = ByteArray(4096)

                while (isActive) {
                    val bytesRead = connection.input.readAvailable(buffer, 0, buffer.size)
                    if (bytesRead <= 0) break

                    var msgType = "[Undetermined]"
                    val data = buffer.copyOfRange(0, bytesRead)

                    // Handle policy file request
                    if (data.startsWithBytes(POLICY_FILE_REQUEST)) {
                        Logger.debug { "=====> [SOCKET START]: POLICY_FILE_REQUEST from connection=$connection" }
                        connection.sendRaw(POLICY_FILE_RESPONSE)
                        Logger.debug {
                            buildString {
                                appendLine("<===== [SOCKET END]  : Responded to POLICY_FILE_REQUEST for connection=$connection")
                                append("====================================================================================================")
                            }
                        }
                        break
                    }

                    val elapsed = measureTimeMillis {
                        val data2 = if (data.startsWithBytes(byteArrayOf(0x00))) {
                            data.drop(1).toByteArray()
                        } else data

                        val deserialized = PIODeserializer.deserialize(data2)
                        val msg = SocketMessage.fromRaw(deserialized)
                        if (msg.isEmpty()) {
                            Logger.debug { "==== [SOCKET] Ignored empty message from connection=$connection, raw: $msg" }
                            return@measureTimeMillis
                        }

                        msgType = msg.msgTypeToString()

                        Logger.debug {
                            "=====> [SOCKET START]: of type $msgType, raw: ${data.sanitizedString()} for playerId=${connection.playerId}, bytes=$bytesRead"
                        }

                        socketDispatcher.findHandlerFor(msg).handle(HandlerContext(connection, msg))
                    }

                    Logger.debug {
                        buildString {
                            appendLine("<===== [SOCKET END] of type $msgType handled for playerId=${connection.playerId} in ${elapsed}ms")
                            append("====================================================================================================")
                        }
                    }
                }
            } catch (_: ClosedByteChannelException) {
                // Handle connection reset gracefully - this is expected when clients disconnect abruptly
                Logger.info { "Client ${connection.remoteAddress} disconnected abruptly (connection reset)" }
            } catch (e: SocketException) {
                // Handle other socket-related exceptions gracefully
                when {
                    e.message?.contains("Connection reset") == true -> {
                        Logger.info { "Client ${connection.remoteAddress} connection was reset by peer" }
                    }

                    e.message?.contains("Broken pipe") == true -> {
                        Logger.info { "Client ${connection.remoteAddress} connection broken (broken pipe)" }
                    }

                    else -> {
                        Logger.warn { "Socket exception for ${connection.remoteAddress}: ${e.message}" }
                    }
                }
            } catch (e: Exception) {
                Logger.error { "Unexpected error in socket for ${connection.remoteAddress}: $e" }
                e.printStackTrace()
            } finally {
                // Cleanup logic - this will run regardless of how the connection ended
                Logger.info { "Cleaning up connection for ${connection.remoteAddress}" }

                // Only perform cleanup if playerId is set (client was authenticated)
                if (connection.playerId != "[Undetermined]") {
                    serverContext.onlinePlayerRegistry.markOffline(connection.playerId)
                    serverContext.playerAccountRepository.updateLastLogin(connection.playerId, getTimeMillis())

                    // Faire quitter le joueur de toutes ses rooms
                    room.RoomManager.leaveAllRooms(connection.playerId)

                    serverContext.playerContextTracker.removePlayer(connection.playerId)
                    serverContext.taskDispatcher.stopAllTasksForPlayer(connection.playerId)
                }

                connection.shutdown()
            }
        }
    }

    override suspend fun shutdown() {
        running = false
        room.RoomManager.shutdown()
        room.JoinKeyManager.shutdown()
        serverContext.playerContextTracker.shutdown()
        serverContext.onlinePlayerRegistry.shutdown()
        serverContext.sessionManager.shutdown()
        serverContext.taskDispatcher.shutdown()
        socketDispatcher.shutdown()
        gameServerScope.cancel()
    }
}

fun ByteArray.startsWithBytes(prefix: ByteArray): Boolean {
    if (this.size < prefix.size) return false
    for (i in prefix.indices) {
        if (this[i] != prefix[i]) return false
    }
    return true
}
