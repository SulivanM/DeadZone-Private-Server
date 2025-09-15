@file:OptIn(ExperimentalSerializationApi::class)

package dev.deadzone.core.items.model

import dev.deadzone.core.model.game.data.CraftingInfo
import dev.deadzone.utils.UUID
import kotlinx.serialization.EncodeDefault
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.Serializable

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
