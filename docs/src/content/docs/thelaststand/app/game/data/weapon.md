---
title: Weapon
slug: thelaststand/app/game/data/weapon
description: Weapon
---

Weapon class

## Object structure

```scala
data Weapon

attachments: List<String>!
burstFire: Boolean!
injuryCause: InjuryCause!
weaponClass: WeaponClass!
animType: String!
reloadAnim: String!
swingAnims: List<String>!
playSwingExertionSound: Boolean = true
flags: UInt = 0
weaponType: UInt = 0
ammoType: UInt = 0
survivorClasses: List<String> = []

```
