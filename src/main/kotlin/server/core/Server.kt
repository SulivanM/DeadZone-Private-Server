package server.core

import context.ServerContext
import kotlinx.coroutines.CoroutineScope

/**
 * Represent a server.
 */
interface Server {
    val name: String

    suspend fun initialize(scope: CoroutineScope, context: ServerContext)
    suspend fun start()
    suspend fun shutdown()

    fun isRunning(): Boolean
}