package dev.deadzone.core.model.data

import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.KSerializer
import kotlinx.serialization.SerializationException
import kotlinx.serialization.builtins.ByteArraySerializer
import kotlinx.serialization.descriptors.PrimitiveKind
import kotlinx.serialization.descriptors.PrimitiveSerialDescriptor
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import org.bson.BsonBinary
import org.bson.codecs.kotlinx.BsonDecoder
import org.bson.codecs.kotlinx.BsonEncoder
import kotlin.experimental.or

object PlayerFlags {
    // nicknameVerified is a flag sent by server if user's nickname is bad
    // with nicknameVerified = true, this will prompt the game to edit the leader's nickname
    // usually the prompt is on compound screen with title of "Leader Update"
    // nicknameVerified is initially false when player registers.

    fun create(
        nicknameVerified: Boolean = false, refreshNeighbors: Boolean = false,
        tutorialComplete: Boolean = false, injurySustained: Boolean = false,
        injuryHelpComplete: Boolean = false, autoProtectionApplied: Boolean = false,
        tutorialCrateFound: Boolean = false, tutorialCrateUnlocked: Boolean = false,
        tutorialSchematicFound: Boolean = false, tutorialEffectFound: Boolean = false,
        tutorialPvPPractice: Boolean = false,
    ): ByteArray {
        val flags = listOf(
            nicknameVerified, refreshNeighbors, tutorialComplete,
            injurySustained, injuryHelpComplete, autoProtectionApplied,
            tutorialCrateFound, tutorialCrateUnlocked, tutorialSchematicFound,
            tutorialEffectFound, tutorialPvPPractice,
        )
        return flags.toByteArray()
    }

    fun newgame(
        nicknameVerified: Boolean = false, refreshNeighbors: Boolean = false,
        tutorialComplete: Boolean = false, injurySustained: Boolean = false,
        injuryHelpComplete: Boolean = false, autoProtectionApplied: Boolean = false,
        tutorialCrateFound: Boolean = false, tutorialCrateUnlocked: Boolean = false,
        tutorialSchematicFound: Boolean = false, tutorialEffectFound: Boolean = false,
        tutorialPvPPractice: Boolean = false,
    ): ByteArray {
        val flags = listOf(
            nicknameVerified, refreshNeighbors, tutorialComplete,
            injurySustained, injuryHelpComplete, autoProtectionApplied,
            tutorialCrateFound, tutorialCrateUnlocked, tutorialSchematicFound,
            tutorialEffectFound, tutorialPvPPractice,
        )
        return flags.toByteArray()
    }

    fun skipTutorial(
        nicknameVerified: Boolean = true, refreshNeighbors: Boolean = false,
        tutorialComplete: Boolean = true, injurySustained: Boolean = true,
        injuryHelpComplete: Boolean = true, autoProtectionApplied: Boolean = true,
        tutorialCrateFound: Boolean = true, tutorialCrateUnlocked: Boolean = true,
        tutorialSchematicFound: Boolean = true, tutorialEffectFound: Boolean = true,
        tutorialPvPPractice: Boolean = true,
    ): ByteArray {
        val flags = listOf(
            nicknameVerified, refreshNeighbors, tutorialComplete,
            injurySustained, injuryHelpComplete, autoProtectionApplied,
            tutorialCrateFound, tutorialCrateUnlocked, tutorialSchematicFound,
            tutorialEffectFound, tutorialPvPPractice,
        )

        return flags.toByteArray()
    }
}

fun List<Boolean>.toByteArray(): ByteArray {
    val bytes = ByteArray(this.size)

    for (i in this.indices) {
        if (this[i]) {
            val byteIndex = i / 8
            val bitIndex = i % 8
            bytes[byteIndex] = bytes[byteIndex] or (1 shl bitIndex).toByte()
        }
    }

    return bytes
}

@OptIn(ExperimentalSerializationApi::class)
object ByteArrayAsBinarySerializer : KSerializer<ByteArray> {
    override val descriptor: SerialDescriptor =
        PrimitiveSerialDescriptor("ByteArrayAsBinary", PrimitiveKind.STRING)

    override fun serialize(encoder: Encoder, value: ByteArray) {
        if (encoder is BsonEncoder) {
            encoder.encodeBsonValue(BsonBinary(value))
        } else {
            encoder.encodeSerializableValue(ByteArraySerializer(), value)
        }
    }

    override fun deserialize(decoder: Decoder): ByteArray {
        if (decoder is BsonDecoder) {
            val bsonValue = decoder.decodeBsonValue()
            if (bsonValue !is BsonBinary)
                throw SerializationException("Expected BsonBinary but found ${bsonValue.bsonType}")
            return bsonValue.data
        } else {
            return decoder.decodeSerializableValue(ByteArraySerializer())
        }
    }
}


object PlayerFlags_Constants {
    val NicknameVerified = 0u
    val RefreshNeighbors = 1u
    val TutorialComplete = 2u
    val InjurySustained = 3u
    val InjuryHelpComplete = 4u
    val AutoProtectionApplied = 5u
    val TutorialCrateFound = 6u
    val TutorialCrateUnlocked = 7u
    val TutorialSchematicFound = 8u
    val TutorialEffectFound = 9u
    val TutorialPvPPractice = 10u
}
