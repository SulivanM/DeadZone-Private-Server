---
title: CrateItem
slug: thelaststand/app/game/data/crateitem
description: CrateItem
---

CrateItem class

## Object structure

```scala
data CrateItem

type: String!
id: String = "" // uses GUID.create() by default
new: Boolean = false
storeId: String!
level: Int = 0
series: Int = 0
version: Int = 0
contents: List<Item>!

```
