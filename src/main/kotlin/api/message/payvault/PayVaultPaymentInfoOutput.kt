package api.message.payvault

import api.message.KeyValuePair
import kotlinx.serialization.Serializable

@Serializable
data class PayVaultPaymentInfoOutput(
    val providerArguments: List<KeyValuePair> = emptyList()
) {
    companion object {
        fun dummy(): PayVaultPaymentInfoOutput {
            return PayVaultPaymentInfoOutput(
                providerArguments = listOf(
                    KeyValuePair(key = "dummy", value = "value")
                )
            )
        }
    }
}
