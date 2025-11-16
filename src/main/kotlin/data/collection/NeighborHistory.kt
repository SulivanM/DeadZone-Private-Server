package data.collection

import core.model.network.RemotePlayerData
import kotlinx.serialization.Serializable

/**
 * Neighbor history table
 */
@Serializable
data class NeighborHistory(
    val playerId: String, // reference to UserDocument
    val map: Map<String, @Serializable RemotePlayerData>? = emptyMap()
) {
    companion object {
        fun empty(pid: String): NeighborHistory {
            return NeighborHistory(
                playerId = pid,
                map = emptyMap()
            )
        }
    }
}