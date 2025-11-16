package core.data.assets

import core.data.GameDefinition
import core.data.resources.*
import org.w3c.dom.Document
import org.w3c.dom.Element

class QuestsGlobalParser : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        val root = doc.documentElement
        val gracePeriod = root.getAttribute("gracePeriod").toIntOrNull()

        val questNodes = doc.getElementsByTagName("quest")

        for (i in 0 until questNodes.length) {
            val questElement = questNodes.item(i) as? Element ?: continue
            val id = questElement.getAttribute("id")
            val type = questElement.getAttribute("type")
            val service = questElement.getAttribute("service").takeIf { it.isNotBlank() }
            val startDate = getChildElementText(questElement, "startDate")
            val endDate = getChildElementText(questElement, "endDate")

            if (id.isBlank()) continue

            val goals = parseGoals(questElement)
            val rewards = parseRewards(questElement)

            val quest = GlobalQuestResource(
                id = id,
                type = type,
                startDate = startDate,
                endDate = endDate,
                service = service,
                goals = goals,
                rewards = rewards
            )

            gameDefinition.globalQuestsById[id] = quest
        }

        gameDefinition.globalQuestGracePeriod = gracePeriod
    }

    private fun parseGoals(questElement: Element): List<GlobalQuestGoal> {
        val goals = mutableListOf<GlobalQuestGoal>()
        val objectivesElements = questElement.getElementsByTagName("objectives")

        if (objectivesElements.length == 0) return goals

        val objectivesElement = objectivesElements.item(0) as Element
        val objectiveNodes = objectivesElement.getElementsByTagName("objective")

        for (i in 0 until objectiveNodes.length) {
            val objectiveElement = objectiveNodes.item(i) as? Element ?: continue
            val statId = objectiveElement.getAttribute("id")
            val contributionMultiplier = objectiveElement.getAttribute("contributionMultiplier").toIntOrNull() ?: 1
            val contributionAmount = objectiveElement.getAttribute("contributionAmount").toIntOrNull() ?: 0
            val goalValue = objectiveElement.getAttribute("goal").toIntOrNull() ?: 0

            if (statId.isNotBlank()) {
                goals.add(GlobalQuestGoal(
                    statId = statId,
                    contributionMultiplier = contributionMultiplier,
                    contributionAmount = contributionAmount,
                    goalValue = goalValue
                ))
            }
        }

        return goals
    }

    private fun parseRewards(questElement: Element): List<GlobalQuestReward> {
        val rewards = mutableListOf<GlobalQuestReward>()
        val rewardsElements = questElement.getElementsByTagName("rewards")

        if (rewardsElements.length == 0) return rewards

        val rewardsElement = rewardsElements.item(0) as Element
        val itemNodes = rewardsElement.getElementsByTagName("item")

        for (i in 0 until itemNodes.length) {
            val itemElement = itemNodes.item(i) as? Element ?: continue
            val type = itemElement.getAttribute("type")
            val itemType = itemElement.getAttribute("itemType").takeIf { it.isNotBlank() }
            val quantity = itemElement.getAttribute("quantity").toIntOrNull()
            val xpPercentage = itemElement.getAttribute("xpPercentage").toDoubleOrNull()

            if (type.isNotBlank()) {
                rewards.add(GlobalQuestReward(
                    type = type,
                    itemType = itemType,
                    quantity = quantity,
                    xpPercentage = xpPercentage
                ))
            }
        }

        return rewards
    }

    private fun getChildElementText(element: Element, tagName: String): String? {
        val elements = element.getElementsByTagName(tagName)
        if (elements.length == 0) return null
        val el = elements.item(0) as? Element ?: return null
        return el.textContent.trim().takeIf { it.isNotBlank() }
    }
}
