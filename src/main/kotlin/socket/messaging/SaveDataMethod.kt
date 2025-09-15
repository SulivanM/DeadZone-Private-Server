package dev.deadzone.socket.messaging

/**
 * Save data method constants used by the game.
 */
@Suppress("Unused", "SpellCheckingInspection")
object SaveDataMethod {
    // -------------------- COMPOUND_BUILDING --------------------
    const val BUILDING_CREATE = "bld_create"
    const val BUILDING_CREATE_BUY = "bld_create_buy"
    const val BUILDING_UPGRADE = "bld_upgrade"
    const val BUILDING_UPGRADE_BUY = "bld_upgrade_buy"
    const val BUILDING_MOVE = "bld_move"
    const val BUILDING_RECYCLE = "bld_recycle"
    const val BUILDING_COLLECT = "bld_collect"
    const val BUILDING_CANCEL = "bld_cancel"
    const val BUILDING_SPEED_UP = "bld_speedup"
    const val BUILDING_REPAIR = "bld_repair"
    const val BUILDING_REPAIR_BUY = "bld_repair_buy"
    const val BUILDING_REPAIR_SPEED_UP = "bld_repair_speedup"
    const val BUILDING_TRAP_EXPLODE = "bld_trap_exp"

    val COMPOUND_BUILDING_SAVES = setOf(
        BUILDING_CREATE,
        BUILDING_CREATE_BUY,
        BUILDING_UPGRADE,
        BUILDING_UPGRADE_BUY,
        BUILDING_MOVE,
        BUILDING_RECYCLE,
        BUILDING_COLLECT,
        BUILDING_CANCEL,
        BUILDING_SPEED_UP,
        BUILDING_REPAIR,
        BUILDING_REPAIR_BUY,
        BUILDING_REPAIR_SPEED_UP,
        BUILDING_TRAP_EXPLODE,
    )

    // -------------------- COMPOUND_TASK --------------------
    const val TASK_STARTED = "tsk_start"
    const val TASK_CANCELLED = "tsk_cancelled"
    const val TASK_SURVIVOR_ASSIGNED = "tsk_srv_assign"
    const val TASK_SURVIVOR_REMOVED = "tsk_srv_remove"
    const val TASK_SPEED_UP = "tsk_speedup"

    val COMPOUND_TASK_SAVES = setOf(
        TASK_STARTED,
        TASK_CANCELLED,
        TASK_SURVIVOR_ASSIGNED,
        TASK_SURVIVOR_REMOVED,
        TASK_SPEED_UP,
    )

    // -------------------- COMPOUND_MISC --------------------
    const val CRAFT_ITEM = "craft_item"
    const val CRAFT_UPGRADE = "craft_upgrade"
    const val CRAFT_SCHEMATIC = "craft_schematic"
    const val EFFECT_SET = "effect_set"
    const val RESEARCH_START = "rsstrt"
    const val AH_EVENT = "ahEvent"
    const val CULL_NEIGHBORS = "cullneighbors"
    const val RALLY_ASSIGNMENT = "rally_assign"

    val COMPOUND_MISC_SAVES = setOf(
        CRAFT_ITEM,
        CRAFT_UPGRADE,
        CRAFT_SCHEMATIC,
        EFFECT_SET,
        RESEARCH_START,
        AH_EVENT,
        CULL_NEIGHBORS,
        RALLY_ASSIGNMENT
    )

    // -------------------- ITEM --------------------
    const val ITEM = "itm"
    const val ITEM_BUY = "itm_buy"
    const val ITEM_LIST = "itm_list"
    const val ITEM_RECYCLE = "itm_recycle"
    const val ITEM_DISPOSE = "itm_dispose"
    const val ITEM_CLEAR_NEW = "itm_clear_new"
    const val ITEM_BATCH_RECYCLE = "itm_batch_recycle"
    const val ITEM_BATCH_RECYCLE_SPEED_UP = "itm_batch_recycle_speedup"
    const val ITEM_BATCH_DISPOSE = "itm_batch_dispose"

