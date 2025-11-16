package server.service

import core.data.GameDefinition
import core.data.resources.ItemModResource
import core.data.resources.ItemResource

/**
 * Service pour appliquer les modifications d'items basé sur itemmods.xml
 * Applique des multiplicateurs séquentiels aux statistiques des items
 */
object ItemModService {

    /**
     * Applique un modificateur à un item et retourne les statistiques modifiées
     *
     * @param itemId ID de l'item de base
     * @param modId ID du modificateur à appliquer
     * @return ModifiedItemStats contenant les statistiques modifiées, ou null si l'item ou le mod n'existe pas
     */
    fun applyModToItem(itemId: String, modId: String): ModifiedItemStats? {
        val item = GameDefinition.findItem(itemId) ?: return null
        val mod = GameDefinition.itemModsById[modId] ?: return null

        // Vérifier que l'item a des données d'arme
        val weapon = item.weapon ?: return null

        return ModifiedItemStats(
            itemId = itemId,
            modId = modId,
            damage = calculateModifiedStat(weapon.damageMin, weapon.damageMax, mod.damage),
            accuracy = calculateModifiedStatDouble(weapon.accuracy, mod.accuracy),
            range = calculateModifiedStatDoubleToInt(weapon.range, mod.range),
            reloadTime = calculateModifiedStatDouble(weapon.reloadTime, mod.reloadTime),
            capacity = calculateModifiedStat(weapon.capacity, mod.capacity),
            criticalChance = mod.criticalChance,
            criticalDamage = mod.criticalDamage
        )
    }

    /**
     * Calcule les statistiques finales d'un item en appliquant une liste de mods séquentiellement
     *
     * NOTE IMPORTANTE - Divergence avec le client AS3:
     * Cette implémentation utilise un stacking MULTIPLICATIF: final = base × mod1 × mod2 × mod3
     * Le client AS3 utilise un stacking ADDITIF des multiplicateurs:
     * - AS3: final = base × (1 + (mod1-1) + (mod2-1) + (mod3-1))
     * - Exemple AS3: base=100, mods=[1.15, 1.10, 1.05] → 100 * (1 + 0.15 + 0.10 + 0.05) = 130
     * - Cette impl: base=100, mods=[1.15, 1.10, 1.05] → 100 * 1.15 * 1.10 * 1.05 = 132.825
     *
     * TODO: Refactor pour matcher la logique AS3 ItemAttributes.addModValue() (lignes 197-216)
     * et ItemAttributes.getUncappedValueForBase() (lignes 327-362)
     *
     * @param itemId ID de l'item de base
     * @param modIds Liste des IDs de modificateurs à appliquer dans l'ordre
     * @return FinalStats contenant toutes les statistiques finales, ou null si l'item n'existe pas
     */
    fun calculateFinalStats(itemId: String, modIds: List<String>): FinalStats? {
        val item = GameDefinition.findItem(itemId) ?: return null
        val weapon = item.weapon ?: return null

        // Commencer avec les stats de base
        var damageMin = weapon.damageMin ?: 0.0
        var damageMax = weapon.damageMax ?: 0.0
        var accuracy = weapon.accuracy ?: 0.0
        var range = weapon.range ?: 0.0
        var reloadTime = weapon.reloadTime ?: 0.0
        var capacity = weapon.capacity?.toDouble() ?: 0.0
        var criticalChance = 0.0
        var criticalDamage = 0.0

        // Appliquer chaque mod séquentiellement
        for (modId in modIds) {
            val mod = GameDefinition.itemModsById[modId] ?: continue

            // Appliquer les multiplicateurs (les valeurs dans ItemMod sont en pourcentage, ex: 110 = 110%)
            mod.damage?.let {
                damageMin *= (it / 100.0)
                damageMax *= (it / 100.0)
            }
            mod.accuracy?.let { accuracy *= (it / 100.0) }
            mod.range?.let {
                val rangeInt = range.toInt()
                range = (rangeInt * (it / 100.0))
            }
            mod.reloadTime?.let { reloadTime *= (it / 100.0) }
            mod.capacity?.let {
                val capacityInt = capacity.toInt()
                capacity = (capacityInt * (it / 100.0))
            }

            // Les valeurs critiques sont additives plutôt que multiplicatives
            mod.criticalChance?.let { criticalChance += it }
            mod.criticalDamage?.let { criticalDamage += it }
        }

        return FinalStats(
            itemId = itemId,
            appliedMods = modIds,
            damageMin = damageMin,
            damageMax = damageMax,
            accuracy = accuracy,
            range = range.toInt(),
            reloadTime = reloadTime,
            capacity = capacity.toInt(),
            criticalChance = criticalChance,
            criticalDamage = criticalDamage
        )
    }

