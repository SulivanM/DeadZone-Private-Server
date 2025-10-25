package core.data.assets

import core.data.GameDefinition
import core.data.resources.*
import core.model.game.data.GameResources
import org.w3c.dom.Document
import org.w3c.dom.Element

class ItemsParser : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        val items = doc.getElementsByTagName("item")

        for (i in 0 until items.length) {
            val itemNode = items.item(i) as? Element ?: continue
            val item = parseItem(itemNode)

            gameDefinition.itemsById[item.id] = item
            gameDefinition.itemsByIdUppercased[item.id.uppercase()] = item
            gameDefinition.itemsByType.getOrPut(item.type) { mutableListOf() }.add(item)

            for (loc in item.lootLocations) {
                gameDefinition.itemsByLootable.getOrPut(loc) { mutableListOf() }.add(item)
            }
        }
    }

    private fun parseItem(element: Element): ItemResource {
        val id = element.getAttribute("id")
        val type = element.getAttribute("type")
        val quality = element.getAttribute("quality").takeIf { it.isNotBlank() }
        val rarity = element.getAttribute("rarity").toDoubleOrNull()
        val image = getChildElementText(element, "img", "uri")
        val model = getChildElementText(element, "mdl", "uri")
        val levelMin = getChildElementText(element, "lvl_min")?.toIntOrNull()
        val levelMax = getChildElementText(element, "lvl_max")?.toIntOrNull()
        val quantityMin = getChildElementText(element, "qnt_min")?.toIntOrNull()
        val quantityMax = getChildElementText(element, "qnt_max")?.toIntOrNull()
        val stack = getChildElementText(element, "stack")?.toIntOrNull() ?: 1
        val lootLocations = element.getAttribute("locs")
            .split(',')
            .map { it.trim() }
            .filter { it.isNotBlank() }
        val resources = parseItemResources(element)
        val kit = parseUpgradeKit(element)
        val weapon = parseWeapon(element)
        val gear = parseGear(element)

        return ItemResource(
            id = id,
            type = type,
            quality = quality,
            rarity = rarity,
            image = image,
            model = model,
            levelMin = levelMin,
            levelMax = levelMax,
            quantityMin = quantityMin,
            quantityMax = quantityMax,
            stack = stack,
            lootLocations = lootLocations,
            resources = resources,
            kit = kit,
            weapon = weapon,
            gear = gear
        )
    }

    private fun parseItemResources(element: Element): GameResources? {
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

    private fun parseUpgradeKit(element: Element): UpgradeKit? {
        val kitElements = element.getElementsByTagName("kit")
        if (kitElements.length == 0) return null

        val kitElement = kitElements.item(0) as Element
        val itemLevelMin = getChildElementText(kitElement, "itm_lvl_min")?.toIntOrNull() ?: 0
        val itemLevelMax = getChildElementText(kitElement, "itm_lvl_max")?.toIntOrNull() ?: 0
        val maxUpgradeChance = getChildElementText(kitElement, "max_upgrade_chance")?.toDoubleOrNull() ?: 0.0

        return UpgradeKit(itemLevelMin, itemLevelMax, maxUpgradeChance)
    }

    private fun parseWeapon(element: Element): WeaponData? {
        val weapElements = element.getElementsByTagName("weap")
        if (weapElements.length == 0) return null

        val weapElement = weapElements.item(0) as Element
        val weaponClass = getChildElementText(weapElement, "cls")
        val weaponType = parseList(weapElement, "type")
        val animation = getChildElementText(weapElement, "anim")
        val swingAnimations = parseSwingAnimations(weapElement)
        val damageMin = getChildElementText(weapElement, "dmg_min")?.toDoubleOrNull()
        val damageMax = getChildElementText(weapElement, "dmg_max")?.toDoubleOrNull()
        val damageLevelMultiplier = weapElement.getElementsByTagName("dmg_min").let { elements ->
            if (elements.length > 0) {
                (elements.item(0) as? Element)?.getAttribute("lvl")?.toDoubleOrNull()
            } else null
        }
        val rate = getChildElementText(weapElement, "rate")?.toDoubleOrNull()
        val range = getChildElementText(weapElement, "rng")?.toDoubleOrNull()
        val capacity = getChildElementText(weapElement, "cap")?.toIntOrNull()
        val accuracy = getChildElementText(weapElement, "acc")?.toDoubleOrNull()
        val reloadTime = getChildElementText(weapElement, "rldtime")?.toDoubleOrNull()
        val damageToBuild = getChildElementText(weapElement, "dmg_bld")?.toDoubleOrNull()
        val knockback = getChildElementText(weapElement, "knock")?.toDoubleOrNull()
        val sounds = parseWeaponSounds(weapElement)

        return WeaponData(
            weaponClass = weaponClass,
            weaponType = weaponType,
            animation = animation,
            swingAnimations = swingAnimations,
            damageMin = damageMin,
            damageMax = damageMax,
            damageLevelMultiplier = damageLevelMultiplier,
            rate = rate,
            range = range,
            capacity = capacity,
            accuracy = accuracy,
            reloadTime = reloadTime,
            damageToBuild = damageToBuild,
            knockback = knockback,
            sounds = sounds
        )
    }

    private fun parseSwingAnimations(element: Element): List<String> {
        val swingElements = element.getElementsByTagName("swing")
        if (swingElements.length == 0) return emptyList()

        val swingElement = swingElements.item(0) as Element
        return parseList(swingElement, "anim")
    }

    private fun parseWeaponSounds(element: Element): WeaponSounds? {
        val sndElements = element.getElementsByTagName("snd")
        if (sndElements.length == 0) return null

        val sndElement = sndElements.item(0) as Element
        val hit = parseList(sndElement, "hit")
        val fire = parseList(sndElement, "fire")
        val reload = parseList(sndElement, "reload")

        if (hit.isEmpty() && fire.isEmpty() && reload.isEmpty()) return null

        return WeaponSounds(hit, fire, reload)
    }

    private fun parseGear(element: Element): GearData? {
        val gearElements = element.getElementsByTagName("gear")
        if (gearElements.length == 0) return null

        val gearElement = gearElements.item(0) as Element
        val slot = getChildElementText(gearElement, "slot")
        val armor = getChildElementText(gearElement, "armor")?.toDoubleOrNull()
        val storage = getChildElementText(gearElement, "storage")?.toIntOrNull()

        return GearData(slot, armor, storage)
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
