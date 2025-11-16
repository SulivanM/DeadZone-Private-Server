package server.service

import server.model.Offer

/**
 * Service for managing game offers.
 *
 * Currently returns hardcoded offers, but can be extended to:
 * - Load offers from database
 * - Load offers from configuration files
 * - Support dynamic offer generation based on player data
 *
 * Note: The AS3 client uses Language.getInstance().getString("offers." + key)
 * to get localized title/description, so we don't send those from the server.
 */
object OfferService {

    /**
     * Get all available offers.
     *
     * Note: Filtering by player level and expiration is handled client-side.
     * The server returns all offers and the client filters based on:
     * - Player level (levelMin/levelMax)
     * - Expiration date
     * - Viewed state (stored locally)
     *
     * IMPORTANT: Offer IDs must match keys in the language file (en.xml.gz):
     * - Client looks up title: Language.getInstance().getString("offers." + id)
     * - Client looks up description: Language.getInstance().getString("offers." + id + "_desc")
     * - If keys don't exist, client will display "?" as title
     */
    fun getAllOffers(): List<Offer> {
        return listOf(
            // Starter Pack - One-time welcome package for new players (level 1 only)
            // Language keys: offers.packagebeginner, offers.packagebeginner_desc
            Offer(
                id = "packagebeginner",
                type = "package",
                priority = 100, // Highest priority - shown first
                levelMin = 1,
                levelMax = 1, // Only visible at level 1
                expires = null, // No expiration
                PriceCoins = 0, // Free offer
                fuel = 1500,
                items = listOf(
                    // Basic survival resources to get started
                    mapOf("type" to "food", "qty" to 750),
                    mapOf("type" to "water", "qty" to 750),
                    mapOf("type" to "wood", "qty" to 500),
                    mapOf("type" to "metal", "qty" to 200),
                    // Basic equipment
                    mapOf("type" to "melee-bat", "qty" to 1),
                    mapOf("type" to "medical-bandage", "qty" to 20)
                ),
                image = "images/ui/buy-package.jpg",
                headerBgColor = "#4A90E2",
                headerTitleColor = "#FFFFFF"
            ),

            // Small Fuel Package - Entry-level fuel offer
            // Language keys: offers.packagefuel2500, offers.packagefuel2500_desc
            Offer(
                id = "packagefuel2500",
                type = "package",
                priority = 60,
                levelMin = 1,
                levelMax = null,
                expires = null,
                PriceCoins = null, // Not purchasable with coins
                PriceUSD = 999, // $9.99 in cents
                PriceKKR = 10, // 10 Kongregate Kreds
                fuel = 2500,
                items = listOf(
                    // Bonus items for fuel purchase
                    mapOf("type" to "food", "qty" to 1000),
                    mapOf("type" to "water", "qty" to 1000),
                    mapOf("type" to "ammo-clip", "qty" to 100)
                ),
                image = "images/ui/buy-package.jpg",
                headerBgColor = "#FF9500",
                headerTitleColor = "#FFFFFF"
            ),

            // Large Fuel Package - Better value for established players
            // Language keys: offers.packagefuel7000, offers.packagefuel7000_desc
            Offer(
                id = "packagefuel7000",
                type = "package",
                priority = 50,
                levelMin = 10, // Only appears at level 10+
                levelMax = null,
                expires = null,
                PriceCoins = null,
                PriceUSD = 1999, // $19.99
                PriceKKR = 20,
                fuel = 7000,
                items = listOf(
                    mapOf("type" to "food", "qty" to 3000),
                    mapOf("type" to "water", "qty" to 3000),
                    mapOf("type" to "wood", "qty" to 2000),
                    mapOf("type" to "metal", "qty" to 1000),
                    mapOf("type" to "ammo-clip", "qty" to 300)
                ),
                image = "images/ui/buy-package.jpg",
                headerBgColor = "#7B1FA2",
                headerTitleColor = "#FFFFFF"
            ),

            // Warrior Pack - Premium equipment for mid-level players
            // Language keys: offers.packagewarrior, offers.packagewarrior_desc
            Offer(
                id = "packagewarrior",
                type = "package",
                priority = 70,
                levelMin = 15, // Only appears at level 15+
                levelMax = 30,
                expires = null,
                PriceCoins = 5000, // 5000 coins
                fuel = 2000,
                items = listOf(
                    // Premium warrior equipment
                    mapOf("type" to "melee-katana", "qty" to 1, "quality" to 2),
                    mapOf("type" to "armor-tactical", "qty" to 1, "quality" to 2),
                    mapOf("type" to "helmet-military", "qty" to 1, "quality" to 2),
                    mapOf("type" to "food", "qty" to 2000),
                    mapOf("type" to "medical-bandage", "qty" to 50)
                ),
                image = "images/ui/buy-package.jpg",
                headerBgColor = "#D32F2F",
                headerTitleColor = "#FFD700"
            )
        )
    }

    /**
     * Get offers as a map keyed by offer ID.
     * This format matches what the AS3 client expects in GET_OFFERS response.
     *
     * The client expects: { "offer_id": { ...offer_data... }, ... }
     * The client will add "key" and "viewed" properties on its side.
     */
    fun getOffersAsMap(): Map<String, Map<String, Any?>> {
        return getAllOffers().associate { offer ->
            offer.id to buildMap<String, Any?> {
                put("type", offer.type)
                offer.priority?.let { put("priority", it) }
                offer.levelMin?.let { put("levelMin", it) }
                offer.levelMax?.let { put("levelMax", it) }
                offer.hideLevels?.let { put("hideLevels", it) }
                offer.expires?.let { put("expires", it) }
                offer.PriceCoins?.let { put("PriceCoins", it) }
                offer.PriceUSD?.let { put("PriceUSD", it) }
                offer.PriceKKR?.let { put("PriceKKR", it) }
                offer.fuel?.let { put("fuel", it) }
                offer.items?.let { put("items", it) }
                offer.image?.let { put("image", it) }
                offer.headerBgColor?.let { put("headerBgColor", it) }
                offer.headerTitleColor?.let { put("headerTitleColor", it) }
                offer.oneTime?.let { put("oneTime", it) }
                offer.upgrade?.let { put("upgrade", it) }
            }
        }
    }
}
