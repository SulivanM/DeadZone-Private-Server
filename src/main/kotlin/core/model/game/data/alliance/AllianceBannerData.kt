package dev.deadzone.core.model.game.data.alliance

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class AllianceBannerData(val value: Int)

object AllianceBannerData_Constants {
    val BASE_COLOR = AllianceBannerData(0)
    val DECAL_1 = AllianceBannerData(1)
    val DECAL_1_COLOR = AllianceBannerData(2)
    val DECAL_2 = AllianceBannerData(3)
    val DECAL_2_COLOR = AllianceBannerData(4)
    val DECAL_3 = AllianceBannerData(5)
    val DECAL_3_COLOR = AllianceBannerData(6)
}
