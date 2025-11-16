package core.data

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.add
import kotlinx.serialization.json.addJsonObject
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put
import kotlinx.serialization.json.putJsonArray
import kotlinx.serialization.json.putJsonObject

/**
 * Cost table data for game operations.
 * Provides pricing and cost information for various in-game actions.
 */
object CostTable {
    
    /**
     * Generate the cost table as a JSON string.
     * This replaces the cost_table.json file.
     */
    fun toJsonString(): String {
        val json = buildJsonObject {
            // Empty cost entries for operations that don't need pricing
            putJsonObject("BatchDisposal") {}
            putJsonObject("BatchRecycle") {}
            putJsonObject("constructionCosts") {
                put("coinsPerResUnit", 1.0)
                put("coinsPerSecond", 0.5)
            }
            putJsonObject("CraftUpgradeItem") {}
            putJsonObject("CraftItem") {}
            putJsonObject("SurvivorReassign") {}
            
            // Dynamic arena launch costs (placeholders)
            putJsonObject("ArenaLaunch_<name>") {
                put("TODO", "this is dynamic data")
            }
            putJsonObject("ArenaLaunch_stadium") {
                put("TODO", "this is dynamic data")
            }
            
            // Other empty cost entries
            putJsonObject("ResearchTask") {}
            putJsonObject("AllianceCreation") {}
            putJsonObject("SpeedUpInfectedBounty") {}
            putJsonObject("AllianceBannerEdit") {}
            
            // Buy coins/fuel options for different services
            // Facebook service
            putJsonObject("buy_coins_fb_small") {
                put("type", "buy_coins_fb")
                put("order", 1)
                put("key", "buy_coins_fb_small")
                put("fuel", 100)
                put("image", "images/items/fuel-bottle.jpg")
                put("PriceUSD", 99)
                put("PriceEUR", 99)
                put("PriceGBP", 79)
                put("PriceFBC", 1.0)
            }
            putJsonObject("buy_coins_fb_medium") {
                put("type", "buy_coins_fb")
                put("order", 2)
                put("key", "buy_coins_fb_medium")
                put("fuel", 250)
                put("image", "images/items/fuel-drop.jpg")
                put("PriceUSD", 199)
                put("PriceEUR", 199)
                put("PriceGBP", 149)
                put("PriceFBC", 2.0)
            }
            putJsonObject("buy_coins_fb_large") {
                put("type", "buy_coins_fb")
                put("order", 3)
                put("key", "buy_coins_fb_large")
                put("fuel", 600)
                put("image", "images/items/fuel-cans.jpg")
                put("PriceUSD", 499)
                put("PriceEUR", 499)
                put("PriceGBP", 399)
                put("PriceFBC", 5.0)
            }
            putJsonObject("buy_coins_fb_xlarge") {
                put("type", "buy_coins_fb")
                put("order", 4)
                put("key", "buy_coins_fb_xlarge")
                put("fuel", 1500)
                put("image", "images/items/fuel-container.jpg")
                put("PriceUSD", 999)
                put("PriceEUR", 999)
                put("PriceGBP", 799)
                put("PriceFBC", 10.0)
                putJsonArray("items") {
                    addJsonObject {
                        put("type", "food")
                        put("qty", 50)
                    }
                    addJsonObject {
                        put("type", "water")
                        put("qty", 50)
                    }
                    addJsonObject {
                        put("type", "cash")
                        put("qty", 100)
                    }
                }
            }
            
            // Kongregate service
            putJsonObject("buy_coins_kong_small") {
                put("type", "buy_coins_kong")
                put("order", 1)
                put("key", "buy_coins_kong_small")
                put("fuel", 100)
                put("image", "images/items/fuel-bottle.jpg")
                put("PriceKKR", 10)
            }
            putJsonObject("buy_coins_kong_medium") {
                put("type", "buy_coins_kong")
                put("order", 2)
                put("key", "buy_coins_kong_medium")
                put("fuel", 250)
                put("image", "images/items/fuel-drop.jpg")
                put("PriceKKR", 20)
            }
            putJsonObject("buy_coins_kong_large") {
                put("type", "buy_coins_kong")
                put("order", 3)
                put("key", "buy_coins_kong_large")
                put("fuel", 600)
                put("image", "images/items/fuel-cans.jpg")
                put("PriceKKR", 50)
            }
            putJsonObject("buy_coins_kong_xlarge") {
                put("type", "buy_coins_kong")
                put("order", 4)
                put("key", "buy_coins_kong_xlarge")
                put("fuel", 1500)
                put("image", "images/items/fuel-container.jpg")
                put("PriceKKR", 100)
                putJsonArray("items") {
                    addJsonObject {
                        put("type", "food")
                        put("qty", 50)
                    }
                    addJsonObject {
                        put("type", "water")
                        put("qty", 50)
                    }
                    addJsonObject {
                        put("type", "cash")
                        put("qty", 100)
                    }
                }
            }
            
            // PlayerIO service
            putJsonObject("buy_coins_pio_small") {
                put("type", "buy_coins_pio")
                put("order", 1)
                put("key", "buy_coins_pio_small")
                put("fuel", 100)
                put("image", "images/items/fuel-bottle.jpg")
                put("PriceUSD", 99)
                put("PriceEUR", 99)
                put("PriceGBP", 79)
            }
            putJsonObject("buy_coins_pio_medium") {
                put("type", "buy_coins_pio")
                put("order", 2)
                put("key", "buy_coins_pio_medium")
                put("fuel", 250)
                put("image", "images/items/fuel-drop.jpg")
                put("PriceUSD", 199)
                put("PriceEUR", 199)
                put("PriceGBP", 149)
            }
            putJsonObject("buy_coins_pio_large") {
                put("type", "buy_coins_pio")
                put("order", 3)
                put("key", "buy_coins_pio_large")
                put("fuel", 600)
                put("image", "images/items/fuel-cans.jpg")
                put("PriceUSD", 499)
                put("PriceEUR", 499)
                put("PriceGBP", 399)
            }
            putJsonObject("buy_coins_pio_xlarge") {
                put("type", "buy_coins_pio")
                put("order", 4)
                put("key", "buy_coins_pio_xlarge")
                put("fuel", 1500)
                put("image", "images/items/fuel-container.jpg")
                put("PriceUSD", 999)
                put("PriceEUR", 999)
                put("PriceGBP", 799)
                putJsonArray("items") {
                    addJsonObject {
                        put("type", "food")
                        put("qty", 50)
                    }
                    addJsonObject {
                        put("type", "water")
                        put("qty", 50)
                    }
                    addJsonObject {
                        put("type", "cash")
                        put("qty", 100)
                    }
                }
            }
            
            // Armor Games service
            putJsonObject("buy_coins_armor_small") {
                put("type", "buy_coins_armor")
                put("order", 1)
                put("key", "buy_coins_armor_small")
                put("fuel", 100)
                put("image", "images/items/fuel-bottle.jpg")
                put("PriceUSD", 99)
                put("PriceEUR", 99)
                put("PriceGBP", 79)
            }
            putJsonObject("buy_coins_armor_medium") {
                put("type", "buy_coins_armor")
                put("order", 2)
                put("key", "buy_coins_armor_medium")
                put("fuel", 250)
                put("image", "images/items/fuel-drop.jpg")
                put("PriceUSD", 199)
                put("PriceEUR", 199)
                put("PriceGBP", 149)
            }
            putJsonObject("buy_coins_armor_large") {
                put("type", "buy_coins_armor")
                put("order", 3)
                put("key", "buy_coins_armor_large")
                put("fuel", 600)
                put("image", "images/items/fuel-cans.jpg")
                put("PriceUSD", 499)
                put("PriceEUR", 499)
                put("PriceGBP", 399)
            }
            putJsonObject("buy_coins_armor_xlarge") {
                put("type", "buy_coins_armor")
                put("order", 4)
                put("key", "buy_coins_armor_xlarge")
                put("fuel", 1500)
                put("image", "images/items/fuel-container.jpg")
                put("PriceUSD", 999)
                put("PriceEUR", 999)
                put("PriceGBP", 799)
                putJsonArray("items") {
                    addJsonObject {
                        put("type", "food")
                        put("qty", 50)
                    }
                    addJsonObject {
                        put("type", "water")
                        put("qty", 50)
                    }
                    addJsonObject {
                        put("type", "cash")
                        put("qty", 100)
                    }
                }
            }
            
            // Yahoo service
            putJsonObject("buy_coins_yahoo_small") {
                put("type", "buy_coins_yahoo")
                put("order", 1)
                put("key", "buy_coins_yahoo_small")
                put("fuel", 100)
                put("image", "images/items/fuel-bottle.jpg")
                put("PriceUSD", 99)
                put("PriceEUR", 99)
                put("PriceGBP", 79)
            }
            putJsonObject("buy_coins_yahoo_medium") {
                put("type", "buy_coins_yahoo")
                put("order", 2)
                put("key", "buy_coins_yahoo_medium")
                put("fuel", 250)
                put("image", "images/items/fuel-drop.jpg")
                put("PriceUSD", 199)
                put("PriceEUR", 199)
                put("PriceGBP", 149)
            }
            putJsonObject("buy_coins_yahoo_large") {
                put("type", "buy_coins_yahoo")
                put("order", 3)
                put("key", "buy_coins_yahoo_large")
                put("fuel", 600)
                put("image", "images/items/fuel-cans.jpg")
                put("PriceUSD", 499)
                put("PriceEUR", 499)
                put("PriceGBP", 399)
            }
            putJsonObject("buy_coins_yahoo_xlarge") {
                put("type", "buy_coins_yahoo")
                put("order", 4)
                put("key", "buy_coins_yahoo_xlarge")
                put("fuel", 1500)
                put("image", "images/items/fuel-container.jpg")
                put("PriceUSD", 999)
                put("PriceEUR", 999)
                put("PriceGBP", 799)
                putJsonArray("items") {
                    addJsonObject {
                        put("type", "food")
                        put("qty", 50)
                    }
                    addJsonObject {
                        put("type", "water")
                        put("qty", 50)
                    }
                    addJsonObject {
                        put("type", "cash")
                        put("qty", 100)
                    }
                }
            }
            
            // Inventory upgrades
            putJsonObject("InventoryUpgrade1") {}
            putJsonObject("InventoryUpgrade2") {}
            putJsonObject("InventoryUpgrade3") {}
            
            // Other operations
            putJsonObject("AttributeReset") {}
            putJsonObject("TradeSlotUpgrade") {}
            putJsonObject("DeathMobileUpgrade") {}
            putJsonObject("InventoryUpgrade1_UNUSED") {}
            
            // Speed up items
            putJsonObject("SpeedUpOneHour") {
                put("type", "speed_up")
                put("order", 2)
                put("enabled", true)
                put("FreelyGivable", false)
                put("key", "SpeedUpOneHour")
                put("time", 3600)
                put("maxTime", 14400)
                put("costPerMin", 0.35)
                put("minCost", 25)
                put("PriceCoins", 20)
            }
            
            putJsonObject("SpeedUpTwoHour") {
                put("type", "speed_up")
                put("order", 3)
                put("enabled", true)
                put("FreelyGivable", false)
                put("key", "SpeedUpTwoHour")
                put("time", 7200)
                put("maxTime", 28800)
                put("costPerMin", 0.3)
                put("minCost", 40)
                put("PriceCoins", 40)
            }
            
            putJsonObject("SpeedUpHalf") {
                put("type", "speed_up")
                put("order", 1)
                put("enabled", true)
                put("FreelyGivable", false)
                put("key", "SpeedUpHalf")
                put("percent", 0.5)
                put("costPerMin", 0.4)
                put("minCost", 60)
                put("PriceCoins", 70)
            }
            
            putJsonObject("SpeedUpComplete") {
                put("type", "speed_up")
                put("order", 4)
                put("enabled", true)
                put("FreelyGivable", false)
                put("key", "SpeedUpComplete")
                put("PriceCoins", 80)
                put("minCost", 80)
            }
            
            putJsonObject("SpeedUpFree") {
                put("type", "speed_up")
                put("order", 5)
                put("enabled", true)
                put("FreelyGivable", true)
                put("key", "SpeedUpFree")
                put("maxTime", 300)
                put("PriceCoins", 0)
            }
        }
        
        return json.toString()
    }
}
