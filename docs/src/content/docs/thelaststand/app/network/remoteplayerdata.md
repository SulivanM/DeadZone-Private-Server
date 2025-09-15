---
title: RemotePlayerData
slug: thelaststand/app/network/remoteplayerdata
description: RemotePlayerData
---

RemotePlayerData class

## Object structure

```scala
data RemotePlayerData

name: String?
nickname: String?
level: Int?
serviceUserId: String?
serviceAvatar: String?
serviceAvatarURL: String?
lastLogin: Long?
allianceId: String?
allianceTag: String?
allianceName: String?
bounty: Int?
bountyAllTime: Int?
bountyAllTimeCount: Int?
bountyEarnings: Int?
bountyCollectCount: Int?
bountyDate: Long?
online: Boolean?
onlineTimestamp: Long?
raidLockout: Long?
underAttack: Boolean?
protected: Boolean?
protected_start: Long?
protected_length: Int?
banned: Boolean?

```

## Constants

```scala
enum RemotePlayerDataConstants
      
RELATIONSHIP_FRIEND: String = "friend"
RELATIONSHIP_NEUTRAL: String = "neutral"
RELATIONSHIP_ENEMY: String = "enemy"

```
