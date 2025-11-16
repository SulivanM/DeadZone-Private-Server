package thelaststand.app.network.chat
{
   import com.greensock.TweenMax;
   import flash.display.StageDisplayState;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import org.osflash.signals.Signal;
   import playerio.Client;
   import playerio.Connection;
   import playerio.Message;
   import playerio.PlayerIOError;
   import playerio.RoomInfo;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Global;
   import thelaststand.app.core.Settings;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.game.Game;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.BuildingCollection;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.data.alliance.AllianceData;
   import thelaststand.app.game.data.alliance.AllianceMember;
   import thelaststand.app.game.data.alliance.AllianceRank;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.chat.components.IChatMessageDisplayData;
   import thelaststand.app.game.gui.chat.components.UIChatMessageList;
   import thelaststand.app.game.gui.chat.events.ChatLinkEvent;
   import thelaststand.app.game.gui.chat.events.ChatOptionsMenuEvent;
   import thelaststand.app.game.gui.chat.events.ChatUserMenuEvent;
   import thelaststand.app.game.gui.dialogues.ChatCommentReportDialogue;
   import thelaststand.app.game.gui.dialogues.InventoryFullDialogue;
   import thelaststand.app.game.logic.BadWordFilter;
   import thelaststand.app.game.logic.TradeSystem;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PlayerIOConnector;
   import thelaststand.app.network.RPCResponse;
   import thelaststand.app.network.RoomType;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.lang.Language;
   
   public class ChatSystem
   {
      
      public static const STATUS_DISCONNECTED:String = "disconnected";
      
      public static const STATUS_CONNECTING:String = "connecting";
      
      public static const STATUS_CONNECTED:String = "connected";
      
      public static const CHANNEL_ALL:String = "all";
      
      public static const CHANNEL_PUBLIC:String = "public";
      
      public static const CHANNEL_PRIVATE:String = "private";
      
      public static const CHANNEL_TRADE_PUBLIC:String = "tradePublic";
      
      public static const CHANNEL_RECRUITING:String = "recruiting";
      
      public static const CHANNEL_ALLIANCE:String = "alliance";
      
      public static const CHANNEL_ADMIN:String = "admin";
      
      public static const ADMIN_CHANNEL_ALERT:String = "_alert_";
      
      public static const MESSAGE_TYPE_PUBLIC:String = "public";
      
      public static const MESSAGE_TYPE_PRIVATE:String = "private";
      
      public static const MESSAGE_TYPE_SYSTEM:String = "system";
      
      public static const MESSAGE_TYPE_WARNING:String = "warning";
      
      public static const MESSAGE_TYPE_COMMAND:String = "command";
      
      public static const MESSAGE_TYPE_TRADE_REQUEST:String = "tradeRequest";
      
      public static const MESSAGE_TYPE_TRADE_FEEDBACK:String = "tradeFeedback";
      
      public static const MESSAGE_TYPE_ADMIN_PUBLIC:String = "adminPublic";
      
      public static const MESSAGE_TYPE_ADMIN_PRIVATE:String = "adminPrivate";
      
      public static const MESSAGE_TYPE_ALLIANCE_INVITE:String = "allianceInvite";
      
      public static const MESSAGE_TYPE_ALLIANCE_FEEDBACK:String = "allianceFeedback";
      
      public static const BT_NONE:String = "";
      
      public static const BT_SILENCE:String = "silence";
      
      public static const BT_STRIKE:String = "strike";
      
      public static const BT_KICK:String = "kick";
      
      public static const BT_TRADEBAN:String = "tradeBan";
      
      public static const BT_SUSPEND:String = "suspend";
      
      public static const USER_NAME_WARNING:String = "WARNING";
      
      public static const USER_NAME_WARNING_PERSONAL:String = "DIRECT WARNING";
      
      public static const USER_NAME_BAN:String = "BAN";
      
      public static const USER_NAME_COMMAND:String = "COMMAND";
      
      public static const USER_NAME_ERROR:String = "ERROR";
      
      public static const USER_NAME_NOTHING:String = "";
      
      public static const USER_TRADE_IN:String = "tradeIn";
      
      public static const USER_TRADE_OUT:String = "tradeOut";
      
      public static const USER_TRADE_USERLEFT:String = "tradeUserLeft";
      
      public static var SERVICE_PREFIX:String = "";
      
      private static const COMMAND_WHISPER:String = "whisper";
      
      private static const COMMAND_REPLY:String = "reply";
      
      private static const COMMAND_GANG_ONLY:String = "gangOnly";
      
      private static const COMMAND_MUTE:String = "mute";
      
      private static const COMMAND_UNMUTE:String = "unmute";
      
      private static const COMMAND_UNMUTEALL:String = "unmuteAll";
      
      private static const COMMAND_BLOCK:String = "block";
      
      private static const COMMAND_UNBLOCK:String = "unblock";
      
      private static const COMMAND_UNBLOCKALL:String = "unblockAll";
      
      private static const COMMAND_EXIT:String = "exit";
      
      private static const COMMAND_HELP:String = "help";
      
      private static const COMMAND_MUTED:String = "muted";
      
      private static const COMMAND_LISTROOMS:String = "listRooms";
      
      private static const COMMAND_WARNING:String = "warning";
      
      private static const COMMAND_ADD_CONTACT:String = "addContact";
      
      private static const COMMAND_REMOVE_CONTACT:String = "removeContact";
      
      private static const COMMAND_REMOVEALL_CONTACTS:String = "removeAllContacts";
      
      private static const COMMAND_LIST_CONTACTS:String = "listContacts";
      
      private static const COMMAND_TRADE_REQUEST:String = "tradeRequest";
      
      private static const COMMAND_ALLIANCE_INVITE:String = "allianceInvite";
      
      private static const COMMAND_ALLIANCE_FEEDBACK:String = "allianceFeedback";
      
      private static const COMMAND_ADMIN_PAYVAULT:String = "payvault";
      
      private static const COMMAND_ADMIN_JOINROOM:String = "joinRoom";
      
      private static const COMMAND_ADMIN_LISTUSERS:String = "listUsers";
      
      private static const COMMAND_ADMIN_RECAPUSER:String = "recapUser";
      
      internal static const COMMAND_ADMIN_SILENCE:String = "silenced";
      
      internal static const COMMAND_ADMIN_KICK:String = "kicked";
      
      internal static const COMMAND_ADMIN_KICKSILENTLY:String = "kickedSilently";
      
      internal static const COMMAND_ADMIN_TRADEBAN:String = "tradeBan";
      
      internal static const COMMAND_ADMIN_STRIKE:String = "strike";
      
      internal static const COMMAND_ADMIN_SEND_COMMAND:String = "sendCommand";
      
      private static const COMMAND_ADMIN_FIND:String = "find";
      
      private static const COMMAND_ADMIN_CHANGEALLIANCE:String = "changeAlliance";
      
      private static const COMMAND_ADMIN_PULLIN:String = "pull";
      
      private static const COMMAND_ADMIN_PUSHOUT:String = "push";
      
      private static const COMMAND_ADMIN_LOCK:String = "lock";
      
      private static const COMMAND_ADMIN_UNLOCK:String = "unlock";
      
      internal static const COMMAND_ADMIN_TEMP:String = "tempAdminCommand";
      
      internal static const COMMAND_BOUNCED_MSG:String = "bounced";
      
      private static const PUBLIC_ROOM_PREFIX:String = "DeadZone";
      
      private static const PUBLIC_ROOM_NICKNAME:String = "_public_";
      
      private static const TRADE_ROOM_PREFIX:String = "Trade";
      
      private static const TRADE_ROOM_NICKNAME:String = "_tradepublic_";
      
      private static const RECRUITING_ROOM_PREFIX:String = "Recruiting";
      
      private static const RECRUITING_ROOM_NICKNAME:String = "_recruiting_";
      
      private static const GROUP_ROOM_PREFIX:String = "group_";
      
      private static const MISSING_USER_NICKNAME:String = "@missing nickName@";
      
      private static const INDEFINITE_BAN_TIME:int = 263520;
      
      public var onChatStatusChange:Signal = new Signal(String,String);
      
      public var onChatMessageReceived:Signal = new Signal(ChatMessageData);
      
      public var onCommandReceived:Signal = new Signal(String,String,Array);
      
      public var onAllowedChannelsChange:Signal = new Signal();
      
      public var onTargetUserNotOnline:Signal = new Signal(String);
      
      public var onTradeRequestCreated:Signal = new Signal(String);
      
      private var _game:Game;
      
      private var _client:Client;
      
      private var _userData:ChatUserData;
      
      private var _roomPublic:ChatRoom;
      
      private var _roomTradePublic:ChatRoom;
      
      private var _roomPrivate:ChatRoom;
      
      private var _roomAlliance:ChatRoom;
      
      private var _roomRecruiting:ChatRoom;
      
      private var _roomAdmin:ChatRoom;
      
      private var _genericPublicChatRoomsByChannel:Dictionary = new Dictionary();
      
      private var _genericPublicChatRoomsList:Array = [];
      
      private var _privateChatRoomList:Vector.<ChatRoom> = new Vector.<ChatRoom>();
      
      private var _queuedDirectMsgs:Dictionary = new Dictionary();
      
      private var _lastPrivateMsgSender:String = "";
      
      private var _floodBanned:uint = 0;
      
      private var _blocklist:Array = [];
      
      private var _mutedlist:Array = [];
      
      private var _contactlist:Array = [];
      
      private var _allowedChannels:Dictionary;
      
      private var _buildings:BuildingCollection;
      
      private var _channelBuildRequirements:Dictionary;
      
      private var _playerData:PlayerData;
      
      private var _allianceSystem:AllianceSystem;
      
      private var _lang:Language = Language.getInstance();
      
      private var _lastAllianceInviteTimestamp:int = 0;
      
      private var _origNickname:String;
      
      private var _nicknameCheckCounter:int;
      
      private var _nicknameSearchInProgress:Boolean = false;
      
      private var _nicknameValidated:Boolean = false;
      
      private var _banType:String = "";
      
      private var _banExpiration:Number;
      
      private var _banReason:String = "";
      
      private var _lastBanStrikeNum:int = -1;
      
      public var ReminderStrikeNum:int = 0;
      
      public var badwords:BadWordFilter;
      
      private var roomLookupResults:Dictionary = new Dictionary();
      
      private var roomLookupId:uint = 0;
      
      public function ChatSystem(param1:Client)
      {
         super();
         this._client = param1;
         this.badwords = new BadWordFilter();
         Global.stage.addEventListener(ChatLinkEvent.LINK_CLICK,this.onChatLinkClick);
         Global.stage.addEventListener(ChatUserMenuEvent.MENU_ITEM_CLICK,this.onChatUserMenuClick);
         Global.stage.addEventListener(ChatOptionsMenuEvent.MENU_ITEM_CLICK,this.onChatOptionsMenuClick);
      }
      
      public function init(param1:Game, param2:String, param3:String) : void
      {
         if(!param2)
         {
            param2 = "RADIO_CALLSIGN";
         }
         this._origNickname = param2.replace(/ /ig,"_");
         this._allianceSystem = AllianceSystem.getInstance();
         this._allianceSystem.connected.add(this.onAllianceSystemConnected);
         this._allianceSystem.disconnected.add(this.onAllianceSystemDisconnected);
         this._playerData = Network.getInstance().playerData;
         this._game = param1;
         this._userData = new ChatUserData();
         this._userData.nickName = param2;
         this._userData.userId = param3;
         this._userData.allianceId = this._playerData.allianceId;
         this._userData.allianceTag = this._playerData.allianceTag;
         this._userData.isAdmin = this._playerData.isAdmin;
         TradeSystem.getInstance().init(param1);
         this.collectContactAndBlockLists();
         switch(Network.getInstance().service)
         {
            case PlayerIOConnector.SERVICE_FACEBOOK:
            case PlayerIOConnector.SERVICE_ARMOR_GAMES:
            case PlayerIOConnector.SERVICE_PLAYER_IO:
               SERVICE_PREFIX = "";
               break;
            case PlayerIOConnector.SERVICE_KONGREGATE:
               SERVICE_PREFIX = "kong";
               break;
            case PlayerIOConnector.SERVICE_YAHOO:
               SERVICE_PREFIX = "yahoo";
               break;
            default:
               SERVICE_PREFIX = Network.getInstance().service;
         }
         this._roomPublic = this.generateChatRoomObject(CHANNEL_PUBLIC);
         this._roomTradePublic = this.generateChatRoomObject(CHANNEL_TRADE_PUBLIC);
         this._roomPrivate = this.generateChatRoomObject(CHANNEL_PRIVATE);
         this._roomAlliance = this.generateChatRoomObject(CHANNEL_ALLIANCE);
         this._roomAdmin = this.generateChatRoomObject(CHANNEL_ADMIN);
         this._roomRecruiting = this.generateChatRoomObject(CHANNEL_RECRUITING);
         this._allowedChannels = new Dictionary();
         this._allowedChannels[CHANNEL_PUBLIC] = false;
         this._allowedChannels[CHANNEL_TRADE_PUBLIC] = false;
         this._allowedChannels[CHANNEL_PRIVATE] = false;
         this._allowedChannels[CHANNEL_RECRUITING] = false;
         this._allowedChannels[CHANNEL_ADMIN] = this._playerData.isAdmin;
         this._buildings = this._playerData.compound.buildings;
         this._buildings.buildingAdded.add(this.onBuildingStateChange);
         this._buildings.buildingRemoved.add(this.onBuildingStateChange);
         this._playerData.getPlayerSurvivor().levelIncreased.add(this.onLevelUp);
         this._channelBuildRequirements = new Dictionary();
         this._channelBuildRequirements[CHANNEL_PUBLIC] = [{
            "building":"comm-radio-receiver",
            "level":0
         },{
            "building":"comm-radio-tower",
            "level":0
         }];
         this._channelBuildRequirements[CHANNEL_TRADE_PUBLIC] = [{
            "building":"comm-radio-receiver",
            "level":0
         },{
            "building":"comm-radio-tower",
            "level":0
         }];
         this._channelBuildRequirements[CHANNEL_RECRUITING] = [{
            "building":"playerLevel",
            "level":int(Config.xml.ALLIANCE_MIN_JOIN_LEVEL)
         },{
            "building":"comm-radio-receiver",
            "level":0
         },{
            "building":"comm-radio-tower",
            "level":0
         }];
         this._channelBuildRequirements[CHANNEL_PRIVATE] = [{
            "building":"comm-radio-receiver",
            "level":0
         },{
            "building":"comm-radio-tower",
            "level":0
         },{
            "building":"comm-two-way",
            "level":0
         }];
         this._channelBuildRequirements[CHANNEL_ALLIANCE] = [{
            "building":"comm-radio-receiver",
            "level":0
         },{
            "building":"comm-radio-tower",
            "level":0
         }];
         this.checkBuildingRequirements();
      }
      
      private function checkPrivateConnection() : void
      {
         var _loc2_:String = null;
         var _loc1_:Boolean = false;
         for(_loc2_ in this._allowedChannels)
         {
            if(this._allowedChannels[_loc2_] == true)
            {
               _loc1_ = true;
               break;
            }
         }
         if(_loc1_ == false)
         {
            this._roomPrivate.disconnect();
            this._nicknameValidated = false;
         }
      }
      
      private function performNickNameCheck(param1:Function = null) : void
      {
         var callback:Function = param1;
         if(this._nicknameSearchInProgress || this._roomPrivate.status == STATUS_CONNECTED)
         {
            return;
         }
         this._nicknameSearchInProgress = true;
         this._userData.nickName = this._origNickname;
         if(this._nicknameCheckCounter > 1)
         {
            this._userData.nickName = this._userData.nickName + "(" + this._nicknameCheckCounter + ")";
         }
         this._client.multiplayer.listRooms(RoomType.CHAT,{"NickName":SERVICE_PREFIX + this._userData.nickName},1,0,function(param1:Array):void
         {
            onNickNameCheckComplete(param1,callback);
         },function(param1:PlayerIOError):void
         {
            onNickNameCheckComplete(null,callback);
         });
      }
      
      private function onNickNameCheckComplete(param1:Array, param2:Function = null) : void
      {
         this._nicknameSearchInProgress = false;
         if(param1 == null || param1.length == 0)
         {
            this._roomPrivate.createJoin(this._userData.userId,SERVICE_PREFIX + this._userData.nickName,RoomType.CHAT,{"AutoClose":true},true);
            this._nicknameValidated = true;
            if(param2 != null)
            {
               param2();
            }
            return;
         }
         var _loc3_:RoomInfo = param1[0];
         if(_loc3_.id == this._userData.userId)
         {
            this._roomPrivate.createJoin(this._userData.userId,SERVICE_PREFIX + this._userData.nickName,RoomType.CHAT,{"AutoClose":true},true);
            this._nicknameValidated = true;
            if(param2 != null)
            {
               param2();
            }
         }
         else
         {
            ++this._nicknameCheckCounter;
            this.performNickNameCheck(param2);
         }
      }
      
      public function get userData() : ChatUserData
      {
         return this._userData;
      }
      
      public function isConnected(param1:String) : Boolean
      {
         if(param1 == ADMIN_CHANNEL_ALERT)
         {
            return true;
         }
         var _loc2_:ChatRoom = this.getChatRoomByChannel(param1);
         return _loc2_ ? _loc2_.status == STATUS_CONNECTED : false;
      }
      
      public function getStatus(param1:String) : String
      {
         var _loc2_:ChatRoom = this.getChatRoomByChannel(param1);
         return _loc2_ ? _loc2_.status : STATUS_DISCONNECTED;
      }
      
      public function getConnection(param1:String) : Connection
      {
         var _loc2_:ChatRoom = this.getChatRoomByChannel(param1);
         if(_loc2_ == null)
         {
            return null;
         }
         return _loc2_.connection;
      }
      
      public function connect(param1:String, param2:String = "ChatRoom-14", param3:Object = null) : void
      {
         var room:ChatRoom;
         var channel:String = param1;
         var customRoomType:String = param2;
         var customRoomData:Object = param3;
         if(this._nicknameValidated == false)
         {
            this.performNickNameCheck(function():void
            {
               connect(channel,customRoomType,customRoomData);
            });
            return;
         }
         room = this.getChatRoomByChannel(channel);
         if(Boolean(room) && room.status != STATUS_DISCONNECTED)
         {
            return;
         }
         switch(channel)
         {
            case CHANNEL_TRADE_PUBLIC:
            case CHANNEL_PUBLIC:
            case CHANNEL_RECRUITING:
               this._client.multiplayer.listRooms(RoomType.CHAT,{"NickName":this.getBalancedRoomNickname(channel)},1000,0,function(param1:Array):void
               {
                  onBalancedRoomListSuccess(channel,param1);
               },function(param1:PlayerIOError):void
               {
                  onBalancedRoomListSuccess(channel,[]);
               });
               break;
            case CHANNEL_ADMIN:
               this._roomAdmin.createJoin(SERVICE_PREFIX + "admin","admin",RoomType.CHAT,{"AutoClose":false},false);
               break;
            case CHANNEL_PRIVATE:
               break;
            case CHANNEL_ALLIANCE:
               if(this._allianceSystem.inAlliance)
               {
                  this._roomAlliance.createJoin(SERVICE_PREFIX + this._playerData.allianceId,SERVICE_PREFIX + this._playerData.allianceId,RoomType.CHAT,{"AutoClose":false},true);
               }
               break;
            case CHANNEL_ALL:
               throw new Error("Cannot connect to the \'all\' channel. It is used for faking signals to all chat windows");
            default:
               if(room == null)
               {
                  room = this.generateChatRoomObject(channel);
                  this._genericPublicChatRoomsByChannel[channel] = room;
                  this._genericPublicChatRoomsList.push(room);
               }
               if(customRoomData == null)
               {
                  customRoomData = {};
               }
               customRoomData.AutoClose = false;
               room.createJoin(SERVICE_PREFIX + channel,SERVICE_PREFIX + channel,customRoomType,customRoomData,false);
         }
      }
      
      public function disconnectAll() : void
      {
         var _loc1_:ChatRoom = null;
         for each(_loc1_ in this._genericPublicChatRoomsList)
         {
            this.disconnect(_loc1_.channel);
         }
         if(this._roomAlliance != null)
         {
            this.disconnect(this._roomAlliance.channel);
         }
         if(this._roomPublic != null)
         {
            this.disconnect(this._roomPublic.channel);
         }
         if(this._roomTradePublic != null)
         {
            this.disconnect(this._roomTradePublic.channel);
         }
         if(this._roomAdmin != null)
         {
            this.disconnect(this._roomAdmin.channel);
         }
         if(this._roomRecruiting != null)
         {
            this.disconnect(this._roomRecruiting.channel);
         }
         if(this._roomPrivate != null)
         {
            this._nicknameValidated = false;
            this.disconnect(this._roomPrivate.channel);
         }
         this.disconnectFromAllPrivateRooms();
      }
      
      public function disconnect(param1:String) : void
      {
         var _loc2_:ChatRoom = this.getChatRoomByChannel(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(this._genericPublicChatRoomsByChannel[param1])
         {
            this.disposeChatRoomObject(_loc2_);
         }
         if(param1 != CHANNEL_PRIVATE)
         {
            _loc2_.disconnect();
         }
      }
      
      private function disconnectFromAllPrivateRooms() : void
      {
         while(this._privateChatRoomList.length > 0)
         {
            this.disposeChatRoomObject(this._privateChatRoomList.pop());
         }
      }
      
      public function isChannelAllowed(param1:String) : Boolean
      {
         if(this._allowedChannels[param1] === false)
         {
            return false;
         }
         return true;
      }
      
      public function sendMessage(param1:String, param2:Array = null, param3:String = "") : void
      {
         var _loc4_:ChatMessageData = null;
         var _loc5_:ParsedMessageData = null;
         var _loc6_:Number = NaN;
         var _loc7_:Array = null;
         var _loc8_:ChatRoom = null;
         var _loc9_:ChatRoom = null;
         if(this.testKickedBan(true,param3) || this.testSilencedBan(true,param3))
         {
            return;
         }
         if(param3 == CHANNEL_TRADE_PUBLIC && this.testTradeBan(true,CHANNEL_TRADE_PUBLIC))
         {
            return;
         }
         if(this._floodBanned > getTimer())
         {
            _loc6_ = Math.ceil((this._floodBanned - getTimer()) / (60 * 1000));
            _loc4_ = new ChatMessageData(param3,MESSAGE_TYPE_SYSTEM);
            _loc4_.posterNickName = USER_NAME_BAN;
            _loc4_.toNickName = this._userData.nickName;
            _loc4_.message = this._lang.getString("chat.flooding_ban_minutes",_loc6_);
            this.onChatMessageReceived.dispatch(_loc4_);
            return;
         }
         _loc5_ = this.parseMessageString(param1);
         if(_loc5_ == null)
         {
            return;
         }
         _loc5_.message = _loc5_.message.replace(/(.)\1{5,}/ig,"$1$1$1$1$1");
         _loc5_.linkData = param2;
         if(_loc5_.command != "")
         {
            switch(_loc5_.command)
            {
               case COMMAND_REPLY:
                  if(_loc5_.nickName == "" || _loc5_.nickName == MISSING_USER_NICKNAME)
                  {
                     _loc4_ = new ChatMessageData(param3,MESSAGE_TYPE_SYSTEM);
                     _loc4_.posterNickName = USER_NAME_ERROR;
                     _loc4_.toNickName = this._userData.nickName;
                     _loc4_.message = this._lang.getString("chat.unknown_reply_user");
                     this.onChatMessageReceived.dispatch(_loc4_);
                     break;
                  }
                  this.sendPrivateMessage(_loc5_,param3);
                  break;
               case COMMAND_WHISPER:
                  this.sendPrivateMessage(_loc5_,param3);
                  break;
               case COMMAND_EXIT:
                  this.disconnect(param3);
                  break;
               case COMMAND_MUTE:
                  if(_loc5_.nickName == "" || _loc5_.nickName == MISSING_USER_NICKNAME)
                  {
                     break;
                  }
                  this.addToMuteList(_loc5_.nickName,param3);
                  break;
               case COMMAND_UNMUTE:
                  if(_loc5_.nickName == "" || _loc5_.nickName == MISSING_USER_NICKNAME)
                  {
                     break;
                  }
                  this.removeFromMuteList(_loc5_.nickName,param3);
                  break;
               case COMMAND_UNMUTEALL:
                  this.removeAllFromMuteList(param3);
                  break;
               case COMMAND_BLOCK:
                  if(_loc5_.nickName == "" || _loc5_.nickName == MISSING_USER_NICKNAME)
                  {
                     break;
                  }
                  this.addToBlockList(_loc5_.nickName,param3);
                  break;
               case COMMAND_UNBLOCK:
                  if(_loc5_.nickName == "" || _loc5_.nickName == MISSING_USER_NICKNAME)
                  {
                     break;
                  }
                  this.removeFromBlockList(_loc5_.nickName,param3);
                  break;
               case COMMAND_UNBLOCKALL:
                  this.removeAllFromBlockList(param3);
                  break;
               case COMMAND_MUTED:
                  this.listBlockedAndMutedUsers(param3);
                  break;
               case COMMAND_ADD_CONTACT:
                  if(_loc5_.nickName == "" || _loc5_.nickName == MISSING_USER_NICKNAME)
                  {
                     break;
                  }
                  this.addToContactList(_loc5_.nickName,param3);
                  break;
               case COMMAND_REMOVE_CONTACT:
                  if(_loc5_.nickName == "" || _loc5_.nickName == MISSING_USER_NICKNAME)
                  {
                     break;
                  }
                  this.removeFromContactList(_loc5_.nickName,param3);
                  break;
               case COMMAND_REMOVEALL_CONTACTS:
                  this.removeAllContacts(param3);
                  break;
               case COMMAND_LIST_CONTACTS:
                  this.listContacts(param3);
                  break;
               case COMMAND_TRADE_REQUEST:
                  this.catchTradeRequest(_loc5_.nickName,param3);
                  break;
               case COMMAND_ALLIANCE_INVITE:
                  if(_loc5_.nickName != MISSING_USER_NICKNAME)
                  {
                     this.sendAllianceInvitation(_loc5_.nickName,param3);
                  }
                  break;
               case COMMAND_HELP:
                  this.showHelp(param3);
                  break;
               case COMMAND_LISTROOMS:
                  this.displayRoomList(param3);
            }
            if(this._playerData.isAdmin == true)
            {
               switch(_loc5_.command)
               {
                  case COMMAND_ADMIN_PAYVAULT:
                     this.adminDisplayPayvaultLink(_loc5_.nickName,param3);
                     break;
                  case COMMAND_ADMIN_JOINROOM:
                     this.joinParticularRoom(param3,_loc5_.nickName);
                     break;
                  case COMMAND_ADMIN_LISTUSERS:
                     this.adminListUsers(param3);
                     break;
                  case COMMAND_ADMIN_RECAPUSER:
                     this.adminRecapUser(param3,_loc5_.nickName);
                     break;
                  case COMMAND_ADMIN_SILENCE:
                  case COMMAND_ADMIN_KICKSILENTLY:
                  case COMMAND_ADMIN_KICK:
                  case COMMAND_ADMIN_TRADEBAN:
                  case COMMAND_ADMIN_STRIKE:
                     this.doKickSilence(_loc5_.nickName,_loc5_.message,param3,_loc5_.command);
                     break;
                  case COMMAND_ADMIN_FIND:
                     _loc4_ = new ChatMessageData(param3,MESSAGE_TYPE_SYSTEM);
                     _loc4_.posterNickName = USER_NAME_COMMAND;
                     _loc4_.toNickName = this._userData.nickName;
                     _loc4_.message = "Performing search for " + _loc5_.nickName;
                     this.onChatMessageReceived.dispatch(_loc4_);
                     this.sendDirectCommand(_loc5_.nickName,"_findUser",param3);
                     break;
                  case COMMAND_ADMIN_SEND_COMMAND:
                     _loc7_ = ([_loc5_.nickName] as Array).concat(_loc5_.message.split(" "));
                     this.sendDirectCommand.apply(null,_loc7_);
                     break;
                  case COMMAND_ADMIN_CHANGEALLIANCE:
                     this.adminChangeAlliance(_loc5_.message);
                     break;
                  case COMMAND_ADMIN_PULLIN:
                     this.adminPushPull(param3,_loc5_.nickName,true);
                     break;
                  case COMMAND_ADMIN_PUSHOUT:
                     this.adminPushPull(param3,_loc5_.nickName,false);
                     break;
                  case COMMAND_ADMIN_LOCK:
                     this.adminLockUnlock(param3,true);
                     break;
                  case COMMAND_ADMIN_UNLOCK:
                     this.adminLockUnlock(param3,false);
                     break;
                  case COMMAND_ADMIN_TEMP:
                     break;
                  case COMMAND_WARNING:
                     _loc8_ = this.getChatRoomByChannel(param3);
                     if(!_loc8_)
                     {
                        throw new Error("Tried sending warning to unspecified chat channel : " + param3);
                     }
                     _loc8_.sendWarning(_loc5_.message);
               }
            }
         }
         else
         {
            _loc9_ = this.getChatRoomByChannel(param3);
            if(!_loc9_)
            {
               throw new Error("Tried sending message to unspecified chat channel : " + param3);
            }
            _loc9_.sendMessage(MESSAGE_TYPE_PUBLIC,"",_loc5_.message,param2);
            if(_loc9_ == this._roomPublic)
            {
               if(_loc5_.message.search(/(^|\s)ft(\s|$)/ig) > -1 || _loc5_.message.search(/(^|\s)lf(\s|$)/ig) > -1)
               {
                  _loc4_ = new ChatMessageData(CHANNEL_PUBLIC,MESSAGE_TYPE_SYSTEM);
                  _loc4_.posterNickName = USER_NAME_WARNING;
                  _loc4_.toNickName = this._userData.nickName;
                  _loc4_.message = this._lang.getString("chat.trade_warning");
                  this.onChatMessageReceived.dispatch(_loc4_);
               }
            }
         }
      }
      
      public function sendDirectCommand(param1:String, param2:String, ... rest) : void
      {
         if(!param1 || param1 == "")
         {
            return;
         }
         if(!param2 || param2 == "")
         {
            return;
         }
         var _loc4_:ParsedMessageData = new ParsedMessageData();
         _loc4_.messageType = MESSAGE_TYPE_COMMAND;
         _loc4_.nickName = param1;
         _loc4_.command = param2;
         _loc4_.linkData = rest;
         this.sendDirectMessage(_loc4_);
      }
      
      public function extractUserData(param1:String) : ChatUserData
      {
         var _loc4_:ChatRoom = null;
         var _loc5_:ChatUserData = null;
         var _loc2_:Vector.<ChatRoom> = Vector.<ChatRoom>(this._genericPublicChatRoomsList.concat([this._roomPublic,this._roomPrivate,this._roomTradePublic,this._roomAlliance,this._roomAdmin,this._roomRecruiting]));
         _loc2_ = _loc2_.concat(this._privateChatRoomList);
         var _loc3_:ChatUserData = null;
         for each(_loc4_ in _loc2_)
         {
            if(_loc4_)
            {
               _loc5_ = _loc4_.getUserByNickName(param1);
               if(_loc5_ != null)
               {
                  if(_loc5_.online)
                  {
                     return _loc5_;
                  }
                  _loc3_ = _loc5_;
               }
            }
         }
         return _loc3_;
      }
      
      public function sendReport(param1:String, param2:String, param3:String, param4:String, param5:String, param6:String) : void
      {
         var _loc7_:ChatRoom = null;
         if(param3 == "")
         {
            return;
         }
         if(param1 != CHANNEL_PUBLIC && param1 != CHANNEL_TRADE_PUBLIC && param1 != CHANNEL_RECRUITING)
         {
            param5 = "Orig Channel: " + param1 + "\n" + param5;
            _loc7_ = this.getChatRoomByChannel(CHANNEL_PUBLIC);
            if(_loc7_ == null)
            {
               _loc7_ = this.getChatRoomByChannel(CHANNEL_TRADE_PUBLIC);
            }
            if(param1 == CHANNEL_ALLIANCE)
            {
               param4 = "a" + param4.substr(1);
            }
            else
            {
               param4 = "t" + param4.substr(1);
            }
         }
         else
         {
            _loc7_ = this.getChatRoomByChannel(param1);
         }
         if(_loc7_ == null)
         {
            return;
         }
         _loc7_.sendReport(param2,param3,param4,param5,param6);
      }
      
      private function generateChatRoomObject(param1:String) : ChatRoom
      {
         var _loc2_:ChatRoom = new ChatRoom(this._client,param1,this._userData);
         _loc2_.onStatusChange.add(this.handleChatStatusChange);
         _loc2_.onMessageReceived.add(this.handleChatMessageReceived);
         _loc2_.onCommandReceived.add(this.handleCommandReceived);
         _loc2_.onFloodBanned.add(this.handleFloodBan);
         _loc2_.onBan.add(this.handleBan);
         _loc2_.onInitialBanUpdate.add(this.handleInitialBanUpdate);
         return _loc2_;
      }
      
      private function disposeChatRoomObject(param1:ChatRoom) : void
      {
         param1.onStatusChange.remove(this.handleChatStatusChange);
         param1.onMessageReceived.remove(this.handleChatMessageReceived);
         param1.onCommandReceived.remove(this.handleCommandReceived);
         param1.onFloodBanned.remove(this.handleFloodBan);
         param1.onBan.remove(this.handleBan);
         param1.onInitialBanUpdate.remove(this.handleInitialBanUpdate);
         var _loc2_:int = int(this._privateChatRoomList.indexOf(param1));
         if(_loc2_ > -1)
         {
            this._privateChatRoomList.splice(_loc2_,1);
         }
         if(this._genericPublicChatRoomsByChannel[param1.channel])
         {
            delete this._genericPublicChatRoomsByChannel[param1.channel];
            _loc2_ = int(this._genericPublicChatRoomsList.indexOf(param1));
            if(_loc2_ > -1)
            {
               this._genericPublicChatRoomsList.splice(_loc2_,1);
            }
         }
         param1.disconnect();
         param1.dispose();
      }
      
      private function handleChatStatusChange(param1:ChatRoom) : void
      {
         var _loc4_:Array = null;
         var _loc5_:ParsedMessageData = null;
         var _loc6_:ChatMessageData = null;
         var _loc7_:ChatMessageData = null;
         var _loc8_:* = null;
         var _loc9_:Boolean = false;
         var _loc2_:int = int(this._privateChatRoomList.indexOf(param1));
         if(_loc2_ > -1)
         {
            switch(param1.status)
            {
               case STATUS_CONNECTED:
                  _loc4_ = this._queuedDirectMsgs[param1.nickName];
                  if(_loc4_)
                  {
                     for each(_loc5_ in _loc4_)
                     {
                        if(_loc5_.messageType == MESSAGE_TYPE_COMMAND)
                        {
                           param1.sendCommand(_loc5_.command,_loc5_.nickName,_loc5_.linkData);
                        }
                        else
                        {
                           param1.sendMessage(MESSAGE_TYPE_PRIVATE,_loc5_.nickName,_loc5_.message,_loc5_.linkData);
                        }
                     }
                  }
                  delete this._queuedDirectMsgs[param1.nickName];
                  break;
               case STATUS_DISCONNECTED:
                  this.onDirectListRoomsFail(param1.nickName);
                  this.disposeChatRoomObject(param1);
            }
            return;
         }
         this.onChatStatusChange.dispatch(param1.channel,param1.status);
         var _loc3_:* = param1 == this._roomPrivate;
         if(param1.status == STATUS_CONNECTED && !_loc3_)
         {
            if(param1 == this._roomPublic || param1 == this._roomTradePublic)
            {
               _loc6_ = new ChatMessageData(param1.channel,MESSAGE_TYPE_SYSTEM);
               _loc6_.posterNickName = USER_NAME_COMMAND;
               _loc6_.toNickName = this._userData.nickName;
               _loc6_.message = this._lang.getString("chat.youHaveJoined",param1.roomId);
               this.onChatMessageReceived.dispatch(_loc6_);
               this.SendStrikeReminder(param1);
            }
            if(param1 == this._roomAdmin)
            {
               _loc7_ = new ChatMessageData(param1.channel,MESSAGE_TYPE_SYSTEM);
               _loc7_.posterNickName = USER_NAME_COMMAND;
               _loc7_.toNickName = this._userData.nickName;
               if(this._userData.isAdmin)
               {
                  _loc8_ = "Welcome " + this._userData.nickName + ", here are the people currently in this room: \n";
                  _loc7_.message = _loc8_;
                  this.onChatMessageReceived.dispatch(_loc7_);
                  this.adminListUsers(param1.channel);
               }
               else
               {
                  _loc7_.message = this._lang.getString("chat.youHaveJoinedAdmin");
                  this.onChatMessageReceived.dispatch(_loc7_);
               }
            }
            this.testKickedBan(true,param1.channel);
            this.testSilencedBan(true,param1.channel);
            if(param1.channel == CHANNEL_TRADE_PUBLIC)
            {
               this.testTradeBan(true,CHANNEL_TRADE_PUBLIC);
            }
         }
         if(param1 == this._roomAdmin && param1.status == STATUS_DISCONNECTED)
         {
            this._allowedChannels[CHANNEL_ADMIN] = this._userData.isAdmin;
            this.onAllowedChannelsChange.dispatch();
         }
         if(param1 != this._roomPrivate)
         {
            _loc9_ = this._roomAlliance.status == STATUS_CONNECTED || this._roomPublic.status == STATUS_CONNECTED || this._roomTradePublic.status == STATUS_CONNECTED || this._roomRecruiting.status == STATUS_CONNECTED || this._roomAdmin.status == STATUS_CONNECTED;
            this._roomPrivate.setPrivateRoomOnlineStatus(_loc9_);
            if(_loc9_ == false)
            {
               this.disconnectFromAllPrivateRooms();
            }
         }
      }
      
      private function SendStrikeReminder(param1:ChatRoom) : void
      {
         if(param1 == null || param1.HasShownStrikeReminder || param1.status != ChatSystem.STATUS_CONNECTED || this.ReminderStrikeNum <= 0)
         {
            return;
         }
         param1.HasShownStrikeReminder = true;
         var _loc2_:ChatMessageData = new ChatMessageData(param1.channel,ChatSystem.MESSAGE_TYPE_SYSTEM);
         _loc2_.posterNickName = ChatSystem.USER_NAME_WARNING;
         _loc2_.message = Language.getInstance().getString("chat.strike_reminder").replace("%strike",this.ReminderStrikeNum);
         _loc2_.toNickName = this._userData.nickName;
         this.onChatMessageReceived.dispatch(_loc2_);
      }
      
      private function getChatRoomByChannel(param1:String) : ChatRoom
      {
         switch(param1)
         {
            case CHANNEL_PUBLIC:
               return this._roomPublic;
            case CHANNEL_TRADE_PUBLIC:
               return this._roomTradePublic;
            case CHANNEL_PRIVATE:
               return this._roomPrivate;
            case CHANNEL_ALLIANCE:
               return this._roomAlliance;
            case CHANNEL_RECRUITING:
               return this._roomRecruiting;
            case CHANNEL_ADMIN:
               return this._roomAdmin;
            default:
               return this._genericPublicChatRoomsByChannel[param1];
         }
      }
      
      private function parseMessageString(param1:String) : ParsedMessageData
      {
         var _loc4_:String = null;
         var _loc2_:ParsedMessageData = new ParsedMessageData();
         param1 = param1.replace(/^\s+|\s+$/i,"").replace(/[ ]+/i," ");
         param1 = param1.replace(/^\/r\[/,"/r [");
         var _loc3_:Array = param1.split(" ");
         var _loc5_:String = "";
         if(param1.charAt(0) == "/")
         {
            _loc4_ = _loc3_.shift();
            if(_loc4_.length > 1)
            {
               _loc5_ = _loc4_.substr(1);
            }
         }
         if(param1.charAt(0) == "@")
         {
            _loc5_ = "@";
         }
         var _loc6_:Boolean = false;
         switch(_loc5_.toLowerCase())
         {
            case "@":
            case "w":
            case "whisper":
            case "t":
            case "tell":
               _loc2_.command = COMMAND_WHISPER;
               _loc6_ = true;
               break;
            case "r":
            case "reply":
               _loc2_.command = COMMAND_REPLY;
               _loc2_.nickName = this._lastPrivateMsgSender ? this._lastPrivateMsgSender : MISSING_USER_NICKNAME;
               break;
            case "mute":
               _loc2_.command = COMMAND_MUTE;
               _loc6_ = true;
               break;
            case "unmute":
               _loc2_.command = COMMAND_UNMUTE;
               _loc6_ = true;
               break;
            case "unmuteall":
               _loc2_.command = COMMAND_UNMUTEALL;
               break;
            case "block":
               _loc2_.command = COMMAND_BLOCK;
               _loc6_ = true;
               break;
            case "unblock":
               _loc2_.command = COMMAND_UNBLOCK;
               _loc6_ = true;
               break;
            case "unblockall":
               _loc2_.command = COMMAND_UNBLOCKALL;
               break;
            case "g":
            case "gang":
               _loc2_.command = COMMAND_GANG_ONLY;
               break;
            case "exit":
            case "disconnect":
            case "leave":
               _loc2_.command = COMMAND_EXIT;
               break;
            case "h":
            case "help":
               _loc2_.command = COMMAND_HELP;
               break;
            case "blocked":
            case "blocklist":
            case "muted":
               _loc2_.command = COMMAND_MUTED;
               break;
            case "add":
               _loc2_.command = COMMAND_ADD_CONTACT;
               _loc6_ = true;
               break;
            case "remove":
               _loc2_.command = COMMAND_REMOVE_CONTACT;
               _loc6_ = true;
               break;
            case "removeall":
               _loc2_.command = COMMAND_REMOVEALL_CONTACTS;
               break;
            case "contacts":
               _loc2_.command = COMMAND_LIST_CONTACTS;
               break;
            case "trade":
               _loc2_.command = COMMAND_TRADE_REQUEST;
               _loc6_ = true;
               break;
            case "invite":
               _loc2_.command = COMMAND_ALLIANCE_INVITE;
               _loc6_ = true;
               break;
            case "ls":
            case "listrooms":
               _loc2_.command = COMMAND_LISTROOMS;
               break;
            case "warn":
            case "warning":
               _loc2_.command = COMMAND_WARNING;
               break;
            case "pv":
            case "payvault":
               _loc2_.command = COMMAND_ADMIN_PAYVAULT;
               _loc6_ = true;
               break;
            case "join":
               _loc2_.command = COMMAND_ADMIN_JOINROOM;
               _loc6_ = true;
               break;
            case "listusers":
               _loc2_.command = COMMAND_ADMIN_LISTUSERS;
               break;
            case "recap":
               _loc2_.command = COMMAND_ADMIN_RECAPUSER;
               _loc6_ = true;
               break;
            case "kick":
               _loc2_.command = COMMAND_ADMIN_KICK;
               _loc6_ = true;
               break;
            case "strike":
               _loc2_.command = COMMAND_ADMIN_STRIKE;
               _loc6_ = true;
               break;
            case "ninjakick":
               _loc2_.command = COMMAND_ADMIN_KICKSILENTLY;
               _loc6_ = true;
               break;
            case "silence":
               _loc2_.command = COMMAND_ADMIN_SILENCE;
               _loc6_ = true;
               break;
            case "find":
               _loc2_.command = COMMAND_ADMIN_FIND;
               _loc6_ = true;
               break;
            case "alliance":
               _loc2_.command = COMMAND_ADMIN_CHANGEALLIANCE;
               break;
            case "command":
               _loc2_.command = COMMAND_ADMIN_SEND_COMMAND;
               _loc6_ = true;
               break;
            case "pull":
               _loc2_.command = COMMAND_ADMIN_PULLIN;
               _loc6_ = true;
               break;
            case "push":
               _loc2_.command = COMMAND_ADMIN_PUSHOUT;
               _loc6_ = true;
               break;
            case "temp":
               _loc2_.command = COMMAND_ADMIN_TEMP;
               break;
            case "lock":
               _loc2_.command = COMMAND_ADMIN_LOCK;
               break;
            case "unlock":
               _loc2_.command = COMMAND_ADMIN_UNLOCK;
               break;
            case "tradeban":
               _loc2_.command = COMMAND_ADMIN_TRADEBAN;
               _loc6_ = true;
               break;
            default:
               if(_loc5_ != "")
               {
                  return null;
               }
         }
         if(_loc6_)
         {
            if(_loc5_ == "@")
            {
               _loc2_.nickName = _loc3_.shift().substr(1);
            }
            else if(_loc3_.length > 0)
            {
               _loc2_.nickName = _loc3_.shift();
            }
            if(_loc2_.nickName == "" || _loc2_.nickName.search(/(\[|\])/ig) > -1)
            {
               _loc2_.nickName = MISSING_USER_NICKNAME;
            }
         }
         _loc2_.message = _loc3_.join(" ");
         return _loc2_;
      }
      
      private function handleChatMessageReceived(param1:ChatRoom, param2:ChatMessageData) : void
      {
         var _loc3_:* = null;
         var _loc4_:ChatMessageData = null;
         if(param2.messageType != MESSAGE_TYPE_SYSTEM && param2.messageType != MESSAGE_TYPE_WARNING)
         {
            if(!param2.posterIsAdmin)
            {
               if(this.checkBlocked(param2.posterNickName) || this.checkMuted(param2.posterNickName))
               {
                  return;
               }
            }
            if(this.testKickedBan(false,param2.channel))
            {
               return;
            }
            if(param2.channel == CHANNEL_TRADE_PUBLIC && this.testTradeBan(false,CHANNEL_TRADE_PUBLIC))
            {
               return;
            }
         }
         if(param2.posterNickName != this._userData.nickName && param2.channel == CHANNEL_PRIVATE && !this.isChannelAllowed(CHANNEL_PRIVATE) && !param2.posterIsAdmin)
         {
            _loc3_ = "<a href=\'event:" + ChatLinkEvent.LT_USERMENU + ":" + param2.posterNickName + ":0\'>" + param2.posterNickName + "</a>";
            _loc4_ = new ChatMessageData(param2.channel,MESSAGE_TYPE_PRIVATE);
            _loc4_.toNickName = this._userData.nickName;
            _loc4_.message = this._lang.getString("chat.get_private_requires_2way",_loc3_);
            this.onChatMessageReceived.dispatch(_loc4_);
            param1.sendUnfilteredMessage(MESSAGE_TYPE_SYSTEM,this._lang.getString("chat.bounce_private_requires_2way",this._userData.nickName),param2.posterNickName,USER_NAME_WARNING);
            return;
         }
         if(param2.channel == CHANNEL_PRIVATE && param2.posterNickName != this._userData.nickName)
         {
            this._lastPrivateMsgSender = param2.posterNickName;
         }
         this.onChatMessageReceived.dispatch(param2);
      }
      
      private function handleCommandReceived(param1:String, param2:Boolean, param3:String, param4:Array) : void
      {
         var _loc5_:ChatMessageData = null;
         if(!param2)
         {
            if(this.checkBlocked(param1) || this.checkMuted(param1))
            {
               return;
            }
         }
         switch(param3)
         {
            case "_findUser":
               this.sendDirectCommand(param1,"_findUserResponse",param4[0],this._roomPublic.roomId,this._roomTradePublic.roomId);
               break;
            case "_findUserResponse":
               _loc5_ = new ChatMessageData(param4[0],MESSAGE_TYPE_SYSTEM);
               _loc5_.posterNickName = USER_NAME_COMMAND;
               _loc5_.message = "Find Response:";
               _loc5_.message += "\n Public room: " + param4[1];
               _loc5_.message += "\n Trade room: " + param4[2];
               this.onChatMessageReceived.dispatch(_loc5_);
               break;
            case COMMAND_ALLIANCE_INVITE:
               this.handleAllianceInviteReceived(param1,param4[0],param4[1],param4[2],param4[3]);
               break;
            case COMMAND_ALLIANCE_FEEDBACK:
               this.handleAllianceInviteResponse(param1,param4[0],param4[1]);
               break;
            case COMMAND_BOUNCED_MSG:
               _loc5_ = new ChatMessageData("temp",MESSAGE_TYPE_SYSTEM);
               _loc5_.posterNickName = USER_NAME_NOTHING;
               _loc5_.toNickName = this._userData.nickName;
               _loc5_.message = this._lang.getString("chat.not_online_message",param1);
               _loc5_.channel = CHANNEL_PRIVATE;
               this.onChatMessageReceived.dispatch(_loc5_);
               break;
            case COMMAND_ADMIN_PULLIN:
               this._allowedChannels[CHANNEL_ADMIN] = true;
               this.onAllowedChannelsChange.dispatch();
               this.connect(CHANNEL_ADMIN);
         }
         this.onCommandReceived.dispatch(param1,param3,param4);
      }
      
      private function onBalancedRoomListSuccess(param1:String, param2:Array) : void
      {
         var _loc4_:int = 0;
         var _loc9_:RoomInfo = null;
         var _loc10_:RoomInfo = null;
         var _loc12_:RoomInfo = null;
         var _loc3_:String = this.getBalancedRoomPrefix(param1);
         var _loc5_:* = Network.getInstance().playerData.getPlayerSurvivor().level > 24;
         if(param1 == CHANNEL_TRADE_PUBLIC)
         {
            _loc3_ += _loc5_ ? "High" : "Low";
            _loc4_ = int(param2.length - 1);
            while(_loc4_ >= 0)
            {
               if(param2[_loc4_].id.indexOf(_loc3_) == -1)
               {
                  param2.splice(_loc4_,1);
               }
               _loc4_--;
            }
         }
         _loc4_ = int(param2.length - 1);
         while(_loc4_ >= 0)
         {
            if(param2[_loc4_].id.indexOf(_loc3_) == -1)
            {
               param2.splice(_loc4_,1);
            }
            _loc4_--;
         }
         if(param2.length == 0)
         {
            this.joinBalancedRoom(param1,_loc3_ + 0);
            return;
         }
         var _loc6_:Number = param1 == CHANNEL_TRADE_PUBLIC ? Number(Config.constant.CHAT_TRADE_ROOM_SIZE_LIMIT) : Number(Config.constant.CHAT_PUBLIC_ROOM_SIZE_LIMIT);
         var _loc7_:Number = int(_loc6_ * (param1 == CHANNEL_TRADE_PUBLIC ? Config.constant.CHAT_TRADE_ROOM_BALANCE_THRESHOLD : Config.constant.CHAT_PUBLIC_ROOM_BALANCE_THRESHOLD));
         var _loc8_:Number = int(_loc7_ * 0.5);
         var _loc11_:Array = [int(param2[0].id.replace(_loc3_,""))];
         _loc4_ = 0;
         while(_loc4_ < param2.length)
         {
            _loc12_ = RoomInfo(param2[_loc4_]);
            _loc11_.push(int(_loc12_.id.replace(_loc3_,"")));
            if(_loc12_.onlineUsers > _loc8_)
            {
               if(!_loc9_ || _loc12_.onlineUsers < _loc9_.onlineUsers)
               {
                  _loc9_ = _loc12_;
               }
            }
            else if(!_loc10_ || _loc12_.onlineUsers > _loc10_.onlineUsers)
            {
               _loc10_ = _loc12_;
            }
            _loc4_++;
         }
         if(Boolean(_loc9_) && _loc9_.onlineUsers < _loc7_)
         {
            this.joinBalancedRoom(param1,_loc9_.id);
         }
         else if(_loc10_)
         {
            this.joinBalancedRoom(param1,_loc10_.id);
         }
         else
         {
            _loc4_ = 0;
            while(_loc4_ <= _loc11_.length)
            {
               if(_loc11_.indexOf(_loc4_) == -1)
               {
                  this.joinBalancedRoom(param1,_loc3_ + _loc4_);
                  break;
               }
               _loc4_++;
            }
         }
      }
      
      private function joinBalancedRoom(param1:String, param2:String) : void
      {
         this.getChatRoomByChannel(param1).createJoin(param2,this.getBalancedRoomNickname(param1),RoomType.CHAT,{"AutoClose":false},true);
      }
      
      private function getBalancedRoomNickname(param1:String) : String
      {
         var _loc2_:String = "";
         _loc2_ = SERVICE_PREFIX;
         switch(param1)
         {
            case CHANNEL_PUBLIC:
               _loc2_ += PUBLIC_ROOM_NICKNAME;
               break;
            case CHANNEL_TRADE_PUBLIC:
               _loc2_ += TRADE_ROOM_NICKNAME;
               break;
            case CHANNEL_RECRUITING:
               _loc2_ += RECRUITING_ROOM_NICKNAME;
               break;
            default:
               throw new Error("Unknown channel for nickname");
         }
         return _loc2_;
      }
      
      private function getBalancedRoomPrefix(param1:String) : String
      {
         switch(param1)
         {
            case CHANNEL_PUBLIC:
               return SERVICE_PREFIX + PUBLIC_ROOM_PREFIX;
            case CHANNEL_TRADE_PUBLIC:
               return SERVICE_PREFIX + TRADE_ROOM_PREFIX;
            case CHANNEL_RECRUITING:
               return SERVICE_PREFIX + RECRUITING_ROOM_PREFIX;
            default:
               throw new Error("Unknown channel for prefix");
         }
      }
      
      private function sendPrivateMessage(param1:ParsedMessageData, param2:String) : void
      {
         var _loc5_:ChatMessageData = null;
         var _loc3_:ChatUserData = this.extractUserData(param1.nickName);
         var _loc4_:Boolean = _loc3_ != null && _loc3_.isAdmin;
         if(!this.isChannelAllowed(CHANNEL_PRIVATE) && !_loc4_)
         {
            _loc5_ = new ChatMessageData(CHANNEL_PRIVATE,MESSAGE_TYPE_SYSTEM);
            _loc5_.posterNickName = USER_NAME_ERROR;
            _loc5_.toNickName = this._userData.nickName;
            _loc5_.message = this._lang.getString("chat.send_private_requires_2way");
            this.onChatMessageReceived.dispatch(_loc5_);
            return;
         }
         param1.messageType = MESSAGE_TYPE_PRIVATE;
         param1.channel = param2;
         this.sendDirectMessage(param1);
      }
      
      private function sendDirectMessage(param1:ParsedMessageData) : void
      {
         var ud:ChatUserData;
         var r:ChatRoom = null;
         var list:Array = null;
         var md:ParsedMessageData = param1;
         if(md.nickName == "" || md.nickName == MISSING_USER_NICKNAME)
         {
            return;
         }
         if(md.messageType == MESSAGE_TYPE_PRIVATE)
         {
            if(md.message.replace(/(^\s*|\s*$/ig,"") == "")
            {
               return;
            }
         }
         ud = this._roomPrivate.getUserByNickName(md.nickName);
         if(Boolean(ud) && ud.online)
         {
            if(md.messageType == MESSAGE_TYPE_COMMAND)
            {
               this._roomPrivate.sendCommand(md.command,md.nickName,md.linkData);
            }
            else
            {
               this._roomPrivate.sendMessage(md.messageType,md.nickName,md.message,md.linkData);
            }
            return;
         }
         for each(r in this._privateChatRoomList)
         {
            if(r.nickName == md.nickName)
            {
               if(md.messageType == MESSAGE_TYPE_COMMAND)
               {
                  r.sendCommand(md.command,md.nickName,md.linkData);
               }
               else
               {
                  r.sendMessage(md.messageType,md.nickName,md.message,md.linkData);
               }
               return;
            }
         }
         list = ([this._roomPublic,this._roomTradePublic,this._roomRecruiting] as Array).concat(this._genericPublicChatRoomsList);
         for each(r in list)
         {
            if(r.status == STATUS_CONNECTED)
            {
               ud = r.getUserByNickName(md.nickName);
               if(!(ud == null || ud.online == false))
               {
                  if(md.messageType == MESSAGE_TYPE_COMMAND)
                  {
                     r.sendCommand(md.command,md.nickName,md.linkData);
                  }
                  else
                  {
                     r.sendMessage(md.messageType,md.nickName,md.message,md.linkData);
                  }
                  return;
               }
            }
         }
         if(!this._queuedDirectMsgs[md.nickName])
         {
            this._queuedDirectMsgs[md.nickName] = [];
         }
         this._queuedDirectMsgs[md.nickName].push(md);
         this._client.multiplayer.listRooms(RoomType.CHAT,{"NickName":SERVICE_PREFIX + md.nickName},1,0,function(param1:Array):void
         {
            onDirectListRoomsSuccess(md.nickName,param1);
         },function(param1:PlayerIOError):void
         {
            onDirectListRoomsFail(md.nickName);
         });
      }
      
      private function onAllianceSystemConnected() : void
      {
         this._userData.allianceId = this._playerData.allianceId;
         this._userData.allianceTag = this._playerData.allianceTag;
      }
      
      private function onAllianceSystemDisconnected() : void
      {
         this._userData.allianceId = this._playerData.allianceId;
         this._userData.allianceTag = this._playerData.allianceTag;
      }
      
      private function onDirectListRoomsSuccess(param1:String, param2:Array) : void
      {
         var _loc3_:ChatRoom = null;
         var _loc4_:RoomInfo = null;
         var _loc5_:ChatRoom = null;
         if(param2.length == 0)
         {
            this.onDirectListRoomsFail(param1);
            return;
         }
         for each(_loc3_ in this._privateChatRoomList)
         {
            if(_loc3_.nickName == param1)
            {
               return;
            }
         }
         for each(_loc4_ in param2)
         {
            if(_loc4_["initData"]["NickName"] == param1)
            {
               _loc5_ = this.generateChatRoomObject(CHANNEL_PRIVATE);
               _loc5_.nickName = param1;
               this._privateChatRoomList.push(_loc5_);
               _loc5_.join(_loc4_.id);
               return;
            }
         }
         this.onDirectListRoomsFail(param1);
      }
      
      private function onDirectListRoomsFail(param1:String) : void
      {
         var data:ChatMessageData = null;
         var md:ParsedMessageData = null;
         var toNickName:String = param1;
         var channelsList:Array = [];
         var a:Array = this._queuedDirectMsgs[toNickName];
         if(a)
         {
            for each(md in a)
            {
               if(md.messageType == MESSAGE_TYPE_PRIVATE)
               {
                  if(channelsList.indexOf(md.channel) == -1)
                  {
                     channelsList.push(md.channel);
                  }
                  data = new ChatMessageData(CHANNEL_PRIVATE,MESSAGE_TYPE_PRIVATE);
                  data.posterId = this._userData.userId;
                  data.posterNickName = this._userData.nickName;
                  data.toNickName = toNickName;
                  data.message = md.message;
                  data.linkData = md.linkData;
                  this.onChatMessageReceived.dispatch(data);
               }
            }
            TweenMax.delayedCall(0.05 + Math.random() * 0.2,function():void
            {
               data = new ChatMessageData("temp",MESSAGE_TYPE_SYSTEM);
               data.posterNickName = USER_NAME_NOTHING;
               data.toNickName = _userData.nickName;
               data.message = _lang.getString("chat.not_online_message",toNickName);
               data.channel = CHANNEL_PRIVATE;
               onChatMessageReceived.dispatch(data);
            });
            this.onTargetUserNotOnline.dispatch(toNickName);
            delete this._queuedDirectMsgs[toNickName];
         }
      }
      
      private function collectContactAndBlockLists() : void
      {
         Network.getInstance().save(null,SaveDataMethod.CHAT_GET_CONTACTS_AND_BLOCKS,function(param1:Object):void
         {
            if(param1 == null)
            {
               return;
            }
            if(Boolean(param1.contacts) && param1.contacts is Array)
            {
               _contactlist = param1.contacts;
            }
            if(Boolean(param1.blocks) && param1.blocks is Array)
            {
               _blocklist = param1.blocks;
            }
         });
      }
      
      private function addToContactList(param1:String, param2:String) : void
      {
         var nickName:String = param1;
         var channel:String = param2;
         Network.getInstance().save({"nickName":nickName},SaveDataMethod.CHAT_ADD_CONTACT,function(param1:Object):void
         {
            var _loc2_:Boolean = Boolean(param1["success"]);
            if(_loc2_)
            {
               _contactlist.push(nickName);
            }
            var _loc3_:ChatMessageData = new ChatMessageData(channel,MESSAGE_TYPE_SYSTEM);
            _loc3_.posterNickName = USER_NAME_COMMAND;
            _loc3_.toNickName = _userData.nickName;
            _loc3_.message = _loc2_ ? "SAVED: " + nickName : "CONTACT LIMIT REACHED";
            onChatMessageReceived.dispatch(_loc3_);
         });
      }
      
      private function removeFromContactList(param1:String, param2:String) : void
      {
         var nickName:String = param1;
         var channel:String = param2;
         Network.getInstance().save({"nickName":nickName},SaveDataMethod.CHAT_REMOVE_CONTACT,function(param1:Object):void
         {
            var _loc2_:int = int(_contactlist.indexOf(nickName));
            if(_loc2_ > -1)
            {
               _contactlist.splice(_loc2_,1);
            }
            var _loc3_:ChatMessageData = new ChatMessageData(channel,MESSAGE_TYPE_SYSTEM);
            _loc3_.posterNickName = USER_NAME_COMMAND;
            _loc3_.toNickName = _userData.nickName;
            _loc3_.message = _loc2_ > -1 ? "REMOVED: " + nickName : "UNKNOWN: " + nickName;
            onChatMessageReceived.dispatch(_loc3_);
         });
      }
      
      private function removeAllContacts(param1:String) : void
      {
         var channel:String = param1;
         Network.getInstance().save(null,SaveDataMethod.CHAT_REMOVE_ALL_CONTACTS,function(param1:Object):void
         {
            _contactlist = [];
            var _loc2_:ChatMessageData = new ChatMessageData(channel,MESSAGE_TYPE_SYSTEM);
            _loc2_.posterNickName = USER_NAME_COMMAND;
            _loc2_.toNickName = _userData.nickName;
            _loc2_.message = "All user blocks have been removed";
            onChatMessageReceived.dispatch(_loc2_);
         });
      }
      
      private function listContacts(param1:String) : void
      {
         this._contactlist.sort(Array.CASEINSENSITIVE);
         var _loc2_:String = "CONTACTS: " + this._contactlist.length + " user" + (this._contactlist.length == 1 ? "" : "s");
         var _loc3_:int = 0;
         while(_loc3_ < this._contactlist.length)
         {
            _loc2_ += "\n<a href=\'event:" + ChatLinkEvent.LT_USERMENU + ":" + this._contactlist[_loc3_] + ":\'>" + this._contactlist[_loc3_] + "</a>";
            _loc3_++;
         }
         var _loc4_:ChatMessageData = new ChatMessageData(param1,MESSAGE_TYPE_SYSTEM);
         _loc4_.posterNickName = USER_NAME_COMMAND;
         _loc4_.toNickName = this._userData.nickName;
         _loc4_.message = _loc2_;
         this.onChatMessageReceived.dispatch(_loc4_);
      }
      
      public function checkContact(param1:String) : Boolean
      {
         return this._contactlist.indexOf(param1) > -1;
      }
      
      private function addToBlockList(param1:String, param2:String) : void
      {
         var targetUserId:String;
         var targetUserData:ChatUserData;
         var nickName:String = param1;
         var channel:String = param2;
         if(nickName == this.userData.nickName)
         {
            return;
         }
         targetUserId = "";
         targetUserData = this.extractUserData(nickName);
         if(targetUserData != null)
         {
            targetUserId = targetUserData.userId;
         }
         Network.getInstance().save({
            "nickName":nickName,
            "userId":targetUserId
         },SaveDataMethod.CHAT_ADD_BLOCK,function(param1:Object):void
         {
            var _loc4_:int = 0;
            var _loc2_:Boolean = Boolean(param1["success"]);
            if(_loc2_)
            {
               _blocklist.push(nickName);
            }
            var _loc3_:ChatMessageData = new ChatMessageData(channel,MESSAGE_TYPE_SYSTEM);
            _loc3_.posterNickName = USER_NAME_COMMAND;
            _loc3_.toNickName = _userData.nickName;
            _loc3_.message = _loc2_ ? "PERMANENTLY BLOCKED: " + nickName : "BLOCKED LIMIT REACHED";
            if(_loc2_)
            {
               _loc4_ = int(_mutedlist.indexOf(nickName));
               if(_loc4_ > -1)
               {
                  _mutedlist.splice(_loc4_,1);
               }
            }
            onChatMessageReceived.dispatch(_loc3_);
         });
      }
      
      private function removeFromBlockList(param1:String, param2:String) : void
      {
         var nickName:String = param1;
         var channel:String = param2;
         var targetUserId:String = "";
         var targetUserData:ChatUserData = this.extractUserData(nickName);
         if(targetUserData != null)
         {
            targetUserId = targetUserData.userId;
         }
         Network.getInstance().save({
            "nickName":nickName,
            "userId":targetUserId
         },SaveDataMethod.CHAT_REMOVE_BLOCK,function(param1:Object):void
         {
            var _loc2_:int = int(_blocklist.indexOf(nickName));
            if(_loc2_ > -1)
            {
               _blocklist.splice(_loc2_,1);
            }
            var _loc3_:ChatMessageData = new ChatMessageData(channel,MESSAGE_TYPE_SYSTEM);
            _loc3_.posterNickName = USER_NAME_COMMAND;
            _loc3_.toNickName = _userData.nickName;
            _loc3_.message = _loc2_ > -1 ? "UNBLOCKED: " + nickName : "UNKNOWN USER: " + nickName;
            onChatMessageReceived.dispatch(_loc3_);
            _loc2_ = int(_mutedlist.indexOf(nickName));
            if(_loc2_ > -1)
            {
               _mutedlist.splice(_loc2_,1);
            }
         });
      }
      
      private function removeAllFromBlockList(param1:String) : void
      {
         var channel:String = param1;
         Network.getInstance().save(null,SaveDataMethod.CHAT_REMOVE_ALL_BLOCKS,function(param1:Object):void
         {
            _blocklist = [];
            var _loc2_:ChatMessageData = new ChatMessageData(channel,MESSAGE_TYPE_SYSTEM);
            _loc2_.posterNickName = USER_NAME_COMMAND;
            _loc2_.toNickName = _userData.nickName;
            _loc2_.message = "All user blocks have been removed";
            onChatMessageReceived.dispatch(_loc2_);
         });
      }
      
      private function listBlockedAndMutedUsers(param1:String) : void
      {
         var _loc2_:Array = this._blocklist.concat(this._mutedlist);
         _loc2_.sort(Array.CASEINSENSITIVE);
         var _loc3_:* = "";
         var _loc4_:String = "";
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         while(_loc6_ < _loc2_.length)
         {
            if(_loc4_ != _loc2_[_loc6_])
            {
               _loc4_ = _loc2_[_loc6_];
               _loc3_ += "\n<a href=\'event:" + ChatLinkEvent.LT_USERMENU + ":" + _loc2_[_loc6_] + ":0\'>" + _loc2_[_loc6_] + "</a>";
               if(this._blocklist.indexOf(_loc2_[_loc6_]) == -1)
               {
                  _loc3_ += " (muted for this session)";
               }
               _loc5_++;
            }
            _loc6_++;
         }
         _loc3_ = "BLOCKED/MUTED: " + _loc5_ + " user" + (_loc5_ == 1 ? "" : "s") + _loc3_;
         var _loc7_:ChatMessageData = new ChatMessageData(param1,MESSAGE_TYPE_SYSTEM);
         _loc7_.posterNickName = USER_NAME_COMMAND;
         _loc7_.toNickName = this._userData.nickName;
         _loc7_.message = _loc3_;
         this.onChatMessageReceived.dispatch(_loc7_);
      }
      
      public function checkBlocked(param1:String) : Boolean
      {
         return this._blocklist.indexOf(param1) > -1;
      }
      
      private function addToMuteList(param1:String, param2:String) : void
      {
         if(param1 == this.userData.nickName)
         {
            return;
         }
         var _loc3_:int = int(this._mutedlist.indexOf(param1));
         if(_loc3_ == -1)
         {
            this._mutedlist.push(param1);
         }
         var _loc4_:ChatMessageData = new ChatMessageData(param2,MESSAGE_TYPE_SYSTEM);
         _loc4_.posterNickName = USER_NAME_COMMAND;
         _loc4_.toNickName = this._userData.nickName;
         _loc4_.message = "MUTED FOR THIS SESSION: " + param1;
         this.onChatMessageReceived.dispatch(_loc4_);
      }
      
      private function removeFromMuteList(param1:String, param2:String) : void
      {
         var _loc3_:int = int(this._mutedlist.indexOf(param1));
         if(_loc3_ > -1)
         {
            this._mutedlist.splice(_loc3_,1);
         }
         var _loc4_:ChatMessageData = new ChatMessageData(param2,MESSAGE_TYPE_SYSTEM);
         _loc4_.posterNickName = USER_NAME_COMMAND;
         _loc4_.toNickName = this._userData.nickName;
         _loc4_.message = _loc3_ > -1 ? "UNMUTED: " + param1 : "UNKNOWN USER: " + param1;
         this.onChatMessageReceived.dispatch(_loc4_);
      }
      
      private function removeAllFromMuteList(param1:String) : void
      {
         this._mutedlist = [];
         var _loc2_:ChatMessageData = new ChatMessageData(param1,MESSAGE_TYPE_SYSTEM);
         _loc2_.posterNickName = USER_NAME_COMMAND;
         _loc2_.toNickName = this._userData.nickName;
         _loc2_.message = "All users have been unmuted";
         this.onChatMessageReceived.dispatch(_loc2_);
      }
      
      public function checkMuted(param1:String) : Boolean
      {
         return this._mutedlist.indexOf(param1) > -1;
      }
      
      private function handleFloodBan(param1:uint, param2:String) : void
      {
         var _loc3_:ChatMessageData = new ChatMessageData(param2,MESSAGE_TYPE_SYSTEM);
         _loc3_.toNickName = this._userData.nickName;
         if(param1 == 0)
         {
            _loc3_.message = this._lang.getString("chat.flooding_ban_warning",param1);
            _loc3_.posterNickName = USER_NAME_WARNING;
         }
         else
         {
            this._floodBanned = getTimer() + param1 * 60 * 1000;
            _loc3_.message = this._lang.getString("chat.flooding_ban_minutes",param1);
            _loc3_.posterNickName = USER_NAME_BAN;
         }
         this.onChatMessageReceived.dispatch(_loc3_);
      }
      
      private function handleInitialBanUpdate(param1:Message, param2:String) : void
      {
         var _loc3_:int = 0;
         this.ReminderStrikeNum = param1.getInt(_loc3_++);
         this._banType = param1.getString(_loc3_++);
         var _loc4_:int = param1.getInt(_loc3_++);
         this._banReason = param1.getString(_loc3_++);
         this._banExpiration = param1.getNumber(_loc3_++);
         this.testSilencedBan(false,"");
         this.testKickedBan(true,"");
         this.SendStrikeReminder(this._roomPublic);
         this.SendStrikeReminder(this._roomTradePublic);
      }
      
      private function handleBan(param1:Message, param2:String) : void
      {
         var _loc11_:ChatRoom = null;
         var _loc12_:String = null;
         var _loc13_:String = null;
         var _loc3_:int = 0;
         var _loc4_:int = param1.getInt(_loc3_++);
         var _loc5_:String = param1.getString(_loc3_++);
         var _loc6_:Boolean = param1.getBoolean(_loc3_++);
         var _loc7_:int = param1.getInt(_loc3_++);
         var _loc8_:String = param1.getString(_loc3_++);
         var _loc9_:String = param1.getString(_loc3_++);
         var _loc10_:Number = param1.getNumber(_loc3_++);
         this._banType = _loc5_;
         this._banReason = _loc8_;
         this._banExpiration = _loc10_;
         if(_loc5_ == BT_STRIKE)
         {
            this._lastBanStrikeNum = this.ReminderStrikeNum = _loc4_;
         }
         else
         {
            this._lastBanStrikeNum = -1;
         }
         if(_loc7_ > 0 && _loc5_ != BT_NONE)
         {
            _loc11_ = this.getChatRoomByChannel(param2);
            if(_loc11_ != null)
            {
               _loc12_ = "";
               _loc13_ = "";
               switch(_loc5_)
               {
                  case BT_SILENCE:
                     _loc12_ = this.userData.nickName + " has been " + (_loc6_ ? "silently" : "") + " silenced for " + this.getBanTimeText(this._banExpiration) + " reason: " + this._banReason;
                     _loc13_ = this._lang.getString(this.getBanTimeMin(this._banExpiration) >= INDEFINITE_BAN_TIME ? "chat.public_silenced_indefinitely" : "chat.public_silenced_time");
                     break;
                  case BT_KICK:
                     _loc12_ = this.userData.nickName + " has been " + (_loc6_ ? "silently" : "") + " kicked for " + this.getBanTimeText(this._banExpiration) + " reason: " + this._banReason;
                     _loc13_ = this._lang.getString(this.getBanTimeMin(this._banExpiration) > INDEFINITE_BAN_TIME ? "chat.public_kicked_indefinitely" : "chat.public_kicked_time");
                     break;
                  case BT_TRADEBAN:
                     _loc12_ = this.userData.nickName + " has been " + (_loc6_ ? "silently" : "") + " trade banned for " + this.getBanTimeText(this._banExpiration) + " reason: " + this._banReason;
                     _loc13_ = this._lang.getString(this.getBanTimeMin(this._banExpiration) > INDEFINITE_BAN_TIME ? "chat.public_tradeBan_indefinitely" : "chat.public_tradeBan_time");
                     break;
                  case BT_STRIKE:
                     _loc12_ = this.userData.nickName + " has been " + (_loc6_ ? "silently" : "") + " given a Strike for " + this.getBanTimeText(this._banExpiration) + " reason: " + this._banReason;
                     _loc13_ = this._lang.getString(this.getBanTimeMin(this._banExpiration) > INDEFINITE_BAN_TIME ? "chat.public_strike_indefinitely" : "chat.public_strike_time");
                     break;
                  case BT_SUSPEND:
                     _loc12_ = this.userData.nickName + " has been " + (_loc6_ ? "silently" : "") + " suspended for " + this.getBanTimeText(this._banExpiration) + " reason: " + this._banReason;
                     _loc13_ = this._lang.getString(this.getBanTimeMin(this._banExpiration) > INDEFINITE_BAN_TIME ? "chat.public_suspended_indefinitely" : "chat.public_suspended_time");
                     this._banType = BT_KICK;
               }
               if(_loc12_ != "")
               {
                  _loc11_.sendAdminFeedback("Client response: " + _loc12_);
               }
               if(_loc13_ != "")
               {
                  _loc13_ = _loc13_.replace("%time",this.getBanTimeText(this._banExpiration));
                  _loc13_ = _loc13_.replace("%user",this._userData.nickName);
                  _loc13_ = _loc13_.replace("%reason",this._banReason);
                  _loc13_ = _loc13_.replace("%strike",this.ReminderStrikeNum);
                  if(_loc6_)
                  {
                     if(_loc9_ != "")
                     {
                        _loc11_.sendUnfilteredMessage(MESSAGE_TYPE_SYSTEM,_loc12_ != "" ? _loc12_ : _loc13_,_loc9_,USER_NAME_BAN);
                     }
                  }
                  else
                  {
                     _loc11_.sendUnfilteredMessage(MESSAGE_TYPE_SYSTEM,_loc13_,"",USER_NAME_BAN);
                     _loc11_.sendAdminFeedback("Client response: " + _loc13_);
                  }
               }
               _loc11_.sendBanConsumed();
            }
         }
         if(_loc5_ == BT_SILENCE)
         {
            this.testSilencedBan(true,param2);
         }
         else if(_loc5_ == BT_TRADEBAN)
         {
            this.testTradeBan(true,CHANNEL_ALL);
         }
         else
         {
            this.testKickedBan(true,param2);
         }
         if(_loc5_ == BT_SUSPEND)
         {
            Network.getInstance().disconnect();
         }
      }
      
      private function testSilencedBan(param1:Boolean, param2:String) : Boolean
      {
         var _loc3_:ChatMessageData = null;
         if(this._banType != BT_SILENCE || this._banExpiration <= 0 || param2 == CHANNEL_ADMIN || Network.getInstance().playerData.isAdmin)
         {
            return false;
         }
         if(this._banExpiration < Network.getInstance().serverTime)
         {
            this._banExpiration = 0;
            return false;
         }
         if(param1)
         {
            _loc3_ = new ChatMessageData(param2,MESSAGE_TYPE_SYSTEM);
            _loc3_.posterNickName = USER_NAME_BAN;
            _loc3_.toNickName = this._userData.nickName;
            _loc3_.message = this._lang.getString(this.getBanTimeMin(this._banExpiration) >= INDEFINITE_BAN_TIME ? "chat.user_silenced_indefinite" : "chat.user_silenced_time");
            _loc3_.message = _loc3_.message.replace("%time",this.getBanTimeText(this._banExpiration));
            _loc3_.message = _loc3_.message.replace("%reason",this._banReason == "" ? "N/A" : this._banReason);
            this.onChatMessageReceived.dispatch(_loc3_);
         }
         return true;
      }
      
      private function testKickedBan(param1:Boolean, param2:String) : Boolean
      {
         var _loc3_:ChatMessageData = null;
         if(this._banType != BT_KICK && this._banType != BT_STRIKE || this._banExpiration <= 0 || param2 == CHANNEL_ADMIN || Network.getInstance().playerData.isAdmin)
         {
            return false;
         }
         if(this._banExpiration < Network.getInstance().serverTime)
         {
            this._banExpiration = 0;
            return false;
         }
         if(param1)
         {
            _loc3_ = new ChatMessageData(CHANNEL_ALL,MESSAGE_TYPE_SYSTEM);
            _loc3_.toNickName = this._userData.nickName;
            _loc3_.posterNickName = USER_NAME_COMMAND;
            _loc3_.message = "*clear*";
            this.onChatMessageReceived.dispatch(_loc3_);
            _loc3_ = new ChatMessageData(CHANNEL_ALL,MESSAGE_TYPE_SYSTEM);
            _loc3_.posterNickName = USER_NAME_BAN;
            _loc3_.toNickName = this._userData.nickName;
            if(this._lastBanStrikeNum > 0)
            {
               _loc3_.message = this._lang.getString(this.getBanTimeMin(this._banExpiration) > INDEFINITE_BAN_TIME ? "chat.user_strike_indefinitely" : "chat.user_strike_time");
            }
            else
            {
               _loc3_.message = this._lang.getString(this.getBanTimeMin(this._banExpiration) > INDEFINITE_BAN_TIME ? "chat.user_kicked_indefinitely" : "chat.user_kicked_time");
            }
            _loc3_.message = _loc3_.message.replace("%time",this.getBanTimeText(this._banExpiration));
            _loc3_.message = _loc3_.message.replace("%reason",this._banReason == "" ? "N/A" : this._banReason);
            _loc3_.message = _loc3_.message.replace("%strike",this._lastBanStrikeNum);
            this.onChatMessageReceived.dispatch(_loc3_);
         }
         return true;
      }
      
      public function testTradeBan(param1:Boolean, param2:String) : Boolean
      {
         var _loc3_:ChatMessageData = null;
         if(this._banType != BT_TRADEBAN || this._banExpiration <= 0 || Network.getInstance().playerData.isAdmin)
         {
            return false;
         }
         if(this._banExpiration < Network.getInstance().serverTime)
         {
            this._banExpiration = 0;
            return false;
         }
         if(param1)
         {
            _loc3_ = new ChatMessageData(CHANNEL_TRADE_PUBLIC,MESSAGE_TYPE_SYSTEM);
            _loc3_.toNickName = this._userData.nickName;
            _loc3_.posterNickName = USER_NAME_COMMAND;
            _loc3_.message = "*clear*";
            this.onChatMessageReceived.dispatch(_loc3_);
            _loc3_ = new ChatMessageData(param2,MESSAGE_TYPE_SYSTEM);
            _loc3_.posterNickName = USER_NAME_BAN;
            _loc3_.toNickName = this._userData.nickName;
            _loc3_.message = this._lang.getString(this.getBanTimeMin(this._banExpiration) > INDEFINITE_BAN_TIME ? "chat.user_tradeBan_indefinitely" : "chat.user_tradeBan_time");
            _loc3_.message = _loc3_.message.replace("%time",this.getBanTimeText(this._banExpiration));
            _loc3_.message = _loc3_.message.replace("%reason",this._banReason == "" ? "N/A" : this._banReason);
            this.onChatMessageReceived.dispatch(_loc3_);
         }
         return true;
      }
      
      private function getBanTimeMin(param1:Number) : int
      {
         return Math.floor((param1 - Network.getInstance().serverTime) / 1000 / 60);
      }
      
      private function getBanTimeText(param1:Number) : String
      {
         var _loc2_:Number = Math.floor((param1 - Network.getInstance().serverTime) / 1000);
         _loc2_ = Math.ceil(_loc2_ / 60) * 60;
         return DateTimeUtils.secondsToString(_loc2_,false,false);
      }
      
      private function onLevelUp(param1:Survivor, param2:int) : void
      {
         this.checkBuildingRequirements();
      }
      
      private function onBuildingStateChange(param1:Building) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Object = null;
         for each(_loc2_ in this._channelBuildRequirements)
         {
            for each(_loc3_ in _loc2_)
            {
               if(_loc3_.building == param1.type)
               {
                  this.checkBuildingRequirements();
                  return;
               }
            }
         }
      }
      
      private function checkBuildingRequirements() : void
      {
         var _loc1_:Boolean = false;
         var _loc3_:String = null;
         var _loc2_:Boolean = false;
         for(_loc3_ in this._channelBuildRequirements)
         {
            _loc1_ = Boolean(this._allowedChannels[_loc3_]);
            this._allowedChannels[_loc3_] = this.processMultipleBuildingStates(this._channelBuildRequirements[_loc3_]);
            if(_loc1_ != this._allowedChannels[_loc3_])
            {
               _loc2_ = true;
            }
         }
         if(_loc2_)
         {
            this.onAllowedChannelsChange.dispatch();
            this.checkPrivateConnection();
         }
      }
      
      private function processMultipleBuildingStates(param1:Array) : Boolean
      {
         var _loc3_:Object = null;
         var _loc2_:Boolean = true;
         for each(_loc3_ in param1)
         {
            if(_loc3_.building == "playerLevel")
            {
               if(this._playerData.getPlayerSurvivor().level < _loc3_.level)
               {
                  _loc2_ = false;
               }
            }
            else if(this.processBuildingStatus(_loc3_.building,_loc3_.level) == false)
            {
               _loc2_ = false;
            }
         }
         return _loc2_;
      }
      
      private function processBuildingStatus(param1:String, param2:int) : Boolean
      {
         var _loc5_:TimerData = null;
         var _loc3_:Vector.<Building> = this._buildings.getBuildingsOfType(param1);
         if(_loc3_.length == 0)
         {
            return false;
         }
         var _loc4_:Building = _loc3_[0];
         if(_loc4_ != null)
         {
            if(_loc4_.isUnderConstruction())
            {
               _loc5_ = _loc4_.upgradeTimer;
               if(_loc5_)
               {
                  _loc5_.completed.add(this.onBuildingTimerComplete);
               }
            }
            else if(_loc4_.level >= param2)
            {
               return true;
            }
         }
         return false;
      }
      
      private function onBuildingTimerComplete(param1:TimerData) : void
      {
         this.checkBuildingRequirements();
      }
      
      private function openExternalURL(param1:String) : void
      {
         if(Global.stage.displayState != StageDisplayState.NORMAL)
         {
            Global.stage.displayState == StageDisplayState.NORMAL;
         }
         navigateToURL(new URLRequest(param1),"_blank");
      }
      
      private function showHelp(param1:String) : void
      {
         var _loc2_:ChatMessageData = new ChatMessageData(param1,MESSAGE_TYPE_SYSTEM);
         _loc2_.posterNickName = USER_NAME_COMMAND;
         _loc2_.toNickName = this._userData.nickName;
         _loc2_.message = this._lang.getString("chat.help_message");
         this.onChatMessageReceived.dispatch(_loc2_);
      }
      
      private function displayRoomList(param1:String = "public") : void
      {
         var data:ChatMessageData = null;
         var uniqueId:int = 0;
         var channel:String = param1;
         switch(channel)
         {
            case CHANNEL_PUBLIC:
            case CHANNEL_TRADE_PUBLIC:
            case CHANNEL_RECRUITING:
               data = new ChatMessageData(channel,MESSAGE_TYPE_SYSTEM);
               data.posterNickName = USER_NAME_COMMAND;
               data.message = this._lang.getString("chat.gatheringRooms");
               this.onChatMessageReceived.dispatch(data);
               uniqueId = int(this.roomLookupId++);
               this.roomLookupResults[channel] = {
                  "id":uniqueId,
                  "list":[]
               };
               this._client.multiplayer.listRooms(RoomType.CHAT,{"NickName":this.getBalancedRoomNickname(channel)},1000,0,function(param1:Array):void
               {
                  roomLookupResults[channel].list = param1;
                  generateListRoomsMessage(channel,uniqueId);
               },function(param1:PlayerIOError):void
               {
                  generateListRoomsMessage(channel,uniqueId);
               });
               return;
            default:
               data = new ChatMessageData(channel,MESSAGE_TYPE_SYSTEM);
               data.posterNickName = USER_NAME_COMMAND;
               data.toNickName = this._userData.nickName;
               data.message = this._lang.getString("chat.listRoomsNotAvailable");
               this.onChatMessageReceived.dispatch(data);
               return;
         }
      }
      
      private function generateListRoomsMessage(param1:String, param2:uint) : void
      {
         if(this.roomLookupResults[param1] == null || this.roomLookupResults[param1].id != param2)
         {
            return;
         }
         this.generateGenericListRoomsMessage(param1);
      }
      
      private function generateGenericListRoomsMessage(param1:String) : void
      {
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Boolean = false;
         var _loc14_:Object = null;
         var _loc15_:ChatMessageData = null;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:String = null;
         var _loc19_:* = false;
         var _loc2_:* = "";
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         var _loc5_:Array = this.roomLookupResults[param1].list;
         var _loc6_:Boolean = this._playerData.isAdmin;
         var _loc7_:Array = [];
         var _loc11_:Array = [];
         var _loc12_:String = this.getBalancedRoomPrefix(param1);
         var _loc13_:int = int(Network.getInstance().playerData.getPlayerSurvivor().level);
         if(param1 == CHANNEL_TRADE_PUBLIC)
         {
            _loc11_.push({
               "name":_loc12_ + "Low",
               "count":3
            });
            if(_loc13_ >= 24)
            {
               _loc11_.push({
                  "name":_loc12_ + "High",
                  "count":3
               });
            }
         }
         else
         {
            _loc16_ = param1 == CHANNEL_PUBLIC ? 5 : 1;
            _loc11_.push({
               "name":_loc12_,
               "count":(param1 == CHANNEL_PUBLIC ? 5 : 1)
            });
            if(param1 == CHANNEL_PUBLIC && _loc13_ >= 49)
            {
               _loc11_.push({
                  "name":SERVICE_PREFIX + "Veterans",
                  "count":1
               });
            }
         }
         _loc8_ = 0;
         while(_loc8_ < _loc5_.length)
         {
            _loc10_ = false;
            _loc9_ = 0;
            while(_loc9_ < _loc11_.length)
            {
               if(_loc5_[_loc8_].id.indexOf(_loc11_[_loc9_].name) > -1)
               {
                  _loc10_ = true;
                  break;
               }
               _loc9_++;
            }
            if(_loc10_)
            {
               _loc7_.push(_loc5_[_loc8_]);
            }
            _loc8_++;
         }
         _loc8_ = 0;
         while(_loc8_ < _loc11_.length)
         {
            _loc9_ = 0;
            while(_loc9_ < _loc11_[_loc8_].count)
            {
               _loc10_ = false;
               _loc17_ = 0;
               while(_loc17_ < _loc7_.length)
               {
                  _loc18_ = _loc11_[_loc8_].name + _loc9_ + " " + _loc7_[_loc17_].id;
                  if(_loc11_[_loc8_].name + _loc9_ == _loc7_[_loc17_].id)
                  {
                     _loc10_ = true;
                     break;
                  }
                  _loc17_++;
               }
               if(!_loc10_)
               {
                  _loc7_.push({
                     "id":_loc11_[_loc8_].name + _loc9_,
                     "onlineUsers":0
                  });
               }
               _loc9_++;
            }
            _loc8_++;
         }
         _loc7_ = _loc7_.sortOn("id");
         for each(_loc14_ in _loc7_)
         {
            _loc19_ = _loc14_.onlineUsers > Config.constant.CHAT_PUBLIC_ROOM_SIZE_LIMIT - 10;
            if((_loc19_) && !_loc6_ || _loc14_.id == this.getChatRoomByChannel(param1).roomId)
            {
               _loc2_ += "\n" + _loc14_.id + " (" + (_loc19_ ? "full" : _loc14_.onlineUsers) + ")";
               if(_loc14_.id == this.getChatRoomByChannel(param1).roomId)
               {
                  _loc2_ += "   &lt;-- current";
               }
            }
            else
            {
               _loc2_ += "\n<a href=\'event:" + ChatLinkEvent.LT_JOINBALANCED + ":" + param1 + ":" + _loc14_.id + "\'>" + _loc14_.id + " (" + (_loc19_ ? "full" : _loc14_.onlineUsers) + ")</a>";
            }
            _loc3_++;
            _loc4_ += _loc14_.onlineUsers;
         }
         _loc15_ = new ChatMessageData(param1,MESSAGE_TYPE_SYSTEM);
         _loc15_.posterNickName = USER_NAME_COMMAND;
         _loc15_.toNickName = this._userData.nickName;
         _loc15_.message = "Room list - " + _loc3_ + " room(s) - " + _loc4_ + " users" + _loc2_;
         this.onChatMessageReceived.dispatch(_loc15_);
         delete this.roomLookupResults[param1];
      }
      
      private function joinParticularRoom(param1:String, param2:String) : void
      {
         var _loc3_:ChatRoom = this.getChatRoomByChannel(param1);
         _loc3_.join(param2);
      }
      
      public function sendAllianceInviteResponse(param1:String, param2:int, param3:String) : void
      {
         this.sendDirectCommand(param1,COMMAND_ALLIANCE_FEEDBACK,param2,param3);
      }
      
      private function sendAllianceInvitation(param1:String, param2:String) : void
      {
         var coolDown:int;
         var clientAllianceMember:AllianceMember;
         var errMsg:String;
         var otherUser:ChatUserData;
         var data:ChatMessageData = null;
         var toNickName:String = param1;
         var channel:String = param2;
         if(toNickName == this._userData.nickName)
         {
            return;
         }
         coolDown = 30 * 1000 - (getTimer() - this._lastAllianceInviteTimestamp);
         if(coolDown > 0)
         {
            data = new ChatMessageData(channel,ChatSystem.MESSAGE_TYPE_ALLIANCE_FEEDBACK);
            data.posterNickName = ChatSystem.USER_NAME_NOTHING;
            data.toNickName = Network.getInstance().chatSystem.userData.nickName;
            data.message = this._lang.getString("chat.alliance_invite_cooldown",Math.ceil(coolDown / 1000));
            this.onChatMessageReceived.dispatch(data);
            return;
         }
         clientAllianceMember = AllianceSystem.getInstance().clientMember;
         if(clientAllianceMember == null)
         {
            return;
         }
         errMsg = "";
         otherUser = this.extractUserData(toNickName);
         if(otherUser == null || !otherUser.online)
         {
            errMsg = this._lang.getString("alliance.chat_not_online");
         }
         else if(this._playerData.allianceId == null)
         {
            errMsg = this._lang.getString("alliance.chat_not_a_member");
         }
         else if(clientAllianceMember.rank < AllianceRank.RANK_7)
         {
            errMsg = this._lang.getString("alliance.chat_insufficient_privileges",toNickName);
         }
         else if(!AllianceSystem.getInstance().alliancesEnabled)
         {
            errMsg = this._lang.getString("alliance.chat_disabled");
         }
         else if(AllianceSystem.getInstance().alliance.members.numMembers >= int(Config.xml.ALLIANCE_MEMBER_MAX_COUNT))
         {
            errMsg = this._lang.getString("alliance.chat_alliance_full",toNickName);
         }
         else if(otherUser.allianceId != "")
         {
            errMsg = this._lang.getString("alliance.chat_other_already_aligned",toNickName);
         }
         if(errMsg == "" && otherUser.level < int(Config.constant.ALLIANCE_MIN_JOIN_LEVEL))
         {
            errMsg = this._lang.getString("alliance.chat_level_not_high_enough",toNickName);
         }
         if(errMsg != "")
         {
            data = new ChatMessageData(channel,ChatSystem.MESSAGE_TYPE_ALLIANCE_FEEDBACK);
            data.posterNickName = ChatSystem.USER_NAME_NOTHING;
            data.toNickName = Network.getInstance().chatSystem.userData.nickName;
            data.message = errMsg;
            this.onChatMessageReceived.dispatch(data);
            return;
         }
         data = new ChatMessageData(channel,ChatSystem.MESSAGE_TYPE_ALLIANCE_FEEDBACK);
         data.posterNickName = ChatSystem.USER_NAME_NOTHING;
         data.toNickName = Network.getInstance().chatSystem.userData.nickName;
         data.message = this._lang.getString("alliance.chat_inviteSent",toNickName);
         this.onChatMessageReceived.dispatch(data);
         this._allianceSystem.inviteMember(otherUser.userId,function(param1:RPCResponse):void
         {
            var _loc2_:AllianceData = null;
            var _loc3_:String = null;
            if(param1.success)
            {
               _loc2_ = AllianceSystem.getInstance().alliance;
               _loc3_ = _loc2_.banner.hexString.replace("0x","");
               sendDirectCommand(toNickName,COMMAND_ALLIANCE_INVITE,_loc2_.id,_loc2_.tag,_loc3_,channel);
               _lastAllianceInviteTimestamp = getTimer();
            }
         });
      }
      
      private function handleAllianceInviteReceived(param1:String, param2:String, param3:String, param4:String, param5:String) : void
      {
         var _loc6_:int = 1;
         if(!AllianceSystem.getInstance().buildingRequirementsMet)
         {
            _loc6_ = -1;
         }
         else if(AllianceSystem.getInstance().inAlliance)
         {
            _loc6_ = -2;
         }
         if(_loc6_ != 1)
         {
            this.sendDirectCommand(param1,COMMAND_ALLIANCE_FEEDBACK,_loc6_,param5);
            return;
         }
         var _loc7_:ChatMessageData = new ChatMessageData(ChatSystem.CHANNEL_ALL,ChatSystem.MESSAGE_TYPE_SYSTEM);
         _loc7_.posterNickName = USER_NAME_NOTHING;
         _loc7_.toNickName = this._userData.nickName;
         _loc7_.message = this._lang.getString("chat.alliance_invite_msg","<a href=\'event:" + ChatLinkEvent.LT_USERMENU + ":" + param1 + ":0\'>" + param1 + "</a> [<a href=\'event:" + ChatLinkEvent.LT_ALLIANCE_SHOW + ":" + param2 + "\'>" + param3 + "</a>]");
         this.onChatMessageReceived.dispatch(_loc7_);
         _loc7_ = new ChatMessageData(ChatSystem.CHANNEL_ALL,ChatSystem.MESSAGE_TYPE_ALLIANCE_INVITE);
         _loc7_.posterNickName = param1;
         _loc7_.posterAllianceId = param2;
         _loc7_.posterAllianceTag = param3;
         _loc7_.linkData = [param4,param5];
         this.onChatMessageReceived.dispatch(_loc7_);
      }
      
      private function handleAllianceInviteResponse(param1:String, param2:int, param3:String) : void
      {
         var _loc4_:String = "";
         switch(param2)
         {
            case 2:
               _loc4_ = this._lang.getString("alliance.chat_acceptedInvitation",param1);
               break;
            case 1:
               _loc4_ = this._lang.getString("alliance.chat_reviewingInvitation",param1);
               break;
            case 0:
               _loc4_ = this._lang.getString("alliance.chat_rejectedInvitation",param1);
               break;
            case -1:
               _loc4_ = this._lang.getString("alliance.chat_missing_building",param1);
               break;
            case -2:
               _loc4_ = this._lang.getString("alliance.chat_other_already_aligned",param1);
               break;
            case -3:
               _loc4_ = this._lang.getString("alliance.chat_inviteAllianceFull",param1);
         }
         if(_loc4_ == "")
         {
            return;
         }
         var _loc5_:ChatMessageData = new ChatMessageData(param3,ChatSystem.MESSAGE_TYPE_ALLIANCE_FEEDBACK);
         _loc5_.posterNickName = ChatSystem.USER_NAME_NOTHING;
         _loc5_.message = _loc4_;
         this.onChatMessageReceived.dispatch(_loc5_);
      }
      
      private function catchTradeRequest(param1:String, param2:String) : void
      {
         var _loc3_:ChatMessageData = null;
         var _loc5_:InventoryFullDialogue = null;
         if(param1 == this._userData.nickName || param1 == MISSING_USER_NICKNAME)
         {
            return;
         }
         if(this.testKickedBan(true,param2) || this.testSilencedBan(true,param2) || this.testTradeBan(true,param2))
         {
            return;
         }
         if(Network.getInstance().shutdownMissionsLocked || Settings.getInstance().tradeEnabled == false && !Network.getInstance().playerData.isAdmin)
         {
            _loc3_ = new ChatMessageData(param2,MESSAGE_TYPE_SYSTEM);
            _loc3_.posterNickName = USER_NAME_NOTHING;
            _loc3_.toNickName = this._userData.nickName;
            _loc3_.message = this._lang.getString("trade.tradeDisabled");
            this.onChatMessageReceived.dispatch(_loc3_);
            return;
         }
         var _loc4_:int = TradeSystem.getInstance().attemptToStartTrade(param1);
         if(_loc4_ < 0)
         {
            switch(_loc4_)
            {
               case TradeSystem.CANCEL_FULL_INVENTORY:
                  _loc5_ = new InventoryFullDialogue(InventoryFullDialogue.TRADE_FULL);
                  _loc5_.open();
                  break;
               default:
                  _loc3_ = new ChatMessageData(param2,MESSAGE_TYPE_SYSTEM);
                  _loc3_.posterNickName = USER_NAME_NOTHING;
                  _loc3_.toNickName = this._userData.nickName;
                  _loc3_.message = this._lang.getString(_loc4_ == TradeSystem.CANCEL_ZOMBIE_ATTACK ? "trade.zombieAttack" : "trade.alreadyInProgress");
                  this.onChatMessageReceived.dispatch(_loc3_);
            }
         }
      }
      
      public function get isTradeAllowed() : Boolean
      {
         return TradeSystem.getInstance().isTradeAllowed && !this.testTradeBan(false,CHANNEL_ALL);
      }
      
      public function get lastPrivateMsgSender() : String
      {
         return this._lastPrivateMsgSender;
      }
      
      public function displayTradeRequestInChat(param1:String, param2:String, param3:String) : void
      {
         if(this.testSilencedBan(false,CHANNEL_PUBLIC) || this.testKickedBan(false,CHANNEL_PUBLIC) || this.testTradeBan(false,CHANNEL_TRADE_PUBLIC))
         {
            return;
         }
         var _loc4_:ChatMessageData = new ChatMessageData(CHANNEL_ALL,MESSAGE_TYPE_TRADE_REQUEST);
         _loc4_.posterNickName = param1;
         _loc4_.posterAllianceId = param2;
         _loc4_.posterAllianceTag = param3;
         _loc4_.toNickName = this._userData.nickName;
         _loc4_.message = "Trade Request from " + param1;
         this.onChatMessageReceived.dispatch(_loc4_);
      }
      
      public function openCommentReportWindow(param1:String, param2:String, param3:String, param4:Object) : void
      {
         if(!(param4 is UIChatMessageList))
         {
            return;
         }
         var _loc5_:UIChatMessageList = UIChatMessageList(param4);
         var _loc6_:IChatMessageDisplayData = _loc5_.findMessageByUniqueId(param3);
         if(_loc6_ == null)
         {
            return;
         }
         var _loc7_:ChatUserData = this.extractUserData(_loc6_.nickName);
         if(_loc7_ == null)
         {
            return;
         }
         var _loc8_:String = "";
         if(_loc6_.messageData.messageType == MESSAGE_TYPE_PRIVATE)
         {
            _loc8_ = _loc5_.ContentsToString();
         }
         var _loc9_:ChatCommentReportDialogue = new ChatCommentReportDialogue(_loc7_,_loc6_,param2,_loc8_);
         _loc9_.open();
      }
      
      private function adminRecapUser(param1:String, param2:String) : void
      {
         var _loc3_:ChatMessageData = new ChatMessageData(param1,MESSAGE_TYPE_SYSTEM);
         _loc3_.posterNickName = USER_NAME_COMMAND;
         _loc3_.toNickName = param2;
         _loc3_.message = "*recap*";
         this.onChatMessageReceived.dispatch(_loc3_);
      }
      
      private function adminPushPull(param1:String, param2:String, param3:Boolean) : void
      {
         if(param3 && this._roomAdmin.status == STATUS_DISCONNECTED)
         {
            this.connect(CHANNEL_ADMIN);
         }
         var _loc4_:ChatMessageData = new ChatMessageData(param1,MESSAGE_TYPE_SYSTEM);
         _loc4_.posterNickName = USER_NAME_COMMAND;
         _loc4_.toNickName = param2;
         _loc4_.message = param3 ? "Asking " + param2 + " to join the admin room" : "Pushing " + param2 + " out of the admin room";
         this.onChatMessageReceived.dispatch(_loc4_);
         if(param3)
         {
            this.sendDirectCommand(param2,COMMAND_ADMIN_PULLIN);
         }
         else
         {
            this._roomAdmin.disconnectUser(param2);
         }
      }
      
      private function adminLockUnlock(param1:String, param2:Boolean) : void
      {
         var _loc3_:ChatRoom = this.getChatRoomByChannel(param1);
         if(_loc3_ == null)
         {
            return;
         }
         _loc3_.adminLockUnlock(param2);
      }
      
      private function adminListUsers(param1:String) : void
      {
         var msg:String;
         var sorted:Vector.<ChatUserData>;
         var i:int;
         var data:ChatMessageData;
         var channel:String = param1;
         var room:ChatRoom = this.getChatRoomByChannel(channel);
         if(room == null)
         {
            return;
         }
         msg = "Listing all users";
         sorted = room.allUsers.sort(function(param1:ChatUserData, param2:ChatUserData):int
         {
            if(param1.nickName.toLowerCase() < param2.nickName.toLowerCase())
            {
               return -1;
            }
            if(param1.nickName == param2.nickName)
            {
               return 0;
            }
            return 1;
         });
         i = 0;
         while(i < room.allUsers.length)
         {
            if(room.allUsers[i].nickName != this._userData.nickName)
            {
               msg += "\n<a href=\'event:" + ChatLinkEvent.LT_USERMENU + ":" + room.allUsers[i].nickName + ":0\'>" + room.allUsers[i].nickName + " (" + room.allUsers[i].level + ")</a>";
               if(room.allUsers[i].allianceId)
               {
                  msg += " <a href=\'event:" + ChatLinkEvent.LT_ALLIANCE_SHOW + ":" + room.allUsers[i].allianceId + ":0\'>[" + room.allUsers[i].allianceTag + "]</a>";
               }
            }
            i++;
         }
         msg += "\nTotal: " + room.allUsers.length + " (including you)";
         data = new ChatMessageData(channel,MESSAGE_TYPE_SYSTEM);
         data.posterNickName = USER_NAME_COMMAND;
         data.toNickName = this._userData.nickName;
         data.message = msg;
         this.onChatMessageReceived.dispatch(data);
      }
      
      private function adminDisplayPayvaultLink(param1:String, param2:String) : void
      {
         var _loc3_:ChatMessageData = null;
         var _loc4_:ChatUserData = this.extractUserData(param1);
         if(_loc4_ == null)
         {
            _loc3_ = new ChatMessageData(param2,MESSAGE_TYPE_SYSTEM);
            _loc3_.posterNickName = USER_NAME_ERROR;
            _loc3_.toNickName = this._userData.nickName;
            _loc3_.message = "Details for requested nickname were not found. Sorry. (" + param1 + ")";
            this.onChatMessageReceived.dispatch(_loc3_);
            return;
         }
         _loc3_ = new ChatMessageData(param2,MESSAGE_TYPE_SYSTEM);
         _loc3_.posterNickName = USER_NAME_COMMAND;
         _loc3_.toNickName = this._userData.nickName;
         _loc3_.message = "Details found - opening payvault. (" + param1 + ", " + _loc4_.userId + ")";
         this.onChatMessageReceived.dispatch(_loc3_);
         var _loc5_:String = _loc4_.userId.replace(/_/ig," ");
         this.openExternalURL(Settings.getInstance().payvaultURL + _loc5_);
      }
      
      private function doKickSilence(param1:String, param2:String, param3:String, param4:String) : void
      {
         var _loc10_:Array = null;
         var _loc11_:int = 0;
         var _loc12_:ChatUserData = null;
         var _loc5_:int = 5;
         var _loc6_:String = "N/A";
         if(param2 != "")
         {
            _loc10_ = param2.split(" ");
            if(_loc10_.length > 0)
            {
               _loc11_ = parseInt(_loc10_[0]);
               if(isNaN(_loc11_) == false)
               {
                  _loc5_ = _loc11_;
               }
               _loc10_.shift();
            }
            if(_loc10_.length > 0)
            {
               _loc6_ = _loc10_.join(" ");
            }
         }
         var _loc7_:Object = [];
         switch(param4)
         {
            case COMMAND_ADMIN_STRIKE:
               _loc7_[0] = "Striking";
               _loc7_[1] = "strike";
               break;
            case COMMAND_ADMIN_TRADEBAN:
               _loc7_[0] = "Trade Banning";
               _loc7_[1] = "trade ban";
               break;
            case COMMAND_ADMIN_KICKSILENTLY:
               _loc7_[0] = "Ninja Kicking";
               _loc7_[1] = "ninja kick";
               break;
            case COMMAND_ADMIN_KICK:
               _loc7_[0] = "Kicking";
               _loc7_[1] = "kick";
               break;
            case COMMAND_ADMIN_SILENCE:
            default:
               _loc7_[0] = "Silencing";
               _loc7_[1] = "silence";
         }
         var _loc8_:ChatMessageData = new ChatMessageData(param3,MESSAGE_TYPE_SYSTEM);
         _loc8_.posterNickName = USER_NAME_COMMAND;
         _loc8_.message = _loc7_[0] + " user " + param1 + " for " + _loc5_ + " min(s) - Reason: " + _loc6_;
         this.onChatMessageReceived.dispatch(_loc8_);
         var _loc9_:ChatRoom = this.getChatRoomByChannel(param3);
         if(_loc9_.status == STATUS_CONNECTED)
         {
            _loc12_ = _loc9_.getUserByNickName(param1);
            if(_loc12_ != null && _loc12_.online)
            {
               _loc9_.sendAdminCommand(param4,param1,_loc12_.userId,_loc5_,_loc6_);
               return;
            }
         }
         _loc8_ = new ChatMessageData(param3,MESSAGE_TYPE_SYSTEM);
         _loc8_.posterNickName = USER_NAME_WARNING;
         _loc8_.message = String(_loc7_[1]).toUpperCase() + " FAILED for user " + param1 + " - They must have left the room before the " + _loc7_[1] + " could be done";
         this.onChatMessageReceived.dispatch(_loc8_);
      }
      
      public function adminCheckIfInAdminRoom(param1:String) : Boolean
      {
         var _loc2_:ChatUserData = this._roomAdmin.getUserByNickName(param1);
         if(_loc2_ == null || _loc2_.online == false)
         {
            return false;
         }
         return true;
      }
      
      private function adminChangeAlliance(param1:String) : void
      {
         var allianceString:String = param1;
         if(allianceString.replace(" ","") == "")
         {
            return;
         }
         if(this._roomAlliance.status != ChatSystem.STATUS_DISCONNECTED)
         {
            this._roomAlliance.disconnect();
         }
         AllianceSystem.getInstance().parseAllianceString(allianceString,function(param1:String):void
         {
            _roomAlliance.createJoin(SERVICE_PREFIX + param1,SERVICE_PREFIX + param1,RoomType.CHAT,{"AutoClose":false},true);
         });
      }
      
      private function onChatUserMenuClick(param1:ChatUserMenuEvent) : void
      {
         switch(param1.command)
         {
            case ChatUserMenuEvent.CMD_MUTE:
               this.addToMuteList(param1.data[0],param1.data[1]);
               break;
            case ChatUserMenuEvent.CMD_UNMUTE:
               this.removeFromMuteList(param1.data[0],param1.data[1]);
               break;
            case ChatUserMenuEvent.CMD_BLOCK:
               this.addToBlockList(param1.data[0],param1.data[1]);
               break;
            case ChatUserMenuEvent.CMD_UNBLOCK:
               this.removeFromBlockList(param1.data[0],param1.data[1]);
               break;
            case ChatUserMenuEvent.CMD_ADD_CONTACT:
               this.addToContactList(param1.data[0],param1.data[1]);
               break;
            case ChatUserMenuEvent.CMD_REMOVE_CONTACT:
               this.removeFromContactList(param1.data[0],param1.data[1]);
               break;
            case ChatUserMenuEvent.CMD_PAYVAULT:
               this.adminDisplayPayvaultLink(param1.data[0],param1.data[1]);
               break;
            case ChatUserMenuEvent.CMD_RECAP:
               this.adminRecapUser(param1.data[1],param1.data[0]);
               break;
            case ChatUserMenuEvent.CMD_PUSHPULL:
               this.adminPushPull(param1.data[0],param1.data[1],param1.data[2]);
               break;
            case ChatUserMenuEvent.CMD_TRADE:
               this.catchTradeRequest(param1.data[0],param1.data[1]);
               break;
            case ChatUserMenuEvent.CMD_INVITE:
               this.sendAllianceInvitation(param1.data[0],param1.data[1]);
               break;
            case ChatUserMenuEvent.CMD_REPORT:
               this.openCommentReportWindow(param1.data[0],param1.data[1],param1.data[2],param1.data[3]);
         }
      }
      
      private function onChatOptionsMenuClick(param1:ChatOptionsMenuEvent) : void
      {
         switch(param1.command)
         {
            case ChatOptionsMenuEvent.CMD_LISTROOMS:
               this.displayRoomList(param1.data[0]);
               break;
            case ChatOptionsMenuEvent.CMD_CONTACTS:
               this.listContacts(param1.data[0]);
               break;
            case ChatOptionsMenuEvent.CMD_BLOCKED:
               this.listBlockedAndMutedUsers(param1.data[0]);
               break;
            case ChatOptionsMenuEvent.CMD_HELP:
               this.showHelp(param1.data[0]);
               break;
            case ChatOptionsMenuEvent.CMD_INSERT_WAR_STATS:
         }
      }
      
      private function onChatLinkClick(param1:ChatLinkEvent) : void
      {
         var _loc2_:String = null;
         switch(param1.linkType)
         {
            case ChatLinkEvent.LT_JOINBALANCED:
               this.joinBalancedRoom(param1.data[0],param1.data[1]);
               break;
            case ChatLinkEvent.LT_JOIN:
               this.joinParticularRoom(param1.data[0],param1.data[1]);
               break;
            case ChatLinkEvent.LT_HYPERLINK:
               _loc2_ = param1.data;
               if(_loc2_.indexOf("http://") == -1)
               {
                  _loc2_ = "http://" + _loc2_;
               }
               this.openExternalURL(_loc2_);
         }
      }
   }
}

class ParsedMessageData
{
   
   public var command:String = "";
   
   public var message:String = "";
   
   public var nickName:String = "";
   
   public var linkData:Array;
   
   public var messageType:String;
   
   public var channel:String;
   
   public function ParsedMessageData()
   {
      super();
   }
}
