---
title: StoreSale
slug: thelaststand/app/game/data/store/storesale
description: StoreSale
---

StoreSale class

## Object structure

```scala
data StoreSale

// based on param2 DatabaseObject

admin: Boolean!
savingPerc: Double!
levelMin: Int = 0
levelMax: Int = 2147483647
start: Long!
end: Long!
items: List<String>? // assigned to itemKeys, a list of string

```
