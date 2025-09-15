---
title: Main
slug: preloader-main
description: Index page of the preloader.swf file
---

The `Main` class (`thelaststand.preloader.core/Main.as`) is the entry point for the preloader of The Last Stand: Dead Zone. It is responsible for initializing the loading screen, managing the loading of core game assets, and preparing the environment before the main game (`core.swf`) is launched.

- The `Main` class constructor sets up the stage properties and adds listeners for when the preloader is added or removed from the stage.
- When the preloader is added to the stage (`onAddedToStage`), it reads configuration parameters from `loaderInfo` (such as `local`, `path`, `core`, and `useSSL`) and calls `init()`.
- The `init()` method:
  - Sets the static stage reference.
  - If available, enables JavaScript-Flash communication and registers a screenshot callback.
  - Instantiates the `PlayerIOConnector` and sets up event listeners for connection events.
  - Sets the secure API flag if needed.
  - Initializes loaders for the core game and background image, and attaches progress and completion listeners.
  - Begins loading the background image.
- When the background image finishes loading (`onBackgroundLoadComplete` or `onBackgroundLoadFailed`), `initStage()` is called to:
  - Add the background, logo (if needed), noise overlay, progress bar, spinner, and status text to the stage.
  - Notify JavaScript that the preloader is ready.
  - Animate the background and schedule the PlayerIO connection.
- When the PlayerIO connection completes ([`onPlayerIOConnected`](/thelaststand/app/network/playerioconnector#onplayerioconnected)), `loadCore()` is called to:
  - Build the URL for the core SWF, set security permissions, and start loading the core game file.
  - Update the status text and loader context.
  - Validate the origin of the loaded file.
- As the core SWF loads, `onCoreLoadProgress` updates the progress bar.
- When the core SWF finishes loading (`onCoreLoadComplete`), `initCore()`:
  - Adds the core game to the stage.
  - Cleans up preloader UI elements and listeners.
  - The core SWF file starts its `Main` class
- The class also handles stage resizing, spinner animation, connection errors, and provides a JavaScript-accessible screenshot function.
