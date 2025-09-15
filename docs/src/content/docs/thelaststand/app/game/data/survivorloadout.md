---
title: SurvivorLoadout
slug: thelaststand/app/game/data/survivorloadout
description: SurvivorLoadout
---

SurvivorLoadout class

## Object structure

```scala
data SurvivorLoadout

type: String!
survivor: Survivor!
weapon: SurvivorLoadoutData!
gearPassive: SurvivorLoadoutData!
gearActive: SurvivorLoadoutData!
supressChanges: Boolean = false

```

## Constants

```scala
enum SurvivorLoadoutConstants

SLOT_WEAPON: String = "weapon"
SLOT_GEAR_PASSIVE: String = "gearPassive"
SLOT_GEAR_ACTIVE: String = "gearActive"
TYPE_OFFENCE: String = "offence"
TYPE_DEFENCE: String = "defence"

```
