package core.data.assets

import core.data.GameDefinition
import core.data.resources.*
import org.w3c.dom.Document
import org.w3c.dom.Element

class CraftingParser : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        val schematics = doc.getElementsByTagName("schem")

        for (i in 0 until schematics.length) {
            val schemElement = schematics.item(i) as? Element ?: continue
            val recipe = parseCraftingRecipe(schemElement)

            gameDefinition.craftingRecipesById[recipe.id] = recipe
            gameDefinition.craftingRecipesByType.getOrPut(recipe.type) { mutableListOf() }.add(recipe)
        }
    }

    private fun parseCraftingRecipe(element: Element): CraftingResource {
        val id = element.getAttribute("id")
        val type = element.getAttribute("type")

        val limitElement = element.getElementsByTagName("limit").item(0) as? Element
        val limited = limitElement != null
        val limitStart = limitElement?.let { getChildElementText(it, "start") }
        val limitEnd = limitElement?.let { getChildElementText(it, "end") }

        val result = parseCraftingResult(element)
        val recipe = parseRecipe(element)
        val cost = getChildElementText(element, "cost")?.toIntOrNull() ?: 0

        return CraftingResource(id, type, limited, limitStart, limitEnd, result, recipe, cost)
    }

    private fun parseCraftingResult(element: Element): CraftingResult {
        val itmElements = element.getElementsByTagName("itm")
        if (itmElements.length > 0) {
            val itmElement = itmElements.item(0) as Element
            val type = itmElement.getAttribute("type")
            val level = itmElement.getAttribute("l").toIntOrNull() ?: 0
            return CraftingResult(type, level)
        }
        return CraftingResult("", 0)
    }

    private fun parseRecipe(element: Element): CraftingRecipe {
        val recipeElements = element.getElementsByTagName("recipe")
        if (recipeElements.length == 0) return CraftingRecipe()

        val recipeElement = recipeElements.item(0) as Element
        val items = mutableListOf<CraftingIngredient>()
        val buildings = mutableListOf<BuildingRequirement>()

        val children = recipeElement.childNodes
        for (i in 0 until children.length) {
            val child = children.item(i)
            if (child !is Element) continue

            when (child.tagName) {
                "itm" -> {
                    val id = child.getAttribute("id")
                    val qty = child.textContent.trim().toIntOrNull() ?: 1
                    items.add(CraftingIngredient(id, qty))
                }
                "bld" -> {
                    val id = child.getAttribute("id")
                    val lvl = child.getAttribute("lvl").toIntOrNull() ?: 0
                    buildings.add(BuildingRequirement(id, lvl))
                }
            }
        }

        return CraftingRecipe(items, buildings)
    }

    private fun getChildElementText(element: Element, tagName: String): String? {
        val elements = element.getElementsByTagName(tagName)
        if (elements.length == 0) return null

        val el = elements.item(0) as? Element ?: return null
        return el.textContent.trim().takeIf { it.isNotBlank() }
    }
}
