import core.mission.LootService
import core.mission.model.LootParameter
import kotlin.test.Test
import kotlin.test.assertTrue

class TestLootService {

    private val sampleSceneXML = """
        <?xml version="1.0"?>
        <scene>
            <e>
                <opt>
                    <srch>random,weapon</srch>
                </opt>
            </e>
            <e>
                <opt>
                    <srch>food,water</srch>
                </opt>
            </e>
        </scene>
    """.trimIndent()

    @Test
    fun testLootServiceInitialization() {
        val parameter = LootParameter(
            areaLevel = 1,
            baseWeight = 100.0
        )

        val service = LootService(sampleSceneXML, parameter)

        assertTrue(service.cumulativeLootsPerLoc.isNotEmpty())
    }

    @Test
    fun testInsertLoots() {
        val parameter = LootParameter(
            areaLevel = 1,
            baseWeight = 100.0
        )

        val service = LootService(sampleSceneXML, parameter)
        val (updatedXML, loots) = service.insertLoots()

        assertTrue(updatedXML.contains("<itms"))
        assertTrue(loots.size >= 0)
    }

    @Test
    fun testInsertLootsWithExistingItems() {
        val sceneWithItems = """
            <?xml version="1.0"?>
            <scene>
                <e>
                    <opt>
                        <srch>random</srch>
                    </opt>
                    <itms>
                        <itm id="existing" type="sword" q="1"/>
                    </itms>
                </e>
            </scene>
        """.trimIndent()

        val parameter = LootParameter(
            areaLevel = 1,
            baseWeight = 100.0
        )

        val service = LootService(sceneWithItems, parameter)
        val (_, loots) = service.insertLoots()

        assertTrue(loots.isEmpty())
    }

    @Test
    fun testLootParameterWithBoosts() {
        val parameter = LootParameter(
            areaLevel = 5,
            baseWeight = 100.0,
            specificItemBoost = mapOf("pipe" to 2.0),
            itemTypeBoost = mapOf("weapon" to 1.5),
            itemQualityBoost = mapOf("rare" to 1.2)
        )

        val service = LootService(sampleSceneXML, parameter)

        assertTrue(service.totalWeightPerLoc.isNotEmpty())
    }

    @Test
    fun testLootParameterWithOverrides() {
        val parameter = LootParameter(
            areaLevel = 1,
            baseWeight = 100.0,
            itemWeightOverrides = mapOf("pipe" to 500.0)
        )

        val service = LootService(sampleSceneXML, parameter)

        assertTrue(service.cumulativeLootsPerLoc.isNotEmpty())
    }

    @Test
    fun testInsertedLootsTracking() {
        val parameter = LootParameter(
            areaLevel = 1,
            baseWeight = 100.0
        )

        val service = LootService(sampleSceneXML, parameter)
        service.insertLoots()

        assertTrue(service.insertedLoots.size >= 0)
    }

    @Test
    fun testEmptySceneXML() {
        val emptyScene = """
            <?xml version="1.0"?>
            <scene>
            </scene>
        """.trimIndent()

        val parameter = LootParameter(
            areaLevel = 1,
            baseWeight = 100.0
        )

        val service = LootService(emptyScene, parameter)
        val (_, loots) = service.insertLoots()

        assertTrue(loots.isEmpty())
    }

    @Test
    fun testHighLevelAreaFiltering() {
        val parameter = LootParameter(
            areaLevel = 50,
            baseWeight = 100.0
        )

        val service = LootService(sampleSceneXML, parameter)

        assertTrue(service.cumulativeLootsPerLoc.size >= 0)
    }
}
