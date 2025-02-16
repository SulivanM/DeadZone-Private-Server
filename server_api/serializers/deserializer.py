import struct

PATTERNS = {
    "false": 0x00,
    "true": 0x01,
    "float": 0x02,
    "double": 0x03,
    "int": 0x04,
    "unsigned_int": 0x08,
    "byte_array": 0x10,
    "string": 0x0C,
    "short_long": 0x30,
    "long": 0x34,
    "unsigned_short_long": 0x38,
    "unsigned_long": 0x3C,
    "short_byte_array": 0x40,
    "short_unsigned_int": 0x80,
    "short_string": 0xC0,
}


def read_length(data, offset):
    return struct.unpack(">I", data[offset : offset + 4])[0] + 1, offset + 4


def read_unsigned_int(data, offset):
    value = 0
    while offset < len(data):
        value = (value << 8) | data[offset]
        offset += 1
    return value, offset


def deserialize_data(data):
    offset = 0
    values = []

    while offset < len(data):
        pattern = data[offset]
        offset += 1

        if pattern & PATTERNS["short_string"] == PATTERNS["short_string"]:
            length = pattern & 0x3F
            value = data[offset : offset + length].decode("utf-8")
            offset += length
        elif pattern & PATTERNS["short_byte_array"] == PATTERNS["short_byte_array"]:
            length = pattern & 0x3F
            value = data[offset : offset + length]
            offset += length
        elif pattern & PATTERNS["short_unsigned_int"] == PATTERNS["short_unsigned_int"]:
            value = pattern & 0x3F
        elif pattern == PATTERNS["false"]:
            value = False
        elif pattern == PATTERNS["true"]:
            value = True
        elif pattern == PATTERNS["float"]:
            value = struct.unpack(">f", data[offset : offset + 4])[0]
            offset += 4
        elif pattern == PATTERNS["double"]:
            value = struct.unpack(">d", data[offset : offset + 8])[0]
            offset += 8
        elif pattern == PATTERNS["int"]:
            value = struct.unpack(">i", data[offset : offset + 4])[0]
            offset += 4
        elif pattern == PATTERNS["unsigned_int"]:
            value = struct.unpack(">I", data[offset : offset + 4])[0]
            offset += 4
        elif pattern == PATTERNS["byte_array"]:
            length, offset = read_length(data, offset)
            value = data[offset : offset + length - 1]
            offset += length - 1
        elif pattern == PATTERNS["string"]:
            length = struct.unpack(">I", data[offset : offset + 4])[0]
            offset += 4
            value = data[offset : offset + length].decode("utf-8")
            offset += length
        else:
            raise ValueError(f"Unsupported pattern: {pattern}")

        values.append(value)

    return values
