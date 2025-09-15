package dev.deadzone.socket.protocol

internal enum class Pattern(val value: Int) {
    STRING_SHORT_PATTERN(0xC0),
    STRING_PATTERN(0x0C),
    BYTE_ARRAY_SHORT_PATTERN(0x40),
    BYTE_ARRAY_PATTERN(0x10),
    UNSIGNED_LONG_SHORT_PATTERN(0x38),
    UNSIGNED_LONG_PATTERN(0x3C),
    LONG_SHORT_PATTERN(0x30),
    LONG_PATTERN(0x34),
    UNSIGNED_INT_SHORT_PATTERN(0x80),
    UNSIGNED_INT_PATTERN(0x08),
    INT_PATTERN(0x04),
    DOUBLE_PATTERN(0x03),
    FLOAT_PATTERN(0x02),
    BOOLEAN_TRUE_PATTERN(0x01),
    BOOLEAN_FALSE_PATTERN(0x00),
    DOES_NOT_EXIST(0xFF);

    companion object {
        fun fromByte(byte: Int): Pattern {
            return entries.toTypedArray().sortedByDescending { it.value }.firstOrNull {
                byte and it.value == it.value
            } ?: DOES_NOT_EXIST
        }
    }
}
