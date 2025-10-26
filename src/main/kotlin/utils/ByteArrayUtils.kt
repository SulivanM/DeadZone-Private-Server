package utils

fun ByteArray.sanitizedString(max: Int = 512, placeholder: Char = '.'): String {
    val decoded = String(this, Charsets.UTF_8)
    val sanitized = decoded.map { ch ->
        if (ch.isISOControl() && ch != '\n' && ch != '\r' && ch != '\t') placeholder
        else if (!ch.isDefined() || !ch.isLetterOrDigit() && ch !in setOf(
                ' ', '.', ',', ':', ';', '-', '_',
                '{', '}', '[', ']', '(', ')', '"',
                '\'', '/', '\\', '?', '=', '+', '*',
                '%', '&', '|', '<', '>', '!', '@',
                '#', '$', '^', '~'
            )
        ) placeholder
        else ch
    }.joinToString("")
    return sanitized.take(max) + if (sanitized.length > max) "..." else ""
}
