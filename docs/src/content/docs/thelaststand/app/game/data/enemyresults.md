---
title: EnemyResults
slug: thelaststand/app/game/data/enemyresults
description: EnemyResults
---

EnemyResults class

## Object structure

```scala
data EnemyResults

attackerId: String!
attackerNickname: String!
numSrvDown: Int = 0
survivors: List<String> = [] // survivor ids
srvDown: List<String> = [] // survivor ids
loot: List<Item> = []
prodBuildingsRaided: List<String> = [] // building ids
buildingsDestroyed: List<String> = [] // building ids
trapsTriggered: List<String> = [] // building ids
trapsDisarmed: List<String> = [] // building ids
totalBuildingsLooted: Int?

```
