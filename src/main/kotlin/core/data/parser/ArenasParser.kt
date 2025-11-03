package core.data.assets

import core.data.GameDefinition
import core.model.game.data.arena.ArenaDefinition
import core.model.game.data.arena.ArenaRewardTier
import core.model.game.data.arena.ArenaStageDefinition
import org.w3c.dom.Document
import org.w3c.dom.Element
import utils.Logger

class ArenasParser() : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        val arenas = doc.getElementsByTagName("arena")

        for (i in 0 until arenas.length) {
            val arenaNode = arenas.item(i) as? Element ?: continue
            val arena = parseArena(arenaNode)

            gameDefinition.arenasById[arena.id] = arena
            
        }
    }

    private fun parseArena(element: Element): ArenaDefinition {
        val id = element.getAttribute("id")

        val levelMin = element.getElementsByTagName("level_min").item(0)?.textContent?.toIntOrNull() ?: 1
        val survivorMin = element.getElementsByTagName("survivor_min").item(0)?.textContent?.toIntOrNull() ?: 1
        val survivorMax = element.getElementsByTagName("survivor_max").item(0)?.textContent?.toIntOrNull() ?: 3
        val pointsPerSurvivor = element.getElementsByTagName("pts_survivor").item(0)?.textContent?.toIntOrNull() ?: 100

        val stages = mutableListOf<ArenaStageDefinition>()
        val stageNodes = element.getElementsByTagName("stage")

        for (i in 0 until stageNodes.length) {
            val stageNode = stageNodes.item(i) as? Element ?: continue
            val stage = parseStage(stageNode, i)
            stages.add(stage)
        }

        val rewards = mutableListOf<ArenaRewardTier>()
        val rewardsNode = element.getElementsByTagName("rewards").item(0) as? Element
        if (rewardsNode != null) {
            val tierNodes = rewardsNode.getElementsByTagName("tier")
            for (i in 0 until tierNodes.length) {
                val tierNode = tierNodes.item(i) as? Element ?: continue
                val tier = parseRewardTier(tierNode)
                rewards.add(tier)
            }
        }

        return ArenaDefinition(
            id = id,
            levelMin = levelMin,
            survivorMin = survivorMin,
            survivorMax = survivorMax,
            pointsPerSurvivor = pointsPerSurvivor,
            stages = stages,
            rewards = rewards
        )
    }

    private fun parseStage(element: Element, index: Int): ArenaStageDefinition {
        val stageId = element.getAttribute("id")
        val time = element.getElementsByTagName("time").item(0)?.textContent?.toIntOrNull() ?: 180
        val enemyLevel = element.getElementsByTagName("enemy_lvl").item(0)?.textContent?.toIntOrNull() ?: 0

        val maps = mutableListOf<String>()
        val mapNodes = element.getElementsByTagName("map")
        for (i in 0 until mapNodes.length) {
            val mapNode = mapNodes.item(i) as? Element ?: continue
            val mapUri = mapNode.getAttribute("uri")
            if (mapUri.isNotBlank()) {
                maps.add(mapUri)
            }
        }

        var triggerPoints = 0
        val triggerNodes = element.getElementsByTagName("trigger")
        if (triggerNodes.length > 0) {
            val firstTrigger = triggerNodes.item(0) as? Element
            triggerPoints = firstTrigger?.getAttribute("pts")?.toIntOrNull() ?: 0
        }

        val elites = mutableListOf<String>()
        val elitesNode = element.getElementsByTagName("elites").item(0) as? Element
        if (elitesNode != null) {
            val eliteNodes = elitesNode.getElementsByTagName("elite")
            for (i in 0 until eliteNodes.length) {
                val eliteNode = eliteNodes.item(i) as? Element ?: continue
                val eliteId = eliteNode.getAttribute("id")
                if (eliteId.isNotBlank()) {
                    elites.add(eliteId)
                }
            }
        }

        return ArenaStageDefinition(
            id = stageId,
            index = index,
            time = time,
            enemyLevel = enemyLevel,
            maps = maps,
            triggerPoints = triggerPoints,
            elites = elites
        )
    }

    private fun parseRewardTier(element: Element): ArenaRewardTier {
        val score = element.getAttribute("score").toIntOrNull() ?: 0

        val itemNode = element.getElementsByTagName("itm").item(0) as? Element
        val itemType = itemNode?.getAttribute("type") ?: ""
        val quantity = itemNode?.getAttribute("q")?.toIntOrNull() ?: 1

        return ArenaRewardTier(
            score = score,
            itemType = itemType,
            quantity = quantity
        )
    }
}
