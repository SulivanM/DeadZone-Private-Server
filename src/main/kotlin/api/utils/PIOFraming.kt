package dev.deadzone.api.utils

/**
 * Adds a PlayerIO framing prefix to the byte array.
 *
 * This is required by the PlayerIO API message convention, which expects each request and response
 * to be prefixed with two specific bytes: `0x00` and `0x01`.
 *
 * @receiver The original unframed [ByteArray] representing a protocol buffer message.
 * @return A new [ByteArray] with `0x00` and `0x01` prepended.
 */
fun ByteArray.pioFraming(): ByteArray {
    return byteArrayOf(0, 1) + this
}
