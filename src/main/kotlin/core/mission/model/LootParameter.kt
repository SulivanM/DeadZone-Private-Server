package dev.deadzone.core.mission.model

// Loot system config, contains variables that affects loot
data class LootParameter(
    val areaLevel: Int,
    val playerLevel: Int, // not used yet
    val itemWeightOverrides: Map<String, Double> = emptyMap(), // absolute override if needed
    val specificItemBoost: Map<String, Double> = emptyMap(),   // e.g. "fuel" to 0.2 (+20%)
    val itemTypeBoost: Map<String, Double> = emptyMap(),       // e.g. "weapon" to 0.1 (+10%)
    val itemQualityBoost: Map<String, Double> = emptyMap(),    // e.g. "blue" to -0.4 (-40%)
    val baseWeight: Double = 1.0,
    val fuelLimit: Int = 0 // not used yet
)
