package server

import context.ServerContext
import server.core.Server
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancelAndJoin

class ServerContainer(private val servers: List<Server>, private val context: ServerContext) {
    private val job = SupervisorJob()
    private val coroutineScope: CoroutineScope = CoroutineScope(Dispatchers.Default + job)

    suspend fun initializeAll() {
        servers.forEach { it.initialize(coroutineScope, context) }
    }

    suspend fun startAll() {
        servers.forEach { it.start() }
    }

    suspend fun shutdownAll() {
        servers.forEach { it.shutdown() }
        job.cancelAndJoin()
    }
}