    val ITEM_SAVES = setOf(
        ITEM,
        ITEM_BUY,
        ITEM_LIST,
        ITEM_RECYCLE,
        ITEM_DISPOSE,
        ITEM_CLEAR_NEW,
        ITEM_BATCH_RECYCLE,
        ITEM_BATCH_RECYCLE_SPEED_UP,
        ITEM_BATCH_DISPOSE,
    )

    // -------------------- MISSION --------------------
    const val MISSION_START = "mis_start"
    const val MISSION_END = "mis_end"
    const val MISSION_INJURY = "mis_inj"
    const val MISSION_SPEED_UP = "mis_speedup"
    const val MISSION_ZOMBIES = "mis_zombies"
    const val MISSION_START_FLAG = "mis_startFlag"
    const val MISSION_INTERACTION_FLAG = "mis_interacted"
    const val MISSION_SCOUTED = "mis_scouted"
    const val MISSION_ITEM_USE = "mis_use"
    const val MISSION_TRIGGER = "mis_trig"
    const val MISSION_ELITE_SPAWNED = "mis_elsp"
    const val MISSION_ELITE_KILLED = "mis_elkl"

    val MISSION_SAVES = setOf(
        MISSION_START,
        MISSION_END,
        MISSION_INJURY,
        MISSION_SPEED_UP,
        MISSION_ZOMBIES,
        MISSION_START_FLAG,
        MISSION_INTERACTION_FLAG,
        MISSION_SCOUTED,
        MISSION_ITEM_USE,
        MISSION_TRIGGER,
        MISSION_ELITE_SPAWNED,
        MISSION_ELITE_KILLED,
        STAT_DATA,
        STAT
    )

    // -------------------- SURVIVOR --------------------
    const val SURVIVOR_CLASS = "srv_class"
    const val SURVIVOR_OFFENCE_LOADOUT = "srv_oLoadout"
    const val SURVIVOR_DEFENCE_LOADOUT = "srv_dLoadout"
    const val SURVIVOR_CLOTHING_LOADOUT = "srv_cLoadout"
    const val SURVIVOR_INJURY_SPEED_UP = "srv_injury_speedup"
    const val SURVIVOR_RENAME = "srv_rename"
    const val SURVIVOR_REASSIGN = "srv_reassign"
    const val SURVIVOR_REASSIGN_SPEED_UP = "srv_reassign_speedup"
    const val SURVIVOR_BUY = "srv_buy"
    const val SURVIVOR_INJURE = "srv_inj"
    const val SURVIVOR_ENEMY_INJURE = "srv_einj"
    const val SURVIVOR_HEAL_INJURY = "srv_heal"
    const val SURVIVOR_HEAL_ALL = "srv_healall"
    const val PLAYER_CUSTOM = "ply_custom"
    const val SURVIVOR_EDIT = "srv_edit"
    const val NAMES = "names"
    const val RESET_LEADER = "resetLeader"

    val SURVIVOR_SAVES = setOf(
        SURVIVOR_CLASS,
        SURVIVOR_OFFENCE_LOADOUT,
        SURVIVOR_DEFENCE_LOADOUT,
        SURVIVOR_CLOTHING_LOADOUT,
        SURVIVOR_INJURY_SPEED_UP,
        SURVIVOR_RENAME,
        SURVIVOR_REASSIGN,
        SURVIVOR_REASSIGN_SPEED_UP,
        SURVIVOR_BUY,
        SURVIVOR_INJURE,
        SURVIVOR_ENEMY_INJURE,
        SURVIVOR_HEAL_INJURY,
        SURVIVOR_HEAL_ALL,
        PLAYER_CUSTOM,
        SURVIVOR_EDIT,
        NAMES,
        RESET_LEADER,
    )

