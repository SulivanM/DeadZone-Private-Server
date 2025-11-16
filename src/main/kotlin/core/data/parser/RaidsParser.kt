package core.data.assets

import core.data.GameDefinition
import core.data.resources.*
import org.w3c.dom.Document
import org.w3c.dom.Element

class RaidsParser : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        val raidNodes = doc.getElementsByTagName("raid")

        for (i in 0 until raidNodes.length) {
            val raidElement = raidNodes.item(i) as? Element ?: continue
            val id = raidElement.getAttribute("id")

            if (id.isBlank()) continue

            val levelMin = getChildElementText(raidElement, "level_min")?.toIntOrNull()
            val levelMax = getChildElementText(raidElement, "level_max")?.toIntOrNull()
            val survivorMin = getChildElementText(raidElement, "survivor_min")?.toIntOrNull()
            val survivorMax = getChildElementText(raidElement, "survivor_max")?.toIntOrNull()
            val raidPointsPerSurvivor = getChildElementText(raidElement, "rp_survivor")?.toIntOrNull()

            val stages = parseStages(raidElement)
            val rewards = parseRewards(raidElement)

            val raid = RaidResource(
                id = id,
                levelMin = levelMin,
                levelMax = levelMax,
                survivorMin = survivorMin,
                survivorMax = survivorMax,
                raidPointsPerSurvivor = raidPointsPerSurvivor,
                stages = stages,
                rewards = rewards
            )

            gameDefinition.raidsById[id] = raid
        }
    }

    private fun parseStages(raidElement: Element): List<RaidStage> {
        val stages = mutableListOf<RaidStage>()
        val stageNodes = raidElement.getElementsByTagName("stage")

        for (i in 0 until stageNodes.length) {
            val stageElement = stageNodes.item(i) as? Element ?: continue
            val id = stageElement.getAttribute("id")
            val level = stageElement.getAttribute("level").toIntOrNull()
            val time = getChildElementText(stageElement, "time")?.toIntOrNull()

            val maps = parseMaps(stageElement)

            stages.add(RaidStage(
                id = id,
                level = level,
                time = time,
                maps = maps
            ))
        }

        return stages
    }

    private fun parseMaps(stageElement: Element): List<RaidMap> {
        val maps = mutableListOf<RaidMap>()
        val mapNodes = stageElement.getElementsByTagName("map")

        for (i in 0 until mapNodes.length) {
            val mapElement = mapNodes.item(i) as? Element ?: continue
            val uri = mapElement.getAttribute("uri")
            val tag = mapElement.getAttribute("tag").takeIf { it.isNotBlank() }

            val objectives = parseObjectives(mapElement)

            maps.add(RaidMap(
                uri = uri,
                tag = tag,
                objectives = objectives
            ))
        }

        return maps
    }

    private fun parseObjectives(mapElement: Element): List<RaidObjective> {
        val objectives = mutableListOf<RaidObjective>()
        val objectiveNodes = mapElement.getElementsByTagName("objective")

        for (i in 0 until objectiveNodes.length) {
            val objectiveElement = objectiveNodes.item(i) as? Element ?: continue
            val id = objectiveElement.getAttribute("id")
            val langKey = getChildElementText(objectiveElement, "lang")
            val raidPoints = getChildElementText(objectiveElement, "rp")?.toIntOrNull()

            val triggers = parseTriggers(objectiveElement)

            objectives.add(RaidObjective(
                id = id,
                langKey = langKey,
                raidPoints = raidPoints,
                triggers = triggers
            ))
        }

        return objectives
    }

    private fun parseTriggers(objectiveElement: Element): Map<String, Int> {
        val triggers = mutableMapOf<String, Int>()
        val triggerNodes = objectiveElement.getElementsByTagName("trigger")

        for (i in 0 until triggerNodes.length) {
            val triggerElement = triggerNodes.item(i) as? Element ?: continue
            val id = triggerElement.getAttribute("id")
            val count = triggerElement.textContent.trim().toIntOrNull() ?: 0

            if (id.isNotBlank()) {
                triggers[id] = count
            }
        }

        return triggers
    }

    private fun parseRewards(raidElement: Element): List<RaidRewardTier> {
        val tiers = mutableListOf<RaidRewardTier>()
        val rewardsElements = raidElement.getElementsByTagName("rewards")

        if (rewardsElements.length == 0) return tiers

        val rewardsElement = rewardsElements.item(0) as Element
        val tierNodes = rewardsElement.getElementsByTagName("tier")

        for (i in 0 until tierNodes.length) {
            val tierElement = tierNodes.item(i) as? Element ?: continue
            val score = tierElement.getAttribute("score").toIntOrNull() ?: 0

            val items = mutableListOf<RaidRewardItem>()
            val itmNodes = tierElement.getElementsByTagName("itm")

            for (j in 0 until itmNodes.length) {
                val itmElement = itmNodes.item(j) as? Element ?: continue
                val type = itmElement.getAttribute("type")
                val quantity = itmElement.getAttribute("q").toIntOrNull() ?: 1

                if (type.isNotBlank()) {
                    items.add(RaidRewardItem(type = type, quantity = quantity))
                }
            }

            tiers.add(RaidRewardTier(score = score, items = items))
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
