package core.data.assets

import core.data.GameDefinition
import core.data.resources.*
import org.w3c.dom.Document
import org.w3c.dom.Element

class InjuryParser : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        // Parse severity configs
        parseSeverityConfigs(doc, gameDefinition)

        // Parse injuries
        parseInjuries(doc, gameDefinition)
    }

    private fun parseSeverityConfigs(doc: Document, gameDefinition: GameDefinition) {
        val severityElements = doc.getElementsByTagName("severity")
        if (severityElements.length == 0) return

        val severityElement = severityElements.item(0) as Element

        // Parse minor severities
        val minorElements = severityElement.getElementsByTagName("minor")
        if (minorElements.length > 0) {
            val minorElement = minorElements.item(0) as Element
            val max = minorElement.getAttribute("max").toIntOrNull() ?: 0
            val levels = parseSeverityLevels(minorElement)
            gameDefinition.severityConfigs.add(SeverityConfig("minor", max, levels))
        }

        // Parse major severities
        val majorElements = severityElement.getElementsByTagName("major")
        if (majorElements.length > 0) {
            val majorElement = majorElements.item(0) as Element
            val max = majorElement.getAttribute("max").toIntOrNull() ?: 0
            val levels = parseSeverityLevels(majorElement)
            gameDefinition.severityConfigs.add(SeverityConfig("major", max, levels))
        }
    }

    private fun parseSeverityLevels(element: Element): List<SeverityLevel> {
        val levels = mutableListOf<SeverityLevel>()
        val severityNodes = element.getElementsByTagName("severity")

        for (i in 0 until severityNodes.length) {
            val severityElement = severityNodes.item(i) as? Element ?: continue
            val type = severityElement.getAttribute("type")
            val rarity = severityElement.getAttribute("rar").toIntOrNull() ?: 0
            val cost = severityElement.getAttribute("cost").toIntOrNull() ?: 0
            val level = severityElement.getAttribute("lvl").toIntOrNull() ?: 0
            val damage = severityElement.getAttribute("dmg").toDoubleOrNull() ?: 0.0
            val morale = severityElement.getAttribute("morale").toIntOrNull() ?: 0
            val time = severityElement.getAttribute("time").toIntOrNull() ?: 0

            levels.add(SeverityLevel(type, rarity, cost, level, damage, morale, time))
        }

        return levels
    }

    private fun parseInjuries(doc: Document, gameDefinition: GameDefinition) {
        val injuryNodes = doc.getElementsByTagName("injury")

        for (i in 0 until injuryNodes.length) {
            val injuryElement = injuryNodes.item(i) as? Element ?: continue
            val type = injuryElement.getAttribute("type")

            if (type.isBlank()) continue

            val causes = parseList(injuryElement, "cause")
            val rarity = getChildElementText(injuryElement, "rar")?.toIntOrNull() ?: 0

            val locations = parseLocations(injuryElement)

            val injury = InjuryResource(
                type = type,
                causes = causes,
                rarity = rarity,
                locations = locations
            )

            gameDefinition.injuriesByType[type] = injury
        }
    }

    private fun parseLocations(injuryElement: Element): List<InjuryLocation> {
        val locations = mutableListOf<InjuryLocation>()
        val locNodes = injuryElement.getElementsByTagName("loc")

        for (i in 0 until locNodes.length) {
            val locElement = locNodes.item(i) as? Element ?: continue
            val id = locElement.getAttribute("id")

            if (id.isBlank()) continue

            val severities = parseSeverities(locElement)

            locations.add(InjuryLocation(id = id, severities = severities))
        }

        return locations
    }

    private fun parseSeverities(locElement: Element): List<InjurySeverity> {
        val severities = mutableListOf<InjurySeverity>()
        val sevNodes = locElement.getElementsByTagName("sev")

        for (i in 0 until sevNodes.length) {
            val sevElement = sevNodes.item(i) as? Element ?: continue
            val type = sevElement.getAttribute("type")

            val combatMelee = getChildElementText(sevElement, "combatMelee")?.toDoubleOrNull()
            val combatProjectile = getChildElementText(sevElement, "combatProjectile")?.toDoubleOrNull()
            val combatImprovised = getChildElementText(sevElement, "combatImprovised")?.toDoubleOrNull()

            val recipe = parseRecipe(sevElement)

            severities.add(InjurySeverity(
                type = type,
                combatMelee = combatMelee,
                combatProjectile = combatProjectile,
                combatImprovised = combatImprovised,
                recipe = recipe
            ))
        }

        return severities
    }

    private fun parseRecipe(sevElement: Element): List<MedicalIngredient> {
        val ingredients = mutableListOf<MedicalIngredient>()
        val recipeElements = sevElement.getElementsByTagName("recipe")

        if (recipeElements.length == 0) return ingredients

        val recipeElement = recipeElements.item(0) as Element
        val medNodes = recipeElement.getElementsByTagName("med")

        for (i in 0 until medNodes.length) {
            val medElement = medNodes.item(i) as? Element ?: continue
            val id = medElement.getAttribute("id")
            val grade = medElement.getAttribute("grade").toIntOrNull() ?: 1

            if (id.isNotBlank()) {
                ingredients.add(MedicalIngredient(id = id, grade = grade))
            }
        }

        return ingredients
    }

    private fun parseList(element: Element, tagName: String): List<String> {
        val list = mutableListOf<String>()
        val elements = element.getElementsByTagName(tagName)

        for (i in 0 until elements.length) {
            val el = elements.item(i) as? Element ?: continue
            val text = el.textContent.trim()
            if (text.isNotBlank()) {
                list.add(text)
            }
        }

        return list
    }

    private fun getChildElementText(element: Element, tagName: String): String? {
        val elements = element.getElementsByTagName(tagName)
        if (elements.length == 0) return null
        val el = elements.item(0) as? Element ?: return null
        return el.textContent.trim().takeIf { it.isNotBlank() }
    }
}
