import struct


class Serializer:
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

    @staticmethod
    def serialize_value(value):
        if isinstance(value, bool):
            return bytes(
                [Serializer.PATTERNS["true"] if value else Serializer.PATTERNS["false"]]
            )
        elif isinstance(value, int):
            if 0 <= value < 64:
                return bytes([Serializer.PATTERNS["short_unsigned_int"] | value])
            else:
                return Serializer._serialize_int(value)
        elif isinstance(value, float):
            return bytes([Serializer.PATTERNS["double"]]) + struct.pack(">d", value)
        elif isinstance(value, str):
            encoded_value = value.encode("utf-8")
            if len(encoded_value) < 64:
                return (
                    bytes([Serializer.PATTERNS["short_string"] | len(encoded_value)])
                    + encoded_value
                )
            else:
                return Serializer._serialize_string(encoded_value)
        elif isinstance(value, bytes):
            if len(value) < 64:
                return (
                    bytes([Serializer.PATTERNS["short_byte_array"] | len(value)])
                    + value
                )
            else:
                return Serializer._serialize_byte_array(value)
        else:
            raise NotImplementedError(f"Value type {type(value)} is not implemented")

    @staticmethod
    def _serialize_int(value):
        encoded_value = struct.pack(">I", value)
        return (
            bytes([Serializer.PATTERNS["int"] | (len(encoded_value) - 1)])
            + encoded_value
        )

    @staticmethod
    def _serialize_string(value):
        length = len(value)
        encoded_length = struct.pack(">I", length)
        return (
            bytes([Serializer.PATTERNS["string"] | (len(encoded_length) - 1)])
            + encoded_length
            + value
        )

    @staticmethod
    def _serialize_byte_array(value):
        length = len(value)
        encoded_length = struct.pack(">I", length)
        return (
            bytes([Serializer.PATTERNS["byte_array"] | (len(encoded_length) - 1)])
            + encoded_length
            + value
        )
