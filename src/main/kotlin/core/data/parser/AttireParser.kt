package core.data.assets

import core.data.GameDefinition
import core.data.resources.*
import org.w3c.dom.Document
import org.w3c.dom.Element

class AttireParser : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        // Parse voices
        parseVoices(doc, gameDefinition)

        // Parse hair textures
        parseHairTextures(doc, gameDefinition)

        // Parse attire items
        parseAttireItems(doc, gameDefinition)
    }

    private fun parseVoices(doc: Document, gameDefinition: GameDefinition) {
        val voicesElements = doc.getElementsByTagName("voices")
        if (voicesElements.length == 0) return

        val voicesElement = voicesElements.item(0) as Element
        val voiceNodes = voicesElement.getElementsByTagName("voice")

        for (i in 0 until voiceNodes.length) {
            val voiceElement = voiceNodes.item(i) as? Element ?: continue
            val id = voiceElement.getAttribute("id")
            val gender = voiceElement.getAttribute("gender")
            val samples = voiceElement.getAttribute("samples").toIntOrNull() ?: 0

            if (id.isNotBlank()) {
                val voice = VoiceResource(id = id, gender = gender, samples = samples)
                gameDefinition.voicesById[id] = voice
            }
        }
    }

    private fun parseHairTextures(doc: Document, gameDefinition: GameDefinition) {
        val hairTexturesElements = doc.getElementsByTagName("hair_textures")
        if (hairTexturesElements.length == 0) return

        val hairTexturesElement = hairTexturesElements.item(0) as Element
        val texNodes = hairTexturesElement.getElementsByTagName("tex")

        for (i in 0 until texNodes.length) {
            val texElement = texNodes.item(i) as? Element ?: continue
            val id = texElement.getAttribute("id")
            val color = texElement.getAttribute("color")
            val uri = texElement.getAttribute("uri")
            val allowRandom = texElement.getAttribute("allow_random") == "1"

            if (id.isNotBlank()) {
                val hairTexture = HairTextureResource(
                    id = id,
                    color = color,
                    uri = uri,
                    allowRandom = allowRandom
                )
                gameDefinition.hairTexturesById[id] = hairTexture
            }
        }
    }

    private fun parseAttireItems(doc: Document, gameDefinition: GameDefinition) {
        val itemNodes = doc.getElementsByTagName("item")

        for (i in 0 until itemNodes.length) {
            val itemElement = itemNodes.item(i) as? Element ?: continue
            val id = itemElement.getAttribute("id")
            val type = itemElement.getAttribute("type")
            val color = itemElement.getAttribute("color").takeIf { it.isNotBlank() }
            val classOnly = itemElement.getAttribute("classOnly") == "1"
            val allowRandom = itemElement.getAttribute("allow_random") == "1"

            if (id.isBlank()) continue

            val male = parseGenderData(itemElement, "male")
            val female = parseGenderData(itemElement, "female")
            val children = parseList(itemElement, "child")
            val flags = parseList(itemElement, "flag")

            val attire = AttireResource(
                id = id,
                type = type,
                color = color,
                classOnly = classOnly,
                allowRandom = allowRandom,
                male = male,
                female = female,
                children = children,
                flags = flags
            )

            gameDefinition.attireById[id] = attire
        }
    }

    private fun parseGenderData(itemElement: Element, gender: String): AttireGenderData? {
        val genderElements = itemElement.getElementsByTagName(gender)
        if (genderElements.length == 0) return null

        val genderElement = genderElements.item(0) as Element

        val model = getChildElementText(genderElement, "mdl", "uri")
        val texture = getChildElementText(genderElement, "tex", "uri")
        val voice = getChildElementText(genderElement, "voice")

        val overlays = parseOverlays(genderElement)

        return AttireGenderData(
            model = model,
            texture = texture,
            voice = voice,
            overlays = overlays
        )
    }

    private fun parseOverlays(genderElement: Element): List<AttireOverlay> {
        val overlays = mutableListOf<AttireOverlay>()
        val overlayNodes = genderElement.getElementsByTagName("overlay")

        for (i in 0 until overlayNodes.length) {
            val overlayElement = overlayNodes.item(i) as? Element ?: continue
            val type = overlayElement.getAttribute("type")
            val uri = overlayElement.getAttribute("uri")

            if (type.isNotBlank() && uri.isNotBlank()) {
                overlays.add(AttireOverlay(type = type, uri = uri))
            }
        }

        return overlays
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
