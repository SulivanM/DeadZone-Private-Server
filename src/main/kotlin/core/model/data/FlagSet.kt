package dev.deadzone.core.model.data

import kotlinx.serialization.Serializable

/**
 * Bytearray of booleans
 *
 * Content of booleans depend on [PlayerFlags]
 */
@Serializable
data class FlagSet(
    val byteArray: ByteArray = byteArrayOf()
) {
    companion object {
        fun mockFlagSetByteArray(bitCount: Int = 256): ByteArray {
            val byteSize = (bitCount + 7) / 8 // round up
            val data = ByteArray(byteSize)

            // For example, just set first few flags
            for (i in 0 until byteSize) {
                data[i] = 0b00000001 // only first bit set
            }

            return data
        }
    }
}
