package core.data.assets

import core.data.GameDefinition
import core.data.resources.BadWord
import core.data.resources.BadwordsResource
import org.w3c.dom.Document
import org.w3c.dom.Element

class BadwordsParser : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        val variations = mutableMapOf<String, String>()
        val words = mutableListOf<BadWord>()

        // Parse variations
        val variationElements = doc.getElementsByTagName("variations")
        if (variationElements.length > 0) {
            val variationsElement = variationElements.item(0) as Element
            val itemNodes = variationsElement.getElementsByTagName("item")
            for (i in 0 until itemNodes.length) {
                val itemElement = itemNodes.item(i) as? Element ?: continue
                val letter = itemElement.getAttribute("t")
                val pattern = itemElement.textContent.trim()
                if (letter.isNotBlank() && pattern.isNotBlank()) {
                    variations[letter] = pattern
                }
            }
        }

        // Parse words
        val wordsElements = doc.getElementsByTagName("words")
        if (wordsElements.length > 0) {
            val wordsElement = wordsElements.item(0) as Element
            val wordNodes = wordsElement.getElementsByTagName("word")
            for (i in 0 until wordNodes.length) {
                val wordElement = wordNodes.item(i) as? Element ?: continue
                val word = wordElement.textContent.trim()
                val important = wordElement.getAttribute("i") == "1"
                if (word.isNotBlank()) {
                    words.add(BadWord(word = word, important = important))
                }
            }
        }

        gameDefinition.badwords = BadwordsResource(
            variations = variations,
            words = words
        )
    }
}
