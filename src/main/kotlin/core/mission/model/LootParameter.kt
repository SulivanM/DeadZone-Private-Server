package core.mission.model

data class LootParameter(
    val areaLevel: Int,
    val playerLevel: Int, 
    val itemWeightOverrides: Map<String, Double> = emptyMap(), 
    val specificItemBoost: Map<String, Double> = emptyMap(),   
    val itemTypeBoost: Map<String, Double> = emptyMap(),       
    val itemQualityBoost: Map<String, Double> = emptyMap(),    
    val baseWeight: Double = 1.0,
    val fuelLimit: Int = 0 
)
