package socket.handler.save.command

import context.GlobalContext
import core.items.model.CrateItem
import core.items.model.Item
import core.items.model.SchematicItem
import dev.deadzone.socket.handler.save.SaveHandlerContext
import socket.handler.buildMsg
import socket.handler.save.SaveSubHandler
import socket.messaging.CommandMessage
import socket.protocol.PIOSerializer
import utils.LogConfigSocketToClient
import utils.Logger
import utils.UUID

class CommandSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = CommandMessage.COMMAND_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        when (type) {
            CommandMessage.GIVE -> {
                val type = data["type"] as? String ?: return

                Logger.info(LogConfigSocketToClient) { "Received 'give' command with type=$type | data=$data" }

                when (type) {
                    "schematic" -> {
                        // not tested
                        val schem = data["schem"] as? String ?: return
                        val item = SchematicItem(type = type, schem = schem, new = true)
                        val response = GlobalContext.json.encodeToString(item)
                        send(PIOSerializer.serialize(buildMsg(saveId, response)))
                    }

                    "crate" -> {
                        // not tested
                        val series = data["series"] as? Int ?: return
                        val repeat = (data["repeat"] as? Int) ?: 1
                        repeat(repeat) {
                            val item = CrateItem(type = type, series = series, new = true)
                            val response = GlobalContext.json.encodeToString(item)
                            send(PIOSerializer.serialize(buildMsg(saveId, response)))
                        }
                    }

                    "effect" -> {
                        Logger.warn(LogConfigSocketToClient) { "Received 'give' command of type effect [not implemented]" }
                    }

                    else -> {
                        // not tested with mod
                        val level = data["level"] as? Int ?: return
                        val qty = data["qty"] as? Int ?: 1
                        val mod1 = data["mod1"] as? String?
                        val mod2 = data["mod2"] as? String?
                        val item = Item(
                            id = UUID.new(),
                            type = type,
                            level = level,
                            qty = qty.toUInt(),
                            mod1 = mod1,
                            mod2 = mod2,
                            new = true,
                        )
                        val response = GlobalContext.json.encodeToString(item)
                        send(PIOSerializer.serialize(buildMsg(saveId, response)))
                    }
                }
            }


            CommandMessage.GIVE_RARE -> {
                val type = (data["type"] as String?) ?: return
                val level = (data["level"] as Int?) ?: return

                val item = Item(
                    id = UUID.new(),
                    type = type,
                    level = level,
                    quality = 50,
                    new = true,
                )

                Logger.info(LogConfigSocketToClient) { "Received 'giveRare' command with type=$type | level=$level" }

                val response = GlobalContext.json.encodeToString(item)
                send(PIOSerializer.serialize(buildMsg(saveId, response)))
            }

            CommandMessage.GIVE_UNIQUE -> {
                val type = (data["type"] as String?) ?: return
                val level = (data["level"] as Int?) ?: return

                val item = Item(
                    id = UUID.new(),
                    type = type,
                    level = level,
                    quality = 51,
                    new = true,
                )

                Logger.info(LogConfigSocketToClient) { "Received 'giveUnique' command with type=$type | level=$level" }

                val response = GlobalContext.json.encodeToString(item)
                send(PIOSerializer.serialize(buildMsg(saveId, response)))
            }

            CommandMessage.STORE_CLEAR -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'STORE_CLEAR' message [not implemented]" }
            }

            CommandMessage.STORE_BLOCK -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'STORE_BLOCK' message [not implemented]" }
            }

            CommandMessage.SPAWN_ELITE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SPAWN_ELITE' message [not implemented]" }
            }

            CommandMessage.ELITE_CHANCE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ELITE_CHANCE' message [not implemented]" }
            }

            CommandMessage.ADD_BOUNTY -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ADD_BOUNTY' message [not implemented]" }
            }

            CommandMessage.LEVEL -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'LEVEL' message [not implemented]" }
            }

            CommandMessage.SERVER_TIME -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SERVER_TIME' message [not implemented]" }
            }

            CommandMessage.ZOMBIE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ZOMBIE' message [not implemented]" }
            }

            CommandMessage.TIME -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'TIME' message [not implemented]" }
            }

            CommandMessage.STAT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'STAT' message [not implemented]" }
            }

            CommandMessage.GIVE_AMOUNT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'GIVE_AMOUNT' message [not implemented]" }
            }

            CommandMessage.COUNTER -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'COUNTER' message [not implemented]" }
            }

            CommandMessage.DAILY_QUEST -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'DAILY_QUEST' message [not implemented]" }
            }

            CommandMessage.CHAT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CHAT' message [not implemented]" }
            }

            CommandMessage.LANG -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'LANG' message [not implemented]" }
            }

            CommandMessage.FLAG -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'FLAG' message [not implemented]" }
            }

            CommandMessage.PROMO -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'PROMO' message [not implemented]" }
            }

            CommandMessage.BOUNTY_ADD -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'BOUNTY_ADD' message [not implemented]" }
            }

            CommandMessage.GIVE_INFECTED_BOUNTY -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'GIVE_INFECTED_BOUNTY' message [not implemented]" }
            }

            CommandMessage.BOUNTY_ABANDON -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'BOUNTY_ABANDON' message [not implemented]" }
            }

            CommandMessage.BOUNTY_COMPLETE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'BOUNTY_COMPLETE' message [not implemented]" }
            }

            CommandMessage.BOUNTY_TASK_COMPLETE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'BOUNTY_TASK_COMPLETE' message [not implemented]" }
            }

            CommandMessage.BOUNTY_CONDITION_COMPLETE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'BOUNTY_CONDITION_COMPLETE' message [not implemented]" }
            }

            CommandMessage.BOUNTY_KILL -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'BOUNTY_KILL' message [not implemented]" }
            }

            CommandMessage.SKILL_GIVEXP -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SKILL_GIVEXP' message [not implemented]" }
            }

            CommandMessage.SKILL_LEVEL -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SKILL_LEVEL' message [not implemented]" }
            }
        }
    }
}
