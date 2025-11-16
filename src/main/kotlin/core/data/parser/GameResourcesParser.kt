package core.data.assets

import core.data.GameDefinition
import org.w3c.dom.Document

/**
 * Parser for the game XML resources (e.g., `items.xml`, `zombies.xml`)
 *
 * This is used to create code level representation from the game's data.
 *
 * As an example, [ItemsParser] reads the `items.xml` and depending on the item type
 * (e.g., `type="weapon"`, `type="junk"`), it chooses subparser (i.e., [WeaponItemParser])
 * and creates the corresponding [core.items.model.Item] object.
 */
interface GameResourcesParser {
    fun parse(doc: Document, gameDefinition: GameDefinition)
}
