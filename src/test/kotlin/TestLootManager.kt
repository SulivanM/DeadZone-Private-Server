import dev.deadzone.core.mission.LootService
import dev.deadzone.core.mission.LootParameter
import dev.deadzone.core.data.GameDefinitions
import dev.deadzone.socket.handler.save.mission.response.loadSceneXML
import java.io.File
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import kotlin.test.Test

object TestDependency {
    val gameDefinitions: GameDefinitions = GameDefinitions({})
}

class TestLootManager {
    private val PARAMETER1 = LootParameter(
        areaLevel = 30,
        playerLevel = 30,
        itemWeightOverrides = mapOf(),
        specificItemBoost = mapOf(
            "fuel-cans" to 3.0 // +300% find fuel chance (of the base chance)
        ),
        itemTypeBoost = mapOf(
            "junk" to 0.8 // +80% junk find chance
        ),
        itemQualityBoost = mapOf(
            "blue" to 0.5 // +50% blue quality find chance
        ),
        baseWeight = 1.0,
        fuelLimit = 50
    )
    private val SCENES_TO_TEST = listOf("exterior-bridge-1")
    private val GENERATION_PER_SCENE = 10

    val logDir = File("logs")
    val timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss"))
    val logFile = File(logDir, "loot_generation_test-$timestamp.log")

    @Test
    fun testLootGeneration() {
        if (!logDir.exists()) logDir.mkdirs()

        logFile.bufferedWriter().use { writer ->
            SCENES_TO_TEST.forEach { filename ->

                repeat(GENERATION_PER_SCENE) { i ->
                    val sceneXML = loadSceneXML(filename)
                    val manager = LootService(
                        gameDefinitions = TestDependency.gameDefinitions,
                        sceneXML = sceneXML,
                        parameter = PARAMETER1
                    )
                    manager.insertLoots()

                    writer.write("========> Scene: $filename (areaLevel:${PARAMETER1.areaLevel}) (iteration:$i)\n")
                    val lootsAggregate: Map<String, Int> = manager.insertedLoots
                        .groupingBy { it.itemIdInXML }
                        .fold(0) { acc, loot -> acc + loot.quantity }

                    for ((itemId, totalQty) in lootsAggregate.entries.sortedByDescending { it.value }) {
                        writer.write(" - $itemId (total x$totalQty)\n")
                    }

                    writer.write("==============================================\n")
                }
            }
        }

        println("Loot generation logs written to: ${logFile.absolutePath}")
    }
}

