package core.data.assets

import core.data.GameDefinition
import org.w3c.dom.Document

interface GameResourcesParser {
    fun parse(doc: Document, gameDefinition: GameDefinition)
}
