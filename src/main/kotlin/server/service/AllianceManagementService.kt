package server.service

import core.data.GameDefinition
import core.data.resources.AllianceEffectSet
import core.data.resources.AllianceIndividualTier
import core.data.resources.AllianceTaskSet
import kotlin.math.max

/**
 * Service pour gérer les alliances basé sur alliances.xml
 * Gère les effets, tâches, coûts et récompenses d'alliance
 */
object AllianceManagementService {

    /**
     * Calcule le coût d'un effet d'alliance
     * Implémente la logique exacte de AllianceSystem.as getEffectCost() (lignes 612-620)
     *
     * @param memberCount Nombre de membres dans l'alliance
     * @param daysRemaining Jours restants dans la période d'alliance
     * @return Coût total de l'effet
     */
    fun calculateEffectCost(memberCount: Int, daysRemaining: Int): Int {
        val alliance = GameDefinition.alliance ?: return 0
        val config = core.data.GameDefinition.config ?: return 0

        // AS3: Math.max(this._round.memberCount, 2)
        val actualMembers = max(memberCount, 2)

        // AS3: Math.max(this._round.daysRemaining, 1)
        val actualDays = max(daysRemaining, 1)

        // effectCostPerDayMember from XML
        val costPerMember = alliance.effectCostPerDayMember ?: 5.71

        // AS3: var _loc2_:Number = Math.max(memberCount,2) * effectCostPerDayMember * Math.max(daysRemaining,1)
        val cost = actualMembers * costPerMember * actualDays

        // AS3: Math.ceil(_loc2_ / 5) * 5 - Arrondir au multiple de 5 supérieur
        val roundedCost = kotlin.math.ceil(cost / 5.0).toInt() * 5

        // AS3: Math.max(Config.constant.ALLIANCE_EFFECT_MIN_COST, roundedCost)
        val minCost = (config.constants["ALLIANCE_EFFECT_MIN_COST"] as? Number)?.toInt() ?: 20

        return max(minCost, roundedCost)
    }

    /**
     * Récupère tous les sets d'effets disponibles
     *
     * @return Liste des AllianceEffectSet disponibles
     */
    fun getAvailableEffectSets(): List<AllianceEffectSet> {
        val alliance = GameDefinition.alliance ?: return emptyList()
        return alliance.effectSets
    }

    /**
     * Récupère tous les sets de tâches disponibles
     *
     * @return Liste des AllianceTaskSet disponibles
     */
    fun getAvailableTaskSets(): List<AllianceTaskSet> {
        val alliance = GameDefinition.alliance ?: return emptyList()
        return alliance.taskSets
    }

    /**
     * Récupère le tier de récompense individuelle basé sur le score
     *
     * @param score Score du joueur
     * @return AllianceIndividualTier correspondant, ou null si aucun tier n'est atteint
     */
    fun getIndividualRewardTier(score: Int): AllianceIndividualTier? {
        val alliance = GameDefinition.alliance ?: return null

        // Trouver le plus haut tier dont le score requis est <= au score du joueur
        return alliance.individualTiers
            .filter { it.score <= score }
            .maxByOrNull { it.score }
    }

    /**
     * Calcule les récompenses de guerre d'alliance
     *
     * @param allianceMemberCount Nombre de membres dans l'alliance
     * @param warRank Rang de l'alliance dans la guerre (1 = premier, 2 = deuxième, etc.)
     * @return Montant de la récompense, ou null si le rang est invalide
     */
    fun calculateWarRewards(allianceMemberCount: Int, warRank: Int): Int? {
        val alliance = GameDefinition.alliance ?: return null
        val rewards = alliance.rewards ?: return null

        // Vérifier que le rang est valide
        if (warRank < 1 || warRank > rewards.distribution.size) {
            return null
        }

        // La distribution est basée sur le nombre de membres
        // et le rang détermine le pourcentage de la distribution
        val distributionPercentage = rewards.distribution.getOrNull(warRank - 1) ?: return null

        // Calcul basé sur le nombre de membres minimum requis
        val baseReward = rewards.memberCount * 100 // Exemple de calcul
        return (baseReward * distributionPercentage) / 100
    }

    /**
     * Vérifie si un service d'alliance est actif
     *
     * @param serviceId ID du service (ex: "kong|armor")
     * @return true si le service est actif, false sinon
     */
    fun isServiceActive(serviceId: String): Boolean {
        val alliance = GameDefinition.alliance ?: return false

        return alliance.services.any { service ->
            service.id.equals(serviceId, ignoreCase = true) && service.active
        }
    }

    /**
     * Récupère les détails d'un service d'alliance
     *
     * @param serviceId ID du service
     * @return AllianceService correspondant, ou null si non trouvé
     */
    fun getServiceDetails(serviceId: String): core.data.resources.AllianceService? {
        val alliance = GameDefinition.alliance ?: return null

        return alliance.services.find { service ->
            service.id.equals(serviceId, ignoreCase = true)
        }
    }

    /**
     * Récupère tous les tiers de récompenses individuelles
     *
     * @return Liste de tous les tiers disponibles, triés par score
     */
    fun getAllIndividualTiers(): List<AllianceIndividualTier> {
        val alliance = GameDefinition.alliance ?: return emptyList()
        return alliance.individualTiers.sortedBy { it.score }
    }

    /**
     * Calcule le nombre maximum d'effets actifs pour une alliance
     * Basé sur la constante ALLIANCE_EFFECT_BASE_COUNT
     * AS3: Config.constant.ALLIANCE_EFFECT_BASE_COUNT
     *
     * @return Nombre maximum d'effets actifs
     */
    fun getMaxActiveEffects(): Int {
        val config = core.data.GameDefinition.config ?: return 4
        return (config.constants["ALLIANCE_EFFECT_BASE_COUNT"] as? Number)?.toInt() ?: 4
    }

    /**
     * Vérifie si une alliance peut acheter un nouvel effet
     *
     * @param currentEffectsCount Nombre d'effets actuellement actifs
     * @param allianceTokens Jetons disponibles de l'alliance
     * @param memberCount Nombre de membres
     * @param daysRemaining Jours restants
     * @return true si l'achat est possible, false sinon
     */
    fun canPurchaseEffect(
        currentEffectsCount: Int,
        allianceTokens: Int,
        memberCount: Int,
        daysRemaining: Int
    ): Boolean {
        if (currentEffectsCount >= getMaxActiveEffects()) {
            return false
        }

        val cost = calculateEffectCost(memberCount, daysRemaining)
        return allianceTokens >= cost
    }
}
