package dev.deadzone.socket.core

import context.ServerContext
import kotlinx.coroutines.*

/**
 * The main server that orchestrates all sub-servers.
 *
 * Provides a single entry point to initialize, start, and shut down all sub-servers.
 * Serves as the root coroutine context, shared by sub-servers and client connections.
 */
class MainServer(private val servers: List<Server>, private val context: ServerContext) {
    private val job = SupervisorJob()
    private val coroutineScope: CoroutineScope = CoroutineScope(Dispatchers.Default + job)

    init {
        coroutineScope.launch {
            servers.forEach { it.initialize(coroutineScope, context) }
        }
    }

    fun start() {
        coroutineScope.launch {
            servers.forEach { it.start() }
        }
    }

    fun shutdown() {
        coroutineScope.launch {
            servers.forEach { it.shutdown() }
            job.cancelAndJoin()
        }
    }
}
