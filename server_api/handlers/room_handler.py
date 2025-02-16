import uuid
from datetime import datetime
import logging
import json


def create_room(room_id, room_type, visible):
    if not room_id or not room_type:
        raise ValueError("room_id et room_type doivent être fournis")

    if room_id.lower() == "auto":
        room_id = str(uuid.uuid4())

    room_data = {
        "roomId": room_id,
        "roomType": room_type,
        "visible": visible,
        "createdAt": datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S"),
        "status": "active",
        "players": [],
    }

    store_room(room_data)

    logging.info(f"Room created: {room_data}")

    return f"Room {room_id} of type {room_type} created successfully."


def store_room(room_data):
    print(f"Room data saved: {room_data}")
