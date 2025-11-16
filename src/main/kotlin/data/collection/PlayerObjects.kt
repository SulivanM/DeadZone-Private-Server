package data.collection

import core.data.AdminData
import core.metadata.model.ByteArrayAsBase64Serializer
import core.model.data.HighActivity
import core.model.data.Notification
import core.metadata.model.PlayerFlags
import core.metadata.model.toByteArray
import core.model.data.user.AbstractUser
import core.model.game.data.Attributes
import core.model.game.data.BatchRecycleJob
import core.model.game.data.BuildingCollection
import core.model.game.data.BuildingLike
import core.model.game.data.GameResources
import core.model.game.data.Gender_Constants
import core.model.game.data.MissionData
import core.model.game.data.MissionStats
import core.model.game.data.Survivor
import core.model.game.data.SurvivorAppearance
import core.model.game.data.SurvivorAppearance.Companion.toHumanAppearance
import core.model.game.data.SurvivorClassConstants_Constants
import core.model.game.data.SurvivorCollection
import core.model.game.data.SurvivorLoadoutEntry
import core.model.game.data.Task
import core.model.game.data.TaskCollection
import core.model.game.data.assignment.AssignmentData
import core.model.game.data.bounty.InfectedBounty
import core.model.game.data.effects.Effect
import core.model.game.data.quests.GQDataObj
import core.model.game.data.research.ResearchState
import core.model.game.data.alliance.AllianceWinnings
import core.model.game.data.alliance.AllianceLifetimeStats
import core.model.game.data.skills.SkillState
import core.model.network.RemotePlayerData
import io.ktor.util.date.getTimeMillis
import kotlinx.serialization.Serializable

