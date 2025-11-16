package api.message.db

import kotlinx.serialization.Serializable

@Serializable
data class CreateObjectsOutput(
    val objects: List<BigDBObject> = listOf(),
)
