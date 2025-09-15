---
title: Effect
slug: thelaststand/app/game/data/effects/effect
description: Effect
---

Effect class

## Object structure

```scala
data Effect

// usually parsed from raw bytearray
raw: ByteArray = []
type: String!
id: String!
lockTime: Int!
cooldownTime: Int!
started: Boolean = false
timer: TimerData?
lockoutTimer: TimerData?
effectList: List<EffectData> = []
itemId: String?

```
