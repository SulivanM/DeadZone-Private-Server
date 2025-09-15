---
title: SchematicItem
slug: thelaststand/app/game/data/schematicitem
description: SchematicItem
---

SchematicItem class

## Object structure

```scala
data SchematicItem

item: Item!
type: String!
schem: String!
id: String = ""      // actually default a GUID.create()
new: Boolean = false
storeId: String?

```
