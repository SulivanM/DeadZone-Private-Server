package thelaststand.app.game.logic
{
   import org.osflash.signals.Signal;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.Game;
   import thelaststand.app.game.gui.dialogues.InventoryFullDialogue;
   import thelaststand.app.game.gui.dialogues.TradeRequestDialog;
   import thelaststand.app.game.gui.dialogues.TradingDialog;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.RoomType;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.app.network.chat.ChatSystem;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class TradeSystem
   {
      
      private static var _instance:TradeSystem;
      
      public static const NO_REASON:int = -1;
      
      public static const CANCEL_TRADING_WITH_SOMEONE_ELSE:int = -2;
      
      public static const CANCEL_TRADING_WITH_THIS_PERSON:int = -3;
      
      public static const CANCEL_OTHER_PERSON_OFFLINE:int = -4;
      
      public static const CANCEL_TRADE_OFFER_EXPIRED:int = -5;
      
      public static const CANCEL_UNKNOWN_ERROR:int = -6;
      
      public static const CANCEL_OTHER_USER_LEFT:int = -7;
      
      public static const CANCEL_REQUEST_CANCELED:int = -8;
      
      public static const CANCEL_THEYRE_BUSY:int = -9;
      
      public static const CANCEL_OUTSIDE_RANGE:int = -10;
      
      public static const CANCEL_ZOMBIE_ATTACK:int = -11;
      
      public static const CANCEL_FULL_INVENTORY:int = -12;
      
      private static const CMD_TRADE_REQUEST:String = "trade_tradeRequest";
      
      private static const CMD_TRADE_REQUEST_REJECT:String = "trade_tradeRequestReject";
      
      private static const CMD_TRADE_REQUEST_ACCEPT:String = "trade_tradeRequestAccept";
      
      private static const CMD_TRADE_REQUEST_COMPLETE:String = "trade_tradeRequestComplete";
      
      private static const CMD_CLOSE_TRADE:String = "trade_closeTrade";
      
      private var _game:Game;
      
      private var _chatSystem:ChatSystem;
      
      private var _chatChannel:String = "";
      
      private var tradePartnerInfo:TradePartnerInfo;
      
      private var tradingDialog:TradingDialog;
      
      private var tradeRequestDialog:TradeRequestDialog;
      
      public var onTradeRequestResponse:Signal = new Signal(String,Boolean,int);
      
      public var onCancelTradeRequests:Signal = new Signal();
      
      public var isTradeSystemEnabled:Boolean = true;
      
      public function TradeSystem(param1:TradeSystemSingletonEnforcer)
      {
         super();
         if(!param1)
         {
            throw new Error("TradeSystem is a Singleton and cannot be directly instantiated. Use TradeSystem.getInstance().");
         }
         this._chatSystem = Network.getInstance().chatSystem;
         this._chatSystem.onCommandReceived.add(this.onChatCommandReceived);
         this._chatSystem.onTargetUserNotOnline.add(this.onChatUserNotOnline);
      }
      
      public static function getInstance() : TradeSystem
      {
         if(!_instance)
         {
            _instance = new TradeSystem(new TradeSystemSingletonEnforcer());
         }
         return _instance;
      }
      
      public function init(param1:Game) : void
      {
         this._game = param1;
         this._game.stage.addEventListener(NavigationEvent.START,this.onNavigationChange);
      }
      
      public function attemptToStartTrade(param1:String) : int
      {
         var _loc2_:String = Network.getInstance().chatSystem.userData.nickName;
         if(!this.isTradeSystemEnabled)
         {
            return CANCEL_UNKNOWN_ERROR;
         }
         if(param1 == _loc2_)
         {
            return CANCEL_UNKNOWN_ERROR;
         }
         if(this.tradePartnerInfo != null)
         {
            return this.tradePartnerInfo.chatNickName == param1 ? CANCEL_TRADING_WITH_THIS_PERSON : CANCEL_TRADING_WITH_SOMEONE_ELSE;
         }
         if(this.tradeRequestDialog != null)
         {
            return CANCEL_UNKNOWN_ERROR;
         }
         if(this._game.zombieAttackImminent)
         {
            return CANCEL_ZOMBIE_ATTACK;
         }
         if(!this.checkLocationValid())
         {
            return CANCEL_UNKNOWN_ERROR;
         }
         var _loc3_:PlayerData = Network.getInstance().playerData;
         if(_loc3_.inventory.numItems >= _loc3_.inventory.maxItems)
         {
            return CANCEL_FULL_INVENTORY;
         }
         var _loc4_:Number = Network.getInstance().serverTime + 30 * 1000;
         this.tradePartnerInfo = new TradePartnerInfo();
         this.tradePartnerInfo.chatNickName = param1;
         this.tradeRequestDialog = new TradeRequestDialog(param1,_loc4_);
         this.tradeRequestDialog.closed.add(this.onTradeRequestClosed);
         this.tradeRequestDialog.open();
         this._chatSystem.sendDirectCommand(param1,CMD_TRADE_REQUEST,_loc3_.getPlayerSurvivor().level + 1,_loc3_.allianceId || "",_loc3_.allianceTag || "");
         return 1;
      }
      
      private function onTradeRequestClosed(param1:Dialogue) : void
      {
         this.tradeRequestDialog.closed.remove(this.onTradeRequestClosed);
         this.tradeRequestDialog = null;
      }
      
      public function closeCurrentTrade(param1:int = -1) : void
      {
         if(!this.tradePartnerInfo)
         {
            return;
         }
         if(this.tradingDialog == null)
         {
            this.closeTradeChatChannel();
         }
         var _loc2_:String = this.tradePartnerInfo.chatNickName;
         this.tradePartnerInfo = null;
         this._chatSystem.sendDirectCommand(_loc2_,CMD_CLOSE_TRADE,param1);
      }
      
      public function acceptTradeRequest(param1:String) : void
      {
         var _loc4_:InventoryFullDialogue = null;
         if(Network.getInstance().playerData.inventory.numItems >= Network.getInstance().playerData.inventory.maxItems)
         {
            this.rejectTradeRequest(param1,CANCEL_FULL_INVENTORY);
            _loc4_ = new InventoryFullDialogue(InventoryFullDialogue.TRADE_FULL);
            _loc4_.open();
            return;
         }
         if(Boolean(this.tradePartnerInfo) && this.tradePartnerInfo.chatNickName != param1)
         {
            this.closeCurrentTrade(CANCEL_TRADING_WITH_SOMEONE_ELSE);
         }
         var _loc2_:String = Network.getInstance().chatSystem.userData.nickName;
         this.tradePartnerInfo = new TradePartnerInfo();
         this.tradePartnerInfo.chatNickName = param1;
         this.tradePartnerInfo.tradeGUID = "trade_" + _loc2_ + "_" + param1;
         var _loc3_:PlayerData = Network.getInstance().playerData;
         this._chatSystem.sendDirectCommand(this.tradePartnerInfo.chatNickName,CMD_TRADE_REQUEST_ACCEPT,_loc2_,_loc3_.id,this.tradePartnerInfo.tradeGUID);
      }
      
      public function rejectTradeRequest(param1:String, param2:int = 0) : void
      {
         this._chatSystem.sendDirectCommand(param1,CMD_TRADE_REQUEST_REJECT,param2);
      }
      
      private function onChatCommandReceived(param1:String, param2:String, param3:Array) : void
      {
         var _loc4_:int = 0;
         var _loc5_:PlayerData = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(param2 == "" || param2.substr(0,6) != "trade_")
         {
            return;
         }
         switch(param2)
         {
            case CMD_TRADE_REQUEST:
               if(!this.isTradeSystemEnabled)
               {
                  this.rejectTradeRequest(param1,CANCEL_UNKNOWN_ERROR);
                  return;
               }
               _loc6_ = int(param3[0]);
               _loc7_ = Network.getInstance().playerData.getPlayerSurvivor().level + 1;
               if(_loc7_ < 10 && _loc6_ - _loc7_ > 5 || _loc6_ < 10 && _loc7_ - _loc6_ > 5)
               {
                  this.rejectTradeRequest(param1,CANCEL_OUTSIDE_RANGE);
                  return;
               }
               if(this._game.zombieAttackImminent == true)
               {
                  this.rejectTradeRequest(param1,CANCEL_ZOMBIE_ATTACK);
                  return;
               }
               if(this.checkLocationValid() == false)
               {
                  this.rejectTradeRequest(param1,CANCEL_THEYRE_BUSY);
                  return;
               }
               if(this.tradePartnerInfo || this.tradingDialog || Boolean(this.tradeRequestDialog))
               {
                  if(Boolean(this.tradingDialog) || this.tradePartnerInfo.chatNickName != param1)
                  {
                     this.rejectTradeRequest(param1,CANCEL_TRADING_WITH_SOMEONE_ELSE);
                  }
                  return;
               }
               Network.getInstance().chatSystem.displayTradeRequestInChat(param1,param3[1],param3[2]);
               return;
               break;
            case CMD_CLOSE_TRADE:
               _loc4_ = Boolean(param3) && param3.length > 0 ? int(param3[0]) : CANCEL_OTHER_USER_LEFT;
               if(Boolean(this.tradePartnerInfo) && this.tradePartnerInfo.chatNickName == param1)
               {
                  this.closeCurrentTrade(_loc4_);
               }
               this.onTradeRequestResponse.dispatch(param1,false,_loc4_);
               return;
            case CMD_TRADE_REQUEST_REJECT:
               if(Boolean(this.tradePartnerInfo) && this.tradePartnerInfo.chatNickName == param1)
               {
                  this.closeCurrentTrade(param3[0]);
               }
               this.onTradeRequestResponse.dispatch(param1,false,param3[0]);
               return;
            case CMD_TRADE_REQUEST_ACCEPT:
               if(this.tradePartnerInfo == null || this.tradePartnerInfo.chatNickName != param1)
               {
                  this.rejectTradeRequest(param1,this.tradePartnerInfo == null ? CANCEL_TRADE_OFFER_EXPIRED : CANCEL_TRADING_WITH_SOMEONE_ELSE);
                  return;
               }
               if(this.checkLocationValid() == false)
               {
                  this.rejectTradeRequest(param1,CANCEL_THEYRE_BUSY);
                  return;
               }
               this.tradePartnerInfo.userId = param3[1];
               this.tradePartnerInfo.tradeGUID = param3[2];
               _loc5_ = Network.getInstance().playerData;
               this._chatSystem.sendDirectCommand(param1,CMD_TRADE_REQUEST_COMPLETE,_loc5_.nickname,_loc5_.id);
               this.startTrade();
               this.onTradeRequestResponse.dispatch(param1,true,0);
               return;
               break;
            case CMD_TRADE_REQUEST_COMPLETE:
               if(this.tradePartnerInfo == null || this.tradePartnerInfo.chatNickName != param1)
               {
                  this.rejectTradeRequest(param1,CANCEL_TRADE_OFFER_EXPIRED);
                  return;
               }
               this.tradePartnerInfo.userId = param3[1];
               this.startTrade();
               this.onTradeRequestResponse.dispatch(this.tradePartnerInfo.chatNickName,true,0);
               return;
               break;
            default:
               if(this.tradePartnerInfo == null || param1 != this.tradePartnerInfo.chatNickName)
               {
                  this.rejectTradeRequest(param1,CANCEL_UNKNOWN_ERROR);
                  return;
               }
               return;
         }
      }
      
      private function closeTradeChatChannel() : void
      {
         if(this._chatChannel == "")
         {
            return;
         }
         this._chatSystem.disconnect(this._chatChannel);
         this._chatSystem.onChatStatusChange.remove(this.onChatStatusChange);
         this._chatChannel = "";
      }
      
      private function checkLocationValid() : Boolean
      {
         return (this._game.location == NavigationLocation.PLAYER_COMPOUND || this._game.location == NavigationLocation.WORLD_MAP) && this._game.zombieAttackImminent == false;
      }
      
      private function startTrade() : void
      {
         var msgBusy:BusyDialogue = null;
         if(this.tradePartnerInfo == null)
         {
            return;
         }
         msgBusy = new BusyDialogue(Language.getInstance().getString("trade.loadingMessage"),"loadingtrade");
         msgBusy.open();
         Network.getInstance().save({},SaveDataMethod.FLUSH_PLAYER,function(param1:Object):void
         {
            msgBusy.close();
            var _loc2_:String = Network.getInstance().chatSystem.userData.nickName;
            tradingDialog = new TradingDialog(tradePartnerInfo.tradeGUID,_loc2_,tradePartnerInfo.chatNickName);
            tradingDialog.closed.addOnce(onTradeDialogClosed);
            tradingDialog.open();
            var _loc3_:Object = {
               "userId1":Network.getInstance().playerData.id,
               "userId2":tradePartnerInfo.userId
            };
            _chatChannel = tradePartnerInfo.tradeGUID;
            _chatSystem.connect(_chatChannel,RoomType.TRADE,_loc3_);
            _chatSystem.onChatStatusChange.add(onChatStatusChange);
         });
      }
      
      private function onTradeDialogClosed(param1:BaseDialogue) : void
      {
         if(this.tradingDialog)
         {
            this.tradingDialog = null;
         }
         this.closeTradeChatChannel();
         this.tradePartnerInfo = null;
      }
      
      private function onChatStatusChange(param1:String, param2:String) : void
      {
         if(param1 != this._chatChannel)
         {
            return;
         }
         if(param2 == ChatSystem.STATUS_CONNECTED)
         {
            this._chatSystem.onChatStatusChange.remove(this.onChatStatusChange);
            this.tradingDialog.init(this._chatSystem.getConnection(this._chatChannel));
         }
      }
      
      private function onChatUserNotOnline(param1:String) : void
      {
         if(this.tradePartnerInfo == null)
         {
            return;
         }
         if(param1 == this.tradePartnerInfo.chatNickName)
         {
            this.closeCurrentTrade(CANCEL_OTHER_PERSON_OFFLINE);
         }
         this.onTradeRequestResponse.dispatch(param1,false,CANCEL_OTHER_PERSON_OFFLINE);
      }
      
      private function onNavigationChange(param1:NavigationEvent) : void
      {
         if(param1.location == NavigationLocation.WORLD_MAP || param1.location == NavigationLocation.PLAYER_COMPOUND)
         {
            return;
         }
         this.onCancelTradeRequests.dispatch();
      }
      
      public function get tradeInProgress() : Boolean
      {
         return this.tradePartnerInfo != null || this.tradingDialog != null || this.tradeRequestDialog != null;
      }
      
      public function get isTradeAllowed() : Boolean
      {
         return this.isTradeSystemEnabled && this.tradeInProgress == false && this._game.zombieAttackImminent == false && (this._game.location == "playerCompound" || this._game.location == "worldmap");
      }
   }
}

class TradeSystemSingletonEnforcer
{
   
   public function TradeSystemSingletonEnforcer()
   {
      super();
   }
}

class TradePartnerInfo
{
   
   public var chatNickName:String = "";
   
   public var userId:String = "";
   
   public var tradeGUID:String = "";
   
   public function TradePartnerInfo()
   {
      super();
   }
}
