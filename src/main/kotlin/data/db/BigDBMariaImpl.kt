package data.db

import com.toxicbakery.bcrypt.Bcrypt
import core.data.AdminData
import data.collection.*
import io.ktor.util.date.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.experimental.newSuspendedTransaction
import common.Emoji
import common.JSON
import common.Logger
import common.UUID
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
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

    // Game data consolidated into player_accounts
    val playerObjectsJson = text("player_objects_json")
    val neighborHistoryJson = text("neighbor_history_json")
    val inventoryJson = text("inventory_json")
    val payVaultJson = text("pay_vault_json")

    override val primaryKey = PrimaryKey(playerId)
}

object Alliances : Table("alliances") {
    val allianceId = varchar("alliance_id", 36)
    val name = varchar("name", 100).uniqueIndex()
    val tag = varchar("tag", 10).uniqueIndex()
    val bannerBytes = text("banner_bytes")
    val thumbImage = text("thumb_image")
    val createdAt = long("created_at")
    val creatorPlayerId = varchar("creator_player_id", 36)
    val points = integer("points").default(0)
    val tokens = integer("tokens").default(0)

    override val primaryKey = PrimaryKey(allianceId)
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
                SchemaUtils.create(PlayerAccounts)
                SchemaUtils.create(Alliances)
            }
            val count = database.suspendedTransaction {
                PlayerAccounts.selectAll().count()
            }
            val allianceCount = database.suspendedTransaction {
                Alliances.selectAll().count()
            }
            Logger.info { "${Emoji.Database} MariaDB: User table ready, contains $count users." }
            Logger.info { "${Emoji.Database} MariaDB: Alliances table ready, contains $allianceCount alliances." }
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
                        val adminPayVault = PayVaultData.empty(AdminData.PLAYER_ID)

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
                            it[neighborHistoryJson] = JSON.encode(adminNeighbor)
                            it[inventoryJson] = JSON.encode(adminInventory)
                            it[payVaultJson] = JSON.encode(adminPayVault)
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

    override suspend fun updateInventoryJson(playerId: String, updatedInventory: Inventory) {
        database.suspendedTransaction {
            PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                it[inventoryJson] = JSON.encode(updatedInventory)
            }
        }
    }

    override suspend fun updateNeighborHistoryJson(playerId: String, updatedNeighborHistory: NeighborHistory) {
        database.suspendedTransaction {
            PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                it[neighborHistoryJson] = JSON.encode(updatedNeighborHistory)
            }
        }
    }

    override suspend fun createObject(table: String, key: String, properties: Map<String, Any>, loadExisting: Boolean): String? {
        return database.suspendedTransaction {
            val exists = PlayerAccounts.selectAll().where { PlayerAccounts.playerId eq key }.count() > 0

            if (exists && loadExisting) {
                // Return existing object version
                generateVersion()
            } else if (exists && !loadExisting) {
                // Object already exists and we're not loading existing
                throw Exception("Object already exists: $table/$key")
            } else {
                // Create new object - this is a simplified implementation
                // In a real scenario, you'd need to handle creating new player accounts
                // For now, we'll just return a success indicator
                generateVersion()
            }
        }
    }

    override suspend fun saveObjectChanges(
        table: String,
        key: String,
        onlyIfVersion: String?,
        changes: Map<String, Any>,
        createIfMissing: Boolean
    ): String? {
        return database.suspendedTransaction {
            val row = PlayerAccounts.selectAll().where { PlayerAccounts.playerId eq key }.singleOrNull()

            if (row == null && !createIfMissing) {
                throw Exception("Object not found: $table/$key")
            }

            if (row == null && createIfMissing) {
                // Would create new object here
                return@suspendedTransaction generateVersion()
            }

            // For optimistic locking, we'd check version here
            // For now, we'll apply the changes based on table type
            when (table) {
                "PlayerObjects" -> {
                    val current = JSON.decode<PlayerObjects>(row!![PlayerAccounts.playerObjectsJson])
                    val updated = applyChangesToPlayerObjects(current, changes)
                    PlayerAccounts.update({ PlayerAccounts.playerId eq key }) {
                        it[playerObjectsJson] = JSON.encode(updated)
                    }
                }
                "Inventory" -> {
                    val current = JSON.decode<Inventory>(row!![PlayerAccounts.inventoryJson])
                    val updated = applyChangesToInventory(current, changes)
                    PlayerAccounts.update({ PlayerAccounts.playerId eq key }) {
                        it[inventoryJson] = JSON.encode(updated)
                    }
                }
                "NeighborHistory" -> {
                    val current = JSON.decode<NeighborHistory>(row!![PlayerAccounts.neighborHistoryJson])
                    val updated = applyChangesToNeighborHistory(current, changes)
                    PlayerAccounts.update({ PlayerAccounts.playerId eq key }) {
                        it[neighborHistoryJson] = JSON.encode(updated)
                    }
                }
            }

            generateVersion()
        }
    }

    override suspend fun deleteObjects(table: String, keys: List<String>) {
        database.suspendedTransaction {
            // For now, we don't actually delete player accounts
            // In a real scenario, you might want to soft-delete or archive
            keys.forEach { key ->
                PlayerAccounts.deleteWhere { PlayerAccounts.playerId eq key }
            }
        }
    }

    private fun generateVersion(): String {
        return System.currentTimeMillis().toString()
    }

    private fun applyChangesToPlayerObjects(current: PlayerObjects, changes: Map<String, Any>): PlayerObjects {
        // This is a simplified implementation
        // In reality, you'd need to apply changes based on the property paths
        return current
    }

    private fun applyChangesToInventory(current: Inventory, changes: Map<String, Any>): Inventory {
        return current
    }

    private fun applyChangesToNeighborHistory(current: NeighborHistory, changes: Map<String, Any>): NeighborHistory {
        return current
    }

    @Suppress("UNCHECKED_CAST")
    override fun <T> getCollection(name: CollectionName): T {
        return when (name) {
            CollectionName.PLAYER_ACCOUNT_COLLECTION -> PlayerAccounts
            CollectionName.PLAYER_OBJECTS_COLLECTION -> PlayerAccounts
            CollectionName.NEIGHBOR_HISTORY_COLLECTION -> PlayerAccounts
            CollectionName.INVENTORY_COLLECTION -> PlayerAccounts
        } as T
    }

    override suspend fun createUser(username: String, password: String, email: String?, countryCode: String?): String {
        val pid = UUID.new()
        val now = getTimeMillis()

        database.suspendedTransaction {
            val account = PlayerAccount(
                playerId = pid,
                hashedPassword = hashPw(password),
                email = email ?: "dummyemail@email.com",
                displayName = username,
                avatarUrl = "https://picsum.photos/200",
                createdAt = now,
                lastLogin = now,
                countryCode = countryCode,
                serverMetadata = ServerMetadata()
            )

            val playerSrvId = UUID.new()
            val objects = PlayerObjects.newgame(pid, username, playerSrvId)
            val neighbor = NeighborHistory.empty(pid)
            val inventory = Inventory.newgame(pid)
            val payVault = PayVaultData.empty(pid)

            PlayerAccounts.insert {
                it[playerId] = account.playerId
                it[hashedPassword] = account.hashedPassword
                it[PlayerAccounts.email] = account.email
                it[displayName] = account.displayName
                it[avatarUrl] = account.avatarUrl
                it[createdAt] = account.createdAt
                it[lastLogin] = account.lastLogin
                it[PlayerAccounts.countryCode] = account.countryCode
                it[serverMetadataJson] = JSON.encode(account.serverMetadata)
                it[playerObjectsJson] = JSON.encode(objects)
                it[neighborHistoryJson] = JSON.encode(neighbor)
                it[inventoryJson] = JSON.encode(inventory)
                it[payVaultJson] = JSON.encode(payVault)
            }
        }
        return pid
    }

    @OptIn(kotlin.io.encoding.ExperimentalEncodingApi::class)
    private fun hashPw(password: String): String {
        return Base64.encode(Bcrypt.hash(password, 10))
    }

    override suspend fun loadPayVault(playerId: String): PayVaultData? {
        return database.suspendedTransaction {
            PlayerAccounts.selectAll().where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()?.let { row ->
                    JSON.decode<PayVaultData>(row[PlayerAccounts.payVaultJson])
                }
        }
    }

    override suspend fun updatePayVault(playerId: String, payVault: PayVaultData) {
        database.suspendedTransaction {
            PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                it[payVaultJson] = JSON.encode(payVault)
            }
        }
    }

    override suspend fun creditCoins(playerId: String, amount: Long, reason: String): PayVaultData {
        return database.suspendedTransaction {
            val current = PlayerAccounts.selectAll().where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()?.let { row ->
                    JSON.decode<PayVaultData>(row[PlayerAccounts.payVaultJson])
                } ?: throw Exception("PayVault not found for player: $playerId")

            val updated = current.copy(
                coins = current.coins + amount,
                version = System.currentTimeMillis().toString()
            )

            PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                it[payVaultJson] = JSON.encode(updated)
            }

            updated
        }
    }

    override suspend fun debitCoins(playerId: String, amount: Long, reason: String): PayVaultData {
        return database.suspendedTransaction {
            val current = PlayerAccounts.selectAll().where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()?.let { row ->
                    JSON.decode<PayVaultData>(row[PlayerAccounts.payVaultJson])
                } ?: throw Exception("PayVault not found for player: $playerId")

            if (current.coins < amount) {
                throw Exception("Insufficient coins: has ${current.coins}, needs $amount")
            }

            val updated = current.copy(
                coins = current.coins - amount,
                version = System.currentTimeMillis().toString()
            )

            PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                it[payVaultJson] = JSON.encode(updated)
            }

            updated
        }
    }

    override suspend fun giveItems(playerId: String, items: List<PayVaultItemData>): PayVaultData {
        return database.suspendedTransaction {
            val current = PlayerAccounts.selectAll().where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()?.let { row ->
                    JSON.decode<PayVaultData>(row[PlayerAccounts.payVaultJson])
                } ?: throw Exception("PayVault not found for player: $playerId")

            val updated = current.copy(
                items = current.items + items,
                version = System.currentTimeMillis().toString()
            )

            PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                it[payVaultJson] = JSON.encode(updated)
            }

            updated
        }
    }

    override suspend fun consumeItems(playerId: String, itemIds: List<String>): PayVaultData {
        return database.suspendedTransaction {
            val current = PlayerAccounts.selectAll().where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()?.let { row ->
                    JSON.decode<PayVaultData>(row[PlayerAccounts.payVaultJson])
                } ?: throw Exception("PayVault not found for player: $playerId")

            // Remove consumed items
            val updated = current.copy(
                items = current.items.filterNot { it.id in itemIds },
                version = System.currentTimeMillis().toString()
            )

            PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                it[payVaultJson] = JSON.encode(updated)
            }

            updated
        }
    }

    // ==================== Alliance Operations ====================

    override suspend fun createAlliance(
        allianceId: String,
        name: String,
        tag: String,
        bannerBytes: String,
        thumbImage: String,
        creatorPlayerId: String
    ): Boolean {
        return database.suspendedTransaction {
            try {
                Alliances.insert {
                    it[Alliances.allianceId] = allianceId
                    it[Alliances.name] = name
                    it[Alliances.tag] = tag
                    it[Alliances.bannerBytes] = bannerBytes
                    it[Alliances.thumbImage] = thumbImage
                    it[Alliances.createdAt] = getTimeMillis()
                    it[Alliances.creatorPlayerId] = creatorPlayerId
                }
                true
            } catch (e: Exception) {
                Logger.error { "Failed to create alliance: ${e.message}" }
                false
            }
        }
    }

    override suspend fun allianceNameExists(name: String): Boolean {
        return database.suspendedTransaction {
            Alliances.selectAll().where { Alliances.name eq name }.count() > 0
        }
    }

    override suspend fun allianceTagExists(tag: String): Boolean {
        return database.suspendedTransaction {
            Alliances.selectAll().where { Alliances.tag eq tag }.count() > 0
        }
    }

    override suspend fun loadAlliance(allianceId: String): core.model.game.data.alliance.AllianceData? {
        return database.suspendedTransaction {
            val row = Alliances.selectAll().where { Alliances.allianceId eq allianceId }.singleOrNull()
            if (row != null) {
                core.model.game.data.alliance.AllianceData(
                    allianceDataSummary = core.model.game.data.alliance.AllianceDataSummary(
                        allianceId = row[Alliances.allianceId],
                        name = row[Alliances.name],
                        tag = row[Alliances.tag],
                        banner = row[Alliances.bannerBytes],
                        thumbURI = row[Alliances.thumbImage],
                        memberCount = 1,
                        efficiency = 0.0,
                        points = row[Alliances.points]
                    ),
                    members = null, // Will be loaded separately
                    messages = null, // Will be loaded separately
                    enemies = null,
                    ranks = null,
                    bannerEdits = 0,
                    effects = emptyList(),
                    tokens = row[Alliances.tokens],
                    taskSet = null,
                    tasks = null,
                    attackedTargets = null,
                    scoutedTargets = null
                )
            } else {
                null
            }
        }
    }

    override suspend fun getAllianceMembers(allianceId: String): List<core.model.game.data.alliance.AllianceMember> {
        return database.suspendedTransaction {
            // Load alliance creator as the only member for now
            val alliance = Alliances.selectAll().where { Alliances.allianceId eq allianceId }.singleOrNull()
            if (alliance != null) {
                val creatorId = alliance[Alliances.creatorPlayerId]
                val playerObjects = loadPlayerObjects(creatorId)
                if (playerObjects != null) {
                    listOf(
                        core.model.game.data.alliance.AllianceMember(
                            playerId = creatorId,
                            nickname = playerObjects.nickname ?: "Unknown",
                            level = playerObjects.survivors.firstOrNull()?.level ?: 0,
                            joindate = alliance[Alliances.createdAt],
                            rank = 0u, // Founder
                            tokens = 0u,
                            online = true,
                            points = 0u,
                            pointsAttack = 0u,
                            pointsDefend = 0u,
                            pointsMission = 0u,
                            efficiency = 0.0,
                            wins = 0,
                            losses = 0,
                            abandons = 0,
                            defWins = 0,
                            defLosses = 0,
                            missionSuccess = 0,
                            missionFail = 0,
                            missionAbandon = 0,
                            missionEfficiency = 0.0,
                            raidWinPts = 0u,
                            raidLosePts = 0u
                        )
                    )
                } else {
                    emptyList()
                }
            } else {
                emptyList()
            }
        }
    }

    override suspend fun getAllianceMessages(allianceId: String): List<core.model.game.data.alliance.AllianceMessage> {
        // No messages initially
        return emptyList()
    }

    override suspend fun shutdown() = Unit
}

/**
 * Non-blocking I/O wrapper for Exposed's transaction. It always use `Dispatchers.IO`.
 */
suspend fun <T> Database.suspendedTransaction(block: suspend Transaction.() -> T): T {
    return newSuspendedTransaction(Dispatchers.IO, this, statement = block)
}

/**
 * Executes a suspending transaction on the database and returns a Result wrapper with `runCatching`.
 */
suspend fun <T> Database.suspendedTransactionResult(
    block: suspend Transaction.() -> T
): Result<T> = runCatching {
    this.suspendedTransaction(block)
}
