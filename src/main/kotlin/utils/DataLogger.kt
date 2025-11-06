package utils

import dev.deadzone.utils.AnyMapSerializer
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import java.io.File

const val TELEMETRY_DIRECTORY = "telemetry"

object DataLogger {
    fun event(name: String) = DataLogBuilder(name)
}

class DataLogBuilder(private val name: String) {
    private val data = mutableMapOf<String, Any>()
    private var playerId: String = "[Undefined]"
    private var text: String = ""
    private val jsonBuilder = Json { prettyPrint = false }

    fun playerId(id: String) = apply { playerId = id }

    fun prefixText(text: String) = apply { this.text = text }

    fun data(key: String, value: Any) = apply {
        if (key.equals("playerId", ignoreCase = true)) {
            playerId = value.toString()
        } else {
            data[key] = value
        }
    }

    fun log(level: LogLevel = LogLevel.INFO, textOnly: Boolean = false) {
        val msg = buildString(textOnly)
        when (level) {
            LogLevel.VERBOSE -> Logger.verbose(logFull = true) { msg }
            LogLevel.DEBUG -> Logger.debug(logFull = true) { msg }
            LogLevel.INFO -> Logger.info(logFull = true) { msg }
            LogLevel.WARN -> Logger.warn(logFull = true) { msg }
            LogLevel.ERROR -> Logger.error(logFull = true) { msg }
            LogLevel.SUCCESS -> Logger.success(logFull = true) { msg }
            LogLevel.NOTHING -> {}
        }
    }

    fun record() = apply {
        val dir = File(TELEMETRY_DIRECTORY)
        if (!dir.exists()) dir.mkdirs()

        val file = File(dir, "$name.json")
        val newJson = asJson()

        if (!file.exists() || file.readBytes().isEmpty()) {
            file.writeText("[\n$newJson\n]")
        } else {
            val content = file.readText().trim()
            if (content.endsWith("]")) {
                val updated = buildString {
                    append(content.dropLast(1).trimEnd())
                    if (content.length > 2) append(",\n")
                    append(newJson)
                    append("\n]")
                }
                file.writeText(updated)
            } else {
                Logger.warn { "JSON corruption detected on file telemetry/${file.name}, new JSON data appended directly" }
                file.appendText("[\n$newJson\n]")
            }
        }
    }

    fun buildString(textOnly: Boolean): String {
        val content = buildString {
            if (textOnly) {
                append("$name ")
            } else {
                append("[Event:$name] ")
            }
            if (text.isNotEmpty()) {
                append("$text ")
            }
            append(jsonBuilder.encodeToString(LogEvent.serializer(), LogEvent(playerId, data)))
        }
        return content
    }

    fun asJson(): String {
        return JSON.encode(TelemetryEvent(name, playerId, data))
    }
}

@Serializable
data class TelemetryEvent(
    val event: String,
    val playerId: String,
    @Serializable(with = AnyMapSerializer::class)
    val data: Map<String, Any> = emptyMap()
)

@Serializable
data class LogEvent(
    val playerId: String,
    @Serializable(with = AnyMapSerializer::class)
    val data: Map<String, Any> = emptyMap()
)
