package api.message.db

import kotlinx.serialization.Serializable

@Serializable
data class DeleteObjectsOutput(
    val success: Boolean = true,
)