    // -------------------- RAID --------------------
    const val RAID_START = "raid_start"
    const val RAID_CONTINUE = "raid_cont"
    const val RAID_ABORT = "raid_abort"
    const val RAID_DEATH = "raid_death"

    val RAID_SAVES = setOf(
        RAID_START,
        RAID_CONTINUE,
        RAID_ABORT,
        RAID_DEATH,
    )

    // -------------------- ARENA --------------------
    const val ARENA_START = "arena_start"
    const val ARENA_CONTINUE = "arena_cont"
    const val ARENA_FINISH = "arena_fin"
    const val ARENA_ABORT = "arena_abort"
    const val ARENA_DEATH = "arena_death"
    const val ARENA_UPDATE = "arena_update"
    const val ARENA_LEADER = "arena_ldr"
    const val ARENA_LEADERBOARD = "arena_lb"

    val ARENA_SAVES = setOf(
        ARENA_START,
        ARENA_CONTINUE,
        ARENA_FINISH,
        ARENA_ABORT,
        ARENA_DEATH,
        ARENA_UPDATE,
        ARENA_LEADER,
        ARENA_LEADERBOARD,
    )

    // -------------------- QUEST --------------------
    const val QUEST_COLLECT = "quest_collect"
    const val QUEST_TRACK = "quest_track"
    const val QUEST_UNTRACK = "quest_untrack"
    const val QUEST_DAILY_DECLINE = "quest_daily_dec"
    const val QUEST_DAILY_ACCEPT = "quest_daily_acc"
    const val REPEAT_ACHIEVEMENT = "rep_ach"
    const val GLOBAL_QUEST_COLLECT = "gQuest_collect"

    val QUEST_SAVES = setOf(
        QUEST_COLLECT,
        QUEST_TRACK,
        QUEST_UNTRACK,
        QUEST_DAILY_DECLINE,
        QUEST_DAILY_ACCEPT,
        REPEAT_ACHIEVEMENT,
        GLOBAL_QUEST_COLLECT
    )

    // -------------------- CRATE --------------------
    const val CRATE_UNLOCK = "crate_unlock"
    const val CRATE_MYSTERY_UNLOCK = "crate_mystery_unlock"

    val CRATE_SAVES = setOf(
        CRATE_UNLOCK,
        CRATE_MYSTERY_UNLOCK
    )

    // -------------------- ALLIANCE --------------------
    const val ALLIANCE_CREATE = "alliance_create"
    const val ALLIANCE_COLLECT_WINNINGS = "alliance_collectWinnings"
    const val ALLIANCE_QUERY_WINNINGS = "alliance_queryWinnings"
    const val ALLIANCE_GET_PREV_ROUND_RESULT = "alliance_getPrevRoundResults"
    const val ALLIANCE_EFFECT_UPDATE = "alliance_effects"
    const val ALLIANCE_INFORM_ABOUT_LEAVE = "alliance_informAboutLeave"
    const val ALLIANCE_GET_LIFETIMESTATS = "alliance_getLifeStats"

    val ALLIANCE_SAVES = setOf(
        ALLIANCE_CREATE,
        ALLIANCE_COLLECT_WINNINGS,
        ALLIANCE_QUERY_WINNINGS,
        ALLIANCE_GET_PREV_ROUND_RESULT,
        ALLIANCE_EFFECT_UPDATE,
        ALLIANCE_INFORM_ABOUT_LEAVE,
        ALLIANCE_GET_LIFETIMESTATS,
    )

