package thelaststand.app.network
{
   import com.adobe.crypto.MD5;
   import com.dynamicflash.util.Base64;
   import com.gskinner.utils.SWFBridgeAS3;
   import com.junkbyte.console.Cc;
   import com.probertson.utils.GZIPBytesEncoder;
   import flash.display.StageDisplayState;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.system.Capabilities;
   import flash.system.System;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.Endian;
   import flash.utils.Timer;
   import flash.utils.describeType;
   import org.osflash.signals.Signal;
   import playerio.Client;
   import playerio.Connection;
   import playerio.DatabaseObject;
   import playerio.Message;
   import playerio.PlayerIOError;
   import playerio.facebook.FB;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Global;
   import thelaststand.app.core.Settings;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.NewsArticle;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.data.PlayerFlags;
   import thelaststand.app.game.data.Attributes;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.DamageType;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.Gender;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemAttributes;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorClass;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.data.WeaponData;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.data.bounty.InfectedBounty;
   import thelaststand.app.game.data.notification.NotificationFactory;
   import thelaststand.app.game.data.notification.NotificationType;
   import thelaststand.app.game.data.quests.DynamicQuest;
   import thelaststand.app.game.entities.light.SunLight;
   import thelaststand.app.game.gui.chat.masterpanel.ChatMasterPanel;
   import thelaststand.app.game.gui.dialogues.BountyAddDialogue;
   import thelaststand.app.game.gui.dialogues.DailyQuestDialogue;
   import thelaststand.app.game.gui.dialogues.PromoCodeDialogue;
   import thelaststand.app.game.logic.GlobalQuestSystem;
   import thelaststand.app.game.logic.NotificationSystem;
   import thelaststand.app.game.logic.QuestSystem;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.chat.ChatSystem;
   import thelaststand.app.network.users.AbstractUser;
   import thelaststand.app.network.users.FacebookUser;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.error.CustomError;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.common.resources.formats.GZipHandler;
   
   public class Network
   {
      
      private static var _instance:Network;
      
      private var PLAYERIO_CONN_ID:String = "";
      
      private var PLAYERIO_GAME_ID:String = "";
      
      private var LOGGER_URL:String = "";
      
      private var CONNECT_TIMEOUT:int = 30;
      
      private var _connector:PlayerIOConnector;
      
      private var _client:Client;
      
      private var _costTableReady:Boolean;
      
      private var _connected:Boolean;
      
      private var _connection:Connection;
      
      private var _connectionStep:int = 0;
      
      private var _numConnectionSteps:int = 6;
      
      private var _loadingStep:int = 0;
      
      private var _numLoadingSteps:int = 4;
      
      private var _gameReady:Boolean;
      
      private var _data:NetworkData;
      
      private var _playerData:PlayerData;
      
      private var _facebookAccessToken:String;
      
      private var _facebookUserId:String;
      
      private var _serverTime:Number = 0;
      
      private var _sentMessageIds:Array = [];
      
      private var _saveMessageIds:Array = [];
      
      private var _messageCallbacksById:Dictionary;
      
      private var _locked:Boolean;
      
      private var _lockMessageIds:Array = [];
      
      private var _nextMessageId:int = 0;
      
      private var _loginPlayerState:Object;
      
      private var _loginFlags:LoginFlags;
      
      private var _connectTimeout:Timer;
      
      private var _serverActive:Boolean = true;
      
      private var _serverUpdated:Boolean = false;
      
      private var _joinedRoom:Boolean = false;
      
      private var _outOfSync:Boolean = false;
      
      private var _chatSystem:ChatSystem;
      
      private var _broadcastSystem:BroadcastSystem;
      
      private var _asyncOpCount:int;
      
      private var _chatCommander:ChatMasterPanel;
      
      private var _shutdownInEffect:Boolean;
      
      private var _shutdownMissionsLocked:Boolean;
      
      private var _lcBridge:SWFBridgeAS3;
      
      public var devServer:String;
      
      public var currentStatus:String;
      
      public var connected:Signal;
      
      public var connectOpened:Signal;
      
      public var connectError:Signal;
      
      public var connectProgress:Signal;
      
      public var serverInitProgress:Signal;
      
      public var loadingProgress:Signal;
      
      public var disconnected:Signal;
      
      public var gameReady:Signal;
      
      public var loginFailed:Signal;
      
      public var stateSaveStarted:Signal;
      
      public var stateSaveCompleted:Signal;
      
      public var outOfSync:Signal;
      
      public var locked:Signal;
      
      public var unlocked:Signal;
      
      public var settingsChanged:Signal;
      
      public var gameDataReceived:Signal;
      
      public var asyncOpsCompleted:Signal;
      
      public var onShutdownInEffectChange:Signal;
      
      public var onShutdownMissionsLockChange:Signal;
      
      public var onRPC:Signal;
      
      private var AHSrvs:Vector.<Survivor>;
      
      public function Network(param1:NetworkSingletonEnforcer)
      {
         super();
         if(!param1)
         {
            Cc.logch("load","Network Singleton Error: Attempted direct instantiation");
            throw new Error("Network is a Singleton and cannot be directly instantiated. Use Network.getInstance().");
         }
         Cc.logch("load","Network: Initializing singleton");
         this._playerData = new PlayerData();
         this._playerData.flags.changed.add(this.onPlayerFlagChanged);
         this._data = new NetworkData();
         this._loginFlags = new LoginFlags();
         this._messageCallbacksById = new Dictionary(true);
         var _loc2_:int = this.CONNECT_TIMEOUT * 1000;
         this._connectTimeout = new Timer(_loc2_,1);
         this._connectTimeout.addEventListener(TimerEvent.TIMER_COMPLETE,this.onConnectTimeout);
         this.connected = new Signal();
         this.connectOpened = new Signal();
         this.connectError = new Signal(String);
         this.connectProgress = new Signal(Number);
         this.serverInitProgress = new Signal(Number);
         this.loadingProgress = new Signal(Number);
         this.disconnected = new Signal();
         this.stateSaveStarted = new Signal();
         this.stateSaveCompleted = new Signal();
         this.outOfSync = new Signal();
         this.locked = new Signal();
         this.unlocked = new Signal();
         this.gameReady = new Signal();
         this.loginFailed = new Signal(String);
         this.settingsChanged = new Signal();
         this.gameDataReceived = new Signal();
         this.asyncOpsCompleted = new Signal();
         this.onShutdownInEffectChange = new Signal(Boolean);
         this.onShutdownMissionsLockChange = new Signal(Boolean);
         this.onRPC = new Signal(RPC);
         this.PLAYERIO_GAME_ID = Config.xml.playerio.game_id.toString();
         this.PLAYERIO_CONN_ID = Config.xml.playerio.conn_id.toString();
         this.LOGGER_URL = Config.getPath("logger_url");
         Cc.logch("load","Network: Initialization complete, Game ID: " + this.PLAYERIO_GAME_ID);
      }
      
      public static function getInstance() : Network
      {
         if(_instance == null)
         {
            Cc.logch("load","Network: Creating singleton instance");
         }
         return _instance || (_instance = new Network(new NetworkSingletonEnforcer()));
      }
      
      public function log(msg:String) : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("console.log",msg);
         }
         else
         {
            trace(msg);
         }
      }
      
      public function connect() : void
      {
         if(this._connected)
         {
            Cc.logch("load","Connect: Already connected, skipping");
            return;
         }
         Cc.logch("load","Connect: Starting connection process");
         this._connector = PlayerIOConnector.getInstance();
         this._client = this._connector.client;
         this._connectTimeout.stop();
         this._joinedRoom = false;
         ResourceManager.getInstance().resourceLoadFailed.add(this.onResourceLoadFail);
         if(this.devServer != null)
         {
            this._client.multiplayer.developmentServer = this.devServer;
            Cc.logch("load","Connect: Using development server: " + this.devServer);
         }
         this._chatSystem = new ChatSystem(this._client);
         this._broadcastSystem = new BroadcastSystem();
         this.currentStatus = "Retrieving your profile";
         this.connectProgress.dispatch((this._connectionStep = 0) / this._numConnectionSteps);
         Cc.logch("load","Connect: Retrieving profile, progress: " + (this._connectionStep / this._numConnectionSteps * 100).toFixed(2) + "%");
         if(this._connector.service == PlayerIOConnector.SERVICE_FACEBOOK)
         {
            Cc.logch("load","Connect: Initializing Facebook with access token");
            FB.init({
               "access_token":FacebookUser(this._connector.user).accessToken,
               "debug":false
            });
         }
         this._connector.user.loaded.addOnce(function():void
         {
            Cc.logch("load","Connect: User data loaded, starting room join");
            _connectTimeout.reset();
            _connectTimeout.start();
            joinRoom(_connector.user.getJoinData());
         });
         this._connector.user.loadFailed.addOnce(this.onNetworkError);
         Cc.logch("load","Connect: Initiating user data load");
         this._connector.user.load();
      }
      
      public function disconnect() : void
      {
         Cc.logch("load","Disconnect: Starting disconnection process");
         if(this._connection != null)
         {
            Cc.logch("load","Disconnect: Disconnecting connection");
            this._connection.disconnect();
         }
         Cc.logch("load","Disconnect: Stopping connect timeout");
         this._connectTimeout.stop();
         this.onServerDisconnected();
         Cc.logch("load","Disconnect: Server disconnected handler called");
      }
      
      public function startAsyncOp() : void
      {
         ++this._asyncOpCount;
         Cc.logch("load","Async Op: Started, count: " + this._asyncOpCount);
      }
      
      public function completeAsyncOp() : void
      {
         var _loc1_:int = this._asyncOpCount;
         --this._asyncOpCount;
         Cc.logch("load","Async Op: Completed, count: " + this._asyncOpCount);
         if(this._asyncOpCount <= 0)
         {
            this._asyncOpCount = 0;
            if(this._asyncOpCount != _loc1_)
            {
               this.asyncOpsCompleted.dispatch();
               Cc.logch("load","Async Op: All operations completed, dispatched signal");
            }
         }
      }
      
      public function forwardRPC(param1:Connection, param2:Message) : void
      {
         Cc.logch("load","Forward RPC: Processing message type: " + param2.type);
         var _loc3_:Connection = null;
         var _loc4_:int = 0;
         if(param2.type != "rpc" && param2.type != "rpcr")
         {
            Cc.logch("load","Forward RPC: Invalid message type, skipping");
            return;
         }
         switch(param2.getInt(1))
         {
            case RPCDestination.AllianceServer:
               _loc3_ = AllianceSystem.getInstance().connection;
               Cc.logch("load","Forward RPC: Destination AllianceServer");
               break;
            case RPCDestination.GameServer:
               _loc3_ = this._connection;
               Cc.logch("load","Forward RPC: Destination GameServer");
         }
         var _loc5_:uint = uint(param2.getInt(_loc4_++));
         var _loc6_:uint = uint(param2.getInt(_loc4_++));
         var _loc7_:int = param2.getInt(_loc4_++);
         var _loc8_:String = param2.getString(_loc4_++);
         if(_loc3_ == null || !_loc3_.connected)
         {
            Cc.logch("load","Forward RPC: No valid connection, sending error response");
            if(param1 != null && param1.connected)
            {
               param1.send(NetworkMessage.RPC_RESPONSE,_loc6_,_loc5_,_loc7_,_loc8_,false);
            }
            return;
         }
         var _loc9_:Message = _loc3_.createMessage(param2.type,_loc5_,_loc6_,_loc7_,_loc8_);
         if(param2.type == "rpcr")
         {
            _loc9_.add(param2.getBoolean(_loc4_++));
         }
         if(param2.length > _loc4_)
         {
            _loc9_.add(param2.getString(_loc4_++));
         }
         _loc3_.sendMessage(_loc9_);
         Cc.logch("load","Forward RPC: Sent message to destination");
      }
      
      public function sendRPCResponse(param1:RPCResponse) : void
      {
         Cc.logch("load","Send RPC Response: Processing response to: " + param1.to);
         var _loc2_:Connection = null;
         switch(param1.to)
         {
            case RPCDestination.AllianceServer:
               _loc2_ = AllianceSystem.getInstance().connection;
               Cc.logch("load","Send RPC Response: Destination AllianceServer");
               break;
            case RPCDestination.GameServer:
               _loc2_ = this._connection;
               Cc.logch("load","Send RPC Response: Destination GameServer");
         }
         if(_loc2_ == null || !_loc2_.connected)
         {
            Cc.logch("load","Send RPC Response: No valid connection, skipping");
            return;
         }
         var _loc3_:Message = _loc2_.createMessage("rpcr",param1.from,param1.to,param1.id,param1.type,param1.success);
         if(param1.data != null)
         {
            _loc3_.add(JSON.stringify(param1.data));
            Cc.logch("load","Send RPC Response: Added data to message");
         }
         _loc2_.sendMessage(_loc3_);
         Cc.logch("load","Send RPC Response: Sent message");
      }
      
      public function send(param1:String, param2:Object = null, param3:Function = null, param4:Boolean = false) : Boolean
      {
         if(!this._connected || !this._connection || this._outOfSync)
         {
            Cc.logch("load","Send Error: Cannot send message, not connected or out of sync");
            this.throwSyncError();
            return false;
         }
         Cc.logch("load","Send: Preparing message " + param1 + " with ID m" + this._nextMessageId);
         if(param2 != null && param2 is Array)
         {
            Cc.logch("load","Send: Converting array to object for message data");
            param2 = {"list":param2};
         }
         var _loc5_:String = "m" + this._nextMessageId++;
         var _loc6_:Object = {"id":_loc5_};
         if(param2 != null)
         {
            Cc.logch("load","Send: Adding data to message " + _loc5_);
            _loc6_.data = param2;
         }
         this._messageCallbacksById[_loc5_] = param3;
         this._sentMessageIds.push(_loc5_);
         if(param1 == NetworkMessage.SAVE)
         {
            Cc.logch("load","Send: Marking message " + _loc5_ + " as save message");
            this._saveMessageIds.push(_loc5_);
         }
         if(param4)
         {
            Cc.logch("load","Send: Locking, message " + _loc5_ + " requires lock");
            this._locked = true;
            this._lockMessageIds.push(_loc5_);
            this.locked.dispatch();
            Cc.logch("load","Send: Dispatched locked signal for message " + _loc5_);
         }
         Cc.logch("load","Send: Sending message " + param1 + " with ID " + _loc5_);
         this._connection.send(param1,JSON.stringify(_loc6_));
         return true;
      }
      
      public function save(param1:Object, param2:String, param3:Function = null, param4:Boolean = false) : void
      {
         if(param1 is Array)
         {
            param1 = {"list":param1};
         }
         else
         {
            param1 ||= {};
         }
         param1._type = param2;
         if(this.send(NetworkMessage.SAVE,param1,param3,param4))
         {
            this.stateSaveStarted.dispatch();
         }
      }
      
      public function throwSyncError() : void
      {
         this.disconnectSilent();
         if(this._outOfSync)
         {
            return;
         }
         Cc.fatalch("network","Out of sync");
         this._outOfSync = true;
         this.outOfSync.dispatch();
      }
      
      public function share(param1:String, param2:String, param3:String, param4:String, param5:String = null) : void
      {
         var shareData:Object;
         var title:String = param1;
         var caption:String = param2;
         var description:String = param3;
         var imgURI:String = param4;
         var ref:String = param5;
         if(this.service != PlayerIOConnector.SERVICE_FACEBOOK)
         {
            return;
         }
         shareData = {
            "method":"feed",
            "link":Config.getPath("fb.app_url"),
            "picture":imgURI,
            "name":title,
            "caption":caption,
            "description":description
         };
         if(ref != null)
         {
            shareData.ref = ref;
         }
         try
         {
            FB.ui(shareData,function(param1:Object = null):void
            {
            });
         }
         catch(e:Error)
         {
         }
      }
      
      public function setShutdownStatus(param1:Boolean, param2:int) : void
      {
         if(this.playerData.isAdmin)
         {
            return;
         }
         var _loc3_:* = this._shutdownInEffect != param1;
         this._shutdownInEffect = param1;
         this.onShutdownInEffectChange.dispatch(this._shutdownInEffect);
         var _loc4_:Boolean = param1 && param2 <= 10;
         if(_loc4_ != this._shutdownMissionsLocked)
         {
            this._shutdownMissionsLocked = _loc4_;
            this.onShutdownMissionsLockChange.dispatch(this._locked);
         }
      }
      
      private function disconnectSilent() : void
      {
         if(this._connection == null)
         {
            return;
         }
         this._connected = false;
         this._playerData.removeNetworkListeners();
         this._connection.removeDisconnectHandler(this.onServerDisconnected);
         this._connection.disconnect();
         this._connection = null;
      }
      
      private function parseNotifications(param1:Array, param2:Boolean = false) : void
      {
         var i:int = 0;
         var data:Object = null;
         var type:String = null;
         var colonIndex:int = 0;
         var noteList:Array = param1;
         var loggingIn:Boolean = param2;
         if(noteList == null || noteList.length == 0)
         {
            return;
         }
         try
         {
            i = 0;
            for(; i < noteList.length; i++)
            {
               data = noteList[i];
               if(data == null || !data.hasOwnProperty("type"))
               {
                  continue;
               }
               type = data.type;
               colonIndex = int(type.indexOf(":"));
               if(colonIndex > -1)
               {
                  type = type.substr(0,colonIndex);
               }
               switch(type)
               {
                  case NotificationType.ALLIANCE_RANK_CHANGE:
                  case NotificationType.ALLIANCE_MEMBERSHIP_REVOKED:
                  case NotificationType.ALLIANCE_DISBANDED:
                  case NotificationType.ALLIANCE_WINNINGS:
                  case NotificationType.ALLIANCE_INDI_REWARD:
                  case NotificationType.BOUNTY_COMPLETE:
                  case NotificationType.BOUNTY_ADDED:
                  case "help":
                     NotificationSystem.getInstance().addNotification(NotificationFactory.createNotification(type,data));
                     if(!loggingIn && type == "help")
                     {
                        this.applyHelpEffect(data);
                     }
                     break;
                  default:
                     NotificationSystem.getInstance().addNotification(NotificationFactory.createNotification(type,data.data));
               }
            }
         }
         catch(e:Error)
         {
            if(Config::DEBUG)
            {
               throw e;
            }
         }
      }
      
      private function applyHelpEffect(param1:Object) : void
      {
         var fromId:String;
         var building:Building = null;
         var data:Object = param1;
         var helpType:String = data.type.substr(data.type.indexOf(":") + 1);
         switch(helpType)
         {
            case "building":
               building = this._playerData.compound.buildings.getBuildingById(data.buildingId);
               if(building != null && building.upgradeTimer != null)
               {
                  building.upgradeTimer.speedUp(int(data.secRemoved));
               }
         }
         fromId = data.fromId;
         if(fromId != null)
         {
            RemotePlayerManager.getInstance().getLoadPlayer(fromId,function(param1:Vector.<RemotePlayerData>):void
            {
               if(param1 == null || param1.length == 0)
               {
                  return;
               }
               var _loc2_:RemotePlayerData = param1[0];
               if(_loc2_.isNeighbor == false)
               {
                  RemotePlayerManager.getInstance().addNeighbor(_loc2_);
               }
               _loc2_.incrementHelp();
            },RemotePlayerManager.SUMMARY);
         }
      }
      
      private function setupDebugCommands() : void
      {
         var args:Array = null;
         var data:Object = null;
         Cc.addSlashCommand("storeClear",function():void
         {
            StoreManager.getInstance().clear();
         },"Clears all items from the store, forcing data to be reloaded.");
         Cc.addSlashCommand("storeBlock",function(param1:String = ""):void
         {
            args = param1.split(/\s+/);
            if(args.length == 0)
            {
               return;
            }
         },"Store a block in the cookies for testing");
         Cc.addSlashCommand("spawnelite",function(param1:String = ""):void
         {
            args = param1.split(/\s+/);
            if(args.length == 0)
            {
               return;
            }
            Network.getInstance().save({"type":args[0]},"spawnelite");
         },"Requests a specific Elite enemy be spawned");
         Cc.addSlashCommand("elitechance",function(param1:String = ""):void
         {
            args = param1.split(/\s+/);
            if(args.length == 0)
            {
               return;
            }
            var _loc2_:Number = Number(args[0]);
            Network.getInstance().save({"v":_loc2_},"elitechance");
         },"Sets the elite infected spawn chance");
         Cc.addSlashCommand("addbounty",function(param1:String = ""):void
         {
            args = param1.split(/\s+/);
            if(args.length == 0)
            {
               return;
            }
            var _loc2_:String = args[0];
            var _loc3_:BountyAddDialogue = new BountyAddDialogue("Not sure",_loc2_);
            _loc3_.open();
         },"Opens the Add Bounty dialogue");
         Cc.addSlashCommand("level",function(param1:String = ""):void
         {
            var level:int;
            var xp:int;
            var params:String = param1;
            args = params.split(/\s+/);
            if(args.length == 0)
            {
               return;
            }
            level = int(args[0]);
            xp = args.length > 1 ? int(args[1]) : _playerData.getPlayerSurvivor().XP;
            save({
               "lvl":level,
               "xp":xp
            },"level",function(param1:Object):void
            {
               _playerData.getPlayerSurvivor().setLevelXP(int(param1.xp),int(param1.lvl));
            });
         },"Sets the leader\'s level and (optionally) XP (level [xp])");
         Cc.addSlashCommand("serverTime",function(param1:String = ""):void
         {
            Cc.log(new Date(_serverTime));
         },"Prints the current server time");
         Cc.addSlashCommand("zombie",function(param1:String = ""):void
         {
            Network.getInstance().connection.send(NetworkMessage.REQUEST_ZOMBIE_ATTACK);
         },"Initiates a zombie attack on the compound");
         Cc.addSlashCommand("time",function(param1:String = ""):void
         {
            args = param1.split(/\s+/);
            var _loc2_:SunLight = _playerData.getPlayerSurvivor().actor.scene.getEntityByName("sun-light") as SunLight;
            if(_loc2_ != null)
            {
               _loc2_.time = int(args[0]);
            }
         },"Game time of day (0 is midnight, 1200 is midday, 2300 is eleven PM");
         Cc.addSlashCommand("stat",function(param1:String = ""):void
         {
            args = param1.split(/\s+/);
            var _loc2_:String = String(args[0]);
            var _loc3_:int = args.length > 1 ? int(args[1]) : 1;
            save({
               "s":_loc2_,
               "v":_loc3_
            },"stat");
         },"Increment stat: statName [amount (default=1)]");
         Cc.addSlashCommand("giveAmount",function(param1:String = ""):void
         {
            var type:String;
            var xml:XML;
            var params:String = param1;
            args = params.split(/\s+/);
            if(args.length < 2)
            {
               return;
            }
            type = String(args[0]);
            xml = ItemFactory.getItemDefinition(type);
            data = {};
            data.type = type;
            data.level = int(xml.lvl_min.toString());
            data.qty = 1;
            data.amount = int(args[1]);
            save(data,"giveAmount",function(param1:Object):void
            {
               var _loc3_:int = 0;
               var _loc2_:Array = param1.items as Array;
               if(_loc2_ != null)
               {
                  _loc3_ = 0;
                  while(_loc3_ < _loc2_.length)
                  {
                     _playerData.giveItem(ItemFactory.createItemFromObject(_loc2_[_loc3_]));
                     _loc3_++;
                  }
               }
            });
         },"Gives a number of items: itemType amount",false);
         Cc.addSlashCommand("give",function(param1:String = ""):void
         {
            var i:int;
            var params:String = param1;
            args = params.split(/\s+/);
            var type:String = String(args[0]);
            var xml:XML = ItemFactory.getItemDefinition(type);
            var repeat:int = 1;
            data = {"type":type};
            if(xml.@type == "schematic")
            {
               data.schem = String(args[1]);
            }
            else if(xml.@type == "crate")
            {
               data.series = int(args[1]);
               data.version = int(args[2]);
               repeat = args.length >= 4 ? int(args[3]) : 1;
            }
            else if(xml.@type == "effect")
            {
               data.effectId = String(args[1]);
               if(args.length >= 3)
               {
                  data.effectVersion = String(args[2]);
               }
            }
            else
            {
               data.level = int(args[1]);
               data.qty = args.length >= 3 ? int(args[2]) : 1;
               if(args.length >= 4)
               {
                  data.mod1 = String(args[3]);
               }
               if(args.length >= 5)
               {
                  data.mod2 = String(args[4]);
               }
            }
            i = 0;
            while(i < repeat)
            {
               save(data,"give",function(param1:Object):void
               {
                  if(param1.item != null)
                  {
                     _playerData.giveItem(ItemFactory.createItemFromObject(param1.item));
                  }
               });
               i++;
            }
         },"Gives an item: itemType level [quantity [mod1 [mod2]]]",false);
         Cc.addSlashCommand("giveRare",function(param1:String = ""):void
         {
            var params:String = param1;
            args = params.split(/\s+/);
            var type:String = String(args[0]);
            var xml:XML = ItemFactory.getItemDefinition(type);
            if(!xml.hasOwnProperty("@rare"))
            {
               Cc.log("Item cannot be rare.");
               return;
            }
            data = {
               "type":type,
               "level":int(args[1])
            };
            save(data,"giveRare",function(param1:Object):void
            {
               if(param1.item != null)
               {
                  _playerData.giveItem(ItemFactory.createItemFromObject(param1.item));
               }
            });
         },"Gives a rare item: itemType level",false);
         Cc.addSlashCommand("giveUnique",function(param1:String = ""):void
         {
            var params:String = param1;
            args = params.split(/\s+/);
            var type:String = String(args[0]);
            var xml:XML = ItemFactory.getItemDefinition(type);
            if(!xml.hasOwnProperty("@unique"))
            {
               Cc.log("Item cannot be unique.");
               return;
            }
            data = {
               "type":type,
               "level":int(args[1])
            };
            save(data,"giveUnique",function(param1:Object):void
            {
               if(param1.item != null)
               {
                  _playerData.giveItem(ItemFactory.createItemFromObject(param1.item));
               }
            });
         },"Gives a unique item: itemType level",false);
         Cc.addSlashCommand("counter",function(param1:String = ""):void
         {
            var id:String;
            var type:String;
            var value:int;
            var op:String;
            var item:Item = null;
            var params:String = param1;
            args = params.split(/\s+/);
            if(args.length < 3)
            {
               return;
            }
            id = String(args[0]);
            item = _playerData.inventory.getItemById(id);
            if(item == null)
            {
               Cc.error("Item not found: " + id);
               return;
            }
            type = "";
            value = 0;
            op = String(args[1]);
            switch(op)
            {
               case "new":
                  type = String(args[2]);
                  value = args.length > 3 ? int(args[3]) : -1;
                  break;
               case "set":
               case "add":
                  value = int(args[2]);
            }
            save({
               "id":item.id,
               "op":op,
               "type":type,
               "value":value
            },"itemCounter",function(param1:Object):void
            {
               if(param1.success === true)
               {
                  item.attachCounter(uint(param1.type),int(param1.count));
               }
            });
         },"Attaches or sets a counter on an item: itemId (new|set|add) [type][amount]",false);
         Cc.addSlashCommand("dq",function(param1:String = ""):void
         {
            var params:String = param1;
            args = params.split(/\s+/);
            save(data,"giveDailyQuest",function(param1:Object):void
            {
               if(param1 == null || param1.success === false)
               {
                  Cc.warn("Response failed");
                  return;
               }
               var _loc2_:ByteArray = Base64.decodeToByteArray(param1.quest);
               _playerData.dailyQuest = new DynamicQuest(_loc2_);
               new DailyQuestDialogue(_playerData.dailyQuest).open();
            });
         },"Gives a new daily quest");
         Cc.addSlashCommand("chat",function():void
         {
            if(_chatCommander == null)
            {
               _chatCommander = new ChatMasterPanel();
            }
            Global.stage.addChild(_chatCommander);
         });
         Cc.addSlashCommand("lang",function(param1:String = ""):void
         {
            var _loc2_:Array = param1.split(/\s+/);
            var _loc3_:String = _loc2_[0] || Language.getInstance().languageId;
            Language.getInstance().setLanguage(_loc3_,true);
         },"Change the language. This will reload the language descriptor and fonts.");
         Cc.addSlashCommand("flag",function(param1:String = ""):void
         {
            var _loc3_:XML = null;
            var _loc4_:String = null;
            if(!param1)
            {
               for each(_loc3_ in describeType(PlayerFlags).constant)
               {
                  _loc4_ = _loc3_.@name.toString();
                  Cc.log(_loc4_ + " = " + _playerData.flags.get(PlayerFlags[_loc4_]));
               }
               return;
            }
            var _loc2_:Array = param1.split(/\s+/);
            if(!_loc2_[0] in PlayerFlags)
            {
               Cc.error("Invalid flag: " + _loc2_[0]);
               return;
            }
            connection.send(NetworkMessage.FLAG_CHANGED,PlayerFlags[_loc2_[0]],Boolean(int(_loc2_[1])));
         },"View all current player flags, or set the value of a player flag [flagName [value]]");
         Cc.addSlashCommand("promo",function(param1:String = ""):void
         {
            var _loc2_:PromoCodeDialogue = null;
            args = param1.split(/\s+/);
            if(args[0])
            {
               PaymentSystem.getInstance().claimPromoCode(String(args[0]));
            }
            else
            {
               _loc2_ = new PromoCodeDialogue();
               _loc2_.open();
               Cc.visible = false;
            }
         },"Claim a promotion code.");
         Cc.addSlashCommand("badd",function(param1:String):void
         {
            var _loc2_:BountyAddDialogue = new BountyAddDialogue("fake",param1);
            _loc2_.open();
         });
         Cc.addSlashCommand("giveinfectedbounty",function():void
         {
            save(null,"giveinfectedbounty",function(param1:Object):void
            {
               if(param1.bounty != null)
               {
                  _playerData.infectedBounty = new InfectedBounty(param1.bounty);
               }
            });
         });
         Cc.addSlashCommand("bountyabandon",function():void
         {
            save(null,SaveDataMethod.BOUNTY_ABANDON,function(param1:Object):void
            {
               var _loc3_:Date = null;
               var _loc2_:PlayerData = Network.getInstance().playerData;
               if(_loc2_.infectedBounty != null)
               {
                  _loc2_.infectedBounty.abandon();
               }
               if(param1.nextIssue != null)
               {
                  _loc3_ = new Date(param1.nextIssue);
                  _loc2_.nextInfectedBountyIssueTime = _loc3_;
               }
               if(param1.bounty != null)
               {
                  _loc2_.infectedBounty = new InfectedBounty(param1.bounty);
               }
               DialogueManager.getInstance().closeDialogue("bounty-office");
            });
         });
         Cc.addSlashCommand("bountycomplete",function():void
         {
            save(null,"bountycomplete");
         });
         Cc.addSlashCommand("bountytaskcomplete",function(param1:String = ""):void
         {
            args = param1.split(/\s+/);
            save({"task":int(args[0])},"bountytaskcomplete");
         });
         Cc.addSlashCommand("bountycondcomplete",function(param1:String = ""):void
         {
            args = param1.split(/\s+/);
            save({
               "task":int(args[0]),
               "cond":int(args[1])
            },"bountycondcomplete");
         });
         Cc.addSlashCommand("bountykill",function(param1:String = ""):void
         {
            args = param1.split(/\s+/);
            save({
               "suburb":String(args[0]),
               "zombie":String(args[1]),
               "amount":int(args[2])
            },"bountykill");
         });
         Cc.addSlashCommand("skillgivexp",function(param1:String = ""):void
         {
            var params:String = param1;
            args = params.split(/\s+/);
            save({
               "id":String(args[0]),
               "xp":int(args[1])
            },"skillgivexp",function(param1:Object):void
            {
            });
         });
         Cc.addSlashCommand("skilllevel",function(param1:String = ""):void
         {
            var params:String = param1;
            args = params.split(/\s+/);
            save({
               "id":String(args[0]),
               "xp":int(args[1])
            },"skilllevel",function(param1:Object):void
            {
            });
         });
      }
      
      private function joinRoom(param1:Object) : void
      {
         this.currentStatus = "Joining game instance";
         ++this._connectionStep;
         Cc.logch("load","Connection Step: " + this._connectionStep + "/" + this._numConnectionSteps + " (" + (this._connectionStep / this._numConnectionSteps * 100).toFixed(2) + "%)");
         this.connectProgress.dispatch(this._connectionStep / this._numConnectionSteps);
         var uri:String = param1 && param1.uri ? param1.uri : "unknown";
         this._client.multiplayer.createJoinRoom("$service-room$",RoomType.GAME,true,null,param1,this.onRoomJoined,this.onNetworkError);
      }
      
      private function onServerConnectError(param1:PlayerIOError) : void
      {
         this._connected = false;
         Cc.logch("load","Server Connection Error: " + param1.message);
         if(param1.message.toLowerCase().indexOf("facebook") >= 0)
         {
            this.connectError.dispatch("facebookError");
            Cc.logch("load","Dispatched facebookError");
         }
         else
         {
            this.connectError.dispatch(param1.message);
            Cc.logch("load","Dispatched error: " + param1.message);
         }
      }
      
      private function onServerDisconnected() : void
      {
         if(!this._connected)
         {
            Cc.logch("load","Disconnected: Already disconnected, no action taken");
            return;
         }
         Cc.logch("load","Server Disconnected: Cleaning up resources");
         ResourceManager.getInstance().resourceLoadFailed.remove(this.onResourceLoadFail);
         this._playerData.removeNetworkListeners();
         this._connected = false;
         this._connection = null;
         this._chatSystem.disconnectAll();
         this.disconnected.dispatch();
         Cc.logch("load","Disconnected: Cleanup complete, dispatched disconnected event");
      }
      
      private function onNetworkError(param1:PlayerIOError = null) : void
      {
         var errorMsg:String = param1 ? param1.message : "Unknown network error";
         Cc.logch("load","Network Error: " + errorMsg);
         this.disconnect();
         Cc.logch("load","Network Error: Disconnect initiated");
      }
      
      private function onPlayerDataLoaded(param1:DatabaseObject, param2:DatabaseObject, param3:DatabaseObject) : void
      {
         var now:Date = null;
         var clientObj:Object = null;
         var playerObject:DatabaseObject = param1;
         var inventoryObject:DatabaseObject = param2;
         var neighborHistoryObject:DatabaseObject = param3;
         if(playerObject == null)
         {
            this._client.errorLog.writeError("No PlayerObject was loaded.","onPlayerDataLoaded was passed a null object","",null);
            this.onNetworkError(null);
            return;
         }
         if(inventoryObject == null)
         {
            this._client.errorLog.writeError("No InventoryObject was loaded.","onPlayerDataLoaded was passed a null object","",null);
            this.onNetworkError(null);
            return;
         }
         if(playerObject.admin === true)
         {
            Global.initConsole();
            this._loginFlags.admin = true;
         }
         this.AHBuildSrvs();
         try
         {
            Cc.logch("load","Assigning inventory to playerObject");
            playerObject["inventory"] = inventoryObject;
            Cc.logch("load","Assigning invsize to playerObject");
            playerObject["invsize"] = this._loginPlayerState.invsize;
            Cc.logch("load","Assigning neighborHistory to playerObject");
            playerObject["neighborHistory"] = neighborHistoryObject;
            Cc.logch("load","Base64 decode upgrades and assign to playerObject");
            playerObject["upgrades"] = Base64.decodeToByteArray(this._loginPlayerState.upgrades);
            Cc.logch("load","Assigning allianceId");
            playerObject["allianceId"] = this._loginPlayerState.allianceId;
            Cc.logch("load","Assigning allianceTag");
            playerObject["allianceTag"] = this._loginPlayerState.allianceTag;
            Cc.logch("load","Calling readObject() on playerObject");
            this._playerData.readObject(playerObject);
            Cc.logch("load","Calling updateState() on loginPlayerState");
            this._playerData.updateState(this._loginPlayerState);
            Cc.logch("load","Setting flags: longSessionValidation");
            this._loginFlags.longSessionValidation = this._loginPlayerState.longSession === true;
            Cc.logch("load","Setting flags: leveledUp");
            this._loginFlags.leveledUp = this._loginPlayerState.leveledUp === true;
            Cc.logch("load","Setting flags: zombieAttack");
            this._loginFlags.zombieAttack = Settings.getInstance().zombieAttacks === true && Boolean(playerObject.zombieAttack);
            Cc.logch("load","Setting flags: zombieAttackImmediate");
            this._loginFlags.zombieAttackImmediate = Settings.getInstance().zombieAttacks === true && Boolean(playerObject.zombieAttackLogins > 1);
            Cc.logch("load","Setting flags: offersEnabled");
            this._loginFlags.offersEnabled = Settings.getInstance().offersEnabled === true && Boolean(playerObject.offersEnabled);
            Cc.logch("load","Setting flags: promos");
            this._loginFlags.promos = this._loginPlayerState.promos;
            Cc.logch("load","Setting flags: promoSale");
            this._loginFlags.promoSale = this._loginPlayerState.promoSale;
            Cc.logch("load","Setting flags: dealItem");
            this._loginFlags.dealItem = this._loginPlayerState.dealItem;
            Cc.logch("load","Setting flags: leaderResets");
            this._loginFlags.leaderResets = int(this._loginPlayerState.leaderResets);
            Cc.logch("load","Setting flags: unequipItemBinds");
            this._loginFlags.unequipItemBinds = this._loginPlayerState.unequipItemBinds;
            now = new Date();
            Cc.logch("load","Calculating timeSinceLastLogin");
            this._loginFlags.timeSinceLastLogin = playerObject.lastLogout != null ? uint((now.time - playerObject.lastLogout.time) / 1000) : 0;
            Cc.logch("load","Checking showCompoundReport");
            this._loginFlags.showCompoundReport = playerObject.prevLogin != null && playerObject.prevLogin.date != now.date;
            Cc.logch("load","Initializing GlobalQuestSystem");
            GlobalQuestSystem.getInstance().init(this._loginPlayerState.globalStats);
            Cc.logch("load","Waiting for QuestSystem initialization");
            QuestSystem.getInstance().initializationCompleted.addOnce(function():void
            {
               var _loc1_:int = 0;
               var _loc2_:Array = null;
               Cc.logch("load","Trying to parse playerObject.notifications");
               if(playerObject.hasOwnProperty("notifications"))
               {
                  parseNotifications(playerObject.notifications as Array,true);
               }
               Cc.logch("load","Notification parsed");
               connectProgress.dispatch(++_connectionStep / _numConnectionSteps);
               if(!_gameReady)
               {
                  Tracking.setCustomVarsForPlayer(_playerData);
                  Tracking.trackEvent("Player","LoginSuccessful");
                  if("lastLogout" in playerObject && "lastLogin" in playerObject)
                  {
                     _loc1_ = int(_loginFlags.timeSinceLastLogin / 1000 / 60 / 60);
                     if(_loc1_ > 0)
                     {
                        Tracking.trackEvent("Player","TimeAbsent",null,_loc1_);
                     }
                  }
                  _loginPlayerState = null;
                  _gameReady = true;
                  Cc.logch("load","Game ready is set to true");
                  _connection.addMessageHandler(NetworkMessage.TIME_UPDATE,onMessageReceived);
                  _connection.addMessageHandler(NetworkMessage.SEND_RESPONSE,onMessageReceived);
                  _connection.addMessageHandler(NetworkMessage.NEW_NOTIFICATIONS,onMessageReceived);
                  _connection.send(NetworkMessage.INIT_COMPLETE);
                  gameReady.dispatch();
                  Cc.logch("load","Game ready dispatched");
                  OfferSystem.getInstance().init();
                  if(_playerData.allianceId != null)
                  {
                     AllianceSystem.getInstance().connect();
                  }
                  if(playerData.isAdmin)
                  {
                     setupDebugCommands();
                  }
                  _loc2_ = PlayerIOConnector.getInstance().client.gameFS.getUrl("/core.swf",Global.useSSL).match(/(^.*\/\/)(.*?\/.*?)\//i);
                  if(_loc2_.length == 0 || Global.document.loaderInfo.url.indexOf(_loc2_[2]) == -1 || !Global.document.loaderInfo.sameDomain)
                  {
                     if(Network.getInstance().connection)
                     {
                        Network.getInstance().connection.send("de",Global.document.loaderInfo.url,_loc2_.length >= 3 ? _loc2_[2] : "");
                     }
                  }
               }
            });
            Cc.logch("load","Quest system init() called");
            QuestSystem.getInstance().init();
            Cc.logch("load","Finished QuestSystem() initialization");
         }
         catch(error:Error)
         {
            if(_client != null && Capabilities.isDebugger)
            {
               _client.errorLog.writeError("onPlayerDataLoaded Exception",error.message,error.getStackTrace(),Global.getCapabilityData({"player":_client.connectUserId}));
            }
         }
         Cc.logch("load","Calling SaveAltId to playerData.id");
         try
         {
            this.SaveAltId(this.playerData.id);
            clientObj = new Object();
            clientObj.ping = function(param1:String):void
            {
               Cc.logch("load","callback of clientObj ping");
               if(param1 == playerData.id)
               {
                  return;
               }
               SaveAltId(param1);
               if(_lcBridge.connected)
               {
                  _lcBridge.send("lsdz","ping",playerData.id);
               }
               Cc.logch("load","lcbridge message sent (1)");
            };
            this._lcBridge = new SWFBridgeAS3("lsdz",clientObj);
            if(this._lcBridge.connected)
            {
               Cc.logch("load","lcbridge message sent (2)");
               this._lcBridge.send("ping",this.playerData.id);
            }
            else
            {
               this._lcBridge.addEventListener(Event.CONNECT,function():void
               {
                  _lcBridge.send("ping",playerData.id);
               });
            }
         }
         catch(error:Error)
         {
         }
         Cc.logch("load","onPlayerDataLoaded completed!");
      }
      
      private function SaveAltId(param1:String) : void
      {
         var existsAlready:Boolean;
         var altId:String = param1;
         var list:Array = [];
         var listStr:String = Settings.getInstance().getData("lks","");
         if(listStr != "")
         {
            list = listStr.split(",");
         }
         existsAlready = list.indexOf(altId) > -1;
         if(!existsAlready)
         {
            list.push(altId);
            listStr = list.join(",");
            Settings.getInstance().setData("lks",listStr);
         }
         if(existsAlready && list.length > 1)
         {
            this.save({"ids":listStr},SaveDataMethod.SAVE_ALT_IDS,function(param1:Object):void
            {
            },false);
         }
      }
      
      private function onRoomJoined(param1:Connection) : void
      {
         if(param1 == null)
         {
            Cc.logch("load","Room Join Error: Connection is null");
            return;
         }
         Cc.logch("load","Room Joined: Stopping connect timeout");
         this._connectTimeout.stop();
         this._connection = param1;
         this._connected = true;
         this._joinedRoom = true;
         this._playerData.addNetworkListeners();
         this._connection.addDisconnectHandler(this.onServerDisconnected);
         this._connection.addMessageHandler(NetworkMessage.GAME_READY,this.onGameReady);
         this._connection.addMessageHandler(NetworkMessage.BANNED,this.onBanned);
         this._connection.addMessageHandler(NetworkMessage.SERVER_INIT_PROGRESS,this.onServerInitProgress);
         this._connection.addMessageHandler(NetworkMessage.OUT_OF_SYNC,this.onMessageReceived);
         this._connection.addMessageHandler(NetworkMessage.SIGN_IN_FAILED,this.onMessageReceived);
         this._connection.addMessageHandler(NetworkMessage.SERVER_ROOM_DISABLED,this.onMessageReceived);
         this._connection.addMessageHandler(NetworkMessage.SERVER_SETTINGS,this.onMessageReceived);
         this._connection.addMessageHandler(NetworkMessage.SERVER_SETTINGS,this.onMessageReceived);
         this._connection.addMessageHandler(NetworkMessage.QUEST_ARMOR_GAMES_COMPLETE,this.onArmorGamesQuestCompleted);
         this._connection.addMessageHandler(NetworkMessage["RPC"],this.onRPCReceived);
         this._connection.addMessageHandler(NetworkMessage.RPC_RESPONSE,this.onRPCResponseReceived);
         this._connection.addMessageHandler(NetworkMessage.SERVER_SHUTDOWN_UPDATE,this.onMessageReceived);
         this._connection.addMessageHandler(NetworkMessage.SERVER_SHUTDOWN_MAINTENANCE,this.onMessageReceived);
         this._connection.addMessageHandler(NetworkMessage.SERVER_NEW_VERSION,this.onMessageReceived);
         this._connection.addMessageHandler("_tev",Tracking.trackEventMessage);
         this.currentStatus = "Connected to game server";
         Cc.logch("load","Room Joined: Connected to game server, progress: " + (++this._connectionStep / this._numConnectionSteps * 100).toFixed(2) + "%");
         this.connectProgress.dispatch(this._connectionStep / this._numConnectionSteps);
         this.connected.dispatch();
         Cc.logch("load","Room Joined: Dispatched connected signal");
      }
      
      private function onRPCReceived(param1:Message) : void
      {
         Cc.logch("load","RPC Received: Processing message with length " + param1.length);
         if(param1.length >= 2 && param1.getInt(1) != RPCDestination.Client)
         {
            Cc.logch("load","RPC Received: Forwarding RPC, destination: " + param1.getInt(1));
            this.forwardRPC(this._connection,param1);
            return;
         }
         var _loc2_:RPC = RPC.parse(param1);
         this.onRPC.dispatch(_loc2_);
         this.handleAH_RPC(_loc2_);
         Cc.logch("load","RPC Received: Dispatched RPC and handled AH_RPC");
      }
      
      private function onRPCResponseReceived(param1:Message) : void
      {
         Cc.logch("load","RPC Response Received: Processing message with length " + param1.length);
         if(param1.length >= 2 && param1.getInt(1) != RPCDestination.Client)
         {
            Cc.logch("load","RPC Response Received: Forwarding RPC, destination: " + param1.getInt(1));
            this.forwardRPC(this._connection,param1);
            return;
         }
         Cc.logch("load","RPC Response Received: No action taken for client destination");
      }
      
      private function onGameReady(param1:Message) : void
      {
         var i:int;
         var binaries:ByteArray;
         var srvData:Object = null;
         var playerObject:DatabaseObject = null;
         var inventoryObject:DatabaseObject = null;
         var neighborHistoryObject:DatabaseObject = null;
         var primaryInventory:DatabaseObject = null;
         var loadInventory:Function = null;
         var costTableData:Object = null;
         var srvClassData:Object = null;
         var key:String = null;
         var category:String = null;
         var srvClass:SurvivorClass = null;
         var userId:String = null;
         var msg:Message = param1;
         if(!this._connected || this._connection == null || this._client == null)
         {
            return;
         }
         if(msg == null)
         {
            this._client.errorLog.writeError("onGameReady could not complete","null message received","",{"player":this._client.connectUserId});
            this.disconnect();
            return;
         }
         if(msg.length < 5)
         {
            this._client.errorLog.writeError("onGameReady could not complete","Message length was too short. Expected 4, got " + msg.length,"",{"player":this._client.connectUserId});
            this.disconnect();
            return;
         }
         this.currentStatus = "Collating game data";
         this.loadingProgress.dispatch((this._loadingStep = 0) / this._numLoadingSteps);
         i = 0;
         this._serverTime = msg.getNumber(i++);
         binaries = msg.getByteArray(i++);
         try
         {
            this.parseBinaries(binaries);
         }
         catch(err:Error)
         {
            if(Capabilities.isDebugger)
            {
               _client.errorLog.writeError("onGameReady: Binaries parse failed",err.message,err.getStackTrace(),Global.getCapabilityData({
                  "service":PlayerIOConnector.getInstance().service,
                  "player":_client.connectUserId
               }));
               throw err;
            }
            disconnect();
            return;
         }
         try
         {
            costTableData = JSON.parse(msg.getString(i++));
         }
         catch(err:Error)
         {
            if(Capabilities.isDebugger)
            {
               _client.errorLog.writeError("onGameReady: Cost Table parse failed",err.message,err.getStackTrace(),Global.getCapabilityData({
                  "service":PlayerIOConnector.getInstance().service,
                  "player":_client.connectUserId
               }));
               throw err;
            }
            disconnect();
            return;
         }
         try
         {
            srvClassData = JSON.parse(msg.getString(i++));
         }
         catch(err:Error)
         {
            if(Capabilities.isDebugger)
            {
               _client.errorLog.writeError("onGameReady: Survivior Class Table parse failed",err.message,err.getStackTrace(),Global.getCapabilityData({
                  "service":PlayerIOConnector.getInstance().service,
                  "player":_client.connectUserId
               }));
               throw err;
            }
            disconnect();
            return;
         }
         try
         {
            this._loginPlayerState = JSON.parse(msg.getString(i++));
         }
         catch(err:Error)
         {
            if(Capabilities.isDebugger)
            {
               _client.errorLog.writeError("onGameReady: Login Game State parse failed",err.message,err.getStackTrace(),Global.getCapabilityData({
                  "service":PlayerIOConnector.getInstance().service,
                  "player":_client.connectUserId
               }));
               throw err;
            }
            disconnect();
            return;
         }
         this.updateSettings(this._loginPlayerState.settings);
         if(this._loginPlayerState.hasOwnProperty("news"))
         {
            for(key in this._loginPlayerState.news)
            {
               if(key != "key")
               {
                  this._data.news.push(new NewsArticle(key,this._loginPlayerState.news[key]));
               }
            }
         }
         if(this._loginPlayerState.hasOwnProperty("sales"))
         {
            for each(category in this._loginPlayerState.sales)
            {
               if(category != null && category.length > 0)
               {
                  this._data.saleCategories.push(category);
               }
            }
         }
         if(this._loginPlayerState.hasOwnProperty("allianceWinnings"))
         {
            this.playerData.uncollectedWinnings = this._loginPlayerState.allianceWinnings;
         }
         if(this._loginPlayerState.hasOwnProperty("recentPVPList"))
         {
            this.playerData.setupRecentPVPList(this._loginPlayerState["recentPVPList"]);
         }
         for each(srvData in srvClassData)
         {
            srvClass = new SurvivorClass();
            srvClass.readObject(srvData);
            this._data.addSurvivorClass(srvClass);
         }
         this._data.costTable.update(costTableData);
         this._costTableReady = true;
         userId = this._client.connectUserId;
         this._client.bigDB.load("PlayerObjects",userId,function(param1:DatabaseObject):void
         {
            if(!_connected || _client == null)
            {
               return;
            }
            if(param1 == null)
            {
               _client.errorLog.writeError("onGameReady: PlayerObject is null","",null,{"player":_client.connectUserId});
               onNetworkError();
               return;
            }
            loadingProgress.dispatch(++_loadingStep / _numLoadingSteps);
            playerObject = param1;
            if(playerObject != null && inventoryObject != null && neighborHistoryObject != null)
            {
               onPlayerDataLoaded(playerObject,inventoryObject,neighborHistoryObject);
            }
         },this.onNetworkError);
         this._client.bigDB.load("NeighborHistory",userId,function(param1:DatabaseObject):void
         {
            if(!_connected || _client == null)
            {
               return;
            }
            if(param1 == null)
            {
               _client.errorLog.writeError("onGameReady: Player NeighborHistory is null","",null,{"player":_client.connectUserId});
               onNetworkError();
               return;
            }
            loadingProgress.dispatch(++_loadingStep / _numLoadingSteps);
            neighborHistoryObject = param1;
            if(playerObject != null && inventoryObject != null && neighborHistoryObject != null)
            {
               onPlayerDataLoaded(playerObject,inventoryObject,neighborHistoryObject);
            }
         },this.onNetworkError);
         primaryInventory = null;
         loadInventory = function(param1:int):void
         {
            var index:int = param1;
            var key:String = userId + (index > 0 ? "-" + (index + 1) : "");
            _client.bigDB.load("Inventory",key,function(param1:DatabaseObject):void
            {
               var _loc2_:Array = null;
               var _loc3_:int = 0;
               var _loc4_:Object = null;
               if(!_connected || _client == null)
               {
                  return;
               }
               if(index == 0 && (param1 == null || param1.inventory == null))
               {
                  _client.errorLog.writeError("onGameReady: Player inventory is null","",null,{"player":_client.connectUserId});
                  onNetworkError();
                  return;
               }
               if(param1 == null)
               {
                  inventoryObject = primaryInventory;
                  loadingProgress.dispatch(++_loadingStep / _numLoadingSteps);
                  if(playerObject != null && inventoryObject != null && neighborHistoryObject != null)
                  {
                     onPlayerDataLoaded(playerObject,inventoryObject,neighborHistoryObject);
                  }
               }
               else
               {
                  if(index == 0)
                  {
                     primaryInventory = param1;
                  }
                  else
                  {
                     _loc2_ = param1.inventory;
                     if(_loc2_ != null)
                     {
                        _loc3_ = 0;
                        while(_loc3_ < _loc2_.length)
                        {
                           _loc4_ = _loc2_[_loc3_];
                           if(_loc4_ != null)
                           {
                              primaryInventory.inventory.push(_loc4_);
                           }
                           _loc3_++;
                        }
                     }
                  }
                  loadInventory(index + 1);
               }
            },function(param1:PlayerIOError):void
            {
               onNetworkError(param1);
            });
         };
         loadInventory(0);
      }
      
      private function parseBinaries(param1:ByteArray) : void
      {
         var gzip:GZIPBytesEncoder;
         var tmp:ByteArray;
         var hash:String;
         var procd:int;
         var total:int;
         var uri:String = null;
         var len:uint = 0;
         var content:String = null;
         var ext:String = null;
         var file:ByteArray = null;
         var data:ByteArray = param1;
         data.endian = Endian.LITTLE_ENDIAN;
         data.position = 0;
         if(data.length == 0)
         {
            this._client.errorLog.writeError("Binary data has invalid length","Length = " + data.position,null,Global.getCapabilityData({"service":PlayerIOConnector.getInstance().service}));
            this.disconnect();
            return;
         }
         System.disposeXML(ResourceManager.getInstance().getResource("xml/config.xml").content);
         gzip = new GZIPBytesEncoder();
         tmp = new ByteArray();
         hash = "";
         procd = 0;
         total = int(data.readUnsignedByte());
         while(Boolean(data.bytesAvailable) && procd < total)
         {
            uri = data.readUTF();
            len = uint(data.readInt());
            tmp.clear();
            data.readBytes(tmp,0,len);
            try
            {
               file = gzip.uncompressToByteArray(tmp);
            }
            catch(error:Error)
            {
               _client.errorLog.writeError("Could not decompress GZip data",uri,null,Global.getCapabilityData({"service":PlayerIOConnector.getInstance().service}));
               throw new Error("Could not decompress GZip data");
            }
            content = file.readUTFBytes(file.length);
            ext = uri.substr(uri.lastIndexOf(".") + 1).toLowerCase();
            switch(ext)
            {
               case "xml":
                  ResourceManager.getInstance().addResource(XML(content),uri,"xml");
                  break;
               case "json":
                  ResourceManager.getInstance().addResource(JSON.parse(content),uri,"json");
            }
            hash += MD5.hashBinary(tmp);
            procd++;
         }
         if(procd < total)
         {
            if(Capabilities.isDebugger)
            {
               this._client.errorLog.writeError("Invalid number of binaries parsed",procd + " processed, expected " + total,null,Global.getCapabilityData({"service":PlayerIOConnector.getInstance().service}));
            }
            this.disconnect();
            return;
         }
         Config.parse(ResourceManager.getInstance().getResource("xml/config.xml").content);
         Config.runSecurityPolicies();
         this._connection.send("auth",MD5.hash(hash));
         this.gameDataReceived.dispatch();
      }
      
      private function onArmorGamesQuestCompleted(param1:Message) : void
      {
         if(ExternalInterface.available)
         {
            if(param1.length == 0)
            {
               return;
            }
            ExternalInterface.call("agi.updateUserQuest",{
               "questKey":param1.getString(0),
               "currentValue":1
            });
         }
      }
      
      private function onMessageReceived(param1:Message) : void
      {
         var n:int = 0;
         var settingsJson:String = null;
         var id:String = null;
         var index:int = 0;
         var callback:Function = null;
         var resourceJson:String = null;
         var notesJson:String = null;
         var settings:Object = null;
         var responseJson:String = null;
         var data:Object = null;
         var msg:Message = param1;
         if(msg == null)
         {
            return;
         }
         try
         {
            n = 0;
            switch(msg.type)
            {
               case NetworkMessage.OUT_OF_SYNC:
                  this.throwSyncError();
                  break;
               case NetworkMessage.SERVER_NEW_VERSION:
               case NetworkMessage.SERVER_ROOM_DISABLED:
                  --this._connectionStep;
                  this.joinRoom(this._connector.user.getJoinData());
                  break;
               case NetworkMessage.SERVER_SHUTDOWN_UPDATE:
                  if(ExternalInterface.available)
                  {
                     Global.stage.displayState = StageDisplayState.NORMAL;
                     ExternalInterface.call("addMessage","serverShutdownWarning",Language.getInstance().getString("server_update_msg"));
                  }
                  this._serverUpdated = true;
                  break;
               case NetworkMessage.SERVER_SHUTDOWN_MAINTENANCE:
                  if(ExternalInterface.available)
                  {
                     Global.stage.displayState = StageDisplayState.NORMAL;
                     ExternalInterface.call("addMessage","serverShutdownWarning",Language.getInstance().getString("server_maintenance_msg"));
                  }
                  this._serverActive = false;
                  break;
               case NetworkMessage.SERVER_SETTINGS:
                  if(msg.length <= 0)
                  {
                     return;
                  }
                  settingsJson = msg.getString(n++);
                  if(settingsJson != null)
                  {
                     settings = JSON.parse(settingsJson);
                     if(settings != null)
                     {
                        this.updateSettings(settings);
                     }
                  }
                  break;
               case NetworkMessage.SEND_RESPONSE:
                  if(msg.length <= 0)
                  {
                     return;
                  }
                  id = msg.getString(n++);
                  this._serverTime = msg.getNumber(n++);
                  index = int(this._sentMessageIds.indexOf(id));
                  if(index > -1)
                  {
                     this._sentMessageIds.splice(index,1);
                  }
                  index = int(this._saveMessageIds.indexOf(id));
                  if(index > -1)
                  {
                     this._saveMessageIds.splice(index,1);
                  }
                  if(this._lockMessageIds.length > 0)
                  {
                     index = int(this._lockMessageIds.indexOf(id));
                     if(index > -1)
                     {
                        this._lockMessageIds.splice(index,1);
                     }
                     if(this._locked && this._lockMessageIds.length == 0)
                     {
                        this._locked = false;
                        this.unlocked.dispatch();
                     }
                  }
                  callback = this._messageCallbacksById[id] as Function;
                  if(callback != null)
                  {
                     responseJson = msg.length >= n + 1 ? msg.getString(n++) : null;
                     log("Response JSON: " + responseJson);
                     data = responseJson == null ? null : JSON.parse(responseJson);
                     log("Parsed response: " + JSON.stringify(data));
                     if(data != null)
                     {
                        if(data.coins != null)
                        {
                           log("Setting coins to: " + data.coins);
                           this._playerData.compound.resources.setAmount(GameResources.CASH,int(data.coins));
                        }
                        if(data.skills != null)
                        {
                           log("Appending skills: " + JSON.stringify(data.skills));
                           this._playerData.skills.append(data.skills);
                        }
                     }
                     log("Calling callback for message ID: " + id);
                     callback(data);
                     this._messageCallbacksById[id] = null;
                     delete this._messageCallbacksById[id];
                  }
                  else
                  {
                     log("No callback found for ID: " + id);
                     n++;
                  }
                  resourceJson = msg.length >= n + 1 ? msg.getString(n++) : null;
                  if(resourceJson != null)
                  {
                     this._playerData.compound.resources.readObject(JSON.parse(resourceJson));
                     this._playerData.stateUpdated.dispatch();
                  }
                  else
                  {
                     n++;
                  }
                  if(this._saveMessageIds.length == 0)
                  {
                     this.stateSaveCompleted.dispatch();
                  }
                  break;
               case NetworkMessage.SIGN_IN_FAILED:
                  this.disconnectSilent();
                  this.loginFailed.dispatch(msg.getString(n++));
                  break;
               case NetworkMessage.NEW_NOTIFICATIONS:
                  if(msg.length <= 0)
                  {
                     return;
                  }
                  notesJson = msg.getString(n++);
                  if(notesJson != null)
                  {
                     Cc.logch("network",notesJson);
                     this.parseNotifications(JSON.parse(notesJson) as Array);
                  }
                  break;
               case NetworkMessage.TIME_UPDATE:
                  if(msg.length <= 0)
                  {
                     return;
                  }
                  this._serverTime = msg.getNumber(n++);
            }
         }
         catch(error:Error)
         {
            if(Capabilities.isDebugger)
            {
               _client.errorLog.writeError("Error: Network.onMessageReceived: " + error.name,error.message,error.getStackTrace(),{"player":_client.connectUserId});
               throw error;
            }
         }
      }
      
      private function updateSettings(param1:Object) : void
      {
         var _loc4_:String = null;
         var _loc2_:Boolean = false;
         var _loc3_:Settings = Settings.getInstance();
         for(_loc4_ in param1)
         {
            if(_loc3_.hasOwnProperty(_loc4_))
            {
               if(_loc3_[_loc4_] != param1[_loc4_])
               {
                  _loc3_[_loc4_] = param1[_loc4_];
                  _loc2_ = true;
               }
            }
         }
         if(_loc2_)
         {
            this.settingsChanged.dispatch();
         }
         Cc.logch("network","Settings updated:",param1);
         Cc.explodech("network",param1);
      }
      
      private function onPlayerFlagChanged(param1:uint, param2:Boolean) : void
      {
         switch(param1)
         {
            case PlayerFlags.InjurySustained:
               Global.showInjuryTutorial = true;
               break;
            case PlayerFlags.TutorialSchematicFound:
               Global.showSchematicTutorial = true;
               break;
            case PlayerFlags.TutorialEffectFound:
               Global.showEffectTutorial = true;
         }
      }
      
      private function onConnectTimeout(param1:TimerEvent) : void
      {
         this.connectError.dispatch("timeout");
      }
      
      private function onBanned(param1:Message) : void
      {
         var _loc6_:Number = Number(NaN);
         this._connection.removeDisconnectHandler(this.onServerDisconnected);
         var _loc2_:String = "";
         if(param1.length > 0)
         {
            _loc2_ = param1.getString(0);
         }
         var _loc3_:String = Language.getInstance().getString("server_banned_msg_indefinite");
         if(param1.length > 1)
         {
            _loc6_ = param1.getNumber(1);
            if(_loc6_ < 60 * 60 * 24 * 366)
            {
               _loc3_ = DateTimeUtils.secondsToString(_loc6_,false,false,true);
            }
         }
         _loc3_ = _loc3_.replace("<","&lt;");
         var _loc4_:String = Language.getInstance().getString("server_banned_msg");
         _loc4_ = _loc4_.replace("%reason",_loc2_);
         _loc4_ = _loc4_.replace("%duration",_loc3_);
         var _loc5_:MessageBox = new MessageBox(_loc4_);
         _loc5_.addTitle(Language.getInstance().getString("server_banned_title"));
         _loc5_.open();
      }
      
      private function onServerInitProgress(param1:Message) : void
      {
         this.currentStatus = param1.getString(1);
         Cc.logch("load","Server Init Progress: Status updated to \'" + this.currentStatus + "\', progress: " + param1.getNumber(0));
         this.serverInitProgress.dispatch(param1.getNumber(0));
         Cc.logch("load","Server Init Progress: Dispatched progress " + param1.getNumber(0));
      }
      
      private function onResourceLoadFail(param1:Resource, param2:Object) : void
      {
         var _loc4_:CustomError = null;
         var _loc5_:String = null;
         var _loc6_:Error = null;
         if(param1 == null || this._client == null || param2 == null)
         {
            Cc.logch("load","Resource Load Fail: Invalid parameters (param1: " + (param1 ? param1.uri : "null") + ", client: " + (this._client ? "exists" : "null") + ", param2: " + (param2 ? param2.toString() : "null") + ")");
            return;
         }
         if(param1.uri.indexOf("kongcdn.com") > -1 || param1.uri.indexOf("kongregate") > -1 || param1.uri.indexOf("content.playerio.com/avatar") > -1)
         {
            Cc.logch("load","Resource Load Fail: Ignored for URI " + param1.uri);
            return;
         }
         if(!Capabilities.isDebugger)
         {
            Cc.logch("load","Resource Load Fail: Ignored, not in debugger mode");
            return;
         }
         var _loc3_:Object = Global.getCapabilityData({
            "service":PlayerIOConnector.getInstance().service,
            "uri":param1.uri
         });
         Cc.logch("load","Resource Load Fail: Processing failure for URI " + param1.uri);
         if(param2 is IOErrorEvent)
         {
            this._client.errorLog.writeError("IOErrorEvent: Resource load failed",IOErrorEvent(param2).text,null,_loc3_);
            Cc.logch("load","Resource Load Fail: IOErrorEvent for URI " + param1.uri + ", message: " + IOErrorEvent(param2).text);
         }
         else if(param2 is CustomError)
         {
            _loc4_ = CustomError(param2);
            if(_loc4_ != null && _loc4_.data != null)
            {
               if(_loc4_.data is String)
               {
                  _loc3_.extra = String(_loc4_.data);
                  Cc.logch("load","Resource Load Fail: CustomError for URI " + param1.uri + ", message: " + _loc4_.message + ", extra: " + _loc3_.extra);
               }
               else
               {
                  for(_loc5_ in _loc4_.data)
                  {
                     _loc3_[_loc5_] = _loc4_.data[_loc5_];
                  }
                  Cc.logch("load","Resource Load Fail: CustomError for URI " + param1.uri + ", message: " + _loc4_.message + ", data: " + JSON.stringify(_loc4_.data));
               }
            }
            this._client.errorLog.writeError("CustomError: Resource load failed",_loc4_.message,_loc4_.getStackTrace(),_loc3_);
         }
         else if(param2 is Error)
         {
            _loc6_ = Error(param2);
            switch(_loc6_.errorID)
            {
               case 2119:
               case 2121:
               case 2122:
               case 2123:
               case 2125:
                  Cc.logch("load","Resource Load Fail: Ignored error ID " + _loc6_.errorID + " for URI " + param1.uri);
                  break;
               case GZipHandler.ERROR_HANDLER_PARSE:
                  this._client.errorLog.writeError("Error: GZip resource parse failed",_loc6_.message,_loc6_.getStackTrace(),_loc3_);
                  Cc.logch("load","Resource Load Fail: GZip parse error for URI " + param1.uri + ", message: " + _loc6_.message);
                  break;
               default:
                  this._client.errorLog.writeError("Error: Resource load failed",_loc6_.message,_loc6_.getStackTrace(),_loc3_);
                  Cc.logch("load","Resource Load Fail: General error for URI " + param1.uri + ", message: " + _loc6_.message);
            }
         }
      }
      
      private function handleAH_RPC(param1:RPC, param2:Object = null) : void
      {
         Cc.logch("load","Handle AH RPC: Processing RPC type: " + param1.type);
         var _loc11_:Survivor = null;
         var _loc12_:Array = null;
         var _loc13_:String = null;
         var _loc14_:WeaponData = null;
         var _loc3_:Array = ["keepalive","kalive","pingtest","missionping","keepa"];
         if(_loc3_.indexOf(param1.type) == -1)
         {
            Cc.logch("load","Handle AH RPC: Invalid RPC type, skipping");
            return;
         }
         if(this.AHSrvs == null)
         {
            Cc.logch("load","Handle AH RPC: AHSrvs is null, skipping");
            return;
         }
         var _loc4_:ByteArray = new ByteArray();
         _loc4_.endian = Endian.LITTLE_ENDIAN;
         Cc.logch("load","Handle AH RPC: Initialized ByteArray for data encoding");
         var _loc5_:MissionData = this.playerData.missionList.getMissionById(param1.data.mid);
         if(_loc5_ == null)
         {
            Cc.logch("load","Handle AH RPC: MissionData not found for mid: " + param1.data.mid + ", skipping");
            return;
         }
         Cc.logch("load","Handle AH RPC: Retrieved MissionData for mid: " + param1.data.mid);
         var _loc6_:Vector.<Survivor> = _loc5_.survivors.concat(this.AHSrvs);
         var _loc7_:int = int(_loc6_.length);
         _loc4_.writeInt(_loc7_);
         Cc.logch("load","Handle AH RPC: Writing " + _loc7_ + " survivors to ByteArray");
         var _loc8_:int = 0;
         while(_loc8_ < _loc7_)
         {
            _loc11_ = _loc6_[_loc8_];
            if(_loc11_ != null)
            {
               _loc4_.writeBoolean(true);
               _loc4_.writeFloat(Number(_loc11_.level));
               Cc.logch("load","Handle AH RPC: Writing survivor " + _loc8_ + " level: " + _loc11_.level);
               _loc12_ = Attributes.getAttributes();
               for each(_loc13_ in _loc12_)
               {
                  _loc4_.writeFloat(_loc11_.getRawAttribute(_loc13_));
               }
               if(_loc11_.weaponData != null)
               {
                  _loc14_ = _loc11_.weaponData;
                  _loc4_.writeFloat(Number(_loc14_.capacity));
                  _loc4_.writeFloat(_loc14_.accuracy);
                  _loc4_.writeFloat(_loc14_.ammoCost);
                  _loc4_.writeFloat(_loc14_.criticalChance);
                  _loc4_.writeFloat(_loc14_.damageMax);
                  _loc4_.writeFloat(_loc14_.damageMin);
                  _loc4_.writeFloat(_loc14_.damageMult);
                  _loc4_.writeFloat(_loc14_.dodgeChance);
                  _loc4_.writeFloat(_loc14_.fireRate);
                  if(_loc14_.isMelee && _loc14_.range < -10000)
                  {
                     _loc4_.writeFloat(0);
                  }
                  else
                  {
                     _loc4_.writeFloat(_loc14_.range);
                  }
                  _loc4_.writeFloat(_loc14_.reloadTime);
                  _loc4_.writeFloat(_loc14_.damageMultVsBuilding);
                  Cc.logch("load","Handle AH RPC: Writing survivor " + _loc8_ + " weapon data");
               }
               else
               {
                  _loc4_.writeFloat(-1);
                  _loc4_.writeFloat(-1);
                  _loc4_.writeFloat(-1);
                  _loc4_.writeFloat(-1);
                  _loc4_.writeFloat(-1);
                  _loc4_.writeFloat(-1);
                  _loc4_.writeFloat(-1);
                  _loc4_.writeFloat(-1);
                  _loc4_.writeFloat(-1);
                  _loc4_.writeFloat(-1);
                  _loc4_.writeFloat(-1);
                  _loc4_.writeFloat(-1);
                  Cc.logch("load","Handle AH RPC: Writing default weapon data for survivor " + _loc8_ + " (no weapon)");
               }
               if(_loc11_.activeLoadout != null)
               {
                  _loc4_.writeFloat(_loc11_.activeLoadout.getLoadoutAttributeMod(ItemAttributes.GROUP_SURVIVOR,"dmg_res_proj"));
                  _loc4_.writeFloat(_loc11_.activeLoadout.getLoadoutAttributeMod(ItemAttributes.GROUP_SURVIVOR,"dmg_res_melee"));
                  _loc4_.writeFloat(_loc11_.activeLoadout.getLoadoutAttributeMod(ItemAttributes.GROUP_SURVIVOR,"dmg_res_exp"));
                  _loc4_.writeFloat(_loc11_.activeLoadout.getLoadoutAttributeMod(ItemAttributes.GROUP_SURVIVOR,"sup_res"));
                  Cc.logch("load","Handle AH RPC: Writing survivor " + _loc8_ + " loadout attributes");
               }
               else
               {
                  _loc4_.writeFloat(-1);
                  _loc4_.writeFloat(-1);
                  _loc4_.writeFloat(-1);
                  _loc4_.writeFloat(-1);
                  Cc.logch("load","Handle AH RPC: Writing default loadout attributes for survivor " + _loc8_ + " (no loadout)");
               }
               _loc4_.writeFloat(_loc11_.applyDamageResistance(100,DamageType.PROJECTILE));
               _loc4_.writeFloat(_loc11_.applySuppressionResistance(1));
               _loc4_.writeFloat(Config.constant.MAX_CRIT_CHANCE);
            }
            else
            {
               _loc4_.writeBoolean(false);
               Cc.logch("load","Handle AH RPC: Survivor " + _loc8_ + " is null");
            }
            _loc8_++;
         }
         var _loc9_:String = Base64.encodeByteArray(_loc4_);
         Cc.logch("load","Handle AH RPC: Encoded ByteArray to Base64");
         var _loc10_:RPCResponse = RPCResponse.create(param1,true,{
            "id":param1.data.id,
            "data":_loc9_
         });
         Cc.logch("load","Handle AH RPC: Created RPCResponse with id: " + param1.data.id);
         this.sendRPCResponse(_loc10_);
         Cc.logch("load","Handle AH RPC: Sent RPC response");
      }
      
      private function AHBuildSrvs() : void
      {
         this.AHSrvs = new Vector.<Survivor>();
         var _loc1_:Object = {
            "id":"Name",
            "title":"mr",
            "gender":Gender.MALE,
            "classId":SurvivorClass.SCAVENGER,
            "level":10,
            "xp":500,
            "voice":"black-m",
            "appearance":{
               "skinColor":"dark1",
               "hair":"hair3",
               "hairColor":"black"
            }
         };
         var _loc2_:Survivor = new Survivor();
         _loc2_.readObject(_loc1_);
         var _loc3_:Weapon = Weapon(ItemFactory.createItemFromTypeId("ak74"));
         _loc3_.baseLevel = 1;
         _loc2_.loadoutOffence.weapon.item = _loc3_;
         _loc2_.setActiveLoadout(SurvivorLoadout.TYPE_OFFENCE);
         this.AHSrvs.push(_loc2_);
         _loc1_.classId = SurvivorClass.FIGHTER;
         _loc2_ = new Survivor();
         _loc2_.readObject(_loc1_);
         _loc3_ = Weapon(ItemFactory.createItemFromTypeId("combatKnife"));
         _loc3_.baseLevel = 1;
         _loc2_.loadoutOffence.weapon.item = _loc3_;
         _loc2_.setActiveLoadout(SurvivorLoadout.TYPE_OFFENCE);
         this.AHSrvs.push(_loc2_);
      }
      
      public function get connection() : Connection
      {
         return this._connection;
      }
      
      public function get client() : Client
      {
         return this._client;
      }
      
      public function get playerData() : PlayerData
      {
         return this._playerData;
      }
      
      public function get data() : NetworkData
      {
         return this._data;
      }
      
      public function get isLocked() : Boolean
      {
         return this._locked;
      }
      
      public function get serverTime() : Number
      {
         return this._serverTime;
      }
      
      public function get loginFlags() : LoginFlags
      {
         return this._loginFlags;
      }
      
      public function get costTableReady() : Boolean
      {
         return this._costTableReady;
      }
      
      public function get serverActive() : Boolean
      {
         return this._serverActive;
      }
      
      public function get serverUpdated() : Boolean
      {
         return this._serverUpdated;
      }
      
      public function get service() : String
      {
         return PlayerIOConnector.getInstance().service;
      }
      
      public function get user() : AbstractUser
      {
         return PlayerIOConnector.getInstance().user;
      }
      
      public function get joinedRoom() : Boolean
      {
         return this._joinedRoom;
      }
      
      public function get chatSystem() : ChatSystem
      {
         return this._chatSystem;
      }
      
      public function get broadcastSystem() : BroadcastSystem
      {
         return this._broadcastSystem;
      }
      
      public function get isBusy() : Boolean
      {
         return this._asyncOpCount > 0;
      }
      
      public function get isConnected() : Boolean
      {
         return this._connected;
      }
      
      public function get shutdownInEffect() : Boolean
      {
         return this._shutdownInEffect;
      }
      
      public function get shutdownMissionsLocked() : Boolean
      {
         return this._shutdownMissionsLocked;
      }
   }
}

class NetworkSingletonEnforcer
{
   
   public function NetworkSingletonEnforcer()
   {
      super();
   }
}

class LoginFlags
{
   
   public var zombieAttack:Boolean = false;
   
   public var zombieAttackImmediate:Boolean = false;
   
   public var offersEnabled:Boolean = false;
   
   public var showCompoundReport:Boolean = false;
   
   public var timeSinceLastLogin:uint = 0;
   
   public var leveledUp:Boolean = false;
   
   public var admin:Boolean = false;
   
   public var promos:Array = [];
   
   public var longSessionValidation:Boolean = false;
   
   public var promoSale:String;
   
   public var dealItem:String;
   
   public var leaderResets:int = 0;
   
   public var unequipItemBinds:Array;
   
   public function LoginFlags()
   {
      super();
   }
}
