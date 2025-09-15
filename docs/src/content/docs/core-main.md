---
title: Main
slug: core-main
description: Index page of the core.swf file
---

### Game Bootstrap

- The game starts with the Main class, which is invoked by the [preloader](/preloader-main).
- Begin resource unpacking.
  - Event listeners are registered for successful and failed unpacking events.
  - Resources are unpacked and loaded asynchronously in the background.
  - Once completed, a notification is dispatched indicating that resource loading is done.

### Socket Server Connection Establishment

- Begin connection to socket server.
  - This is triggered by calling the `connect()` method on the [Network](/thelaststand/app/network/network) class, which internally invokes a private `joinRoom()` method.
  - `joinRoom()` uses the PlayerIO [Multiplayer](/playerio/multiplayer) API to request [create and join room (API 27)](/api-server#api-27).
  - API server responds room data and the endpoint for the socket server.
  - Client connects to the socket server from the given endpoint and port.
  - Client initially send `<policy-file-request/>` and server must reply appropriately, by allowing request from any domain to the server port (with byte 0 appended after the policy file response).
  - Client sends the initial `"join"` message which includes the data received from API 27.
  - The socket server replies with a `playerio.joinresult` message:
    - If the join is valid, send a true boolean value.
    - If the join is invalid, send false along with an error message.
  - Upon success, a connected event is dispatched, indicating the socket connection is ready for communication.

### Initial Data Exchange & Player Data Loading

- Early socket communication is focused on retrieving the player's game state and additional data stored in the server.
- [`onGameReady`](/thelaststand/app/network/network#ongameready) function from Network class is expected to run.
  - The `"gr"` message (game ready) should be sent from the socket server:
    - The message contains 5 values:
      1. Server time in long data type.
      2. Binaries data in XML or gzipped XML, which are assets like `buildings.xml`, `attire.xml`, etc. The game updates its loaded XML with the one sent from server.
      3. JSON cost table data, possibly the in-game cost for items or upgrades.
      4. JSON survivor class table, the specific stats of a survivor class (e.g., `baseAttributes` like `health`, `combatMelee`, `movement`).
      5. JSON login player state, allegedly updates from server (like news, sales) and other events that has occured while player is logged out.
  - The `onNetworkGameDataReceived` from core `Main.as` will be triggered every time the game receives XML files from server. This method updates the game's currently loaded XML with the newly received XML.
  - The JSON dumps are parsed and stored in local variables in the `Network` class for later use.
  - Next is loading `PlayerObjects`, `NeighborHistory`, and `Inventory` from BigDB by making request to [API 85](/api-server#api-85). A network error (which force disconnects the player) will be raised if the loaded objects are empty or null.
- When all three objects are loaded successfully, [`onPlayerDataLoaded`](/thelaststand/app/network/network#onplayerdataloaded) is called.
- `onPlayerDataLoaded`
  - Create in-game `Survivor` objects using the `AHBuildSrvs` method. This method internally reads the parsed survivor class table from the server, loads local assets and data, and maps them to the corresponding survivor object.
  - Parses `playerObject` and `loginPlayerState` to initializes internal game state.
  - Initializes core game systems: `GlobalQuestSystem`, `QuestSystem`, `OfferSystem`, and `AllianceSystem`.
  - Send the game ready signal.

### Game Start

- The `onNetworkGameReady` method in main listens for the game ready signal and calls the `onReady` method next, which:
  - Closes the loading dialogue and removes network listeners for loading/error/start connection events.
  - Opens the "create survivor" dialogue (if necessary).
  - After survivor is created, or if player player has already created one before, game start signal will be dispatched and `Game.as` (as well as `Tutorial.as` if not finished tutorial) will enter the stage.
  - The most important method is loading the compound with the method [`gotoCompound`](/game#gotocompound) of `Game.as`.
 
Past this, everything isn't really sequential anymore, so we stop here. See also [Game](/game) and [Tutorial](/tutorial).
