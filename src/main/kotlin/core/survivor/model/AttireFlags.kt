package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class AttireFlags(val value: UInt)

object AttireFlags_Constants {
    val NONE = AttireFlags(0u)
    val NO_HAIR = AttireFlags(1u)
    val NO_FACIAL_HAIR = AttireFlags(2u)
    val MOUTH = AttireFlags(4u)
    val EYES = AttireFlags(8u)
    val HEAD = AttireFlags(16u)
    val BACK = AttireFlags(32u)
    val CHEST = AttireFlags(64u)
    val NECK = AttireFlags(128u)
    val WAIST_FRONT = AttireFlags(256u)
    val WAIST_BACK = AttireFlags(512u)
    val LEFT_SHOULDER = AttireFlags(1024u)
    val LEFT_UPPER_ARM = AttireFlags(2048u)
    val LEFT_LOWER_ARM = AttireFlags(4096u)
    val LEFT_UPPER_LEG = AttireFlags(8192u)
    val LEFT_LOWER_LEG = AttireFlags(16384u)
    val RIGHT_SHOULDER = AttireFlags(32768u)
    val RIGHT_UPPER_ARM = AttireFlags(65536u)
    val RIGHT_LOWER_ARM = AttireFlags(131072u)
    val RIGHT_UPPER_LEG = AttireFlags(262144u)
    val RIGHT_LOWER_LEG = AttireFlags(524288u)
    val UPPER_BODY = AttireFlags(1048576u)
    val LOWER_BODY = AttireFlags(2097152u)
    val ALL = AttireFlags(16777215u)
    val CLOTHING = AttireFlags(3145728u)
    val ACCESSORIES = AttireFlags(13631487u)
}
