package user.auth

import user.model.PlayerSession

interface AuthProvider {
    /**
     * Register a new account with [username] and [password].
     *
     * @param username The username for the account
     * @param password The password for the account
     * @param email The email address (optional, defaults to "dummyemail@email.com")
     * @param countryCode The country code (optional, defaults to null)
     * @return [PlayerSession] of the newly created account for further authentication.
     */
    suspend fun register(username: String, password: String, email: String? = null, countryCode: String? = null): PlayerSession

    /**
     * Login with [username] and [password].
     *
     * @return [PlayerSession] which is used for further authentication, null if login is failed.
     */
    suspend fun login(username: String, password: String): PlayerSession?

    /**
     * Login with admin account, will always succeed.
     */
    suspend fun adminLogin(): PlayerSession?

    /**
     * Check whether a user with [username] exists.
     */
    suspend fun doesUserExist(username: String): Boolean
}
