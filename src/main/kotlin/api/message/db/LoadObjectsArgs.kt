package dev.deadzone.api.message.db

import kotlinx.serialization.Serializable

@Serializable
data class LoadObjectsArgs(
    val objectIds: List<BigDBObjectId> = listOf()
)