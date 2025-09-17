package core.metadata.model
import kotlinx.serialization.KSerializer
import kotlinx.serialization.descriptors.PrimitiveKind
import kotlinx.serialization.descriptors.PrimitiveSerialDescriptor
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlin.experimental.or
import kotlin.io.encoding.Base64
import kotlin.io.encoding.ExperimentalEncodingApi
object PlayerFlags {
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
@OptIn(ExperimentalEncodingApi::class)
object ByteArrayAsBase64Serializer : KSerializer<ByteArray> {
    override val descriptor: SerialDescriptor =
        PrimitiveSerialDescriptor("ByteArrayAsBase64", PrimitiveKind.STRING)
    override fun serialize(encoder: Encoder, value: ByteArray) {
        encoder.encodeString(Base64.encode(value))
    }
    override fun deserialize(decoder: Decoder): ByteArray {
        return Base64.decode(decoder.decodeString())
    }
}
object PlayerFlags_Constants {
    val TutorialComplete = 2u
}