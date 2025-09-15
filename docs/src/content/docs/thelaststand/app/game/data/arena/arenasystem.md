---
title: ArenaSystem
slug: thelaststand/app/game/data/arena/arenasystem
description: ArenaSystem
---

ArenaSystem class

## Object structure

```scala
data ArenaSystem

// from handleMissionResult method
id: String! // cased to ArenaSession, so must be one of the AssignmentType enum
srvcount: Int!
srvpoints: Int!
objpoints: Int!
completed: Boolean!
points: Int!
stage: Int!
returnsurvivors: List<String> = [] // survivor ids
cooldown: CooldownCollection = CooldownCollection()
assignsuccess: Boolean!
items: List<Item> = []

```
