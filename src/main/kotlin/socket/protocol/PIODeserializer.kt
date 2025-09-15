package dev.deadzone.socket.protocol

import dev.deadzone.utils.LogConfigSocketError
import dev.deadzone.utils.LogSource
import dev.deadzone.utils.Logger
import dev.deadzone.utils.parseJsonToMap
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder

object PIODeserializer {
    fun deserialize(data: ByteArray): List<Any> {
        var state = "init"
        var pattern = Pattern.DOES_NOT_EXIST
        val buffer = ByteArrayOutputStream()
        var partLength = 0
        var length = -1
        val message = mutableListOf<Any>()

        fun onValue(value: Any?) {
            if (length == -1 && value is Int) {
                length = value
            } else {
                message.add(value ?: "null")
            }
        }

        fun ByteArray.padStart(size: Int): ByteArray {
            return ByteArray(size - this.size) { 0 } + this
        }

        try {
            for (byte in data) {
                when (state) {
                    "init" -> {
                        pattern = Pattern.fromByte(byte.toInt() and 0xFF)
                        val part = byte.toInt() and 0x3F

                        when (pattern) {
                            Pattern.STRING_SHORT_PATTERN,
                            Pattern.BYTE_ARRAY_SHORT_PATTERN -> {
                                partLength = part
                                state = if (partLength > 0) "data" else {
                                    val value = if (pattern == Pattern.STRING_SHORT_PATTERN) "" else ByteArray(0)
                                    onValue(value)
                                    "init"
                                }
                            }

                            Pattern.STRING_PATTERN,
                            Pattern.BYTE_ARRAY_PATTERN,
                            Pattern.UNSIGNED_INT_PATTERN,
                            Pattern.INT_PATTERN -> {
                                partLength = 4
                                state = "header"
                            }

                            Pattern.UNSIGNED_INT_SHORT_PATTERN -> {
                                onValue(part)
                            }

                            Pattern.UNSIGNED_LONG_SHORT_PATTERN,
                            Pattern.LONG_SHORT_PATTERN -> {
                                partLength = 1
                                state = "data"
                            }

                            Pattern.UNSIGNED_LONG_PATTERN,
                            Pattern.LONG_PATTERN -> {
                                partLength = 6
                                state = "data"
                            }

                            Pattern.DOUBLE_PATTERN -> {
                                partLength = 8
                                state = "data"
                            }

                            Pattern.FLOAT_PATTERN -> {
                                partLength = 4
                                state = "data"
                            }

                            Pattern.BOOLEAN_TRUE_PATTERN -> onValue(true)
                            Pattern.BOOLEAN_FALSE_PATTERN -> onValue(false)
                            else -> {} // unsupported
                        }
                    }

                    "header" -> {
                        buffer.write(byte.toInt())
                        if (buffer.size() == partLength) {
                            val padded = buffer.toByteArray().padStart(4)
                            partLength = ByteBuffer.wrap(padded).order(ByteOrder.LITTLE_ENDIAN).int

                            if (partLength < 0 || partLength > 10_000_000) {
                                throw IllegalArgumentException("Invalid partLength = $partLength")
                            }

                            buffer.reset()
                            state = "data"
                        }
                    }

                    "data" -> {
                        buffer.write(byte.toInt())
                        if (buffer.size() == partLength) {
                            val bytes = buffer.toByteArray()
                            val padded = { b: ByteArray, size: Int -> b.padStart(size) }

                            val value = try {
                                when (pattern) {
                                    Pattern.STRING_SHORT_PATTERN,
                                    Pattern.STRING_PATTERN -> bytes.toString(Charsets.UTF_8)

                                    Pattern.UNSIGNED_INT_PATTERN,
                                    Pattern.INT_PATTERN -> ByteBuffer.wrap(padded(bytes, 4))
                                        .order(ByteOrder.BIG_ENDIAN).int

                                    Pattern.UNSIGNED_LONG_PATTERN,
                                    Pattern.UNSIGNED_LONG_SHORT_PATTERN,
                                    Pattern.LONG_PATTERN,
                                    Pattern.LONG_SHORT_PATTERN -> ByteBuffer.wrap(padded(bytes, 8))
                                        .order(ByteOrder.BIG_ENDIAN).long

                                    Pattern.DOUBLE_PATTERN -> ByteBuffer.wrap(padded(bytes, 8))
                                        .order(ByteOrder.BIG_ENDIAN).double

                                    Pattern.FLOAT_PATTERN -> ByteBuffer.wrap(padded(bytes, 4))
                                        .order(ByteOrder.BIG_ENDIAN).float

                                    Pattern.BYTE_ARRAY_SHORT_PATTERN,
                                    Pattern.BYTE_ARRAY_PATTERN -> bytes

                                    else -> null
                                }
                            } catch (e: Exception) {
                                Logger.error(LogConfigSocketError) { "Error deserializing pattern $pattern: ${e.message}" }
                                null
                            }

                            onValue(value)
                            buffer.reset()
                            state = "init"
                        }
                    }
                }
            }

            return message
        } catch (_: Exception) {
            Logger.info(LogSource.SOCKET) { "Deserializer receives JSON-like message" }
        }

        val offset = data.indexOfFirst { it == '{'.code.toByte() }

        return if (offset != -1) {
            try {
                val jsonBytes = data.copyOfRange(offset, data.size)
                val json = jsonBytes.toString(Charsets.UTF_8)
                val parsed = parseJsonToMap(json)
                val type = message.firstOrNull() as? String

                if (type != null) {
                    val isAlreadyWrapped = parsed.size == 1 && parsed.containsKey(type)

                    val final = if (isAlreadyWrapped) {
                        listOf(type, parsed[type]!!)
                    } else {
                        listOf(type, parsed)
                    }
                    final
                } else {
                    Logger.error(LogConfigSocketError) { "Cannot determine message type from partial data" }
                    emptyList()
                }
            } catch (e: Exception) {
                Logger.error(LogConfigSocketError) { "JSON fallback deserialization failed: ${e.message}" }
                emptyList()
            }
        } else {
            emptyList()
        }
    }
}
