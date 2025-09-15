package dev.deadzone.core.model.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class RequirementTypes(val value: UInt)

object RequirementTypes_Constants {
    val None = RequirementTypes(0u)
    val PlayerLevel = RequirementTypes(2u)
    val Buildings = RequirementTypes(4u)
    val Survivors = RequirementTypes(8u)
    val Items = RequirementTypes(16u)
    val Resources = RequirementTypes(32u)
    val Skills = RequirementTypes(64u)
    val All = RequirementTypes(16777215u)
    val NotItemsResources = RequirementTypes(16777167u)
    val ItemsResources = RequirementTypes(48u)
}
