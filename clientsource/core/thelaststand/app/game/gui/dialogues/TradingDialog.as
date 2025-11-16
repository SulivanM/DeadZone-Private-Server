package thelaststand.app.game.gui.dialogues
{
   import com.greensock.TweenMax;
   import com.junkbyte.console.Cc;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import playerio.Connection;
   import playerio.Message;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.Gear;
   import thelaststand.app.game.data.Inventory;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.SurvivorLoadoutManager;
   import thelaststand.app.game.gui.chat.UIChatPanel;
   import thelaststand.app.game.gui.chat.events.ChatLinkEvent;
   import thelaststand.app.game.gui.trade.TradingSlots;
   import thelaststand.app.game.logic.TradeSystem;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.NetworkMessage;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.app.network.chat.ChatMessageData;
   import thelaststand.app.network.chat.ChatSystem;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class TradingDialog extends BaseDialogue
   {
      
      private static const TM_ERROR:String = "traderoomError";
      
      private static const TM_INIT_COMPLETE:String = "tradeInitComplete";
      
      private static const TM_JOINED_TRADE:String = "joinedTradeRoom";
      
      private static const TM_ITEM_CHANGE:String = "tradeChangeHeard";
      
      private static const TM_SET_ACCEPTED:String = "setAccepted";
      
      private static const TM_CHANGED_DEAL:String = "changedDeal";
      
      private static const TM_PRICE_UPDATE:String = "priceUpdate";
      
      private static const TM_OTHER_USER_LEFT:String = "tradePartnerLeft";
      
      private static const TM_TRADE_ACCEPTED:String = "bothAcceptTrade";
      
      private static const TM_TRADE_LOCKDOWN:String = "tradeLockdown";
      
      private static const TM_TRADE_TABLE_READY:String = "tradeTableReady";
      
      private static const TM_FREE_SLOTS_UPGRADE:String = "freeSlotsUpgrade";
      
      private var _lang:Language;
      
      private var _trade:TradeSystem;
      
      private var _chat:ChatSystem;
      
      private var mc_container:Sprite;
      
      private var _tradeChannel:String;
      
      private var _myName:String;
      
      private var _otherNickName:String;
      
      private var _chatPanel:UIChatPanel;
      
      private var _localSlots:TradingSlots;
      
      private var _remoteSlots:TradingSlots;
      
      private var ui_image:UIImage;
      
      private var _acceptedHeading:AcceptedHeading;
      
      private var txt_transportCostTitle:BodyTextField;
      
      private var acceptBtnLabel:AcceptBtnLabel;
      
      private var btn_acceptTrade:PushButton;
      
      private var inventoryDialog:InventoryDialogue;
      
      private var _currentInventorySlot:int;
      
      private var _connection:Connection;
      
      private var _accepted:Boolean = false;
      
      private var _priceBase:int;
      
      private var _priceItem:int;
      
      private var _priceTotal:int;
      
      private var _serverInited:Boolean = false;
      
      private var _lastSelectedIndex:int;
      
      private var _msgBusy:BusyDialogue;
      
      private var _tradeAccepted:Boolean;
      
      private var _successMsg:TradeSuccessMessage;
      
      public function TradingDialog(param1:String, param2:String, param3:String)
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         this.mc_container = new Sprite();
         super("TradingDialog",this.mc_container,true);
         this._lang = Language.getInstance();
         this._chat = Network.getInstance().chatSystem;
         this._trade = TradeSystem.getInstance();
         this._tradeChannel = param1;
         this._otherNickName = param3;
         this._myName = param2;
         _loc4_ = 522;
         _loc5_ = 272;
         _loc6_ = int(_padding * 0.5);
         GraphicUtils.drawUIBlock(this.mc_container.graphics,_loc4_,_loc5_,0,_loc6_,1250067);
         addTitle(this._lang.getString("trade.tradeWindowTitle",this._otherNickName.toUpperCase()),BaseDialogue.TITLE_COLOR_GREY);
         this.ui_image = new UIImage(197,268,1250067);
         this.ui_image.uri = "images/ui/trade-panelimage.jpg";
         this.ui_image.x = int((_loc4_ - this.ui_image.width) * 0.5);
         this.ui_image.y = _loc6_ + 1;
         this.mc_container.addChild(this.ui_image);
         this._localSlots = new TradingSlots(param2);
         this._localSlots.x = 6;
         this._localSlots.y = _loc6_ + 6;
         this.mc_container.addChild(this._localSlots);
         this._localSlots.onSlotClicked.add(this.onSlotClicked);
         this._localSlots.onUnlockFreeSlots.add(this.onUnlockFreeSlots);
         this._localSlots.alpha = 0.7;
         this._remoteSlots = new TradingSlots(this._otherNickName,true);
         this._remoteSlots.x = 347;
         this._remoteSlots.y = this._localSlots.y;
         this.mc_container.addChild(this._remoteSlots);
         this._remoteSlots.faded = true;
         this._localSlots.mouseChildren = false;
         this._remoteSlots.mouseChildren = false;
         this._acceptedHeading = new AcceptedHeading();
         this._acceptedHeading.x = this._localSlots.x + this._localSlots.width + 2;
         this._acceptedHeading.y = this._localSlots.y;
         this._acceptedHeading.width = this._remoteSlots.x - this._acceptedHeading.x - 2;
         this.mc_container.addChild(this._acceptedHeading);
         this.txt_transportCostTitle = new BodyTextField({
            "color":8034649,
            "size":14,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_transportCostTitle.text = this._lang.getString("trade.tradeWindowTradingCostLabel");
         this.txt_transportCostTitle.x = int((_loc4_ - this.txt_transportCostTitle.width) * 0.5);
         this.txt_transportCostTitle.y = _loc6_ + 175;
         this.mc_container.addChild(this.txt_transportCostTitle);
         this.acceptBtnLabel = new AcceptBtnLabel();
         this.btn_acceptTrade = new PushButton(null,this.acceptBtnLabel,-1,null,2574340);
         this.btn_acceptTrade.height = 57;
         this.btn_acceptTrade.selectedColor = 6072333;
         this.btn_acceptTrade.x = int((_loc4_ - this.btn_acceptTrade.width) * 0.5);
         this.btn_acceptTrade.y = this._localSlots.y + this._localSlots.height - this.btn_acceptTrade.height;
         this.mc_container.addChild(this.btn_acceptTrade);
         this.btn_acceptTrade.clicked.add(this.acceptTradeClicked);
         this.btn_acceptTrade.enabled = false;
         this.acceptBtnLabel.mouseEnabled = false;
         _loc6_ += _loc5_ + _padding;
         var _loc7_:Number = 140;
         GraphicUtils.drawUIBlock(this.mc_container.graphics,_loc4_,_loc7_,0,_loc6_,0);
         this._chatPanel = new UIChatPanel(param1,[ChatSystem.CHANNEL_PRIVATE]);
         this._chatPanel.x = 4;
         this._chatPanel.y = _loc6_ + 4;
         this._chatPanel.width = _loc4_ - 8;
         this._chatPanel.height = _loc7_ - 8;
         this.mc_container.addChild(this._chatPanel);
         this._chatPanel.allowInput = false;
         this._chatPanel.messageConnecting = this._chatPanel.messageConnected = this._lang.getString("trade.tradeChatConnected");
         _autoSize = false;
         _height = _loc6_ + _loc7_ + _padding * 2.5;
         _width = _loc4_ + _padding * 2;
         this.updateAcceptedDisplay(true,false);
         this.updateAcceptedDisplay(false,false);
         var _loc8_:InventoryDialogueOptions = new InventoryDialogueOptions();
         _loc8_.showResources = true;
         _loc8_.showStoreButton = false;
         _loc8_.showRecyclerButton = true;
         _loc8_.showIncineratorButton = true;
         _loc8_.preProcessorFunction = this.inventoryPreProcessorFunction;
         _loc8_.disableUnavailableItems = true;
         _loc8_.clearNewFlagsOnClose = false;
         _loc8_.trackingPageTag = "tradeInventory";
         _loc8_.trackingEventTag = "TradeInventory";
         _loc8_.itemListOptions = new ItemListOptions();
         _loc8_.itemListOptions.clothingPreviews = ClothingPreviewDisplayOptions.DISABLED;
         _loc8_.itemListOptions.allowSelection = false;
         _loc8_.itemListOptions.showNoneItem = true;
         _loc8_.itemListOptions.showResourceLimited = false;
         _loc8_.itemListOptions.showEquippedIcons = true;
         _loc8_.itemListOptions.itemInfoParams = {"showResourceLimited":false};
         this.inventoryDialog = new InventoryDialogue(null,_loc8_);
         this.inventoryDialog.selected.add(this.inventoryItemSelected);
         this.inventoryDialog.weakReference = false;
         this.inventoryDialog.sprite.addEventListener(ChatLinkEvent.ADD_TO_CHAT,this.onAddToChat,false,10,true);
      }
      
      public function init(param1:Connection) : void
      {
         this._connection = param1;
         this._connection.addDisconnectHandler(this.onConnectionDisconnect);
         this._connection.addMessageHandler(TM_INIT_COMPLETE,this.onInitComplete);
         this._connection.addMessageHandler(TM_ERROR,this.onServerError);
         this._connection.addMessageHandler(TM_JOINED_TRADE,this.onJoinedTrade);
         this._connection.addMessageHandler(TM_ITEM_CHANGE,this.onItemChangeHeard);
         this._connection.addMessageHandler(TM_SET_ACCEPTED,this.onSetAcceptedHeard);
         this._connection.addMessageHandler(TM_CHANGED_DEAL,this.onDealChanged);
         this._connection.addMessageHandler(TM_PRICE_UPDATE,this.onPriceUpdateHeard);
         this._connection.addMessageHandler(TM_OTHER_USER_LEFT,this.onOtherUserLeft);
         this._connection.addMessageHandler(TM_TRADE_ACCEPTED,this.onTradeAcceptedByBoth);
         this._connection.addMessageHandler(TM_TRADE_LOCKDOWN,this.onTradeLockedDown);
         this._connection.addMessageHandler(TM_TRADE_TABLE_READY,this.onTradeTableReady);
         this._connection.addMessageHandler(TM_FREE_SLOTS_UPGRADE,this.onFreeSlotsUpgradeHeard);
      }
      
      override public function open() : void
      {
         super.open();
         this._msgBusy = new BusyDialogue(Language.getInstance().getString("trade.processingInitDialogue"),"initialising",false);
         this._msgBusy.open();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         TweenMax.killDelayedCallsTo(this.reenableAcceptButton);
         this._localSlots.dispose();
         this._remoteSlots.dispose();
         this._chatPanel.dispose();
         if(this._connection)
         {
            this._connection.removeDisconnectHandler(this.onConnectionDisconnect);
            this.removeConectionListeners();
            this._connection = null;
         }
         if(this.inventoryDialog)
         {
            this.inventoryDialog.sprite.removeEventListener(ChatLinkEvent.ADD_TO_CHAT,this.onAddToChat);
            this.inventoryDialog.close();
            this.inventoryDialog.dispose();
         }
         if(this._msgBusy)
         {
            this._msgBusy.close();
            this._msgBusy = null;
         }
         if(this._successMsg)
         {
            this._successMsg.dispose();
            this._successMsg = null;
         }
         this._lang = null;
         this._trade = null;
         this._chat = null;
      }
      
      override public function close() : void
      {
         if(this._trade)
         {
            this._trade.closeCurrentTrade();
         }
         super.close();
      }
      
      private function removeConectionListeners() : void
      {
         if(!this._connection)
         {
            return;
         }
         this._connection.removeMessageHandler(TM_INIT_COMPLETE,this.onInitComplete);
         this._connection.removeMessageHandler(TM_ERROR,this.onServerError);
         this._connection.removeMessageHandler(TM_JOINED_TRADE,this.onJoinedTrade);
         this._connection.removeMessageHandler(TM_ITEM_CHANGE,this.onItemChangeHeard);
         this._connection.removeMessageHandler(TM_SET_ACCEPTED,this.onSetAcceptedHeard);
         this._connection.removeMessageHandler(TM_CHANGED_DEAL,this.onDealChanged);
         this._connection.removeMessageHandler(TM_PRICE_UPDATE,this.onPriceUpdateHeard);
         this._connection.removeMessageHandler(TM_OTHER_USER_LEFT,this.onOtherUserLeft);
         this._connection.removeMessageHandler(TM_TRADE_ACCEPTED,this.onTradeAcceptedByBoth);
         this._connection.removeMessageHandler(TM_TRADE_LOCKDOWN,this.onTradeLockedDown);
         this._connection.removeMessageHandler(TM_TRADE_TABLE_READY,this.onTradeTableReady);
         this._connection.removeMessageHandler(TM_FREE_SLOTS_UPGRADE,this.onFreeSlotsUpgradeHeard);
      }
      
      private function onSlotClicked(param1:int) : void
      {
         this.setAccepted(false);
         this.updateAcceptedDisplay(false,false);
         this._connection.send(TM_CHANGED_DEAL);
         this._currentInventorySlot = param1;
         this._lastSelectedIndex = param1;
         this.inventoryDialog.refreshItems();
         this.inventoryDialog.open();
      }
      
      private function inventoryPreProcessorFunction(param1:Vector.<Item>) : Vector.<Item>
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:Item = null;
         var _loc8_:Boolean = false;
         var _loc9_:Gear = null;
         var _loc10_:int = 0;
         var _loc11_:Item = null;
         var _loc2_:SurvivorLoadoutManager = Network.getInstance().playerData.loadoutManager;
         var _loc6_:Vector.<Item> = new Vector.<Item>();
         _loc3_ = 0;
         while(_loc3_ < 6)
         {
            if(_loc3_ != this._lastSelectedIndex && this._localSlots.getItemAt(_loc3_) != null)
            {
               _loc6_.push(this._localSlots.getItemAt(_loc3_));
            }
            _loc3_++;
         }
         _loc4_ = int(param1.length);
         _loc3_ = _loc4_ - 1;
         while(_loc3_ >= 0)
         {
            _loc7_ = param1[_loc3_];
            if(_loc7_.isAccountBound)
            {
               param1.splice(_loc3_,1);
            }
            else
            {
               _loc8_ = false;
               if(this.inventoryDialog)
               {
                  this.inventoryDialog.setItemTint(_loc7_.id,-1);
               }
               if(_loc7_.category == "gear")
               {
                  _loc9_ = Gear(_loc7_);
                  if(_loc9_.isActiveGear)
                  {
                     _loc10_ = _loc2_.getCompoundAvailableQuantity(_loc7_);
                     _loc7_ = _loc7_.clone();
                     param1[_loc3_] = _loc7_;
                     _loc7_.quantity = _loc10_;
                  }
               }
               _loc5_ = int(_loc6_.length - 1);
               while(_loc5_ >= 0)
               {
                  _loc11_ = _loc6_[_loc5_];
                  if(_loc7_.id == _loc11_.id || _loc7_.category == "resource" && _loc7_.type == _loc11_.type)
                  {
                     if(!_loc8_)
                     {
                        _loc7_ = _loc7_.clone();
                        param1[_loc3_] = _loc7_;
                     }
                     _loc8_ = true;
                     _loc7_.quantity -= _loc11_.quantity;
                     _loc6_.splice(_loc5_,1);
                  }
                  _loc5_--;
               }
               if(_loc7_.quantity < 1)
               {
                  if(this.inventoryDialog)
                  {
                     this.inventoryDialog.setItemTint(_loc7_.id,_loc8_ ? 8453888 : 6579300);
                  }
               }
               if(!_loc7_.isTradable)
               {
                  if(this.inventoryDialog)
                  {
                     this.inventoryDialog.setItemTint(_loc7_.id,6579300);
                  }
               }
            }
            _loc3_--;
         }
         return param1;
      }
      
      private function setAccepted(param1:Boolean) : void
      {
         if(this._accepted == param1)
         {
            return;
         }
         this._accepted = param1;
         var _loc2_:ChatMessageData = new ChatMessageData(this._tradeChannel,ChatSystem.MESSAGE_TYPE_SYSTEM);
         _loc2_.posterNickName = ChatSystem.USER_NAME_NOTHING;
         _loc2_.message = this._lang.getString(param1 ? "trade.tradeAccepted" : "trade.tradeUnaccepted").replace("%user",this._myName);
         this._chat.onChatMessageReceived.dispatch(_loc2_);
         this._connection.send(TM_SET_ACCEPTED,this._accepted);
         this.updateAcceptedDisplay(true,this._accepted);
      }
      
      private function updateAcceptedDisplay(param1:Boolean, param2:Boolean) : void
      {
         if(param1)
         {
            this._localSlots.accepted = param2;
            this._acceptedHeading.leftChecked = param2;
            this.btn_acceptTrade.selected = param2;
            this.acceptBtnLabel.selected = param2;
            btn_close.enabled = !param2;
         }
         else
         {
            this._remoteSlots.accepted = param2;
            this._acceptedHeading.rightChecked = param2;
         }
      }
      
      private function inventoryItemSelected(param1:Item, param2:Boolean = false) : void
      {
         var cap:int = 0;
         var dlgHowMany:HowManyDialogue = null;
         var item:Item = param1;
         var ignoreRareness:Boolean = param2;
         if(item != null && item.quantity > 1)
         {
            cap = int(item.quantity);
            if(item.stackLimit > 0 && item.stackLimit < cap)
            {
               cap = item.stackLimit;
            }
            dlgHowMany = new HowManyDialogue(this._lang.getString("trade.howmany_title",item.getName()),this._lang.getString("trade.howmany_msg"),cap);
            dlgHowMany.amountSelected.addOnce(function(param1:int):void
            {
               if(param1 == 0)
               {
                  return;
               }
               addSelectedInventoryItem(item,param1);
            });
            dlgHowMany.open();
         }
         else
         {
            if(item != null && !item.isTradable)
            {
               return;
            }
            this.addSelectedInventoryItem(item,1);
         }
      }
      
      private function addSelectedInventoryItem(param1:Item, param2:int = 1) : void
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc9_:ChatMessageData = null;
         var _loc10_:ChatMessageData = null;
         var _loc3_:Item = param1 != null ? param1.clone() : null;
         if(_loc3_)
         {
            _loc3_.quantity = param2;
         }
         var _loc6_:Item = this._localSlots.getItemAt(this._currentInventorySlot);
         if(_loc6_)
         {
            _loc5_ = _loc6_.getName();
            if(_loc6_.quantity > 1)
            {
               _loc5_ += " (" + _loc6_.quantity + ")";
            }
            _loc9_ = new ChatMessageData(this._tradeChannel,ChatSystem.MESSAGE_TYPE_TRADE_FEEDBACK);
            _loc9_.posterNickName = ChatSystem.USER_TRADE_OUT;
            _loc9_.message = this._lang.getString("trade.tradeMsgRemoved").replace("%user",this._myName).replace("%item",_loc5_);
            this._chat.onChatMessageReceived.dispatch(_loc9_);
         }
         this._localSlots.setItemAt(this._currentInventorySlot,_loc3_);
         this.inventoryDialog.close();
         var _loc7_:String = "";
         var _loc8_:int = 0;
         if(_loc3_ != null)
         {
            _loc7_ = _loc3_.id;
            _loc8_ = param2;
            _loc5_ = _loc3_.getName();
            if(_loc3_.quantity > 1)
            {
               _loc5_ += " (" + _loc3_.quantity + ")";
            }
            _loc10_ = new ChatMessageData(this._tradeChannel,ChatSystem.MESSAGE_TYPE_TRADE_FEEDBACK);
            _loc10_.posterNickName = ChatSystem.USER_TRADE_IN;
            _loc10_.message = this._lang.getString("trade.tradeMsgAdded").replace("%user",this._myName).replace("%item",_loc5_);
            this._chat.onChatMessageReceived.dispatch(_loc10_);
            if(_loc3_.category == "resource")
            {
               _loc7_ = _loc3_.type;
            }
         }
         this.calculatePriceLocal();
         this._accepted = false;
         this.onDealChanged(null);
         this._connection.send(TM_ITEM_CHANGE,this._currentInventorySlot,_loc7_,_loc8_);
      }
      
      private function acceptTradeClicked(param1:MouseEvent) : void
      {
         var _loc2_:int = Network.getInstance().playerData.compound.resources.getAmount(GameResources.CASH);
         if(this._priceTotal > _loc2_)
         {
            PaymentSystem.getInstance().openBuyCoinsScreen(true);
            return;
         }
         this.setAccepted(!this._accepted);
         if(!this._accepted)
         {
            this.btn_acceptTrade.enabled = false;
            TweenMax.delayedCall(2,this.reenableAcceptButton);
         }
      }
      
      private function reenableAcceptButton() : void
      {
         if(this._msgBusy)
         {
            return;
         }
         this.btn_acceptTrade.enabled = true;
      }
      
      private function lockDownTrade() : void
      {
         if(Boolean(this.inventoryDialog) && Boolean(this.inventoryDialog.opened))
         {
            this.inventoryDialog.close();
         }
         this._localSlots.mouseEnabled = this._remoteSlots.mouseChildren = false;
         if(this._tradeAccepted == false)
         {
            this._localSlots.alpha = this._remoteSlots.alpha = 0.3;
         }
         this._chatPanel.allowInput = false;
         this.btn_acceptTrade.enabled = false;
      }
      
      private function updateDisplayedPrice(param1:int) : void
      {
         this._priceTotal = param1;
         this.acceptBtnLabel.label = String(param1);
      }
      
      private function calculatePriceLocal() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = this._priceBase;
         _loc2_ = 2;
         while(_loc2_ < 6)
         {
            if(this._localSlots.getItemAt(_loc2_) != null)
            {
               _loc1_ += this._priceItem;
            }
            if(this._remoteSlots.getItemAt(_loc2_) != null)
            {
               _loc1_ += this._priceItem;
            }
            _loc2_++;
         }
         this.updateDisplayedPrice(_loc1_);
      }
      
      private function onAddToChat(param1:ChatLinkEvent) : void
      {
         this._chatPanel.addItemFromEvent(param1);
         param1.stopImmediatePropagation();
      }
      
      private function onConnectionDisconnect() : void
      {
      }
      
      private function onServerError(param1:Message) : void
      {
         var _loc2_:ChatMessageData = new ChatMessageData(this._tradeChannel,ChatSystem.MESSAGE_TYPE_SYSTEM);
         _loc2_.posterNickName = ChatSystem.USER_NAME_ERROR;
         _loc2_.message = this._lang.getString("trade.serverError");
         if(!this._serverInited)
         {
            _loc2_.message = this._lang.getString("trade.serverInitFail");
         }
         this._chat.onChatMessageReceived.dispatch(_loc2_);
         this.lockDownTrade();
         this.removeConectionListeners();
         btn_close.enabled = true;
         if(this._msgBusy)
         {
            this._msgBusy.close();
            this._msgBusy = null;
         }
      }
      
      private function onInitComplete(param1:Message) : void
      {
         var _loc2_:int = 0;
         this._priceBase = param1.getInt(_loc2_++);
         this._priceItem = param1.getInt(_loc2_++);
         this.updateDisplayedPrice(this._priceBase);
         var _loc3_:* = param1.getString(_loc2_++) == Network.getInstance().playerData.id;
         TradingSlots(_loc3_ ? this._localSlots : this._remoteSlots).updateFreeSlotUpgrade(param1.getBoolean(_loc2_++));
         TradingSlots(_loc3_ ? this._remoteSlots : this._localSlots).updateFreeSlotUpgrade(param1.getBoolean(_loc2_++));
         this._localSlots.mouseChildren = this._remoteSlots.mouseChildren = true;
         this.btn_acceptTrade.enabled = true;
         this._localSlots.alpha = 1;
         this._chatPanel.allowInput = true;
         this._serverInited = true;
         if(this._msgBusy)
         {
            this._msgBusy.close();
            this._msgBusy = null;
         }
         var _loc4_:ChatMessageData = new ChatMessageData(this._tradeChannel,ChatSystem.MESSAGE_TYPE_SYSTEM);
         _loc4_.posterNickName = ChatSystem.USER_NAME_NOTHING;
         _loc4_.message = this._lang.getString("trade.serverInitialised");
         this._chat.onChatMessageReceived.dispatch(_loc4_);
      }
      
      private function onJoinedTrade(param1:Message) : void
      {
         var _loc2_:int = 0;
         var _loc3_:String = param1.getString(_loc2_++);
         var _loc4_:int = param1.getInt(_loc2_++);
         var _loc5_:String = "";
         if(_loc4_ == 1)
         {
            if(_loc3_ == this._myName)
            {
               _loc5_ = "trade.userConnectMeFirst";
            }
            else
            {
               _loc5_ = "trade.userConnectOther";
            }
         }
         else if(_loc3_ == this._myName)
         {
            _loc5_ = "trade.userConnectMeSecond";
         }
         else
         {
            _loc5_ = "trade.userConnectOther";
         }
         var _loc6_:ChatMessageData = new ChatMessageData(this._tradeChannel,ChatSystem.MESSAGE_TYPE_SYSTEM);
         _loc6_.posterNickName = ChatSystem.USER_NAME_NOTHING;
         _loc6_.message = this._lang.getString(_loc5_).replace("%user",this._otherNickName);
         this._chat.onChatMessageReceived.dispatch(_loc6_);
      }
      
      private function onOtherUserLeft(param1:Message) : void
      {
         var _loc2_:ChatMessageData = new ChatMessageData(this._tradeChannel,ChatSystem.MESSAGE_TYPE_TRADE_FEEDBACK);
         _loc2_.posterNickName = ChatSystem.USER_TRADE_USERLEFT;
         _loc2_.message = this._lang.getString("trade.otherUserLeft").replace("%user",this._otherNickName);
         this._chat.onChatMessageReceived.dispatch(_loc2_);
         if(!this._serverInited)
         {
            this._msgBusy.close();
         }
         this.lockDownTrade();
         btn_close.enabled = true;
      }
      
      private function onPriceUpdateHeard(param1:Message) : void
      {
         this.updateDisplayedPrice(param1.getInt(0));
      }
      
      private function onItemChangeHeard(param1:Message) : void
      {
         var _loc2_:String = null;
         var _loc6_:String = null;
         var _loc11_:ChatMessageData = null;
         var _loc3_:int = 0;
         var _loc4_:int = param1.getInt(_loc3_++);
         var _loc5_:String = param1.getString(_loc3_++);
         this.onDealChanged(null);
         var _loc7_:Item = this._remoteSlots.getItemAt(_loc4_);
         if(_loc7_)
         {
            _loc11_ = new ChatMessageData(this._tradeChannel,ChatSystem.MESSAGE_TYPE_TRADE_FEEDBACK);
            _loc11_.posterNickName = ChatSystem.USER_TRADE_OUT;
            _loc6_ = _loc7_.getName();
            if(_loc7_.quantity > 1)
            {
               _loc6_ += " (" + _loc7_.quantity + ")";
            }
            _loc11_.message = this._lang.getString("trade.tradeMsgRemoved").replace("%user",this._otherNickName).replace("%item",_loc6_);
            this._chat.onChatMessageReceived.dispatch(_loc11_);
         }
         if(!_loc5_ || _loc5_ == "")
         {
            this._remoteSlots.setItemAt(_loc4_,null);
            return;
         }
         var _loc8_:Object = JSON.parse(_loc5_);
         var _loc9_:Item = ItemFactory.createItemFromObject(_loc8_);
         this._remoteSlots.setItemAt(_loc4_,_loc9_);
         this._remoteSlots.faded = false;
         var _loc10_:ChatMessageData = new ChatMessageData(this._tradeChannel,ChatSystem.MESSAGE_TYPE_TRADE_FEEDBACK);
         _loc10_.posterNickName = ChatSystem.USER_TRADE_IN;
         _loc6_ = _loc9_.getName();
         if(_loc9_.quantity > 1)
         {
            _loc6_ += " (" + _loc9_.quantity + ")";
         }
         _loc10_.message = this._lang.getString("trade.tradeMsgAdded").replace("%user",this._otherNickName).replace("%item",_loc6_);
         this._chat.onChatMessageReceived.dispatch(_loc10_);
      }
      
      private function onSetAcceptedHeard(param1:Message) : void
      {
         var _loc2_:Boolean = param1.getBoolean(0);
         this.updateAcceptedDisplay(false,_loc2_);
         var _loc3_:ChatMessageData = new ChatMessageData(this._tradeChannel,ChatSystem.MESSAGE_TYPE_SYSTEM);
         _loc3_.posterNickName = ChatSystem.USER_NAME_NOTHING;
         _loc3_.message = this._lang.getString(_loc2_ ? "trade.tradeAccepted" : "trade.tradeUnaccepted").replace("%user",this._otherNickName);
         this._chat.onChatMessageReceived.dispatch(_loc3_);
      }
      
      private function onDealChanged(param1:Message) : void
      {
         var _loc2_:MessageBox = null;
         if(this._accepted)
         {
            _loc2_ = new MessageBox(this._lang.getString("trade.tradeWarningMessage",this._otherNickName),"tradeDealChanged",true);
            _loc2_.addTitle(this._lang.getString("trade.tradeWarningTitle"));
            _loc2_.addButton(this._lang.getString("trade.tradeWarningButton"),true,{"width":100});
            _loc2_.open();
         }
         this._accepted = false;
         this.updateAcceptedDisplay(true,false);
         this.updateAcceptedDisplay(false,false);
      }
      
      private function onTradeAcceptedByBoth(param1:Message) : void
      {
         var _loc2_:ChatMessageData = new ChatMessageData(this._tradeChannel,ChatSystem.MESSAGE_TYPE_SYSTEM);
         _loc2_.posterNickName = ChatSystem.USER_NAME_NOTHING;
         _loc2_.message = this._lang.getString("trade.bothUsersAccept");
         this._chat.onChatMessageReceived.dispatch(_loc2_);
      }
      
      private function onTradeLockedDown(param1:Message) : void
      {
         var _loc6_:Item = null;
         TweenMax.killDelayedCallsTo(this.reenableAcceptButton);
         this._tradeAccepted = true;
         this.btn_acceptTrade.clicked.remove(this.acceptTradeClicked);
         this.btn_acceptTrade.enabled = false;
         btn_close.enabled = false;
         this._localSlots.onSlotClicked.remove(this.onSlotClicked);
         this._localSlots.disable();
         var _loc2_:ChatMessageData = new ChatMessageData(this._tradeChannel,ChatSystem.MESSAGE_TYPE_SYSTEM);
         _loc2_.posterNickName = ChatSystem.USER_NAME_NOTHING;
         _loc2_.message = this._lang.getString("trade.processingLockDown");
         this._chat.onChatMessageReceived.dispatch(_loc2_);
         this._msgBusy = new BusyDialogue(Language.getInstance().getString("trade.processingBusyDialogue"),"processing",false);
         this._msgBusy.open();
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         while(_loc5_ < 6)
         {
            _loc6_ = this._localSlots.getItemAt(_loc5_);
            if(_loc6_ != null)
            {
               _loc3_++;
               Tracking.trackEvent("Player","Trade",_loc6_.getTradeTrackingName(),_loc6_.quantity);
            }
            _loc6_ = this._remoteSlots.getItemAt(_loc5_);
            if(_loc6_ != null)
            {
               _loc4_++;
            }
            _loc5_++;
         }
         Tracking.trackEvent("Player","Trade","ItemTotal-" + (_loc3_ + _loc4_),1);
         Tracking.trackEvent("Player","Trade","ItemRatio-" + Math.min(_loc3_,_loc4_) + "-" + Math.max(_loc3_,_loc4_),1);
      }
      
      private function onTradeTableReady(param1:Message) : void
      {
         var data:ChatMessageData = null;
         var network:Network = null;
         var m:Message = param1;
         var tradeId:String = m.getString(0);
         network = Network.getInstance();
         network.save({"id":tradeId},SaveDataMethod.TRADE_DO_TRADE,function(param1:Object):void
         {
            var _loc2_:Inventory = null;
            var _loc3_:Object = null;
            var _loc4_:Item = null;
            Cc.logch("trade","Parsed trade id",param1.success);
            btn_close.enabled = true;
            if(param1 != null && param1.success === true)
            {
               _loc2_ = network.playerData.inventory;
               if(param1.toUpdate != null)
               {
                  _loc2_.updateQuantities(param1.toUpdate);
               }
               if(param1.newItems != null)
               {
                  for each(_loc3_ in param1.newItems)
                  {
                     _loc4_ = ItemFactory.createItemFromObject(_loc3_);
                     if(_loc4_ != null)
                     {
                        network.playerData.giveItem(_loc4_);
                     }
                  }
               }
               _loc3_ = new ChatMessageData(_tradeChannel,ChatSystem.MESSAGE_TYPE_SYSTEM);
               _loc3_.posterNickName = ChatSystem.USER_NAME_NOTHING;
               _loc3_.message = _lang.getString("trade.processingSuccess");
               _chat.onChatMessageReceived.dispatch(_loc3_);
               _successMsg = new TradeSuccessMessage(522,272);
               _successMsg.y = _padding * 0.5;
               mc_container.addChild(_successMsg);
               Network.getInstance().playerData.checkAndUpdateLoadouts();
               network.send(NetworkMessage.PURCHASE_COINS);
            }
            else
            {
               _loc3_ = new ChatMessageData(_tradeChannel,ChatSystem.MESSAGE_TYPE_SYSTEM);
               _loc3_.posterNickName = ChatSystem.USER_NAME_ERROR;
               _loc3_.message = _lang.getString("trade.processingFailed");
               _chat.onChatMessageReceived.dispatch(_loc3_);
            }
            if(_msgBusy)
            {
               _msgBusy.close();
               _msgBusy = null;
            }
         });
      }
      
      private function onRefreshComplete(param1:Message) : void
      {
         this._localSlots.mouseChildren = true;
         if(this._msgBusy)
         {
            this._msgBusy.close();
            this._msgBusy = null;
         }
      }
      
      private function onUnlockFreeSlots() : void
      {
         var _loc1_:TradeSlotUpgradeDialogue = new TradeSlotUpgradeDialogue();
         _loc1_.slotUpgradePurchased.add(this.onUpgradePurchased);
         _loc1_.open();
      }
      
      private function onUpgradePurchased() : void
      {
         this._localSlots.updateFreeSlotUpgrade(true);
         this._connection.send(TM_FREE_SLOTS_UPGRADE);
      }
      
      private function onFreeSlotsUpgradeHeard(param1:Message) : void
      {
         TradingSlots(param1.getString(0) == this._myName ? this._localSlots : this._remoteSlots).updateFreeSlotUpgrade(param1.getBoolean(1));
         var _loc2_:ChatMessageData = new ChatMessageData(this._tradeChannel,ChatSystem.MESSAGE_TYPE_TRADE_FEEDBACK);
         _loc2_.posterNickName = ChatSystem.USER_NAME_NOTHING;
         _loc2_.message = this._lang.getString("trade.boughtSlots",param1.getString(0));
         this._chat.onChatMessageReceived.dispatch(_loc2_);
      }
   }
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormatAlign;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;
import thelaststand.common.lang.Language;

