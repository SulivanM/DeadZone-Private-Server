package core.model.game.data.quests

import core.model.game.data.MoraleConstants
import core.model.game.data.MoraleConstants_Constants
import kotlinx.serialization.Serializable
import io.ktor.util.date.getTimeMillis
import java.io.ByteArrayOutputStream
import java.io.DataOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder

@Serializable
data class DynamicQuest(
    val raw: ByteArray,  
    val quest: Quest,  
    val questType: Int,
    val accepted: Boolean,
    val attributes: List<QuestAttribute> = listOf()
) {
    
    val goals: List<QuestAttribute>
        get() = attributes.filter { it.category == QuestAttributeCategory.GOAL }

    val rewards: List<QuestAttribute>
        get() = attributes.filter { it.category == QuestAttributeCategory.REWARD }

    val failurePenalties: List<QuestAttribute>
        get() = attributes.filter { it.category == QuestAttributeCategory.PENALTY }

    companion object {
        
        fun dummy(): ByteArray {
            val buffer = ByteBuffer.allocate(2048).order(ByteOrder.LITTLE_ENDIAN)

            buffer.putShort(2)      
            buffer.putShort(1)      

            val questIdBytes = ByteArrayOutputStream()
            DataOutputStream(questIdBytes).writeUTF("comfortQuest")
            buffer.put(questIdBytes.toByteArray())

            buffer.put(0) 
            buffer.put(0) 
            buffer.put(0) 
            buffer.put(0) 

            buffer.putDouble(getTimeMillis().toDouble())

            buffer.putShort(1) 
            val goalData = ByteArrayOutputStream()
            val goalOut = DataOutputStream(goalData)
            goalOut.writeUTF("statInc")
            goalOut.writeUTF("zombieKills")
            goalOut.writeInt(10)
            val goalBytes = goalData.toByteArray()
            buffer.putShort(goalBytes.size.toShort())
            buffer.put(goalBytes)

            buffer.putShort(1) 
            val rewardData = ByteArrayOutputStream()
            val rewardOut = DataOutputStream(rewardData)
            rewardOut.writeShort(0)      
            rewardOut.writeInt(500)      
            val rewardBytes = rewardData.toByteArray()
            buffer.putShort(rewardBytes.size.toShort())
            buffer.put(rewardBytes)

            buffer.putShort(1) 
            val penaltyData = ByteArrayOutputStream()
            val penaltyOut = DataOutputStream(penaltyData)
            penaltyOut.writeShort(2)         
            penaltyOut.writeUTF("comfort")      
            penaltyOut.writeDouble(5.0)      
            val penaltyBytes = penaltyData.toByteArray()
            buffer.putShort(penaltyBytes.size.toShort())
            buffer.put(penaltyBytes)

            buffer.putInt(12345678)

            return buffer.array().sliceArray(0 until buffer.position())
        }
    }
}
