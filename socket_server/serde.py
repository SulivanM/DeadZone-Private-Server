import io
import struct
from enum import IntEnum


class Pattern(IntEnum):
    STRING_SHORT_PATTERN = 0xC0
    STRING_PATTERN = 0x0C
    BYTE_ARRAY_SHORT_PATTERN = 0x40
    BYTE_ARRAY_PATTERN = 0x10
    UNSIGNED_LONG_SHORT_PATTERN = 0x38
    UNSIGNED_LONG_PATTERN = 0x3C
    LONG_SHORT_PATTERN = 0x30
    LONG_PATTERN = 0x34
    UNSIGNED_INT_SHORT_PATTERN = 0x80
    UNSIGNED_INT_PATTERN = 0x08
    INT_PATTERN = 0x04
    DOUBLE_PATTERN = 0x03
    FLOAT_PATTERN = 0x02
    BOOLEAN_TRUE_PATTERN = 0x01
    BOOLEAN_FALSE_PATTERN = 0x00
    DOES_NOT_EXIST = 0xFF


class BinarySerializer:
    def __init__(self):
        self.buffer = bytearray()

    def serialize(self, message):
        self.buffer.clear()
        self.serialize_value(len(message) - 1)
        for value in message:
            self.serialize_value(value)
        return bytes(self.buffer)

    def serialize_value(self, value):
        if isinstance(value, str):
            encoded = value.encode("utf-8")
            self._write_tag_with_length(
                len(encoded), Pattern.STRING_SHORT_PATTERN, Pattern.STRING_PATTERN)
            self.buffer += encoded

        elif isinstance(value, bool):
            self.buffer.append(
                Pattern.BOOLEAN_TRUE_PATTERN if value else Pattern.BOOLEAN_FALSE_PATTERN)

        elif isinstance(value, int):
            if -2**31 <= value <= 2**31 - 1:
                self._write_tag_with_length(
                    value, Pattern.UNSIGNED_INT_SHORT_PATTERN, Pattern.INT_PATTERN)
            else:
                self._write_long_pattern(
                    value, Pattern.LONG_SHORT_PATTERN, Pattern.LONG_PATTERN, signed=True)

        elif isinstance(value, float):
            self.buffer.append(Pattern.DOUBLE_PATTERN)
            self.buffer += self._reverse_bytes(struct.pack('<d', value))

        elif isinstance(value, bytes):
            self._write_tag_with_length(
                len(value), Pattern.BYTE_ARRAY_SHORT_PATTERN, Pattern.BYTE_ARRAY_PATTERN)
            self.buffer += value

        else:
            raise TypeError(f"Unsupported type: {type(value)}")

    def _write_tag_with_length(self, length, short_pattern, full_pattern):
        if 0 <= length <= 63:
            self.buffer.append(short_pattern | length)
        else:
            encoded = self._reverse_bytes(struct.pack('<I', length))
            nonzero = next((i for i, b in enumerate(encoded) if b != 0), 3)
            used = 4 - nonzero
            self.buffer.append(full_pattern | (used - 1))
            self.buffer += encoded[nonzero:]

    def _write_long_pattern(self, value, short_pattern, long_pattern, signed=False):
        fmt = '<q' if signed else '<Q'
        encoded = self._reverse_bytes(struct.pack(fmt, value))
        nonzero = next((i for i, b in enumerate(encoded) if b != 0), 7)
        used = 8 - nonzero
        pattern = long_pattern if used > 4 else short_pattern
        self.buffer.append(pattern | (used - (5 if used > 4 else 1)))
        self.buffer += encoded[nonzero:]

    @staticmethod
    def _reverse_bytes(b):
        return b[::-1]


