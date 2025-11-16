package core.data.assets

import core.data.GameDefinition
import core.data.resources.VehicleNamesResource
import org.w3c.dom.Document
import org.w3c.dom.Element

class VehicleNamesParser : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        val firstNames = mutableListOf<String>()
        val lastNames = mutableListOf<String>()

        // Parse first names
        val firstElements = doc.getElementsByTagName("first")
        if (firstElements.length > 0) {
            val firstElement = firstElements.item(0) as Element
            val nameNodes = firstElement.getElementsByTagName("n")
            for (i in 0 until nameNodes.length) {
                val nameElement = nameNodes.item(i) as? Element ?: continue
                val name = nameElement.textContent.trim()
                if (name.isNotBlank()) {
                    firstNames.add(name)
                }
            }
        }

        // Parse last names
        val lastElements = doc.getElementsByTagName("last")
        if (lastElements.length > 0) {
            val lastElement = lastElements.item(0) as Element
            val nameNodes = lastElement.getElementsByTagName("n")
            for (i in 0 until nameNodes.length) {
                val nameElement = nameNodes.item(i) as? Element ?: continue
                val name = nameElement.textContent.trim()
                if (name.isNotBlank()) {
                    lastNames.add(name)
                }
            }
        }

        gameDefinition.vehicleNames = VehicleNamesResource(
            firstNames = firstNames,
            lastNames = lastNames
        )
    }
}
