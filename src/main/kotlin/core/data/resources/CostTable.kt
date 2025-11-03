package core.data.resources

import kotlinx.serialization.Serializable

@Serializable
data class SpeedUpConfig(
    val type: String = "",
    val order: Int = 0,
    val enabled: Boolean = true,
    val key: String = "",
    val time: Int? = null,
    val maxTime: Int? = null,
    val percent: Double? = null,
    val costPerMin: Double = 0.0,
    val minCost: Int = 0,
    val priceCoins: Int = 0
)

@Serializable
data class CostTable(
    val speedUpOneHour: SpeedUpConfig = SpeedUpConfig(),
    val speedUpTwoHour: SpeedUpConfig = SpeedUpConfig(),
    val speedUpHalf: SpeedUpConfig = SpeedUpConfig(),
    val speedUpComplete: SpeedUpConfig = SpeedUpConfig(),
    val speedUpFree: SpeedUpConfig = SpeedUpConfig()
) {
    fun getSpeedUpConfig(option: String): SpeedUpConfig? {
        return when (option) {
            "SpeedUpOneHour" -> speedUpOneHour
            "SpeedUpTwoHour" -> speedUpTwoHour
            "SpeedUpHalf" -> speedUpHalf
            "SpeedUpComplete" -> speedUpComplete
            "SpeedUpFree" -> speedUpFree
            else -> null
        }
    }
}
