package core.model.data

import kotlinx.serialization.Serializable

@Serializable
data class FlagSet(
    val byteArray: ByteArray = byteArrayOf()
) {
    companion object {
        fun mockFlagSetByteArray(bitCount: Int = 256): ByteArray {
            val byteSize = (bitCount + 7) / 8 
            val data = ByteArray(byteSize)

            for (i in 0 until byteSize) {
                data[i] = 0b00000001 
            }

            return data
        }
    }
}
