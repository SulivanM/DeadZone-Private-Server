package dev.deadzone.socket.messaging

/**
 * CC commands constants used by the game.
 */
@Suppress("Unused", "SpellCheckingInspection")
object CommandMessage {
    const val STORE_CLEAR = "storeClear"
    const val STORE_BLOCK = "storeBlock"
    const val SPAWN_ELITE = "spawnelite"
    const val ELITE_CHANCE = "elitechance"
    const val ADD_BOUNTY = "addbounty"
    const val LEVEL = "level"
    const val SERVER_TIME = "serverTime"
    const val ZOMBIE = "zombie"
    const val TIME = "time"
    const val STAT = "stat"
    const val GIVE_AMOUNT = "giveAmount"
    const val GIVE = "give"
    const val GIVE_RARE = "giveRare"
    const val GIVE_UNIQUE = "giveUnique"
    const val COUNTER = "counter"
    const val DAILY_QUEST = "dq"
    const val CHAT = "chat"
    const val LANG = "lang"
    const val FLAG = "flag"
    const val PROMO = "promo"
    const val BOUNTY_ADD = "badd"
    const val GIVE_INFECTED_BOUNTY = "giveinfectedbounty"
    const val BOUNTY_ABANDON = "bountyabandon"
    const val BOUNTY_COMPLETE = "bountycomplete"
    const val BOUNTY_TASK_COMPLETE = "bountytaskcomplete"
    const val BOUNTY_CONDITION_COMPLETE = "bountycondcomplete"
    const val BOUNTY_KILL = "bountykill"
    const val SKILL_GIVEXP = "skillgivexp"
    const val SKILL_LEVEL = "skilllevel"

    val COMMAND_SAVES = setOf(
        STORE_CLEAR,
        STORE_BLOCK,
        SPAWN_ELITE,
        ELITE_CHANCE,
        ADD_BOUNTY,
        LEVEL,
        SERVER_TIME,
        ZOMBIE,
        TIME,
        STAT,
        GIVE_AMOUNT,
        GIVE,
        GIVE_RARE,
        GIVE_UNIQUE,
        COUNTER,
        DAILY_QUEST,
        CHAT,
        LANG,
        FLAG,
        PROMO,
        BOUNTY_ADD,
        GIVE_INFECTED_BOUNTY,
        BOUNTY_ABANDON,
        BOUNTY_COMPLETE,
        BOUNTY_TASK_COMPLETE,
        BOUNTY_CONDITION_COMPLETE,
        BOUNTY_KILL,
        SKILL_GIVEXP,
        SKILL_LEVEL,
    )
}
