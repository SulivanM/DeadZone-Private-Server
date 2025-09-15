package dev.deadzone.api.message.utils

import kotlinx.serialization.Serializable

@Serializable
data class TypicalPIOError(
    val message: String = "",
    val errorCode: Int = 0,
) {
    companion object {
        fun dummy(): TypicalPIOError {
            return TypicalPIOError(
                message = "A generic error example",
                errorCode = 42,
            )
        }
    }
}
