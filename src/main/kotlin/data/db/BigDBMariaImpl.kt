package data.db

import com.toxicbakery.bcrypt.Bcrypt
import context.GlobalContext
import core.data.AdminData
import data.collection.*
import io.ktor.util.date.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction
import utils.Emoji
import utils.Logger
import utils.UUID
import kotlin.io.encoding.Base64

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
    override val primaryKey = PrimaryKey(playerId)
}

object PlayerObjectsTable : Table("player_objects") {
    val playerId = varchar("player_id", 36).uniqueIndex()
    val dataJson = text("data_json")
    override val primaryKey = PrimaryKey(playerId)
}

object NeighborHistoryTable : Table("neighbor_history") {
    val playerId = varchar("player_id", 36).uniqueIndex()
    val dataJson = text("data_json")
    override val primaryKey = PrimaryKey(playerId)
}

object InventoryTable : Table("inventory") {
    val playerId = varchar("player_id", 36).uniqueIndex()
    val dataJson = text("data_json")
    override val primaryKey = PrimaryKey(playerId)
}

class BigDBMariaImpl(val database: Database, private val adminEnabled: Boolean) : BigDB {
    private val json = GlobalContext.json

    init {
        CoroutineScope(Dispatchers.IO).launch {
            setupDatabase()
        }
    }

    private fun setupDatabase() {
        try {
            transaction(database) {
                SchemaUtils.create(PlayerAccounts, PlayerObjectsTable, NeighborHistoryTable, InventoryTable)
            }
            val count = transaction(database) {
                PlayerAccounts.selectAll().count()
            }
            Logger.info { "${Emoji.Database} MariaDB: User table ready, contains $count users." }
            if (adminEnabled) {
                val adminExists = transaction(database) {
                    PlayerAccounts.selectAll().where { PlayerAccounts.playerId eq AdminData.PLAYER_ID }.count() > 0
                }
                if (!adminExists) {
                    val start = getTimeMillis()
                    transaction(database) {
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
                            it[serverMetadataJson] = json.encodeToString(adminAccount.serverMetadata)
                        }

                        PlayerObjectsTable.insert {
                            it[playerId] = adminObjects.playerId
                            it[dataJson] = json.encodeToString(adminObjects)
                        }

                        NeighborHistoryTable.insert {
                            it[playerId] = adminNeighbor.playerId
                            it[dataJson] = json.encodeToString(adminNeighbor)
                        }

                        InventoryTable.insert {
                            it[playerId] = adminInventory.playerId
                            it[dataJson] = json.encodeToString(adminInventory)
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
        return transaction(database) {
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
                        serverMetadata = json.decodeFromString(row[PlayerAccounts.serverMetadataJson])
                    )
                }
        }
    }

    override suspend fun loadPlayerObjects(playerId: String): PlayerObjects? {
        return transaction(database) {
            PlayerObjectsTable.selectAll().where { PlayerObjectsTable.playerId eq playerId }
                .singleOrNull()?.let { row ->
                    val playerobject = json.decodeFromString<PlayerObjects>(row[PlayerObjectsTable.dataJson])
                    println("PBS: ${playerobject.buildings}")
                    playerobject
                }
        }
    }

    override suspend fun loadNeighborHistory(playerId: String): NeighborHistory? {
        return transaction(database) {
            NeighborHistoryTable.selectAll().where { NeighborHistoryTable.playerId eq playerId }
                .singleOrNull()?.let { row ->
                    json.decodeFromString(row[NeighborHistoryTable.dataJson])
                }
        }
    }

    override suspend fun loadInventory(playerId: String): Inventory? {
        return transaction(database) {
            InventoryTable.selectAll().where { InventoryTable.playerId eq playerId }
                .singleOrNull()?.let { row ->
                    json.decodeFromString(row[InventoryTable.dataJson])
                }
        }
    }

    override suspend fun updatePlayerObjectsJson(playerId: String, updatedPlayerObjects: PlayerObjects) {
        transaction(database) {
            PlayerObjectsTable.update({ PlayerObjectsTable.playerId eq playerId }) {
                it[dataJson] = json.encodeToString(updatedPlayerObjects)
            }
        }
    }

    @Suppress("UNCHECKED_CAST")
    override suspend fun <T> getCollection(name: CollectionName): T {
        return when (name) {
            CollectionName.PLAYER_ACCOUNT_COLLECTION -> PlayerAccounts
            CollectionName.PLAYER_OBJECTS_COLLECTION -> PlayerObjectsTable
            CollectionName.NEIGHBOR_HISTORY_COLLECTION -> NeighborHistoryTable
            CollectionName.INVENTORY_COLLECTION -> InventoryTable
        } as T
    }

    override suspend fun createUser(username: String, password: String): String {
        val pid = UUID.new()
        val now = getTimeMillis()

        transaction(database) {
            val account = PlayerAccount(
                playerId = pid,
                hashedPassword = hashPw(password),
                email = "dummyemail@email.com",
                displayName = username,
                avatarUrl = "https://picsum.photos/200",
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
                it[serverMetadataJson] = json.encodeToString(account.serverMetadata)
            }

            PlayerObjectsTable.insert {
                it[playerId] = objects.playerId
                it[dataJson] = json.encodeToString(objects)
            }

            NeighborHistoryTable.insert {
                it[playerId] = neighbor.playerId
                it[dataJson] = json.encodeToString(neighbor)
            }

            InventoryTable.insert {
                it[playerId] = inventory.playerId
                it[dataJson] = json.encodeToString(inventory)
            }
        }
        return pid
    }

    private fun hashPw(password: String): String {
        return Base64.encode(Bcrypt.hash(password, 10))
    }

    override suspend fun shutdown() {}
}