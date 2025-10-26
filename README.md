# Recapturing The DeadZone

A private server revival for The Last Stand: Dead Zone.

[![Discord](https://img.shields.io/discord/YOUR_DISCORD_ID?color=7289da&logo=discord&logoColor=white)](https://discord.gg/jFyAePxDBJ)
[![Java](https://img.shields.io/badge/Java-25-orange.svg)](https://www.oracle.com/java/technologies/downloads)
[![MariaDB](https://img.shields.io/badge/MariaDB-11+-blue.svg)](https://mariadb.org/)

## Table of Contents

- [Quick Start](#quick-start)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Development](#development)
- [Documentation](#documentation)
- [Contributing](#contributing)

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

## Development

### Project Structure

```
.
├── src/main/kotlin/
│   ├── api/              # REST API endpoints
│   ├── core/             # Game logic & services
│   ├── data/             # Database models
│   ├── server/           # Socket server & handlers
│   ├── user/             # Authentication & sessions
│   └── utils/            # Utility functions
├── static/               # Game assets & data files
└── deploy/               # Build output directory
```

### Tech Stack

- **Language:** Kotlin 2.x
- **Framework:** Ktor (Server)
- **Database:** MariaDB with Exposed ORM
- **Serialization:** kotlinx.serialization (JSON, ProtoBuf)
- **Build:** Gradle 8.x

### Development Workflow

1. Make your changes
2. Run tests (if available): `./gradlew test`
3. Build: `./gradlew build`
4. Run locally: `./gradlew run`

## Documentation

Partial documentation is available in our separate repository:

📚 [DeadZone Documentation](https://github.com/glennhenry/DeadZone-Documentation)

### Running Documentation Locally

```bash
cd DeadZone-Documentation
npm install
npm run dev
```

### Contributing Documentation

1. Create a new `.md` file with frontmatter:

```markdown
---
title: Your Page Title
slug: package/path/filename
description: Brief description
---
```

2. Add images/videos to `src/assets/`
3. Update sidebar in `astro.config.mjs`

**Slug Convention:**
The slug follows the game's package structure.

Example: For file in package `thelaststand.app.network`, slug is `thelaststand/app/network/filename`

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Community

- **Discord:** [Join our server](https://discord.gg/jFyAePxDBJ)
- **GitHub Issues:** Report bugs and request features
- **Discussions:** Share ideas and get help

## License

This project is a community revival effort. All rights to The Last Stand: Dead Zone belong to Con Artist Games.

---

**⚠️ Disclaimer:** This is an unofficial private server. We are not affiliated with Con Artist Games.
