package dev.deadzone.core.model.data

import kotlinx.serialization.Serializable

@Serializable
data class Notification(
    val type: String?, // notification: type
    val data: String?,
)
