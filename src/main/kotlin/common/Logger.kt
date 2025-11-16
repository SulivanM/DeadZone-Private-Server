package common
import io.ktor.server.routing.*
import io.ktor.util.date.*
import java.io.File
import java.io.FileDescriptor
import java.io.FileOutputStream
import java.io.PrintStream
import java.text.SimpleDateFormat

fun RoutingContext.logInput(txt: Any?, logFull: Boolean = false, disableLogging: Boolean = false) {
    if (!disableLogging) {
        Logger.info(LogSource.API, logFull = logFull) { "Received [API ${call.parameters["path"]}]: $txt" }
    }
}

fun RoutingContext.logOutput(txt: ByteArray?, logFull: Boolean = false, disableLogging: Boolean = false) {
    if (!disableLogging) {
        Logger.info(
            LogSource.API,
            logFull = logFull
        ) { "Sent [API ${call.parameters["path"]}]: ${txt?.decodeToString()}" }
    }
}

object Logger {
    private val logFileMap = mapOf(
        LogFile.CLIENT_WRITE_ERROR to File("logs/client_write_error-1.log"),
        LogFile.ASSETS_ERROR to File("logs/assets_error-1.log"),
        LogFile.API_SERVER_ERROR to File("logs/api_server_error-1.log"),
        LogFile.SOCKET_SERVER_ERROR to File("logs/socket_server_error-1.log"),
    ).also { File("logs").mkdirs() }

    private var level: LogLevel = LogLevel.DEBUG
    private var colorfulLog = true
    private const val MAX_LOG_LENGTH = 500
    private const val MAX_LOG_FILE_SIZE = 5 * 1024 * 1024
    private const val MAX_LOG_ROTATES = 5
    private val dateFormatter = SimpleDateFormat("yyyy-MM-dd HH:mm:ss")

    fun success(msg: String) = success { msg }
    fun success(config: LogConfig, forceLogFull: Boolean? = null, msg: () -> String) =
        success(config.src, config.targets, forceLogFull ?: config.logFull, msg)

    fun success(
        src: LogSource = LogSource.SOCKET,
        targets: Set<LogTarget> = setOf(LogTarget.PRINT),
        logFull: Boolean = false,
        msg: () -> String
    ) = log(src, targets, LogLevel.SUCCESS, msg, logFull)

    fun debug(msg: String) = debug { msg }
    fun debug(config: LogConfig, forceLogFull: Boolean? = null, msg: () -> String) =
        debug(config.src, config.targets, forceLogFull ?: config.logFull, msg)

    fun debug(
        src: LogSource = LogSource.SOCKET,
        targets: Set<LogTarget> = setOf(LogTarget.PRINT),
        logFull: Boolean = true,
        msg: () -> String
    ) = log(src, targets, LogLevel.DEBUG, msg, logFull)

    fun info(msg: String) = info { msg }
    fun info(config: LogConfig, forceLogFull: Boolean? = null, msg: () -> String) =
        info(config.src, config.targets, forceLogFull ?: config.logFull, msg)

    fun info(
        src: LogSource = LogSource.SOCKET,
        targets: Set<LogTarget> = setOf(LogTarget.PRINT),
        logFull: Boolean = false,
        msg: () -> String
    ) = log(src, targets, LogLevel.INFO, msg, logFull)

    fun warn(msg: String) = warn { msg }
    fun warn(config: LogConfig, forceLogFull: Boolean? = null, msg: () -> String) =
        warn(config.src, config.targets, forceLogFull ?: config.logFull, msg)

    fun warn(
        src: LogSource = LogSource.SOCKET,
        targets: Set<LogTarget> = setOf(LogTarget.PRINT),
        logFull: Boolean = false,
        msg: () -> String
    ) = log(src, targets, LogLevel.WARN, msg, logFull)

    fun error(msg: String) = error { msg }
    fun error(config: LogConfig, forceLogFull: Boolean? = null, msg: () -> String) =
        error(config.src, config.targets, forceLogFull ?: config.logFull, msg)

    fun error(
        src: LogSource = LogSource.SOCKET,
        targets: Set<LogTarget> = setOf(LogTarget.PRINT),
        logFull: Boolean = false,
        msg: () -> String
    ) = log(src, targets, LogLevel.ERROR, msg, logFull)

