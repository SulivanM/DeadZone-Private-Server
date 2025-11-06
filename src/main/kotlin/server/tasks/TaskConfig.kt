package server.tasks

import kotlin.time.Duration

data class TaskConfig(
    val startDelay: Duration = Duration.ZERO,
    val repeatInterval: Duration? = null,
    val maxRepeats: Int? = null,
    val timeout: Duration? = null
)
