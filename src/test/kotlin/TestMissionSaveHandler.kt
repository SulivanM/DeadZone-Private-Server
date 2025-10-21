import context.GlobalContext
import core.data.GameDefinitions
import core.items.model.Item
import core.items.model.compactString
import core.items.model.quantityString
import data.collection.combineItems
import utils.Logger
import utils.UUID
import kotlin.math.min
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class TestMissionSaveHandler {
    private val def = GameDefinitions()

    @Test
    fun testBuildInventoryItemsAndCombineItems() {
        // include:
        // - resources (shouldn't be added to inventory)
        // - normal items (add to inventory)
        // - stackable items (add to inventory with same quantity as provided)
        // - overflowed stackable items (add to inventory with multiple units)
        val items1 = listOf(
            Item(type = "water"),
            Item(type = "food"),
            Item(type = "cash"),
            Item(type = "infamous-helmet"),
            Item(type = "pipe"),
            Item(type = "insulation"),
            Item(type = "nails"),
            Item(type = "bolts"),
            Item(type = "screws"),
            Item(type = "rivets"),
            Item(type = "wire"),
        )
        // must follow game convention, item type is uppercased
        val counter1 = mapOf(
            "WATER" to 40,
            "FOOD" to 1000,
            "CASH" to 234,
            "INFAMOUS-HELMET" to 3, // stack = 1
            "PIPE" to 1,            // stack = 10
            "INSULATION" to 11,     // stack = 10
            "NAILS" to 100,         // stack = 100
            "BOLTS" to 101,         // stack = 100
            "SCREWS" to 245,        // stack = 100
            "WIRE" to 24,           // stack = 25
        )

        val expectedFirst = listOf(
            Item(type = "infamous-helmet", qty = 1u),
            Item(type = "infamous-helmet", qty = 1u),
            Item(type = "infamous-helmet", qty = 1u),
            Item(type = "pipe", qty = 1u),
            Item(type = "insulation", qty = 10u),
            Item(type = "insulation", qty = 1u),
            Item(type = "nails", qty = 100u),
            Item(type = "bolts", qty = 100u),
            Item(type = "bolts", qty = 1u),
            Item(type = "screws", qty = 100u),
            Item(type = "screws", qty = 100u),
            Item(type = "screws", qty = 45u),
            Item(type = "wire", qty = 24u),
        )

        val actualFirst = buildNewInventoryItems(items1, counter1)

        println("expectedFirst: ${expectedFirst.sortByQuantity().joinToString { it.quantityString() }}")
        println("actualFirst  : ${actualFirst.sortByQuantity().joinToString { it.quantityString() }}")
        println()
        assertTrue(expectedFirst.isQuantityEqual(actualFirst))

        val items2 = listOf(
            Item(type = "water"),
            Item(type = "infamous-helmet"),
            Item(type = "pipe"),
            Item(type = "insulation"),
            Item(type = "nails"),
            Item(type = "bolts"),
            Item(type = "screws"),
            Item(type = "rivets"),
            Item(type = "wire"),
            Item(type = "thread"),
            Item(type = "strap"),
        )
        val counter2 = mapOf(
            "WATER" to 40,
            "INFAMOUS-HELMET" to 2,
            "PIPE" to 4,
            "INSULATION" to 8,
            "NAILS" to 100,
            "BOLTS" to 77,
            "SCREWS" to 133,
            "WIRE" to 2,
            "THREAD" to 12,         // stack = 50
            "STRAP" to 18,          // stack = 10
        )

        val expectedSecond = listOf(
            Item(type = "infamous-helmet", qty = 1u),
            Item(type = "infamous-helmet", qty = 1u),
            Item(type = "pipe", qty = 4u),
            Item(type = "insulation", qty = 8u),
            Item(type = "nails", qty = 100u),
            Item(type = "bolts", qty = 77u),
            Item(type = "screws", qty = 100u),
            Item(type = "screws", qty = 33u),
            Item(type = "wire", qty = 2u),
            Item(type = "thread", qty = 12u),
            Item(type = "strap", qty = 10u),
            Item(type = "strap", qty = 8u),
        )

        val actualSecond = buildNewInventoryItems(items2, counter2)

        println("expectedSecond: ${expectedSecond.sortByQuantity().joinToString { it.quantityString() }}")
        println("actualSecond  : ${actualSecond.sortByQuantity().joinToString { it.quantityString() }}")
        println()
        assertTrue(expectedSecond.isQuantityEqual(actualSecond))

        // combine two inventory to ensure its expanded correctly (i.e., non-full stack added together)
        val expectedCombination = listOf(
            Item(type = "infamous-helmet", qty = 1u),
            Item(type = "infamous-helmet", qty = 1u),
            Item(type = "infamous-helmet", qty = 1u),
            Item(type = "infamous-helmet", qty = 1u),
            Item(type = "infamous-helmet", qty = 1u),
            Item(type = "pipe", qty = 5u),
            Item(type = "insulation", qty = 10u),
            Item(type = "insulation", qty = 9u),
            Item(type = "nails", qty = 100u),
            Item(type = "nails", qty = 100u),
            Item(type = "bolts", qty = 100u),
            Item(type = "bolts", qty = 78u),
            Item(type = "screws", qty = 100u),
            Item(type = "screws", qty = 100u),
            Item(type = "screws", qty = 100u),
            Item(type = "screws", qty = 78u),
            Item(type = "wire", qty = 25u),
            Item(type = "wire", qty = 1u),
            Item(type = "thread", qty = 12u),
            Item(type = "strap", qty = 10u),
            Item(type = "strap", qty = 8u),
        )

        val actualCombination = actualFirst.combineItems(actualSecond, def)

        println("expectedCombination: ${expectedCombination.sortByQuantity().joinToString { it.quantityString() }}")
        println("actualCombination  : ${actualCombination.sortByQuantity().joinToString { it.quantityString() }}")
        println()
        assertTrue(actualCombination.isQuantityEqual(expectedCombination))
    }

    // direct code copy from MissionSaveHandler (because the method is private)
    private fun buildNewInventoryItems(items: List<Item>, counter: Map<String, Int>): List<Item> {
        val inventory = mutableListOf<Item>()

        for (item in items) {
            val count = counter[item.type.uppercase()]
            // Resource type of item (e.g., water, food) does not need to be added to the inventory
            if (!def.isResourceItem(item.type)) {
                if (count != null) {
                    val maxStack = def.getMaxStackOfItem(idInXml = item.type)
                    // e.g., 18 items with max stack of 10 should produce 2 item units (10 and 8)
                    val totalItemUnits = count / maxStack
                    val overflowCounts = count % maxStack

                    repeat(totalItemUnits) {
                        inventory.add(item.copy(qty = min(maxStack, count).toUInt()))
                    }
                    if (overflowCounts > 0) {
                        // regenerate UUID as it is a new item
                        inventory.add(item.copy(id = UUID.new(), qty = overflowCounts.toUInt()))
                    }
                } else {
                    Logger.warn(logFull = true) { "buildNewInventoryItems: Item counter is null for itemId: ${item.id}, items: ${items.map { it.compactString() }}, counter: $counter" }
                }
            }
        }

        return inventory
    }

    private fun Item.isQuantityEqual(other: Item): Boolean {
        return this.type == other.type && this.qty == other.qty
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
