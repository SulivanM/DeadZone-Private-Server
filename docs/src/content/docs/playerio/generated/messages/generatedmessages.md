---
title: PlayerIO Generated Messages
slug: playerio/generated/messages
description: PlayerIO Generated Messages
---

The `playerio.generated.messages` package contains the set of PlayerIO message classes used to exchange data between the client and the API server.

TLSDZ uses [Protocol Buffers (protobuf)](https://protobuf.dev/) as the data exchange format. Each message class constructor registers its fields using the `registerField()` method.

## registerField

A field is registered with the method `registerField()`, passing in:

- The name of the field
- [Optional] package name if the field refer to another class
- The type of the field
- [Optional] label to indicate whether the field is optional (label=1), required (label=2), or repeated (list, label=3).
- The field number (i.e., its position in the protobuf schema).

As an example, this is how to construct `CreateJoinRoomOutput` (through protobuf API for AS3):

```as3
// playerio.generated.messages/CreateJoinRoomOutput.as

public function CreateJoinRoomOutput()
{
    super()
    registerField("roomId","",9,1,1)
    registerField("joinKey","",9,1,2)
    registerField("endpoints","playerio.generated.messages.ServerEndpoint",11,3,3)
}
```

Each class inherits `com.protobuf.Message`. `registerField` method creates a `com.protobuf.Descriptor` object through the `Message` class which parse the field arguments.

These are the numeric constants used to indicate field types when calling `registerField()`:

```
DOUBLE = 1 | INT32   = 5 | STRING    =  9 | UINT     = 13 | SINT32   = 17
FLOAT  = 2 | FIXED64 = 6 | GROUP     = 10 | ENUM     = 14 | SINT64   = 18
LONG   = 3 | FIXED32 = 7 | MESSAGE   = 11 | SFIXED32 = 15 | MAX_TYPE = 18
UINT64 = 4 | BOOL    = 8 | BYTEARRAY = 12 | SFIXED64 = 16 |
```

```
// name, messageClass, type, label, fieldNumber
registerField("roomId","",9,1,1)
registerField("joinKey","",9,1,2)
registerField("endpoints","playerio.generated.messages.ServerEndpoint",11,3,3)
```

This creates a protobuf message like:

```protobuf
message CreateJoinRoomOutput {
  optional string roomId = 1;
  optional string joinKey = 2;
  repeated ServerEndpoint endpoints = 3;
}
```

The third parameter, with label 3, indicates a repeated field, and type of 11, which corresponds to a list of `ServerEndpoint` object.

```protobuf
message ServerEndpoint {
  optional string address = 1;
  optional int32 port = 2;
}
```
