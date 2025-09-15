---
title: MissionData
slug: thelaststand/app/game/data/missiondata
description: MissionData
---

MissionData class

## Object structure

```scala
data MissionData

id: String!
player: SurvivorData!
stats: MissionStats?
xpEarned: Int!
xp: Map<String, Int> = {}
completed: Boolean!
assignmentId: String!
assignmentType: String!
playerId: String?
compound: Boolean!
areaLevel: Int!
areaId: String!
type: String!
suburb: String!
automated: Boolean!
survivors: List<String> = [] // survivor ids
srvDown: List<String> = [] // survivor ids
buildingsDestroyed: List<String> = [] // building ids
returnTimer: TimerData?
lockTimer: TimerData?
loot: List<Item> = []
highActivityIndex: Int?

```

## Constants

```scala
enum MissionDataConstants

DANGER_NORMAL: Int = 0
DANGER_LOW: Int = 0
DANGER_MODERATE: Int = 1
DANGER_DANGEROUS: Int = 2
DANGER_HIGH: Int = 3
DANGER_EXTREME: Int = 4

```
