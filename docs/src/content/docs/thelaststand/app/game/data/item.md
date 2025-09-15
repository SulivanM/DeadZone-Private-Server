---
title: Item
slug: thelaststand/app/game/data/item
description: Item
---

Item class

## Object structure

```scala
data Item

id: String!
new: Boolean = false
storeId: String?
bought: Boolean = false
mod1: String?
mod2: String?
mod3: String?
type: String!
level: Int = 0
qty: UInt = 1
quality: Int?
bind: UInt?
tradable: Boolean?
disposable: Boolean?
ctrType: UInt?
ctrVal: Int?
craft: CraftingInfo?
name: String?
specData: ItemBonusStats?
duplicate: Boolean! // added from deserialize of Inventory

```
