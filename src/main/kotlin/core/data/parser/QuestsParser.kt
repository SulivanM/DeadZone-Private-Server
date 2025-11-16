package core.data.assets

import core.data.GameDefinition
import core.data.resources.*
import org.w3c.dom.Document
import org.w3c.dom.Element
import common.Logger

class QuestsParser : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        // Parse quest types
        parseQuestTypes(doc, gameDefinition)

        // Parse dynamic quest configs
        parseDynamicQuests(doc, gameDefinition)

        // Parse repeatable achievements
        parseRepeatableAchievements(doc, gameDefinition)

        // Parse regular quests
        parseQuests(doc, gameDefinition)

        // Parse achievements
        parseAchievements(doc, gameDefinition)

        Logger.info { "Loaded ${gameDefinition.questsById.size} quests and ${gameDefinition.achievementsById.size} achievements" }
    }

    private fun parseQuestTypes(doc: Document, gameDefinition: GameDefinition) {
        val typesNode = doc.getElementsByTagName("types").item(0) as? Element ?: return
        val typeNodes = typesNode.getElementsByTagName("type")

        for (i in 0 until typeNodes.length) {
            val typeNode = typeNodes.item(i) as? Element ?: continue
            val typeName = typeNode.textContent.trim()
            if (typeName.isNotBlank()) {
                gameDefinition.questTypes.add(typeName)
            }
        }
    }

    private fun parseDynamicQuests(doc: Document, gameDefinition: GameDefinition) {
        val dynamicNode = doc.getElementsByTagName("dynamic").item(0) as? Element ?: return
        val statNodes = dynamicNode.getElementsByTagName("stat")

        for (i in 0 until statNodes.length) {
            val statNode = statNodes.item(i) as? Element ?: continue
            val config = parseDynamicQuestConfig(statNode)
            gameDefinition.dynamicQuestConfigs.add(config)
        }
    }

    private fun parseDynamicQuestConfig(element: Element): DynamicQuestConfig {
        val statId = element.getAttribute("id")
        val rarity = element.getAttribute("rarity").toIntOrNull() ?: 100

        val levelMin = getChildElementText(element, "lvl_min")?.toIntOrNull() ?: 0
        val levelMax = getChildElementText(element, "lvl_max")?.toIntOrNull() ?: 100

        val minElement = element.getElementsByTagName("min").item(0) as? Element
        val min = minElement?.textContent?.toIntOrNull() ?: 0
        val minLevelMult = minElement?.getAttribute("lvl")?.toDoubleOrNull()

        val maxElement = element.getElementsByTagName("max").item(0) as? Element
        val max = maxElement?.textContent?.toIntOrNull() ?: 0
        val maxLevelMult = maxElement?.getAttribute("lvl")?.toDoubleOrNull()

        val xpElement = element.getElementsByTagName("xp").item(0) as? Element
        val xp = xpElement?.textContent?.toDoubleOrNull() ?: 0.0
        val xpLevelMult = xpElement?.getAttribute("lvl")?.toDoubleOrNull()

        val moraleElement = element.getElementsByTagName("morale").item(0) as? Element
        val morale = moraleElement?.textContent?.toDoubleOrNull() ?: 0.0
        val moraleLevelMult = moraleElement?.getAttribute("lvl")?.toDoubleOrNull()

        return DynamicQuestConfig(
            statId = statId,
            rarity = rarity,
            levelMin = levelMin,
            levelMax = levelMax,
            min = min,
            max = max,
            minLevelMultiplier = minLevelMult,
            maxLevelMultiplier = maxLevelMult,
            xp = xp,
            xpLevelMultiplier = xpLevelMult,
            morale = morale,
            moraleLevelMultiplier = moraleLevelMult
        )
    }

    private fun parseRepeatableAchievements(doc: Document, gameDefinition: GameDefinition) {
        val repeatNode = doc.getElementsByTagName("repeat").item(0) as? Element ?: return
        val achNodes = repeatNode.getElementsByTagName("ach")

        for (i in 0 until achNodes.length) {
            val achNode = achNodes.item(i) as? Element ?: continue
            val achievement = parseRepeatableAchievement(achNode)
            gameDefinition.repeatableAchievements[achievement.id] = achievement
        }
    }

    private fun parseRepeatableAchievement(element: Element): AchievementDefinition {
        val id = element.getAttribute("id")
        val mission = element.getAttribute("mission") == "1"
        val percentage = element.getAttribute("perc") == "1"

        val min = getChildElementText(element, "min")?.toIntOrNull() ?: 0
        val time = getChildElementText(element, "time")?.toDoubleOrNull() ?: 0.0

        val xpElement = element.getElementsByTagName("xp").item(0) as? Element
        val xp = xpElement?.textContent?.toIntOrNull() ?: 0
        val xpLevelMult = xpElement?.getAttribute("mlvl")?.toDoubleOrNull()

        val xpPerc = getChildElementText(element, "xp_perc")?.toDoubleOrNull() ?: 0.0
        val limitPerMission = getChildElementText(element, "limitPerMission")?.toIntOrNull()

        return AchievementDefinition(
            id = id,
            mission = mission,
            min = min,
            time = time,
            xp = xp,
            xpPerc = xpPerc,
            xpLevelMultiplier = xpLevelMult,
            limitPerMission = limitPerMission,
            percentage = percentage
        )
    }

    private fun parseQuests(doc: Document, gameDefinition: GameDefinition) {
        val questsNode = doc.getElementsByTagName("quests").item(0) as? Element ?: return
        val questNodes = questsNode.getElementsByTagName("quest")

        for (i in 0 until questNodes.length) {
            val questNode = questNodes.item(i) as? Element ?: continue
            val quest = parseQuestDefinition(questNode, false)
            gameDefinition.questsById[quest.id] = quest
            gameDefinition.questsByLevel.getOrPut(quest.level) { mutableListOf() }.add(quest)
        }
    }

    private fun parseAchievements(doc: Document, gameDefinition: GameDefinition) {
        val achievementsNode = doc.getElementsByTagName("achievements").item(0) as? Element ?: return
        val achNodes = achievementsNode.getElementsByTagName("ach")

        for (i in 0 until achNodes.length) {
            val achNode = achNodes.item(i) as? Element ?: continue
            val achievement = parseQuestDefinition(achNode, true)
            gameDefinition.achievementsById[achievement.id] = achievement
        }
    }

    private fun parseQuestDefinition(element: Element, isAchievement: Boolean): QuestDefinition {
        val id = element.getAttribute("id")
        val type = if (isAchievement) "achievement" else element.getAttribute("type")
        val level = element.getAttribute("level").toIntOrNull() ?: 0
        val important = element.getAttribute("important") == "1"
        val secret = element.getAttribute("secret").toIntOrNull() ?: 0
        val time = element.getAttribute("time") == "1"
        val visible = element.getAttribute("visible") != "0"
        val silent = element.getAttribute("silent") == "1"

        val startTime = element.getAttribute("start").toLongOrNull()
        val endTime = element.getAttribute("end").toLongOrNull()

        val startImageUri = getChildElementText(element, "img_start", "uri")
        val completeImageUri = getChildElementText(element, "img_comp", "uri")

        val prerequisites = parsePrerequisites(element)
        val goals = parseGoals(element)
        val rewards = parseRewards(element)

        return QuestDefinition(
            id = id,
            type = type,
            level = level,
            important = important,
            secret = secret,
            timeBased = time,
            startImageUri = startImageUri,
            completeImageUri = completeImageUri,
            startTime = startTime,
            endTime = endTime,
            visible = visible && !silent,
            silent = silent,
            prerequisites = prerequisites,
            goals = goals,
            rewards = rewards
        )
    }

    private fun parsePrerequisites(element: Element): List<QuestPrerequisite> {
        val prerequisites = mutableListOf<QuestPrerequisite>()
        val prereqNodes = element.getElementsByTagName("prereq")

        for (i in 0 until prereqNodes.length) {
            val prereqNode = prereqNodes.item(i) as? Element ?: continue
            val questNodes = prereqNode.getElementsByTagName("quest")
            val questIds = mutableListOf<String>()

            for (j in 0 until questNodes.length) {
                val questNode = questNodes.item(j) as? Element ?: continue
                val questId = questNode.textContent.trim()
                if (questId.isNotBlank()) {
                    questIds.add(questId)
                }
            }

            if (questIds.isNotEmpty()) {
                prerequisites.add(QuestPrerequisite(questIds))
            }
        }

        return prerequisites
    }

    private fun parseGoals(element: Element): List<QuestGoal> {
        val goals = mutableListOf<QuestGoal>()
        val goalNode = element.getElementsByTagName("goal").item(0) as? Element ?: return goals

        // Parse different goal types
        parseGoalsByType(goalNode, "stat", GoalType.STAT, goals)
        parseGoalsByType(goalNode, "lvl", GoalType.LEVEL, goals)
        parseGoalsByType(goalNode, "bld", GoalType.BUILDING, goals)
        parseGoalsByType(goalNode, "srv", GoalType.SURVIVOR, goals)
        parseGoalsByType(goalNode, "itm", GoalType.ITEM, goals)
        parseGoalsByType(goalNode, "res", GoalType.RESOURCE, goals)
        parseGoalsByType(goalNode, "tut", GoalType.TUTORIAL, goals)
        parseGoalsByType(goalNode, "task", GoalType.TASK, goals)

        return goals
    }

    private fun parseGoalsByType(goalNode: Element, tagName: String, goalType: GoalType, goals: MutableList<QuestGoal>) {
        val nodes = goalNode.getElementsByTagName(tagName)

        for (i in 0 until nodes.length) {
            val node = nodes.item(i) as? Element ?: continue
            val id = node.getAttribute("id")
            val type = node.getAttribute("type") // For ITEM goals, this specifies item type (weapon, gear, etc.)
            val level = node.getAttribute("lvl").toIntOrNull()
            val desc = node.getAttribute("desc")

            val valueElement = node.getElementsByTagName("val").item(0) as? Element
            val value = valueElement?.textContent?.trim()?.toIntOrNull() ?: 1

            // For ITEM goals, prefer 'type' attribute over 'id' if both exist
            // This handles cases like <itm type="weapon"> vs <itm id="pipe">
            val goalId = when {
                type.isNotBlank() -> type
                id.isNotBlank() -> id
                else -> null
            }

            goals.add(
                QuestGoal(
                    type = goalType,
                    id = goalId,
                    value = value,
                    level = level,
                    description = if (desc.isNotBlank()) desc else null
                )
            )
        }
    }

    private fun parseRewards(element: Element): List<QuestReward> {
        val rewards = mutableListOf<QuestReward>()
        val rewardNode = element.getElementsByTagName("reward").item(0) as? Element ?: return rewards

        // Parse XP rewards
        val xpNodes = rewardNode.getElementsByTagName("xp")
        for (i in 0 until xpNodes.length) {
            val xpNode = xpNodes.item(i) as? Element ?: continue
            val value = xpNode.textContent.trim().toIntOrNull() ?: 0
            val minLevel = xpNode.getAttribute("minlvl").toIntOrNull()
            val maxLevel = xpNode.getAttribute("maxlvl").toIntOrNull()

            rewards.add(
                QuestReward(
                    type = RewardType.XP,
                    value = value,
                    minLevel = minLevel,
                    maxLevel = maxLevel
                )
            )
        }

        // Parse XP percentage rewards
        val xpPercNodes = rewardNode.getElementsByTagName("xpPerc")
        for (i in 0 until xpPercNodes.length) {
            val xpPercNode = xpPercNodes.item(i) as? Element ?: continue
            val percentage = xpPercNode.textContent.trim().toDoubleOrNull() ?: 0.0
            val minLevel = xpPercNode.getAttribute("minlvl").toIntOrNull()
            val maxLevel = xpPercNode.getAttribute("maxlvl").toIntOrNull()

            rewards.add(
                QuestReward(
                    type = RewardType.XP_PERC,
                    percentage = percentage,
                    minLevel = minLevel,
                    maxLevel = maxLevel
                )
            )
        }

        // Parse item rewards
        val itmNodes = rewardNode.getElementsByTagName("itm")
        for (i in 0 until itmNodes.length) {
            val itmNode = itmNodes.item(i) as? Element ?: continue
            val id = itmNode.getAttribute("id")
            val minLevel = itmNode.getAttribute("minlvl").toIntOrNull()
            val maxLevel = itmNode.getAttribute("maxlvl").toIntOrNull()

            // Store the full XML for complex items (with level, quality, etc.)
            val itemXml = if (itmNode.hasChildNodes()) {
                serializeElement(itmNode)
            } else null

            rewards.add(
                QuestReward(
                    type = RewardType.ITEM,
                    id = id,
                    itemXml = itemXml,
                    minLevel = minLevel,
                    maxLevel = maxLevel
                )
            )
        }

        // Parse resource rewards
        val resNodes = rewardNode.getElementsByTagName("res")
        for (i in 0 until resNodes.length) {
            val resNode = resNodes.item(i) as? Element ?: continue
            val id = resNode.getAttribute("id")
            val value = resNode.textContent.trim().toIntOrNull() ?: 0
            val minLevel = resNode.getAttribute("minlvl").toIntOrNull()
            val maxLevel = resNode.getAttribute("maxlvl").toIntOrNull()

            rewards.add(
                QuestReward(
                    type = RewardType.RESOURCE,
                    id = id,
                    value = value,
                    minLevel = minLevel,
                    maxLevel = maxLevel
                )
            )
        }

        return rewards
    }

    private fun serializeElement(element: Element): String {
        return try {
            val transformer = javax.xml.transform.TransformerFactory.newInstance().newTransformer()
            val writer = java.io.StringWriter()
            transformer.transform(javax.xml.transform.dom.DOMSource(element), javax.xml.transform.stream.StreamResult(writer))
            writer.toString()
        } catch (e: Exception) {
            ""
        }
    }

    /**
     * Get the text content of a child element
     */
    private fun getChildElementText(parent: Element, tagName: String): String? {
        val element = parent.getElementsByTagName(tagName).item(0) as? Element
        return element?.textContent?.trim()?.takeIf { it.isNotBlank() }
    }

    /**
     * Get an attribute value from a child element
     */
    private fun getChildElementText(parent: Element, tagName: String, attributeName: String): String? {
        val element = parent.getElementsByTagName(tagName).item(0) as? Element
        return element?.getAttribute(attributeName)?.trim()?.takeIf { it.isNotBlank() }
    }
}
