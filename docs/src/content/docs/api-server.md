---
title: API Server
slug: api-server
description: API Server
---

TLSDZ utilizes RPC to make requests to the API server by invoking the `Request` method in [`HTTPChannel`](/playerio/utils/httpchannel). Additionally, both requests and responses are formatted using Protobuf.

All expected messages for input (arguments), output, and errors can be found in the [`playerio.generated.messages`](/playerio/generated/messages/generatedmessages) package. The server follows the input message format for making requests, and our server must respond to the API with the expected output message. The error format typically only contains error code and message.

Below is a list of API requests made by the game, along with the expected messages defined in the `.proto` file.

### API 13

Authenticate. Contextual call `thelaststand.app.network.PlayerIOConnector@line 210` and actual call `playerio.generated.PlayerIO@line 68`.

Response is based on `AuthenticateOutput` message.

```protobuf
message AuthenticateOutput {
  optional string token = 1;
  optional string userId = 2;
  optional bool showBranding = 3 [default = false];
  optional string playerInsightState = 4;
  optional bool isSocialNetworkUser = 5 [default = false];
  optional bool isInstalledByPublishingNetwork = 6 [default = false];
  optional bool deprecated1 = 7 [default = false];
  optional string apiSecurity = 8;
  repeated string apiServerHosts = 9;
}
```

### API 601

Social refresh. Contextual call `thelaststand.app.network.PlayerIOConnector@line 221` and actual call `playerio.generated.social@line 33`.

Response is based on `SocialRefreshOutput` message.

```protobuf
message SocialRefreshOutput {
    optional SocialProfile myProfile = 1;
    repeated SocialProfile friends = 2;
    repeated string blocked = 3;
}

message SocialProfile {
    optional string userId = 1;
    optional string displayName = 2;
    optional string avatarUrl = 3;
    optional bool lastOnline = 4;
    optional string countryCode = 5;
    optional string userToken = 6;
}
```

### API 27

Create join room. Contextual call `thelaststand.app.network.Network@line 1064` and actual call `playerio.generated.Multiplayer@line 155`.

Response is based on `CreateJoinRoomOutput` message.

```protobuf
message CreateJoinRoomOutput {
  optional string roomId = 1;
  optional string joinKey = 2;
  repeated ServerEndpoint endpoints = 3;
}

message ServerEndpoint {
  optional string address = 1;
  optional int32 port = 2;
}
```

### API 50

Write error. Called in many places to send error to server. Contextual call `thelaststand.app.network.Network@line 1358` and actual call `playerio.generated.ErrorLog@line 36`.

Response is not mandatory since it is one-way communication from client to the server. Input from client request is based on `WriteErrorArgs` and the response is an error message based on `WriteErrorError`.

```protobuf
message WriteErrorArgs {
  optional string source = 1;
  optional string error = 2;
  optional string details = 3;
  optional string stacktrace = 4;
  repeated KeyValuePair extraData = 5;
}

message WriteErrorError {
  optional int32 errorCode = 1;
  optional string message = 2;
}
```

### API 85

BigDB request to load objects. Contextual call `thelaststand.app.network.Network@line 1355` and actual call `playerio.generated.BigDB@line 86`.

Input is `LoadObjectsArgs` which contains a list of `BigDBObjectId` that denotes the list of table it wants to load to (e.g., `Inventory`, `PlayerObjects`) and the keys (usually `userId`).

```
message LoadObjectsArgs {
  repeated BigDBObjectId objectIds = 1;
}

message BigDBObjectId {
  optional string table = 1;
  repeated string keys = 2;
}
```

Output is `LoadObjectsOutput` which is a list of `BigDBObject`. Each contain `key`, `version`, `creator`, and the list of `properties` or the actual data in another object format called `ObjectProperty`.

```
message LoadObjectsOutput {
  repeated BigDBObject objects = 1;
}

message BigDBObject {
  optional string key = 1;
  optional string version = 2;
  repeated ObjectProperty properties = 3;
  optional uint32 creator = 4;
}
```

Data is always represented as a key-value pair object (similar to JSON), consisting of a name and a value. The value has a data type ranging from 1 to 10 and contains actual data that corresponds to the type, such as a string, int32, long, another object, or an array.

```
message ObjectProperty {
  optional string name = 1;
  optional ValueObject value = 2;
}

message ValueObject {
  enum ValueType {
    STRING = 0;
    INT32 = 1;
    UINT = 2;
    LONG = 3;
    BOOL = 4;
    FLOAT = 5;
    DOUBLE = 6;
    BYTE_ARRAY = 7;
    DATETIME = 8;
    ARRAY = 9;
    OBJECT = 10;
  }

  optional ValueType valueType = 1;
  optional string string = 2;
  optional int32 int32 = 3;
  optional uint32 uInt = 4;
  optional int64 long = 5;
  optional bool bool = 6;
  optional float float = 7;
  optional double double = 8;
  optional bytes byteArray = 9;
  optional int64 dateTime = 10;
  repeated ArrayProperty arrayProperties = 11;
  repeated ObjectProperty objectProperties = 12;
}

message ArrayProperty {
  optional int32 index = 1;
  optional ValueObject value = 2;
}
```

An array is essentially an object with key of index and corresponding values. While the array is transmitted as an object (no array type in protobuf), the client-side decodes it into an array format, provided the object adheres to the valid structure of an array.
