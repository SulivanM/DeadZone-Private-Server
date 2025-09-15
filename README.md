# Recapturing The DeadZone

TLS:DZ private server (revival).

## How to Play?

1. Install [Java 24](https://www.oracle.com/java/technologies/downloads/). We recommend installing it in the default directory. (e.g., for Windows 64-bit users, download the x64 MSI installer).
2. Install [MongoDB community edition](https://www.mongodb.com/try/download/community). (You don't have to install MongoDB compass and installing it as a service is optional)
3. Download the server [latest release](https://github.com/glennhenry/Recapturing-The-DeadZone/releases) (download the `deploy.zip`).
4. Extract the zip.
5. Run the MongoDB server, this can be done by running the `runmongo.bat/sh` scripts (for more information see MongoDB's tutorial, [this is for Windows](https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-windows/)).
5. Run the game server, this can be done by running the `autorun.bat/sh` script (behind the scene, this script locate your Java default installation to run the server).
6. Open a flash-compatible browser (emulator like Ruffle is not supported), such as [Basilisk](https://www.mediafire.com/file/tmecqq7ke0uhqm7/Basilisk_with_Flash_%2528debug%2529.zip/file). Then, go to `127.0.0.1:8080`.

Join our [Discord](https://discord.gg/jFyAePxDBJ) for questions and more information.

## Development

### Requirements:

- Java 24
- MongoDB community edition

### Running the Server

1. Run MongoDB server (from scripts: `runmongo.bat/sh`).
2. Run game server:
   - from scripts: `runserver.bat/sh`.
   - via command line `.\gradlew run`.
   - via Intellij IDE by clicking run on `Application.Kt`.

## Docs

Formerly in [this repo](https://github.com/glennhenry/DeadZone-Documentation), we also have documentation of TLSDZ. It's incomplete and isn't updated to the latest information, but still contains basic information about TLSDZ.

To run the docs website locally:

```
npm install
npm run dev
```

### How to add new page:

1. A page must be `.md` file and is enforced to have this on top of them (frontmatter):

```
---
title: Subfolder Example
slug: playerio/subfolder-example/subfolder
description: example
---
```

2. Replace the title appropriately. The description is optional, so you can set it to be the same as the title. Any images or videos should be placed in `src/assets/`.
3. The slug is produced from the directory structure based on the game packages. For example, `playerioconnector.md` exists within the `thelaststand.app.network` package, thus the final slug is `thelaststand/app/network/playerioconnector`.
4. Next, add the page to the sidebar.

   1. Begin by editing the `astro.config.mjs`.
   2. Follow the existing sidebar link format. You can create new groups or place it in existing ones based on the page topic.

   Sidebar lists are based on game packages. Long package names can be shortened (e.g., `thelaststand.app`). If a package has several child packages, we can make a group for them (e.g., `network
