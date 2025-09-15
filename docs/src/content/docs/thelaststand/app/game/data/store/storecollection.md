---
title: StoreCollection
slug: thelaststand/app/game/data/store/storecollection
description: StoreCollection
---

StoreCollection class

## Object structure

```scala
data StoreCollection

// based on param2 DatabaseObject

key: String!
admin: Boolean = false
new: Boolean = false
individualPurchases: Boolean = true
levelMin: Int = 0
levelMax: Int = 2147483647
start: Long?
end: Long?
items: List<String> = []
PriceCoins: Int = 0
PriceUSD: Int = 0
PriceKKR: Int = 0

```
