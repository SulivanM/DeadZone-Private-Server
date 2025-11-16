package api.message.db

import kotlinx.serialization.Serializable

@Serializable
data class CreateObjectsArgs(
    val objects: List<NewBigDBObject> = listOf(),
    val loadExisting: Boolean = false,
)
