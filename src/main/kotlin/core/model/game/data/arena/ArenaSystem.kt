package dev.deadzone.core.model.game.data.arena

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.CooldownCollection
import dev.deadzone.core.items.model.Item

@Serializable
data class ArenaSystem(
    val id: String,  // cased to ArenaSession, so must be one of the AssignmentType enum
    val srvcount: Int,
    val srvpoints: Int,
    val objpoints: Int,
    val completed: Boolean,
    val points: Int,
    val stage: Int,
    val returnsurvivors: List<String> = listOf(),  // survivor ids
    val cooldown: CooldownCollection = CooldownCollection(),
    val assignsuccess: Boolean,
    val items: List<Item> = listOf()
)
