package thelaststand.app.network.chat
{
   import flash.system.Capabilities;
   import flash.utils.Dictionary;
   import flash.utils.setTimeout;
   import org.osflash.signals.Signal;
   import playerio.Client;
   import playerio.Connection;
   import playerio.Message;
   import playerio.PlayerIOError;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class ChatRoom
   {
      
      private static const SM_INITIAL_JOIN:String = "initialJoin";
      
      private static const SM_PLAYER_JOINED:String = "playerJoined";
      
      private static const SM_PLAYER_LEFT:String = "playerLeft";
      
      private static const SM_CHAT_MSG:String = "chatMsg";
      
      private static const SM_UNFILTERED_MSG:String = "unfilteredMsg";
      
      private static const SM_FLOOD_BAN:String = "floodBan";
      
      private static const SM_SILENCE:String = "silence";
      
      private static const SM_SEND_COMMAND:String = "sendCommand";
      
      private static const SM_WARNING:String = "warning";
      
      private static const SM_WARNING_PERSONAL:String = "warningPersonal";
      
      private static const SM_LEVEL_UPDATE:String = "levelUpdate";
      
      private static const SM_ALLIANCE_UPDATE:String = "allianceUpdate";
      
      private static const SM_SET_PRIVATE_ONLINE:String = "prvtOnline";
      
      private static const SM_DISCONNECT_USER:String = "disconnectUser";
      
      private static const SM_LOCK:String = "lock";
      
      private static const SM_UNLOCK:String = "unlock";
      
      private static const SM_ADMIN_FEEDBACK_MSG:String = "adminFeedback";
      
      private static const SM_REPORT:String = "report";
      
      private static const SM_INITIAL_BAN_UPDATE:String = "initialBanUpdate";
      
      private static const SM_BAN:String = "ban";
      
      private static const SM_BAN_CONSUME:String = "banConsume";
      
      public var onStatusChange:Signal = new Signal(ChatRoom);
      
      public var onMessageReceived:Signal = new Signal(ChatRoom,ChatMessageData);
      
      public var onFloodBanned:Signal = new Signal(int,String);
      
      public var onInitialBanUpdate:Signal = new Signal(Message,String);
      
      public var onBan:Signal = new Signal(Message,String);
      
      public var onCommandReceived:Signal = new Signal(String,Boolean,String,Array);
      
      internal var nickName:String = "";
      
      private var _status:String = ChatSystem.STATUS_DISCONNECTED;
      
      private var _roomId:String;
      
      public var _client:Client;
      
      private var _channel:String;
      
      private var _connection:Connection;
      
      private var _userData:ChatUserData;
      
      private var _playerData:PlayerData;
      
      private var _playerDict:Dictionary = new Dictionary();
      
      private var _playerList:Vector.<ChatUserData> = new Vector.<ChatUserData>();
      
      public var HasShownStrikeReminder:Boolean = false;
      
      public function ChatRoom(param1:Client, param2:String, param3:ChatUserData)
      {
         super();
         this._client = param1;
         this._channel = param2;
         this._userData = param3;
         AllianceSystem.getInstance().connected.add(this.onAllianceSystemConnected);
         AllianceSystem.getInstance().disconnected.add(this.onAllianceSystemDisconnected);
         this._playerData = Network.getInstance().playerData;
         this._playerData.getPlayerSurvivor().levelIncreased.add(this.onSurvivorLevelUp);
      }
      
      internal function dispose() : void
      {
         if(this._status != ChatSystem.STATUS_DISCONNECTED)
         {
            this.disconnect();
         }
         Network.getInstance().playerData.getPlayerSurvivor().levelIncreased.remove(this.onSurvivorLevelUp);
         AllianceSystem.getInstance().connected.remove(this.onAllianceSystemConnected);
         AllianceSystem.getInstance().disconnected.remove(this.onAllianceSystemDisconnected);
         this._client = null;
         this._roomId = "";
         this._connection = null;
         this._playerData = null;
      }
      
      internal function createJoin(param1:String, param2:String, param3:String, param4:Object = null, param5:Boolean = true) : void
      {
         if(param1 == this._roomId)
         {
            return;
         }
         param4 ||= {};
         param4.NickName = param2;
         if(!param4.hasOwnProperty("AutoClose"))
         {
            param4.AutoClose = false;
         }
         if(this._status != ChatSystem.STATUS_DISCONNECTED)
         {
            this.disconnect();
         }
         this.changeStatus(ChatSystem.STATUS_CONNECTING);
         this._roomId = param1;
         this._client.multiplayer.createJoinRoom(this._roomId,param3,param5,param4,{
            "nickName":this._userData.nickName,
            "level":Network.getInstance().playerData.getPlayerSurvivor().level + 1,
            "allianceId":this._userData.allianceId || "",
            "allianceTag":this._userData.allianceTag || ""
         },this.handleJoinSuccess,this.handleJoinError);
      }
      
      internal function join(param1:String) : void
      {
         var roomId:String = param1;
         if(roomId == this._roomId)
         {
            return;
         }
         if(this._status != ChatSystem.STATUS_DISCONNECTED)
         {
            this.disconnect();
            setTimeout(function():void
            {
               join(roomId);
            },2000);
            return;
         }
         this.changeStatus(ChatSystem.STATUS_CONNECTING);
         this._roomId = roomId;
         this._client.multiplayer.joinRoom(this._roomId,{
            "nickName":this._userData.nickName,
            "level":Network.getInstance().playerData.getPlayerSurvivor().level + 1,
            "allianceId":this._userData.allianceId || "",
            "allianceTag":this._userData.allianceTag || ""
         },this.handleJoinSuccess,this.handleJoinError);
      }
      
      internal function disconnect() : void
      {
         this._roomId = "";
         this.changeStatus(ChatSystem.STATUS_DISCONNECTED);
         if(this._connection)
         {
            this._connection.removeDisconnectHandler(this.handleServerDisconnect);
            this._connection.removeMessageHandler(SM_INITIAL_JOIN,this.onInitialJoin);
            this._connection.removeMessageHandler(SM_PLAYER_JOINED,this.onPlayerJoin);
            this._connection.removeMessageHandler(SM_PLAYER_LEFT,this.onPlayerLeft);
            this._connection.removeMessageHandler(SM_FLOOD_BAN,this.onFloodBan);
            this._connection.removeMessageHandler(SM_LOCK,this.onLockChange);
            this._connection.removeMessageHandler(SM_UNLOCK,this.onLockChange);
            this._connection.removeMessageHandler(SM_INITIAL_BAN_UPDATE,this.handleInitialBanUpdateMessage);
            this._connection.removeMessageHandler(SM_BAN,this.onBanRequest);
            this._connection.removeMessageHandler(SM_CHAT_MSG,this.onIncomingMessage);
            this._connection.removeMessageHandler(SM_SEND_COMMAND,this.onIncomingCommand);
            this._connection.removeMessageHandler(SM_WARNING,this.onIncomingWarning);
            this._connection.removeMessageHandler(SM_WARNING_PERSONAL,this.onIncomingWarning);
            this._connection.removeMessageHandler(SM_LEVEL_UPDATE,this.onChatUserLevelUp);
            this._connection.removeMessageHandler(SM_ALLIANCE_UPDATE,this.onChatUserAllianceupdate);
            this._connection.disconnect();
            this.resetUserLists();
         }
         this._connection = null;
      }
      
      internal function sendMessage(param1:String, param2:String, param3:String, param4:Array = null) : void
      {
         var _loc6_:Object = null;
         if(!this._connection)
         {
            return;
         }
         var _loc5_:Message = this._connection.createMessage(SM_CHAT_MSG,param1,param3,param2);
         if(!param4)
         {
            _loc5_.add(0);
         }
         else
         {
            _loc5_.add(param4.length);
            for each(_loc6_ in param4)
            {
               _loc5_.add(String(_loc6_));
            }
         }
         this._connection.sendMessage(_loc5_);
      }
      
      internal function sendWarning(param1:String) : void
      {
         var _loc2_:Message = this._connection.createMessage(SM_WARNING,param1);
         this._connection.sendMessage(_loc2_);
      }
      
      internal function sendUnfilteredMessage(param1:String, param2:String, param3:String = "", param4:String = "") : void
      {
         if(!this._connection)
         {
            return;
         }
         this._connection.send(SM_UNFILTERED_MSG,param1,param2,param3,param4);
      }
      
      internal function sendAdminFeedback(param1:String) : void
      {
         if(!this._connection)
         {
            return;
         }
         this._connection.send(SM_ADMIN_FEEDBACK_MSG,param1);
      }
      
      internal function sendCommand(param1:String, param2:String, param3:Array = null) : void
      {
         var _loc5_:int = 0;
         if(!this._connection)
         {
            return;
         }
         var _loc4_:Message = this._connection.createMessage(SM_SEND_COMMAND,param2,param1);
         if(param3 != null)
         {
            _loc5_ = 0;
            while(_loc5_ < param3.length)
            {
               _loc4_.add(String(param3[_loc5_]));
               _loc5_++;
            }
         }
         this._connection.sendMessage(_loc4_);
      }
      
      internal function sendReport(param1:String, param2:String, param3:String, param4:String, param5:String) : void
      {
         if(!this._connection)
         {
            return;
         }
         var _loc6_:Message = this._connection.createMessage(SM_REPORT,param1,param2,param3,param4,param5);
         this._connection.sendMessage(_loc6_);
      }
      
      internal function sendBanConsumed() : void
      {
         if(!this._connection)
         {
            return;
         }
         this._connection.send(SM_BAN_CONSUME);
      }
      
      internal function sendAdminCommand(param1:String, param2:String, ... rest) : void
      {
         if(!this._connection)
         {
            return;
         }
         switch(param1)
         {
            case ChatSystem.COMMAND_ADMIN_TRADEBAN:
               this._connection.send(SM_BAN,ChatSystem.BT_TRADEBAN,false,param2,rest[0],rest[1],rest[2]);
               break;
            case ChatSystem.COMMAND_ADMIN_SILENCE:
               this._connection.send(SM_BAN,ChatSystem.BT_SILENCE,false,param2,rest[0],rest[1],rest[2]);
               break;
            case ChatSystem.COMMAND_ADMIN_KICK:
               this._connection.send(SM_BAN,ChatSystem.BT_KICK,false,param2,rest[0],rest[1],rest[2]);
               break;
            case ChatSystem.COMMAND_ADMIN_KICKSILENTLY:
               this._connection.send(SM_BAN,ChatSystem.BT_KICK,true,param2,rest[0],rest[1],rest[2]);
               break;
            case ChatSystem.COMMAND_ADMIN_STRIKE:
               this._connection.send(SM_BAN,ChatSystem.BT_STRIKE,false,param2,rest[0],rest[1],rest[2]);
         }
      }
      
      internal function getUserByNickName(param1:String) : ChatUserData
      {
         return this._playerDict[param1];
      }
      
      internal function setPrivateRoomOnlineStatus(param1:Boolean) : void
      {
         if(!this._connection)
         {
            return;
         }
         this._connection.send(SM_SET_PRIVATE_ONLINE,param1);
      }
      
      internal function disconnectUser(param1:String) : void
      {
         if(!this._connection)
         {
            return;
         }
         this._connection.send(SM_DISCONNECT_USER,param1);
      }
      
      internal function adminLockUnlock(param1:Boolean) : void
      {
         if(!this._connection)
         {
            return;
         }
         this._connection.send(param1 ? SM_LOCK : SM_UNLOCK);
      }
      
      private function handleJoinSuccess(param1:Connection) : void
      {
         this._connection = param1;
         this._connection.addDisconnectHandler(this.handleServerDisconnect);
         this._connection.addMessageHandler(SM_INITIAL_JOIN,this.onInitialJoin);
         this._connection.addMessageHandler(SM_PLAYER_JOINED,this.onPlayerJoin);
         this._connection.addMessageHandler(SM_PLAYER_LEFT,this.onPlayerLeft);
         this._connection.addMessageHandler(SM_FLOOD_BAN,this.onFloodBan);
         this._connection.addMessageHandler(SM_LOCK,this.onLockChange);
         this._connection.addMessageHandler(SM_UNLOCK,this.onLockChange);
         this._connection.addMessageHandler(SM_INITIAL_BAN_UPDATE,this.handleInitialBanUpdateMessage);
         this._connection.addMessageHandler(SM_BAN,this.onBanRequest);
         this._connection.addMessageHandler(SM_CHAT_MSG,this.onIncomingMessage);
         this._connection.addMessageHandler(SM_SEND_COMMAND,this.onIncomingCommand);
         this._connection.addMessageHandler(SM_WARNING,this.onIncomingWarning);
         this._connection.addMessageHandler(SM_WARNING_PERSONAL,this.onIncomingWarning);
         this._connection.addMessageHandler(SM_LEVEL_UPDATE,this.onChatUserLevelUp);
         this._connection.addMessageHandler(SM_ALLIANCE_UPDATE,this.onChatUserAllianceupdate);
      }
      
      private function handleJoinError(param1:PlayerIOError) : void
      {
         this._roomId = "";
         this.changeStatus(ChatSystem.STATUS_DISCONNECTED);
      }
      
      private function handleServerDisconnect() : void
      {
         this.changeStatus(ChatSystem.STATUS_DISCONNECTED);
         this.resetUserLists();
      }
      
      private function onAllianceSystemConnected() : void
      {
      }
      
      private function onAllianceSystemDisconnected() : void
      {
         if(this._status != ChatSystem.STATUS_CONNECTED)
         {
            return;
         }
         if(this._playerData.allianceId == null)
         {
            this._connection.send(SM_ALLIANCE_UPDATE,this._playerData.allianceId || "",this._playerData.allianceTag || "");
         }
      }
      
      private function onInitialJoin(param1:Message) : void
      {
         var pos:uint = 0;
         var len:uint = 0;
         var i:int = 0;
         var ud:ChatUserData = null;
         var m:Message = param1;
         if(this._connection === null)
         {
            return;
         }
         this._connection.send(SM_ALLIANCE_UPDATE,this._playerData.allianceId || "",this._playerData.allianceTag || "");
         try
         {
            pos = 0;
            len = m.getUInt(pos++);
            if(pos < m.length)
            {
               i = 0;
               while(i < len)
               {
                  ud = new ChatUserData();
                  ud.userId = m.getString(pos++);
                  ud.nickName = m.getString(pos++);
                  ud.level = m.getInt(pos++);
                  ud.allianceId = m.getString(pos++);
                  ud.allianceTag = m.getString(pos++);
                  ud.isAdmin = m.getBoolean(pos++);
                  this._playerList.push(ud);
                  this._playerDict[ud.nickName] = ud;
                  if(pos >= m.length)
                  {
                     break;
                  }
                  i++;
               }
            }
            this.changeStatus(ChatSystem.STATUS_CONNECTED);
         }
         catch(error:Error)
         {
            if(Capabilities.isDebugger)
            {
               Network.getInstance().client.errorLog.writeError("ChatRoom.onInitialJoin",error.message,error.getStackTrace(),null);
               throw error;
            }
         }
      }
      
      private function onPlayerJoin(param1:Message) : void
      {
         var _loc3_:ChatUserData = null;
         var _loc5_:ChatMessageData = null;
         var _loc2_:String = param1.getString(1);
         if(this._playerDict[_loc2_] != null)
         {
            _loc3_ = this._playerDict[_loc2_];
         }
         else
         {
            _loc3_ = new ChatUserData();
            this._playerDict[_loc2_] = _loc3_;
            this._playerList.push(_loc3_);
         }
         var _loc4_:int = 0;
         _loc3_.userId = param1.getString(_loc4_++);
         _loc3_.nickName = param1.getString(_loc4_++);
         _loc3_.level = param1.getInt(_loc4_++);
         _loc3_.allianceId = param1.getString(_loc4_++);
         _loc3_.allianceTag = param1.getString(_loc4_++);
         _loc3_.isAdmin = param1.getBoolean(_loc4_++);
         _loc3_.online = true;
         if(this._channel == ChatSystem.CHANNEL_ADMIN && this._userData.isAdmin)
         {
            _loc5_ = new ChatMessageData(this._channel,ChatSystem.MESSAGE_TYPE_SYSTEM);
            _loc5_.posterNickName = ChatSystem.USER_NAME_COMMAND;
            _loc5_.message = _loc3_.nickName + " has joined the room.";
            this.onMessageReceived.dispatch(this,_loc5_);
         }
      }
      
      private function onPlayerLeft(param1:Message) : void
      {
         var _loc6_:ChatMessageData = null;
         var _loc2_:String = param1.getString(0);
         var _loc3_:int = -1;
         var _loc4_:int = 0;
         while(_loc4_ < this._playerList.length)
         {
            if(this._playerList[_loc4_].userId == _loc2_)
            {
               _loc3_ = _loc4_;
               break;
            }
            _loc4_++;
         }
         if(_loc3_ == -1)
         {
            return;
         }
         var _loc5_:ChatUserData = this._playerList[_loc3_];
         _loc5_.online = false;
         if(this._channel == ChatSystem.CHANNEL_ADMIN)
         {
            _loc6_ = new ChatMessageData(this._channel,ChatSystem.MESSAGE_TYPE_SYSTEM);
            _loc6_.posterNickName = ChatSystem.USER_NAME_COMMAND;
            _loc6_.message = _loc5_.nickName + " has left the room.";
            this.onMessageReceived.dispatch(this,_loc6_);
         }
      }
      
      private function resetUserLists() : void
      {
         this._playerDict = new Dictionary();
         this._playerList = new Vector.<ChatUserData>();
      }
      
      private function onIncomingMessage(param1:Message) : void
      {
         var _loc8_:int = 0;
         var _loc2_:String = this._channel;
         var _loc3_:uint = 0;
         var _loc4_:String = param1.getString(_loc3_++);
         var _loc5_:String = param1.getString(_loc3_++);
         switch(_loc5_)
         {
            case ChatSystem.MESSAGE_TYPE_PRIVATE:
            case ChatSystem.MESSAGE_TYPE_ADMIN_PRIVATE:
               _loc2_ = ChatSystem.CHANNEL_PRIVATE;
         }
         var _loc6_:ChatMessageData = new ChatMessageData(_loc2_,_loc5_);
         _loc6_.uniqueId = _loc4_;
         _loc6_.posterId = param1.getString(_loc3_++);
         _loc6_.posterNickName = param1.getString(_loc3_++);
         _loc6_.posterIsAdmin = param1.getBoolean(_loc3_++);
         _loc6_.toNickName = param1.getString(_loc3_++);
         _loc6_.message = param1.getString(_loc3_++);
         if(_loc5_ == ChatSystem.MESSAGE_TYPE_ADMIN_PRIVATE || _loc5_ == ChatSystem.MESSAGE_TYPE_ADMIN_PUBLIC)
         {
            _loc6_.customNickName = param1.getString(_loc3_++);
            _loc6_.customNameColor = param1.getString(_loc3_++);
            _loc6_.customMsgColor = param1.getString(_loc3_++);
         }
         var _loc7_:int = int(param1.getUInt(_loc3_++));
         if(_loc7_ > 0)
         {
            _loc6_.linkData = [];
            _loc8_ = 0;
            while(_loc8_ < _loc7_)
            {
               _loc6_.linkData.push(param1.getString(_loc3_++));
               _loc8_++;
            }
         }
         if(this._playerDict[_loc6_.posterNickName])
         {
            _loc6_.posterAllianceId = this._playerDict[_loc6_.posterNickName].allianceId;
            _loc6_.posterAllianceTag = this._playerDict[_loc6_.posterNickName].allianceTag;
         }
         this.onMessageReceived.dispatch(this,_loc6_);
      }
      
      private function onIncomingWarning(param1:Message) : void
      {
         var _loc2_:ChatMessageData = new ChatMessageData(this.channel,ChatSystem.MESSAGE_TYPE_WARNING);
         _loc2_.posterNickName = param1.type == SM_WARNING_PERSONAL ? ChatSystem.USER_NAME_WARNING_PERSONAL : ChatSystem.USER_NAME_WARNING;
         _loc2_.message = param1.getString(0);
         this.onMessageReceived.dispatch(this,_loc2_);
      }
      
      private function onIncomingCommand(param1:Message) : void
      {
         var _loc7_:String = null;
         var _loc8_:Number = NaN;
         var _loc2_:int = 0;
         var _loc3_:String = param1.getString(_loc2_++);
         var _loc4_:Boolean = param1.getBoolean(_loc2_++);
         var _loc5_:String = param1.getString(_loc2_++);
         var _loc6_:Array = [];
         while(_loc2_ < param1.length)
         {
            _loc7_ = param1.getString(_loc2_++);
            _loc8_ = Number(_loc7_);
            if(_loc7_.length > 0 && !isNaN(_loc8_) && _loc8_ != Number.POSITIVE_INFINITY && _loc8_ != Number.NEGATIVE_INFINITY)
            {
               _loc6_.push(Number(_loc7_));
            }
            else
            {
               _loc6_.push(_loc7_);
            }
         }
         this.onCommandReceived.dispatch(_loc3_,_loc4_,_loc5_,_loc6_);
      }
      
      private function onFloodBan(param1:Message) : void
      {
         this.onFloodBanned.dispatch(param1.getUInt(0),this._channel);
      }
      
      private function onBanRequest(param1:Message) : void
      {
         this.onBan.dispatch(param1,this._channel);
      }
      
      private function handleInitialBanUpdateMessage(param1:Message) : void
      {
         this.onInitialBanUpdate.dispatch(param1,this._channel);
      }
      
      private function onLockChange(param1:Message) : void
      {
         var _loc2_:ChatMessageData = new ChatMessageData(this._channel,ChatSystem.MESSAGE_TYPE_WARNING);
         _loc2_.message = Language.getInstance().getString(param1.type == SM_LOCK ? "chat.locked" : "chat.unlocked");
         this.onMessageReceived.dispatch(this,_loc2_);
      }
      
      private function changeStatus(param1:String) : void
      {
         if(this._status == param1)
         {
            return;
         }
         this._status = param1;
         this.onStatusChange.dispatch(this);
      }
      
      private function onSurvivorLevelUp(param1:Survivor, param2:int) : void
      {
         if(this._status != ChatSystem.STATUS_CONNECTED)
         {
            return;
         }
         this._connection.send(SM_LEVEL_UPDATE,param2);
      }
      
      private function onChatUserLevelUp(param1:Message) : void
      {
         var _loc2_:String = param1.getString(0);
         var _loc3_:ChatUserData = this.getUserByNickName(_loc2_);
         if(_loc3_)
         {
            _loc3_.level = param1.getInt(1);
         }
      }
      
      private function onChatUserAllianceupdate(param1:Message) : void
      {
         var _loc2_:String = param1.getString(0);
         var _loc3_:ChatUserData = this.getUserByNickName(_loc2_);
         if(_loc3_)
         {
            _loc3_.allianceId = param1.getString(1);
            _loc3_.allianceTag = param1.getString(2);
         }
      }
      
      internal function get status() : String
      {
         return this._status;
      }
      
      internal function get channel() : String
      {
         return this._channel;
      }
      
      internal function get roomId() : String
      {
         return this._roomId;
      }
      
      internal function get allUsers() : Vector.<ChatUserData>
      {
         return this._playerList;
      }
      
      internal function get connection() : Connection
      {
         return this._connection;
      }
   }
}