class BinaryDeserializer:
    def __init__(self):
        self.reset()

    def reset(self):
        self.state = 'init'
        self.pattern = Pattern.DOES_NOT_EXIST
        self.buffer = io.BytesIO()
        self.message = []
        self.length = -1
        self.part_length = 0
        self.values = []

    def deserialize(self, data: bytes):
        for byte in data:
            self._deserialize_byte(byte)
        return self.values

    def _deserialize_byte(self, byte_val):
        if self.state == 'init':
            self._handle_init_state(byte_val)

        elif self.state == 'header':
            self.buffer.write(bytes([byte_val]))
            if self.buffer.tell() == self.part_length:
                self.part_length = struct.unpack(">I", self.buffer.getvalue()[
                                                 ::-1].rjust(4, b'\x00'))[0]
                self.buffer = io.BytesIO()
                self.state = 'data'

        elif self.state == 'data':
            self.buffer.write(bytes([byte_val]))
            if self.buffer.tell() == self.part_length:
                self._handle_pattern_data(self.buffer.getvalue())
                self.buffer = io.BytesIO()
                self.state = 'init'

    def _handle_init_state(self, byte_val):
        self.pattern = retrieve_flag_pattern(byte_val)

        if self.pattern in {Pattern.STRING_SHORT_PATTERN, Pattern.BYTE_ARRAY_SHORT_PATTERN}:
            self.part_length = retrieve_part_length(byte_val, self.pattern)
            if self.part_length > 0:
                self.state = 'data'
            else:
                self._on_value("" if self.pattern ==
                               Pattern.STRING_SHORT_PATTERN else b"")

        elif self.pattern in {Pattern.STRING_PATTERN, Pattern.BYTE_ARRAY_PATTERN,
                              Pattern.UNSIGNED_INT_PATTERN, Pattern.INT_PATTERN}:
            self.part_length = retrieve_part_length(byte_val, self.pattern) + 1
            self.state = 'header'

        elif self.pattern in {Pattern.UNSIGNED_INT_SHORT_PATTERN}:
            self._on_value(retrieve_part_length(byte_val, self.pattern))

        elif self.pattern in {Pattern.UNSIGNED_LONG_SHORT_PATTERN, Pattern.LONG_SHORT_PATTERN}:
            self.part_length = 1
            self.state = 'data'

        elif self.pattern in {Pattern.UNSIGNED_LONG_PATTERN, Pattern.LONG_PATTERN}:
            self.part_length = 6
            self.state = 'data'

        elif self.pattern == Pattern.DOUBLE_PATTERN:
            self.part_length = 8
            self.state = 'data'

        elif self.pattern == Pattern.FLOAT_PATTERN:
            self.part_length = 4
            self.state = 'data'

        elif self.pattern == Pattern.BOOLEAN_TRUE_PATTERN:
            self._on_value(True)

        elif self.pattern == Pattern.BOOLEAN_FALSE_PATTERN:
            self._on_value(False)

    def _handle_pattern_data(self, value_bytes):
        try:
            def padded(b, size): return b.rjust(size, b'\x00')
            patterns = {
                Pattern.STRING_SHORT_PATTERN: lambda b: b.decode('utf-8'),
                Pattern.STRING_PATTERN: lambda b: b.decode('utf-8'),
                Pattern.UNSIGNED_INT_PATTERN: lambda b: struct.unpack(">I", padded(b, 4))[0],
                Pattern.INT_PATTERN: lambda b: struct.unpack(">i", padded(b, 4))[0],
                Pattern.UNSIGNED_LONG_SHORT_PATTERN: lambda b: struct.unpack(">Q", padded(b, 8))[0],
                Pattern.UNSIGNED_LONG_PATTERN: lambda b: struct.unpack(">Q", padded(b, 8))[0],
                Pattern.LONG_SHORT_PATTERN: lambda b: struct.unpack(">q", padded(b, 8))[0],
                Pattern.LONG_PATTERN: lambda b: struct.unpack(">q", padded(b, 8))[0],
                Pattern.DOUBLE_PATTERN: lambda b: struct.unpack(">d", padded(b, 8))[0],
                Pattern.FLOAT_PATTERN: lambda b: struct.unpack(">f", padded(b, 4))[0],
                Pattern.BYTE_ARRAY_PATTERN: lambda b: b,
                Pattern.BYTE_ARRAY_SHORT_PATTERN: lambda b: b,
            }
            self._on_value(patterns.get(
                self.pattern, lambda b: None)(value_bytes))
        except Exception as e:
            import logging
            logging.error(
                f"Deserialization failed for pattern {self.pattern}: {e}")
            self._on_value(None)

    def _on_value(self, value):
        if self.length == -1:
            self.length = value
        else:
            self.message.append(value)
            if len(self.message) == self.length + 1:
                self.values.append(self.message)
                self.message = []
                self.length = -1


def retrieve_flag_pattern(byte_val):
    int_patterns = [v for v in Pattern if isinstance(v, IntEnum)]
    for pattern in sorted(int_patterns, reverse=True):
        if (byte_val & pattern) == pattern:
            return pattern
    return Pattern.DOES_NOT_EXIST


def retrieve_part_length(byte_val, pattern):
    return byte_val & ~pattern
