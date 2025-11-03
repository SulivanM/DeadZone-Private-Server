package data.db

import com.toxicbakery.bcrypt.Bcrypt
import core.data.AdminData
import data.collection.*
import io.ktor.util.date.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.experimental.newSuspendedTransaction
import utils.Emoji
import utils.JSON
import utils.Logger
import utils.UUID
import kotlin.io.encoding.Base64
import kotlin.let

object PlayerAccounts : Table("player_accounts") {
    val playerId = varchar("player_id", 36).uniqueIndex()
    val hashedPassword = text("hashed_password")
    val email = varchar("email", 255)
    val displayName = varchar("display_name", 100)
    val avatarUrl = varchar("avatar_url", 500)
    val createdAt = long("created_at")
    val lastLogin = long("last_login")
    val countryCode = varchar("country_code", 10).nullable()
    val serverMetadataJson = text("server_metadata_json")
    val playerObjectsJson = text("player_objects_json")
    val inventoryJson = text("inventory_json")
    val neighborHistoryJson = text("neighbor_history_json")
    override val primaryKey = PrimaryKey(playerId)
}

object ArenaLeaderboardTable : Table("arena_leaderboard") {
    val id = integer("id").autoIncrement()
    val playerId = varchar("player_id", 36)
    val playerName = varchar("player_name", 100)
    val arenaName = varchar("arena_name", 100)
    val level = integer("level")
    val points = integer("points")
    val timestamp = long("timestamp")
    override val primaryKey = PrimaryKey(id)

    init {
        
        uniqueIndex(playerId, arenaName)
        
        index(false, arenaName, level, points)
    }
}

object ActiveArenaSessionsTable : Table("active_arena_sessions") {
    val sessionId = varchar("session_id", 36)
    val playerId = varchar("player_id", 36)
    val arenaName = varchar("arena_name", 100)
    val dataJson = text("data_json")
    val createdAt = long("created_at")
    val lastUpdatedAt = long("last_updated_at")
    override val primaryKey = PrimaryKey(sessionId)

    init {
        
        index(false, playerId)
        index(false, arenaName)
        
        index(false, playerId, lastUpdatedAt)
    }
}

object AlliancesTable : Table("alliances") {
    val allianceId = varchar("alliance_id", 36)
    val name = varchar("name", 100)
    val tag = varchar("tag", 10)
    val bannerBytes = text("banner_bytes").nullable()
    val thumbImage = text("thumb_image").nullable()
    val createdAt = long("created_at")
    val createdBy = varchar("created_by", 36)
    val memberCount = integer("member_count").default(0)
    val totalPoints = integer("total_points").default(0)
    val dataJson = text("data_json").nullable()
    override val primaryKey = PrimaryKey(allianceId)

    init {
        
        index(false, name)
        index(false, tag)
    }
}

object AllianceMembersTable : Table("alliance_members") {
    val id = integer("id").autoIncrement()
    val allianceId = varchar("alliance_id", 36)
    val playerId = varchar("player_id", 36)
    val joinedAt = long("joined_at")
    val rank = integer("rank").default(0)
    val lifetimeStatsJson = text("lifetime_stats_json").nullable()
    override val primaryKey = PrimaryKey(id)

    init {
        
        uniqueIndex(playerId)
        
        index(false, allianceId)
    }
}

class BigDBMariaImpl(val database: Database, private val adminEnabled: Boolean) : BigDB {
    init {
        CoroutineScope(Dispatchers.IO).launch {
            setupDatabase()
        }
    }

