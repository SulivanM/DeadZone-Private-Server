---
title: BigDB
slug: playerio/bigdb
description: BigDB
---

:::note
Part of PlayerIO backend services. Source: https://playerio.com/documentation/services/bigdb/.
:::

PlayerIO implementation of database, which is similar to a NoSQL database like MongoDB. BigDB data is stored in tables, with each data being a key-value pair object that is similar to JSON.

Exchange of data between game and the server is done with protobuf format via APIs.

## load

The `load` method is used to call the internally generated PlayerIO class that again call `_loadObjects`, which makes the request to [API 85](/api-server#api-85).

The input for `load`:

- `param1`: table name (e.g., "PlayerObjects")
- `param2`: key (e.g., "userId")
- `param3`: callback
- `param4`: error handler

The client sends the table name and key as a `BigDBObjectId`. The server uses this table name and key to retrieve the relevant data. The output is `BigDBObjects`, which contains the data as a list of objects.

Internally, data is stored as objects (a single object is called `ObjectProperty`, which has `name` and `value` type of `ValueObject`) and transmitted using the protobuf protocol. When the client receives these objects, the low-level message handler first deserializes the protobuf and then converts the object into a `DatabaseObject` using the [`Converter`](/playerio/utils/converter) utility class. The [converter deserializes](/playerio/utils/converter#deserializevalueobject) each BigDB `ValueObject` into AS3 native types according to the specified BigDB type.
