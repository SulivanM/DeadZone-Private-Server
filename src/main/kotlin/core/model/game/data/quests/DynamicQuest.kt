package dev.deadzone.core.model.game.data.quests

import dev.deadzone.core.model.game.data.MoraleConstants_Constants
import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.quests.DynamicQuestGoal
import dev.deadzone.core.model.game.data.quests.DynamicQuestPenalty
import dev.deadzone.core.model.game.data.quests.DynamicQuestReward
import dev.deadzone.core.model.game.data.quests.Quest
import io.ktor.util.date.getTimeMillis
import java.io.ByteArrayOutputStream
import java.io.DataOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder

@Serializable
data class DynamicQuest(
    val raw: ByteArray,  // see DynamicQuest.as for detail of structure
    val quest: Quest,  // inherited
    val questType: Int,
    val accepted: Boolean,
    val goals: List<DynamicQuestGoal> = listOf(),
    val rewards: List<DynamicQuestReward> = listOf(),
    val failurePenalties: List<DynamicQuestPenalty> = listOf()
) {
    companion object {
        // Still wrong! EOF error
        fun dummy(): ByteArray {
            val buffer = ByteBuffer.allocate(2048).order(ByteOrder.LITTLE_ENDIAN)

            // Version and quest type
            buffer.putShort(2)      // version
            buffer.putShort(1)      // quest type

            // Quest ID
            val questIdBytes = ByteArrayOutputStream()
            DataOutputStream(questIdBytes).writeUTF("comfortQuest")
            buffer.put(questIdBytes.toByteArray())

            // Booleans
            buffer.put(0) // accepted
            buffer.put(0) // complete
            buffer.put(0) // collected
            buffer.put(0) // failed

            // End Time
            buffer.putDouble(getTimeMillis().toDouble())

            // ----- Goals -----
            buffer.putShort(1) // 1 goal
            val goalData = ByteArrayOutputStream()
            val goalOut = DataOutputStream(goalData)
            goalOut.writeUTF("statInc")
            goalOut.writeUTF("zombieKills")
            goalOut.writeInt(10)
            val goalBytes = goalData.toByteArray()
            buffer.putShort(goalBytes.size.toShort())
            buffer.put(goalBytes)

            // ----- Rewards -----
            buffer.putShort(1) // 1 reward
            val rewardData = ByteArrayOutputStream()
            val rewardOut = DataOutputStream(rewardData)
            rewardOut.writeShort(0)      // type = xp
            rewardOut.writeInt(500)      // xp amount
            val rewardBytes = rewardData.toByteArray()
            buffer.putShort(rewardBytes.size.toShort())
            buffer.put(rewardBytes)

            // ----- Failure Penalties -----
            buffer.putShort(1) // 1 penalty
            val penaltyData = ByteArrayOutputStream()
            val penaltyOut = DataOutputStream(penaltyData)
            penaltyOut.writeShort(2)         // type = morale
            penaltyOut.writeUTF("comfort")      // morale type
            penaltyOut.writeDouble(5.0)      // morale amount
            val penaltyBytes = penaltyData.toByteArray()
            buffer.putShort(penaltyBytes.size.toShort())
            buffer.put(penaltyBytes)

            // ----- Version-specific field (v2+) -----
            buffer.putInt(12345678)

            return buffer.array().sliceArray(0 until buffer.position())
        }
    }
}
