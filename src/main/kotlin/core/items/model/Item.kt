@file:OptIn(ExperimentalSerializationApi::class)

package core.items.model

import core.data.GameDefinition
import core.model.game.data.CraftingInfo
import utils.UUID
import kotlinx.serialization.EncodeDefault
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.Serializable
import kotlin.math.min

@Serializable
data class Item(
    
    
    
    
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
    @EncodeDefault(EncodeDefault.Mode.NEVER) val duplicate: Boolean = false,  
)

fun Item.compactString(): String {
    return "Item(id=${this.id}, type=${this.type})"
}

fun Item.quantityString(): String {
    return "Item(type=${this.type}, qty=${this.qty})"
}

fun List<Item>.combineItems(other: List<Item>, gameDefinition: GameDefinition): List<Item> {
    val result = mutableListOf<Item>()
    val alreadyCombined = mutableSetOf<String>()

    for (item in other) {
        val maxStack = gameDefinition.getMaxStackOfItem(item.type)

        if (item.qty >= maxStack.toUInt()) {
            result.add(item)
            continue
        }

        val existingItem = this.find { it.type == item.type && it.qty < maxStack.toUInt() }

        if (existingItem != null && existingItem.canStack(item)) {
            
            
            
            val totalQty = existingItem.qty + item.qty

            result.add(item.copy(qty = min(totalQty, maxStack.toUInt())))

            val overflowCounts = totalQty.toInt() - maxStack
            if (overflowCounts > 0) {
                
                result.add(item.copy(id = UUID.new(), qty = overflowCounts.toUInt()))
            }
            alreadyCombined.add(existingItem.id)
        } else {
            
            
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

    val grouped = groupBy { item ->
        "${item.type}|${item.level}|${item.quality}|${item.mod1}|${item.mod2}|${item.mod3}|${item.bind}"
    }

    for ((_, group) in grouped) {
        val base = group.first()
        val maxStack = def.getMaxStackOfItem(base.type).toUInt()

        if (maxStack <= 1u) {
            
            stacked.addAll(group)
            continue
        }

        var remaining = group.sumOf { it.qty.toLong() }.toUInt()
        while (remaining > 0u) {
            val stackQty = minOf(remaining, maxStack)
            stacked.add(base.copy(id = UUID.new(), qty = stackQty, new = true))
            remaining -= stackQty
        }
    }

    return stacked
}

fun Item.canStack(other: Item): Boolean {
    return this.type == other.type &&
            this.level == other.level &&
            this.quality == other.quality &&
            this.mod1 == other.mod1 &&
            this.mod2 == other.mod2 &&
            this.mod3 == other.mod3 &&
            this.bind == other.bind
}
