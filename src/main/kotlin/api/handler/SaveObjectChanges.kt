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
suspend fun RoutingContext.saveObjectChanges(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    val saveObjectChangesArgs = try {
        ProtoBuf.decodeFromByteArray<SaveObjectChangesArgs>(body)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_payload")
        return
    }

    logInput(saveObjectChangesArgs, disableLogging = false)

    val versions = mutableListOf<String>()

    for (changeset in saveObjectChangesArgs.changesets) {
        try {
            // Convert changes to a Map
            val changesMap = convertPropertiesToMap(changeset.changes)

            val version = serverContext.db.saveObjectChanges(
                table = changeset.table,
                key = changeset.key,
                onlyIfVersion = if (changeset.onlyIfVersion.isNotEmpty()) changeset.onlyIfVersion else null,
                changes = changesMap,
                createIfMissing = saveObjectChangesArgs.createIfMissing
            )

            if (version != null) {
                versions.add(version)
            } else {
                versions.add("")
            }
        } catch (e: Exception) {
            Logger.error(LogConfigAPIError) { "Failed to save changes for ${changeset.table}/${changeset.key}: ${e.message}" }
            versions.add("")
        }
    }

    val output = SaveObjectChangesOutput(versions = versions)
    val encoded = ProtoBuf.encodeToByteArray(output)
    logOutput(encoded, disableLogging = false)
    call.respondBytes(encoded.pioFraming())
}

private fun convertPropertiesToMap(properties: List<ObjectProperty>): Map<String, Any> {
    val map = mutableMapOf<String, Any>()
    for (prop in properties) {
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
