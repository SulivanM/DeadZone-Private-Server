package dev.deadzone.core.auth.model

/**
 * Representation of a player's authentication session.
 *
 * This session is issued during website login and included in API 13 (Authenticate)
 * and API 601 (SocialRefresh) responses.
 *
 * When the game client connects to the game socket using a `playerId`,
 * the server must verify that a valid session with a matching token exists.
 *
 * @property playerId The internal ID, used for linking session to [dev.deadzone.data.collection.PlayerAccount].
 * @property token A unique prove for authentication; currently not much used.
 * @property issuedAt Epoch millis when this session was created.
 * @property expiresAt Epoch millis when this session is no longer valid.
 */
data class PlayerSession(
    val playerId: String,
    val token: String,
    val issuedAt: Long,
    var expiresAt: Long,
    var lifetime: Long,
)
