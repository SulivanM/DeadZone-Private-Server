# Based onGameReady at Network.as

import json
import struct
import gzip

# The game expects binaries data. From the looks of it, it expects config.xml, buildings.xml, resources_secondary.xml from onNetworkGameDataReceived (Main.as), and allianes.xml from AllianceSystem.as.
def generate_binaries(entries):
    payload = bytearray()

    # sending 4 files
    payload.append(4)
    
    for path, uri, is_compressed in entries:
        with open(path, "rb") as f:
            raw = f.read()
        data = raw if is_compressed else gzip.compress(raw)

        encoded_uri = uri.encode("utf-8")
        payload += struct.pack("<H", len(encoded_uri))
        payload += encoded_uri
        payload += struct.pack("<I", len(data))
        payload += data

    return bytes(payload)

# Cost table, possibly the game building, upgrade, or item prices?
def generate_cost_table():
    return json.dumps(
        {
            "buildings": {
                "barricade": {"wood": 10, "metal": 5},
                "turret": {"wood": 50, "metal": 25}
            },
            "upgrades": {
                "storage": {"cost": 1000},
                "speed": {"cost": 500}
            }
        }
    )

# Must be the survivor data table
def generate_srv_table():
    return json.dumps({
        "fighter": {
            "name": "Fighter",
            "health": 100,
            "skills": ["melee", "endurance"]
        },
        "medic": {
            "name": "Medic",
            "health": 80,
            "skills": ["heal", "support"]
        }
    })

# Player login state, includes info updates from server and the thing that has been going on since player offline (like finished war or attack report)
def generate_login_state():
    return json.dumps({
        "settings": {
            "volume": 0.8,
            "language": "en"
        },
        "news": {
            "event": "Double XP Weekend"
        },
        "sales": [
            ["weapons", "discount"],
            ["armor", "clearance"]
        ],
        "allianceWinnings": {
            "gold": 500,
            "medals": 2
        },
        "recentPVPList": [
            {"opponent": "Player123", "result": "win"},
            {"opponent": "Player456", "result": "loss"}
        ]
    })
