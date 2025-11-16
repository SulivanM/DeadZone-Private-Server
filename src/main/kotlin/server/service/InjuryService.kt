package server.service

import core.data.GameDefinition
import core.data.resources.InjuryResource
import core.data.resources.InjurySeverity
import core.data.resources.MedicalIngredient
import core.data.resources.SeverityConfig
import core.data.resources.SeverityLevel

/**
 * Service pour gérer les blessures basé sur injury.xml
 * Applique des dégâts, modificateurs d'attributs et recettes de guérison
 */
object InjuryService {

    /**
     * Récupère la définition complète d'une blessure
     *
     * @param type Type de blessure (ex: "sprain", "fracture")
     * @param location Localisation (ex: "arm", "leg", "head")
     * @param severity Sévérité (ex: "minor", "moderate", "major")
     * @return InjuryDefinition avec tous les détails, ou null si non trouvée
     */
    fun getInjuryDefinition(type: String, location: String, severity: String): InjuryDefinition? {
        val injuryResource = GameDefinition.injuriesByType[type] ?: return null

        val injuryLocation = injuryResource.locations.find { it.id == location } ?: return null
        val injurySeverity = injuryLocation.severities.find { it.type == severity } ?: return null

        // Récupérer les données de sévérité globales
        val severityLevel = getSeverityLevel(type, severity) ?: return null

        return InjuryDefinition(
            type = type,
            location = location,
            severity = severity,
            damage = severityLevel.damage.toInt(),
            morale = severityLevel.morale,
            healTime = severityLevel.time,
            attributeModifiers = extractAttributeModifiers(injurySeverity),
            recipe = injurySeverity.recipe
        )
    }

    /**
     * Calcule les effets d'une blessure sur un survivant
     *
     * @param injuryDef Définition de la blessure
     * @return InjuryEffects avec les modificateurs à appliquer
     */
    fun calculateInjuryEffects(injuryDef: InjuryDefinition): InjuryEffects {
        val modifiers = injuryDef.attributeModifiers

        return InjuryEffects(
            healthDamage = injuryDef.damage,
            moraleChange = injuryDef.morale,
            strengthMultiplier = modifiers["strength"] ?: 1.0,
            constitutionMultiplier = modifiers["constitution"] ?: 1.0,
            dexterityMultiplier = modifiers["dexterity"] ?: 1.0
        )
    }

    /**
     * Récupère la configuration d'une sévérité spécifique
     *
     * @param severityType Type de sévérité (ex: "minor", "moderate", "major")
     * @return SeverityConfig correspondante, ou null si non trouvée
     */
    fun getSeverityConfig(severityType: String): SeverityConfig? {
        return GameDefinition.severityConfigs.find { config ->
            config.severityLevels.any { it.type == severityType }
        }
    }

    /**
     * Récupère une blessure aléatoire pour une localisation donnée
     *
     * @param location Localisation de la blessure
     * @return InjuryDefinition aléatoire, ou null si aucune n'est disponible
     */
    fun getRandomInjury(location: String): InjuryDefinition? {
        // Récupérer toutes les blessures possibles pour cette localisation
        val possibleInjuries = mutableListOf<Triple<String, String, String>>()

        for ((type, injuryResource) in GameDefinition.injuriesByType) {
            val injuryLocation = injuryResource.locations.find { it.id == location }
            if (injuryLocation != null) {
                for (severity in injuryLocation.severities) {
                    possibleInjuries.add(Triple(type, location, severity.type))
                }
            }
        }

        if (possibleInjuries.isEmpty()) return null

        // Sélectionner une blessure aléatoire
        val (randomType, randomLocation, randomSeverity) = possibleInjuries.random()
        return getInjuryDefinition(randomType, randomLocation, randomSeverity)
    }

    /**
     * Vérifie si une blessure peut être guérie avec les items disponibles
     *
     * @param injuryDef Définition de la blessure
     * @param availableItems Liste des IDs d'items disponibles
     * @return true si tous les ingrédients requis sont disponibles, false sinon
     */
    fun canHealInjury(injuryDef: InjuryDefinition, availableItems: List<String>): Boolean {
        if (injuryDef.recipe.isEmpty()) {
            // Pas de recette requise, peut être guéri naturellement
            return true
        }

        // Vérifier que tous les ingrédients sont disponibles
        return injuryDef.recipe.all { ingredient ->
            availableItems.contains(ingredient.id)
        }
    }

    /**
     * Récupère toutes les blessures disponibles pour un type donné
     *
     * @param type Type de blessure
     * @return InjuryResource correspondante, ou null si non trouvée
     */
    fun getInjuryResourceByType(type: String): InjuryResource? {
        return GameDefinition.injuriesByType[type]
    }

    /**
     * Récupère tous les types de blessures disponibles
     *
     * @return Liste de tous les types de blessures
     */
    fun getAllInjuryTypes(): List<String> {
        return GameDefinition.injuriesByType.keys.toList()
    }

    // Fonctions utilitaires privées

    private fun getSeverityLevel(injuryType: String, severity: String): SeverityLevel? {
        // Chercher dans toutes les configurations de sévérité (minor, major)
        // pour trouver celle qui contient le niveau de sévérité demandé
        for (severityConfig in GameDefinition.severityConfigs) {
            val level = severityConfig.severityLevels.find { it.type == severity }
            if (level != null) {
                return level
            }
        }
        return null
    }

    private fun extractAttributeModifiers(injurySeverity: InjurySeverity): Map<String, Double> {
        val modifiers = mutableMapOf<String, Double>()

        // Les modificateurs de combat peuvent affecter les attributs
        injurySeverity.combatMelee?.let { modifiers["strength"] = it }
        injurySeverity.combatProjectile?.let { modifiers["dexterity"] = it }
        injurySeverity.combatImprovised?.let { modifiers["constitution"] = it }

        return modifiers
    }
}

/**
 * Définition complète d'une blessure
 */
data class InjuryDefinition(
    val type: String,
    val location: String,
    val severity: String,
    val damage: Int,
    val morale: Int,
    val healTime: Int,
    val attributeModifiers: Map<String, Double>,  // "strength" -> 0.95
    val recipe: List<MedicalIngredient>
)

/**
 * Effets d'une blessure sur un survivant
 */
data class InjuryEffects(
    val healthDamage: Int,
    val moraleChange: Int,
    val strengthMultiplier: Double = 1.0,
    val constitutionMultiplier: Double = 1.0,
    val dexterityMultiplier: Double = 1.0
)
