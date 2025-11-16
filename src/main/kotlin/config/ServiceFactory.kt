package config

import context.PlayerContextTracker
import context.ServerConfig
import context.ServerContext
import data.db.BigDBMariaImpl
import org.jetbrains.exposed.sql.Database
import server.core.OnlinePlayerRegistry
import server.handler.save.alliance.AllianceSaveHandler
import server.handler.save.arena.ArenaSaveHandler
import server.handler.save.bounty.BountySaveHandler
import server.handler.save.chat.ChatSaveHandler
import server.handler.save.command.CommandSaveHandler
import server.handler.save.compound.building.BuildingSaveHandler
import server.handler.save.compound.misc.CmpMiscSaveHandler
import server.handler.save.compound.task.TaskSaveHandler
import server.handler.save.crate.CrateSaveHandler
import server.handler.save.item.ItemSaveHandler
import server.handler.save.misc.MiscSaveHandler
import server.handler.save.mission.MissionSaveHandler
import server.handler.save.purchase.PurchaseSaveHandler
import server.handler.save.quest.QuestSaveHandler
import server.handler.save.raid.RaidSaveHandler
import server.handler.save.survivor.SurvivorSaveHandler
import server.tasks.ServerTaskDispatcher
import user.PlayerAccountRepositoryMaria
import user.auth.SessionManager
import user.auth.WebsiteAuthProvider
import kotlinx.serialization.json.Json
import common.Emoji
import common.Logger

/**
 * Factory for creating and initializing server services
 */
object ServiceFactory {

    /**
     * Initialize database connection
     */
    fun initializeDatabase(config: AppConfiguration): BigDBMariaImpl {
        Logger.info("${Emoji.Database} Connecting to MariaDB...")
        return try {
            val mariaDb = Database.connect(
                url = config.database.url,
                driver = "org.mariadb.jdbc.Driver",
                user = config.database.user,
                password = config.database.password
            )
            Logger.info("${Emoji.Green} MariaDB connected")
            BigDBMariaImpl(mariaDb, config.game.enableAdmin)
        } catch (e: Exception) {
            Logger.error("${Emoji.Red} MariaDB connection failed: ${e.message}")
            throw e
        }
    }

    /**
     * Create ServerContext with all initialized services
     */
    fun createServerContext(
        config: AppConfiguration,
        database: BigDBMariaImpl,
        json: Json
    ): ServerContext {
        val sessionManager = SessionManager()
        val playerAccountRepository = PlayerAccountRepositoryMaria(database.database, json)
        val onlinePlayerRegistry = OnlinePlayerRegistry()
        val authProvider = WebsiteAuthProvider(database, playerAccountRepository, sessionManager)
        val taskDispatcher = ServerTaskDispatcher()
        val playerContextTracker = PlayerContextTracker()
        val saveHandlers = createSaveHandlers()

        val serverConfig = ServerConfig(
            adminEnabled = config.game.enableAdmin,
            useMaria = true,
            mariaUrl = config.database.url,
            mariaUser = config.database.user,
            mariaPassword = config.database.password,
            isProd = !config.isDevelopment,
            gameHost = config.game.host,
            gamePort = config.game.port,
            broadcastEnabled = config.broadcast.enabled,
            broadcastHost = config.broadcast.host,
            broadcastPorts = config.broadcast.ports,
            broadcastPolicyServerEnabled = config.broadcast.enablePolicyServer,
            policyHost = config.policy.host,
            policyPort = config.policy.port
        )

        return ServerContext(
            db = database,
            playerAccountRepository = playerAccountRepository,
            sessionManager = sessionManager,
            onlinePlayerRegistry = onlinePlayerRegistry,
            authProvider = authProvider,
            taskDispatcher = taskDispatcher,
            playerContextTracker = playerContextTracker,
            saveHandlers = saveHandlers,
            config = serverConfig
        )
    }

    /**
     * Create all save handlers organized by domain
     */
    private fun createSaveHandlers() = listOf(
        // Player & Alliance
        AllianceSaveHandler(),
        CommandSaveHandler(),

        // Combat Systems
        ArenaSaveHandler(),
        RaidSaveHandler(),

        // Bounty & Quests
        BountySaveHandler(),
        QuestSaveHandler(),

        // Chat & Social
        ChatSaveHandler(),

        // Compound Management
        BuildingSaveHandler(),
        CmpMiscSaveHandler(),
        TaskSaveHandler(),

        // Inventory & Items
        ItemSaveHandler(),
        CrateSaveHandler(),

        // Missions
        MissionSaveHandler(),

        // Survivors
        SurvivorSaveHandler(),

        // Economy
        PurchaseSaveHandler(),

        // Misc
        MiscSaveHandler()
    )
}
