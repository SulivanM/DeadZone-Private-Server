package server.service

import core.data.GameDefinition
import core.data.resources.SurvivorArrivalRequirement
import kotlin.math.min

/**
 * Service pour gérer le recrutement de survivants basé sur survivor.xml
 * Calcule les progrès et valide les conditions de recrutement
 */
object SurvivorRecruitmentService {

    /**
     * Récupère les exigences pour le prochain survivant à recruter
     *
     * @param currentSurvivorCount Nombre actuel de survivants dans le composé
     * @return SurvivorArrivalRequirement pour le prochain survivant, ou null si aucun n'est disponible
     */
    fun getNextSurvivorRequirements(currentSurvivorCount: Int): SurvivorArrivalRequirement? {
        if (currentSurvivorCount < 0 || currentSurvivorCount >= GameDefinition.survivorArrivals.size) {
            return null
        }
        return GameDefinition.survivorArrivals.getOrNull(currentSurvivorCount)
    }

    /**
     * Calcule le progrès de recrutement du prochain survivant
     *
     * @param playerData Snapshot des données actuelles du joueur
     * @return SurvivorRecruitmentProgress avec les détails du progrès pour chaque composant
     */
    fun calculateRecruitmentProgress(playerData: PlayerDataSnapshot): SurvivorRecruitmentProgress {
        val requirements = getNextSurvivorRequirements(playerData.survivorCount)
            ?: return SurvivorRecruitmentProgress(
                foodProgress = 1.0,
                waterProgress = 1.0,
                comfortProgress = 1.0,
                securityProgress = 1.0,
                moraleProgress = 1.0,
                totalProgress = 1.0,
                requirements = SurvivorArrivalRequirement(0, 0, 0, 0, 0, emptyList(), 0),
                canRecruit = false
            )

        // Calculer les jours de ressources restants
        val foodDaysRemaining = if (playerData.dailyFoodConsumption > 0) {
            playerData.totalFood.toDouble() / playerData.dailyFoodConsumption
        } else {
            Double.MAX_VALUE
        }

        val waterDaysRemaining = if (playerData.dailyWaterConsumption > 0) {
            playerData.totalWater.toDouble() / playerData.dailyWaterConsumption
        } else {
            Double.MAX_VALUE
        }

        // Calculer le progrès de chaque composant (cappé entre 0.0 et 1.0)
        val foodProgress = if (requirements.food > 0) {
            min(1.0, foodDaysRemaining / requirements.food)
        } else {
            1.0
        }

        val waterProgress = if (requirements.water > 0) {
            min(1.0, waterDaysRemaining / requirements.water)
        } else {
            1.0
        }

        val comfortProgress = if (requirements.comfort > 0) {
            min(1.0, playerData.currentComfort.toDouble() / requirements.comfort)
        } else {
            1.0
        }

        val securityProgress = if (requirements.security > 0) {
            min(1.0, playerData.currentSecurity.toDouble() / requirements.security)
        } else {
            1.0
        }

        val moraleProgress = if (requirements.morale > 0) {
            min(1.0, playerData.currentMorale.toDouble() / requirements.morale)
        } else {
            1.0
        }

        // Calculer le progrès total (moyenne des 5 composants)
        val totalProgress = (foodProgress + waterProgress + comfortProgress + securityProgress + moraleProgress) / 5.0

        // Vérifier si le recrutement est possible (tous les composants à 100%)
        val canRecruit = foodProgress >= 1.0 &&
                waterProgress >= 1.0 &&
                comfortProgress >= 1.0 &&
                securityProgress >= 1.0 &&
                moraleProgress >= 1.0

        return SurvivorRecruitmentProgress(
            foodProgress = foodProgress,
            waterProgress = waterProgress,
            comfortProgress = comfortProgress,
            securityProgress = securityProgress,
            moraleProgress = moraleProgress,
            totalProgress = totalProgress,
            requirements = requirements,
            canRecruit = canRecruit
        )
    }

    /**
     * Vérifie si le joueur peut recruter un nouveau survivant
     *
     * @param playerData Snapshot des données actuelles du joueur
     * @return true si toutes les conditions sont remplies, false sinon
     */
    fun canRecruitSurvivor(playerData: PlayerDataSnapshot): Boolean {
        val progress = calculateRecruitmentProgress(playerData)
        return progress.canRecruit
    }

    /**
     * Récupère le coût en ressources pour recruter un survivant spécifique
     *
     * @param survivorIndex Index du survivant (0-based)
     * @return Coût du survivant, ou null si l'index est invalide
     */
    fun getSurvivorCost(survivorIndex: Int): Int? {
        return getNextSurvivorRequirements(survivorIndex)?.cost
    }
}

/**
 * Snapshot des données du joueur pour le calcul de recrutement
 */
data class PlayerDataSnapshot(
    val totalFood: Int,
    val totalWater: Int,
    val currentComfort: Int,
    val currentSecurity: Int,
    val currentMorale: Int,
    val survivorCount: Int,
    val dailyFoodConsumption: Int,
    val dailyWaterConsumption: Int
)

/**
 * Résultat du calcul de progrès de recrutement
 */
data class SurvivorRecruitmentProgress(
    val foodProgress: Double,           // 0.0 - 1.0
    val waterProgress: Double,          // 0.0 - 1.0
    val comfortProgress: Double,        // 0.0 - 1.0
    val securityProgress: Double,       // 0.0 - 1.0
    val moraleProgress: Double,         // 0.0 - 1.0
    val totalProgress: Double,          // moyenne des 5 composants
    val requirements: SurvivorArrivalRequirement,
    val canRecruit: Boolean
)