class AcceptedHeading extends Sprite
{
   
   private var _leftChecked:Boolean = false;
   
   private var _rightChecked:Boolean = false;
   
   private var _width:Number = 200;
   
   private var leftSprite:Sprite;
   
   private var rightSprite:Sprite;
   
   private var centre:Shape;
   
   private var leftIcon:Bitmap;
   
   private var rightIcon:Bitmap;
   
   private var tickBD:BitmapData;
   
   private var crossBD:BitmapData;
   
   private var txt_label:BodyTextField;
   
   public function AcceptedHeading()
   {
      super();
      this.tickBD = new BmpIconTradeTickGreen();
      this.crossBD = new BmpIconTradeCrossRed();
      this.centre = new Shape();
      this.centre.graphics.beginFill(723723,1);
      this.centre.graphics.drawRect(0,0,50,25);
      this.centre.graphics.endFill();
      addChild(this.centre);
      this.centre.x = 25;
      this.leftSprite = new Sprite();
      addChild(this.leftSprite);
      this.leftIcon = new Bitmap(this.crossBD);
      this.leftSprite.addChild(this.leftIcon);
      this.rightSprite = new Sprite();
      addChild(this.rightSprite);
      this.rightIcon = new Bitmap(this.crossBD);
      this.rightSprite.addChild(this.rightIcon);
      this.txt_label = new BodyTextField({
         "width":this._width - 50,
         "size":14,
         "color":6842472,
         "filters":[Effects.TEXT_SHADOW_DARK]
      });
      this.txt_label.text = Language.getInstance().getString("trade.tradeWindowAcceptedLabel");
      addChild(this.txt_label);
      this.txt_label.y = int((this.centre.height - this.txt_label.height) * 0.5);
      this.leftChecked = false;
      this.rightChecked = false;
      this.width = 200;
      mouseChildren = mouseEnabled = false;
   }
   
