---
title: Connection
slug: playerio/connection
description: Connection
---

This class represents a client connection to the socket server. It manages real-time communication, socket connections, sending and receiving messages, and handling related errors.

## Internal Logic

Connection class is constructed with the given endpoint from API server responding to [API 27](/api-server#api-27).

### Constructor

In the constructor, it initializes an instance of the [serializer](/playerio/utils/binaryserializer) and listens for incoming [network messages](/playerio/message) using the `onMessage` event, calling the appropriate [message handler](#handlemessage) (explained below) as needed.

### doConnect

It then calls the private `doConnect` method which sets event listeners for the sockets:

- `connect`: This event is triggered when the socket successfully connects to the specified endpoint. It sends an initial "join" message containing a join key along with the `joinData` from the response of API 27.
- `close`: Triggered when the socket is closed, this event disconnects all message handlers.
- `ioError`: Triggered for I/O-related socket errors, this event attempts to disconnect and connect to other available endpoints.
- `securityError`: Triggered for security-related socket errors, it follows the same logic as the `ioError`.
- `socketData`: Triggered upon receiving raw socket data, this event reads all available bytes from the socket and sends them to the serializer. Once a sufficient number of bytes are received to form a complete message, the serializer fires the `onMessage` event.

### handleMessage

This method is called when the `onMessage` event is triggered and is responsible for handling the received message.

- If the message type is the special (hardcoded) `"playerio.joinresult"`, the message is expected to contain a boolean indicating whether the "join" message from `connect` listener of `doConnect` method was successful. If the boolean is `false` or missing, it attempts to extract a string and error code to construct a [PlayerIOError](/playerio/playerioerror).
- For all other message types, it checks if a matching message handler has been registered and calls it.

Example of how message handlers are registered:

```as3
// thelaststand.app.network/Network.as
// @line 1286
this._connection.addMessageHandler(NetworkMessage.GAME_READY,this.onGameReady);
this._connection.addMessageHandler(NetworkMessage.BANNED,this.onBanned);
this._connection.addMessageHandler(NetworkMessage.SERVER_INIT_PROGRESS,this.onServerInitProgress);
```

:::note
[List of network message type](/thelaststand/app/network/networkmessage).
:::
