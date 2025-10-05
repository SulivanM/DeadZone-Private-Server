# Recapturing The DeadZone

TLS:DZ private server (revival).

## How to Play?

1. Install [Java 25](https://download.oracle.com/java/25/latest/jdk-25_windows-x64_bin.exe). We recommend installing it in the default directory.

2. Install MariaDB using our companion repository:  
   👉 https://github.com/SwitchCompagnie/Deadzone-Revive-Website-Game  
   This repo provides a ready-to-use setup for MariaDB.

3. Create a new database named `prod_deadzone_game` in MariaDB.  
   ⚠️ Tables will be created automatically on first server run.

4. Download the latest server :  
   👉 [Latest Release](https://github.com/SulivanM/DeadZone-Private-Server/releases) (`deploy.zip`)

5. Extract the zip archive.

6. Run the game server using the provided script:  
   - `autorun.bat` (Windows)  
   - `autorun.sh` (Linux/macOS)  
   This script will automatically detect your Java installation.

7. Use a Flash-compatible browser (Ruffle is **not supported**).  
   We recommend using [Basilisk with Flash (debug)](https://www.mediafire.com/file/tmecqq7ke0uhqm7/Basilisk_with_Flash_%2528debug%2529.zip/file)

8. Go to the following URL in your browser:  
   `http://127.0.0.1:8080`

👉 Join our [Discord](https://discord.gg/jFyAePxDBJ) for questions, updates, or community support.

---

## Development

### Requirements

- Java 25
- MariaDB (installed via: [Deadzone-Revive-Website-Game](https://github.com/SwitchCompagnie/Deadzone-Revive-Website-Game))

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

### Running the Server

1. Ensure your MariaDB service is running.

2. Start the server using the provided script:  
   - `runserver.bat` (Windows)  
   - `runserver.sh` (Linux/macOS)

---

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