   public function dispose() : void
   {
      this.tickBD.dispose();
      this.crossBD.dispose();
      this.txt_label.dispose();
   }
   
   override public function get width() : Number
   {
      return this._width;
   }
   
   override public function set width(param1:Number) : void
   {
      this._width = param1;
      this.centre.width = this._width - 50;
      this.rightSprite.x = this._width - 25;
      this.txt_label.x = 25 + int((this.centre.width - this.txt_label.width) * 0.5);
   }
   
   override public function get height() : Number
   {
      return 25;
   }
   
   override public function set height(param1:Number) : void
   {
   }
   
   public function get leftChecked() : Boolean
   {
      return this._leftChecked;
   }
   
   public function set leftChecked(param1:Boolean) : void
   {
      this._leftChecked = param1;
      this.drawIcon(this.leftSprite,this.leftIcon,param1);
   }
   
   public function get rightChecked() : Boolean
   {
      return this._rightChecked;
   }
   
   public function set rightChecked(param1:Boolean) : void
   {
      this._rightChecked = param1;
      this.drawIcon(this.rightSprite,this.rightIcon,param1);
   }
   
   private function drawIcon(param1:Sprite, param2:Bitmap, param3:Boolean) : void
   {
      param1.graphics.clear();
      param1.graphics.beginFill(param3 ? 3695627 : 11076612,1);
      param1.graphics.drawRect(0,0,25,25);
      param1.graphics.endFill();
      param2.bitmapData = param3 ? this.tickBD : this.crossBD;
      param2.x = int((param1.width - param2.width) * 0.5);
      param2.y = int((param1.height - param2.height) * 0.5);
   }
}

