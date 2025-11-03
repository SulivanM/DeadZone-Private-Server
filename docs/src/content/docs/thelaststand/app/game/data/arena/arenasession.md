---
title: ArenaSession
slug: thelaststand/app/game/data/arena/arenasession
description: Persistent arena session data tracking player progress and XP
---

# ArenaSession

Represents a persistent arena session that tracks a player's progress and experience points across all arena stages.

## Object Structure

```scala
data ArenaSession

points: Int!                                    // Total accumulated XP/points for this arena
state: Map<String, AssignmentStageState> = {}  // Stage progression (LOCKED=0, ACTIVE=1, COMPLETE=2)
```

## Fields

### points
- **Type:** `Int!` (required)
- **Description:** Total accumulated experience points (XP) earned in this arena
- **Usage:**
  - Incremented after each successful arena stage completion
  - Used to calculate leaderboard rankings
  - Persisted to database in `PlayerObjectsTable` as JSON

### state
- **Type:** `Map<String, AssignmentStageState>`
- **Default:** `{}`
- **Description:** Maps stage IDs to their current state
- **Values:**
  - `LOCKED` (0) - Stage not yet unlocked
  - `ACTIVE` (1) - Stage currently available
  - `COMPLETE` (2) - Stage successfully completed

## Database Storage

Arena sessions are stored in the `PlayerObjectsTable`:
- **Key:** `playerId` (varchar, primary key)
- **Value:** JSON serialized `ArenaSession` object
- **Format:**
  ```json
  {
    "points": 1500,
    "state": {
      "stage_1": 2,
      "stage_2": 2,
      "stage_3": 1,
      "stage_4": 0
    }
  }
  ```

## XP Calculation

Arena XP is calculated from:
1. **Survivor Points** (`srvpoints`) - Points awarded based on survivors used
2. **Objective Points** (`objpoints`) - Points for completing objectives
3. **Total:** `points = srvpoints + objpoints`

## Leaderboard Integration

The `points` field determines leaderboard rankings:
- Players with higher `points` rank higher
- Top players per arena level receive broadcast notifications
- Leader (rank #1) triggers `ARENA_LEADER` broadcast
- Top 10 trigger `ARENA_LEADERBOARD` broadcast

## Usage Example

```kotlin
import core.model.game.data.arena.ArenaSession
import core.model.game.data.assignment.AssignmentStageState

// Create new arena session
val session = ArenaSession(
    points = 0,
    state = mapOf(
        "stage_1" to AssignmentStageState.ACTIVE,
        "stage_2" to AssignmentStageState.LOCKED
    )
)

// Update points after stage completion
val earnedPoints = 500
val updatedSession = session.copy(
    points = session.points + earnedPoints,
    state = session.state + ("stage_1" to AssignmentStageState.COMPLETE)
)
```

## Related

- [ArenaSystem](./arenasystem) - Single arena run result data
- [ArenaStageData](./arenastagedata) - Individual stage configuration
- [Broadcast System](/broadcast-system) - Arena event notifications
- [Assignment Types](../assignment/assignmenttype) - Arena as assignment type
