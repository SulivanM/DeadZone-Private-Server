package core.game

import kotlin.math.ceil
import kotlin.math.max

object SpeedUpCostCalculator {
    fun calculateCost(option: String, secondsRemaining: Int): Int {
        return when (option) {
            "SpeedUpOneHour" -> {
                val costPerMin = 0.35
                val minCost = 25
                val timeInMinutes = secondsRemaining / 60.0
                max(minCost, ceil(costPerMin * timeInMinutes).toInt())
            }
            "SpeedUpTwoHour" -> {
                val costPerMin = 0.3
                val minCost = 40
                val timeInMinutes = secondsRemaining / 60.0
                max(minCost, ceil(costPerMin * timeInMinutes).toInt())
            }
            "SpeedUpHalf" -> {
                val costPerMin = 0.4
                val minCost = 60
                val timeInMinutes = (secondsRemaining * 0.5) / 60.0
                max(minCost, ceil(costPerMin * timeInMinutes).toInt())
            }
            "SpeedUpComplete" -> {
                val costPerMin = 0.5
                val minCost = 80
                val timeInMinutes = secondsRemaining / 60.0
                max(minCost, ceil(costPerMin * timeInMinutes).toInt())
            }
            "SpeedUpFree" -> {
                0
            }
            else -> {
                0
            }
        }
    }
}