package api.message.db

import kotlinx.serialization.Serializable

@Serializable
data class SaveObjectChangesOutput(
    val versions: List<String> = listOf(),
)
