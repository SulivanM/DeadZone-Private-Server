package core.data.assets

import core.data.GameDefinition
import core.data.resources.EffectResource
import org.w3c.dom.Document
import org.w3c.dom.Element

class EffectsParser : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        val effects = doc.getElementsByTagName("effect")

        for (i in 0 until effects.length) {
            val effectElement = effects.item(i) as? Element ?: continue
            val effect = parseEffect(effectElement)

            gameDefinition.effectsById[effect.id] = effect
        }

        val types = doc.getElementsByTagName("types")
        if (types.length > 0) {
            val typesElement = types.item(0) as Element
            val typesList = typesElement.textContent.split(',').map { it.trim() }
            gameDefinition.effectTypes.addAll(typesList)
        }
    }

    private fun parseEffect(element: Element): EffectResource {
        val id = element.getAttribute("id")
        val icon = getChildElementText(element, "icon", "uri")
        val image = getChildElementText(element, "img", "uri")
        val group = getChildElementText(element, "group")
        val find = element.getAttribute("find").toIntOrNull() ?: 1

        return EffectResource(id, icon, image, group, find)
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
