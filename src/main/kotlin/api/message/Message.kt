package api.message

/**
 * Helper class pour créer des messages PIO
 * Un message est essentiellement une liste mutable avec le type en premier élément
 */
class Message(val type: String) {
    private val data = mutableListOf<Any>(type)

    /**
     * Ajoute une valeur directement au message (pour les protocoles séquentiels)
     */
    fun add(value: Any) {
        data.add(value)
    }

    /**
     * Ajoute une propriété au message
     */
    operator fun set(key: String, value: Any?) {
        // Pour PIO, on ajoute la clé puis la valeur
        if (value != null) {
            data.add(key)
            data.add(value)
        }
    }

    /**
     * Convertit le message en liste pour la sérialisation PIO
     */
    fun toList(): List<Any> {
        return data.toList()
    }

    override fun toString(): String {
        return "Message(type=$type, data=$data)"
    }
}
