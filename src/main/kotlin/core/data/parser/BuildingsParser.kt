package core.data.assets

import core.data.GameDefinition
import core.data.resources.*
import core.model.game.data.GameResources
import org.w3c.dom.Document
import org.w3c.dom.Element
import org.w3c.dom.NodeList

class BuildingsParser : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        val items = doc.getElementsByTagName("item")

        for (i in 0 until items.length) {
            val itemElement = items.item(i) as? Element ?: continue
            val building = parseBuilding(itemElement)

            gameDefinition.buildingsById[building.id] = building
            gameDefinition.buildingsByType.getOrPut(building.type) { mutableListOf() }.add(building)
        }
    }

    private fun parseBuilding(element: Element): BuildingResource {
        val id = element.getAttribute("id")
        val type = element.getAttribute("type")
        val max = element.getAttribute("max").toIntOrNull() ?: 1
        val indoor = element.getAttribute("indoor") == "1"
        val outdoor = element.getAttribute("outdoor") == "1"
        val scav = element.getAttribute("scav") == "1"
        val assignable = element.getAttribute("assignable") == "1"
        val destroy = element.getAttribute("destroy") == "1"
        val connect = element.getAttribute("connect") == "1"

        val size = parseBuildingSize(element)
        val model = getChildElementText(element, "mdl", "uri")
        val damagedModel = getChildElementText(element, "damaged_mdl", "uri")
        val image = getChildElementText(element, "img", "uri")
        val health = getChildElementText(element, "health")?.toIntOrNull()
        val sounds = parseBuildingSounds(element)
        val resources = parseBuildingResources(element)
        val resourceMultiplier = element.getElementsByTagName("res").let { resList ->
            if (resList.length > 0) {
                (resList.item(0) as? Element)?.getAttribute("m")?.toDoubleOrNull() ?: 1.0
            } else 1.0
        }
        val craft = parseList(element, "craft")
        val store = getChildElementText(element, "store")
        val cover = getChildElementText(element, "cover")?.toIntOrNull()
        val assignPositions = parseAssignPositions(element)
        val levels = parseBuildingLevels(element)

        return BuildingResource(
            id = id,
            type = type,
            max = max,
            indoor = indoor,
            outdoor = outdoor,
            scav = scav,
            assignable = assignable,
            destroy = destroy,
            connect = connect,
            size = size,
            model = model,
            damagedModel = damagedModel,
            image = image,
            health = health,
            sounds = sounds,
            resources = resources,
            resourceMultiplier = resourceMultiplier,
            craft = craft,
            store = store,
            cover = cover,
            assignPositions = assignPositions,
            levels = levels
        )
    }

    private fun parseBuildingSize(element: Element): BuildingSize {
        val sizeElements = element.getElementsByTagName("size")
        if (sizeElements.length > 0) {
            val sizeElement = sizeElements.item(0) as Element
            val x = sizeElement.getAttribute("x").toIntOrNull() ?: 1
            val y = sizeElement.getAttribute("y").toIntOrNull() ?: 1
            return BuildingSize(x, y)
        }
        return BuildingSize(1, 1)
    }

    private fun parseBuildingSounds(element: Element): BuildingSounds? {
        val sndElements = element.getElementsByTagName("snd")
        if (sndElements.length > 0) {
            val sndElement = sndElements.item(0) as Element
            val deaths = parseList(sndElement, "death")
            if (deaths.isNotEmpty()) {
                return BuildingSounds(death = deaths)
            }
        }
        return null
    }

    private fun parseBuildingResources(element: Element): GameResources? {
        val resElements = element.getElementsByTagName("res")
        if (resElements.length == 0) return null

        val resContainer = resElements.item(0) as? Element ?: return null
        val resourceChildren = resContainer.childNodes

        var wood = 0
        var metal = 0
        var cloth = 0
        var water = 0
        var food = 0
        var ammunition = 0
        var cash = 0

        for (i in 0 until resourceChildren.length) {
            val node = resourceChildren.item(i)
            if (node is Element && node.tagName == "res") {
                val resId = node.getAttribute("id")
                val amount = node.textContent.trim().toIntOrNull() ?: 0

                when (resId) {
                    "wood" -> wood = amount
                    "metal" -> metal = amount
                    "cloth" -> cloth = amount
                    "water" -> water = amount
                    "food" -> food = amount
                    "ammunition" -> ammunition = amount
                    "cash" -> cash = amount
                }
            }
        }

        if (wood == 0 && metal == 0 && cloth == 0 && water == 0 && food == 0 && ammunition == 0 && cash == 0) {
            return null
        }

        return GameResources(
            wood = wood,
            metal = metal,
            cloth = cloth,
            water = water,
            food = food,
            ammunition = ammunition,
            cash = cash
        )
    }

    private fun parseAssignPositions(element: Element): List<BuildingAssignPosition> {
        val positions = mutableListOf<BuildingAssignPosition>()
        val assignElements = element.getElementsByTagName("assign")

        for (i in 0 until assignElements.length) {
            val assignElement = assignElements.item(i) as? Element ?: continue
            val x = assignElement.getAttribute("x").toIntOrNull() ?: 0
            val y = assignElement.getAttribute("y").toIntOrNull() ?: 0
            positions.add(BuildingAssignPosition(x, y))
        }

        return positions
    }

    private fun parseBuildingLevels(element: Element): List<BuildingLevel> {
        val levels = mutableListOf<BuildingLevel>()
        val lvlElements = element.getElementsByTagName("lvl")

        for (i in 0 until lvlElements.length) {
            val lvlElement = lvlElements.item(i) as? Element ?: continue
            val number = lvlElement.getAttribute("n").toIntOrNull() ?: i

            val cover = getChildElementText(lvlElement, "cover")?.toIntOrNull()
            val xp = getChildElementText(lvlElement, "xp")?.toIntOrNull()
            val time = getChildElementText(lvlElement, "time")?.toIntOrNull()
            val model = getChildElementText(lvlElement, "mdl", "uri")
            val image = getChildElementText(lvlElement, "img", "uri")
            val comfort = getChildElementText(lvlElement, "comfort")?.toIntOrNull()
            val security = getChildElementText(lvlElement, "security")?.toIntOrNull()
            val capacity = getChildElementText(lvlElement, "cap")?.toIntOrNull()
            val maxUpgradeLevel = getChildElementText(lvlElement, "max_upgrade_level")?.toIntOrNull()
            val production = parseBuildingProduction(lvlElement, capacity)
            val requirements = parseBuildingRequirements(lvlElement)
            val items = parseBuildingLevelItems(lvlElement)

            levels.add(
                BuildingLevel(
                    number = number,
                    cover = cover,
                    xp = xp,
                    time = time,
                    model = model,
                    image = image,
                    comfort = comfort,
                    security = security,
                    capacity = capacity,
                    maxUpgradeLevel = maxUpgradeLevel,
                    production = production,
                    requirements = requirements,
                    items = items
                )
            )
        }

        return levels
    }

    private fun parseBuildingProduction(element: Element, capacity: Int?): BuildingProduction? {
        // Check if this level has a production rate (for resource-producing buildings)
        val rate = getChildElementText(element, "rate")?.toDoubleOrNull()
        
        // If no rate is defined, this is not a production building level
        if (rate == null) return null

        // For production buildings, capacity (cap) represents the production storage capacity
        return BuildingProduction(rate = rate, cap = capacity, capacity = capacity)
    }

    private fun parseBuildingRequirements(element: Element): BuildingRequirements? {
        val reqElements = element.getElementsByTagName("req")
        if (reqElements.length == 0) return null

        val reqElement = reqElements.item(0) as Element
        val buildings = mutableListOf<BuildingRequirement>()
        val items = mutableListOf<ItemRequirement>()
        var level: Int? = null

        val children = reqElement.childNodes
        for (i in 0 until children.length) {
            val child = children.item(i)
            if (child !is Element) continue

            when (child.tagName) {
                "bld" -> {
                    val id = child.getAttribute("id")
                    val lvl = child.getAttribute("lvl").toIntOrNull() ?: 0
                    val qty = child.textContent.trim().toIntOrNull() ?: 1
                    buildings.add(BuildingRequirement(id, lvl, qty))
                }
                "itm" -> {
                    val id = child.getAttribute("id")
                    val qty = child.textContent.trim().toIntOrNull() ?: 1
                    items.add(ItemRequirement(id, qty))
                }
                "lvl" -> {
                    level = child.textContent.trim().toIntOrNull()
                }
            }
        }

        if (buildings.isEmpty() && items.isEmpty() && level == null) return null

        return BuildingRequirements(buildings, items, level)
    }

    private fun parseBuildingLevelItems(element: Element): List<BuildingLevelItem> {
        val levelItems = mutableListOf<BuildingLevelItem>()
        val itemsElements = element.getElementsByTagName("items")

        if (itemsElements.length == 0) return levelItems

        val itemsElement = itemsElements.item(0) as Element
        val itmElements = itemsElement.getElementsByTagName("itm")

        for (i in 0 until itmElements.length) {
            val itmElement = itmElements.item(i) as? Element ?: continue
            val type = itmElement.getAttribute("type")
            val lvl = itmElement.getAttribute("l").toIntOrNull() ?: 0
            val qty = itmElement.getAttribute("q").toIntOrNull() ?: 1
            val mod1 = itmElement.getAttribute("m1").takeIf { it.isNotBlank() }

            levelItems.add(BuildingLevelItem(type, lvl, qty, mod1))
        }

        return levelItems
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

    private fun getChildElementText(element: Element, tagName: String, attribute: String? = null): String? {
        val elements = element.getElementsByTagName(tagName)
        if (elements.length == 0) return null

        val el = elements.item(0) as? Element ?: return null

        return if (attribute != null) {
            el.getAttribute(attribute).takeIf { it.isNotBlank() }
        } else {
            el.textContent.trim().takeIf { it.isNotBlank() }
        }
    }
}