    /**
     * Obtient la liste de tous les mods disponibles pour un type d'item donné
     *
     * @param itemType Type d'item (ex: "weapon", "gear")
     * @return Liste des ItemModResource correspondant au type
     */
    fun getModsForItemType(itemType: String): List<ItemModResource> {
        return GameDefinition.itemModsById.values.filter { it.type == itemType }
    }

    /**
     * Vérifie si un mod peut être appliqué à un item
     *
     * @param itemId ID de l'item
     * @param modId ID du modificateur
     * @return true si le mod peut être appliqué, false sinon
     */
    fun canApplyMod(itemId: String, modId: String): Boolean {
        val item = GameDefinition.findItem(itemId) ?: return false
        val mod = GameDefinition.itemModsById[modId] ?: return false

        // Un mod de type "weapon" ne peut être appliqué qu'à un item avec des données d'arme
        if (mod.type == "weapon" && item.weapon == null) return false

        return true
    }

    // Fonctions utilitaires privées

    private fun calculateModifiedStat(baseStat: Double?, modValue: Int?): Double? {
        if (baseStat == null || modValue == null) return baseStat
        return baseStat * (modValue / 100.0)
    }

    private fun calculateModifiedStat(baseMin: Double?, baseMax: Double?, modValue: Int?): Pair<Double, Double>? {
        if (baseMin == null || baseMax == null || modValue == null) {
            return if (baseMin != null && baseMax != null) Pair(baseMin, baseMax) else null
        }
        val multiplier = modValue / 100.0
        return Pair(baseMin * multiplier, baseMax * multiplier)
    }

    private fun calculateModifiedStat(baseStat: Int?, modValue: Int?): Int? {
        if (baseStat == null || modValue == null) return baseStat
        return (baseStat * (modValue / 100.0)).toInt()
    }

    private fun calculateModifiedStatDouble(baseStat: Double?, modValue: Double?): Double? {
        if (baseStat == null || modValue == null) return baseStat
        return baseStat * (modValue / 100.0)
    }

    private fun calculateModifiedStatDoubleToInt(baseStat: Double?, modValue: Int?): Int? {
        if (baseStat == null || modValue == null) return baseStat?.toInt()
        return (baseStat * (modValue / 100.0)).toInt()
    }
}

/**
 * Statistiques d'un item après application d'un seul modificateur
 */
data class ModifiedItemStats(
    val itemId: String,
    val modId: String,
    val damage: Pair<Double, Double>?,
    val accuracy: Double?,
    val range: Int?,
    val reloadTime: Double?,
    val capacity: Int?,
    val criticalChance: Double?,
    val criticalDamage: Double?
)

/**
 * Statistiques finales d'un item après application de tous les modificateurs
 */
data class FinalStats(
    val itemId: String,
    val appliedMods: List<String>,
    val damageMin: Double,
    val damageMax: Double,
    val accuracy: Double,
    val range: Int,
    val reloadTime: Double,
    val capacity: Int,
    val criticalChance: Double,
    val criticalDamage: Double
)
