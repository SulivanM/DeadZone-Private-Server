package api.handler

import api.message.db.*
import api.protocol.pioFraming
import context.ServerContext
import common.LogConfigAPIError
import common.Logger
import common.logInput
import common.logOutput
import io.ktor.http.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.utils.io.*
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf

@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.createObjects(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    val createObjectsArgs = try {
        ProtoBuf.decodeFromByteArray<CreateObjectsArgs>(body)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_payload")
        return
    }

    logInput(createObjectsArgs, disableLogging = false)

    val resultObjects = mutableListOf<BigDBObject>()

    for (newObj in createObjectsArgs.objects) {
        try {
            // Convert properties to a Map for the DB layer
            val propertiesMap = convertPropertiesToMap(newObj.properties)

            val version = serverContext.db.createObject(
                table = newObj.table,
                key = newObj.key,
                properties = propertiesMap,
                loadExisting = createObjectsArgs.loadExisting
            )

            if (version != null) {
                resultObjects.add(
                    BigDBObject(
                        key = newObj.key,
                        version = version,
                        properties = newObj.properties,
                        creator = 0u
                    )
                )
            }
        } catch (e: Exception) {
            Logger.error(LogConfigAPIError) { "Failed to create object ${newObj.table}/${newObj.key}: ${e.message}" }
            // For now, we'll continue with other objects
            // In a real implementation, you might want to return an error
        }
    }

    val output = CreateObjectsOutput(objects = resultObjects)
    val encoded = ProtoBuf.encodeToByteArray(output)
    logOutput(encoded, disableLogging = false)
    call.respondBytes(encoded.pioFraming())
}

private fun convertPropertiesToMap(properties: List<ObjectProperty>): Map<String, Any> {
    val map = mutableMapOf<String, Any>()
    for (prop in properties) {
        // This is a simplified conversion
        // In reality, you'd need to handle all value types properly
        val value: Any = when (prop.value.valueType) {
            ValueType.STRING -> prop.value.string
            ValueType.INT32 -> prop.value.int32
            ValueType.UINT -> prop.value.uInt
            ValueType.LONG -> prop.value.long
            ValueType.BOOL -> prop.value.bool
            ValueType.FLOAT -> prop.value.float
            ValueType.DOUBLE -> prop.value.double
            ValueType.BYTE_ARRAY -> prop.value.byteArray
            ValueType.DATETIME -> prop.value.dateTime
            ValueType.ARRAY -> listOf<Any>() // Simplified
            ValueType.OBJECT -> mapOf<String, Any>() // Simplified
        }
        map[prop.name] = value
    }
    return map
}
