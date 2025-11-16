package server.service

import core.data.GameDefinition
import core.data.resources.BadWord
import java.util.regex.Pattern

/**
 * Service pour filtrer les mots interdits basé sur badwords.xml
 * Implémente la logique exacte du client AS3 BadWordFilter
 */
object BadWordFilterService {
    private data class BadWordPattern(
        val pattern: Pattern,
        val important: Boolean,
        val length: Int
    )

    private val patterns = mutableListOf<BadWordPattern>()
    private var initialized = false

    /**
     * Initialise le service avec les données de badwords.xml
     * Doit être appelé après le chargement de GameDefinition
     * Implémente createPatternList() du client AS3 (lignes 37-96)
     */
    fun initialize() {
        if (initialized) return

        val badwords = GameDefinition.badwords ?: return
        patterns.clear()

        // Créer un pattern regex pour chaque mot interdit
        for (word in badwords.words) {
            val patternString = buildRegexPattern(word.word, badwords.variations, word.important)
            val pattern = Pattern.compile(patternString, Pattern.CASE_INSENSITIVE)
            patterns.add(BadWordPattern(pattern, word.important, word.word.length))
        }

        initialized = true
    }

    /**
     * Vérifie si un texte contient des mots interdits
     * Implémente filter() du client AS3 avec mode FILTER_TEST
     */
    fun containsBadWord(text: String): Boolean {
        if (!initialized) initialize()
        if (text.isBlank()) return false

        // Vérifier chaque pattern
        for (patternData in patterns) {
            patternData.pattern.matcher(text).apply {
                reset() // Équivalent de lastIndex = 0 dans AS3
                if (find()) {
                    return true
                }
            }
        }

        return false
    }

    /**
     * Filtre un texte en remplaçant les mots interdits par des astérisques
     * Implémente filter() du client AS3 avec mode FILTER_REPLACE
     */
    fun filterText(text: String, replaceChar: String = "*", useLength: Boolean = true): String {
        if (!initialized) initialize()
        if (text.isBlank()) return text

        var filtered = text

        for (patternData in patterns) {
            val replacement = if (useLength) {
                replaceChar.repeat(patternData.length)
            } else {
                replaceChar
            }

            // Logique AS3: si important, remplacer directement
            // Sinon, garder les groupes de capture $1 et $3
            filtered = if (!patternData.important) {
                patternData.pattern.matcher(filtered).replaceAll("\$1$replacement\$3")
            } else {
                patternData.pattern.matcher(filtered).replaceAll(replacement)
            }
        }

        return filtered
    }

    /**
     * Construit un pattern regex pour un mot avec toutes ses variations
     * Implémente la logique exacte du client AS3 BadWordFilter.as (lignes 67-88)
     *
     * Pattern AS3:
     * - Mots importants: (char1)+([\W]*)(char2)+([\W]*)...
     * - Mots normaux: ([^a-z]|^)(char1)+([\W]*)(char2)+([\W]*)...([^a-z]|$)
     * - Avec variations pour chaque caractère
     */
    private fun buildRegexPattern(wordText: String, variations: Map<String, String>, important: Boolean): String {
        val word = wordText.toLowerCase()
        val numChars = word.length
        val pattern = StringBuilder()

        // Début du pattern selon importance
        if (!important) {
            pattern.append("([^a-z]|^)(")
        } else {
            pattern.append("(")
        }

        // Construire le pattern pour chaque caractère
        for (j in 0 until numChars) {
            val char = word.substring(j, j + 1)

            // Cas spécial pour les espaces
            if (char == " ") {
                pattern.append("\\s*")
            } else {
                // Chercher les variations pour ce caractère
                val variation = variations[char]

                if (variation != null && variation.isNotBlank()) {
                    // Construire (?:char|variations)+
                    pattern.append("(?:").append(char).append("|").append(variation).append(")")
                } else {
                    pattern.append(char)
                }
            }

            // Ajouter +[\W]* ou +[\$]* selon si c'est le dernier caractère
            if (j == numChars - 1) {
                pattern.append("+[\\$]*")
            } else {
                pattern.append("+[\\W]*")
            }
        }

        // Fin du pattern selon importance
        if (!important) {
            pattern.append(")([^a-z]|$)")
        } else {
            pattern.append(")")
        }

        return pattern.toString()
    }

    /**
     * Obtient tous les mots interdits importants
     */
    fun getImportantBadWords(): List<BadWord> {
        val badwords = GameDefinition.badwords ?: return emptyList()
        return badwords.words.filter { it.important }
    }

    /**
     * Valide un nom (pour survivant, alliance, véhicule, etc.)
     * Retourne true si le nom est acceptable
     */
    fun validateName(name: String): Boolean {
        if (name.isBlank()) return false
        if (name.length > 50) return false  // Limite raisonnable

        return !containsBadWord(name)
    }
}
