import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class QuestSecret(val value: UInt)

@Serializable
@JvmInline
value class QuestType(val value: String)

@Serializable
@JvmInline
value class QuestTracking(val value: String)

object QuestConstants {
    val SECRET_NONE = QuestSecret(0u)
    val SECRET_TITLE_ONLY = QuestSecret(1u)
    val SECRET_HIDDEN = QuestSecret(2u)

    val TYPE_ACHIEVEMENT = QuestType("achievement")
    val TYPE_GENERAL = QuestType("general")
    val TYPE_COMBAT = QuestType("combat")
    val TYPE_SCAVENGE = QuestType("scavenge")
    val TYPE_CONSTRUCTION = QuestType("construct")
    val TYPE_COMMUNITY = QuestType("community")
    val TYPE_WORLD = QuestType("world")
    val TYPE_DYNAMIC = QuestType("dynamic")

    val TRACKING_TRACKED = QuestTracking("tracked")
    val TRACKING_UNTRACKED = QuestTracking("untracked")
    val TRACKING_MAX_TRACKED = QuestTracking("maxTracked")
}
