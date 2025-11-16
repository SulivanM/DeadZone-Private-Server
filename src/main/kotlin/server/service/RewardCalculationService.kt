package server.service

import core.data.GameDefinition
import core.data.resources.ArenaResource
import core.data.resources.RaidResource

/**
 * Service pour calculer les récompenses des arenas et raids basé sur le score
 * Utilise les données de arenas.xml et raids.xml pour déterminer les récompenses appropriées
 */
object RewardCalculationService {

    /**
     * Calcule les récompenses d'une arena basé sur le score obtenu
     *
     * La logique trouve le tier de récompense avec le score le plus élevé
     * qui est inférieur ou égal au score du joueur.
     *
     * Exemple: Si les tiers sont [100, 200, 300] et le score est 250,
     * le tier 200 sera sélectionné.
     *
     * @param arenaId ID de l'arena
     * @param score Score obtenu par le joueur
     * @return Liste des récompenses obtenues, ou null si l'arena n'existe pas
     */
    fun calculateArenaRewards(arenaId: String, score: Int): List<RewardItem>? {
        val arena = GameDefinition.arenasById[arenaId] ?: return null

        // Trouver le tier approprié basé sur le score
        val tier = findArenaRewardTier(arena.rewards, score) ?: return emptyList()

        // Convertir les items du tier en RewardItem
        return tier.items.map { item ->
            RewardItem(
                itemType = item.type,
                quantity = item.quantity
            )
        }
    }

    /**
     * Calcule les récompenses d'un raid basé sur le score obtenu
     *
     * La logique trouve le tier de récompense avec le score le plus élevé
     * qui est inférieur ou égal au score du joueur.
     *
     * @param raidId ID du raid
     * @param score Score obtenu par le joueur
     * @return Liste des récompenses obtenues, ou null si le raid n'existe pas
     */
    fun calculateRaidRewards(raidId: String, score: Int): List<RewardItem>? {
        val raid = GameDefinition.raidsById[raidId] ?: return null

        // Trouver le tier approprié basé sur le score
        val tier = findRaidRewardTier(raid.rewards, score) ?: return emptyList()

        // Convertir les items du tier en RewardItem
        return tier.items.map { item ->
            RewardItem(
                itemType = item.type,
                quantity = item.quantity
            )
        }
    }

    /**
     * Obtient tous les tiers de récompenses disponibles pour une arena
     *
     * @param arenaId ID de l'arena
     * @return Liste des tiers avec leurs scores requis et récompenses
     */
    fun getArenaRewardTiers(arenaId: String): List<RewardTierInfo>? {
        val arena = GameDefinition.arenasById[arenaId] ?: return null

        return arena.rewards.map { tier ->
            RewardTierInfo(
                requiredScore = tier.score,
                rewards = tier.items.map { RewardItem(it.type, it.quantity) }
            )
        }.sortedBy { it.requiredScore }
    }

    /**
     * Obtient tous les tiers de récompenses disponibles pour un raid
     *
     * @param raidId ID du raid
     * @return Liste des tiers avec leurs scores requis et récompenses
     */
    fun getRaidRewardTiers(raidId: String): List<RewardTierInfo>? {
        val raid = GameDefinition.raidsById[raidId] ?: return null

        return raid.rewards.map { tier ->
            RewardTierInfo(
                requiredScore = tier.score,
                rewards = tier.items.map { RewardItem(it.type, it.quantity) }
            )
        }.sortedBy { it.requiredScore }
    }

    /**
     * Calcule le score minimum requis pour le prochain tier de récompenses
     *
     * @param arenaId ID de l'arena
     * @param currentScore Score actuel du joueur
     * @return Score requis pour le prochain tier, ou null si déjà au maximum ou arena inexistante
     */
    fun getNextArenaRewardScore(arenaId: String, currentScore: Int): Int? {
        val arena = GameDefinition.arenasById[arenaId] ?: return null

        return arena.rewards
            .map { it.score }
            .filter { it > currentScore }
            .minOrNull()
    }

