package server.handler.save.chat

import context.requirePlayerContext
import server.handler.save.SaveHandlerContext
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import common.JSON
import common.LogConfigSocketToClient
import common.Logger

class ChatSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.CHAT_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        when (type) {
            SaveDataMethod.CHAT_SILENCED -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CHAT_SILENCED' message [not implemented]" }
            }

            SaveDataMethod.CHAT_KICKED -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CHAT_KICKED' message [not implemented]" }
            }

            SaveDataMethod.CHAT_GET_CONTACTS_AND_BLOCKS -> {
                handleGetContactsAndBlocks(ctx)
            }

            SaveDataMethod.CHAT_MIGRATE_CONTACTS_AND_BLOCKS -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CHAT_MIGRATE_CONTACTS_AND_BLOCKS' message [not implemented]" }
            }

            SaveDataMethod.CHAT_ADD_CONTACT -> {
                handleAddContact(ctx)
            }

            SaveDataMethod.CHAT_REMOVE_CONTACT -> {
                handleRemoveContact(ctx)
            }

            SaveDataMethod.CHAT_REMOVE_ALL_CONTACTS -> {
                handleRemoveAllContacts(ctx)
            }

            SaveDataMethod.CHAT_ADD_BLOCK -> {
                handleAddBlock(ctx)
            }

            SaveDataMethod.CHAT_REMOVE_BLOCK -> {
                handleRemoveBlock(ctx)
            }

            SaveDataMethod.CHAT_REMOVE_ALL_BLOCKS -> {
                handleRemoveAllBlocks(ctx)
            }
        }
    }

    private suspend fun handleGetContactsAndBlocks(ctx: SaveHandlerContext) = with(ctx) {
        try {
            val playerId = connection.playerId
            val repository = serverContext.requirePlayerContext(playerId).services.playerObjectMetadata.repository

            val contactsResult = repository.getChatContacts(playerId)
            val blocksResult = repository.getChatBlocks(playerId)

            if (contactsResult.isFailure || blocksResult.isFailure) {
                Logger.error(LogConfigSocketToClient) {
                    "CHAT_GET_CONTACTS_AND_BLOCKS: Error retrieving data for playerId=$playerId"
                }
                val responseData = mapOf("success" to false)
                val responseJson = JSON.encode(responseData)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                return
            }

            val contacts = contactsResult.getOrNull() ?: emptyList()
            val blocks = blocksResult.getOrNull() ?: emptyList()

            Logger.info(LogConfigSocketToClient) {
                "CHAT_GET_CONTACTS_AND_BLOCKS: Retrieved ${contacts.size} contacts and ${blocks.size} blocks for playerId=$playerId"
            }

            val responseData = mapOf(
                "contacts" to contacts,
                "blocks" to blocks
            )
            val responseJson = JSON.encode(responseData)
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        } catch (e: Exception) {
            Logger.error(LogConfigSocketToClient) {
                "CHAT_GET_CONTACTS_AND_BLOCKS: Exception: ${e.message}"
            }
            val responseData = mapOf("success" to false)
            val responseJson = JSON.encode(responseData)
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        }
    }

    private suspend fun handleAddContact(ctx: SaveHandlerContext) = with(ctx) {
        try {
            val playerId = connection.playerId
            val nickname = data["nickName"] as? String

            if (nickname == null) {
                Logger.error(LogConfigSocketToClient) {
                    "CHAT_ADD_CONTACT: Missing nickName parameter for playerId=$playerId"
                }
                val responseData = mapOf("success" to false)
                val responseJson = JSON.encode(responseData)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                return
            }

            val repository = serverContext.requirePlayerContext(playerId).services.playerObjectMetadata.repository
            val result = repository.addChatContact(playerId, nickname)

            if (result.isFailure) {
                Logger.error(LogConfigSocketToClient) {
                    "CHAT_ADD_CONTACT: Error adding contact for playerId=$playerId: ${result.exceptionOrNull()?.message}"
                }
                val responseData = mapOf("success" to false)
                val responseJson = JSON.encode(responseData)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                return
            }

            val success = result.getOrNull() ?: false

            Logger.info(LogConfigSocketToClient) {
                "CHAT_ADD_CONTACT: ${if (success) "Successfully added" else "Failed to add (limit reached)"} contact '$nickname' for playerId=$playerId"
            }

            val responseData = mapOf("success" to success)
            val responseJson = JSON.encode(responseData)
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        } catch (e: Exception) {
            Logger.error(LogConfigSocketToClient) {
                "CHAT_ADD_CONTACT: Exception: ${e.message}"
            }
            val responseData = mapOf("success" to false)
            val responseJson = JSON.encode(responseData)
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        }
    }

    private suspend fun handleRemoveContact(ctx: SaveHandlerContext) = with(ctx) {
        try {
            val playerId = connection.playerId
            val nickname = data["nickName"] as? String

            if (nickname == null) {
                Logger.error(LogConfigSocketToClient) {
                    "CHAT_REMOVE_CONTACT: Missing nickName parameter for playerId=$playerId"
                }
                val responseData = mapOf("success" to false)
                val responseJson = JSON.encode(responseData)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                return
            }

            val repository = serverContext.requirePlayerContext(playerId).services.playerObjectMetadata.repository
            val result = repository.removeChatContact(playerId, nickname)

            if (result.isFailure) {
                Logger.error(LogConfigSocketToClient) {
                    "CHAT_REMOVE_CONTACT: Error removing contact for playerId=$playerId: ${result.exceptionOrNull()?.message}"
                }
                val responseData = mapOf("success" to false)
                val responseJson = JSON.encode(responseData)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                return
            }

            Logger.info(LogConfigSocketToClient) {
                "CHAT_REMOVE_CONTACT: Successfully removed contact '$nickname' for playerId=$playerId"
            }

            val responseData = mapOf("success" to true)
            val responseJson = JSON.encode(responseData)
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        } catch (e: Exception) {
            Logger.error(LogConfigSocketToClient) {
                "CHAT_REMOVE_CONTACT: Exception: ${e.message}"
            }
            val responseData = mapOf("success" to false)
            val responseJson = JSON.encode(responseData)
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        }
    }

    private suspend fun handleRemoveAllContacts(ctx: SaveHandlerContext) = with(ctx) {
        try {
            val playerId = connection.playerId
            val repository = serverContext.requirePlayerContext(playerId).services.playerObjectMetadata.repository
            val result = repository.removeAllChatContacts(playerId)

            if (result.isFailure) {
                Logger.error(LogConfigSocketToClient) {
                    "CHAT_REMOVE_ALL_CONTACTS: Error removing all contacts for playerId=$playerId: ${result.exceptionOrNull()?.message}"
                }
                val responseData = mapOf("success" to false)
                val responseJson = JSON.encode(responseData)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                return
            }

            Logger.info(LogConfigSocketToClient) {
                "CHAT_REMOVE_ALL_CONTACTS: Successfully removed all contacts for playerId=$playerId"
            }

            val responseData = mapOf("success" to true)
            val responseJson = JSON.encode(responseData)
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        } catch (e: Exception) {
            Logger.error(LogConfigSocketToClient) {
                "CHAT_REMOVE_ALL_CONTACTS: Exception: ${e.message}"
            }
            val responseData = mapOf("success" to false)
            val responseJson = JSON.encode(responseData)
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        }
    }

    private suspend fun handleAddBlock(ctx: SaveHandlerContext) = with(ctx) {
        try {
            val playerId = connection.playerId
            val nickname = data["nickName"] as? String
            val userId = data["userId"] as? String // Optional, for future use

            if (nickname == null) {
                Logger.error(LogConfigSocketToClient) {
                    "CHAT_ADD_BLOCK: Missing nickName parameter for playerId=$playerId"
                }
                val responseData = mapOf("success" to false)
                val responseJson = JSON.encode(responseData)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                return
            }

            val repository = serverContext.requirePlayerContext(playerId).services.playerObjectMetadata.repository
            val result = repository.addChatBlock(playerId, nickname)

            if (result.isFailure) {
                Logger.error(LogConfigSocketToClient) {
                    "CHAT_ADD_BLOCK: Error adding block for playerId=$playerId: ${result.exceptionOrNull()?.message}"
                }
                val responseData = mapOf("success" to false)
                val responseJson = JSON.encode(responseData)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                return
            }

            val success = result.getOrNull() ?: false

            Logger.info(LogConfigSocketToClient) {
                "CHAT_ADD_BLOCK: ${if (success) "Successfully added" else "Failed to add (limit reached)"} block '$nickname' for playerId=$playerId"
            }

            val responseData = mapOf("success" to success)
            val responseJson = JSON.encode(responseData)
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        } catch (e: Exception) {
            Logger.error(LogConfigSocketToClient) {
                "CHAT_ADD_BLOCK: Exception: ${e.message}"
            }
            val responseData = mapOf("success" to false)
            val responseJson = JSON.encode(responseData)
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        }
    }

    private suspend fun handleRemoveBlock(ctx: SaveHandlerContext) = with(ctx) {
        try {
            val playerId = connection.playerId
            val nickname = data["nickName"] as? String
            val userId = data["userId"] as? String // Optional, for future use

            if (nickname == null) {
                Logger.error(LogConfigSocketToClient) {
                    "CHAT_REMOVE_BLOCK: Missing nickName parameter for playerId=$playerId"
                }
                val responseData = mapOf("success" to false)
                val responseJson = JSON.encode(responseData)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                return
            }

            val repository = serverContext.requirePlayerContext(playerId).services.playerObjectMetadata.repository
            val result = repository.removeChatBlock(playerId, nickname)

            if (result.isFailure) {
                Logger.error(LogConfigSocketToClient) {
                    "CHAT_REMOVE_BLOCK: Error removing block for playerId=$playerId: ${result.exceptionOrNull()?.message}"
                }
                val responseData = mapOf("success" to false)
                val responseJson = JSON.encode(responseData)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                return
            }

            Logger.info(LogConfigSocketToClient) {
                "CHAT_REMOVE_BLOCK: Successfully removed block '$nickname' for playerId=$playerId"
            }

            val responseData = mapOf("success" to true)
            val responseJson = JSON.encode(responseData)
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        } catch (e: Exception) {
            Logger.error(LogConfigSocketToClient) {
                "CHAT_REMOVE_BLOCK: Exception: ${e.message}"
            }
            val responseData = mapOf("success" to false)
            val responseJson = JSON.encode(responseData)
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        }
    }

    private suspend fun handleRemoveAllBlocks(ctx: SaveHandlerContext) = with(ctx) {
        try {
            val playerId = connection.playerId
            val repository = serverContext.requirePlayerContext(playerId).services.playerObjectMetadata.repository
            val result = repository.removeAllChatBlocks(playerId)

            if (result.isFailure) {
                Logger.error(LogConfigSocketToClient) {
                    "CHAT_REMOVE_ALL_BLOCKS: Error removing all blocks for playerId=$playerId: ${result.exceptionOrNull()?.message}"
                }
                val responseData = mapOf("success" to false)
                val responseJson = JSON.encode(responseData)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                return
            }

            Logger.info(LogConfigSocketToClient) {
                "CHAT_REMOVE_ALL_BLOCKS: Successfully removed all blocks for playerId=$playerId"
            }

            val responseData = mapOf("success" to true)
            val responseJson = JSON.encode(responseData)
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        } catch (e: Exception) {
            Logger.error(LogConfigSocketToClient) {
                "CHAT_REMOVE_ALL_BLOCKS: Exception: ${e.message}"
            }
            val responseData = mapOf("success" to false)
            val responseJson = JSON.encode(responseData)
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        }
    }
}
