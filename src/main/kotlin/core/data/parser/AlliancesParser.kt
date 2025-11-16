package core.data.assets

import core.data.GameDefinition
import core.data.resources.*
import org.w3c.dom.Document
import org.w3c.dom.Element

class AlliancesParser : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        val services = parseServices(doc)
        val individualTiers = parseIndividualTiers(doc)
        val rewards = parseRewards(doc)
        val effectCostPerDayMember = parseEffectCostPerDayMember(doc)
        val effectSets = parseEffectSets(doc)
        val taskSets = parseTaskSets(doc)

        gameDefinition.alliance = AllianceResource(
            services = services,
            individualTiers = individualTiers,
            rewards = rewards,
            effectCostPerDayMember = effectCostPerDayMember,
            effectSets = effectSets,
            taskSets = taskSets
        )
    }

    private fun parseServices(doc: Document): List<AllianceService> {
        val services = mutableListOf<AllianceService>()
        val servicesElements = doc.getElementsByTagName("services")

        if (servicesElements.length == 0) return services

        val servicesElement = servicesElements.item(0) as Element
        val itemNodes = servicesElement.getElementsByTagName("item")

        for (i in 0 until itemNodes.length) {
            val itemElement = itemNodes.item(i) as? Element ?: continue
            val id = itemElement.getAttribute("id")
            val zeroDay = itemElement.getAttribute("zeroday")
            val days = itemElement.getAttribute("days").toIntOrNull() ?: 0
            val graceHours = itemElement.getAttribute("gracehours").toIntOrNull() ?: 0
            val active = itemElement.getAttribute("active") == "1"

            if (id.isNotBlank()) {
                services.add(AllianceService(
                    id = id,
                    zeroDay = zeroDay,
                    days = days,
                    graceHours = graceHours,
                    active = active
                ))
            }
        }

        return services
    }

    private fun parseIndividualTiers(doc: Document): List<AllianceIndividualTier> {
        val tiers = mutableListOf<AllianceIndividualTier>()
        val individualTiersElements = doc.getElementsByTagName("individualTiers")

        if (individualTiersElements.length == 0) return tiers

        val individualTiersElement = individualTiersElements.item(0) as Element
        val tierNodes = individualTiersElement.getElementsByTagName("tier")

        for (i in 0 until tierNodes.length) {
            val tierElement = tierNodes.item(i) as? Element ?: continue
            val score = tierElement.getAttribute("score").toIntOrNull() ?: 0
            val image = tierElement.getAttribute("img").takeIf { it.isNotBlank() }

            val items = mutableListOf<AllianceRewardItem>()
            val itmNodes = tierElement.getElementsByTagName("itm")

            for (j in 0 until itmNodes.length) {
                val itmElement = itmNodes.item(j) as? Element ?: continue
                val type = itmElement.getAttribute("type")
                val quantity = itmElement.getAttribute("q").toIntOrNull() ?: 1

                if (type.isNotBlank()) {
                    items.add(AllianceRewardItem(type = type, quantity = quantity))
                }
            }

            tiers.add(AllianceIndividualTier(score = score, image = image, items = items))
        }

        return tiers
    }

    private fun parseRewards(doc: Document): AllianceRewards? {
        val rewardsElements = doc.getElementsByTagName("rewards")
        if (rewardsElements.length == 0) return null

        val rewardsElement = rewardsElements.item(0) as Element
        val memberCount = rewardsElement.getAttribute("memberCount").toIntOrNull() ?: 0

        val distribution = mutableListOf<Int>()
        val itemNodes = rewardsElement.getElementsByTagName("item")

        for (i in 0 until itemNodes.length) {
            val itemElement = itemNodes.item(i) as? Element ?: continue
            val value = itemElement.textContent.trim().toIntOrNull() ?: 0
            distribution.add(value)
        }

        return AllianceRewards(memberCount = memberCount, distribution = distribution)
    }

    private fun parseEffectCostPerDayMember(doc: Document): Double? {
        val elements = doc.getElementsByTagName("effect_cost_per_day_member")
        if (elements.length == 0) return null

        val element = elements.item(0) as? Element ?: return null
        return element.textContent.trim().toDoubleOrNull()
    }

    private fun parseEffectSets(doc: Document): List<AllianceEffectSet> {
        val effectSets = mutableListOf<AllianceEffectSet>()
        val effectSetsElements = doc.getElementsByTagName("effectSets")

        if (effectSetsElements.length == 0) return effectSets

        val effectSetsElement = effectSetsElements.item(0) as Element
        val setNodes = effectSetsElement.getElementsByTagName("set")

        for (i in 0 until setNodes.length) {
            val setElement = setNodes.item(i) as? Element ?: continue
            val effects = parseList(setElement, "effect")

            effectSets.add(AllianceEffectSet(effects = effects))
        }

        return effectSets
    }

    private fun parseTaskSets(doc: Document): List<AllianceTaskSet> {
        val taskSets = mutableListOf<AllianceTaskSet>()
        val taskSetsElements = doc.getElementsByTagName("taskSets")

        if (taskSetsElements.length == 0) return taskSets

        val taskSetsElement = taskSetsElements.item(0) as Element
        val setNodes = taskSetsElement.getElementsByTagName("set")

        for (i in 0 until setNodes.length) {
            val setElement = setNodes.item(i) as? Element ?: continue
            val tasks = parseList(setElement, "task")

            taskSets.add(AllianceTaskSet(tasks = tasks))
        }

        return taskSets
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
}
