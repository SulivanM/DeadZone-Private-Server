---
title: NetworkMessage
slug: thelaststand/app/network/networkmessage
description: NetworkMessage
---

TLSDZ uses the [`Message`](/playerio/message) object for communication. The `NetworkMessage` class contains a list of static string constants that define the types of messages used in the game's communication between the client and the socket server.

## List of Network Messages

Additionally, `"playerio.joinresult"` which is hardcoded in [`Connection`](/playerio/connection) for initial server connection.

```
INIT_COMPLETE              = "ic"      | ERROR                          = "err"
BANNED                     = "ban"     | SEND_RESPONSE                  = "r"
SERVER_SHUTDOWN_UPDATE     = "ssu"     | SERVER_SHUTDOWN_MAINTENANCE    = "ssm"
SERVER_ROOM_DISABLED       = "srd"     | SERVER_SETTINGS                = "ssup"
SERVER_NEW_VERSION         = "snv"     | GAME_READY                     = "gr"
GAME_LOADING_PROGRESS      = "gp"      | SERVER_INIT_PROGRESS           = "sip"
SIGN_IN_FAILED             = "sf"      | SCENE_READY                    = "sr"
SCENE_REQUEST              = "srq"     | SERVER_UPDATE                  = "su"
TIME_UPDATE                = "tu"      | OUT_OF_SYNC                    = "os"
PURCHASE_COINS             = "p"       | SAVE                           = "s"
SAVE_SUCCCESS              = "ss"      | MISSION_LOOT                   = "ml"
RESOURCE_UPDATE            = "ru"      | SURVIVOR_NEW                   = "sn"
PLAYER_VIEW_REQUEST        = "pvr"     | PLAYER_ATTACK_REQUEST          = "par"
PLAYER_ATTACK_RESPONSE     = "parp"    | HELP_PLAYER                    = "hp"
NEW_NOTIFICATIONS          = "nn"      | UNDER_ATTACK                   = "ua"
ZOMBIE_ATTACK              = "za"      | GET_PLAYER_SURVIVOR            = "ps"
GET_NEIGHBOR_STATES        = "ns"      | REQUEST_ZOMBIE_ATTACK          = "rza"
REQUEST_SURVIVOR_CHECK     = "rsc"     | TASK_COMPLETE                  = "tc"
BUILDING_COMPLETE          = "bc"      | BUILDING_REPAIR_COMPLETE       = "brpc"
MISSION_RETURN_COMPLETE    = "mrc"     | MISSION_LOCK_COMPLETE          = "mlc"
SURVIVOR_INJURY_COMPLETE   = "sic"     | BATCH_RECYCLE_COMPLETE         = "brc"
QUEST_PROGRESS             = "qp"      | QUEST_DAILY_FAILED             = "qdf"
QUEST_ARMOR_GAMES_COMPLETE = "agq"     | SURVIVOR_REASSIGNMENT_COMPLETE = "src"
EFFECT_COMPLETE            = "ec"      | EFFECT_LOCKOUT_COMPLETE        = "elc"
COOLDOWN_COMPLETE          = "cc"      | FLAG_CHANGED                   = "fc"
UPGRADE_FLAG_CHANGED       = "ufc"     | MISSION_EVENT                  = "me"
PVP_LIST_UPDATE            = "pvplist" | SCAV_STARTED                   = "scvstrt"
SCAV_ENDED                 = "scvend"  | FUEL_UPDATE                    = "fuel"
TRADE_DISABLED             = "td"      | LINKED_ALLIANCES               = "alink"
RESEARCH_COMPLETE          = "rscmp"   | GLOBAL_QUEST_CONTRIBUTE        = "gqcon"
GLOBAL_QUEST_PROGRESS      = "gqpr"    | BOUNTY_COMPLETE                = "bcmp"
BOUNTY_TASK_COMPLETE       = "btcmp"   | BOUNTY_TASK_CONDITION_COMPLETE = "btccmp"
BOUNTY_UPDATE              = "bup"     | RPC                            = "rpc"
RPC_RESPONSE               = "rpcr"
```
