package api.message.payvault

import kotlinx.serialization.Serializable

@Serializable
data class PayVaultPaymentInfoError(
    val errorCode: Int = 0,
    val message: String = ""
) {
    companion object {
        fun dummy(): PayVaultPaymentInfoError {
            return PayVaultPaymentInfoError(
                errorCode = 0,
                message = "PayVault not implemented"
            )
        }
    }
}
