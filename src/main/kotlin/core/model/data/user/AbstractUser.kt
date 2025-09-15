package dev.deadzone.core.model.data.user

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.data.Currency
import dev.deadzone.core.model.data.user.UserData

@Serializable
data class AbstractUser(
    val data: UserData,
    val email: String,
    val time: Long,
    val defaultCurrency: String // Currency constants
)
