---
title: Broadcast System
slug: broadcast-system
description: Server-side broadcast system for real-time game events
---

# Broadcast System

The broadcast system provides real-time notifications to all connected clients about significant game events such as achievements, arena victories, raid completions, and more.

## Architecture

### Components

- **BroadcastService** (`server.broadcast.BroadcastService`) - Singleton service managing all broadcasts
- **BroadcastProtocol** (`server.broadcast.BroadcastProtocol`) - Enumeration of broadcast protocol codes
- **BroadcastMessage** (`server.broadcast.BroadcastMessage`) - Data class for broadcast messages
- **BroadcastServer** (`dev.deadzone.socket.core.BroadcastServer`) - Low-level socket server

### Configuration

The broadcast system is configured in `application.yaml`:

```yaml
broadcast:
  enabled: true
  host: 0.0.0.0
  ports: 2121,2122,2123
  enablePolicyServer: true

policy:
  host: 0.0.0.0
  port: 843
```

## Broadcast Protocols

All broadcast protocols match the client-side `BroadcastSystemProtocols` class.

### Message Format

Wire format: `protocol:arg1|arg2|arg3\0`

Example: `arenalb:playerName|arena1|5|1500\0`

### Available Protocols

| Protocol | Code | Parameters | Description |
|----------|------|------------|-------------|
| **STATIC** | `static` | - | Static/random messages |
| **ADMIN** | `admin` | `text` | Administrative announcements |
| **WARNING** | `warn` | `text` | Warning messages |
| **SHUT_DOWN** | `shtdn` | `minutes`, `time`, `reason` | Server shutdown notification |
| **ITEM_UNBOXED** | `itmbx` | `playerName`, `itemJson` | Item unboxed from crate |
| **ITEM_FOUND** | `itmfd` | `playerName`, `itemJson` | Item found during mission |
| **ITEM_CRAFTED** | `crft` | `playerName`, `itemJson` | Item crafted |
| **RAID_ATTACK** | `raid` | `playerName` | Player raiding another base |
| **RAID_DEFEND** | `def` | `playerName` | Player defending their base |
| **ACHIEVEMENT** | `ach` | `playerName`, `achievementId`, `type` | Achievement unlocked |
| **USER_LEVEL** | `lvl` | `playerName`, `level` | Player leveled up |
| **SURVIVOR_COUNT** | `srvcnt` | `playerName`, `count` | Survivor count milestone |
| **ZOMBIE_ATTACK_FAIL** | `zfail` | `playerName` | All survivors died in zombie attack |
| **ALL_INJURED** | `injall` | `playerName`, `suburbId` | All survivors injured |
| **BOUNTY_ADD** | `badd` | `playerName`, `targetName`, `amount` | Bounty added |
| **BOUNTY_COLLECTED** | `bcol` | `collectorName`, `targetName`, `amount` | Bounty collected |
| **ALLIANCE_RAID_SUCCESS** | `ars` | `allianceName`, `targetName` | Alliance raid succeeded |
| **ALLIANCE_RANK** | `arank` | `allianceName`, `rank` | Alliance rank changed |
| **ARENA_LEADER** | `arena_ldr` | `playerName`, `arenaName`, `level`, `points` | Player became arena leader |
| **ARENA_LEADERBOARD** | `arenalb` | `playerName`, `arenaName`, `level`, `points` | Player entered arena leaderboard |
| **RAIDMISSION_STARTED** | `rmstart` | `playerName`, `missionName` | Raid mission started |
| **RAIDMISSION_COMPLETE** | `rmcompl` | `playerName`, `missionName` | Raid mission completed |
| **RAIDMISSION_FAILED** | `rmfail` | `playerName`, `missionName` | Raid mission failed |
| **HAZ_SUCCESS** | `hazwin` | `playerName` | HAZ mission succeeded |
| **HAZ_FAIL** | `hazlose` | `playerName` | HAZ mission failed |
| **PLAIN_TEXT** | `plain` | `text` | Plain text message |

