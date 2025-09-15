---
title: Converter
slug: playerio/utils/converter
description: Converter
---

The PlayerIO utility class that converts raw network messages, such as those message in protobuf format or BigDB objects, into native AS3 values.

## toDatabaseObject

This method is used to transform a low-level `BigDBObject` (e.g., received from [API 85](/api-server#api-85)) into a [`DatabaseObject`](/playerio/databaseobject), which is a more high-level representation.

Each object within the `BigDBObject` is [deserialized](#deserializeValueObject) based on its specific type.

## deserializeValueObject

A helper function within the `Converter` class. It uses the `valueType` enum from the protobuf format (refer to [API 85](/api-server#api-85) for details) to coerce each object into AS3 types. For types like arrays and nested objects, this function is called for each element or child.

If an invalid `valueType` enumeration is encountered, an error will occur: `Unknown valuetype in returned BigDBObject`. If a type is misenumerated (for instance, if data is an integer but marked as an array), this will throw an AS3 error: `Type Coercion failed: cannot convert Int to Array`.
