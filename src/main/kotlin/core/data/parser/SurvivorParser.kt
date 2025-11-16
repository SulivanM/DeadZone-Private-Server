package core.data.assets

import core.data.GameDefinition
import core.data.resources.BuildingRequirement
import core.data.resources.SurvivorArrivalRequirement
import org.w3c.dom.Document
import org.w3c.dom.Element

class SurvivorParser : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        val survivors = mutableListOf<SurvivorArrivalRequirement>()

        val survivorNodes = doc.getElementsByTagName("survivor")
        for (i in 0 until survivorNodes.length) {
            val survivorElement = survivorNodes.item(i) as? Element ?: continue

            // Skip the root element if it's named "survivor"
            if (survivorElement.parentNode == doc.documentElement && survivorElement.tagName == "survivor") {
                continue
            }

            val food = getChildElementText(survivorElement, "food")?.toIntOrNull() ?: 0
            val water = getChildElementText(survivorElement, "water")?.toIntOrNull() ?: 0
            val comfort = getChildElementText(survivorElement, "comfort")?.toIntOrNull() ?: 0
            val security = getChildElementText(survivorElement, "security")?.toIntOrNull() ?: 0
            val morale = getChildElementText(survivorElement, "morale")?.toIntOrNull() ?: 0
            val cost = getChildElementText(survivorElement, "cost")?.toIntOrNull() ?: 0

            // Parse building requirements
            val buildingRequirements = mutableListOf<BuildingRequirement>()
            val reqElements = survivorElement.getElementsByTagName("req")
            if (reqElements.length > 0) {
                val reqElement = reqElements.item(0) as Element
                val bldNodes = reqElement.getElementsByTagName("bld")
                for (j in 0 until bldNodes.length) {
                    val bldElement = bldNodes.item(j) as? Element ?: continue
                    val id = bldElement.getAttribute("id")
                    val level = bldElement.getAttribute("lvl").toIntOrNull() ?: 0
                    val quantity = bldElement.textContent.trim().toIntOrNull() ?: 1

                    if (id.isNotBlank()) {
                        buildingRequirements.add(BuildingRequirement(id, level, quantity))
                    }
                }
            }

            survivors.add(SurvivorArrivalRequirement(
                food = food,
                water = water,
                comfort = comfort,
                security = security,
                morale = morale,
                buildingRequirements = buildingRequirements,
                cost = cost
            ))
        }

        gameDefinition.survivorArrivals.clear()
        gameDefinition.survivorArrivals.addAll(survivors)
    }

    private fun getChildElementText(element: Element, tagName: String): String? {
        val elements = element.getElementsByTagName(tagName)
        if (elements.length == 0) return null
        val el = elements.item(0) as? Element ?: return null
        return el.textContent.trim().takeIf { it.isNotBlank() }
    }
}