## Usage Examples

### Basic Broadcasting

```kotlin
import server.broadcast.BroadcastService

// Simple text broadcast
BroadcastService.broadcastPlainText("Server maintenance in 10 minutes")

// Administrative announcement
BroadcastService.broadcastAdmin("New features deployed!")

// Warning message
BroadcastService.broadcastWarning("High server load detected")
```

### Arena Events

```kotlin
// When a player enters the arena leaderboard
BroadcastService.broadcastArenaLeaderboard(
    playerName = "PlayerOne",
    arenaName = "arena_wasteland",
    level = 5,        // 0-based level (displayed as level+1 on client)
    points = 1500
)

// When a player becomes the #1 arena leader
BroadcastService.broadcastArenaLeader(
    playerName = "PlayerOne",
    arenaName = "arena_wasteland",
    level = 5,
    points = 2000
)
```

### Item Events

```kotlin
// Item found during mission
BroadcastService.broadcastItemFound(
    playerName = "PlayerOne",
    itemName = "legendary_rifle",
    quality = "legendary"
)

// Item crafted
BroadcastService.broadcastItemCrafted(
    playerName = "PlayerOne",
    itemName = "med_kit"
)
```

### Player Events

```kotlin
// Player leveled up
BroadcastService.broadcastUserLevel(
    playerName = "PlayerOne",
    level = 50
)

// Achievement unlocked
BroadcastService.broadcastAchievement(
    playerName = "PlayerOne",
    achievementName = "first_blood"
)
```

### Raid Events

```kotlin
// Raid mission started
BroadcastService.broadcastRaidMissionStarted(
    playerName = "PlayerOne",
    missionName = "raid_military_base"
)

// Raid mission completed
BroadcastService.broadcastRaidMissionComplete(
    playerName = "PlayerOne",
    missionName = "raid_military_base"
)
```

## Arena System Integration

### Arena XP and Leaderboard

Arena XP (experience points) is tracked in the `ArenaSession.points` field. When players complete arena stages:

1. **Points Calculation** - Points are calculated based on:
   - Survivor points (`srvpoints`) - Points for survivors used
   - Objective points (`objpoints`) - Points for objectives completed
   - Total: `points = srvpoints + objpoints`

2. **Leaderboard Updates** - When arena points are updated:
   - Compare player's points to current leaderboard
   - If player enters top rankings → Broadcast `ARENA_LEADERBOARD`
   - If player becomes #1 → Broadcast `ARENA_LEADER`

3. **Database Storage** - Arena data is stored in:
   - **Table:** `PlayerObjectsTable`
   - **Structure:** `playerId` → JSON serialized `ArenaSession`
   - **Fields:** `points` (total XP), `state` (stage progression)

### Example Implementation

```kotlin
suspend fun handleArenaFinish(
    playerId: String,
    arenaName: String,
    level: Int,
    points: Int
) {
    // Update arena session
    val session = getArenaSession(playerId, arenaName)
    val newPoints = session.points + points

    // Save to database
    saveArenaSession(playerId, arenaName, session.copy(points = newPoints))

    // Get leaderboard position
    val leaderboard = getArenaLeaderboard(arenaName, level)
    val playerPosition = calculatePosition(leaderboard, playerId, newPoints)

    // Broadcast based on position
    when {
        playerPosition == 1 && wasNotLeaderBefore -> {
            BroadcastService.broadcastArenaLeader(
                playerName = getPlayerName(playerId),
                arenaName = arenaName,
                level = level,
                points = newPoints
            )
        }
        playerPosition <= 10 -> {
            BroadcastService.broadcastArenaLeaderboard(
                playerName = getPlayerName(playerId),
                arenaName = arenaName,
                level = level,
                points = newPoints
            )
        }
    }
}
```

## Arena XP Database Verification

### Current Status

✅ **Data Models Exist**
- `ArenaSession.points: Int` - Stores total arena XP
- `ArenaSystem.points: Int` - Stores points from arena run
- `ArenaStageData.srvpoints/objpoints` - Stage-level point tracking

