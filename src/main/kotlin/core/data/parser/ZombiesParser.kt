package core.data.assets

import core.data.GameDefinition
import core.data.resources.*
import org.w3c.dom.Document
import org.w3c.dom.Element

class ZombiesParser : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        // Parse zombie sounds
        val sounds = parseZombieSounds(doc)
        gameDefinition.zombieSounds = sounds

        // Parse zombie limits
        val limits = parseZombieLimits(doc)
        gameDefinition.zombieLimits = limits

        // Parse zombie weapons
        parseZombieWeapons(doc, gameDefinition)
    }

    private fun parseZombieSounds(doc: Document): ZombieSounds {
        val soundsElements = doc.getElementsByTagName("sounds")
        if (soundsElements.length == 0) return ZombieSounds()

        val soundsElement = soundsElements.item(0) as Element

        val male = parseZombieVoiceSet(soundsElement, "zombieHuman", "male")
        val female = parseZombieVoiceSet(soundsElement, "zombieHuman", "female")
        val dog = parseZombieVoiceSet(soundsElement, "zombieDog", null)

        return ZombieSounds(male = male, female = female, dog = dog)
    }

    private fun parseZombieVoiceSet(soundsElement: Element, type: String, gender: String?): ZombieVoiceSet? {
        val typeElements = soundsElement.getElementsByTagName(type)
        if (typeElements.length == 0) return null

        val typeElement = typeElements.item(0) as Element

        val genderElement = if (gender != null) {
            val genderElements = typeElement.getElementsByTagName(gender)
            if (genderElements.length == 0) return null
            genderElements.item(0) as Element
        } else {
            typeElement
        }

        return ZombieVoiceSet(
            alert = parseList(genderElement, "alert"),
            idle = parseList(genderElement, "idle"),
            death = parseList(genderElement, "death"),
            attack = parseList(genderElement, "attack"),
            hurt = parseList(genderElement, "hurt")
        )
    }

    private fun parseZombieLimits(doc: Document): ZombieLimits {
        val tags = mutableMapOf<Int, String>()

        val limitsElements = doc.getElementsByTagName("limits")
        if (limitsElements.length > 0) {
            val limitsElement = limitsElements.item(0) as Element
            val tagNodes = limitsElement.getElementsByTagName("tag")

            for (i in 0 until tagNodes.length) {
                val tagElement = tagNodes.item(i) as? Element ?: continue
                val sec = tagElement.getAttribute("sec").toIntOrNull()
                val tag = tagElement.textContent.trim()

                if (sec != null && tag.isNotBlank()) {
                    tags[sec] = tag
                }
            }
        }

        return ZombieLimits(tags = tags)
    }

    private fun parseZombieWeapons(doc: Document, gameDefinition: GameDefinition) {
        val weaponsElements = doc.getElementsByTagName("weapons")
        if (weaponsElements.length == 0) return

        val weaponsElement = weaponsElements.item(0) as Element
        val weaponNodes = weaponsElement.getElementsByTagName("item")

        for (i in 0 until weaponNodes.length) {
            val weaponElement = weaponNodes.item(i) as? Element ?: continue
            val id = weaponElement.getAttribute("id")
            val type = weaponElement.getAttribute("type")

            if (id.isBlank()) continue

            val weaponData = parseWeaponData(weaponElement)

            val zombieWeapon = ZombieResource(
                id = id,
                type = type,
                weapon = weaponData
            )

            gameDefinition.zombieWeaponsById[id] = zombieWeapon
        }
    }

    private fun parseWeaponData(element: Element): WeaponData? {
        val weapElements = element.getElementsByTagName("weap")
        if (weapElements.length == 0) return null

        val weapElement = weapElements.item(0) as Element

        return WeaponData(
            weaponClass = getChildElementText(weapElement, "cls"),
            weaponType = parseList(weapElement, "type"),
            animation = getChildElementText(weapElement, "anim"),
            swingAnimations = emptyList(),
            damageMin = getChildElementText(weapElement, "dmg_min")?.toDoubleOrNull(),
            damageMax = getChildElementText(weapElement, "dmg_max")?.toDoubleOrNull(),
            damageLevelMultiplier = null,
            rate = getChildElementText(weapElement, "rate")?.toDoubleOrNull(),
            range = getChildElementText(weapElement, "rng")?.toDoubleOrNull(),
            capacity = getChildElementText(weapElement, "cap")?.toIntOrNull(),
            accuracy = getChildElementText(weapElement, "acc")?.toDoubleOrNull(),
            reloadTime = getChildElementText(weapElement, "rldtime")?.toDoubleOrNull(),
            damageToBuild = getChildElementText(weapElement, "dmg_bld")?.toDoubleOrNull(),
            knockback = getChildElementText(weapElement, "knock")?.toDoubleOrNull(),
            sounds = null
        )
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