    private fun log(
        src: LogSource,
        targets: Set<LogTarget>,
        level: LogLevel,
        msg: () -> String,
        logFull: Boolean
    ) {
        if (level < this.level) return

        val msgString =
            msg().let { if (it.length > MAX_LOG_LENGTH && !logFull) "${it.take(MAX_LOG_LENGTH)}... [truncated]" else it }
        val timestamp = dateFormatter.format(getTimeMillis())
        val srcName = if (src != LogSource.ANY) src.name else ""

        val logMessage = if (srcName.isEmpty()) {
            "[$timestamp] [${level.name}] : $msgString"
        } else {
            "[$srcName | $timestamp] [${level.name}] : $msgString"
        }

        targets.forEach { target ->
            when (target) {
                LogTarget.PRINT -> {
                    if (this.colorfulLog) {
                        BypassJansi.println(colorizeLog(level, logMessage))
                    } else {
                        BypassJansi.println(logMessage)
                    }
                }
                is LogTarget.FILE -> writeToFile(target.file, logMessage)
                LogTarget.CLIENT -> {}
            }
        }
    }

    fun colorizeLog(level: LogLevel, text: String): String {
        val (fg, bg) = when (level) {
            LogLevel.SUCCESS -> AnsiColors.BlackText to AnsiColors.Success
            LogLevel.DEBUG -> AnsiColors.BlackText to AnsiColors.Debug
            LogLevel.INFO -> AnsiColors.BlackText to AnsiColors.Info
            LogLevel.WARN -> AnsiColors.BlackText to AnsiColors.Warn
            LogLevel.ERROR -> AnsiColors.WhiteText to AnsiColors.Error
        }
        return "$bg$fg$text${AnsiColors.Reset}"
    }

    private fun writeToFile(file: LogFile, message: String) {
        logFileMap[file]?.let { targetFile ->
            if (targetFile.exists() && targetFile.length() > MAX_LOG_FILE_SIZE) {
                rotateLogFile(targetFile)
            }
            targetFile.appendText("$message\n")
        }
    }

    private fun rotateLogFile(file: File): File {
        val match = Regex("""(.+)-(\d+)\.log""").matchEntire(file.name) ?: return file
        val (baseName, currentIndexStr) = match.destructured
        val nextIndex = (currentIndexStr.toInt() % MAX_LOG_ROTATES) + 1
        val newFile = File(file.parentFile, "$baseName-$nextIndex.log")
        if (newFile.exists()) newFile.delete()
        return newFile
    }

    fun enableColorfulLog(useColor: Boolean) {
        this.colorfulLog = useColor
    }

    fun setLevel(level: String) {
        when (level) {
            "0" -> setLevel(LogLevel.SUCCESS)
            "1" -> setLevel(LogLevel.DEBUG)
            "2" -> setLevel(LogLevel.INFO)
            "3" -> setLevel(LogLevel.WARN)
            "4" -> setLevel(LogLevel.ERROR)
            else -> setLevel(LogLevel.DEBUG)
        }
    }

    fun setLevel(logLevel: LogLevel) {
        level = logLevel
    }
}

/**
 * Raw console access that bypass Jansi.
 *
 * This is only needed when you want to style the console (e.g., colored text, emoji display)
 */
object BypassJansi {
    private val rawOut = PrintStream(FileOutputStream(FileDescriptor.out), true, Charsets.UTF_8)
    fun println(msg: String) = rawOut.println(msg)
}

enum class LogLevel { SUCCESS, DEBUG, INFO, WARN, ERROR }

sealed class LogTarget {
    object PRINT : LogTarget()
    object CLIENT : LogTarget()
    data class FILE(val file: LogFile) : LogTarget()
}

enum class LogFile { CLIENT_WRITE_ERROR, ASSETS_ERROR, API_SERVER_ERROR, SOCKET_SERVER_ERROR }
enum class LogSource { SOCKET, API, ANY }

data class LogConfig(
    val src: LogSource,
    val targets: Set<LogTarget> = setOf(LogTarget.PRINT),
    val logFull: Boolean = false
)

val LogConfigWriteError =
    LogConfig(LogSource.API, setOf(LogTarget.PRINT, LogTarget.FILE(LogFile.CLIENT_WRITE_ERROR)), true)
val LogConfigAPIError = LogConfig(LogSource.API, setOf(LogTarget.PRINT, LogTarget.FILE(LogFile.API_SERVER_ERROR)), true)
val LogConfigSocketToClient =
    LogConfig(LogSource.SOCKET, setOf(LogTarget.PRINT, LogTarget.FILE(LogFile.SOCKET_SERVER_ERROR)))
val LogConfigSocketError =
    LogConfig(LogSource.SOCKET, setOf(LogTarget.PRINT, LogTarget.FILE(LogFile.SOCKET_SERVER_ERROR)), true)
val LogConfigAssetsError = LogConfig(LogSource.ANY, setOf(LogTarget.PRINT, LogTarget.FILE(LogFile.ASSETS_ERROR)), true)
