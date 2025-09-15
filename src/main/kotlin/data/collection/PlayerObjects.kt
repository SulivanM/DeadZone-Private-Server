package dev.deadzone.data.collection

import dev.deadzone.core.data.AdminData
import dev.deadzone.core.model.data.ByteArrayAsBinarySerializer
import dev.deadzone.core.model.data.HighActivity
import dev.deadzone.core.model.data.Notification
import dev.deadzone.core.model.data.PlayerFlags
import dev.deadzone.core.model.data.toByteArray
import dev.deadzone.core.model.data.user.AbstractUser
import dev.deadzone.core.model.game.data.Attributes
import dev.deadzone.core.model.game.data.BatchRecycleJob
import dev.deadzone.core.model.game.data.BuildingCollection
import dev.deadzone.core.model.game.data.BuildingLike
import dev.deadzone.core.model.game.data.GameResources
import dev.deadzone.core.model.game.data.Gender_Constants
import dev.deadzone.core.model.game.data.MissionData
import dev.deadzone.core.model.game.data.Survivor
import dev.deadzone.core.model.game.data.SurvivorAppearance
import dev.deadzone.core.model.game.data.SurvivorAppearance.Companion.toHumanAppearance
import dev.deadzone.core.model.game.data.SurvivorClassConstants_Constants
import dev.deadzone.core.model.game.data.SurvivorCollection
import dev.deadzone.core.model.game.data.SurvivorLoadoutEntry
import dev.deadzone.core.model.game.data.Task
import dev.deadzone.core.model.game.data.TaskCollection
import dev.deadzone.core.model.game.data.assignment.AssignmentData
import dev.deadzone.core.model.game.data.bounty.InfectedBounty
import dev.deadzone.core.model.game.data.effects.Effect
import dev.deadzone.core.model.game.data.quests.GQDataObj
import dev.deadzone.core.model.game.data.research.ResearchState
import dev.deadzone.core.model.game.data.skills.SkillState
import dev.deadzone.core.model.network.RemotePlayerData
import io.ktor.util.date.getTimeMillis
import kotlinx.serialization.Serializable
import java.util.UUID

/**
 * Also known as `PlayerData` in the client-side, it contains every game related data for a player.
 */