class AcceptBtnLabel extends Sprite
{
   
   private var fuelIcon:Bitmap;
   
   private var txt_acceptLabel:BodyTextField;
   
   private var txt_cost:BodyTextField;
   
   private var _selected:Boolean = false;
   
   public function AcceptBtnLabel()
   {
      super();
      this.txt_acceptLabel = new BodyTextField({
         "size":13,
         "filters":[Effects.TEXT_SHADOW_DARK],
         "border":false,
         "width":200,
         "align":TextFormatAlign.CENTER,
         "autoSize":TextFieldAutoSize.NONE
      });
      this.txt_acceptLabel.text = Language.getInstance().getString("trade.tradeWindowAcceptBtnInactive");
      addChild(this.txt_acceptLabel);
      this.txt_cost = new BodyTextField({
         "size":20,
         "filters":[Effects.TEXT_SHADOW_DARK]
      });
      this.txt_cost.text = "0";
      this.txt_cost.y = this.txt_acceptLabel.y + this.txt_acceptLabel.height - 3;
      addChild(this.txt_cost);
      this.fuelIcon = new Bitmap(new BmpIconFuel(),"auto",true);
      this.fuelIcon.height = 18;
      this.fuelIcon.scaleX = this.fuelIcon.scaleY;
      this.fuelIcon.x = this.txt_cost.x + this.txt_cost.width + 2;
      this.fuelIcon.y = this.txt_cost.y + (this.txt_cost.height - this.fuelIcon.height) * 0.5 + 1;
      this.fuelIcon.filters = [Effects.TEXT_SHADOW_DARK];
      addChild(this.fuelIcon);
      this.label = "0";
   }
   
