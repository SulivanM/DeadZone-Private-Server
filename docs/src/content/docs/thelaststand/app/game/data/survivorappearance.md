---
title: SurvivorAppearance
slug: thelaststand/app/game/data/survivorappearance
description: SurvivorAppearance
---

SurvivorAppearance class

## Object structure

```scala
data SurvivorAppearance

// local properties and extends
// humanAppearance: HumanAppearance!
// survivor: Survivor!
// activeLoadout: SurvivorLoadout!

skinColor: String?
upper: String?
lower: String?
hair: String?
facialHair: String?
hairColor: String?
forceHair: Boolean = false
hideGear: Boolean = false

```

## Constants

```scala
enum SurvivorAppearanceConstants

SLOT_UPPER_BODY: String = "clothing_upper"
SLOT_LOWER_BODY: String = "clothing_lower"

```
