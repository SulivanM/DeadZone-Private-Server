package core.data.resources

data class EffectResource(
    val id: String,
    val icon: String? = null,
    val image: String? = null,
    val group: String? = null,
    val find: Int = 1,
    val types: List<String> = emptyList()
)
