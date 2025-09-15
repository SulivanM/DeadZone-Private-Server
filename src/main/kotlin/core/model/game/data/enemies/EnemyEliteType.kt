package dev.deadzone.core.model.game.data.enemies

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class EnemyEliteType(val value: UInt)

object EnemyEliteType_Constants {
    val NONE = EnemyEliteType(0u)
    val RARE = EnemyEliteType(1u)
    val UNIQUE = EnemyEliteType(2u)
}
