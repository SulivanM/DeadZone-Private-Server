package dev.deadzone.core.model.game.data

import dev.deadzone.utils.AnyMapSerializer
import io.ktor.util.date.*
import kotlinx.serialization.Serializable
import kotlin.time.Duration
import kotlin.time.Duration.Companion.milliseconds
import kotlin.time.Duration.Companion.seconds
import kotlin.time.DurationUnit
import kotlin.time.toDuration

@Serializable
data class TimerData(
    val start: Long, 
    val length: Long, 
    
    @Serializable(with = AnyMapSerializer::class)
    val data: Map<String, Any>? 
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
}

fun TimerData.reduceBy(hours: Duration): TimerData? {
    if (this.hasEnded()) return null

    val remainingSeconds = this.secondsLeftToEnd().toDuration(DurationUnit.SECONDS)
    val reducedLength = remainingSeconds - hours
    if (reducedLength <= Duration.ZERO) return null

    return this.copy(length = reducedLength.toLong(DurationUnit.SECONDS))
}

fun TimerData.reduceByHalf(): TimerData? {
    if (this.hasEnded()) return null

    val remainingSeconds = this.secondsLeftToEnd().toDuration(DurationUnit.SECONDS)
    val reducedLength = remainingSeconds / 2
    if (reducedLength <= 1.seconds) return null

    return this.copy(length = reducedLength.toLong(DurationUnit.SECONDS))
}

fun TimerData.hasEnded(): Boolean {
    return getTimeMillis() >= this.start + this.length.seconds.inWholeMilliseconds
}

fun TimerData.secondsLeftToEnd(): Int {
    if (this.hasEnded()) return 0
    return ((start.milliseconds + this.length.seconds) - getTimeMillis().milliseconds).toInt(DurationUnit.SECONDS)
}

fun TimerData?.changeLength(updateLength: (Duration?) -> Duration): TimerData? {
    if (this == null) return null
    return this.copy(length = updateLength(this.length.seconds).toLong(DurationUnit.SECONDS))
}

fun TimerData?.removeIfFinished(): TimerData? {
    if (this == null) return null
    return if (this.hasEnded() || this.secondsLeftToEnd() < 1) null else this
}
