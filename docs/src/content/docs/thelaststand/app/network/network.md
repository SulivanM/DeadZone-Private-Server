---
title: Network
slug: thelaststand/app/network/network
description: Network
---

An important class which serves as the central hub for all client-server communication in the game. It is responsible for:

- Managing game connection to socket servers.
- Handling login, room joining, and message dispatching.
- Processing server responses and forwarding relevant data to game managers.
- Maintaining connection state, authentication, and player-related metadata.

First interaction with this class is [core main](/core-main) calling `connect()` method to make a request to [API 27 (CreateJoinRoom)](/api-server#api-27).

## onRoomJoined

This method is called after a successful join result is received in the [Connection](/playerio/connection#handlemessage) class. It updates `connected` property and dispatch a connected signal to inform other class (e.g., core main updates the loading screen).

Next, [message handlers for network requests](/playerio/connection#handlemessage) are registered, such as:

```as3
this._connection.addMessageHandler(NetworkMessage.GAME_READY, this.onGameReady);
this._connection.addMessageHandler(NetworkMessage.BANNED, this.onBanned);
this._connection.addMessageHandler(NetworkMessage.SERVER_INIT_PROGRESS, this.onServerInitProgress);
```

This informs `Connection` class that it should listen to particular type of message it receives from the network (e.g., `"gr"` for game ready and `"ban"` for banned).

## onGameReady

Once room is joined, we can send a game ready message to initialize player's game data. Game ready message has the length of 5 which contains:

1. A number `serverTime`.
2. A byte array `binaries`, which is a gzipped game resources from the server. The binaries must contain `config.xml`, `resources_secondary.xml`, and `alliances.xml`.
3. JSON dump `costTableData`, the costs' data for items(?).
4. JSON dump `srvClassData`, the list of survivors the player has.
5. JSON dump `loginPlayerState`, the state of game during player inactivity (e.g., news, recent PvP).

Then, it parses each value of the message.

- The `binaries` is parsed through the `parseBinaries` method. Inside, it decodes the gzip and notify core main through `onNetworkGameDataReceived` method to replace the existing resource. Our hypothesis is that the resources sent from server are additional data based on player's data that replaces the original resource.
- The JSON dumps are parsed, and the data is assigned to the local variable of `Network` for further access by other classes.

The rest of the method loads player's data from [BigDB](/playerio/bigdb) by making requests to [API 85](/api-server#api-85) (load objects). The objects are `PlayersObject`, `NeighborHistory`, and `Inventory`.

If all three objects follows the protobuf format correctly, the `onPlayerDataLoaded` method is called.

## onPlayerDataLoaded

Responsible for initializing game and player state, initializing game systems, and preparing the environment for gameplay. Specifically, it performs the following steps:

- Verifies that all necessary game objects have been successfully loaded and are not null.
- Calls the `AHBuildSrvs` method to construct in-game `Survivor` objects.
- Parses the `playerObject`, which includes `loginPlayerState`, and maps the relevant data to local variables.
- Initializes core systems such as `GlobalQuestSystem`, `QuestSystem`, `OfferSystem`, and `AllianceSystem`. This is also where game trackers, notifications, and message/event handlers are set up.
- Establishes cross-tab communication using `SWFBridgeAS3` to ensure that only one game instance is active on the same machine.
- Finally, it signals that the game is ready and proceeds to invoke the next stage of the main application flow via `onReady`.