    private suspend fun setupDatabase() {
        try {
            database.suspendedTransaction {
                SchemaUtils.create(PlayerAccounts, ArenaLeaderboardTable, ActiveArenaSessionsTable, AlliancesTable, AllianceMembersTable)
            }
            val count = database.suspendedTransaction {
                PlayerAccounts.selectAll().count()
            }
            Logger.info { "${Emoji.Database} MariaDB: User table ready, contains $count users." }
            if (adminEnabled) {
                val adminExists = database.suspendedTransaction {
                    PlayerAccounts.selectAll().where { PlayerAccounts.playerId eq AdminData.PLAYER_ID }.count() > 0
                }
                if (!adminExists) {
                    val start = getTimeMillis()
                    database.suspendedTransaction {
                        val adminAccount = PlayerAccount.admin()
                        val adminObjects = PlayerObjects.admin()
                        val adminNeighbor = NeighborHistory.empty(AdminData.PLAYER_ID)
                        val adminInventory = Inventory.admin()

                        PlayerAccounts.insert {
                            it[playerId] = adminAccount.playerId
                            it[hashedPassword] = adminAccount.hashedPassword
                            it[email] = adminAccount.email
                            it[displayName] = adminAccount.displayName
                            it[avatarUrl] = adminAccount.avatarUrl
                            it[createdAt] = adminAccount.createdAt
                            it[lastLogin] = adminAccount.lastLogin
                            it[countryCode] = adminAccount.countryCode
                            it[serverMetadataJson] = JSON.encode(adminAccount.serverMetadata)
                            it[playerObjectsJson] = JSON.encode(adminObjects)
                            it[inventoryJson] = JSON.encode(adminInventory)
                            it[neighborHistoryJson] = JSON.encode(adminNeighbor)
                        }
                    }
                    Logger.info { "${Emoji.Database} MariaDB: Admin account inserted in ${getTimeMillis() - start}ms" }
                } else {
                    Logger.info { "${Emoji.Database} MariaDB: Admin account already exists." }
                }
            }
        } catch (e: Exception) {
            Logger.error { "${Emoji.Database} MariaDB: Failed during setup: $e" }
            throw e
        }
    }

    override suspend fun loadPlayerAccount(playerId: String): PlayerAccount? {
        return database.suspendedTransaction {
            PlayerAccounts.selectAll().where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()?.let { row ->
                    PlayerAccount(
                        playerId = row[PlayerAccounts.playerId],
                        hashedPassword = row[PlayerAccounts.hashedPassword],
                        email = row[PlayerAccounts.email],
                        displayName = row[PlayerAccounts.displayName],
                        avatarUrl = row[PlayerAccounts.avatarUrl],
                        createdAt = row[PlayerAccounts.createdAt],
                        lastLogin = row[PlayerAccounts.lastLogin],
                        countryCode = row[PlayerAccounts.countryCode],
                        serverMetadata = JSON.decode(row[PlayerAccounts.serverMetadataJson])
                    )
                }
        }
    }

    override suspend fun loadPlayerObjects(playerId: String): PlayerObjects? {
        return database.suspendedTransaction {
            PlayerAccounts.selectAll().where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()?.let { row ->
                    JSON.decode<PlayerObjects>(row[PlayerAccounts.playerObjectsJson])
                }
        }
    }

    override suspend fun loadNeighborHistory(playerId: String): NeighborHistory? {
        return database.suspendedTransaction {
            PlayerAccounts.selectAll().where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()?.let { row ->
                    JSON.decode(row[PlayerAccounts.neighborHistoryJson])
                }
        }
    }

    override suspend fun loadInventory(playerId: String): Inventory? {
        return database.suspendedTransaction {
            PlayerAccounts.selectAll().where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()?.let { row ->
                    JSON.decode(row[PlayerAccounts.inventoryJson])
                }
        }
    }

