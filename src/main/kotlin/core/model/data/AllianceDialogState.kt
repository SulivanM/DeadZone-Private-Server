package dev.deadzone.core.model.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class AllianceDialogState(val value: Int)

object AllianceDialogState_Constants {
    val SHOW_NONE = AllianceDialogState(0)
    val SHOW_ALLIANCE_DIALOG = AllianceDialogState(1)
    val SHOW_INDIVIDUALS = AllianceDialogState(2)
    val SHOW_TOP_100 = AllianceDialogState(3)
}
