---
title: ItemAttributes
slug: thelaststand/app/game/data/itemattributes
description: ItemAttributes
---

ItemAttributes class

## Object structure

```scala
data ItemAttributes

baseValues: Map<String, Map<String, Double>> = {}
modValues: Map<String, Map<String, Double>> = {}
attCaps: Map<String, Map<String, Double>> = {}

```

## Constants

```scala
enum ItemAttributesConstants

// ItemAttributeGroup (from _allGroups)
GEAR: String = "gear"
SURVIVOR: String = "srv"
WEAPON: String = "weap"

// ItemAdditionAttributes (from _additionAttributes)
CARRY: String = "carry"
EQUIP: String = "equip"
INFECTED_KILL_XP: String = "infected_kill_xp"
SURVIVOR_KILL_XP: String = "survivor_kill_xp"
HUMAN_KILL_XP: String = "human_kill_xp"

// ItemIgnoredAttributes (from _ignoreAttributes)
CLS: String = "cls"
TYPE: String = "type"
AMMO: String = "ammo"
ANIM: String = "anim"
SND: String = "snd"
SWING: String = "swing"
PROJ: String = "proj"
RLDANIM: String = "rldanim"
EXP: String = "exp"

// ItemLowMods (from _lowMods)
NOISE: String = "noise"
RATE: String = "rate"
RLDTIME: String = "rldtime"
AMMO_COST: String = "ammo_cost"
INJURY_CHANCE: String = "injuryChance"
RNG_MIN_EFF: String = "rng_min_eff"

// ItemReverseSignMods (from _reverseSignMods)
REVERSE_RATE: String = "rate"
REVERSE_RLDTIME: String = "rldtime"

```
