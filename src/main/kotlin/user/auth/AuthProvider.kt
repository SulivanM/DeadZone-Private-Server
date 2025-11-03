package user.auth

import user.model.PlayerSession

interface AuthProvider {
    
    suspend fun register(username: String, password: String): PlayerSession

    suspend fun login(username: String, password: String): PlayerSession?

    suspend fun adminLogin(): PlayerSession?

    suspend fun doesUserExist(username: String): Boolean
}
