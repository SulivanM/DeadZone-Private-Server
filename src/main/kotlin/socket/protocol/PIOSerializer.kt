package dev.deadzone.socket.protocol

import java.nio.ByteBuffer
import java.nio.ByteOrder

object PIOSerializer {
    fun serialize(message: List<Any>): ByteArray {
        val buffer = mutableListOf<Byte>()

        fun reverseBytes(bytes: ByteArray): ByteArray = bytes.reversedArray()

        fun writeTagWithLength(length: Int, shortPattern: Pattern, fullPattern: Pattern) {
            if (length in 0..63) {
                buffer.add((shortPattern.value or length).toByte())
            } else {
                val encoded = reverseBytes(ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(length).array())
                val nonZero = encoded.indexOfFirst { it != 0.toByte() }.takeIf { it >= 0 } ?: 3
                val used = 4 - nonZero
                buffer.add((fullPattern.value or (used - 1)).toByte())
                buffer.addAll(encoded.drop(nonZero))
            }
        }

        fun writeLongPattern(value: Long, shortPattern: Pattern, longPattern: Pattern) {
            val encoded = reverseBytes(ByteBuffer.allocate(8).order(ByteOrder.LITTLE_ENDIAN).putLong(value).array())
            val nonZero = encoded.indexOfFirst { it != 0.toByte() }.takeIf { it >= 0 } ?: 7
            val used = 8 - nonZero
            val pattern = if (used > 4) longPattern else shortPattern
            val offset = if (used > 4) used - 5 else used - 1
            buffer.add((pattern.value or offset).toByte())
            buffer.addAll(encoded.drop(nonZero))
        }

        fun serializeValue(value: Any) {
            when (value) {
                is String -> {
                    val encoded = value.toByteArray(Charsets.UTF_8)
                    writeTagWithLength(encoded.size, Pattern.STRING_SHORT_PATTERN, Pattern.STRING_PATTERN)
                    buffer.addAll(encoded.toList())
                }

                is Boolean -> {
                    buffer.add(if (value) Pattern.BOOLEAN_TRUE_PATTERN.value.toByte() else Pattern.BOOLEAN_FALSE_PATTERN.value.toByte())
                }

                is Int -> {
                    writeTagWithLength(value, Pattern.UNSIGNED_INT_SHORT_PATTERN, Pattern.INT_PATTERN)
                }

                is Long -> {
                    writeLongPattern(value, Pattern.LONG_SHORT_PATTERN, Pattern.LONG_PATTERN)
                }

                is Float -> {
                    buffer.add(Pattern.DOUBLE_PATTERN.value.toByte())
                    buffer.addAll(
                        reverseBytes(
                            ByteBuffer.allocate(8).order(ByteOrder.LITTLE_ENDIAN).putDouble(value.toDouble()).array()
                        ).toList()
                    )
                }

                is Double -> {
                    buffer.add(Pattern.DOUBLE_PATTERN.value.toByte())
                    buffer.addAll(
                        reverseBytes(
                            ByteBuffer.allocate(8).order(ByteOrder.LITTLE_ENDIAN).putDouble(value).array()
                        ).toList()
                    )
                }

                is ByteArray -> {
                    writeTagWithLength(value.size, Pattern.BYTE_ARRAY_SHORT_PATTERN, Pattern.BYTE_ARRAY_PATTERN)
                    buffer.addAll(value.toList())
                }

                else -> throw IllegalArgumentException("Unsupported type: ${value::class}")
            }
        }

        serializeValue(message.size - 1)
        for (value in message) {
            serializeValue(value)
        }

        return buffer.toByteArray()
    }
}
