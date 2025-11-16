package server.model

/**
 * Represents an offer that can be presented to players.
 * This structure matches what the AS3 client expects in GET_OFFERS response.
 *
 * The client uses Language.getInstance().getString("offers." + key) for title/description,
 * so we don't send title/description from the server.
 *
 * @property id Unique identifier for the offer (must match a key in language file: offers.{id})
 * @property type Type of offer (e.g., "package", "limited", "special", "codepackage")
 * @property priority Sorting priority (higher = displayed first). Used by UIOffersList.as for sorting
 * @property levelMin Minimum player level required to see this offer (null = no minimum)
 * @property levelMax Maximum player level to see this offer (null = no maximum)
 * @property hideLevels Whether to hide level restrictions in UI
 * @property expires Expiration timestamp in milliseconds (null = no expiration)
 * @property PriceCoins Price in game coins (null if not purchasable with coins)
 * @property PriceUSD Price in USD cents (e.g., 499 = $4.99)
 * @property PriceKKR Price in Kongregate Kreds
 * @property fuel Amount of fuel included in the offer
 * @property items Items or rewards included in the offer
 * @property image Image reference/asset name (not a URL)
 * @property headerBgColor Background color for offer header (hex string)
 * @property headerTitleColor Title text color for offer header (hex string)
 * @property oneTime One-time purchase identifier
 * @property upgrade Upgrade identifier this offer unlocks
 */
data class Offer(
    val id: String,
    val type: String,
    val priority: Int? = null,
    val levelMin: Int? = null,
    val levelMax: Int? = null,
    val hideLevels: Boolean? = null,
    val expires: Long? = null,
    val PriceCoins: Int? = null,
    val PriceUSD: Int? = null,
    val PriceKKR: Int? = null,
    val fuel: Int? = null,
    val items: List<Map<String, Any>>? = null,
    val image: String? = null,
    val headerBgColor: String? = null,
    val headerTitleColor: String? = null,
    val oneTime: String? = null,
    val upgrade: String? = null
)