    // -------------------- CHAT --------------------
    const val CHAT_SILENCED = "chat_silenced"
    const val CHAT_KICKED = "chat_kicked"
    const val CHAT_GET_CONTACTS_AND_BLOCKS = "chat_getContactsBlocks"
    const val CHAT_MIGRATE_CONTACTS_AND_BLOCKS = "chat_migrateContactsBlocks"
    const val CHAT_ADD_CONTACT = "chat_addContact"
    const val CHAT_REMOVE_CONTACT = "chat_removeContact"
    const val CHAT_REMOVE_ALL_CONTACTS = "chat_removeAllContacts"
    const val CHAT_ADD_BLOCK = "chat_addBlock"
    const val CHAT_REMOVE_BLOCK = "chat_removeBlock"
    const val CHAT_REMOVE_ALL_BLOCKS = "chat_removeAllBlocks"

    val CHAT_SAVES = setOf(
        CHAT_SILENCED,
        CHAT_KICKED,
        CHAT_GET_CONTACTS_AND_BLOCKS,
        CHAT_MIGRATE_CONTACTS_AND_BLOCKS,
        CHAT_ADD_CONTACT,
        CHAT_REMOVE_CONTACT,
        CHAT_REMOVE_ALL_CONTACTS,
        CHAT_ADD_BLOCK,
        CHAT_REMOVE_BLOCK,
        CHAT_REMOVE_ALL_BLOCKS,
    )

    // -------------------- BOUNTY --------------------
    const val BOUNTY_VIEW = "dzbountyview"
    const val BOUNTY_SPEED_UP = "dzbountyspeedup"
    const val BOUNTY_NEW = "dzbountynew"
    const val BOUNTY_ABANDON = "dzbountyabn"
    const val BOUNTY_ADD = "addBounty"

    val BOUNTY_SAVES = setOf(
        BOUNTY_VIEW,
        BOUNTY_SPEED_UP,
        BOUNTY_NEW,
        BOUNTY_ABANDON,
        BOUNTY_ADD,
    )

    // -------------------- PURCHASE --------------------
    const val RESOURCE_BUY = "res_buy"
    const val PROTECTION_BUY = "prot_buy"
    const val PAYVAULT_BUY = "payvault_buy"
    const val CLAIM_PROMO_CODE = "claim_promo"
    const val BUY_PACKAGE = "pack_buy"
    const val CHECK_APPLY_DIRECT_PURCHASE = "chk_dp"
    const val HAS_PAYVAULT_ITEM = "haspvitem"
    const val INCREMENT_PURCHASE_COUNT = "incPrchCnt"
    const val DEATH_MOBILE_RENAME = "dm_rename"

    val PURCHASE_SAVES = setOf(
        RESOURCE_BUY,
        PROTECTION_BUY,
        PAYVAULT_BUY,
        CLAIM_PROMO_CODE,
        BUY_PACKAGE,
        CHECK_APPLY_DIRECT_PURCHASE,
        HAS_PAYVAULT_ITEM,
        INCREMENT_PURCHASE_COUNT,
        DEATH_MOBILE_RENAME
    )

    // -------------------- COMMON --------------------
    const val STAT = "stat"
    const val GET_STATS = "stat_get"
    const val GLOBAL_STAT = "gstat"
    const val STAT_DATA = "stat_data"

    // -------------------- MISC --------------------
    const val TUTORIAL_PVP_PRACTICE = "tut_pvppractice"
    const val TUTORIAL_COMPLETE = "tut_complete"
    const val GET_OFFERS = "get_offers"
    const val NEWS_READ = "news_read"
    const val CLEAR_NOTIFICATIONS = "clear_notes"
    const val FLUSH_PLAYER = "flushPlayer"
    const val SAVE_ALT_IDS = "savealts"
    const val TRADE_DO_TRADE = "trade_doTrade"
    const val GET_INVENTORY_SIZE = "get_invsize"

    val MISC_SAVES = setOf(
        TUTORIAL_PVP_PRACTICE,
        TUTORIAL_COMPLETE,
        GET_OFFERS,
        NEWS_READ,
        CLEAR_NOTIFICATIONS,
        FLUSH_PLAYER,
        SAVE_ALT_IDS,
        TRADE_DO_TRADE,
        GET_INVENTORY_SIZE
    )
}
