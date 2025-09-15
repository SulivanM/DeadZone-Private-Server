package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable
import dev.deadzone.data.collection.PlayerObjects

@Serializable
data class CompoundData(
    val player: PlayerObjects?,
    val buildings: BuildingCollection = BuildingCollection(),
    val resources: GameResources = GameResources(),
    val survivors: SurvivorCollection = SurvivorCollection(),
    val tasks: TaskCollection = TaskCollection(),
    val effects: EffectCollection = EffectCollection(),
    val globalEffects: EffectCollection = EffectCollection(),
    val morale: Morale = Morale(),
    val moraleFilter: List<String> = listOf("food", "water", "security", "comfort")
)
