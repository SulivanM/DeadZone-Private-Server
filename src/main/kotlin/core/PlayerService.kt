package dev.deadzone.core

/**
 * Represents a player-scoped game service.
 *
 * This service manages data and domain logic related to a specific game domain for a particular player,
 * such as survivors, inventory, or loot. It is not responsible for low-level database operations,
 * nor should it handle player identification on each operations. Instead, it stores domain data and provides
 * operations to callers.
 *
 * Typically, the service initializes local data through the [init] method.
 * It receives a repository specific to the domain (e.g., [SurvivorRepository]) to delegates the
 * low-level database work. Each repository is preferred to be wrapped in try-catch
 * and always return a Result<T> type. This is to ensure consistency on error handling across repository.
 *
 * Repository may define CRUD operations only, letting the service define the more complex operations.
 *
 * See examples: [SurvivorService]
 */
interface PlayerService {
    /**
     * Initializes the service for the specified [playerId].
     *
     * This method should be used to load or prepare all data related to the player
     * in this service's domain.
     *
     * @return An empty result just for denoting success or failure.
     */
    suspend fun init(playerId: String): Result<Unit>

    /**
     * Closes the service for the specified [playerId].
     *
     * This method is called when the player logs off or disconnects.
     * It should synchronize any in-memory state with persistent storage
     * to ensure no progress or transient data is lost.
     *
     * For example, [CompoundService] maintains additional timing data to enable lazy
     * calculation of building resource production without storing additional time data
     * in the DB and doing more query. This also avoid the need of server running
     * an increment resource task on each production building.
     *
     * However, without a server-initiated task, the DB wouldn't keep the latest data at all time.
     * The `close` method would update fields such as `resourceValue` on production buildings,
     * to reflect the final accumulated resources since the last time resources was collected.
     *
     * @return An empty result just for denoting success or failure.
     */
    suspend fun close(playerId: String): Result<Unit>
}
