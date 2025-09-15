package dev.deadzone.context

import dev.deadzone.core.data.GameDefinitions
import kotlinx.serialization.json.Json

/**
 * Singleton object that holds the server's global context.
 * It is initialized on server startup.
 *
 * @property json pre-configured JSON serializer/deserializer.
 * @property gameDefinitions contains game definitions from XML resources.
 */
object GlobalContext {
    lateinit var json: Json
        private set
    lateinit var gameDefinitions: GameDefinitions
        private set

    fun init(json: Json, gameDefinitions: GameDefinitions) {
        this.json = json
        this.gameDefinitions = gameDefinitions
    }
}
