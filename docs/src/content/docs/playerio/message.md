---
title: Message
slug: playerio/message
description: Message
---

PlayerIO wrapper for messages exchanged between the client and the socket server.

Each message includes a string identifying the [network message type](/thelaststand/app/network/networkmessage) and an array of data values called `content`. Data is accessed using helper methods such as `getBoolean(index)`, `getString(index)`, and `getInt(index)`. The message length refers to the number of items in `content`; the type string is not included in this count, even though it is combined with the data during transmission.

The [Connection](/playerio/connection) class manages message exchange. It is responsible for setting up listeners and callbacks for a specific type of network messages, as well as creating and sending messages.

Messages must be [serialized or deserialized using the proper mechanism](/playerio/utils/binaryserializer).

## Example

A message from the server like `[playerio.joinresult, True]` has the type `"playerio.joinresult"` and a content array with a single `True` value. The corresponding handler for the type of message is then called, see [Connection.handleMessage](/playerio/connection/#handlemessage).
