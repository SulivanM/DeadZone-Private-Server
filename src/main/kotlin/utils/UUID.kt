package utils

import java.util.UUID

object UUID {
    fun new(): String {
        return UUID.randomUUID().toString().uppercase()
    }
}
