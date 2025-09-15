---
title: AllianceDataSummary
slug: thelaststand/app/game/data/alliance/alliancedatasummary
description: AllianceDataSummary
---

AllianceDataSummary class

## Object structure

```scala
data AllianceDataSummary

allianceId: String?
name: String?
tag: String?
banner: String? // can also be bytearray. if a string, will try to decodeToByteArray
thumbURI: String?
memberCount: Int?
efficiency: Double?
points: Int?

```
