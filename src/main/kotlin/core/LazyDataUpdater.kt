package dev.deadzone.core

import core.model.game.data.*
import dev.deadzone.core.model.game.data.*
import io.ktor.util.date.*
import kotlin.math.ceil
import kotlin.math.max
import kotlin.time.Duration.Companion.milliseconds

/**
 * Lazily update player's data based on timer or lastLogin
 */
object LazyDataUpdater {
    fun depleteResources(lastLogin: Long, res: GameResources): GameResources {
        val now = getTimeMillis()
        val minutesPassed = max(0, (now - lastLogin).milliseconds.inWholeMinutes)
        val depletionRate = 0.01
        // TO-DO depletion should be based on the number of survivors
        // depletion formula right now: each minutes deplete res by 0.01, an hour is 0.6, ceil the result

        val depleted = ceil(depletionRate * minutesPassed).toInt()
        return res.copy(
            food = max(1, res.food - depleted),
            water = max(1, res.water - depleted)
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
                        val level = bld.level + 1 // Increment the level by 1 when upgrade is done
                        bld.copy(level = level, upgrade = null)
                    }
                    repairDone -> bld.copy(repair = null)
                    else -> bld
                }
                is JunkBuilding -> when {
                    upgradeDone -> {
                        val level = bld.level + 1 // Increment the level by 1 when upgrade is done
                        bld.copy(level = level, upgrade = null)
                    }
                    repairDone -> bld.copy(repair = null)
                    else -> bld
                }
            }
        }
    }
}