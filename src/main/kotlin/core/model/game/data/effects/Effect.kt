package dev.deadzone.core.model.game.data.effects

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.effects.EffectData
import dev.deadzone.core.model.game.data.TimerData
import java.io.ByteArrayOutputStream
import java.io.DataOutputStream

@Serializable
data class Effect(
    val raw: ByteArray = byteArrayOf(),
    val type: String,
    val id: String,
    val lockTime: Int,
    val cooldownTime: Int,
    val started: Boolean = false,
    val timer: TimerData?,
    val lockoutTimer: TimerData?,
    val effectList: List<EffectData> = listOf(),
    val itemId: String?
) {
    companion object {
        fun dummyEffectByteArray(): ByteArray {
            val output = ByteArrayOutputStream()
            val data = DataOutputStream(output)

            // Write header values required before effect list (optional placeholder):
            data.writeUTF("VacationMode") // _type
            data.writeUTF("vacation")  // _id
            data.writeByte(0)         // unused byte
            data.writeInt(0)          // _lockTime
            data.writeInt(0)          // _cooldownTime

            // Timer not present
            data.writeByte(0) // No _timer

            // Lockout timer not present
            data.writeByte(0) // No _lockoutTimer

            // Now the effect list
            val effects = listOf(
                EffectData(100u, 10.0), // BarricadeHealth
                EffectData(101u, 5.0),  // BarricadeCover
                EffectData(102u, 8.0),  // etc...
                EffectData(103u, 4.0)
            )
            data.writeByte(effects.size) // number of effects

            for (effect in effects) {
                data.writeInt(effect.type.toInt())   // short
                data.writeDouble(effect.value)    // float
            }

            // Optional itemId (not present)
            data.writeByte(0) // No itemId

            return output.toByteArray()
        }

        /**
         * Halloween trick pumpkin zombie effect is needed for starting mission
         */
        fun halloweenTrickPumpkinZombie(): ByteArray {
            val effectType = "HalloweenTrickPumpkinZombie"
            val effectId = "halloween-pumpkinzombies"

            val output = ByteArrayOutputStream()
            val data = DataOutputStream(output)

            // Write header
            data.writeUTF(effectType)
            data.writeUTF(effectId)
            data.writeByte(0)         // unused byte
            data.writeInt(0)          // _lockTime
            data.writeInt(0)          // _cooldownTime

            data.writeByte(0)         // No _timer
            data.writeByte(0)         // No _lockoutTimer

            // Write the single Halloween effect
            val effects = listOf(
                // Enable effect to BarricadeHealth for example
                // this is probably actually used to modify zombie health or something
                EffectData(100u, 1.0)
            )

            data.writeByte(effects.size) // number of effects
            for (effect in effects) {
                data.writeInt(effect.type.toInt())   // int (not short)
                data.writeDouble(effect.value)       // double (not float)
            }

            data.writeByte(0) // No itemId

            return output.toByteArray()
        }

        /**
         * Halloween trick pew pew effect is needed for starting mission
         *
         * This is what it should do before checking pewVal > 0
         * pewVal = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("HalloweenTrickPewPew"));
         */
        fun halloweenTrickPewPew(): ByteArray {
            val effectType = "HalloweenTrickPewPew"
            val effectId = "halloween-pewpew"

            val output = ByteArrayOutputStream()
            val data = DataOutputStream(output)

            // Write header
            data.writeUTF(effectType)
            data.writeUTF(effectId)
            data.writeByte(0)         // unused byte
            data.writeInt(0)          // _lockTime
            data.writeInt(0)          // _cooldownTime

            data.writeByte(0)         // No _timer
            data.writeByte(0)         // No _lockoutTimer

            // Write the single Halloween effect
            val effects:List<EffectData> = listOf(
                // Enable effect to BarricadeCover for example
                // this is probably actually used to modify gun sound or something
                EffectData(207u, 1.0)
            )

            data.writeByte(effects.size) // number of effects
            for (effect in effects) {
                data.writeInt(effect.type.toInt())   // int (not short)
                data.writeDouble(effect.value)       // double (not float)
            }

            data.writeByte(0) // No itemId

            return output.toByteArray()
        }
    }
}