❌ **Handlers Not Implemented**
- `SaveDataMethod.ARENA_START` - [not implemented]
- `SaveDataMethod.ARENA_FINISH` - [not implemented]
- `SaveDataMethod.ARENA_LEADER` - [not implemented]
- `SaveDataMethod.ARENA_LEADERBOARD` - [not implemented]

### Required Implementation

To fully implement arena XP tracking:

1. **Implement `ArenaSaveHandler.ARENA_FINISH`**
   ```kotlin
   SaveDataMethod.ARENA_FINISH -> {
       val points = data["points"] as Int
       val arenaName = data["name"] as String
       val level = data["level"] as Int

       // Update player's arena session
       updateArenaSession(playerId, arenaName, points)

       // Update leaderboard and broadcast
       updateLeaderboard(playerId, arenaName, level, points)
   }
   ```

2. **Implement `ArenaSaveHandler.ARENA_LEADERBOARD`**
   ```kotlin
   SaveDataMethod.ARENA_LEADERBOARD -> {
       val arenaName = data["name"] as String
       val level = data["level"] as Int

       // Query leaderboard from database
       val leaderboard = queryArenaLeaderboard(arenaName, level)

       // Return top players
       respond(leaderboard)
   }
   ```

3. **Implement `ArenaSaveHandler.ARENA_LEADER`**
   ```kotlin
   SaveDataMethod.ARENA_LEADER -> {
       val arenaName = data["name"] as String
       val level = data["level"] as Int

       // Query current leader
       val leader = queryArenaLeader(arenaName, level)

       // Return leader info
       respond(leader)
   }
   ```

## Client-Side Integration

### ActionScript Protocol Constants

The client defines protocols in `BroadcastSystemProtocols.as`:

```actionscript
public static const ARENA_LEADER:String = "arena_ldr";
public static const ARENA_LEADERBOARD:String = "arenalb";
```

### Message Handling

Client processes broadcasts in `BroadcastDisplay.onMessageReceived()`:

```actionscript
case BroadcastSystemProtocols.ARENA_LEADERBOARD:
    var username:String = param2[0];
    var arenaName:String = param2[1];
    var level:int = int(param2[2]);
    var points:int = int(param2[3]);

    // Display formatted message
    message = message.replace("%user", "<span class='user'>" + username + "</span>");
    message = message.replace("%arenaname", "<span class='highlight'>" + arenaName + "</span>");
    message = message.replace("%level", "<span class='highlight'>" + (level + 1) + "</span>");
    message = message.replace("%points", "<span class='highlight'>" + points + "</span>");
```

**Note:** Level is 0-based on server, displayed as `level + 1` on client.

## Technical Details

### Initialization

The broadcast service is initialized in `Application.kt`:

```kotlin
BroadcastService.initialize(broadcastServer)
```

### Concurrency

All broadcast methods are `suspend` functions and should be called from coroutines:

```kotlin
launch {
    BroadcastService.broadcastArenaLeader("PlayerOne", "arena1", 5, 2000)
}
```

### Error Handling

The broadcast system logs warnings if broadcasting is disabled:

```kotlin
suspend fun broadcast(message: BroadcastMessage) {
    if (!enabled) {
        Logger.warn { "Broadcast is not enabled" }
    }
    broadcastServer.broadcast(message)
}
```

## Testing

To test broadcasts, you can use the admin console or create test handlers:

```kotlin
// Test arena leader broadcast
BroadcastService.broadcastArenaLeader(
    playerName = "TestPlayer",
    arenaName = "arena_wasteland",
    level = 0,
    points = 1000
)
```

## Related Documentation

- [Arena System](thelaststand/app/game/data/arena/arenasystem)
- [Arena Session](thelaststand/app/game/data/arena/arenasession)
- [Save Data Methods](architecture#save-data-methods)
- [Server Architecture](architecture)
