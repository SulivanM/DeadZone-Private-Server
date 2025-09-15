---
title: InfectedBounty
slug: thelaststand/app/game/data/bounty/infectedbounty
description: InfectedBounty
---

InfectedBounty class

## Object structure

```scala
data InfectedBounty

id: String!
completed: Boolean!
abandoned: Boolean!
viewed: Boolean!
rewardItemId: String!
issueTime: Long!
tasks: List<InfectedBountyTask> = []

```
