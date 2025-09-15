package dev.deadzone.core.model.game.data.alliance

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class AllianceRankConstants(val value: UInt)

object AllianceRankConstants_Constants {
    val RANK_1 = AllianceRankConstants(1u)
    val RANK_2 = AllianceRankConstants(2u)
    val RANK_3 = AllianceRankConstants(3u)
    val RANK_4 = AllianceRankConstants(4u)
    val RANK_5 = AllianceRankConstants(5u)
    val RANK_6 = AllianceRankConstants(6u)
    val RANK_7 = AllianceRankConstants(7u)
    val RANK_8 = AllianceRankConstants(8u)
    val RANK_9 = AllianceRankConstants(9u)
    val RANK_10 = AllianceRankConstants(10u)
    val FOUNDER = AllianceRankConstants(10u)
    val TWO_IC = AllianceRankConstants(9u)
}
