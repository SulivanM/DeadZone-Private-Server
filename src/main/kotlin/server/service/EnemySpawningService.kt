package server.service

import core.data.GameDefinition
import core.data.resources.HumanEnemyResource
import core.data.resources.HumanEnemyWeapon

/**
 * Service pour gérer la création d'ennemis humains basé sur humanenemies.xml
 * Gère les définitions d'ennemis, leurs armes et équipements
 */
object EnemySpawningService {

    /**
     * Récupère la définition d'un ennemi humain par ID
     *
     * @param enemyId ID de l'ennemi (ex: "raider-01", "bandit-02")
     * @return HumanEnemyResource correspondant, ou null si non trouvé
     */
    fun getHumanEnemyDefinition(enemyId: String): HumanEnemyResource? {
        return GameDefinition.humanEnemiesById[enemyId]
    }

    /**
     * Récupère la définition d'une arme d'ennemi humain par ID
     *
     * @param weaponId ID de l'arme
     * @return HumanEnemyWeapon correspondante, ou null si non trouvée
     */
    fun getHumanEnemyWeapon(weaponId: String): HumanEnemyWeapon? {
        return GameDefinition.humanEnemyWeaponsById[weaponId]
    }

    /**
     * Crée un loadout complet pour un ennemi
     *
     * @param enemyId ID de l'ennemi
     * @return EnemyLoadout avec les détails de l'ennemi et son équipement, ou null si non trouvé
     */
    fun createEnemyLoadout(enemyId: String): EnemyLoadout? {
        val enemy = getHumanEnemyDefinition(enemyId) ?: return null

        // Récupérer les armes disponibles pour cet ennemi
        val weapons = enemy.weapons.mapNotNull { weaponId ->
            getHumanEnemyWeapon(weaponId)
        }

        // Récupérer les équipements disponibles
        val gear = enemy.gear.mapNotNull { gearId ->
            getHumanEnemyWeapon(gearId) // Les gear utilisent aussi la même structure
        }

        return EnemyLoadout(
            enemyId = enemyId,
            type = enemy.type,
            hp = enemy.hp ?: 100,
            scale = enemy.scale ?: 1.0,
            upperAttire = enemy.upper,
            lowerAttire = enemy.lower,
            availableWeapons = weapons,
            availableGear = gear
        )
    }

    /**
     * Sélectionne une arme aléatoire pour un ennemi
     *
     * @param enemyId ID de l'ennemi
     * @return HumanEnemyWeapon aléatoire, ou null si aucune arme disponible
     */
    fun getRandomWeaponForEnemy(enemyId: String): HumanEnemyWeapon? {
        val enemy = getHumanEnemyDefinition(enemyId) ?: return null
        if (enemy.weapons.isEmpty()) return null

        val randomWeaponId = enemy.weapons.random()
        return getHumanEnemyWeapon(randomWeaponId)
    }

    /**
     * Sélectionne un équipement aléatoire pour un ennemi
     *
     * @param enemyId ID de l'ennemi
     * @return HumanEnemyWeapon (gear) aléatoire, ou null si aucun gear disponible
     */
    fun getRandomGearForEnemy(enemyId: String): HumanEnemyWeapon? {
        val enemy = getHumanEnemyDefinition(enemyId) ?: return null
        if (enemy.gear.isEmpty()) return null

        val randomGearId = enemy.gear.random()
        return getHumanEnemyWeapon(randomGearId)
    }

    /**
     * Récupère tous les types d'ennemis disponibles
     *
     * @return Liste de tous les types d'ennemis
     */
    fun getAllEnemyTypes(): List<String> {
        return GameDefinition.humanEnemiesById.values
            .map { it.type }
            .distinct()
    }

    /**
     * Récupère tous les ennemis d'un type spécifique
     *
     * @param type Type d'ennemi (ex: "raider", "bandit")
     * @return Liste des HumanEnemyResource correspondants
     */
    fun getEnemiesByType(type: String): List<HumanEnemyResource> {
        return GameDefinition.humanEnemiesById.values
            .filter { it.type == type }
    }

    /**
     * Sélectionne un ennemi aléatoire d'un type donné
     *
     * @param type Type d'ennemi
     * @return HumanEnemyResource aléatoire, ou null si aucun ennemi de ce type
     */
    fun getRandomEnemyByType(type: String): HumanEnemyResource? {
        val enemies = getEnemiesByType(type)
        return enemies.randomOrNull()
    }

    /**
     * Calcule les dégâts d'une arme d'ennemi
     *
     * @param weapon Arme de l'ennemi
     * @return Dégâts aléatoires entre damageMin et damageMax
     */
    fun calculateWeaponDamage(weapon: HumanEnemyWeapon): Int {
        val minDamage = weapon.damageMin ?: 10
        val maxDamage = weapon.damageMax ?: minDamage

        return (minDamage..maxDamage).random()
    }

    /**
     * Vérifie si une arme est à portée effective
     *
     * @param weapon Arme de l'ennemi
     * @param distance Distance actuelle de la cible
     * @return true si la cible est à portée effective, false sinon
     */
    fun isWeaponInEffectiveRange(weapon: HumanEnemyWeapon, distance: Int): Boolean {
        val minEffective = weapon.rangeMinEffective ?: 0
        val maxRange = weapon.range ?: Int.MAX_VALUE

        return distance in minEffective..maxRange
    }
}

/**
 * Loadout complet d'un ennemi avec toutes ses armes et équipements
 */
data class EnemyLoadout(
    val enemyId: String,
    val type: String,
    val hp: Int,
    val scale: Double,
    val upperAttire: String?,
    val lowerAttire: String?,
    val availableWeapons: List<HumanEnemyWeapon>,
    val availableGear: List<HumanEnemyWeapon>
)
