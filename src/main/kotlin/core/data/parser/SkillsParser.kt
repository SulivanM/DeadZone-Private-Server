package core.data.assets

import core.data.GameDefinition
import core.data.resources.SkillLevel
import core.data.resources.SkillResource
import org.w3c.dom.Document
import org.w3c.dom.Element

class SkillsParser : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        val skills = doc.getElementsByTagName("skill")

        for (i in 0 until skills.length) {
            val skillElement = skills.item(i) as? Element ?: continue
            val skill = parseSkill(skillElement)

            gameDefinition.skillsById[skill.id] = skill
        }
    }

    private fun parseSkill(element: Element): SkillResource {
        val id = element.getAttribute("id")
        val levels = parseSkillLevels(element)

        return SkillResource(id, levels)
    }

    private fun parseSkillLevels(element: Element): List<SkillLevel> {
        val levels = mutableListOf<SkillLevel>()
        val lvlElements = element.getElementsByTagName("lvl")

        for (i in 0 until lvlElements.length) {
            val lvlElement = lvlElements.item(i) as? Element ?: continue
            val xp = lvlElement.getAttribute("xp").toIntOrNull() ?: 0
            val craftXp = getChildElementText(lvlElement, "craft_xp")?.toIntOrNull()
            val craftCost = getChildElementText(lvlElement, "craft_cost")?.toIntOrNull()

            levels.add(SkillLevel(i, xp, craftXp, craftCost))
        }

        return levels
    }

    private fun getChildElementText(element: Element, tagName: String): String? {
        val elements = element.getElementsByTagName(tagName)
        if (elements.length == 0) return null

        val el = elements.item(0) as? Element ?: return null
        return el.textContent.trim().takeIf { it.isNotBlank() }
    }
}
