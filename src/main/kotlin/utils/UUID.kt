package dev.deadzone.utils

import java.util.UUID

object UUID {
    /**
     * Returns an uppercased UUID from java.util.uuid.
     *
     * game used uppercase UUID so make sure to ignorecase when comparing or just use uppercase UUID too
     */
    fun new(): String {
        return UUID.randomUUID().toString().uppercase()
    }
}
