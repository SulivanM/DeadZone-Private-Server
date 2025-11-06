package server.broadcast

data class BroadcastMessage(
    val protocol: BroadcastProtocol,
    val arguments: List<String> = emptyList()
) {
    
    fun toWireFormat(): String {
        val body = if (arguments.isNotEmpty()) {
            ":${arguments.joinToString("|")}"
        } else {
            ""
        }
        return "${protocol.code}$body\u0000"
    }

    companion object {
        
        fun create(protocol: BroadcastProtocol, vararg args: String): BroadcastMessage {
            return BroadcastMessage(protocol, args.toList())
        }

        fun plainText(text: String): BroadcastMessage {
            return BroadcastMessage(BroadcastProtocol.PLAIN_TEXT, listOf(text))
        }

        fun admin(text: String): BroadcastMessage {
            return BroadcastMessage(BroadcastProtocol.ADMIN, listOf(text))
        }

        fun warning(text: String): BroadcastMessage {
            return BroadcastMessage(BroadcastProtocol.WARNING, listOf(text))
        }
    }
}
