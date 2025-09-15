package dev.deadzone.core.model.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class NavigationLocation(val value: String)

object NavigationLocation_Constants {
    val PLAYER_COMPOUND = NavigationLocation("playerCompound")
    val NEIGHBOR_COMPOUND = NavigationLocation("neighborCompound")
    val MISSION = NavigationLocation("mission")
    val MISSION_PLANNING = NavigationLocation("missionPlanning")
    val WORLD_MAP = NavigationLocation("worldmap")
}
