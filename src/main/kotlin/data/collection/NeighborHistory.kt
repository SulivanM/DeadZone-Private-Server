package data.collection

import core.model.network.RemotePlayerData
import kotlinx.serialization.Serializable

@Serializable
data class NeighborHistory(
    val playerId: String, 
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
