import core.data.GameDefinitions
import core.items.model.Item
import core.items.model.combineItems
import core.items.model.quantityString
import core.items.model.stackOwnItems
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class TestMissionSaveHandler {
    private val def = GameDefinitions()

    @Test
    fun testStackItems() {
        val items = listOf(
            Item(type = "pipe", qty = 4u),
            Item(type = "pipe", qty = 6u),
            Item(type = "insulation", qty = 8u),
            Item(type = "insulation", qty = 3u),
            Item(type = "nails", qty = 99u),
            Item(type = "nails", qty = 99u),
            Item(type = "bolts", qty = 80u),
            Item(type = "bolts", qty = 21u),
            Item(type = "screws", qty = 77u),
            Item(type = "screws", qty = 22u),
        )

        val expected = listOf(
            Item(type = "pipe", qty = 10u),
            Item(type = "insulation", qty = 10u),
            Item(type = "insulation", qty = 1u),
            Item(type = "nails", qty = 100u),
            Item(type = "nails", qty = 98u),
            Item(type = "bolts", qty = 100u),
            Item(type = "bolts", qty = 1u),
            Item(type = "screws", qty = 99u),
        )
        val actual = items.stackOwnItems(def)

        println("expected: ${expected.sortByQuantity().joinToString { it.quantityString() }}")
        println("actual  : ${actual.sortByQuantity().joinToString { it.quantityString() }}")
        println()
        assertTrue(expected.isQuantityEqual(actual))
    }

    @Test
    fun testCombineItems() {
        // include:
        // - resources (shouldn't be added to inventory)
        // - normal items (add to inventory)
        // - stackable items (add to inventory with same quantity as provided)
        // - overflowed stackable items (add to inventory with multiple units)
        val items1 = listOf(
            Item(type = "water", qty = 20u),
            Item(type = "waterBottle", qty = 1u),
            Item(type = "waterBottle", qty = 1u),
            Item(type = "waterBottle", qty = 1u),
            Item(type = "infamous-helmet", qty = 1u),
            Item(type = "infamous-helmet", qty = 1u),
            Item(type = "pipe", qty = 4u),
            Item(type = "insulation", qty = 8u),
            Item(type = "nails", qty = 99u),
            Item(type = "bolts", qty = 80u),
            Item(type = "screws", qty = 77u),
        )

        val items2 = listOf(
            Item(type = "water", qty = 20u),
            Item(type = "waterBottle", qty = 1u),
            Item(type = "infamous-helmet", qty = 1u),
            Item(type = "pipe", qty = 6u),
            Item(type = "insulation", qty = 3u),
            Item(type = "nails", qty = 99u),
            Item(type = "bolts", qty = 21u),
            Item(type = "screws", qty = 22u),
        )

        val expected = listOf(
            Item(type = "water", qty = 40u),
            Item(type = "waterBottle", qty = 1u),
            Item(type = "waterBottle", qty = 1u),
            Item(type = "waterBottle", qty = 1u),
            Item(type = "waterBottle", qty = 1u),
            Item(type = "infamous-helmet", qty = 1u),
            Item(type = "infamous-helmet", qty = 1u),
            Item(type = "infamous-helmet", qty = 1u),
            Item(type = "pipe", qty = 10u),
            Item(type = "insulation", qty = 10u),
            Item(type = "insulation", qty = 1u),
            Item(type = "nails", qty = 100u),
            Item(type = "nails", qty = 98u),
            Item(type = "bolts", qty = 100u),
            Item(type = "bolts", qty = 1u),
            Item(type = "screws", qty = 99u),
        )

        val actual = items1.combineItems(items2, def)

        println("expected: ${expected.sortByQuantity().joinToString { it.quantityString() }}")
        println("actual  : ${actual.sortByQuantity().joinToString { it.quantityString() }}")
        println()
        assertTrue(expected.isQuantityEqual(actual))
    }

    private fun List<Item>.isQuantityEqual(other: List<Item>): Boolean {
        if (this.size != other.size) return false

        val groupedA = this.groupingBy { it.type to it.qty }.eachCount()
        val groupedB = other.groupingBy { it.type to it.qty }.eachCount()

        return groupedA == groupedB
    }

    private fun List<Item>.sortByQuantity(): List<Item> {
        return this.sortedWith(compareBy<Item> { it.type }.thenBy { it.qty })
    }
}
