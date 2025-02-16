from serializers.deserializer import deserialize_data
from serializers.serializer import Serializer
from handlers.error_handler import create_error_response
import logging
import json
import re
from datetime import datetime


def clean_room_data(raw_data):
    cleaned_data = re.sub(r"[^\x20-\x7E]", "", raw_data).strip()
    cleaned_data = cleaned_data.replace("\n", "").replace("\r", "")
    parts = [p.strip() for p in re.split(r"[\$*]", cleaned_data) if p.strip()]

    if len(parts) < 2:
        raise ValueError(f"Invalid room data format: {parts}")

    room_id, room_type = parts[0], parts[1]

    if not re.match(r"^[a-zA-Z0-9_-]+$", room_id):
        raise ValueError(f"Invalid room_id: {room_id}")

    return room_id, room_type, parts[2:]


def process_request(rpc_method, data):
    try:
        if rpc_method == 418:
            return b"\x01" + b"\x00\x00\x00"

        if rpc_method == 27:
            values = deserialize_data(data)
            if not values:
                raise ValueError("No room data found in the request")

            room_data = values[0]
            room_id, room_type, extra_data = clean_room_data(room_data)
            valid_room_types = {
                "TLS-DeadZone-Game-28",
                "ChatRoom-14",
                "TradeRoom-10",
                "Alliance-6",
            }

            if room_type not in valid_room_types:
                raise ValueError(f"Invalid room_type: {room_type}")

            room = {
                "roomId": room_id,
                "roomType": room_type,
                "extraData": extra_data,
                "createdAt": datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S"),
                "status": "active",
                "players": [],
            }

            return json.dumps(room).encode("utf-8")

    except Exception as e:
        logging.error(f"Exception: {str(e)}")
        error_response = {"error": str(e)}
        return json.dumps(error_response).encode("utf-8")
