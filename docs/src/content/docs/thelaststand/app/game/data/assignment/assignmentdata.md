---
title: AssignmentData
slug: thelaststand/app/game/data/assignment/assignmentdata
description: AssignmentData
---

AssignmentData class

## Object structure

```scala
data AssignmentData

name: String!
id: String!
started: Boolean!
competed: Boolean!
stageindex: Int!
survivors: List<String> = [] // survivor ids
stagelist: List<AssignmentStageData> = []

```
