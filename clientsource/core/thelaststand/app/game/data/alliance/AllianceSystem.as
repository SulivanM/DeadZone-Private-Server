package thelaststand.app.game.data.alliance
{
   import com.adobe.images.JPGEncoder;
   import com.dynamicflash.util.Base64;
   import com.junkbyte.console.Cc;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLRequest;
   import flash.system.Capabilities;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import org.osflash.signals.Signal;
   import playerio.Connection;
   import playerio.DatabaseObject;
   import playerio.Message;
   import playerio.PlayerIOError;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Settings;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.data.notification.NotificationFactory;
   import thelaststand.app.game.data.notification.NotificationType;
   import thelaststand.app.game.gui.alliance.banner.AllianceBannerDisplay;
   import thelaststand.app.game.gui.dialogues.AllianceIndiRewardsDialogue;
   import thelaststand.app.game.gui.dialogues.AllianceMissionSummaryDialogue;
   import thelaststand.app.game.gui.dialogues.AllianceOpponentMemberListDialogue;
   import thelaststand.app.game.logic.NotificationSystem;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.NetworkMessage;
   import thelaststand.app.network.RPCDestination;
   import thelaststand.app.network.RPCResponse;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.app.network.RoomType;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.app.utils.DictionaryUtils;
   import thelaststand.common.resources.ResourceManager;
   
   public class AllianceSystem
   {
      
      private static var _instance:AllianceSystem;
      
      private static var _rpcId:int = 0;
      
      private var _network:Network;
      
      private var _playerData:PlayerData;
      
      private var _connection:Connection;
      
      private var _connected:Boolean;
      
      private var _isConnecting:Boolean;
      
      private var _alliance:AllianceData;
      
      private var _round:AllianceRound;
      
      private var _clientMember:AllianceMember;
      
      private var _rpcCallbacks:Dictionary;
      
      private var _buildingRequirementsMet:Boolean;
      
      private var _effectCostPerDayMember:Number = 0;
      
      private var _canContributeToRound:Boolean;
      
      private var _serviceNode:XML;
      
      private var _warActive:Boolean;
      
      private var _targetsListCache:AllianceMemberList;
      
      private var _targetsListCacheTime:int = 0;
      
      private var _lifetimeStats:AllianceLifetimeStats;
      
      public var connected:Signal;
      
      public var connectionAttempted:Signal;
      
      public var connectionFailed:Signal;
      
      public var disconnected:Signal;
      
      public var kicked:Signal;
      
      public var rpcResponse:Signal;
      
      public var inviteResponseAccepted:Signal;
      
      public var inviteResponseDeclined:Signal;
      
      public var roundStarted:Signal;
      
      public var roundEnded:Signal;
      
      public var contributedToTask:Signal;
      
      public function AllianceSystem(param1:AllianceSystemSingletonEnforcer)
      {
         var _loc4_:XML = null;
         this.connected = new Signal();
         this.connectionAttempted = new Signal();
         this.connectionFailed = new Signal();
         this.disconnected = new Signal();
         this.kicked = new Signal();
         this.rpcResponse = new Signal(RPCResponse);
         this.inviteResponseAccepted = new Signal();
         this.inviteResponseDeclined = new Signal(String);
         this.roundStarted = new Signal();
         this.roundEnded = new Signal();
         this.contributedToTask = new Signal();
         super();
         if(!param1)
         {
            throw new Error("AllianceSystem is a Singleton and cannot be directly instantiated. Use AllianceSystem.getInstance().");
         }
         this._rpcCallbacks = new Dictionary(true);
         this._network = Network.getInstance();
         this._playerData = this._network.playerData;
         var _loc2_:XML = ResourceManager.getInstance().getResource("xml/alliances.xml").content as XML;
         var _loc3_:XMLList = _loc2_.services.item;
         for each(_loc4_ in _loc3_)
         {
            if(_loc4_.@id.toString().toLowerCase().indexOf(Network.getInstance().service.toLowerCase()) > -1)
            {
               this._serviceNode = _loc4_;
               break;
            }
         }
         if(this.serviceNode == null)
         {
            throw new Error("Matching alliance service node could not be found: " + Network.getInstance().service);
         }
         this._warActive = Boolean(this._serviceNode.hasOwnProperty("@active")) && this._serviceNode.@active == "1";
         this._playerData.compound.buildings.buildingAdded.add(this.onBuildingStateChange);
         this._playerData.compound.buildings.buildingRemoved.add(this.onBuildingStateChange);
         this.updateBuildingRequirementState();
         if(this._network.playerData.isAdmin)
         {
            this.setupDebug();
         }
      }
      
      public static function getInstance() : AllianceSystem
      {
         if(!_instance)
         {
            _instance = new AllianceSystem(new AllianceSystemSingletonEnforcer());
         }
         return _instance;
      }
      
      public static function getThumbURI(param1:String) : String
      {
         return "https://s3.amazonaws.com/tlsdeadzone/images/alliance_" + param1 + "_thumb.jpg";
      }
      
      public function get alliance() : AllianceData
      {
         return this._alliance;
      }
      
      public function get connection() : Connection
      {
         return this._connection;
      }
      
      public function get round() : AllianceRound
      {
         if(!this.isConnected)
         {
            if(this._round == null)
            {
               this._round = new AllianceRound();
            }
            this._round.calculateRoundData();
         }
         return this._round;
      }
      
      public function get clientMember() : AllianceMember
      {
         return this._clientMember;
      }
      
      public function get isConnected() : Boolean
      {
         return this._connected && this._connection != null && this._connection.connected;
      }
      
      public function get isConnecting() : Boolean
      {
         return this._isConnecting;
      }
      
      public function get isFounder() : Boolean
      {
         if(this._playerData.allianceId == null || this._alliance == null)
         {
            return false;
         }
         if(this._playerData.allianceId != this._alliance.id)
         {
            return false;
         }
         return this.clientMember != null && this.clientMember.rank == AllianceRank.FOUNDER;
      }
      
      public function get inAlliance() : Boolean
      {
         return this._playerData.allianceId != null && this._playerData.allianceId != "";
      }
      
      public function get isEnlisting() : Boolean
      {
         return this.inAlliance && this.clientMember != null && this.clientMember.joinDate.time > this.round.activeTime.time;
      }
      
      public function get isRoundActive() : Boolean
      {
         return Network.getInstance().serverTime > this.round.activeTime.time;
      }
      
      public function get alliancesEnabled() : Boolean
      {
         return Settings.getInstance().alliancesEnabled;
      }
      
      public function get buildingRequirementsMet() : Boolean
      {
         return this._buildingRequirementsMet;
      }
      
      public function get canContributeToRound() : Boolean
      {
         return this._canContributeToRound;
      }
      
      public function get serviceNode() : XML
      {
         return this._serviceNode;
      }
      
      public function get warActive() : Boolean
      {
         return this._warActive;
      }
      
      public function hasBannerProtection(param1:String) : Boolean
      {
         if(!this.isConnected || this._alliance == null)
         {
            return false;
         }
         return this._alliance.hasBannerProtection(param1);
      }
      
      public function getAttackedTargetData(param1:String) : Object
      {
         if(!this.isConnected || this._alliance == null)
         {
            return null;
         }
         return this._alliance.getAttackedTargetData(param1);
      }
      
      public function hasScoutingProtection(param1:String) : Boolean
      {
         if(!this.isConnected || this._alliance == null)
         {
            return false;
         }
         return this._alliance.hasScoutingProtection(param1);
      }
      
      public function getScoutingData(param1:String) : Object
      {
         if(!this.isConnected || this._alliance == null)
         {
            return null;
         }
         return this._alliance.getScoutingData(param1);
      }
      
      public function acceptInvite(param1:String) : void
      {
         if(this.isConnected || param1 == null)
         {
            return;
         }
         this.internalConnect(param1,true);
      }
      
      public function connect() : void
      {
         if(this._playerData.allianceId == null)
         {
            return;
         }
         this.internalConnect(this._playerData.allianceId,false);
      }
      
      public function disconnect() : void
      {
         if(this._connection == null || !this._connection.connected)
         {
            return;
         }
         this._connection.disconnect();
         this.onDisconnected();
      }
      
      public function saveBanner(param1:AllianceBannerData, param2:String, param3:Function = null) : void
      {
         if(!this.isConnected || this._alliance == null || param1 == null)
         {
            return;
         }
         var _loc4_:JPGEncoder = new JPGEncoder(90);
         var _loc5_:String = Base64.encodeByteArray(param1.byteArray);
         this.sendRPC("svbnr",{
            "hex":param1.hexString,
            "data":_loc5_,
            "thumb":param2
         },param3);
      }
      
      public function postMessage(param1:String, param2:String, param3:Function = null) : void
      {
         if(this._clientMember == null)
         {
            return;
         }
         this.sendRPC("pmsg",{
            "sub":param1,
            "body":param2
         },param3);
      }
      
      public function deleteMessage(param1:String, param2:Function = null) : void
      {
         this.sendRPC("dmsg",{"id":param1},param2);
      }
      
      public function inviteMember(param1:String, param2:Function = null) : void
      {
         this.sendRPC("invite",{"id":param1},param2);
      }
      
      public function kickMember(param1:AllianceMember, param2:Function = null) : void
      {
         this.sendRPC("kick",{"id":param1.id},param2);
      }
      
      public function changeMemberRank(param1:String, param2:uint, param3:Function = null) : void
      {
         this.sendRPC("rank",{
            "id":param1,
            "rank":param2
         },param3);
      }
      
      public function changeRankName(param1:uint, param2:String, param3:Function = null) : void
      {
         this.sendRPC("rankname",{
            "rank":param1,
            "name":param2
         },param3);
      }
      
      public function leaveAlliance(param1:Function = null) : void
      {
         this.sendRPC("kick",{"id":this._playerData.id},param1);
      }
      
      public function disbandAlliance(param1:Function = null) : void
      {
         if(!this.isFounder)
         {
            return;
         }
         this.sendRPC("disband",null,param1);
      }
      
      public function getIndividualTargetsList(param1:int, param2:Function) : void
      {
         var now:int = 0;
         var expire:int = 0;
         var count:int = param1;
         var callback:Function = param2;
         if(!this.isConnected)
         {
            return;
         }
         now = getTimer();
         expire = this._targetsListCacheTime + 2 * 60 * 1000;
         if(this._targetsListCache != null && this._targetsListCache.numMembers > 0 && getTimer() < expire)
         {
            callback(this._targetsListCache);
            return;
         }
         this.sendRPC("getIndividualTargetsList",{"count":count},function(param1:RPCResponse):void
         {
            if(param1.success == false)
            {
               callback(null);
               return;
            }
            _targetsListCacheTime = getTimer();
            _targetsListCache = new AllianceMemberList();
            _targetsListCache.deserialize(param1.data);
            callback(_targetsListCache);
         });
      }
      
      public function touchIndividualTargetCacheTime() : void
      {
         this._targetsListCacheTime = getTimer();
      }
      
      public function clearIndividualTargetCacheTime() : void
      {
         this._targetsListCacheTime = 0;
      }
      
      public function getAllianceTargetList(param1:int, param2:Function) : void
      {
         var count:int = param1;
         var callback:Function = param2;
         if(!this.isConnected)
         {
            return;
         }
         this.sendRPC("getSuggestedAlliances",{"count":count},function(param1:RPCResponse):void
         {
            if(param1.success == false)
            {
               callback(null);
               return;
            }
            var _loc2_:AllianceList = new AllianceList();
            _loc2_.deserialize(param1.data);
            callback(_loc2_);
         });
      }
      
      public function getOpponentMemberList(param1:String, param2:Function) : void
      {
         var allianceId:String = param1;
         var callback:Function = param2;
         if(!this.isConnected)
         {
            return;
         }
         this.sendRPC("getOpponentAllianceMembers",{"allianceId":allianceId},function(param1:RPCResponse):void
         {
            if(param1.success == false)
            {
               callback(null);
               return;
            }
            var _loc2_:AllianceMemberList = new AllianceMemberList();
            _loc2_.deserialize(param1.data);
            callback(_loc2_);
         });
      }
      
      public function getMemberLeaderboard(param1:int, param2:Function) : void
      {
         var round:int = param1;
         var callback:Function = param2;
         if(!this.isConnected)
         {
            return;
         }
         this.sendRPC("getMemberLeaderboard",{"round":round},function(param1:RPCResponse):void
         {
            if(param1.success == false)
            {
               callback(null);
               return;
            }
            var _loc2_:AllianceMemberList = new AllianceMemberList();
            _loc2_.deserialize(param1.data);
            callback(_loc2_);
         });
      }
      
      public function getPreviousRoundWinners(param1:Function) : void
      {
         var callback:Function = param1;
         Network.getInstance().save(null,SaveDataMethod.ALLIANCE_GET_PREV_ROUND_RESULT,function(param1:Object):void
         {
            if(param1.available == false)
            {
               callback(false,null);
               return;
            }
            var _loc2_:AllianceList = new AllianceList();
            _loc2_.deserialize(param1.list);
            callback(true,_loc2_);
         });
      }
      
      public function getLastRoundRanks(param1:Function) : void
      {
         var callback:Function = param1;
         if(!this.isConnected)
         {
            return;
         }
         this.sendRPC("getLastRoundRanks",null,function(param1:RPCResponse):void
         {
            if(!isConnected)
            {
               return;
            }
            if(param1.success == false || param1.data.available == false)
            {
               callback(false,null,-1,-1);
               return;
            }
            var _loc2_:AllianceDataSummary = new AllianceDataSummary(null);
            _loc2_.deserialize(param1.data.alliance);
            callback(param1.data.available,_loc2_,param1.data.allianceRank,param1.data.memberRank);
         });
      }
      
      public function getMemberContributionList(param1:Function) : void
      {
         var callback:Function = param1;
         if(!this.isConnected)
         {
            return;
         }
         this.sendRPC("getMemberContributions",null,function(param1:RPCResponse):void
         {
            if(param1.success == false)
            {
               callback(null);
               return;
            }
            callback(param1.data);
         });
      }
      
      public function getLifetimeStats(param1:Function) : void
      {
         var callback:Function = param1;
         if(this._lifetimeStats != null)
         {
            callback(true,this._lifetimeStats);
            return;
         }
         Network.getInstance().save(null,SaveDataMethod.ALLIANCE_GET_LIFETIMESTATS,function(param1:Object):void
         {
            if(param1.available == false)
            {
               callback(false,null);
               return;
            }
            _lifetimeStats = new AllianceLifetimeStats();
            _lifetimeStats.deserialize(param1);
            _lifetimeStats.userName = Network.getInstance().playerData.nickname;
            callback(true,_lifetimeStats);
         });
      }
      
      public function invalidateLifetimeStats() : void
      {
         this._lifetimeStats = null;
      }
      
      public function buyEffect(param1:int, param2:Function = null) : void
      {
         this.sendRPC("beff",{"i":param1},param2);
      }
      
      public function contributeToTask(param1:AllianceTask, param2:int, param3:Function = null) : void
      {
         var task:AllianceTask = param1;
         var amount:int = param2;
         var callback:Function = param3;
         if(this._alliance == null)
         {
            return;
         }
         this.sendRPC("tcon",{
            "i":this._alliance.getTaskIndex(task),
            "a":amount
         },function(param1:RPCResponse):void
         {
            if(param1.success)
            {
               contributedToTask.dispatch();
            }
            callback(param1);
         });
      }
      
      public function getEffectCost(param1:int) : int
      {
         if(this._alliance == null || param1 < 0 || param1 >= Config.constant.ALLIANCE_EFFECT_BASE_COUNT)
         {
            return 0;
         }
         var _loc2_:Number = Math.max(this._round.memberCount,2) * this._effectCostPerDayMember * Math.max(this._round.daysRemaining,1);
         return int(Math.max(Config.constant.ALLIANCE_EFFECT_MIN_COST,Math.ceil(_loc2_ / 5) * 5));
      }
      
      public function canAccessAlliances() : Boolean
      {
         if(!this.alliancesEnabled)
         {
            return false;
         }
         if(this._playerData.getPlayerSurvivor().level < int(Config.constant.ALLIANCE_MIN_JOIN_LEVEL))
         {
            return false;
         }
         if(!this.buildingRequirementsMet)
         {
            return false;
         }
         if(this.inAlliance && !this._connected)
         {
            return false;
         }
         return true;
      }
      
      public function sendRPC(param1:String, param2:Object = null, param3:Function = null) : void
      {
         if(!this.isConnected)
         {
            return;
         }
         var _loc4_:int = int(_rpcId++);
         var _loc5_:Message = this._connection.createMessage("rpc",RPCDestination.Client,RPCDestination.AllianceServer,_loc4_,param1);
         if(param2 != null)
         {
            _loc5_.add(JSON.stringify(param2));
         }
         if(param3 != null)
         {
            this._rpcCallbacks[_loc4_] = param3;
         }
         this._connection.sendMessage(_loc5_);
      }
      
      private function internalConnect(param1:String, param2:Boolean = false, param3:Boolean = false) : void
      {
         if(this._connection != null && this._connection.connected)
         {
            return;
         }
         if(param1 == null)
         {
            return;
         }
         var _loc4_:Object = {
            "id":param1,
            "service":this._network.service
         };
         var _loc5_:Object = {
            "invited":(param2 ? 1 : 0),
            "forceAdmin":(param3 ? 1 : 0)
         };
         this._isConnecting = true;
         this.connectionAttempted.dispatch();
         this._network.client.multiplayer.createJoinRoom("A_" + param1,RoomType.ALLIANCE,false,_loc4_,_loc5_,this.onConnected,this.onConnectionError);
      }
      
      private function updateBuildingRequirementState() : void
      {
         var _loc2_:TimerData = null;
         this._buildingRequirementsMet = false;
         var _loc1_:Building = this._playerData.compound.buildings.getFirstBuildingOfType("alliance-flag");
         if(_loc1_ != null)
         {
            if(_loc1_.isUnderConstruction())
            {
               _loc2_ = _loc1_.upgradeTimer;
               if(_loc2_ != null)
               {
                  _loc2_.completed.addOnce(this.onAllianceFlagTimerComplete);
               }
            }
            else
            {
               this._buildingRequirementsMet = true;
            }
         }
      }
      
      public function informServerOfAllianceLeave(param1:String) : void
      {
         Network.getInstance().save({"allianceId":param1},SaveDataMethod.ALLIANCE_INFORM_ABOUT_LEAVE,null);
      }
      
      private function onAllianceFlagTimerComplete(param1:TimerData) : void
      {
         this.updateBuildingRequirementState();
      }
      
      private function onBuildingStateChange(param1:Building) : void
      {
         if(param1.type == "alliance-flag")
         {
            this.updateBuildingRequirementState();
         }
      }
      
      private function onConnected(param1:Connection) : void
      {
         this._isConnecting = false;
         this._connection = param1;
         this._connection.addDisconnectHandler(this.onDisconnected);
         this._connection.addMessageHandler("allianceData",this.onAllianceDataReceived);
         this._connection.addMessageHandler("invAcc",this.onMessageReceived);
         this._connection.addMessageHandler("invDec",this.onMessageReceived);
         this._connection.addMessageHandler("connRejected",this.onMessageReceived);
         this._connection.addMessageHandler("refreshRoom",this.onMessageReceived);
         this._connection.addMessageHandler("_tev",Tracking.trackEventMessage);
      }
      
      private function onDisconnected() : void
      {
         this._isConnecting = false;
         DictionaryUtils.clear(this._rpcCallbacks);
         if(this._connection != null)
         {
            this.removeMessageHandlers();
            this._connection.removeDisconnectHandler(this.onDisconnected);
            this._connection.removeMessageHandler("_tev",Tracking.trackEventMessage);
            this._connection.removeMessageHandler("rpcr",this.onRPCResponseReceived);
            this._connection.removeMessageHandler("enemylist",this.onMessageReceived);
            this._connection.removeMessageHandler("refreshRoom",this.onMessageReceived);
            this._connection = null;
         }
         if(this._connected || this._isConnecting)
         {
            this._isConnecting = false;
            this._connected = false;
            if(this._network.isConnected)
            {
               this.disconnected.dispatch();
               if(this._playerData.allianceId != null)
               {
                  setTimeout(this.connect,30 * 1000);
               }
            }
         }
         this._clientMember = null;
         this._alliance = null;
      }
      
      private function addMessageHandlers() : void
      {
         if(this._connection == null)
         {
            return;
         }
         this._connection.addMessageHandler("rpc",this.onRPCReceived);
         this._connection.addMessageHandler("rpcr",this.onRPCResponseReceived);
         this._connection.addMessageHandler("memberOnline",this.onMessageReceived);
         this._connection.addMessageHandler("memberOffline",this.onMessageReceived);
         this._connection.addMessageHandler("memberAdded",this.onMessageReceived);
         this._connection.addMessageHandler("memberRemoved",this.onMessageReceived);
         this._connection.addMessageHandler("messageAdded",this.onMessageReceived);
         this._connection.addMessageHandler("messageRemoved",this.onMessageReceived);
         this._connection.addMessageHandler("bannerChanged",this.onMessageReceived);
         this._connection.addMessageHandler("rankChanged",this.onMessageReceived);
         this._connection.addMessageHandler("rankNameChanged",this.onMessageReceived);
         this._connection.addMessageHandler("pvUpdate",this.onMessageReceived);
         this._connection.addMessageHandler("kicked",this.onMessageReceived);
         this._connection.addMessageHandler("disband",this.onMessageReceived);
         this._connection.addMessageHandler("effectPurchase",this.onMessageReceived);
         this._connection.addMessageHandler("roundStart",this.onMessageReceived);
         this._connection.addMessageHandler("roundEnd",this.onMessageReceived);
         this._connection.addMessageHandler("points",this.onMessageReceived);
         this._connection.addMessageHandler("tokens",this.onMessageReceived);
         this._connection.addMessageHandler("taskProgress",this.onMessageReceived);
         this._connection.addMessageHandler("taskComplete",this.onMessageReceived);
         this._connection.addMessageHandler("mend",this.onMessageReceived);
         this._connection.addMessageHandler("enemylist",this.onMessageReceived);
         this._connection.addMessageHandler("atkTrgs",this.onMessageReceived);
         this._connection.addMessageHandler("sctTrgs",this.onMessageReceived);
         this._connection.addMessageHandler("playerScoreUpdate",this.onMessageReceived);
      }
      
      private function removeMessageHandlers() : void
      {
         if(this._connection == null)
         {
            return;
         }
         this._connection.removeMessageHandler("allianceData",this.onAllianceDataReceived);
         this._connection.removeMessageHandler("rpc",this.onRPCReceived);
         this._connection.removeMessageHandler("invAcc",this.onMessageReceived);
         this._connection.removeMessageHandler("invDec",this.onMessageReceived);
         this._connection.removeMessageHandler("memberOnline",this.onMessageReceived);
         this._connection.removeMessageHandler("memberOffline",this.onMessageReceived);
         this._connection.removeMessageHandler("memberAdded",this.onMessageReceived);
         this._connection.removeMessageHandler("memberRemoved",this.onMessageReceived);
         this._connection.removeMessageHandler("messageAdded",this.onMessageReceived);
         this._connection.removeMessageHandler("messageRemoved",this.onMessageReceived);
         this._connection.removeMessageHandler("bannerChanged",this.onMessageReceived);
         this._connection.removeMessageHandler("kicked",this.onMessageReceived);
         this._connection.removeMessageHandler("rankChanged",this.onMessageReceived);
         this._connection.removeMessageHandler("rankNameChanged",this.onMessageReceived);
         this._connection.removeMessageHandler("pvUpdate",this.onMessageReceived);
         this._connection.removeMessageHandler("disband",this.onMessageReceived);
         this._connection.removeMessageHandler("effectPurchase",this.onMessageReceived);
         this._connection.removeMessageHandler("roundStart",this.onMessageReceived);
         this._connection.removeMessageHandler("roundEnd",this.onMessageReceived);
         this._connection.removeMessageHandler("points",this.onMessageReceived);
         this._connection.removeMessageHandler("tokens",this.onMessageReceived);
         this._connection.removeMessageHandler("taskProgress",this.onMessageReceived);
         this._connection.removeMessageHandler("taskComplete",this.onMessageReceived);
         this._connection.removeMessageHandler("mend",this.onMessageReceived);
         this._connection.removeMessageHandler("atkTrgs",this.onMessageReceived);
         this._connection.removeMessageHandler("sctTrgs",this.onMessageReceived);
         this._connection.removeMessageHandler("connRejected",this.onMessageReceived);
         this._connection.removeMessageHandler("refreshRoom",this.onMessageReceived);
         this._connection.removeMessageHandler("playerScoreUpdate",this.onMessageReceived);
      }
      
      private function onAllianceDataReceived(param1:Message) : void
      {
         var data:Object = null;
         var newAlliance:AllianceData = null;
         var newClientMember:AllianceMember = null;
         var msg:Message = param1;
         try
         {
            data = JSON.parse(msg.getString(0));
            newAlliance = new AllianceData(data.id);
            newAlliance.messages.lastViewedDate = this._network.playerData.lastLogout;
            newAlliance.deserialize(data);
            if("rankPrivs" in data)
            {
               AllianceRank.deserialize(JSON.parse(String(data.rankPrivs)));
            }
            this._round = new AllianceRound();
            this._round.deserialize(data);
            this._canContributeToRound = Boolean(data.canContribute);
            this._effectCostPerDayMember = Number(data["effectCost"]);
            newClientMember = newAlliance.members.getMemberById(this._playerData.id);
            if(newClientMember == null)
            {
               throw new Error("Player member record was not found in this alliance.");
            }
            this._alliance = newAlliance;
            this._clientMember = newClientMember;
            this._playerData.allianceId = this._alliance.id;
            this._playerData.allianceTag = this._alliance.tag;
            this.addMessageHandlers();
            this._connected = true;
            this.connected.dispatch();
            this.checkAndRepairThumbnail();
            if(this._alliance.points > 0 && this._warActive && this._playerData.compound.hasPermanentEffect(EffectType.getTypeValue("DisablePvP")))
            {
               this.sendRPC("clearRndPts",{"reason":"whiteflag"});
            }
         }
         catch(error:Error)
         {
            if(Capabilities.isDebugger)
            {
               _network.client.errorLog.writeError("Alliance connection error",error.message,error.getStackTrace(),{
                  "player":_network.playerData.id,
                  "alliance":_network.playerData.allianceId,
                  "tag":_network.playerData.allianceTag
               });
               throw error;
            }
            if(!_connected)
            {
               disconnect();
            }
         }
      }
      
      private function onMessageReceived(param1:Message) : void
      {
         var i:int = 0;
         var j:int = 0;
         var json:String = null;
         var member:AllianceMember = null;
         var memberData:Object = null;
         var msgData:Object = null;
         var rankId:uint = 0;
         var rankName:String = null;
         var numEffects:int = 0;
         var numTasks:int = 0;
         var a:Array = null;
         var obj:Object = null;
         var obj2:Object = null;
         var tIndex:int = 0;
         var tValue:int = 0;
         var msg:Message = param1;
         switch(msg.type)
         {
            case "invAcc":
               this.inviteResponseAccepted.dispatch();
               break;
            case "invDec":
               this.inviteResponseDeclined.dispatch(msg.length > 0 ? msg.getString(0) : "error");
               break;
            case "connRejected":
               this.onDisconnected();
               this._playerData.allianceId = null;
               this._playerData.allianceTag = null;
               break;
            case "memberOnline":
               member = this._alliance.members.getMemberById(msg.getString(0));
               if(member != null)
               {
                  member.isOnline = true;
               }
               break;
            case "memberOffline":
               member = this._alliance.members.getMemberById(msg.getString(0));
               if(member != null)
               {
                  member.isOnline = false;
               }
               break;
            case "memberAdded":
               memberData = JSON.parse(msg.getString(0));
               this._alliance.members.addMember(new AllianceMember(memberData));
               break;
            case "memberRemoved":
               this._alliance.members.removeMemberById(msg.getString(0));
               break;
            case "messageAdded":
               msgData = JSON.parse(msg.getString(0));
               this._alliance.messages.addMessage(new AllianceMessage(msgData));
               break;
            case "messageRemoved":
               this._alliance.messages.removeMessageById(msg.getString(0));
               break;
            case "bannerChanged":
               this._alliance.banner.byteArray = msg.getByteArray(0);
               break;
            case "rankChanged":
               member = this._alliance.members.getMemberById(msg.getString(0));
               if(member != null)
               {
                  member.rank = msg.getUInt(1);
               }
               if(msg.getString(0) == this._playerData.id)
               {
                  NotificationSystem.getInstance().addNotification(NotificationFactory.createNotification(NotificationType.ALLIANCE_RANK_CHANGE,{
                     "rank":msg.getUInt(1),
                     "allianceId":this._alliance.id
                  }));
               }
               break;
            case "rankNameChanged":
               rankId = msg.getUInt(0);
               rankName = msg.getString(1);
               this._alliance.setRankName(rankId,rankName);
               break;
            case "disband":
               NotificationSystem.getInstance().addNotification(NotificationFactory.createNotification(NotificationType.ALLIANCE_DISBANDED,{"allianceName":this._alliance.name}));
               this._alliance.clearEffects();
               this._network.save({"id":this._alliance.id},SaveDataMethod.ALLIANCE_EFFECT_UPDATE);
               this._playerData.allianceId = null;
               this._playerData.allianceTag = null;
               this.informServerOfAllianceLeave(this._alliance.id);
               this.removeMessageHandlers();
               break;
            case "kicked":
               if(msg.getString(0) != this._playerData.id)
               {
                  NotificationSystem.getInstance().addNotification(NotificationFactory.createNotification(NotificationType.ALLIANCE_MEMBERSHIP_REVOKED,{"allianceName":this._alliance.name}));
               }
               this._alliance.clearEffects();
               this._network.save({"id":this._alliance.id},SaveDataMethod.ALLIANCE_EFFECT_UPDATE);
               this.informServerOfAllianceLeave(this._playerData.allianceId);
               this._playerData.allianceId = null;
               this._playerData.allianceTag = null;
               this.removeMessageHandlers();
               this.kicked.dispatch();
               break;
            case "pvUpdate":
               this._playerData.compound.resources.setAmount(GameResources.CASH,msg.getUInt(0));
               this._network.send(NetworkMessage.PURCHASE_COINS);
               break;
            case "effectPurchase":
               this._network.save({"id":this._alliance.id},SaveDataMethod.ALLIANCE_EFFECT_UPDATE);
               this._alliance.setTokens(msg.getInt(0));
               numEffects = msg.getInt(1);
               i = 0;
               j = 2;
               while(i < numEffects)
               {
                  this._alliance.addEffect(msg.getInt(j++),msg.getByteArray(j++));
                  i++;
               }
               break;
            case "points":
               this._alliance.setPoints(msg.getInt(0));
               break;
            case "tokens":
               this._alliance.setTokens(msg.getInt(0));
               break;
            case "roundStart":
               this.handleRoundStart(msg);
               break;
            case "roundEnd":
               this._alliance.setPoints(msg.getInt(0));
               this._round.deserialize({
                  "roundNum":msg.getInt(1),
                  "roundActive":msg.getNumber(2),
                  "roundEnd":msg.getNumber(3)
               });
               this.roundEnded.dispatch();
               break;
            case "taskProgress":
               numTasks = msg.getInt(0);
               i = 0;
               j = 1;
               while(i < numTasks)
               {
                  tIndex = msg.getInt(j++);
                  tValue = msg.getInt(j++);
                  this._alliance.getTask(tIndex).setValue(tValue);
                  i++;
               }
               break;
            case "taskComplete":
               this._alliance.setTaskCompleted(msg.getInt(0));
               this._alliance.setTokens(msg.getInt(1));
               break;
            case "playerScoreUpdate":
               if(this.clientMember != null)
               {
                  this.clientMember.setPoints(msg.getInt(0));
               }
               break;
            case "mend":
               this._alliance.setPoints(msg.getInt(0));
               break;
            case "enemylist":
               json = msg.getString(0);
               if(json == "")
               {
                  return;
               }
               a = null;
               try
               {
                  a = JSON.parse(json) as Array;
               }
               catch(e:Error)
               {
                  return;
               }
               this._alliance.enemies.deserialize(a);
               break;
            case "atkTrgs":
               json = msg.getString(0);
               if(json == "")
               {
                  return;
               }
               obj = null;
               try
               {
                  obj = JSON.parse(json);
               }
               catch(e:Error)
               {
                  return;
               }
               this._alliance.parseAttackedTargets(obj);
               break;
            case "sctTrgs":
               json = msg.getString(0);
               if(json == "")
               {
                  return;
               }
               obj2 = null;
               try
               {
                  obj2 = JSON.parse(json);
               }
               catch(e:Error)
               {
                  return;
               }
               this._alliance.parseScoutedTargets(obj2);
         }
      }
      
      private function handleRoundStart(param1:Message) : void
      {
         this._alliance.setPoints(0);
         this._alliance.setEffiency(0);
         this._alliance.clearEffects();
         this._alliance.clearAttackedTargets();
         this._alliance.clearScoutedTargets();
         var _loc2_:int = 0;
         this._round.setMemberCount(param1.getInt(_loc2_++));
         this._alliance.setTaskSet(param1.getInt(_loc2_++));
         this._round.setEffectSet(JSON.parse(param1.getString(_loc2_++)) as Array);
         this._canContributeToRound = true;
         this.roundStarted.dispatch();
      }
      
      private function handleRPCResponse(param1:RPCResponse) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:AllianceMember = null;
         if(!param1.success)
         {
            return;
         }
         switch(param1.type)
         {
            case "disband":
               this._playerData.allianceId = null;
               this._playerData.allianceTag = null;
               break;
            case "kicked":
               this._playerData.allianceId = null;
               this._playerData.allianceTag = null;
               this.disconnect();
               break;
            case "rankname":
               this._alliance.setRankName(uint(param1.data.rank),String(param1.data.name));
               break;
            case "rank":
               _loc2_ = uint(param1.data.rank);
               if(_loc2_ == AllianceRank.FOUNDER)
               {
                  if(this.clientMember != null && this.clientMember.rank == AllianceRank.FOUNDER)
                  {
                     this.clientMember.rank = AllianceRank.TWO_IC;
                  }
               }
               _loc3_ = this._alliance.members.getMemberById(String(param1.data.id));
               if(_loc3_ != null)
               {
                  _loc3_.rank = _loc2_;
               }
               break;
            case "svbnr":
               this._alliance.setNumOfBannerEdits(uint(param1.data.edits));
         }
      }
      
      private function onRPCReceived(param1:Message) : void
      {
         if(param1.length >= 2 && param1.getInt(1) != RPCDestination.Client)
         {
            this._network.forwardRPC(this._connection,param1);
            return;
         }
      }
      
      private function onRPCResponseReceived(param1:Message) : void
      {
         if(param1.length >= 2 && param1.getInt(1) != RPCDestination.Client)
         {
            this._network.forwardRPC(this._connection,param1);
            return;
         }
         if(param1.length < 5)
         {
            return;
         }
         var _loc2_:RPCResponse = RPCResponse.parse(param1);
         this.handleRPCResponse(_loc2_);
         var _loc3_:Function = this._rpcCallbacks[_loc2_.id];
         if(_loc3_ != null)
         {
            _loc3_(_loc2_);
            delete this._rpcCallbacks[_loc2_.id];
         }
         this.rpcResponse.dispatch(_loc2_);
      }
      
      private function onConnectionError(param1:PlayerIOError) : void
      {
         this.connectionFailed.dispatch();
         if(this._playerData.allianceId != null)
         {
            setTimeout(this.connect,30 * 1000);
         }
      }
      
      public function adminConnect(param1:String) : void
      {
         var allianceString:String = param1;
         if(this.isConnected)
         {
            this.disconnect();
         }
         this.parseAllianceString(allianceString,function(param1:String):void
         {
            if(param1 != "")
            {
               internalConnect(param1,false,true);
            }
         });
      }
      
      public function parseAllianceString(param1:String, param2:Function) : void
      {
         var allianceString:String = param1;
         var callback:Function = param2;
         if(!allianceString)
         {
            callback("");
         }
         else if(allianceString.length > 3)
         {
            callback(allianceString);
         }
         else
         {
            Network.getInstance().client.bigDB.loadSingle("AllianceSummary","ByTag",[allianceString.toLowerCase()],function(param1:DatabaseObject):void
            {
               if(param1 != null)
               {
                  callback(param1.key);
               }
               else
               {
                  callback("");
               }
            },function(param1:PlayerIOError):void
            {
               callback("");
            });
         }
      }
      
      private function checkAndRepairThumbnail() : void
      {
         var _loc1_:Loader = new Loader();
         _loc1_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onThumbnailTestLoad,false,0,true);
         _loc1_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onCheckRepairError,false,0,true);
         _loc1_.load(new URLRequest(getThumbURI(this._alliance.id)));
      }
      
      private function onThumbnailTestLoad(param1:Event) : void
      {
         if(LoaderInfo(param1.target).bytesTotal <= 1)
         {
            this.onCheckRepairError(null);
         }
      }
      
      private function onCheckRepairError(param1:IOErrorEvent) : void
      {
         var _loc2_:AllianceBannerDisplay = AllianceBannerDisplay.getInstance();
         if(!this.isConnected || this._alliance == null || _loc2_ == null)
         {
            return;
         }
         if(_loc2_.ready)
         {
            this.regenerateThumbnail();
         }
         else
         {
            _loc2_.onReady.addOnce(this.regenerateThumbnail);
         }
      }
      
      private function regenerateThumbnail() : void
      {
         if(!this.isConnected || this._alliance == null)
         {
            return;
         }
         var _loc1_:AllianceBannerDisplay = AllianceBannerDisplay.getInstance();
         _loc1_.hexString = this._alliance.banner.hexString;
         var _loc2_:JPGEncoder = new JPGEncoder(90);
         var _loc3_:String = Base64.encodeByteArray(_loc2_.encode(_loc1_.generateThumbnail()));
         this.sendRPC("rfshthm",{"thumb":_loc3_},null);
      }
      
      public function calcMissionScore(param1:int, param2:Boolean) : int
      {
         if(!this.inAlliance || this.isEnlisting || this._playerData.compound.hasPermanentEffect(EffectType.getTypeValue("DisablePvP")))
         {
            return 0;
         }
         var _loc3_:int = int(this._playerData.getPlayerSurvivor().level);
         if(param1 < _loc3_ - 10)
         {
            return 0;
         }
         var _loc4_:int = int(Math.ceil((_loc3_ + 1) / 10));
         if(param2)
         {
            _loc4_ *= 2;
         }
         return _loc4_;
      }
      
      private function setupDebug() : void
      {
         var args:Array = null;
         Cc.addSlashCommand("giveTokens",function(param1:String = ""):void
         {
            args = param1.split(/\s+/);
            sendRPC("giveTokens",{"t":int(args[0])});
         },"Gives alliance tokens [amount]");
         Cc.addSlashCommand("roundEnd",function(param1:String = ""):void
         {
            if(_clientMember)
            {
               _clientMember.setPoints(0);
            }
            _alliance.setPoints(0);
            _round.deserialize({
               "roundNum":_round.number + 1,
               "roundActive":_round.endTime.time + 10000,
               "roundEnd":_round.endTime.time + 30000
            });
            roundEnded.dispatch();
         },"Simulates the current round ending.");
         Cc.addSlashCommand("roundStart",function(param1:String = ""):void
         {
            sendRPC("roundStart");
         },"Simulates a new round starting.");
         Cc.addSlashCommand("allianceList",function(param1:String = ""):void
         {
            var allianceString:String;
            var params:String = param1;
            args = params.split(/\s+/);
            if(args.length == 0)
            {
               return;
            }
            allianceString = args[0];
            parseAllianceString(allianceString,function(param1:String):void
            {
               if(param1 == "")
               {
                  return;
               }
               var _loc2_:AllianceOpponentMemberListDialogue = new AllianceOpponentMemberListDialogue(param1,"Debug","no tag");
               _loc2_.open();
            });
         },"Opens the opponents list");
         Cc.addSlashCommand("allianceJoin",function(param1:String = ""):void
         {
            args = param1.split(/\s+/);
            if(args.length == 0)
            {
               return;
            }
            var _loc2_:String = args[0];
            adminConnect(_loc2_);
         },"Forces you into the given alliance temporarily");
         Cc.addSlashCommand("allianceClose",function(param1:String = ""):void
         {
            args = param1.split(/\s+/);
            sendRPC("closeRoom");
         },"Closes the current alliance room");
         Cc.addSlashCommand("allianceResults",function(param1:String = ""):void
         {
            args = param1.split(/\s+/);
            var _loc2_:MissionData = new MissionData();
            var _loc3_:Boolean = args.length > 0 ? args[0] == "true" : true;
            if(_loc3_)
            {
               _loc2_.opponent = new RemotePlayerData("fb100004416123532");
            }
            _loc2_.allianceFlagCaptured = _loc2_.allContainersSearched = args.length > 1 ? args[1] == "true" : true;
            _loc2_.allianceAttackerWinPoints = 15;
            var _loc4_:AllianceMissionSummaryDialogue = new AllianceMissionSummaryDialogue(_loc2_);
            _loc4_.open();
         },"Test open the alliance results");
         Cc.addSlashCommand("allianceIndi",function(param1:String = ""):void
         {
            var _loc2_:Array = [{
               "level":0,
               "type":"cash",
               "qty":50,
               "id":"5F14-7A42-4919-BF1C-83E89CCF575B"
            }];
            var _loc3_:AllianceIndiRewardsDialogue = new AllianceIndiRewardsDialogue({
               "rewardScore":13,
               "items":_loc2_
            });
            _loc3_.open();
         },"Test open the alliance results");
      }
   }
}

class AllianceSystemSingletonEnforcer
{
   
   public function AllianceSystemSingletonEnforcer()
   {
      super();
   }
}
