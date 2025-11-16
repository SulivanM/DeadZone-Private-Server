package server.service

import core.data.GameDefinition
import core.data.resources.AttireResource
import core.data.resources.HairTextureResource
import core.data.resources.VoiceResource

/**
 * Service pour gérer les apparences et tenues basé sur attire.xml
 * Gère les voix, textures de cheveux et vêtements des personnages
 */
object AttireService {

    /**
     * Récupère une voix par ID
     *
     * @param voiceId ID de la voix
     * @return VoiceResource correspondante, ou null si non trouvée
     */
    fun getVoice(voiceId: String): VoiceResource? {
        return GameDefinition.voicesById[voiceId]
    }

    /**
     * Récupère une texture de cheveux par ID
     *
     * @param textureId ID de la texture
     * @return HairTextureResource correspondante, ou null si non trouvée
     */
    fun getHairTexture(textureId: String): HairTextureResource? {
        return GameDefinition.hairTexturesById[textureId]
    }

    /**
     * Récupère un item de tenue par ID
     *
     * @param attireId ID de la tenue
     * @return AttireResource correspondante, ou null si non trouvée
     */
    fun getAttireItem(attireId: String): AttireResource? {
        return GameDefinition.attireById[attireId]
    }

    /**
     * Récupère une texture de cheveux aléatoire
     *
     * @param allowRandomOnly Si true, seulement les textures marquées allowRandom sont considérées
     * @return HairTextureResource aléatoire, ou null si aucune texture disponible
     */
    fun getRandomHairTexture(allowRandomOnly: Boolean = true): HairTextureResource? {
        val textures = if (allowRandomOnly) {
            GameDefinition.hairTexturesById.values.filter { it.allowRandom }
        } else {
            GameDefinition.hairTexturesById.values.toList()
        }

        return textures.randomOrNull()
    }

    /**
     * Récupère toutes les tenues d'un type spécifique
     *
     * @param type Type de tenue (ex: "upper", "lower", "head", "feet")
     * @return Liste des AttireResource correspondantes
     */
    fun getAttiresByType(type: String): List<AttireResource> {
        return GameDefinition.attireById.values
            .filter { it.type == type }
    }

    /**
     * Valide qu'une combinaison de tenues est compatible
     * Vérifie les conflits entre différents items
     *
     * @param attireIds Liste des IDs de tenues à combiner
     * @return true si la combinaison est valide, false sinon
     */
    fun validateAttireCombination(attireIds: List<String>): Boolean {
        val attires = attireIds.mapNotNull { getAttireItem(it) }

        // Vérifier qu'il n'y a pas plusieurs items du même type (sauf si compatible)
        val typeGroups = attires.groupBy { it.type }

        for ((type, items) in typeGroups) {
            if (items.size > 1) {
                // Plusieurs items du même type, vérifier qu'ils sont compatibles
                // Par exemple, certains upper peuvent avoir des overlays qui s'empilent
                val hasOverlays = items.any { attire ->
                    (attire.male?.overlays?.isNotEmpty() == true) ||
                    (attire.female?.overlays?.isNotEmpty() == true)
                }

                if (!hasOverlays) {
                    // Pas d'overlays, donc incompatible d'avoir plusieurs items du même type
                    return false
                }
            }
        }

        return true
    }

    /**
     * Récupère toutes les voix pour un genre spécifique
     *
     * @param gender Genre ("male" ou "female")
     * @return Liste des VoiceResource correspondantes
     */
    fun getVoicesByGender(gender: String): List<VoiceResource> {
        return GameDefinition.voicesById.values
            .filter { it.gender.equals(gender, ignoreCase = true) }
    }

    /**
     * Récupère une voix aléatoire pour un genre donné
     *
     * @param gender Genre du personnage
     * @return VoiceResource aléatoire, ou null si aucune voix disponible
     */
    fun getRandomVoice(gender: String): VoiceResource? {
        val voices = getVoicesByGender(gender)
        return voices.randomOrNull()
    }

    /**
     * Récupère toutes les textures de cheveux d'une couleur spécifique
     *
     * @param color Couleur des cheveux
     * @return Liste des HairTextureResource correspondantes
     */
    fun getHairTexturesByColor(color: String): List<HairTextureResource> {
        return GameDefinition.hairTexturesById.values
            .filter { it.color.equals(color, ignoreCase = true) }
    }

    /**
     * Récupère une texture de cheveux aléatoire pour une couleur donnée
     *
     * @param color Couleur des cheveux
     * @param allowRandomOnly Si true, seulement les textures marquées allowRandom
     * @return HairTextureResource aléatoire, ou null si aucune texture disponible
     */
    fun getRandomHairTextureByColor(color: String, allowRandomOnly: Boolean = true): HairTextureResource? {
        val textures = getHairTexturesByColor(color)
            .let { list ->
                if (allowRandomOnly) {
                    list.filter { it.allowRandom }
                } else {
                    list
                }
            }

        return textures.randomOrNull()
    }

    /**
     * Récupère toutes les tenues disponibles pour la génération aléatoire
     *
     * @param type Type de tenue optionnel pour filtrer
     * @return Liste des AttireResource marquées pour génération aléatoire
     */
    fun getRandomizableAttires(type: String? = null): List<AttireResource> {
        val attires = GameDefinition.attireById.values
            .filter { it.allowRandom }

        return if (type != null) {
            attires.filter { it.type == type }
        } else {
            attires
        }
    }

    /**
     * Récupère une tenue aléatoire pour un type et genre donnés
     *
     * @param type Type de tenue
     * @param gender Genre du personnage
     * @param allowRandomOnly Si true, seulement les tenues marquées allowRandom
     * @return AttireResource aléatoire, ou null si aucune tenue disponible
     */
    fun getRandomAttire(
        type: String,
        gender: String,
        allowRandomOnly: Boolean = true
    ): AttireResource? {
        val attires = getAttiresByType(type)
            .filter { attire ->
                val hasGenderData = when (gender.lowercase()) {
                    "male" -> attire.male != null
                    "female" -> attire.female != null
                    else -> true
                }
                hasGenderData && (!allowRandomOnly || attire.allowRandom)
            }

        return attires.randomOrNull()
    }

    /**
     * Récupère tous les types de tenues disponibles
     *
     * @return Liste des types de tenues
     */
    fun getAllAttireTypes(): List<String> {
        return GameDefinition.attireById.values
            .map { it.type }
            .distinct()
    }

    /**
     * Récupère toutes les couleurs de cheveux disponibles
     *
     * @return Liste des couleurs de cheveux
     */
    fun getAllHairColors(): List<String> {
        return GameDefinition.hairTexturesById.values
            .map { it.color }
            .distinct()
    }

    /**
     * Vérifie si une tenue est exclusive à une classe
     *
     * @param attireId ID de la tenue
     * @return true si la tenue est exclusive à une classe, false sinon
     */
    fun isClassOnlyAttire(attireId: String): Boolean {
        val attire = getAttireItem(attireId) ?: return false
        return attire.classOnly
    }

    /**
     * Récupère les enfants d'une tenue (items qui vont avec)
     *
     * @param attireId ID de la tenue parente
     * @return Liste des AttireResource enfants
     */
    fun getAttireChildren(attireId: String): List<AttireResource> {
        val attire = getAttireItem(attireId) ?: return emptyList()
        return attire.children.mapNotNull { childId ->
            getAttireItem(childId)
        }
    }
}
