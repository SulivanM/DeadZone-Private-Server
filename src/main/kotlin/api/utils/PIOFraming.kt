package api.utils

fun ByteArray.pioFraming(): ByteArray {
    return byteArrayOf(0, 1) + this
}
