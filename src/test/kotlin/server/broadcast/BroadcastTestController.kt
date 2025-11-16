package server.broadcast

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import dev.deadzone.utils.Logger

/**
 * Test controller for sending broadcast messages
 * This is for testing and demonstration purposes
 */
object BroadcastTestController {

    /**
     * Starts sending test broadcast messages periodically
     */
    fun startTestBroadcasts(scope: CoroutineScope) {
        scope.launch(SupervisorJob() + Dispatchers.IO) {
            delay(5000) // Wait 5 seconds after server start

            Logger.info("🧪 Starting broadcast test messages...")

            // Test 1: Plain text message
            BroadcastService.broadcastPlainText("Server is online and broadcast system is working!")
            delay(3000)

            // Test 2: Admin message
            BroadcastService.broadcastAdmin("Welcome to the beta test !")
            delay(3000)

            // Test 3: Warning message
            BroadcastService.broadcastWarning("This is a test warning message")
            delay(3000)

            // Test 4: Item found
            BroadcastService.broadcastItemFound("TestPlayer", "Legendary Sword", "Legendary")
            delay(3000)

            // Test 5: Item unboxed
            BroadcastService.broadcastItemUnboxed("TestPlayer", "Epic Armor", "Epic")
            delay(3000)

            // Test 6: Achievement
            BroadcastService.broadcastAchievement("TestPlayer", "First Blood")
            delay(3000)

            // Test 7: User level
            BroadcastService.broadcastUserLevel("TestPlayer", 50)
            delay(3000)

            // Test 8: Raid attack
            BroadcastService.broadcastRaidAttack("Attacker123", "Defender456", "Victory")
            delay(3000)

            // Test 9: Item crafted
            BroadcastService.broadcastItemCrafted("CrafterPro", "Master Weapon")
            delay(3000)

            // Test 10: Bounty collected
            BroadcastService.broadcastBountyCollected("Hunter", "Target", 5000)

            Logger.info("🧪 Broadcast test messages completed")
        }
    }

    /**
     * Sends a single test message
     */
    fun sendTestMessage(scope: CoroutineScope, protocol: BroadcastProtocol, vararg args: String) {
        scope.launch(SupervisorJob() + Dispatchers.IO) {
            val message = BroadcastMessage(protocol, args.toList())
            BroadcastService.broadcast(message)
            Logger.info("📤 Test broadcast sent: ${message.toWireFormat()}")
        }
    }

    /**
     * Sends periodic maintenance messages every 30 seconds
     */
    fun startMaintenanceMessages(scope: CoroutineScope) {
        scope.launch(SupervisorJob() + Dispatchers.IO) {
            delay(5000) // Wait 5 seconds after server start

            while (isActive) {
                val clientCount = BroadcastService.getClientCount()
                Logger.info("📢 Sending maintenance message to $clientCount client(s)")

                BroadcastService.broadcastWarning("Server maintenance scheduled - save your progress!")

                delay(30000) // 30 seconds
            }
        }
    }

    /**
     * Sends periodic welcome messages
     */
    fun startPeriodicMessages(scope: CoroutineScope, intervalSeconds: Long = 300) {
        scope.launch(SupervisorJob() + Dispatchers.IO) {
            while (true) {
                delay(intervalSeconds * 1000)

                val clientCount = BroadcastService.getClientCount()
                if (clientCount > 0) {
                    BroadcastService.broadcastPlainText("Server running smoothly - $clientCount client(s) connected")
                }
            }
        }
    }
}
