package core.data.assets

import core.data.GameDefinition
import core.data.resources.*
import org.w3c.dom.Document
import org.w3c.dom.Element

class ArenasParser : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        val arenaNodes = doc.getElementsByTagName("arena")

        for (i in 0 until arenaNodes.length) {
            val arenaElement = arenaNodes.item(i) as? Element ?: continue
            val id = arenaElement.getAttribute("id")

            if (id.isBlank()) continue

            val levelMin = getChildElementText(arenaElement, "level_min")?.toIntOrNull()
            val survivorMin = getChildElementText(arenaElement, "survivor_min")?.toIntOrNull()
            val survivorMax = getChildElementText(arenaElement, "survivor_max")?.toIntOrNull()
            val pointsPerSurvivor = getChildElementText(arenaElement, "pts_survivor")?.toIntOrNull()

            val resources = parseResources(arenaElement)
            val audio = parseAudio(arenaElement)
            val rewards = parseRewards(arenaElement)

            val arena = ArenaResource(
                id = id,
                levelMin = levelMin,
                survivorMin = survivorMin,
                survivorMax = survivorMax,
                pointsPerSurvivor = pointsPerSurvivor,
                resources = resources,
                audio = audio,
                rewards = rewards
            )

            gameDefinition.arenasById[id] = arena
        }
    }

    private fun parseResources(arenaElement: Element): List<String> {
        val resourcesList = mutableListOf<String>()
        val resourcesElements = arenaElement.getElementsByTagName("resources")

        if (resourcesElements.length > 0) {
            val resourcesElement = resourcesElements.item(0) as Element
            val fileNodes = resourcesElement.getElementsByTagName("file")

            for (i in 0 until fileNodes.length) {
                val fileElement = fileNodes.item(i) as? Element ?: continue
                val uri = fileElement.getAttribute("uri")
                if (uri.isNotBlank()) {
                    resourcesList.add(uri)
                }
            }
        }

        return resourcesList
    }

    private fun parseAudio(arenaElement: Element): ArenaAudio? {
        val audioElements = arenaElement.getElementsByTagName("audio")
        if (audioElements.length == 0) return null

        val audioElement = audioElements.item(0) as Element

        return ArenaAudio(
            ambient = parseAudioList(audioElement, "ambient"),
            timerWarning = parseAudioList(audioElement, "timer_warning"),
            survivorDeath = parseAudioList(audioElement, "survivor_death"),
            zombieExplode = parseAudioList(audioElement, "zombie_explode"),
            score = parseAudioList(audioElement, "score"),
            win = parseAudioList(audioElement, "win"),
            lose = parseAudioList(audioElement, "lose"),
            zombieDeath = parseAudioList(audioElement, "zombie_death")
        )
    }

    private fun parseAudioList(audioElement: Element, tagName: String): List<String> {
        val list = mutableListOf<String>()
        val nodes = audioElement.getElementsByTagName(tagName)

        for (i in 0 until nodes.length) {
            val element = nodes.item(i) as? Element ?: continue
            val uri = element.getAttribute("uri")
            if (uri.isNotBlank()) {
                list.add(uri)
            }
        }

        return list
    }

    private fun parseRewards(arenaElement: Element): List<ArenaRewardTier> {
        val tiers = mutableListOf<ArenaRewardTier>()
        val rewardsElements = arenaElement.getElementsByTagName("rewards")

        if (rewardsElements.length == 0) return tiers

        val rewardsElement = rewardsElements.item(0) as Element
        val tierNodes = rewardsElement.getElementsByTagName("tier")

        for (i in 0 until tierNodes.length) {
            val tierElement = tierNodes.item(i) as? Element ?: continue
            val score = tierElement.getAttribute("score").toIntOrNull() ?: 0

            val items = mutableListOf<ArenaRewardItem>()
            val itmNodes = tierElement.getElementsByTagName("itm")

            for (j in 0 until itmNodes.length) {
                val itmElement = itmNodes.item(j) as? Element ?: continue
                val type = itmElement.getAttribute("type")
                val quantity = itmElement.getAttribute("q").toIntOrNull() ?: 1

                if (type.isNotBlank()) {
                    items.add(ArenaRewardItem(type = type, quantity = quantity))
                }
            }

            tiers.add(ArenaRewardTier(score = score, items = items))
        }

        return tiers
    }

    private fun getChildElementText(element: Element, tagName: String): String? {
        val elements = element.getElementsByTagName(tagName)
        if (elements.length == 0) return null
        val el = elements.item(0) as? Element ?: return null
        return el.textContent.trim().takeIf { it.isNotBlank() }
    }
}