    override suspend fun updatePlayerObjectsJson(playerId: String, updatedPlayerObjects: PlayerObjects) {
        database.suspendedTransaction {
            PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                it[playerObjectsJson] = JSON.encode(updatedPlayerObjects)
            }
        }
    }

    @Suppress("UNCHECKED_CAST")
    override fun <T> getCollection(name: CollectionName): T {
        return when (name) {
            CollectionName.PLAYER_ACCOUNT_COLLECTION -> PlayerAccounts
            CollectionName.PLAYER_OBJECTS_COLLECTION -> PlayerAccounts
            CollectionName.NEIGHBOR_HISTORY_COLLECTION -> PlayerAccounts
            CollectionName.INVENTORY_COLLECTION -> PlayerAccounts
            CollectionName.ARENA_LEADERBOARD_COLLECTION -> ArenaLeaderboardTable
            CollectionName.ACTIVE_ARENA_SESSIONS_COLLECTION -> ActiveArenaSessionsTable
            CollectionName.ALLIANCES_COLLECTION -> AlliancesTable
            CollectionName.ALLIANCE_MEMBERS_COLLECTION -> AllianceMembersTable
        } as T
    }

    override suspend fun createUser(username: String, password: String): String {
        val pid = UUID.new()
        val now = getTimeMillis()

        database.suspendedTransaction {
            val account = PlayerAccount(
                playerId = pid,
                hashedPassword = hashPw(password),
                email = "dummyemail@email.com",
                displayName = username,
                avatarUrl = "",
                createdAt = now,
                lastLogin = now,
                countryCode = null,
                serverMetadata = ServerMetadata()
            )

            val playerSrvId = UUID.new()
            val objects = PlayerObjects.newgame(pid, username, playerSrvId)
            val neighbor = NeighborHistory.empty(pid)
            val inventory = Inventory.newgame(pid)

            PlayerAccounts.insert {
                it[playerId] = account.playerId
                it[hashedPassword] = account.hashedPassword
                it[email] = account.email
                it[displayName] = account.displayName
                it[avatarUrl] = account.avatarUrl
                it[createdAt] = account.createdAt
                it[lastLogin] = account.lastLogin
                it[countryCode] = account.countryCode
                it[serverMetadataJson] = JSON.encode(account.serverMetadata)
                it[playerObjectsJson] = JSON.encode(objects)
                it[inventoryJson] = JSON.encode(inventory)
                it[neighborHistoryJson] = JSON.encode(neighbor)
            }
        }
        return pid
    }

    private fun hashPw(password: String): String {
        return Base64.encode(Bcrypt.hash(password, 10))
    }

    override suspend fun saveArenaLeaderboardEntry(entry: ArenaLeaderboardEntry) {
        database.suspendedTransaction {
            
            
            ArenaLeaderboardTable.upsert {
                it[playerId] = entry.playerId
                it[playerName] = entry.playerName
                it[arenaName] = entry.arenaName
                it[level] = entry.level
                it[points] = entry.points
                it[timestamp] = entry.timestamp
            }
        }
    }

    override suspend fun getArenaLeaderboard(arenaName: String, limit: Int): List<ArenaLeaderboardEntry> {
        return database.suspendedTransaction {
            ArenaLeaderboardTable
                .selectAll()
                .where { ArenaLeaderboardTable.arenaName eq arenaName }
                .orderBy(ArenaLeaderboardTable.level to SortOrder.DESC, ArenaLeaderboardTable.points to SortOrder.DESC)
                .limit(limit)
                .map { row ->
                    ArenaLeaderboardEntry(
                        playerId = row[ArenaLeaderboardTable.playerId],
                        playerName = row[ArenaLeaderboardTable.playerName],
                        arenaName = row[ArenaLeaderboardTable.arenaName],
                        level = row[ArenaLeaderboardTable.level],
                        points = row[ArenaLeaderboardTable.points],
                        timestamp = row[ArenaLeaderboardTable.timestamp]
                    )
                }
        }
    }

    override suspend fun saveActiveArenaSession(session: core.model.game.data.arena.ActiveArenaSession) {
        database.suspendedTransaction {
            ActiveArenaSessionsTable.upsert {
                it[sessionId] = session.id
                it[playerId] = session.playerId
                it[arenaName] = session.arenaName
                it[dataJson] = JSON.encode(session)
                it[createdAt] = session.createdAt
                it[lastUpdatedAt] = session.lastUpdatedAt
            }
        }
    }

    override suspend fun getActiveArenaSession(sessionId: String): core.model.game.data.arena.ActiveArenaSession? {
        return database.suspendedTransaction {
            ActiveArenaSessionsTable
                .selectAll()
                .where { ActiveArenaSessionsTable.sessionId eq sessionId }
                .singleOrNull()
                ?.let { row ->
                    JSON.decode<core.model.game.data.arena.ActiveArenaSession>(row[ActiveArenaSessionsTable.dataJson])
                }
        }
    }

    override suspend fun getActiveArenaSessionsForPlayer(playerId: String): List<core.model.game.data.arena.ActiveArenaSession> {
        return database.suspendedTransaction {
            ActiveArenaSessionsTable
                .selectAll()
                .where { ActiveArenaSessionsTable.playerId eq playerId }
                .orderBy(ActiveArenaSessionsTable.lastUpdatedAt to SortOrder.DESC)
                .map { row ->
                    JSON.decode<core.model.game.data.arena.ActiveArenaSession>(row[ActiveArenaSessionsTable.dataJson])
                }
        }
    }

    override suspend fun deleteActiveArenaSession(sessionId: String) {
        database.suspendedTransaction {
            ActiveArenaSessionsTable.deleteWhere { ActiveArenaSessionsTable.sessionId eq sessionId }
        }
    }

    override suspend fun createAlliance(alliance: data.collection.Alliance) {
        database.suspendedTransaction {
            AlliancesTable.insert {
                it[allianceId] = alliance.allianceId
                it[name] = alliance.name
                it[tag] = alliance.tag
                it[bannerBytes] = alliance.bannerBytes
                it[thumbImage] = alliance.thumbImage
                it[createdAt] = alliance.createdAt
                it[createdBy] = alliance.createdBy
                it[memberCount] = alliance.memberCount
                it[totalPoints] = alliance.totalPoints
                it[dataJson] = alliance.dataJson
            }
        }
    }

    override suspend fun getAlliance(allianceId: String): data.collection.Alliance? {
        return database.suspendedTransaction {
            AlliancesTable
                .selectAll()
                .where { AlliancesTable.allianceId eq allianceId }
                .singleOrNull()
                ?.let { row ->
                    data.collection.Alliance(
                        allianceId = row[AlliancesTable.allianceId],
                        name = row[AlliancesTable.name],
                        tag = row[AlliancesTable.tag],
                        bannerBytes = row[AlliancesTable.bannerBytes],
                        thumbImage = row[AlliancesTable.thumbImage],
                        createdAt = row[AlliancesTable.createdAt],
                        createdBy = row[AlliancesTable.createdBy],
                        memberCount = row[AlliancesTable.memberCount],
                        totalPoints = row[AlliancesTable.totalPoints],
                        dataJson = row[AlliancesTable.dataJson]
                    )
                }
        }
    }

    override suspend fun updateAlliance(alliance: data.collection.Alliance) {
        database.suspendedTransaction {
            AlliancesTable.update({ AlliancesTable.allianceId eq alliance.allianceId }) {
                it[name] = alliance.name
                it[tag] = alliance.tag
                it[bannerBytes] = alliance.bannerBytes
                it[thumbImage] = alliance.thumbImage
                it[memberCount] = alliance.memberCount
                it[totalPoints] = alliance.totalPoints
                it[dataJson] = alliance.dataJson
            }
        }
    }

    override suspend fun addAllianceMember(member: data.collection.AllianceMember) {
        database.suspendedTransaction {
            AllianceMembersTable.insert {
                it[allianceId] = member.allianceId
                it[playerId] = member.playerId
                it[joinedAt] = member.joinedAt
                it[rank] = member.rank
                it[lifetimeStatsJson] = member.lifetimeStats?.let { stats -> JSON.encode(stats) }
            }
        }
    }

    override suspend fun getAllianceMembers(allianceId: String): List<data.collection.AllianceMember> {
        return database.suspendedTransaction {
            AllianceMembersTable
                .selectAll()
                .where { AllianceMembersTable.allianceId eq allianceId }
                .map { row ->
                    data.collection.AllianceMember(
                        allianceId = row[AllianceMembersTable.allianceId],
                        playerId = row[AllianceMembersTable.playerId],
                        joinedAt = row[AllianceMembersTable.joinedAt],
                        rank = row[AllianceMembersTable.rank],
                        lifetimeStats = row[AllianceMembersTable.lifetimeStatsJson]?.let { json ->
                            JSON.decode<core.model.game.data.alliance.AllianceLifetimeStats>(json)
                        }
                    )
                }
        }
    }

    override suspend fun getPlayerAllianceMembership(playerId: String): data.collection.AllianceMember? {
        return database.suspendedTransaction {
            AllianceMembersTable
                .selectAll()
                .where { AllianceMembersTable.playerId eq playerId }
                .singleOrNull()
                ?.let { row ->
                    data.collection.AllianceMember(
                        allianceId = row[AllianceMembersTable.allianceId],
                        playerId = row[AllianceMembersTable.playerId],
                        joinedAt = row[AllianceMembersTable.joinedAt],
                        rank = row[AllianceMembersTable.rank],
                        lifetimeStats = row[AllianceMembersTable.lifetimeStatsJson]?.let { json ->
                            JSON.decode<core.model.game.data.alliance.AllianceLifetimeStats>(json)
                        }
                    )
                }
        }
    }

    override suspend fun updateAllianceMember(member: data.collection.AllianceMember) {
        database.suspendedTransaction {
            AllianceMembersTable.update({ AllianceMembersTable.playerId eq member.playerId }) {
                it[allianceId] = member.allianceId
                it[rank] = member.rank
                it[lifetimeStatsJson] = member.lifetimeStats?.let { stats -> JSON.encode(stats) }
            }
        }
    }

    override suspend fun removeAllianceMember(playerId: String) {
        database.suspendedTransaction {
            AllianceMembersTable.deleteWhere { AllianceMembersTable.playerId eq playerId }
        }
    }

    override suspend fun shutdown() = Unit
}

suspend fun <T> Database.suspendedTransaction(block: suspend Transaction.() -> T): T {
    return newSuspendedTransaction(Dispatchers.IO, this, statement = block)
}

suspend fun <T> Database.suspendedTransactionResult(
    block: suspend Transaction.() -> T
): Result<T> = runCatching {
    this.suspendedTransaction(block)
}
