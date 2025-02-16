import struct


def create_error_response(error_msg):
    response = b"\x00"
    response += struct.pack(">H", len(error_msg))
    response += error_msg.encode("utf-8")
    return response
