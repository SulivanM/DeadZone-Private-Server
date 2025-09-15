---
title: CompoundData
slug: thelaststand/app/game/data/compounddata
description: CompoundData
---

CompoundData class

## Object structure

```scala
data CompoundData

player: PlayerData?
buildings: BuildingCollection = BuildingCollection()
resources: GameResources = GameResources()
survivors: SurvivorCollection = SurvivorCollection()
tasks: TaskCollection = TaskCollection()
effects: EffectCollection = EffectCollection()
globalEffects: EffectCollection = EffectCollection()
morale: Morale = Morale()
moraleFilter: List<String> = ["food", "water", "security", "comfort"]

```
