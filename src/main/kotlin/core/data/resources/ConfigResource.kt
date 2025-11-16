package core.data.resources

data class ConfigResource(
    val security: SecurityConfig? = null,
    val playerio: PlayerIOConfig? = null,
    val paths: PathsConfig? = null,
    val constants: Map<String, Any> = emptyMap()
)

data class SecurityConfig(
    val policies: List<String> = emptyList(),
    val insecure: List<String> = emptyList()
)

data class PlayerIOConfig(
    val gameId: String,
    val connId: String
)

data class PathsConfig(
    val storageUrl: String? = null,
    val saveImageUrl: String? = null,
    val loggerUrl: String? = null,
    val stage3dInfoUrl: String? = null,
    val music: String? = null,
    val allianceUrl: String? = null
)
