---
title: Task
slug: thelaststand/app/game/data/task
description: Task
---

Task class

## Object structure

```scala
data Task

id: String!
type: String!
length: Int!
time: Double!
items: List<Item>?
completed: Boolean!
survivors: List<String>! // survivor ids

```
