---
title: BinarySeriaizer
slug: playerio/utils/binaryserializer
description: BinarySeriaizer
---

TLSDZ uses a custom serialization mechanism from PlayerIO. This class handles the serialization as well as the deserialization of a message.

## Serialization

Based on `playerio.utils.BinarySerializer@line 161`, the serialized message includes:

- The length of the full message, excluding the type.
- The type of the message, serialized as short string.
- On each value of the message:
  - [Optional] A byte pattern indicating the data type (e.g., string, int, float).
  - [Optional] An unsigned integer representing the length of the value’s byte data (only needed for types with variable length like long strings, byte arrays, etc.).
  - The actual data bytes (e.g., UTF-8 string content, number bytes, boolean flag, etc.).

Below is the list of data type pattern:

```
ShortStringPattern = 11000000
ShortUnsignedIntPattern = 10000000
ShortByteArrayPattern = 01000000
UnsignedLongPattern = 00111000
LongPattern = 00110000
ByteArrayPattern = 00010000
StringPattern = 00001100
UnsignedIntPattern = 00001000
IntPattern = 00000100
DoublePattern = 00000011
FloatPattern = 00000010
BooleanTruePattern = 00000001
BooleanFalsePattern = 00000000
```

### Example

The game often format its message in an array and serialize each element. Pseudocode:

```python
msg = ["playerio.joinresult", False, 11, "Failed to join room: Unknown connection"]

buffer = []
buffer += serialize(len(msg) - 1)

for value in message:
    buffer += serialize(value)

def serialize(value):
    if isinstance(value, str):
        # if long string
            # write type, length, N length, string

    # and so on for each types
```

The message will be serialized to `\x83\xd3playerio.joinresult\x00\x8b\xe7Failed to join room: Unknown connection`.

- `\x83`: The number of arguments (3) is encoded using `ShortUnsignedIntPattern`: `0b10000000 | 3 = 0x83`.
- `\xd3playerio.joinresult`: A short string with a length of 19 bytes. Encoded using `ShortStringPattern`: `0xC0 | 19 = 0xD3`, followed by the UTF-8 encoded string content.
- `\x00`: Serialized `false` using the `BooleanFalsePattern` (`0x00`).
- `\x8b`: Serialized integer `11` using `ShortUnsignedIntPattern`: `0x80 | 11 = 0x8B`.
- `\xe7Failed to join room: Unknown connection`: A short string of length 39 bytes. Encoded using `ShortStringPattern`: `0xC0 | 39 = 0xE7`, followed by the UTF-8 encoded string content.

## Deserialization

Socket data is received from the [`Connection`](/playerio/connection) class. A deserialized message is then passed alongside the `onMessage` event.

Based on `playerio.utils.BinarySerializer@line 119 | AddByte()`:

- `AddByte` or `AddBytes` is called for every incoming byte or byte array received from the socket.
- The first byte will be matched against the defined token pattern (e.g., boolean true = `00000001`, long = `00110000`) to determine what type of token it is.
- A `TokenBuilder` is initialized with the matched `Token` and is responsible for accumulating the necessary bytes based on the token's data type.

  - For example, a token representing a `double` requires 8 additional bytes to fully construct its value, so the `TokenBuilder` collects those bytes accordingly.
  - In contrast, a boolean value requires no extra bytes—the type byte alone is enough to indicate whether it’s `true` or `false`.
  - However, a non-short string (and byte array) token is more complex. First, the string token has a pattern that identifies it as a string. Second, the string has a specific length (e.g., 300). Third, an unsigned integer representing the length of the string (e.g., 300 needs 2 bytes) is also required. And finally, the actual string content.
  - To generalize, the `TokenBuilder` takes a type of token and a chain of handlers that need to be called when processing that type. For instance, the string has this chain of handlers: read type, read length of content length, read content length, and read content.

  :::note
  A short string is defined as a string whose UTF-8 encoded size is less than 64 bytes. The limit for short strings is 64 bytes (6 bits) rather than 256 bytes (8 bits) because short strings utilize the remaining 6 bits of the pattern (i.e., string short = `11000000`) for length. It doesn't send an extra byte during transmission but adds it to the token during deserialization (in the code: `param1 & ~_loc2_.Type`).
  :::

- Once all required bytes are processed, the `TokenBuilder` fires an `onValue` event with the parsed value.
- The value is passed to the `MessageBuilder`, which collects values until a full message is assembled, triggering the `onMessage` event.
