---
title: RaidStageData
slug: thelaststand/app/game/data/raid/raidstagedata
description: RaidStageData
---

RaidStageData class

## Object structure

```scala
data RaidStageData

assignmentStageData: AssignmentStageData!
objectiveIndex: Int!
objectiveState: RaidStageObjectiveState = RaidStageObjectiveState.INCOMPLETE
objectiveXML: String? // actually an XML type
imageURI: String!

```
