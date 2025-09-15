package dev.deadzone.utils

import io.ktor.util.date.getTimeMillis

object Time {
    /**
     * Return the epoch millis in Double type.
     *
     * IMPORTANT! TLSDZ AS3 code uses msg.getNumber(n++) to get the serverTime
     * If we send the epoch in Long, this means getNumber will fail and will default to 0 instead
     * Using Double type is better because it won't fail.
     */
    fun now(): Double {
        return getTimeMillis().toDouble()
    }
}
