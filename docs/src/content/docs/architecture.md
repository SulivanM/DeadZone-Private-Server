---
title: Architecture
slug: architecture
description: Architecture
---

TLSDZ uses [PlayerIO backend service](playerio.com) for their server.

## API

Non-real-time data is fetched to the [API server](/api-server). The API server uses Protobuf serialization on top of PlayerIO custom messages.

PlayerIO uses [BigDB](/playerio/bigdb) as their database. BigDB is a document database like MongoDB whose data look like JSON. Data is stored as plain object in the database (this is called [`DatabaseObject`](/playerio/databaseobject) in the client side). Whether the data is retrieved locally or received from the server, it is [converted](/playerio/utils/converter) into game-level data model representation such as [`PlayerData`](/thelaststand/app/data/playerdata) and [`Survivor`](/thelaststand/app/game/data/survivor).

Data transfer for the game is done via the API server. If a `PlayerData` object were to be transferred over the network, the data model needs to converted into [`BigDBObject` of protobuf definition](/api-server#api-85). Then, wrapped in another protobuf definition of `LoadObjectsOutput` (for loading object from server to client).

- So, on the server-side: `Data model (e.g., PlayerData) -> BigDBObject -> LoadObjectsOutput`
- Client-side: `LoadObjectsOutput -> DatabaseObject -> PlayerData`

Lastly, we need to append byte 0 and byte 1 on the serialized protobuf message.

## Socket

For real-time communication, TLSDZ rely on TCP socket connection. Every [message](/playerio/message) exchange must have type, such as `"gr"` (game ready message), `"qp"` (quest progress), [etc. at NetworkMessage](/thelaststand/app/network/networkmessage); followed by actual message data.

Example of socket handler: [game ready](/thelaststand/app/network/network#ongameready).

## Game Data

We define a standard format of the game data model. The purpose is to summarize the nested and complicated look of data in the decompiled client-side fie. We call it "schema" and these are available in many docs, such as [PlayerData](/thelaststand/app/data/playerdata#object-structure).

The format of schema is:

```scala
<schema_type> <schema_name>

<field_name>: <field_type><field_enforcement>
<field_name>: <field_type><field_enforcement>
<field_name>: <field_type><field_enforcement>
...
...
<field_name>: <field_type><field_enforcement>

<schema_type>        = data (for data definition) or enum (for constants)
<schema_name>        = data or enum name, usually same as the file name
<field_name>         = the name of a field
<field_type>         = the type of the field
<field_enforcement>  = the enforcement of the type, can be required (!), nullable (?), or have a default value (=)

The types can be: String, Int, UInt, Double, Float, Boolean,
Long, Short, Byte, Char, Any,
ByteArray, List<T>, Map<K, V>, and nested object.

For type that refers to enum, it is recommended to use the real enum type (instead of the enum class).
This is to align with the client-side code that usually coerces the types.
```
