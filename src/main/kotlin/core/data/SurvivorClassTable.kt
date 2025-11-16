package core.data

import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put
import kotlinx.serialization.json.putJsonArray
import kotlinx.serialization.json.putJsonObject

/**
 * Survivor class table data.
 * Defines different survivor classes (fighter, medic, scavenger, engineer, recon, player, unassigned)
 * and their base attributes, level-based attribute growth, and weapon restrictions.
 */
object SurvivorClassTable {
    
    /**
     * Generate the survivor class table as a JSON string.
     * This replaces the srv_table.json file.
     */
    fun toJsonString(): String {
        val json = buildJsonObject {
            // Fighter class
            putJsonObject("fighter") {
                put("id", "fighter")
                put("maleUpper", "class_fighter")
                put("maleLower", "class_fighter")
                put("maleSkinOverlay", JsonNull)
                put("femaleUpper", "class_fighter")
                put("femaleLower", "class_fighter")
                put("femaleSkinOverlay", JsonNull)
                putJsonObject("baseAttributes") {
                    put("health", 1.0)
                    put("combatProjectile", 1.0)
                    put("combatMelee", 1.0)
                    put("combatImprovised", 1.0)
                    put("movement", 1.0)
                    put("scavenge", 1.0)
                    put("healing", 0.0)
                    put("trapSpotting", 0.0)
                    put("trapDisarming", 0.0)
                }
                putJsonObject("levelAttributes") {
                    put("health", 0.1)
                    put("combatProjectile", 0.05)
                    put("combatMelee", 0.05)
                    put("combatImprovised", 0.05)
                    put("movement", 0.03)
                    put("scavenge", 0.03)
                    put("healing", 0.02)
                    put("trapSpotting", 0.01)
                    put("trapDisarming", 0.01)
                }
                putJsonObject("weapons") {
                    putJsonArray("classes") {
                        add(JsonPrimitive("assault_rifle"))
                        add(JsonPrimitive("lmg"))
                        add(JsonPrimitive("melee"))
                        add(JsonPrimitive("heavy"))
                    }
                    putJsonArray("types") {}
                }
                put("hideHair", false)
            }
            
            // Medic class
            putJsonObject("medic") {
                put("id", "medic")
                put("maleUpper", "class_medic")
                put("maleLower", "class_medic")
                put("maleSkinOverlay", JsonNull)
                put("femaleUpper", "class_medic")
                put("femaleLower", "class_medic")
                put("femaleSkinOverlay", JsonNull)
                putJsonObject("baseAttributes") {
                    put("health", 1.0)
                    put("combatProjectile", 0.6)
                    put("combatMelee", 0.7)
                    put("combatImprovised", 0.5)
                    put("movement", 1.1)
                    put("scavenge", 0.9)
                    put("healing", 1.5)
                    put("trapSpotting", 0.5)
                    put("trapDisarming", 0.5)
                }
                putJsonObject("levelAttributes") {
                    put("health", 0.1)
                    put("combatProjectile", 0.05)
                    put("combatMelee", 0.05)
                    put("combatImprovised", 0.05)
                    put("movement", 0.03)
                    put("scavenge", 0.03)
                    put("healing", 0.02)
                    put("trapSpotting", 0.01)
                    put("trapDisarming", 0.01)
                }
                putJsonObject("weapons") {
                    putJsonArray("classes") {
                        add(JsonPrimitive("pistol"))
                        add(JsonPrimitive("smg"))
                    }
                    putJsonArray("types") {
                        add(JsonPrimitive("BLADE"))
                    }
                }
                put("hideHair", false)
            }
            
            // Scavenger class
            putJsonObject("scavenger") {
                put("id", "scavenger")
                put("maleUpper", "class_scavenger")
                put("maleLower", "class_scavenger")
                put("maleSkinOverlay", JsonNull)
                put("femaleUpper", "class_scavenger")
                put("femaleLower", "class_scavenger")
                put("femaleSkinOverlay", JsonNull)
                putJsonObject("baseAttributes") {
                    put("health", 0.9)
                    put("combatProjectile", 0.5)
                    put("combatMelee", 0.6)
                    put("combatImprovised", 0.7)
                    put("movement", 1.4)
                    put("scavenge", 1.6)
                    put("healing", 0.3)
                    put("trapSpotting", 0.8)
                    put("trapDisarming", 0.5)
                }
                putJsonObject("levelAttributes") {
                    put("health", 0.1)
                    put("combatProjectile", 0.05)
                    put("combatMelee", 0.05)
                    put("combatImprovised", 0.05)
                    put("movement", 0.03)
                    put("scavenge", 0.03)
                    put("healing", 0.02)
                    put("trapSpotting", 0.01)
                    put("trapDisarming", 0.01)
                }
                putJsonObject("weapons") {
                    putJsonArray("classes") {
                        add(JsonPrimitive("pistol"))
                        add(JsonPrimitive("shotgun"))
                        add(JsonPrimitive("bow"))
                    }
                    putJsonArray("types") {
                        add(JsonPrimitive("BLUNT"))
                    }
                }
                put("hideHair", false)
            }
            
            // Engineer class
            putJsonObject("engineer") {
                put("id", "engineer")
                put("maleUpper", "class_engineer")
                put("maleLower", "class_engineer")
                put("maleSkinOverlay", JsonNull)
                put("femaleUpper", "class_engineer")
                put("femaleLower", "class_engineer")
                put("femaleSkinOverlay", JsonNull)
                putJsonObject("baseAttributes") {
                    put("health", 1.0)
                    put("combatProjectile", 0.6)
                    put("combatMelee", 0.5)
                    put("combatImprovised", 0.9)
                    put("movement", 1.0)
                    put("scavenge", 1.0)
                    put("healing", 0.2)
                    put("trapSpotting", 1.2)
                    put("trapDisarming", 1.5)
                }
                putJsonObject("levelAttributes") {
                    put("health", 0.1)
                    put("combatProjectile", 0.05)
                    put("combatMelee", 0.05)
                    put("combatImprovised", 0.05)
                    put("movement", 0.03)
                    put("scavenge", 0.03)
                    put("healing", 0.02)
                    put("trapSpotting", 0.01)
                    put("trapDisarming", 0.01)
                }
                putJsonObject("weapons") {
                    putJsonArray("classes") {}
                    putJsonArray("types") {
                        add(JsonPrimitive("IMPROVISED"))
                    }
                }
                put("hideHair", false)
            }
            
            // Recon class
            putJsonObject("recon") {
                put("id", "recon")
                put("maleUpper", "class_recon")
                put("maleLower", "class_recon")
                put("maleSkinOverlay", JsonNull)
                put("femaleUpper", "class_recon")
                put("femaleLower", "class_recon")
                put("femaleSkinOverlay", JsonNull)
                putJsonObject("baseAttributes") {
                    put("health", 1.0)
                    put("combatProjectile", 1.4)
                    put("combatMelee", 0.7)
                    put("combatImprovised", 0.6)
                    put("movement", 1.5)
                    put("scavenge", 1.2)
                    put("healing", 0.1)
                    put("trapSpotting", 1.0)
                    put("trapDisarming", 0.8)
                }
                putJsonObject("levelAttributes") {
                    put("health", 0.1)
                    put("combatProjectile", 0.05)
                    put("combatMelee", 0.05)
                    put("combatImprovised", 0.05)
                    put("movement", 0.03)
                    put("scavenge", 0.03)
                    put("healing", 0.02)
                    put("trapSpotting", 0.01)
                    put("trapDisarming", 0.01)
                }
                putJsonObject("weapons") {
                    putJsonArray("classes") {
                        add(JsonPrimitive("assault_rifle"))
                        add(JsonPrimitive("long_rifle"))
                    }
                    putJsonArray("types") {
                        add(JsonPrimitive("BLADE"))
                    }
                }
                put("hideHair", true)
            }
            
            // Player class
            putJsonObject("player") {
                put("id", "player")
                put("maleUpper", "body-upper-tshirtm")
                put("maleLower", "body-lower-pantsm")
                put("maleSkinOverlay", JsonNull)
                put("femaleUpper", "body-upper-tshirtf")
                put("femaleLower", "body-lower-skirtf")
                put("femaleSkinOverlay", JsonNull)
                putJsonObject("baseAttributes") {
                    put("health", 1.0)
                    put("combatProjectile", 1.0)
                    put("combatMelee", 1.0)
                    put("combatImprovised", 1.0)
                    put("movement", 1.0)
                    put("scavenge", 1.0)
                    put("healing", 1.0)
                    put("trapSpotting", 1.0)
                    put("trapDisarming", 1.0)
                }
                putJsonObject("levelAttributes") {
                    put("health", 0.1)
                    put("combatProjectile", 0.05)
                    put("combatMelee", 0.05)
                    put("combatImprovised", 0.05)
                    put("movement", 0.03)
                    put("scavenge", 0.03)
                    put("healing", 0.02)
                    put("trapSpotting", 0.01)
                    put("trapDisarming", 0.01)
                }
                putJsonObject("weapons") {
                    putJsonArray("classes") {
                        add(JsonPrimitive("assault_rifle"))
                        add(JsonPrimitive("bow"))
                        add(JsonPrimitive("launcher"))
                        add(JsonPrimitive("long_rifle"))
                        add(JsonPrimitive("melee"))
                        add(JsonPrimitive("pistol"))
                        add(JsonPrimitive("shotgun"))
                        add(JsonPrimitive("smg"))
                        add(JsonPrimitive("lmg"))
                        add(JsonPrimitive("thrown"))
                        add(JsonPrimitive("heavy"))
                    }
                    putJsonArray("types") {}
                }
                put("hideHair", false)
            }
            
            // Unassigned class
            putJsonObject("unassigned") {
                put("id", "unassigned")
                put("maleUpper", "body-upper-tshirtm")
                put("maleLower", "body-lower-pantsm")
                put("maleSkinOverlay", JsonNull)
                put("femaleUpper", "body-upper-tshirtf")
                put("femaleLower", "body-lower-skirtf")
                put("femaleSkinOverlay", JsonNull)
                putJsonObject("baseAttributes") {
                    put("health", 0.0)
                    put("combatProjectile", 0.0)
                    put("combatMelee", 0.0)
                    put("combatImprovised", 0.0)
                    put("movement", 0.0)
                    put("scavenge", 0.0)
                    put("healing", 0.0)
                    put("trapSpotting", 0.0)
                    put("trapDisarming", 0.0)
                }
                putJsonObject("levelAttributes") {
                    put("health", 0.1)
                    put("combatProjectile", 0.05)
                    put("combatMelee", 0.05)
                    put("combatImprovised", 0.05)
                    put("movement", 0.03)
                    put("scavenge", 0.03)
                    put("healing", 0.02)
                    put("trapSpotting", 0.01)
                    put("trapDisarming", 0.01)
                }
                putJsonObject("weapons") {
                    putJsonArray("classes") {
                        add(JsonPrimitive("rifle"))
                        add(JsonPrimitive("melee"))
                    }
                    putJsonArray("types") {
                        add(JsonPrimitive("primary"))
                        add(JsonPrimitive("secondary"))
                    }
                }
                put("hideHair", false)
            }
        }
        
        return json.toString()
    }
}
