@file:OptIn(ExperimentalSerializationApi::class)

package core.items.model

import core.data.GameDefinition
import core.model.game.data.CraftingInfo
import common.UUID
import kotlinx.serialization.EncodeDefault
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.Serializable
import kotlin.math.min

@Serializable
data class Item(
    // Item has many fields, many of these aren't needed; however,
    // In the client-side, item factory always check whether the fields are present or not
    // If they are, they will use it without checking null (silent NPE is very often here)
    // This is why we shouldn't encode them if we don't intend to specify the field
    @EncodeDefault(EncodeDefault.Mode.NEVER) val id: String = UUID.new(),
    @EncodeDefault(EncodeDefault.Mode.NEVER) val new: Boolean = false,
    @EncodeDefault(EncodeDefault.Mode.NEVER) val storeId: String? = null,
    @EncodeDefault(EncodeDefault.Mode.NEVER) val bought: Boolean = false,
    @EncodeDefault(EncodeDefault.Mode.NEVER) val mod1: String? = null,
    @EncodeDefault(EncodeDefault.Mode.NEVER) val mod2: String? = null,
    @EncodeDefault(EncodeDefault.Mode.NEVER) val mod3: String? = null,
    @EncodeDefault(EncodeDefault.Mode.NEVER) val type: String,
    @EncodeDefault(EncodeDefault.Mode.NEVER) val level: Int = 0,
    @EncodeDefault(EncodeDefault.Mode.NEVER) val qty: UInt = 1u,
    @EncodeDefault(EncodeDefault.Mode.NEVER) val quality: Int? = null,
    @EncodeDefault(EncodeDefault.Mode.NEVER) val bind: UInt? = null,
    @EncodeDefault(EncodeDefault.Mode.NEVER) val tradable: Boolean? = true,
    @EncodeDefault(EncodeDefault.Mode.NEVER) val disposable: Boolean? = true,
    @EncodeDefault(EncodeDefault.Mode.NEVER) val ctrType: UInt? = null,
    @EncodeDefault(EncodeDefault.Mode.NEVER) val ctrVal: Int? = null,
    @EncodeDefault(EncodeDefault.Mode.NEVER) val craft: CraftingInfo? = null,
    @EncodeDefault(EncodeDefault.Mode.NEVER) val name: String? = null,
    @EncodeDefault(EncodeDefault.Mode.NEVER) val specData: ItemBonusStats? = null,
    @EncodeDefault(EncodeDefault.Mode.NEVER) val duplicate: Boolean = false,  // added from deserialize of Inventory
)

fun Item.compactString(): String {
    return "Item(id=${this.id}, type=${this.type})"
}

fun Item.quantityString(): String {
    return "Item(type=${this.type}, qty=${this.qty})"
}

/**
 * Combine two list of items semantically (according to the game definition).
 *
 * It assumes that the [other] list of items are already semantically correct.
 */
fun List<Item>.combineItems(other: List<Item>, gameDefinition: GameDefinition): List<Item> {
    val result = mutableListOf<Item>()
    val alreadyCombined = mutableSetOf<String>()

    for (item in other) {
        val maxStack = gameDefinition.getMaxStackOfItem(item.type)

        // item already hit the max stack, add to result directly
        if (item.qty >= maxStack.toUInt()) {
            result.add(item)
            continue
        }

        // find item of same type and quantity still lower than maximum
        val existingItem = this.find { it.type == item.type && it.qty < maxStack.toUInt() }

        if (existingItem != null && existingItem.canStack(item)) {
            // both item's quantity are guaranteed to be lower than the max stack
            // adding two of them should only produce 2 unit maximum
            // (i.e., 99 + 99 = 198 (100, 98) if max stack = 100)
            val totalQty = existingItem.qty + item.qty

            // add first unit
            result.add(item.copy(qty = min(totalQty, maxStack.toUInt())))

            // add second unit if overflow
            val overflowCounts = totalQty.toInt() - maxStack
            if (overflowCounts > 0) {
                // regenerate UUID as it is a new item
                result.add(item.copy(id = UUID.new(), qty = overflowCounts.toUInt()))
            }
            alreadyCombined.add(existingItem.id)
        } else {
            // either no item is found, each of them are already at maximum amount, or they cannot stack
            // add to result directly
            result.add(item)
        }
    }

    for (item in this) {
        if (!alreadyCombined.contains(item.id)) {
            result.add(item)
        }
    }

    return result
}

fun List<Item>.stackOwnItems(def: GameDefinition): List<Item> {
    if (isEmpty()) return emptyList()

    val stacked = mutableListOf<Item>()

    // Group all items that can stack using a single pass
    val grouped = groupBy { item ->
        "${item.type}|${item.level}|${item.quality}|${item.mod1}|${item.mod2}|${item.mod3}|${item.bind}"
    }

    // For each group, merge and split according to maxStack
    for ((_, group) in grouped) {
        val base = group.first()
        val maxStack = def.getMaxStackOfItem(base.type).toUInt()

        if (maxStack <= 1u) {
            // Non-stackable item, each instance remains unique
            stacked.addAll(group)
            continue
        }

        // Sum quantities and create stacks in one pass
        var remaining = group.sumOf { it.qty.toLong() }.toUInt()
        while (remaining > 0u) {
            val stackQty = minOf(remaining, maxStack)
            stacked.add(base.copy(id = UUID.new(), qty = stackQty, new = true))
            remaining -= stackQty
        }
    }

    return stacked
}

/**
 * Check if two items can be stacked together
 */
fun Item.canStack(other: Item): Boolean {
    return this.type == other.type &&
            this.level == other.level &&
            this.quality == other.quality &&
            this.mod1 == other.mod1 &&
            this.mod2 == other.mod2 &&
            this.mod3 == other.mod3 &&
            this.bind == other.bind
}
