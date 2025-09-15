---
title: Survivor
slug: thelaststand/app/game/data/survivor
description: Survivor
---

Survivor class

## Object structure

```scala
data Survivor

id: String!
title: String!
firstName: String = ""
lastName: String = ""
gender: String!       // Gender constants
portrait: String? = null
classId: String!      // SurvivorClass constants
morale: Map<String, Double> = {}
injuries: List<Injury> = []
level: Int!
xp: Int!
missionId: String?
assignmentId: String?
reassignTimer: TimerData?
appearance: HumanAppearance?
scale: Double = 1.22
voice: String!
accessories: Map<Int, String> // added from parseClothingAccessories of SurvivorLoadoutManager. string is accessory id
maxClothingAccessories: Int

```
