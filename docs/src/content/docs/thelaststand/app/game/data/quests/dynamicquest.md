---
title: DynamicQuest
slug: thelaststand/app/game/data/quests/dynamicquest
description: DynamicQuest
---

DynamicQuest class

## Object structure

```scala
data DynamicQuest

raw: ByteArray! // see DynamicQuest.as for detail of structure

quest: Quest! // inherited

questType: Int! // DynamicQuestType
accepted: Boolean!
goals: List<DynamicQuestGoal> = []
rewards: List<DynamicQuestReward> = []
failurePenalties: List<DynamicQuestPenalty> = []

```

## Custom Definition

```scala
enum DynamicQuestType

SURVIVOR_REQUEST: Int = 0
```

```scala
data DynamicQuestGoal

type: DynamicQuestGoalEnum!
stat: String?
survivor: String?
goal: Int!
```

```scala
enum DynamicQuestGoalEnum

statInc: String = "statInc"
xpInc: String = "xpInc"
```

```scala
data DynamicQuestPenalty

type: DynamicQuestPenaltyEnum!
value: Any!
moraleType: MoraleConstants? // Only if type == "morale"
```

```scala
enum DynamicQuestPenaltyEnum

morale: String = "morale"
```

```scala
data DynamicQuestReward

type: DynamicQuestRewardEnum!
value: String! // some are string and int
moraleType: MoraleConstants? // Only if type == "morale"
```

```scala
enum DynamicQuestRewardEnum

xp: String = "xp"
itm: String = "itm"
morale: String = "morale"
```
