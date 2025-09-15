package dev.deadzone.data.collection

import dev.deadzone.core.model.network.RemotePlayerData

/**
 * Neighbor history table
 */
data class NeighborHistory(
    val playerId: String, // reference to UserDocument
    val map: Map<String, RemotePlayerData>? = emptyMap()
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
