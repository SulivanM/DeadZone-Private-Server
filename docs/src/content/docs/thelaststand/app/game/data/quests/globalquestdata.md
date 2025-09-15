---
title: GlobalQuestData
slug: thelaststand/app/game/data/quests/globalquestdata
description: GlobalQuestData
---

GlobalQuestData class

## Object structure

```scala
data GlobalQuestData

raw: ByteArray!
map: Map<String, GQDataObj> = {}

```

## Custom Definition

```scala
data GQDataObj

id: String!
collected: Boolean!
contributed: Boolean!
contributedLevel: Int!
statValues: List<UInt> = []

```
