package dev.deadzone.core.data.assets

import dev.deadzone.core.data.GameDefinitions
import org.w3c.dom.Document

/**
 * Parser for the game XML resources (e.g., `items.xml`, `zombies.xml`)
 *
 * This is used to create code level representation from the game's data.
 *
 * As an example, [ItemsParser] reads the `items.xml` and depending on the item type
 * (e.g., `type="weapon"`, `type="junk"`), it chooses subparser (i.e., [WeaponItemParser])
 * and creates the corresponding [dev.deadzone.core.items.model.Item] object.
 */
interface GameResourcesParser {
    fun parse(doc: Document, gameDefinitions: GameDefinitions)
}
