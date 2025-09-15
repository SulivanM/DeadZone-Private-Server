package dev.deadzone.api.message.utils

import kotlinx.serialization.Serializable

@Serializable
data class WriteErrorError(
    val errorCode: Int = 0,
    val message: String = "",
) {
    companion object {
        fun dummy(): WriteErrorError {
            return WriteErrorError(
                errorCode = 42,
                message = "Write error, error"
            )
        }
    }
}
