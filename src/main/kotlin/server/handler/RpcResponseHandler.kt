package server.handler

import context.ServerContext
import server.messaging.HandlerContext
import common.LogConfigSocketToClient
import common.Logger
import server.messaging.NetworkMessage
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler

/**
 * Handle `rpcr` (RPC_RESPONSE) message.
 *
 * AS3 Client sends: ["rpcr", from, to, id, type, success, dataJSON?]
 * Format: [message_type, from (uint), to (uint), id (int), type (String), success (Boolean), data (String, optional JSON)]
 *
 * RPC (Remote Procedure Call) allows server to invoke client functions and receive responses.
 * This handler processes responses from client after server initiated an RPC request.
 *
 * From: Network.as:410, RPCResponse.as:16-42
 */
class RpcResponseHandler(private val serverContext: ServerContext) : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.type == NetworkMessage.RPC_RESPONSE ||
                message.contains(NetworkMessage.RPC_RESPONSE)
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val playerId = connection.playerId
        if (playerId == null) {
            Logger.warn(LogConfigSocketToClient) { "RPC_RESPONSE: No playerId in connection" }
            return
        }

        val from = message.getInt(0)
        val to = message.getInt(1)
        val rpcId = message.getInt(2)
        val rpcType = message.getString(3)
        val success = message.getBoolean(4)
        val dataJson = message.getString(5)

        if (rpcId == null || rpcType == null || success == null) {
            Logger.warn(LogConfigSocketToClient) {
                "RPC_RESPONSE: Invalid message format for playerId=$playerId, raw=${message.getRaw()}"
            }
            return
        }

        Logger.debug(LogConfigSocketToClient) {
            "RPC_RESPONSE: Player $playerId - rpcId=$rpcId, type=$rpcType, success=$success, " +
                    "from=$from, to=$to, hasData=${dataJson != null}"
        }
    }
}
