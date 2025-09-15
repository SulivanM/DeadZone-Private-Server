---
title: Building
slug: thelaststand/app/game/data/building
description: Building
---

Building class

## Object structure

```scala
data Building

id: String!
name: String? = null
type: String! // junk for JunkBuilding
level: Int!
rotation: Int!
tx: Int!
ty: Int!
destroyed: Boolean!
resourceValue: Double = 0.0
upgrade: TimerData?
repair: TimerData?

```
