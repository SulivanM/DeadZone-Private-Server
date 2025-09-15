---
title: DatabaseObject
slug: playerio/databaseobject
description: DatabaseObject
---

PlayerIO high-level representation of BigDB objects. It is a dynamic class that allegedly is modified during runtime to give ability to access it like an AS3 dictionary. For instance:

```
var playerObject:DatabaseObject = param1;
var inventoryObject:DatabaseObject = param2;

playerObject["inventory"] = inventoryObject;
```

The utility class [`Converter`](/playerio/utils/converter) is used to convert raw `BigDBObject` into this `DatabaseObject`.