   public function get selected() : Boolean
   {
      return this._selected;
   }
   
   public function set selected(param1:Boolean) : void
   {
      this._selected = param1;
      this.txt_acceptLabel.text = Language.getInstance().getString(this._selected ? "trade.tradeWindowAcceptBtnActive" : "trade.tradeWindowAcceptBtnInactive");
   }
   
   public function get label() : String
   {
      return this.txt_cost.text;
   }
   
   public function set label(param1:String) : void
   {
      this.txt_cost.text = param1;
      this.txt_cost.x = this.txt_acceptLabel.width * 0.5 - (this.txt_cost.width + 2 + this.fuelIcon.width) * 0.5 + 3;
      this.fuelIcon.x = this.txt_cost.x + this.txt_cost.width + 2;
   }
}

class TradeSuccessMessage extends Sprite
{
   
   private var bg:Shape;
   
   private var txt_label:BodyTextField;
   
   private var txt_heading:BodyTextField;
   
   public function TradeSuccessMessage(param1:Number = 300, param2:Number = 100)
   {
      super();
      this.bg = new Shape();
      this.bg.graphics.beginFill(0,0.8);
      this.bg.graphics.drawRect(0,0,param1,param2);
      this.bg.graphics.endFill();
      addChild(this.bg);
      this.txt_label = new BodyTextField({
         "color":16777215,
         "size":19,
         "filters":[Effects.TEXT_SHADOW_DARK]
      });
      this.txt_label.text = Language.getInstance().getString("trade.processingSuccess");
      this.txt_label.x = int((this.bg.width - this.txt_label.width) * 0.5);
      this.txt_label.y = (this.bg.height - this.txt_label.height) * 0.5;
      addChild(this.txt_label);
      this.txt_heading = new BodyTextField({
         "color":Effects.COLOR_GREEN,
         "size":22,
         "filters":[Effects.TEXT_SHADOW_DARK]
      });
      this.txt_heading.text = Language.getInstance().getString("trade.processingSuccessTitle");
      this.txt_heading.x = int((this.bg.width - this.txt_heading.width) * 0.5);
      this.txt_heading.y = this.txt_label.y - this.txt_heading.height;
      addChild(this.txt_heading);
   }
   
   public function dispose() : void
   {
      this.txt_label.dispose();
      this.txt_heading.dispose();
   }
}
