---
title: Multiplayer
slug: playerio/multiplayer
description: Multiplayer
---

The `Multiplayer` class is responsible for managing PlayerIO rooms.

In PlayerIO, a **room** refers to a separate instance of server-side logic, uniquely identified by a **room ID** and a **room type**. Each room can run on a different game server, potentially on separate physical machines. (See [PlayerIO Room documentation](https://playerio.com/documentation/services/multiplayer/essentials) for more details.)

In TLSDZ, the game uses multiple types of rooms, such as `game`, `chat`, `trade`, and `alliance` (defined in `thelaststand.app.network.RoomType`). This means multiple isolated instances of game servers may run simultaneously—potentially on different machines.

The `Multiplayer` class is mainly concerned during connection initialization phase, where it handles the creation or joining of a room. The `createJoinRoom` method internally delegates to the generated `_createJoinRoom` method, which performs the request to [API 27](/api-server#api-27).

Once a successful response is received, a socket connection is established via the [Connection class](/playerio/connection).
