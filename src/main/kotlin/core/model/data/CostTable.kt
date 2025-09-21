package core.model.data

import kotlinx.serialization.Serializable
import core.model.data.CostEntry

@Serializable
data class CostTable(
    val objectsByKey: Map<String, CostEntry> = mapOf(),
    val categories: Map<String, Map<String, CostEntry>> = mapOf()
)
