package core.model.data

import kotlinx.serialization.Serializable

@Serializable
data class Notification(
    val type: String?,
    val data: String?,
)
