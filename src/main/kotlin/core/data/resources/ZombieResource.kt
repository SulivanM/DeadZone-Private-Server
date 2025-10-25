package core.data.resources

data class ZombieResource(
    val id: String,
    val type: String,
    val weapon: WeaponData? = null
)

data class ZombieSounds(
    val male: ZombieVoiceSet? = null,
    val female: ZombieVoiceSet? = null,
    val dog: ZombieVoiceSet? = null
)

data class ZombieVoiceSet(
    val alert: List<String> = emptyList(),
    val idle: List<String> = emptyList(),
    val death: List<String> = emptyList(),
    val attack: List<String> = emptyList(),
    val hurt: List<String> = emptyList()
)

data class ZombieLimits(
    val tags: Map<Int, String> = emptyMap()
)
