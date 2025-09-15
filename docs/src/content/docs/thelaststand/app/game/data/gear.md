---
title: Gear
slug: thelaststand/app/game/data/gear
description: Gear
---

Gear class

## Object structure

```scala
data Gear

// doesn't have deserialize, readobject or parse, but seem like an important class. properties are from local variables

item: Item!
_attireXMLInvalid:Boolean = false

animType: String = ""
attire: List<AttireData> = []
attireXMLList: List<String> = [] // List<XMLList> actually
gearType: UInt = 1
gearClass: String = ""
requiredSurvivorClass: String?
carryLimit: Int = 0
survivorClasses: List<String> = []
weaponClasses: List<String>  = []
weaponTypes: UInt = 0
ammoTypes: UInt = 0
activeAttributes: ItemAttributes!

```