    /**
     * Calcule le score minimum requis pour le prochain tier de récompenses d'un raid
     *
     * @param raidId ID du raid
     * @param currentScore Score actuel du joueur
     * @return Score requis pour le prochain tier, ou null si déjà au maximum ou raid inexistant
     */
    fun getNextRaidRewardScore(raidId: String, currentScore: Int): Int? {
        val raid = GameDefinition.raidsById[raidId] ?: return null

        return raid.rewards
            .map { it.score }
            .filter { it > currentScore }
            .minOrNull()
    }

    /**
     * Vérifie si un score permet d'obtenir des récompenses dans une arena
     *
     * @param arenaId ID de l'arena
     * @param score Score à vérifier
     * @return true si le score permet d'obtenir au moins une récompense
     */
    fun hasArenaRewards(arenaId: String, score: Int): Boolean {
        val arena = GameDefinition.arenasById[arenaId] ?: return false
        return arena.rewards.any { it.score <= score }
    }

    /**
     * Vérifie si un score permet d'obtenir des récompenses dans un raid
     *
     * @param raidId ID du raid
     * @param score Score à vérifier
     * @return true si le score permet d'obtenir au moins une récompense
     */
    fun hasRaidRewards(raidId: String, score: Int): Boolean {
        val raid = GameDefinition.raidsById[raidId] ?: return false
        return raid.rewards.any { it.score <= score }
    }

    /**
     * Obtient des informations détaillées sur une arena
     *
     * @param arenaId ID de l'arena
     * @return ArenaInfo avec les détails de l'arena, ou null si inexistante
     */
    fun getArenaInfo(arenaId: String): ArenaInfo? {
        val arena = GameDefinition.arenasById[arenaId] ?: return null

        return ArenaInfo(
            id = arena.id,
            levelMin = arena.levelMin,
            survivorMin = arena.survivorMin,
            survivorMax = arena.survivorMax,
            pointsPerSurvivor = arena.pointsPerSurvivor,
            rewardTiers = arena.rewards.size
        )
    }

    /**
     * Obtient des informations détaillées sur un raid
     *
     * @param raidId ID du raid
     * @return RaidInfo avec les détails du raid, ou null si inexistant
     */
    fun getRaidInfo(raidId: String): RaidInfo? {
        val raid = GameDefinition.raidsById[raidId] ?: return null

        return RaidInfo(
            id = raid.id,
            levelMin = raid.levelMin,
            levelMax = raid.levelMax,
            survivorMin = raid.survivorMin,
            survivorMax = raid.survivorMax,
            raidPointsPerSurvivor = raid.raidPointsPerSurvivor,
            stages = raid.stages.size,
            rewardTiers = raid.rewards.size
        )
    }

    // Fonctions utilitaires privées pour trouver le tier approprié

    /**
     * Trouve le tier de récompense approprié basé sur le score pour les arenas
     * Retourne le tier avec le score le plus élevé qui est <= au score du joueur
     */
    private fun findArenaRewardTier(tiers: List<core.data.resources.ArenaRewardTier>, score: Int): core.data.resources.ArenaRewardTier? {
        return tiers
            .filter { it.score <= score }
            .maxByOrNull { it.score }
    }

    /**
     * Trouve le tier de récompense approprié basé sur le score pour les raids
     * Retourne le tier avec le score le plus élevé qui est <= au score du joueur
     */
    private fun findRaidRewardTier(tiers: List<core.data.resources.RaidRewardTier>, score: Int): core.data.resources.RaidRewardTier? {
        return tiers
            .filter { it.score <= score }
            .maxByOrNull { it.score }
    }
}

/**
 * Représente un item de récompense avec son type et sa quantité
 */
data class RewardItem(
    val itemType: String,
    val quantity: Int
)

/**
 * Informations sur un tier de récompense
 */
data class RewardTierInfo(
    val requiredScore: Int,
    val rewards: List<RewardItem>
)

/**
 * Informations détaillées sur une arena
 */
data class ArenaInfo(
    val id: String,
    val levelMin: Int?,
    val survivorMin: Int?,
    val survivorMax: Int?,
    val pointsPerSurvivor: Int?,
    val rewardTiers: Int
)

/**
 * Informations détaillées sur un raid
 */
data class RaidInfo(
    val id: String,
    val levelMin: Int?,
    val levelMax: Int?,
    val survivorMin: Int?,
    val survivorMax: Int?,
    val raidPointsPerSurvivor: Int?,
    val stages: Int,
    val rewardTiers: Int
)
