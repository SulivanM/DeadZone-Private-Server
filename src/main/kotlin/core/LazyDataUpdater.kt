package dev.deadzone.core

import dev.deadzone.core.model.game.data.*
import io.ktor.util.date.*
import kotlin.math.min
import kotlin.time.Duration.Companion.milliseconds

/**
 * Lazily update player's data based on timer or lastLogin
 */
object LazyDataUpdater {
    fun depleteResources(lastLogin: Long, res: GameResources): GameResources {
        val minutesPassed = min(0, (getTimeMillis() - lastLogin).milliseconds.inWholeMinutes)
        val depletionRate = 0.02
        // depletion formula: each minutes deplete res by 0.05, an hour is 3

        val depleted = depletionRate * minutesPassed

        return res.copy(
            food = min(1, res.food - (depleted).toInt()),
            water = min(1, res.water - (depleted).toInt())
        )
    }

    @Suppress("CAST_NEVER_SUCCEEDS")
    fun updateBuildingTimers(buildings: List<BuildingLike>): List<BuildingLike> {
        return buildings.map { bld ->
            val upgradeDone = bld.upgrade?.hasEnded() ?: false
            val repairDone = bld.repair?.hasEnded() ?: false

            when (bld) {
                is Building -> when {
                    upgradeDone -> {
                        val level = (bld.upgrade?.data?.get("level") as? Int ?: 1)
                        bld.copy(level = level.toInt(), upgrade = null)
                    }
                    repairDone -> bld.copy(repair = null)
                    else -> bld
                }
                is JunkBuilding -> when {
                    upgradeDone -> {
                        val level = (bld.upgrade?.data?.get("level") as? Int ?: 1)
                        bld.copy(level = level.toInt(), upgrade = null)
                    }
                    repairDone -> bld.copy(repair = null)
                    else -> bld
                }
            }
        }
    }
}
