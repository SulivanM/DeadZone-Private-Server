package server.handler.save

import server.handler.save.SaveHandlerContext

/**
 * Interface for handling game state save operations.
 *
 * Save handlers are specialized handlers that process client requests to persist
 * game state changes. The save system uses a method-based dispatch where each
 * save operation (e.g., "addBuilding", "startMission") is handled by a specific
 * sub-handler implementation.
 *
 * ## Supported Operations
 *
 * Different implementations handle different game systems:
 * - **BuildingSaveHandler**: Building construction, upgrades, repairs
 * - **SurvivorSaveHandler**: Survivor hiring, leveling, equipment
 * - **MissionSaveHandler**: Mission starts, returns, rewards
 * - **ItemSaveHandler**: Crafting, recycling, consumption
 *
 * ## Usage Example
 *
 * ```kotlin
 * class ShopSaveHandler : SaveSubHandler {
 *     override val supportedTypes = setOf("buyItem", "sellItem")
 *
 *     override suspend fun handle(ctx: SaveHandlerContext) {
 *         when (ctx.methodName) {
 *             "buyItem" -> handleBuyItem(ctx)
 *             "sellItem" -> handleSellItem(ctx)
 *         }
 *     }
 *
 *     private suspend fun handleBuyItem(ctx: SaveHandlerContext) {
 *         val itemId = ctx.message.getString(0)
 *         // Process purchase...
 *         ctx.respond("buySuccess", itemId)
 *     }
 * }
 * ```
 *
 * ## Registration
 *
 * Save handlers must be registered in [dev.deadzone.Application.module]:
 * ```kotlin
 * val saveHandlers = listOf(
 *     BuildingSaveHandler(),
 *     SurvivorSaveHandler(),
 *     ShopSaveHandler()  // New handler
 * )
 * ```
 *
 * @see server.handler.SaveHandler Main save message router
 * @see SaveHandlerContext Context containing message and server state
 */
interface SaveSubHandler {
    /**
     * Set of save method names this handler supports.
     *
     * The SaveHandler dispatcher uses this to route save requests to the
     * appropriate sub-handler. Method names should match exactly what the
     * client sends (e.g., "addBuilding", "startMission").
     *
     * @return Set of method names handled by this implementation
     */
    val supportedTypes: Set<String>

    /**
     * Processes a save operation request.
     *
     * This method is called when a client sends a save request with a method
     * name matching one of [supportedTypes]. Implementations should:
     * 1. Extract parameters from [SaveHandlerContext.message]
     * 2. Validate the operation
     * 3. Update game state
     * 4. Persist changes to database
     * 5. Send response via [SaveHandlerContext.respond]
     *
     * @param ctx Context containing method name, message parameters, and server state
     */
    suspend fun handle(ctx: SaveHandlerContext)
}
