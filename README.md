# Recapturing The DeadZone

TLS:DZ private server (revival).

## How to Play?

1. Install [Java 25](https://www.oracle.com/java/technologies/downloads) for your platforms. We recommend installing it in the default directory.
2. Install MariaDB using our companion repository:  
   👉 https://github.com/SwitchCompagnie/Deadzone-Revive-Website-Game  
   This repo provides a ready-to-use setup for MariaDB.
3. Create a new database named `prod_deadzone_game` in MariaDB.  
   ⚠️ Tables will be created automatically on first server run.
4. Build the server by running `build.bat` (Windows) or `build.sh` (Linux/macOS). This process may take a while.
5. Open the `deploy` folder and run the server using the provided script `autorun.bat` (Windows) or `autorun.sh` (Linux/macOS). This script will automatically detect your Java installation.
6. Then access the game in `http://127.0.0.1:8080` using the website from step 2.

👉 Join our [Discord](https://discord.gg/jFyAePxDBJ) for questions, updates, or community support.

---

## Development

The requirements are:

- Java 25
- MariaDB (installed via: [Deadzone-Revive-Website-Game](https://github.com/SwitchCompagnie/Deadzone-Revive-Website-Game)).

### Run Server

Ensure that MariaDB is running, then run the following command:

```bash
.\gradlew run
```

You can also double-click on `runserver.bat` or `runserver.sh`; or run the `main` function in `Application.kt` through IntelliJ IDE run plugin.

### Database Configuration

The database config file is located at:  
`DeadZone-Private-Server/src/main/resources/application.yaml`

Example default configuration:

```yaml
maria:
  url: jdbc:mariadb://localhost:3306/prod_deadzone_game
  user: root
  password: ""
```

✅ You can change these values to match your local setup.  
⚠️ You must create the `prod_deadzone_game` database manually in MariaDB.  
The required tables will be generated automatically when the server starts.

### Logging Configuration

You can switch log levels and toggle color display in the same `application.yaml`

Default configuration:

```yaml
logger:
  level: 0
  colorful: true
```

### Development Flag

By default, the development mode is always on. You can turn it off by setting an environment flag.

For example, in Powershell (to set variables temporarily before running the server):

```bash
$env:DEV_MODE = "false"
java -jar zpr-server.jar
```

## Documentation

Some partial and outdated documentation is available here:  
👉 [DeadZone Documentation](https://github.com/glennhenry/DeadZone-Documentation)

To run the documentation site locally:

```bash
npm install
npm run dev
```

### How to Add a New Page

1. Create a `.md` file with the following frontmatter at the top:

```markdown
---
title: Subfolder Example
slug: playerio/subfolder-example/subfolder
description: example
---
```

2. Update the `title`. The `description` is optional.

3. Place any images or videos in the `src/assets/` folder.

4. The `slug` is based on the game's package structure.  
   For example, for the file `playerioconnector.md` in package `thelaststand.app.network`,  
   the slug would be: `thelaststand/app/network/playerioconnector`.

5. Add the page to the sidebar:
   - Edit `astro.config.mjs`
   - Follow the format of the existing links

---
