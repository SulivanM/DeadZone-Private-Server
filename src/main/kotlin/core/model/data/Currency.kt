package dev.deadzone.core.model.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class Currency(val value: String)

object Currency_Constants {
    val FUEL = Currency("Coins")
    val FACEBOOK_CREDITS = Currency("FBC")
    val US_DOLLARS = Currency("USD")
    val KONGREGATE_KREDS = Currency("KKR")
    val ALLIANCE_TOKENS = Currency("ATK")
}
