package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
data class WeaponData(
    val minRange: Double = 0.0,
    val minEffectiveRange: Double = 0.0,
    val range: Double = 0.0,
    val minRangeMod: Double = 0.0,
    val maxRangeMod: Double = 0.0,
    val burstAvg: Int = 0,
    val roundsInMagazine: Int = 0,
    val ammoCost: Double = 0.0,
    val damageMax: Double = 0.0,
    val damageMin: Double = 0.0,
    val damageMult: Double = 1.0,
    val damageMultVsBuilding: Double = 1.0,
    val accuracy: Double = 0.0,
    val capacity: Int = 0,
    val reloadTime: Double = 0.0,
    val fireRate: Double = 0.0,
    val noise: Double = 0.0,
    val idleNoise: Double = 0.0,
    val criticalChance: Double = 0.0,
    val knockbackChance: Double = 0.0,
    val dodgeChance: Double = 0.0,
    val isMelee: Boolean = false,
    val isExplosive: Boolean = false,
    val attackArcCosine: Double = 0.0,
    val suppressionRate: Double = 0.0,
    val goreMultiplier: Double = 1.0,
    val readyTime: Double = 0.0
)
