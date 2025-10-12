package dev.deadzone.utils

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
