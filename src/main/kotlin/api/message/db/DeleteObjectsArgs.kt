package api.message.db

import kotlinx.serialization.Serializable

@Serializable
data class DeleteObjectsArgs(
    val objectIds: List<BigDBObjectId> = listOf(),
)