@Serializable
data class PlayerObjects(
    val playerId: String,
    val key: String,
    val user: Map<String, AbstractUser> = emptyMap(),
    val admin: Boolean,
    @Serializable(with = ByteArrayAsBase64Serializer::class)
    val flags: ByteArray = PlayerFlags.newgame(),
    @Serializable(with = ByteArrayAsBase64Serializer::class)
    val upgrades: ByteArray = ByteArray(0), // Player upgrades (Death Mobile, Inventory, etc.)
    val nickname: String?,
    val playerSurvivor: String?,
    val levelPts: UInt = 0u,
    val restXP: Int = 0,
    val oneTimePurchases: List<String> = emptyList(),
    val allianceId: String? = null,
    val allianceTag: String? = null,
    val allianceWinnings: AllianceWinnings = AllianceWinnings(),
    val allianceLifetimeStats: AllianceLifetimeStats? = null,
    val neighbors: Map<String, RemotePlayerData>?,
    val friends: Map<String, RemotePlayerData>?,
    val research: ResearchState?,
    val skills: Map<String, SkillState>?,
    val resources: GameResources,
    val survivors: List<Survivor>,
    val playerAttributes: Attributes,
    val buildings: List<BuildingLike>,
    val rally: Map<String, List<String>>?,
    val tasks: List<Task>,
    val missions: List<MissionData>?,
    val assignments: List<AssignmentData>?,
    val effects: List<ByteArray>?,
    val globalEffects: List<ByteArray>?,
    val cooldowns: Map<String, ByteArray>?,
    val batchRecycles: List<BatchRecycleJob>?,
    val offenceLoadout: Map<String, SurvivorLoadoutEntry>?,
    val defenceLoadout: Map<String, SurvivorLoadoutEntry>?,
    val quests: ByteArray?,
    val questsCollected: ByteArray?,
    val achievements: ByteArray?,
    val dailyQuest: ByteArray?,
    val questsTracked: String?,
    val gQuestsV2: Map<String, GQDataObj>?,
    val bountyCap: Int,
    val bountyCapTimestamp: Long? = null,
    val lastLogout: Long? = null,
    val dzBounty: InfectedBounty?,
    val nextDZBountyIssue: Long,
    val highActivity: HighActivity?,
    val invsize: Int = 20, // Base inventory size
    val notifications: List<Notification?>?,
    // Internal server-only fields (not sent to client)
    val lifetimeStats: MissionStats? = null,  // Accumulated stats across all missions for quest tracking
    val chatContacts: List<String> = emptyList(),
    val chatBlocks: List<String> = emptyList(),
) {
    companion object {
        fun admin(): PlayerObjects {
            val mockFlags = IntRange(0, 8).map { false }.toByteArray()
            val emptyUpgrades = ByteArray(0)

            return PlayerObjects(
                playerId = AdminData.PLAYER_ID,
                key = AdminData.PLAYER_DATA_KEY,
                admin = true,
                flags = PlayerFlags.skipTutorial(),
                upgrades = emptyUpgrades,
                nickname = AdminData.DISPLAY_NAME,
                playerSurvivor = AdminData.PLAYER_SRV_ID,
                allianceId = null,
                allianceTag = null,
                neighbors = null,
                friends = null,
                research = ResearchState(active = listOf(), mapOf()),
                skills = null,
                resources = GameResources(
                    cash = 100000,
                    wood = 99999,
                    metal = 99999,
                    cloth = 99999,
                    food = 200,
                    water = 200,
                    ammunition = 99999
                ),
                survivors = SurvivorCollection.threeSurvivors(),
                playerAttributes = Attributes.starter(),
                buildings = BuildingCollection.starterBase(),
                rally = mapOf(),
                tasks = TaskCollection().list,
                missions = emptyList(),
                assignments = null,
                effects = listOf(Effect.halloweenTrickPumpkinZombie(), Effect.halloweenTrickPewPew()),
                globalEffects = listOf(Effect.halloweenTrickPumpkinZombie(), Effect.halloweenTrickPewPew()),
                cooldowns = null,
                batchRecycles = null,
                offenceLoadout = mapOf(
                    AdminData.PLAYER_SRV_ID to SurvivorLoadoutEntry.playerLoudout(),
                    AdminData.FIGHTER_SRV_ID to SurvivorLoadoutEntry.fighterLoadout(),
                    AdminData.RECON_SRV_ID to SurvivorLoadoutEntry.reconLoadout(),
                ),
                defenceLoadout = mapOf(
                    AdminData.PLAYER_SRV_ID to SurvivorLoadoutEntry.playerLoudout(),
                    AdminData.FIGHTER_SRV_ID to SurvivorLoadoutEntry.fighterLoadout(),
                    AdminData.RECON_SRV_ID to SurvivorLoadoutEntry.reconLoadout(),
                ),
                quests = mockFlags,
                questsCollected = mockFlags,
                achievements = mockFlags,
                dailyQuest = null,
                questsTracked = null,
                gQuestsV2 = null,
                bountyCap = 0,
                bountyCapTimestamp = null,
                lastLogout = getTimeMillis() - 100000,
                dzBounty = null,
                nextDZBountyIssue = 1230768000000,
                highActivity = null,
                invsize = 200,
                notifications = null,
            )
        }

        fun newgame(pid: String, nickname: String, playerSrvId: String): PlayerObjects {
            val mockFlags = IntRange(0, 8).map { false }.toByteArray()
            val emptyUpgrades = ByteArray(0)
            val playerSrv = Survivor(
                id = playerSrvId,
                title = nickname,
                firstName = nickname,
                lastName = "DZ",
                gender = Gender_Constants.MALE.value,
                portrait = null,
                classId = SurvivorClassConstants_Constants.PLAYER.value,
                morale = emptyMap(),
                injuries = emptyList(),
                level = 0,
                xp = 0,
                missionId = null,
                assignmentId = null,
                reassignTimer = null,
                appearance = SurvivorAppearance.playerM().toHumanAppearance(),
                voice = "asian-m",
                accessories = emptyMap(),
                maxClothingAccessories = 4
            )

            return PlayerObjects(
                playerId = pid,
                key = pid,
                admin = false,
                flags = PlayerFlags.create(nicknameVerified = false),
                upgrades = emptyUpgrades,
                nickname = null,
                playerSurvivor = playerSrvId,
                allianceId = null,
                allianceTag = null,
                neighbors = null,
                friends = null,
                research = ResearchState(active = emptyList(), levels = emptyMap()),
                skills = null,
                resources = GameResources(
                    cash = 100,
                    wood = 300,
                    metal = 300,
                    cloth = 300,
                    food = 25,
                    water = 25,
                    ammunition = 150
                ),
                survivors = listOf(playerSrv),
                playerAttributes = Attributes.starter(),
                buildings = BuildingCollection.starterBase(),
                rally = emptyMap(),
                tasks = TaskCollection().list,
                missions = emptyList(),
                assignments = null,
                effects = listOf(Effect.halloweenTrickPumpkinZombie(), Effect.halloweenTrickPewPew()),
                globalEffects = listOf(Effect.halloweenTrickPumpkinZombie(), Effect.halloweenTrickPewPew()),
                cooldowns = null,
                batchRecycles = null,
                offenceLoadout = emptyMap(),
                defenceLoadout = emptyMap(),
                quests = mockFlags,
                questsCollected = mockFlags,
                achievements = mockFlags,
                dailyQuest = null,
                questsTracked = null,
                gQuestsV2 = null,
                bountyCap = 0,
                bountyCapTimestamp = null,
                lastLogout = null,
                dzBounty = null,
                nextDZBountyIssue = 1765074185294,
                highActivity = null,
                invsize = 20,
                notifications = null,
            )
        }
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as PlayerObjects

        if (admin != other.admin) return false
        if (restXP != other.restXP) return false
        if (bountyCap != other.bountyCap) return false
        if (bountyCapTimestamp != other.bountyCapTimestamp) return false
        if (lastLogout != other.lastLogout) return false
        if (nextDZBountyIssue != other.nextDZBountyIssue) return false
        if (invsize != other.invsize) return false
        if (key != other.key) return false
        if (user != other.user) return false
        if (!flags.contentEquals(other.flags)) return false
        if (!upgrades.contentEquals(other.upgrades)) return false
        if (nickname != other.nickname) return false
        if (playerSurvivor != other.playerSurvivor) return false
        if (levelPts != other.levelPts) return false
        if (oneTimePurchases != other.oneTimePurchases) return false
        if (allianceId != other.allianceId) return false
        if (allianceTag != other.allianceTag) return false
        if (neighbors != other.neighbors) return false
        if (friends != other.friends) return false
        if (research != other.research) return false
        if (skills != other.skills) return false
        if (resources != other.resources) return false
        if (survivors != other.survivors) return false
        if (playerAttributes != other.playerAttributes) return false
        if (buildings != other.buildings) return false
        if (rally != other.rally) return false
        if (tasks != other.tasks) return false
        if (missions != other.missions) return false
        if (assignments != other.assignments) return false
        if (effects != other.effects) return false
        if (globalEffects != other.globalEffects) return false
        if (cooldowns != other.cooldowns) return false
        if (batchRecycles != other.batchRecycles) return false
        if (offenceLoadout != other.offenceLoadout) return false
        if (defenceLoadout != other.defenceLoadout) return false
        if (!quests.contentEquals(other.quests)) return false
        if (!questsCollected.contentEquals(other.questsCollected)) return false
        if (!achievements.contentEquals(other.achievements)) return false
        if (!dailyQuest.contentEquals(other.dailyQuest)) return false
        if (questsTracked != other.questsTracked) return false
        if (gQuestsV2 != other.gQuestsV2) return false
        if (lifetimeStats != other.lifetimeStats) return false
        if (dzBounty != other.dzBounty) return false
        if (highActivity != other.highActivity) return false
        if (notifications != other.notifications) return false
        if (chatContacts != other.chatContacts) return false
        if (chatBlocks != other.chatBlocks) return false

        return true
    }

    override fun hashCode(): Int {
        var result = admin.hashCode()
        result = 31 * result + restXP
        result = 31 * result + bountyCap
        result = 31 * result + (bountyCapTimestamp?.hashCode() ?: 0)
        result = 31 * result + (lastLogout?.hashCode() ?: 0)
        result = 31 * result + nextDZBountyIssue.hashCode()
        result = 31 * result + invsize
        result = 31 * result + key.hashCode()
        result = 31 * result + user.hashCode()
        result = 31 * result + flags.contentHashCode()
        result = 31 * result + upgrades.contentHashCode()
        result = 31 * result + nickname.hashCode()
        result = 31 * result + playerSurvivor.hashCode()
        result = 31 * result + levelPts.hashCode()
        result = 31 * result + oneTimePurchases.hashCode()
        result = 31 * result + (allianceId?.hashCode() ?: 0)
        result = 31 * result + (allianceTag?.hashCode() ?: 0)
        result = 31 * result + (neighbors?.hashCode() ?: 0)
        result = 31 * result + (friends?.hashCode() ?: 0)
        result = 31 * result + (research?.hashCode() ?: 0)
        result = 31 * result + (skills?.hashCode() ?: 0)
        result = 31 * result + resources.hashCode()
        result = 31 * result + survivors.hashCode()
        result = 31 * result + playerAttributes.hashCode()
        result = 31 * result + buildings.hashCode()
        result = 31 * result + (rally?.hashCode() ?: 0)
        result = 31 * result + tasks.hashCode()
        result = 31 * result + (missions?.hashCode() ?: 0)
        result = 31 * result + (assignments?.hashCode() ?: 0)
        result = 31 * result + (effects?.hashCode() ?: 0)
        result = 31 * result + (globalEffects?.hashCode() ?: 0)
        result = 31 * result + (cooldowns?.hashCode() ?: 0)
        result = 31 * result + (batchRecycles?.hashCode() ?: 0)
        result = 31 * result + (offenceLoadout?.hashCode() ?: 0)
        result = 31 * result + (defenceLoadout?.hashCode() ?: 0)
        result = 31 * result + (quests?.contentHashCode() ?: 0)
        result = 31 * result + (questsCollected?.contentHashCode() ?: 0)
        result = 31 * result + (achievements?.contentHashCode() ?: 0)
        result = 31 * result + (dailyQuest?.hashCode() ?: 0)
        result = 31 * result + (questsTracked?.hashCode() ?: 0)
        result = 31 * result + (gQuestsV2?.hashCode() ?: 0)
        result = 31 * result + (lifetimeStats?.hashCode() ?: 0)
        result = 31 * result + (dzBounty?.hashCode() ?: 0)
        result = 31 * result + (highActivity?.hashCode() ?: 0)
        result = 31 * result + (notifications?.hashCode() ?: 0)
        result = 31 * result + chatContacts.hashCode()
        result = 31 * result + chatBlocks.hashCode()
        return result
    }
}