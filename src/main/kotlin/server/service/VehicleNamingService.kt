package server.service

import core.data.GameDefinition

/**
 * Service pour générer et valider les noms de véhicules basé sur vehiclenames.xml
 * Gère la génération aléatoire de noms et la validation selon les règles du jeu
 */
object VehicleNamingService {

    private const val MAX_NAME_LENGTH = 22
    private val VALID_NAME_REGEX = Regex("^[a-zA-Z0-9 ]+$")

    /**
     * Génère un nom de véhicule aléatoire en combinant un prénom et un nom de famille
     * Implémente la logique exacte de RenameCarDialogue.as generateRandomName() (lignes 92-126)
     *
     * Règles de génération AS3:
     * 1. Si firstName se termine par "%":
     *    - Retirer le "%" du firstName
     *    - Choisir un lastName qui ne commence PAS par "%"
     *    - Pas d'espace entre firstName et lastName
     *
     * 2. Si firstName ne se termine PAS par "%":
     *    - Si lastName commence par "%":
     *      - Retirer le "%" du lastName
     *      - Pas d'espace entre firstName et lastName
     *    - Si lastName ne commence PAS par "%":
     *      - Ajouter un espace entre firstName et lastName
     *
     * Exemples:
     * - "The%" + "Reaper" = "TheReaper"
     * - "Death" + "%Mobile" = "DeathMobile"
     * - "Death" + "Machine" = "Death Machine"
     *
     * @return Un nom de véhicule aléatoire, ou null si les données ne sont pas disponibles
     */
    fun generateRandomName(): String? {
        val vehicleNames = GameDefinition.vehicleNames ?: return null

        if (vehicleNames.firstNames.isEmpty() || vehicleNames.lastNames.isEmpty()) {
            return null
        }

        var firstName = vehicleNames.firstNames.random()
        var lastName: String?
        var noSpace = false

        // AS3 lignes 103-115: Si firstName se termine par "%"
        if (firstName.endsWith("%")) {
            firstName = firstName.substring(0, firstName.length - 1)
            noSpace = false

            // Choisir un lastName qui ne commence PAS par "%"
            lastName = null
            var attempts = 0
            while (lastName == null && attempts < 100) {
                val candidate = vehicleNames.lastNames.random()
                if (!candidate.startsWith("%")) {
                    lastName = candidate
                }
                attempts++
            }

            // Si on n'a pas trouvé de lastName sans "%", prendre n'importe lequel
            if (lastName == null) {
                lastName = vehicleNames.lastNames.random()
            }
        } else {
            // AS3 lignes 116-124: firstName ne se termine pas par "%"
            lastName = vehicleNames.lastNames.random()

            // Si lastName commence par "%", le retirer et ne pas ajouter d'espace
            if (lastName.startsWith("%")) {
                lastName = lastName.substring(1)
                noSpace = true
            }
        }

        // AS3 ligne 125: _loc3_ + (_loc5_ ? "" : " ") + _loc4_
        return if (noSpace) {
            firstName + lastName
        } else {
            "$firstName $lastName"
        }
    }

    /**
     * Génère plusieurs noms de véhicules aléatoires uniques
     *
     * @param count Nombre de noms à générer
     * @return Liste de noms uniques (peut être plus petite que count si pas assez de combinaisons)
     */
    fun generateMultipleNames(count: Int): List<String> {
        val names = mutableSetOf<String>()
        var attempts = 0
        val maxAttempts = count * 10 // Éviter une boucle infinie

        while (names.size < count && attempts < maxAttempts) {
            val name = generateRandomName()
            if (name != null) {
                names.add(name)
            }
            attempts++
        }

        return names.toList()
    }

    /**
     * Valide un nom de véhicule selon les règles du jeu
     *
     * Règles de validation:
     * - Longueur maximale de 22 caractères
     * - Seulement a-zA-Z0-9 et espaces autorisés
     * - Ne doit pas contenir de mots interdits (badwords)
     * - Ne doit pas être vide ou blanc
     *
     * @param name Le nom à valider
     * @return true si le nom est valide, false sinon
     */
    fun validateName(name: String): Boolean {
        // Vérifier que le nom n'est pas vide
        if (name.isBlank()) return false

        // Vérifier la longueur maximale
        if (name.length > MAX_NAME_LENGTH) return false

        // Vérifier les caractères autorisés (a-zA-Z0-9 + espace)
        if (!VALID_NAME_REGEX.matches(name)) return false

        // Vérifier qu'il n'y a pas de mots interdits
        if (BadWordFilterService.containsBadWord(name)) return false

        return true
    }

    /**
     * Nettoie et normalise un nom de véhicule
     *
     * - Supprime les espaces multiples
     * - Trim les espaces de début et fin
     * - Limite à la longueur maximale
     *
     * @param name Le nom à nettoyer
     * @return Le nom nettoyé
     */
    fun sanitizeName(name: String): String {
        var cleaned = name.trim()

        // Remplacer les espaces multiples par un seul espace
        cleaned = cleaned.replace("\\s+".toRegex(), " ")

        // Limiter à la longueur maximale
        if (cleaned.length > MAX_NAME_LENGTH) {
            cleaned = cleaned.substring(0, MAX_NAME_LENGTH)
        }

        return cleaned
    }

    /**
     * Génère un nom de véhicule aléatoire valide
     * Réessaie jusqu'à générer un nom valide ou atteindre le maximum de tentatives
     *
     * @param maxAttempts Nombre maximum de tentatives (défaut: 100)
     * @return Un nom valide, ou null si aucun nom valide n'a pu être généré
     */
    fun generateValidRandomName(maxAttempts: Int = 100): String? {
        repeat(maxAttempts) {
            val name = generateRandomName()
            if (name != null && validateName(name)) {
                return name
            }
        }
        return null
    }

    /**
     * Obtient le nombre total de combinaisons possibles de noms
     *
     * @return Le nombre de combinaisons possibles
     */
    fun getTotalCombinations(): Int {
        val vehicleNames = GameDefinition.vehicleNames ?: return 0
        return vehicleNames.firstNames.size * vehicleNames.lastNames.size
    }

    /**
     * Obtient des statistiques sur les noms de véhicules disponibles
     *
     * @return VehicleNameStats avec les statistiques
     */
    fun getStats(): VehicleNameStats {
        val vehicleNames = GameDefinition.vehicleNames

        if (vehicleNames == null) {
            return VehicleNameStats(0, 0, 0, 0)
        }

        val firstNamesWithPercent = vehicleNames.firstNames.count { it.contains("%") }

        return VehicleNameStats(
            totalFirstNames = vehicleNames.firstNames.size,
            totalLastNames = vehicleNames.lastNames.size,
            totalCombinations = getTotalCombinations(),
            firstNamesWithSpecialRule = firstNamesWithPercent
        )
    }
}

/**
 * Statistiques sur les noms de véhicules disponibles
 */
data class VehicleNameStats(
    val totalFirstNames: Int,
    val totalLastNames: Int,
    val totalCombinations: Int,
    val firstNamesWithSpecialRule: Int
)
