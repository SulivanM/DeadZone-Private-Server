package core.model.game.data.effects

import kotlinx.serialization.Serializable
import core.model.game.data.effects.EffectData
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

            data.writeUTF("VacationMode")
            data.writeUTF("vacation")
            data.writeByte(0)
            data.writeInt(0)
            data.writeInt(0)
            data.writeByte(0)
            data.writeByte(0)

            val effects = listOf(
                EffectData(100u, 10.0),
                EffectData(101u, 5.0),
                EffectData(102u, 8.0),
                EffectData(103u, 4.0)
            )
            data.writeByte(effects.size)

            for (effect in effects) {
                data.writeInt(effect.type.toInt())
                data.writeDouble(effect.value)
            }

            data.writeByte(0)

            return output.toByteArray()
        }

        fun halloweenTrickPumpkinZombie(): ByteArray {
            val effectType = "HalloweenTrickPumpkinZombie"
            val effectId = "halloween-pumpkinzombies"

            val output = ByteArrayOutputStream()
            val data = DataOutputStream(output)

            data.writeUTF(effectType)
            data.writeUTF(effectId)
            data.writeByte(0)
            data.writeInt(0)
            data.writeInt(0)
            data.writeByte(0)
            data.writeByte(0)

            val effects = listOf(
                EffectData(100u, 1.0)
            )

            data.writeByte(effects.size)
            for (effect in effects) {
                data.writeInt(effect.type.toInt())
                data.writeDouble(effect.value)
            }

            data.writeByte(0)

            return output.toByteArray()
        }

        fun halloweenTrickPewPew(): ByteArray {
            val effectType = "HalloweenTrickPewPew"
            val effectId = "halloween-pewpew"

            val output = ByteArrayOutputStream()
            val data = DataOutputStream(output)

            data.writeUTF(effectType)
            data.writeUTF(effectId)
            data.writeByte(0)
            data.writeInt(0)
            data.writeInt(0)
            data.writeByte(0)
            data.writeByte(0)

            val effects: List<EffectData> = listOf(
                EffectData(207u, 1.0)
            )

            data.writeByte(effects.size)
            for (effect in effects) {
                data.writeInt(effect.type.toInt())
                data.writeDouble(effect.value)
            }

            data.writeByte(0)

            return output.toByteArray()
        }
    }
}
