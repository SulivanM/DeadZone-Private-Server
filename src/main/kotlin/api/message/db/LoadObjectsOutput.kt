package dev.deadzone.api.message.db

import dev.deadzone.api.utils.BigDBConverter
import kotlinx.serialization.Serializable

@Serializable
data class LoadObjectsOutput(
    val objects: List<BigDBObject> = listOf()
) {
    companion object {
        inline fun <reified T : Any> fromData(obj: T): BigDBObject {
            return BigDBConverter.toBigDBObject(obj = obj)
        }
    }
}
