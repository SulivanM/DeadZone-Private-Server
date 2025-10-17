package dev.deadzone.core.model.game.data

import dev.deadzone.utils.AnyMapSerializer
import io.ktor.util.date.*
import kotlinx.serialization.Serializable
import kotlin.time.Duration
import kotlin.time.Duration.Companion.milliseconds
import kotlin.time.Duration.Companion.seconds
import kotlin.time.DurationUnit

@Serializable
data class TimerData(
    val start: Long, // epoch millis
    val length: Long, // length in seconds!
    // If sending this via API, the value should be JSONElement. Use Json.encodeToJsonElement()
    @Serializable(with = AnyMapSerializer::class)
    val data: Map<String, Any>? // this depends on each response. e.g., building upgrade need level
) {
    companion object {
        fun runForDuration(
            duration: Duration,
            data: Map<String, Any>? = emptyMap()
        ): TimerData {
            return TimerData(
                start = getTimeMillis(),
                length = duration.inWholeSeconds,
                data = data
            )
        }
    }

    /**
     * Add [length] by [time].
     */
    operator fun plus(time: Duration): TimerData {
        return this.copy(length = (length.seconds + time).toLong(DurationUnit.SECONDS))
    }

    /**
     * Subtract [length] by [time].
     */
    operator fun minus(time: Duration): TimerData {
        return this.copy(length = (length.seconds - time).toLong(DurationUnit.SECONDS))
    }

    /**
     * Multiply [length] by [multiplier].
     */
    operator fun times(multiplier: Int): TimerData {
        return this.copy(length = (length.seconds * multiplier).toLong(DurationUnit.SECONDS))
    }

    /**
     * Divide [length] by [divisor].
     */
    operator fun div(divisor: Int): TimerData {
        return this.copy(length = (length.seconds / divisor).toLong(DurationUnit.SECONDS))
    }
}

operator fun TimerData?.plus(other: TimerData?): TimerData? {
    if (this == null && other == null) return null
    return this + other
}

operator fun TimerData?.minus(other: TimerData?): TimerData? {
    if (this == null && other == null) return null
    return this - other
}

operator fun TimerData?.times(other: TimerData?): TimerData? {
    if (this == null && other == null) return null
    return this * other
}

operator fun TimerData?.div(other: TimerData?): TimerData? {
    if (this == null && other == null) return null
    return this / other
}

fun TimerData.hasEnded(): Boolean {
    return getTimeMillis() >= this.start + this.length.seconds.inWholeMilliseconds
}

fun TimerData.secondsLeftToEnd(): Int {
    if (this.hasEnded()) return 0
    return (this.length.seconds - getTimeMillis().milliseconds).toInt(DurationUnit.SECONDS)
}

/**
 * Change the length of the timer using the provided block.
 *
 * A `null` timer represent no timer is set or the timer has finished.
 *
 * @return `null` if timer was already `null`.
 */
fun TimerData?.changeLength(updateLength: (Duration?) -> Duration): TimerData? {
    if (this == null) return null
    return this.copy(length = updateLength(this.length.seconds).toLong(DurationUnit.SECONDS))
}

/**
 * Return `null` if time has finished (or less than 1 seconds).
 */
fun TimerData?.removeIfFinished(): TimerData? {
    if (this == null) return null
    return if (this.hasEnded() || this.secondsLeftToEnd() < 1) null else this
}
