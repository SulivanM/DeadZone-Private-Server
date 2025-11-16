package common

import java.util.UUID as JavaUUID

/**
 * Ansi colors (256) constants to style console.
 */
@Suppress("unused", "ConstPropertyName")
object AnsiColors {
    const val Reset = "\u001B[0m"

    const val BlackText = "\u001B[38;5;16m"
    const val WhiteText = "\u001B[38;5;255m"

    const val Success = "\u001B[48;5;120m"
    const val Debug = "\u001B[48;5;223m"
    const val Info = "\u001B[48;5;153m"
    const val Warn = "\u001B[48;5;221m"
    const val Error = "\u001B[48;5;203m"

    fun fg(n: Int) = "\u001B[38;5;${n}m"
    fun bg(n: Int) = "\u001B[48;5;${n}m"
}

/**
 * Emoji constants where each uses unicode character. Source: https://emojidb.org
 *
 * Use these constants to ensure that emojis are shown correctly everywhere.
 */
@Suppress("unused", "ConstPropertyName")
object Emoji {
    const val Red = "\uD83D\uDD34"              // 🔴
    const val Orange = "\uD83D\uDFE0"           // 🟠
    const val Yellow = "\uD83D\uDFE1"           // 🟡
    const val Green = "\uD83D\uDFE2"            // 🟢
    const val Blue = "\uD83D\uDD35"             // 🔵
    const val Debug = "\uD83D\uDD0E"            // 🔎
    const val Info = "ℹ\uFE0F"                 // ℹ️
    const val Warn = "⚠\uFE0F"                 // ⚠️
    const val Error = "❌"                      // ❌
    const val Party = "\uD83C\uDF89"            // 🎉
    const val Satellite = "\uD83D\uDCE1"        // 📡
    const val Internet = "\uD83C\uDF10"         // 🌐
    const val Rocket = "\uD83D\uDE80"           // 🚀
    const val Database = "\uD83D\uDDC4\uFE0F"   // 🗄️
    const val Gaming = "\uD83D\uDD79\uFE0F"     // 🕹️
    const val Save = "\uD83D\uDCBE"             // 💾
    const val Phone = "\uD83D\uDCF1"            // 📱
}

/**
 * ByteArray extension to sanitize and convert to string
 */
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

/**
 * UUID utilities
 */
object UUID {
    /**
     * Returns an uppercased UUID from java.util.uuid.
     *
     * game used uppercase UUID so make sure to ignorecase when comparing or just use uppercase UUID too
     */
    fun new(): String {
        return JavaUUID.randomUUID().toString().uppercase()
    }
}

/**
 * Time utilities
 */
object Time {
    /**
     * Return the epoch millis in Double type.
     *
     * IMPORTANT! TLSDZ AS3 code uses msg.getNumber(n++) to get the serverTime
     * If we send the epoch in Long, this means getNumber will fail and will default to 0 instead
     * Using Double type is better because it won't fail.
     */
    fun now(): Double {
        return io.ktor.util.date.getTimeMillis().toDouble()
    }
}
