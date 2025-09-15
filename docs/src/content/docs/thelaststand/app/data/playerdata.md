---
title: PlayerData
slug: thelaststand/app/data/playerdata
description: PlayerData
---

PlayerData class

## Object structure

```scala
data PlayerData

key: String!
user: Map<String, AbstractUser> = {}
admin: Boolean!
allianceId: String!              // from loginPlayerState
allianceTag: String!             // from loginPlayerState
flags: ByteArray?                // deserialized to FlagSet
upgrades: ByteArray?             // from loginPlayerState, deserialized to FlagSet
nickname: String!
playerSurvivor: String!
levelPts: UInt = 0
restXP: Int = 0
oneTimePurchases: List<String> = []
neighbors: Map<String, RemotePlayerData>?
friends: Map<String, RemotePlayerData>?
neighborHistory: Map<String, RemotePlayerData>?     // from API 85 loadobject
research: ResearchState?
skills: Map<String, SkillState>?
resources: GameResources!
survivors: List<Survivor>!
playerAttributes: Attributes!
buildings: List<Building>!
rally: Map<String, List<String>>? // key building id, value list of survivor ids
tasks: List<Task>!
missions: List<MissionData>?
assignments: List<AssignmentData>?
inventory: Inventory?           // from API 85 loadobject
effects: Map<String, String>?
globalEffects: Map<String, String>?
cooldowns: Map<String, ByteArray>?    // bytearray parsed to Cooldown
batchRecycles: List<BatchRecycleJob>?
offenceLoadout: Map<String, SurvivorLoadoutEntry?>?
defenceLoadout: Map<String, SurvivorLoadoutEntry?>?
quests: ByteArray?              // parsed by booleanArrayFromByteArray
questsCollected: ByteArray?     // parsed by booleanArrayFromByteArray
achievements: ByteArray?        // parsed by booleanArrayFromByteArray
dailyQuest: DynamicQuest?
questsTracked: String?          // each quest separated with |
gQuestsV2: Map<String, GQDataObj>?
bountyCap: Int!
lastLogout: Long?
dzBounty: InfectedBounty?
nextDZBountyIssue: Long!
highActivity: HighActivity?           // unknown which class is this so we make custom class
invsize: Int!                  // from loginPlayerState

// below are PlayerData definitions known from Network.as
zombieAttack: Boolean!
zombieAttackLogins: Int!
offersEnabled: Boolean!
prevLogin: PrevLogin?
lastLogin: Long?
notifications: List<Notification?>?
```

### Custom Definition

```scala
data AbstractUser

data: UserData!
email: String!
time: Long!
defaultCurrency: String! // Currency constants

```

```scala
data PlayerIOUser

abstractUser: AbstractUser!
profile: PublishingNetworkProfile!

```

```scala
data PublishingNetworkProfile

userId: String!
displayName: String!
avatarUrl: String!
lastOnline: Long!
countryCode: String!

```

```scala
data UserData

email: String!

```

```scala
data HighActivity

buildings: List<String>! // building ids

```

```scala
data PrevLogin

date: Long!

```
