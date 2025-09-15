---
title: SurvivorClass
slug: thelaststand/app/game/data/survivorclass
description: SurvivorClass
---

SurvivorClass class

## Object structure

```scala
data SurvivorClass

id: String!
maleUpper: String!
maleLower: String!
maleSkinOverlay: String?
femaleUpper: String!
femaleLower: String!
femaleSkinOverlay: String?
baseAttributes: Attributes!
levelAttributes: Attributes!
hideHair: Boolean = false
weapons: List<SurvivorClassWeapons>

```

## Constants

```scala
enum SurvivorClassConstants

FIGHTER: String = "fighter"
MEDIC: String = "medic"
SCAVENGER: String = "scavenger"
ENGINEER: String = "engineer"
RECON: String = "recon"
PLAYER: String = "player"
UNASSIGNED: String = "unassigned"

```
