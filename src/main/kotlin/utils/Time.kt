package utils

import io.ktor.util.date.getTimeMillis

object Time {
    fun now(): Double {
        return getTimeMillis().toDouble()
    }
}
