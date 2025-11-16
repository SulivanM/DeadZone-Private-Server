package core.data.assets

import core.data.GameDefinition
import core.data.resources.*
import org.w3c.dom.Document
import org.w3c.dom.Element

class ConfigParser : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        val root = doc.documentElement

        // Parse security
        val security = parseSecurityConfig(root)

        // Parse playerio
        val playerio = parsePlayerIOConfig(root)

        // Parse paths
        val paths = parsePathsConfig(root)

        // Parse constants (all uppercase element names)
        val constants = parseConstants(root)

        gameDefinition.config = ConfigResource(
            security = security,
            playerio = playerio,
            paths = paths,
            constants = constants
        )
    }

    private fun parseSecurityConfig(root: Element): SecurityConfig? {
        val securityElements = root.getElementsByTagName("security")
        if (securityElements.length == 0) return null

        val securityElement = securityElements.item(0) as Element
        val policies = mutableListOf<String>()
        val insecure = mutableListOf<String>()

        val policyNodes = securityElement.getElementsByTagName("policy")
        for (i in 0 until policyNodes.length) {
            val policyElement = policyNodes.item(i) as? Element ?: continue
            val policy = policyElement.textContent.trim()
            if (policy.isNotBlank()) {
                policies.add(policy)
            }
        }

        val insecureNodes = securityElement.getElementsByTagName("insecure")
        for (i in 0 until insecureNodes.length) {
            val insecureElement = insecureNodes.item(i) as? Element ?: continue
            val insecureValue = insecureElement.textContent.trim()
            if (insecureValue.isNotBlank()) {
                insecure.add(insecureValue)
            }
        }

        return SecurityConfig(policies = policies, insecure = insecure)
    }

    private fun parsePlayerIOConfig(root: Element): PlayerIOConfig? {
        val playerioElements = root.getElementsByTagName("playerio")
        if (playerioElements.length == 0) return null

        val playerioElement = playerioElements.item(0) as Element
        val gameId = getChildElementText(playerioElement, "gameId") ?: ""
        val connId = getChildElementText(playerioElement, "connId") ?: ""

        if (gameId.isBlank() || connId.isBlank()) return null

        return PlayerIOConfig(gameId = gameId, connId = connId)
    }

    private fun parsePathsConfig(root: Element): PathsConfig? {
        val pathsElements = root.getElementsByTagName("paths")
        if (pathsElements.length == 0) return null

        val pathsElement = pathsElements.item(0) as Element

        return PathsConfig(
            storageUrl = getChildElementText(pathsElement, "storageUrl"),
            saveImageUrl = getChildElementText(pathsElement, "saveImageUrl"),
            loggerUrl = getChildElementText(pathsElement, "loggerUrl"),
            stage3dInfoUrl = getChildElementText(pathsElement, "stage3dInfoUrl"),
            music = getChildElementText(pathsElement, "music"),
            allianceUrl = getChildElementText(pathsElement, "allianceUrl")
        )
    }

    private fun getChildElementText(element: Element, tagName: String): String? {
        val elements = element.getElementsByTagName(tagName)
        if (elements.length == 0) return null
        val el = elements.item(0) as? Element ?: return null
        return el.textContent.trim().takeIf { it.isNotBlank() }
    }

    /**
     * Parse constants from config.xml
     * Implements the same logic as AS3 Config.parse() (lines 76-89)
     * - Iterates through all direct children of root
     * - If element name is uppercase and has text content, it's a constant
     * - Tries to parse as number, otherwise stores as string
     */
    private fun parseConstants(root: Element): Map<String, Any> {
        val constants = mutableMapOf<String, Any>()
        val children = root.childNodes

        for (i in 0 until children.length) {
            val node = children.item(i)
            if (node !is Element) continue

            val name = node.nodeName
            val value = node.textContent?.trim() ?: continue

            // Skip if no text content or if it's a known config section
            if (value.isEmpty() || name in setOf("security", "playerio", "armorgames", "paths", "earn_fuel", "achievements")) {
                continue
            }

            // Try to parse as number (int or double), otherwise store as string
            val parsedValue: Any = value.toIntOrNull()
                ?: value.toDoubleOrNull()
                ?: value

            constants[name] = parsedValue
        }

        return constants
    }
}
