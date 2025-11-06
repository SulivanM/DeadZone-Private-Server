---
title: ArenaSystem
slug: thelaststand/app/game/data/arena/arenasystem
description: Single arena run result data with points and rewards
---

# ArenaSystem

Represents the result data from a single arena run, including points earned, survivors, and loot rewards.

## Object Structure

```scala
data ArenaSystem

id: String!                             // Arena type, must be from AssignmentType enum ("Arena")
srvcount: Int!                          // Number of survivors that participated
srvpoints: Int!                         // Points earned from survivors
objpoints: Int!                         // Points earned from objectives
completed: Boolean!                     // Whether the arena stage was completed
points: Int!                            // Total points earned (srvpoints + objpoints)
stage: Int!                             // Stage number completed
returnsurvivors: List<String> = []      // IDs of survivors returning from arena
cooldown: CooldownCollection = CooldownCollection()  // Cooldown data
assignsuccess: Boolean!                 // Whether the assignment was successful
items: List<Item> = []                  // Loot items earned from completion
```

## Fields

### id
- **Type:** `String!` (required)
- **Description:** Arena assignment type identifier
- **Value:** Must be `"Arena"` (from `AssignmentType` enum)
- **Usage:** Used to cast result to `ArenaSession`

### srvcount
- **Type:** `Int!` (required)
- **Description:** Number of survivors that participated in this arena run
- **Usage:** Affects point calculations and rewards

### srvpoints
- **Type:** `Int!` (required)
- **Description:** Points earned based on survivor performance
- **Calculation:** Based on survivors used, their stats, and performance

### objpoints
- **Type:** `Int!` (required)
- **Description:** Points earned from completing arena objectives
- **Calculation:** Based on objectives completed and difficulty

### completed
- **Type:** `Boolean!` (required)
- **Description:** Whether the arena stage was successfully completed
- **Values:**
  - `true` - Stage completed, points awarded
  - `false` - Stage failed or aborted

### points
- **Type:** `Int!` (required)
- **Description:** Total points earned from this arena run
- **Calculation:** `points = srvpoints + objpoints`
- **Usage:** Added to `ArenaSession.points` for leaderboard ranking

### stage
- **Type:** `Int!` (required)
- **Description:** The stage number that was completed
- **Range:** Depends on arena configuration (typically 1-10+)

### returnsurvivors
- **Type:** `List<String>`
- **Default:** `[]`
- **Description:** IDs of survivors that survived and returned from the arena
- **Usage:** Used to update survivor states and remove casualties

### cooldown
- **Type:** `CooldownCollection`
- **Default:** `CooldownCollection()`
- **Description:** Cooldown data for arena re-entry
- **Usage:** Prevents immediate re-runs of the same arena

### assignsuccess
- **Type:** `Boolean!` (required)
- **Description:** Overall success status of the arena assignment
- **Values:**
  - `true` - Assignment completed successfully
  - `false` - Assignment failed

### items
- **Type:** `List<Item>`
- **Default:** `[]`
- **Description:** Loot items earned as rewards from arena completion
- **Usage:** Added to player's inventory

## Points System

### Point Calculation

Arena points are calculated from two sources:

1. **Survivor Points (`srvpoints`)**
   - Based on number of survivors used
   - Survivor level and stats affect points
   - Better performance = more points

2. **Objective Points (`objpoints`)**
   - Based on objectives completed
   - Difficulty multipliers apply
   - Bonus points for perfect completion

3. **Total Points (`points`)**
   ```kotlin
   points = srvpoints + objpoints
   ```

### XP Accumulation

After each arena run:
1. `ArenaSystem.points` is calculated from the run
2. Points are added to `ArenaSession.points`
3. Leaderboard rankings are updated
4. Broadcasts are sent if player enters top rankings

## Usage Example

```kotlin
import core.model.game.data.arena.ArenaSystem
import core.model.game.data.assignment.AssignmentType

// Create arena result
val arenaResult = ArenaSystem(
    id = AssignmentType.Arena,
    srvcount = 5,
    srvpoints = 300,
    objpoints = 200,
    completed = true,
    points = 500,  // 300 + 200
    stage = 1,
    returnsurvivors = listOf("survivor_1", "survivor_2", "survivor_3"),
    cooldown = CooldownCollection(),
    assignsuccess = true,
    items = listOf(/* reward items */)
)

// Process arena result
suspend fun processArenaResult(playerId: String, result: ArenaSystem) {
    // Update arena session with new points
    val session = getArenaSession(playerId)
    val newSession = session.copy(
        points = session.points + result.points
    )
    saveArenaSession(playerId, newSession)

    // Update leaderboard
    updateLeaderboard(playerId, result.points)

    // Send broadcast if top ranking
    if (isTopRanked(playerId)) {
        BroadcastService.broadcastArenaLeaderboard(
            playerName = getPlayerName(playerId),
            arenaName = "arena_wasteland",
            level = result.stage,
            points = newSession.points
        )
    }
}
```

## Broadcast Integration

Based on arena results, broadcasts are triggered:

### ARENA_LEADERBOARD
- **Trigger:** Player enters top 10 rankings
- **Parameters:** `playerName`, `arenaName`, `level`, `points`
- **Example:**
  ```kotlin
  BroadcastService.broadcastArenaLeaderboard(
      playerName = "PlayerOne",
      arenaName = "arena_wasteland",
      level = 5,
      points = 1500
  )
  ```

### ARENA_LEADER
- **Trigger:** Player becomes #1 leader
- **Parameters:** `playerName`, `arenaName`, `level`, `points`
- **Example:**
  ```kotlin
  BroadcastService.broadcastArenaLeader(
      playerName = "PlayerOne",
      arenaName = "arena_wasteland",
      level = 5,
      points = 2000
  )
  ```

## Related

- [ArenaSession](./arenasession) - Persistent arena progress and XP
- [ArenaStageData](./arenastagedata) - Stage configuration and requirements
- [Broadcast System](/broadcast-system) - Event notification system
- [Assignment Types](../assignment/assignmenttype) - Arena as assignment type
- [Item System](../item) - Arena loot rewards
