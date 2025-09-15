---
title: Quest
slug: thelaststand/app/game/data/quests/quest
description: Quest
---

Quest class

## Object structure

```scala
data Quest

id: String!
started: Boolean!
complete: Boolean!
conditionProgress: List<Int> = []
collected: Boolean!
index: Int!
important: Boolean!
startImageURI: String?
completeImageURI: String?
isAchievement: Boolean!
level: Int!
secretLevel: UInt = 0
type: String!
xml: String? // uses XML type actually
new: Boolean!
children: List<Quest> = []
startTime: Long?
endTime: Long?
failed: Boolean!
timeBased: Boolean!
visible: Boolean = true

```

## Constants

```scala
enum QuestConstants

SECRET_NONE: UInt = 0
SECRET_TITLE_ONLY: UInt = 1
SECRET_HIDDEN: UInt = 2
TYPE_ACHIEVEMENT: String = "achievement"
TYPE_GENERAL: String = "general"
TYPE_COMBAT: String = "combat"
TYPE_SCAVENGE: String = "scavenge"
TYPE_CONSTRUCTION: String = "construct"
TYPE_COMMUNITY: String = "community"
TYPE_WORLD: String = "world"
TYPE_DYNAMIC: String = "dynamic"
TRACKING_TRACKED: String = "tracked"
TRACKING_UNTRACKED: String = "untracked"
TRACKING_MAX_TRACKED: String = "maxTracked"

```
