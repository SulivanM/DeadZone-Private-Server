package dev.deadzone.data.collection

import dev.deadzone.core.auth.model.ServerMetadata
import dev.deadzone.core.auth.model.UserProfile
import dev.deadzone.core.data.AdminData
import kotlinx.serialization.Serializable

/**
 * Database-level representation of a user data
 *
 * @property playerId internal ID, also known as userId in PIO login.
 * This is also used to uniquely identify a user document.
 *
 * @property hashedPassword using particular hash system
 */
@Serializable
data class PlayerAccount(
    val playerId: String, // referenced by other collections
    val hashedPassword: String,
    val profile: UserProfile,
    val serverMetadata: ServerMetadata,
) {
    companion object {
        fun admin(): PlayerAccount {
            return PlayerAccount(
                playerId = AdminData.PLAYER_ID,
                hashedPassword = AdminData.PASSWORD,
                profile = UserProfile.Companion.admin(),
                serverMetadata = ServerMetadata()
            )
        }
    }
}

/*
List of common field in PlayerAccount and PlayerObjects
- UserProfile:
    - displayName -> nickname
*/
