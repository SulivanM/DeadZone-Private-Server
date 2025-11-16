package core.data.assets

import core.data.GameDefinition
import core.data.resources.HumanEnemyResource
import core.data.resources.HumanEnemyWeapon
import org.w3c.dom.Document
import org.w3c.dom.Element

class HumanEnemiesParser : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        // Parse items (weapons)
        parseWeapons(doc, gameDefinition)

        // Parse enemies
        parseEnemies(doc, gameDefinition)
    }

    private fun parseWeapons(doc: Document, gameDefinition: GameDefinition) {
        val itemsElements = doc.getElementsByTagName("items")
        if (itemsElements.length == 0) return

        val itemsElement = itemsElements.item(0) as Element
        val itemNodes = itemsElement.getElementsByTagName("item")

        for (i in 0 until itemNodes.length) {
            val itemElement = itemNodes.item(i) as? Element ?: continue
            val id = itemElement.getAttribute("id")
            val type = itemElement.getAttribute("type")

            if (id.isBlank() || type != "weapon") continue

            val model = getChildElementText(itemElement, "mdl", "uri")
            val weaponData = parseWeaponData(itemElement)

            val weapon = HumanEnemyWeapon(
                id = id,
                model = model,
                weaponClass = weaponData["cls"],
                weaponType = weaponData["type"],
                anim = weaponData["anim"],
                damageMin = weaponData["dmg_min"]?.toIntOrNull(),
                damageMax = weaponData["dmg_max"]?.toIntOrNull(),
                rate = weaponData["rate"]?.toDoubleOrNull(),
                range = weaponData["rng"]?.toIntOrNull(),
                rangeMinEffective = weaponData["rng_min_effective"]?.toIntOrNull(),
                accuracy = weaponData["acc"]?.toDoubleOrNull(),
                capacity = weaponData["cap"]?.toIntOrNull(),
                noise = weaponData["noise"]?.toIntOrNull(),
                reloadTime = weaponData["rldtime"]?.toDoubleOrNull(),
                sounds = parseSounds(itemElement)
            )

            gameDefinition.humanEnemyWeaponsById[id] = weapon
        }
    }

    private fun parseWeaponData(itemElement: Element): Map<String, String> {
        val data = mutableMapOf<String, String>()
        val weapElements = itemElement.getElementsByTagName("weap")

        if (weapElements.length == 0) return data

        val weapElement = weapElements.item(0) as Element
        val childNodes = weapElement.childNodes

        for (i in 0 until childNodes.length) {
            val node = childNodes.item(i)
            if (node is Element) {
                val value = node.textContent.trim()
                if (value.isNotBlank()) {
                    data[node.tagName] = value
                }
            }
        }

        return data
    }

    private fun parseSounds(itemElement: Element): Map<String, List<String>> {
        val sounds = mutableMapOf<String, List<String>>()
        val weapElements = itemElement.getElementsByTagName("weap")

        if (weapElements.length == 0) return sounds

        val weapElement = weapElements.item(0) as Element
        val sndElements = weapElement.getElementsByTagName("snd")

        if (sndElements.length == 0) return sounds

        val sndElement = sndElements.item(0) as Element
        val soundTypes = listOf("fire", "reload", "hit")

        for (soundType in soundTypes) {
            val soundNodes = sndElement.getElementsByTagName(soundType)
            val soundList = mutableListOf<String>()

            for (i in 0 until soundNodes.length) {
                val soundElement = soundNodes.item(i) as? Element ?: continue
                val sound = soundElement.textContent.trim()
                if (sound.isNotBlank()) {
                    soundList.add(sound)
                }
            }

            if (soundList.isNotEmpty()) {
                sounds[soundType] = soundList
            }
        }

        return sounds
    }

    private fun parseEnemies(doc: Document, gameDefinition: GameDefinition) {
        val enemiesElements = doc.getElementsByTagName("enemies")
        if (enemiesElements.length == 0) return

        val enemiesElement = enemiesElements.item(0) as Element
        val humanNodes = enemiesElement.getElementsByTagName("human")

        for (i in 0 until humanNodes.length) {
            val humanElement = humanNodes.item(i) as? Element ?: continue
            val id = humanElement.getAttribute("id")
            val type = humanElement.getAttribute("type")

            if (id.isBlank()) continue

            val hp = getChildElementText(humanElement, "hp")?.toIntOrNull()
            val scale = getChildElementText(humanElement, "scale")?.toDoubleOrNull()

            // Parse model
            val mdlElements = humanElement.getElementsByTagName("mdl")
            var upper: String? = null
            var lower: String? = null

            if (mdlElements.length > 0) {
                val mdlElement = mdlElements.item(0) as Element
                upper = getChildElementText(mdlElement, "upper", "id")
                lower = getChildElementText(mdlElement, "lower", "id")
            }

            // Parse loadout
            val loadoutElements = humanElement.getElementsByTagName("loadout")
            val weapons = mutableListOf<String>()
            val gear = mutableListOf<String>()

            if (loadoutElements.length > 0) {
                val loadoutElement = loadoutElements.item(0) as Element

                val weaponNodes = loadoutElement.getElementsByTagName("weapon")
                for (j in 0 until weaponNodes.length) {
                    val weaponElement = weaponNodes.item(j) as? Element ?: continue
                    val weaponId = weaponElement.getAttribute("id")
                    if (weaponId.isNotBlank()) {
                        weapons.add(weaponId)
                    }
                }

                val gearNodes = loadoutElement.getElementsByTagName("gear")
                for (j in 0 until gearNodes.length) {
                    val gearElement = gearNodes.item(j) as? Element ?: continue
                    val gearId = gearElement.getAttribute("id")
                    if (gearId.isNotBlank()) {
                        gear.add(gearId)
                    }
                }
            }

            val enemy = HumanEnemyResource(
                id = id,
                type = type,
                hp = hp,
                scale = scale,
                upper = upper,
                lower = lower,
                weapons = weapons,
                gear = gear
            )

            gameDefinition.humanEnemiesById[id] = enemy
        }
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
