package server.broadcast

/**
 * Represents a broadcast message to be sent to clients
 * Format: "protocol:arg1|arg2|arg3\0"
 */
data class BroadcastMessage(
    val protocol: BroadcastProtocol,
    val arguments: List<String> = emptyList()
) {
    /**
     * Converts the message to the wire format expected by the client
     * Format: "protocol:arg1|arg2|arg3\0"
     */
    fun toWireFormat(): String {
        val body = if (arguments.isNotEmpty()) {
            ":${arguments.joinToString("|")}"
        } else {
            ""
        }
        return "${protocol.code}$body\u0000"
    }

    companion object {
        /**
         * Creates a broadcast message from protocol and vararg arguments
         */
        fun create(protocol: BroadcastProtocol, vararg args: String): BroadcastMessage {
            return BroadcastMessage(protocol, args.toList())
        }

        /**
         * Creates a plain text message
         */
        fun plainText(text: String): BroadcastMessage {
            return BroadcastMessage(BroadcastProtocol.PLAIN_TEXT, listOf(text))
        }

        /**
         * Creates an admin message
         */
        fun admin(text: String): BroadcastMessage {
            return BroadcastMessage(BroadcastProtocol.ADMIN, listOf(text))
        }

        /**
         * Creates a warning message
         */
        fun warning(text: String): BroadcastMessage {
            return BroadcastMessage(BroadcastProtocol.WARNING, listOf(text))
        }
    }
}
