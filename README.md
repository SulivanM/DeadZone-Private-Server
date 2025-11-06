# Recapturing The DeadZone

A complete private server revival for **The Last Stand: Dead Zone**, a multiplayer zombie survival game. This project recreates the game server from the ground up using modern technologies while maintaining compatibility with the original Flash client.

[![Discord](https://img.shields.io/discord/YOUR_DISCORD_ID?color=7289da&logo=discord&logoColor=white)](https://discord.gg/jFyAePxDBJ)
[![Java](https://img.shields.io/badge/Java-25-orange.svg)](https://www.oracle.com/java/technologies/downloads)
[![Kotlin](https://img.shields.io/badge/Kotlin-2.x-7F52FF.svg)](https://kotlinlang.org/)
[![MariaDB](https://img.shields.io/badge/MariaDB-11+-blue.svg)](https://mariadb.org/)
[![License](https://img.shields.io/badge/License-Community-green.svg)](#license)

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Quick Start](#quick-start)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Architecture](#architecture)
- [Development](#development)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [Community](#community)

## Overview

**The Last Stand: Dead Zone** was a browser-based multiplayer survival game where players built compounds, managed survivors, scavenged for supplies, and defended against zombie hordes. After the official servers shut down, this project aims to preserve and revive the game for the community.

This server implementation includes:
- **Complete game logic** - Missions, raids, arena battles, crafting, trading
- **Real-time broadcasts** - Global event notifications for achievements and milestones
- **Player persistence** - Full database integration for player progress
- **REST API** - Web endpoints for game management and statistics
- **Modern architecture** - Built with Kotlin, Ktor, and coroutines for performance

## Features

### Core Gameplay
- ✅ **Base Building** - Construct and upgrade compound buildings
- ✅ **Survivor Management** - Recruit, level up, and equip survivors
- ✅ **Mission System** - Story missions with rewards and progression
- ✅ **Raid System** - Attack other players' compounds
- ✅ **Arena Battles** - Competitive PvE challenges with leaderboards
- ✅ **Crafting & Trading** - Item crafting and player trading
- ✅ **Inventory System** - Weapons, armor, consumables, and loot
- ✅ **Quest System** - Achievements and daily/weekly quests

### Server Features
- ✅ **Player Authentication** - Secure login and session management
- ✅ **Database Persistence** - MariaDB storage for all game data
- ✅ **Real-time Broadcasts** - Global notifications for player achievements
- ✅ **REST API** - HTTP endpoints for game management
- ✅ **Socket Server** - Low-latency binary protocol for gameplay
- ✅ **Admin Commands** - Server administration and moderation tools
- ✅ **Configuration System** - YAML-based server configuration

### In Development
- 🚧 **Arena Leaderboards** - XP tracking and competitive rankings
- 🚧 **Alliance System** - Clan features and alliance raids
- 🚧 **Event System** - Timed events and special challenges

## Quick Start

Get up and running in 5 steps:

1. **Install Java 25** - [Download here](https://www.oracle.com/java/technologies/downloads)
2. **Setup MariaDB** - Use our [companion repository](https://github.com/SwitchCompagnie/Deadzone-Revive-Website-Game)
3. **Create Database** - Create a database named `prod_deadzone_game`
4. **Build Server** - Run `build.bat` (Windows) or `build.sh` (Linux/macOS)
5. **Launch** - Execute `autorun.bat` or `autorun.sh` from the `deploy` folder

Access the game at `http://127.0.0.1:8080`

> 💡 **Need help?** Join our [Discord community](https://discord.gg/jFyAePxDBJ)

## Requirements

- **Java 25** or higher
- **MariaDB 11+** (setup via [companion repository](https://github.com/SwitchCompagnie/Deadzone-Revive-Website-Game))
- **Gradle** (included via wrapper)

## Installation

### Database Setup

1. Start your MariaDB server
2. Create a new database:
   ```sql
   CREATE DATABASE prod_deadzone_game;
   ```
3. Tables will be automatically generated on first server startup

### Server Build

#### Windows
```bash
build.bat
```

#### Linux/macOS
```bash
chmod +x build.sh
./build.sh
```

The build artifacts will be placed in the `deploy` folder.

### Running the Server

#### Production Mode

Navigate to the `deploy` folder and run:

**Windows:**
```bash
autorun.bat
```

**Linux/macOS:**
```bash
chmod +x autorun.sh
./autorun.sh
```

#### Development Mode

From the project root:

```bash
./gradlew run
```

Or use the run scripts:
- Windows: `runserver.bat`
- Linux/macOS: `runserver.sh`

Alternatively, run the `main` function in `Application.kt` through your IDE.

## Configuration

Configuration is managed through `src/main/resources/application.yaml`

### Database Configuration

```yaml
maria:
  url: jdbc:mariadb://localhost:3306/prod_deadzone_game
  user: root
  password: ""
```

### Server Configuration

```yaml
game:
  host: 127.0.0.1
  port: 7777
  enableAdmin: false

broadcast:
  enabled: true
  host: 0.0.0.0
  ports: 2121,2122,2123
  enablePolicyServer: true

policy:
  host: 0.0.0.0
  port: 843
```

### Logging Configuration

```yaml
logger:
  level: 0  # 0=DEBUG, 1=INFO, 2=WARN, 3=ERROR
  colorful: true
```

### Environment Variables

Set environment variables for additional configuration:

**PowerShell (Windows):**
```powershell
$env:DEV_MODE = "false"
$env:ADMIN = "true"
java -jar deadzone-server.jar
```

**Bash (Linux/macOS):**
```bash
export DEV_MODE=false
export ADMIN=true
java -jar deadzone-server.jar
```

**Admin Account:**
- When `ADMIN=true`, an admin account `givemeadmin` is enabled

## Architecture

### Overview

The server is built using a modular architecture with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                        Client (Flash)                        │
└───────────────┬──────────────────────────┬──────────────────┘
                │                          │
        Socket Protocol              REST API (HTTP)
        (Binary Messages)            (JSON)
                │                          │
┌───────────────▼──────────────────────────▼──────────────────┐
│                     Ktor Server                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Socket Handler          │    API Routes               │ │
│  │  - Save handlers         │    - /api/account           │ │
│  │  - Message routing       │    - /api/stats             │ │
│  │  - Session management    │    - /api/leaderboard       │ │
│  └────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Game Logic Layer                                       │ │
│  │  - Mission system        - Crafting system             │ │
│  │  - Raid system           - Trading system              │ │
│  │  - Arena system          - Quest system                │ │
│  │  - Survivor management   - Building system             │ │
│  └────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Broadcast Service                                      │ │
│  │  - Real-time event notifications                        │ │
│  │  - Multi-port socket server (2121, 2122, 2123)         │ │
│  └────────────────────────────────────────────────────────┘ │
└────────────────────────────┬─────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │   MariaDB       │
                    │  - Player data  │
                    │  - Game state   │
                    │  - Leaderboards │
                    └─────────────────┘
```

### Project Structure

```
.
├── src/main/kotlin/
│   ├── api/                    # REST API endpoints
│   │   ├── routes/             # API route handlers
│   │   └── models/             # API request/response models
│   ├── core/                   # Core game logic
│   │   ├── model/              # Game data models
│   │   │   ├── game/           # Game entities (items, survivors, etc.)
│   │   │   └── user/           # User and authentication models
│   │   └── services/           # Business logic services
│   ├── data/                   # Database layer
│   │   ├── db/                 # Database implementation
│   │   └── repository/         # Data access repositories
│   ├── server/                 # Socket server
│   │   ├── handler/            # Message handlers
│   │   │   ├── save/           # Save data handlers
│   │   │   └── load/           # Load data handlers
│   │   ├── messaging/          # Protocol definitions
│   │   └── broadcast/          # Broadcast system
│   ├── user/                   # User management
│   │   ├── auth/               # Authentication logic
│   │   └── session/            # Session management
│   └── utils/                  # Utility functions
├── src/main/resources/
│   ├── application.yaml        # Server configuration
│   └── logback.xml            # Logging configuration
├── static/                     # Game assets
│   ├── game/                   # Game data files
│   │   ├── data/               # XML game definitions
│   │   └── img/                # Game images
│   └── maps/                   # Map data
├── docs/                       # Documentation
│   └── src/content/docs/       # Markdown documentation
├── deploy/                     # Build output
└── build.gradle.kts           # Build configuration
```

### Key Components

#### Socket Server
- **Port:** 7777 (configurable)
- **Protocol:** Binary message format
- **Features:**
  - Session-based authentication
  - Message routing to specialized handlers
  - Automatic serialization/deserialization

#### Broadcast System
- **Ports:** 2121, 2122, 2123 (configurable)
- **Protocol:** Text-based protocol with format `code:arg1|arg2|arg3\0`
- **Purpose:** Real-time notifications for all players
- **Events:** Arena victories, achievements, raids, level ups, etc.

#### Database Layer
- **ORM:** Exposed (JetBrains)
- **Connection Pool:** HikariCP
- **Migrations:** Automatic table creation on startup
- **Tables:**
  - `UsersTable` - User accounts and authentication
  - `PlayerDataTable` - Player game state
  - `PlayerObjectsTable` - Complex game objects (JSON)

#### REST API
- **Framework:** Ktor
- **Format:** JSON
- **Endpoints:**
  - `/api/account` - Account management
  - `/api/stats` - Player statistics
  - `/api/leaderboard` - Rankings and leaderboards

### Tech Stack

- **Language:** Kotlin 2.1
- **Server Framework:** Ktor 3.0
- **Coroutines:** kotlinx.coroutines (async/await patterns)
- **Database:** MariaDB 11+ with Exposed ORM
- **Serialization:** kotlinx.serialization (JSON, ProtoBuf)
- **Connection Pool:** HikariCP
- **Logging:** SLF4J with Logback
- **Build System:** Gradle 8.10 with Kotlin DSL
- **Testing:** JUnit 5 (planned)

## Development

### Development Workflow

1. **Make your changes** - Edit code in `src/main/kotlin/`
2. **Run tests** (if available): `./gradlew test`
3. **Build**: `./gradlew build`
4. **Run locally**: `./gradlew run`
5. **Check logs** - Located in `logs/` directory

### Code Style

This project follows Kotlin coding conventions:
- Use meaningful variable names
- Prefer `data class` for models
- Use `suspend` functions for async operations
- Document public APIs with KDoc comments

### Adding New Features

#### Adding a New Save Handler

1. Create handler in `server/handler/save/`
2. Define save method in `SaveDataMethod.kt`
3. Register in `Application.kt`

Example:
```kotlin
// 1. Define method
const val MY_FEATURE = "my_feature"

// 2. Create handler
class MyFeatureSaveHandler : SaveSubHandler {
    override val supportedTypes = setOf(SaveDataMethod.MY_FEATURE)

    override suspend fun handle(ctx: SaveHandlerContext) {
        // Implementation
    }
}

// 3. Register in Application.kt
val saveHandlers = listOf(
    MyFeatureSaveHandler(),
    // ... other handlers
)
```

#### Adding a New Broadcast Type

1. Add to `BroadcastProtocol.kt`:
```kotlin
MY_EVENT("myevent"),
```

2. Add convenience method to `BroadcastService.kt`:
```kotlin
suspend fun broadcastMyEvent(playerName: String, data: String) {
    broadcast(BroadcastMessage(BroadcastProtocol.MY_EVENT, listOf(playerName, data)))
}
```

3. Update client-side `BroadcastSystemProtocols.as` (if needed)

### Debugging

Enable debug logging in `application.yaml`:

```yaml
logger:
  level: 0  # 0=DEBUG, 1=INFO, 2=WARN, 3=ERROR
  colorful: true
```

Logs are written to:
- Console (colorized)
- `logs/application.log` (file)

## Documentation

### Available Documentation

Comprehensive documentation is available in the `docs/` directory:

📚 **Key Documentation Files:**
- [Broadcast System](docs/src/content/docs/broadcast-system.md) - Real-time event notification system
- [Arena System](docs/src/content/docs/thelaststand/app/game/data/arena/) - Arena battles and leaderboards
- [Architecture](docs/src/content/docs/architecture.md) - Server architecture overview
- [API Server](docs/src/content/docs/api-server.md) - REST API endpoints

### Building Documentation Site

Documentation uses Astro for static site generation:

```bash
cd docs
npm install
npm run dev
```

View at `http://localhost:4321`

### Contributing Documentation

1. Create a new `.md` file with frontmatter:

```markdown
---
title: Your Page Title
slug: package/path/filename
description: Brief description
---
```

2. Add images/videos to `docs/src/assets/`
3. Update sidebar in `docs/astro.config.mjs`

**Slug Convention:**
The slug follows the game's package structure.

Example: For file in package `thelaststand.app.network`, slug is `thelaststand/app/network/filename`

### Key Systems Documentation

#### Broadcast System
The broadcast system provides real-time notifications to all players. See [broadcast-system.md](docs/src/content/docs/broadcast-system.md) for:
- Protocol definitions and message formats
- Available broadcast types (25+ event types)
- Arena leaderboard integration
- Client-side integration examples

#### Arena System
Arena battles are competitive PvE challenges with XP tracking and leaderboards. Documentation includes:
- [ArenaSession](docs/src/content/docs/thelaststand/app/game/data/arena/arenasession.md) - Player progress and XP
- [ArenaSystem](docs/src/content/docs/thelaststand/app/game/data/arena/arenasystem.md) - Single run results
- XP calculation and leaderboard ranking
- Broadcast integration for achievements

## Contributing

Contributions are welcome! Whether it's bug fixes, new features, documentation, or testing - all help is appreciated.

### How to Contribute

1. **Fork the repository**
   ```bash
   git clone https://github.com/YourUsername/Sandbox.git
   cd Sandbox
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make your changes**
   - Follow Kotlin coding conventions
   - Add tests if applicable
   - Update documentation

4. **Test your changes**
   ```bash
   ./gradlew build
   ./gradlew run
   ```

5. **Commit with clear messages**
   ```bash
   git commit -m "Add arena leaderboard XP tracking"
   ```

6. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```

7. **Open a Pull Request**
   - Describe your changes
   - Link related issues
   - Add screenshots if relevant

### Development Guidelines

- **Code Quality:** Write clean, readable, maintainable code
- **Documentation:** Document public APIs and complex logic
- **Testing:** Test your changes thoroughly before submitting
- **Commit Messages:** Use clear, descriptive commit messages
- **Branch Naming:** Use prefixes like `feature/`, `bugfix/`, `docs/`

### Areas Needing Help

- 🐛 **Bug Fixes** - Report and fix bugs
- ✨ **Features** - Implement missing game features
- 📚 **Documentation** - Improve and expand documentation
- 🧪 **Testing** - Write unit and integration tests
- 🎨 **UI/UX** - Improve admin interfaces
- 🔧 **DevOps** - Improve build and deployment

## Recent Changes

### Latest Updates (November 2024)

#### Arena System Enhancements
- ✅ Added `ARENA_LEADER` broadcast protocol for leaderboard leaders
- ✅ Updated `broadcastArenaLeaderboard()` to send all required parameters (playerName, arenaName, level, points)
- ✅ Enhanced arena XP tracking documentation
- ✅ Created comprehensive broadcast system documentation

#### Documentation Improvements
- ✅ Complete broadcast system documentation with 25+ event types
- ✅ Enhanced arena system docs with XP calculation details
- ✅ Added architecture diagrams and component overview
- ✅ Improved README with detailed project information

#### Database & Storage
- ✅ Arena XP data models fully defined (`ArenaSession.points`)
- 🚧 Arena save handlers implementation (in progress)
- 🚧 Leaderboard database queries (in progress)

### Roadmap

#### Short Term (Q4 2024)
- [ ] Complete arena save handler implementations
- [ ] Implement arena leaderboard database queries
- [ ] Add arena XP persistence to database
- [ ] Complete arena broadcast integration

#### Medium Term (Q1 2025)
- [ ] Alliance system implementation
- [ ] Event system framework
- [ ] Enhanced admin tools
- [ ] Performance optimizations

#### Long Term
- [ ] Comprehensive test coverage
- [ ] Web-based admin dashboard
- [ ] Player statistics API
- [ ] Mobile companion app

## Community

Join our community to get help, share ideas, and contribute:

- **Discord:** [Join our server](https://discord.gg/jFyAePxDBJ) - Chat with developers and players
- **GitHub Issues:** [Report bugs](https://github.com/SulivanM/Sandbox/issues) - Report bugs and request features
- **GitHub Discussions:** [Share ideas](https://github.com/SulivanM/Sandbox/discussions) - Discuss features and get help
- **Documentation:** [Read the docs](docs/) - Learn about the codebase

### Support

If you encounter issues:
1. Check existing [GitHub Issues](https://github.com/SulivanM/Sandbox/issues)
2. Ask in our [Discord](https://discord.gg/jFyAePxDBJ)
3. Create a new issue with:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Server logs if applicable

## License

This project is a community revival effort for educational and preservation purposes.

**All rights to The Last Stand: Dead Zone belong to Con Artist Games.**

This server implementation is provided "as-is" without warranties of any kind. Use at your own risk.

---

## Acknowledgments

- **Con Artist Games** - Original game developers
- **Community Contributors** - Everyone who has contributed code, documentation, and testing
- **The Last Stand Community** - Players who keep the game alive

---

**⚠️ Disclaimer:** This is an unofficial private server project. We are not affiliated with, endorsed by, or connected to Con Artist Games in any way. This project is for educational and preservation purposes only.
