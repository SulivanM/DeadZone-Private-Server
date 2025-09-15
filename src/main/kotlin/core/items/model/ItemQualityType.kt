package dev.deadzone.core.items.model

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class ItemQualityType(val value: Int) {
    companion object {
        fun fromString(s: String): Int? {
            return when (s) {
                "none" -> -2147483648
                "grey" -> -1
                "white" -> 0
                "green" -> 1
                "blue" -> 2
                "purple" -> 3
                "rare" -> 50
                "unique" -> 51
                "infamous" -> 52
                "premium" -> 100
                else -> null
            }
        }

        fun fromInt(i: Int): String? {
            return when (i) {
                -2147483648 -> "none"
                -1 -> "grey"
                0 -> "white"
                1 -> "green"
                2 -> "blue"
                3 -> "purple"
                50 -> "rare"
                51 -> "unique"
                52 -> "infamous"
                100 -> "premium"
                else -> null
            }
        }
    }
}

object ItemQualityType_Constants {
    val NONE = ItemQualityType(-2147483648)
    val GREY = ItemQualityType(-1)
    val WHITE = ItemQualityType(0)
    val GREEN = ItemQualityType(1)
    val BLUE = ItemQualityType(2)
    val PURPLE = ItemQualityType(3)
    val RARE = ItemQualityType(50)
    val UNIQUE = ItemQualityType(51)
    val INFAMOUS = ItemQualityType(52)
    val PREMIUM = ItemQualityType(100)
}
