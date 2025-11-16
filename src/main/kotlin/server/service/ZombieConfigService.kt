package server.service

import core.data.GameDefinition
import core.data.resources.ZombieResource
import core.data.resources.ZombieLimits
import core.data.resources.ZombieVoiceSet

/**
 * Service pour gérer la configuration des zombies basé sur zombie.xml
 * Gère les sons, limites et armes des zombies
 */
object ZombieConfigService {

    /**
     * Récupère les sons d'un zombie pour un genre et type de son donnés
     *
     * @param gender Genre du zombie ("male", "female", "dog")
     * @param soundType Type de son ("idle", "alert", "attack", "hurt", "death")
     * @return Liste des IDs de sons disponibles, ou liste vide si non trouvé
     */
    fun getZombieSounds(gender: String, soundType: String): List<String> {
        val zombieSounds = GameDefinition.zombieSounds ?: return emptyList()

        val voiceSet = when (gender.lowercase()) {
            "male" -> zombieSounds.male
            "female" -> zombieSounds.female
            "dog" -> zombieSounds.dog
            else -> null
        } ?: return emptyList()

        return when (soundType.lowercase()) {
            "idle" -> voiceSet.idle
            "alert" -> voiceSet.alert
            "attack" -> voiceSet.attack
            "hurt" -> voiceSet.hurt
            "death" -> voiceSet.death
            else -> emptyList()
        }
    }

    /**
     * Récupère un son aléatoire pour un zombie
     *
     * @param gender Genre du zombie
     * @param soundType Type de son
     * @return ID d'un son aléatoire, ou null si aucun son disponible
     */
    fun getRandomZombieSound(gender: String, soundType: String): String? {
        val sounds = getZombieSounds(gender, soundType)
        return sounds.randomOrNull()
    }

    /**
     * Récupère les limites de zombies configurées
     *
     * @return ZombieLimits, ou null si non configuré
     */
    fun getZombieLimits(): ZombieLimits? {
        return GameDefinition.zombieLimits
    }

    /**
     * Récupère une arme de zombie par ID
     *
     * @param weaponId ID de l'arme
     * @return ZombieResource correspondante, ou null si non trouvée
     */
    fun getZombieWeapon(weaponId: String): ZombieResource? {
        return GameDefinition.zombieWeaponsById[weaponId]
    }

    /**
     * Récupère toutes les armes de zombies disponibles
     *
     * @return Liste de toutes les ZombieResource
     */
    fun getAllZombieWeapons(): List<ZombieResource> {
        return GameDefinition.zombieWeaponsById.values.toList()
    }

    /**
     * Récupère les armes de zombies par type
     *
     * @param type Type d'arme (ex: "melee", "ranged")
     * @return Liste des ZombieResource correspondantes
     */
    fun getZombieWeaponsByType(type: String): List<ZombieResource> {
        return GameDefinition.zombieWeaponsById.values
            .filter { it.type == type }
    }

    /**
     * Sélectionne une arme aléatoire pour un zombie
     *
     * @param type Type d'arme optionnel pour filtrer
     * @return ZombieResource aléatoire, ou null si aucune arme disponible
     */
    fun getRandomZombieWeapon(type: String? = null): ZombieResource? {
        val weapons = if (type != null) {
            getZombieWeaponsByType(type)
        } else {
            getAllZombieWeapons()
        }
        return weapons.randomOrNull()
    }

    /**
     * Récupère le set de voix complet pour un genre donné
     *
     * @param gender Genre du zombie
     * @return ZombieVoiceSet, ou null si non trouvé
     */
    fun getVoiceSet(gender: String): ZombieVoiceSet? {
        val zombieSounds = GameDefinition.zombieSounds ?: return null

        return when (gender.lowercase()) {
            "male" -> zombieSounds.male
            "female" -> zombieSounds.female
            "dog" -> zombieSounds.dog
            else -> null
        }
    }

    /**
     * Vérifie si des sons sont disponibles pour un genre donné
     *
     * @param gender Genre du zombie
     * @return true si des sons sont disponibles, false sinon
     */
    fun hasSoundsForGender(gender: String): Boolean {
        return getVoiceSet(gender) != null
    }

    /**
     * Récupère la limite de tag pour un niveau donné
     *
     * @param level Niveau du tag
     * @return Tag correspondant, ou null si non trouvé
     */
    fun getTagForLevel(level: Int): String? {
        val zombieLimits = GameDefinition.zombieLimits ?: return null
        return zombieLimits.tags[level]
    }

    /**
     * Récupère tous les niveaux de tags disponibles
     *
     * @return Liste des niveaux de tags
     */
    fun getAllTagLevels(): List<Int> {
        val zombieLimits = GameDefinition.zombieLimits ?: return emptyList()
        return zombieLimits.tags.keys.sorted()
    }

    /**
     * Récupère tous les types de sons disponibles
     *
     * @return Liste des types de sons ("idle", "alert", "attack", "hurt", "death")
     */
    fun getAllSoundTypes(): List<String> {
        return listOf("idle", "alert", "attack", "hurt", "death")
    }

    /**
     * Récupère tous les genres de zombies disponibles
     *
     * @return Liste des genres ("male", "female", "dog")
     */
    fun getAllGenders(): List<String> {
        val zombieSounds = GameDefinition.zombieSounds ?: return emptyList()
        val genders = mutableListOf<String>()

        if (zombieSounds.male != null) genders.add("male")
        if (zombieSounds.female != null) genders.add("female")
        if (zombieSounds.dog != null) genders.add("dog")

        return genders
    }
}
