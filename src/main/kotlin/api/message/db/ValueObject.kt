package api.message.db

import kotlinx.serialization.Serializable

@Serializable
data class ValueObject(
    val valueType: ValueType = ValueType.STRING,
    val string: String = "",
    val int32: Int = 0,
    val uInt: UInt = 0u,
    val long: Long = 0L,
    val bool: Boolean = false,
    val float: Float = 0f,
    val double: Double = 0.0,
    val byteArray: ByteArray = byteArrayOf(),
    val dateTime: Long = 0L,
    val arrayProperties: List<ArrayProperty> = listOf(),
    val objectProperties: List<ObjectProperty> = listOf()
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as ValueObject

        if (int32 != other.int32) return false
        if (long != other.long) return false
        if (bool != other.bool) return false
        if (float != other.float) return false
        if (double != other.double) return false
        if (dateTime != other.dateTime) return false
        if (valueType != other.valueType) return false
        if (string != other.string) return false
        if (uInt != other.uInt) return false
        if (!byteArray.contentEquals(other.byteArray)) return false
        if (arrayProperties != other.arrayProperties) return false
        if (objectProperties != other.objectProperties) return false

        return true
    }

    override fun hashCode(): Int {
        var result = int32
        result = 31 * result + long.hashCode()
        result = 31 * result + bool.hashCode()
        result = 31 * result + float.hashCode()
        result = 31 * result + double.hashCode()
        result = 31 * result + dateTime.hashCode()
        result = 31 * result + valueType.hashCode()
        result = 31 * result + string.hashCode()
        result = 31 * result + uInt.hashCode()
        result = 31 * result + byteArray.contentHashCode()
        result = 31 * result + arrayProperties.hashCode()
        result = 31 * result + objectProperties.hashCode()
        return result
    }
}