---
title: Morale
slug: thelaststand/app/game/data/morale
description: Morale
---

Morale class

## Object structure

```scala
data Morale

maps: Map<String, Double>! = {}

```

## Constants

```scala
enum MoraleConstants

EFFECT_INJURY: String = "injury"
EFFECT_MISSION_COMPLETE: String = "missionComplete"
EFFECT_FOOD: String = "food"
EFFECT_WATER: String = "water"
EFFECT_SECURITY: String = "security"
EFFECT_COMFORT: String = "comfort"
EFFECT_AVERAGE_SURVIVOR: String = "avgSurvivor"
EFFECT_DAILY_QUEST_COMPLETED: String = "dailyQuestCompleted"
EFFECT_DAILY_QUEST_FAILED: String = "dailyQuestFailed"

```
