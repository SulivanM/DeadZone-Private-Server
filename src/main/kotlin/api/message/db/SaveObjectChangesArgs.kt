package api.message.db

import kotlinx.serialization.Serializable

@Serializable
data class SaveObjectChangesArgs(
    val lockType: Int = 0,
    val changesets: List<BigDBChangeset> = listOf(),
    val createIfMissing: Boolean = false,
)
