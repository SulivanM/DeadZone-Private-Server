---
title: AllianceData
slug: thelaststand/app/game/data/alliance/alliancedata
description: AllianceData
---

AllianceData class

## Object structure

```scala
data AllianceData

allianceDataSummary: AllianceDataSummary!
members: AllianceMemberList?
messages: AllianceMessageList?
enemies: AllianceList?
ranks: Map<String, Int>?
bannerEdits: Int!
effects: List<Effect>?
tokens: Int?
taskSet: Int?
tasks: Map<Int, Int>?
attackedTargets: Map<String, TargetRecord>?
scoutedTargets: Map<String, TargetRecord>?

```