@Serializable
data class PlayerObjects(
    val playerId: String, // reference to UserDocument

    val key: String,                                  // unknown what key is used for
    val user: Map<String, AbstractUser> = emptyMap(), // unknown what user is used for
    val admin: Boolean,

    @Serializable(with = ByteArrayAsBinarySerializer::class)
    val flags: ByteArray = PlayerFlags.newgame(),     // deserialized to flagset (see PlayerFlags), indicates tutorial stuff
    val nickname: String?,
    val playerSurvivor: String?,
    val levelPts: UInt = 0u,
    val restXP: Int = 0,
    val oneTimePurchases: List<String> = emptyList(),
    val neighbors: Map<String, RemotePlayerData>?,
    val friends: Map<String, RemotePlayerData>?,
    val research: ResearchState?,
    val skills: Map<String, SkillState>?,

    // data like resources and survivors isn't needed here, they are set from loginstate.
    // but useful because client-side playerdata keeps them
    // and its better to store this in playerobjects than making separate loginstate collection
    val resources: GameResources,
    val survivors: List<Survivor>,
    val playerAttributes: Attributes,
    val buildings: List<BuildingLike>,
    val rally: Map<String, List<String>>?,  // key building id, value list of survivor ids
    val tasks: List<Task>,
    val missions: List<MissionData>?,
    val assignments: List<AssignmentData>?,
    val effects: List<ByteArray>?,       // can also be map<string, string>
    val globalEffects: List<ByteArray>?, // can also be map<string, string>
    val cooldowns: Map<String, ByteArray>?,
    val batchRecycles: List<BatchRecycleJob>?,
    val offenceLoadout: Map<String, SurvivorLoadoutEntry>?,
    val defenceLoadout: Map<String, SurvivorLoadoutEntry>?,
    val quests: ByteArray?,              // parsed by booleanArrayFromByteArray
    val questsCollected: ByteArray?,     // parsed by booleanArrayFromByteArray
    val achievements: ByteArray?,        // parsed by booleanArrayFromByteArray
    val dailyQuest: ByteArray?,          // parsed to DynamicQuest via constructor
    val questsTracked: String?,          // each quest separated with |
    val gQuestsV2: Map<String, GQDataObj>?,
    val bountyCap: Int,
    val lastLogout: Long?,
    val dzBounty: InfectedBounty?,
    val nextDZBountyIssue: Long,
    val highActivity: HighActivity?,  // unknown which class is this so we make custom class
    val notifications: List<Notification?>?,
) {
    companion object {
        fun admin(): PlayerObjects {
            val mockFlags = IntRange(0, 8).map { false }.toByteArray()

            return PlayerObjects(
                playerId = AdminData.PLAYER_ID,
                key = AdminData.PLAYER_DATA_KEY,
                admin = true,
                flags = PlayerFlags.skipTutorial(),
                nickname = AdminData.DISPLAY_NAME,
                playerSurvivor = AdminData.PLAYER_SRV_ID,
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
                survivors = SurvivorCollection.Companion.threeSurvivors(),
                playerAttributes = Attributes.Companion.dummy(),
                buildings = BuildingCollection.Companion.starterBase(),
                rally = mapOf(),
                tasks = TaskCollection().list,
                missions = listOf(MissionData.Companion.dummy(AdminData.PLAYER_SRV_ID)),
                assignments = null,
                effects = listOf(Effect.Companion.halloweenTrickPumpkinZombie(), Effect.Companion.halloweenTrickPewPew()),
                globalEffects = listOf(Effect.Companion.halloweenTrickPumpkinZombie(), Effect.Companion.halloweenTrickPewPew()),
                cooldowns = null,
                batchRecycles = null,
                offenceLoadout = mapOf(
                    AdminData.PLAYER_SRV_ID to SurvivorLoadoutEntry.Companion.playerLoudout(),
                    AdminData.FIGHTER_SRV_ID to SurvivorLoadoutEntry.Companion.fighterLoadout(),
                    AdminData.RECON_SRV_ID to SurvivorLoadoutEntry.Companion.reconLoadout(),
                ),
                defenceLoadout = mapOf(
                    AdminData.PLAYER_SRV_ID to SurvivorLoadoutEntry.Companion.playerLoudout(),
                    AdminData.FIGHTER_SRV_ID to SurvivorLoadoutEntry.Companion.fighterLoadout(),
                    AdminData.RECON_SRV_ID to SurvivorLoadoutEntry.Companion.reconLoadout(),
                ),
                quests = mockFlags,
                questsCollected = mockFlags,
                achievements = mockFlags,
                dailyQuest = null,
                questsTracked = null,
                gQuestsV2 = null,
                bountyCap = 0,
                lastLogout = getTimeMillis() - 100000,
                dzBounty = null,
                nextDZBountyIssue = 1230768000000,
                highActivity = null,
                notifications = null,
            )
        }

        fun newgame(pid: String, nickname: String, playerSrvId: String): PlayerObjects {
            val mockFlags = IntRange(0, 8).map { false }.toByteArray()
            val playerSrv = Survivor(
                id = playerSrvId,
                title = nickname,
                firstName = nickname,
                lastName = "",
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
                appearance = SurvivorAppearance.Companion.playerM().toHumanAppearance(),
                voice = "asian-m",
                accessories = emptyMap(),
                maxClothingAccessories = 4
            )

            return PlayerObjects(
                playerId = pid,
                key = pid,
                admin = false,
                flags = PlayerFlags.create(nicknameVerified = false),
                nickname = null,
                playerSurvivor = playerSrvId,
                neighbors = null,
                friends = null,
                research = ResearchState(active = emptyList(), levels = emptyMap()),
                skills = null,
                resources = GameResources(
                    cash = 100, wood = 300, metal = 300,
                    cloth = 300, food = 25, water = 25, ammunition = 150
                ),
                survivors = listOf(playerSrv),
                playerAttributes = Attributes.Companion.dummy(),
                buildings = BuildingCollection.Companion.starterBase(),
                rally = emptyMap(),
                tasks = TaskCollection().list,
                missions = listOf(MissionData.Companion.dummy(AdminData.PLAYER_SRV_ID)),
                assignments = null,
                effects = listOf(Effect.Companion.halloweenTrickPumpkinZombie(), Effect.Companion.halloweenTrickPewPew()),
                globalEffects = listOf(Effect.Companion.halloweenTrickPumpkinZombie(), Effect.Companion.halloweenTrickPewPew()),
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
                lastLogout = null,
                dzBounty = null,
                nextDZBountyIssue = 1765074185294,
                highActivity = null,
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
        if (lastLogout != other.lastLogout) return false
        if (nextDZBountyIssue != other.nextDZBountyIssue) return false
        if (key != other.key) return false
        if (user != other.user) return false
        if (!flags.contentEquals(other.flags)) return false
        if (nickname != other.nickname) return false
        if (playerSurvivor != other.playerSurvivor) return false
        if (levelPts != other.levelPts) return false
        if (oneTimePurchases != other.oneTimePurchases) return false
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
        if (dailyQuest != other.dailyQuest) return false
        if (questsTracked != other.questsTracked) return false
        if (gQuestsV2 != other.gQuestsV2) return false
        if (dzBounty != other.dzBounty) return false
        if (highActivity != other.highActivity) return false
        if (notifications != other.notifications) return false

        return true
    }

    override fun hashCode(): Int {
        var result = admin.hashCode()
        result = 31 * result + restXP
        result = 31 * result + bountyCap
        result = 31 * result + (lastLogout?.hashCode() ?: 0)
        result = 31 * result + nextDZBountyIssue.hashCode()
        result = 31 * result + key.hashCode()
        result = 31 * result + user.hashCode()
        result = 31 * result + (flags?.contentHashCode() ?: 0)
        result = 31 * result + nickname.hashCode()
        result = 31 * result + playerSurvivor.hashCode()
        result = 31 * result + levelPts.hashCode()
        result = 31 * result + oneTimePurchases.hashCode()
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
        result = 31 * result + (dzBounty?.hashCode() ?: 0)
        result = 31 * result + (highActivity?.hashCode() ?: 0)
        result = 31 * result + (notifications?.hashCode() ?: 0)
        return result
    }
}