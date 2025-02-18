from serializers.deserializer import deserialize_data
from serializers.serializer import Serializer
from handlers.error_handler import create_error_response
import logging
import json
import re
from datetime import datetime

def process_request(rpc_method, data):
    try:
        if rpc_method == 418:
            return b"\x01" + b"\x00\x00\x00"

        if rpc_method == 27:
            return b"\x01" + b"\x00\x00\x00"

        if rpc_method == 50:
            return b"\x01" + b"\x00\x00\x00"

    except Exception as e:
        logging.error(f"Exception: {str(e)}")
        error_response = {"error": str(e)}
        return json.dumps(error_response).encode("utf-8")
