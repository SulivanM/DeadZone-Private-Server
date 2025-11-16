package core.data.resources

data class AttireResource(
    val id: String,
    val type: String,
    val color: String? = null,
    val classOnly: Boolean = false,
    val allowRandom: Boolean = false,
    val male: AttireGenderData? = null,
    val female: AttireGenderData? = null,
    val children: List<String> = emptyList(),
    val flags: List<String> = emptyList()
)

data class AttireGenderData(
    val model: String? = null,
    val texture: String? = null,
    val voice: String? = null,
    val overlays: List<AttireOverlay> = emptyList()
)

data class AttireOverlay(
    val type: String,
    val uri: String
)

data class VoiceResource(
    val id: String,
    val gender: String,
    val samples: Int
)

data class HairTextureResource(
    val id: String,
    val color: String,
    val uri: String,
    val allowRandom: Boolean = false
)
