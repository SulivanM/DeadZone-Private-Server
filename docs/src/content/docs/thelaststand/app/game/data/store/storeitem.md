---
title: StoreItem
slug: thelaststand/app/game/data/store/storeitem
description: StoreItem
---

StoreItem class

## Object structure

```scala
data StoreItem

// based on param1 DatabaseObject

key: String!
item: Item!
new: Boolean!
deal: Boolean!
promo: Boolean!
collectionOnly: Boolean!
admin: Boolean!
sale: String?
priority: Int!
levelMin: Int = 0
levelMax: Int = 2147483647
start: Long?
end: Long?
PriceCoins: Int? // pricecoins else usd or kkr
priceUSD: Double?
priceKKR: Int?
orgPriceFUEL: Int?
orgPriceUSD: Int?
orgPriceKKR: Int?
showOrgPrice: Boolean!

```
