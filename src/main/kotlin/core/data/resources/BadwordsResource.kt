package core.data.resources

data class BadwordsResource(
    val variations: Map<String, String> = emptyMap(),
    val words: List<BadWord> = emptyList()
)

data class BadWord(
    val word: String,
    val important: Boolean = false
)
