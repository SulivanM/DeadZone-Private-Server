package core.data.assets

import core.data.GameDefinition
import core.data.resources.ItemModResource
import org.w3c.dom.Document
import org.w3c.dom.Element

class ItemModsParser : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        val mods = doc.getElementsByTagName("mod")

        for (i in 0 until mods.length) {
            val modElement = mods.item(i) as? Element ?: continue
            val id = modElement.getAttribute("id")
            val type = modElement.getAttribute("type")

            if (id.isBlank()) continue

            val mod = ItemModResource(
                id = id,
                type = type,
                damage = getChildElementText(modElement, "dmg")?.toIntOrNull(),
                accuracy = getChildElementText(modElement, "acc")?.toDoubleOrNull(),
                range = getChildElementText(modElement, "range")?.toIntOrNull(),
                reloadTime = getChildElementText(modElement, "reload_time")?.toDoubleOrNull(),
                capacity = getChildElementText(modElement, "cap")?.toIntOrNull(),
                noise = getChildElementText(modElement, "noise")?.toIntOrNull(),
                durability = getChildElementText(modElement, "durability")?.toIntOrNull(),
                weight = getChildElementText(modElement, "weight")?.toDoubleOrNull(),
                criticalChance = getChildElementText(modElement, "crit_chance")?.toDoubleOrNull(),
                criticalDamage = getChildElementText(modElement, "crit_dmg")?.toDoubleOrNull()
            )

            gameDefinition.itemModsById[id] = mod
        }
    }

    private fun getChildElementText(element: Element, tagName: String): String? {
        val elements = element.getElementsByTagName(tagName)
        if (elements.length == 0) return null
        val el = elements.item(0) as? Element ?: return null
        return el.textContent.trim().takeIf { it.isNotBlank() }
    }
}
