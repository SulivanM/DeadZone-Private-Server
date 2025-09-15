package dev.deadzone.core.model.data

import kotlinx.serialization.Serializable

@Serializable
data class NewsArticle(
    val date: Long,
    val body: String
)
