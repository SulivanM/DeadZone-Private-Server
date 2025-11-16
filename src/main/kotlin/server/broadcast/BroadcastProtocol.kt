package server.broadcast

/**
 * Broadcast protocols matching the client-side BroadcastSystemProtocols
 */
enum class BroadcastProtocol(val code: String) {
    STATIC("static"),
    ADMIN("admin"),
    WARNING("warn"),
    SHUT_DOWN("shtdn"),
    ITEM_UNBOXED("itmbx"),
    ITEM_FOUND("itmfd"),
    RAID_ATTACK("raid"),
    RAID_DEFEND("def"),
    ITEM_CRAFTED("crft"),
    ACHIEVEMENT("ach"),
    USER_LEVEL("lvl"),
    SURVIVOR_COUNT("srvcnt"),
    ZOMBIE_ATTACK_FAIL("zfail"),
    ALL_INJURED("injall"),
    PLAIN_TEXT("plain"),
    BOUNTY_ADD("badd"),
    BOUNTY_COLLECTED("bcol"),
    ALLIANCE_RAID_SUCCESS("ars"),
    ALLIANCE_RANK("arank"),
    ARENA_LEADERBOARD("arenalb"),
    RAIDMISSION_STARTED("rmstart"),
    RAIDMISSION_COMPLETE("rmcompl"),
    RAIDMISSION_FAILED("rmfail"),
    HAZ_SUCCESS("hazwin"),
    HAZ_FAIL("hazlose");

    companion object {
        fun fromCode(code: String): BroadcastProtocol? = values().find { it.code == code }
    }
}
