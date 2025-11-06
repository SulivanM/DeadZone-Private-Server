package utils

import core.data.GameDefinition
import kotlin.math.ceil
import kotlin.math.max

object SpeedUpCostCalculator {
    fun calculateCost(option: String, secondsRemaining: Int): Int {
        val speedUpConfig = GameDefinition.costTable.getSpeedUpConfig(option)
            ?: return 0

        if (!speedUpConfig.enabled) {
            return 0
        }

        return when (option) {
            "SpeedUpFree" -> 0
            "SpeedUpHalf" -> {
                val timeInMinutes = (secondsRemaining * (speedUpConfig.percent ?: 0.5)) / 60.0
                max(speedUpConfig.minCost, ceil(speedUpConfig.costPerMin * timeInMinutes).toInt())
            }
            else -> {
                val timeInMinutes = secondsRemaining / 60.0
                max(speedUpConfig.minCost, ceil(speedUpConfig.costPerMin * timeInMinutes).toInt())
            }
        }
    }
}