package thelaststand.app.network
{
   import com.dynamicflash.util.Base64;
   import com.exileetiquette.utils.NumberFormatter;
   import com.junkbyte.console.Cc;
   import flash.display.StageDisplayState;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import playerio.PlayerIOError;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Global;
   import thelaststand.app.core.Settings;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.Currency;
   import thelaststand.app.data.PlayerUpgrades;
   import thelaststand.app.game.data.EffectItem;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.effects.Effect;
   import thelaststand.app.game.data.store.StoreCollection;
   import thelaststand.app.game.data.store.StoreItem;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.dialogues.BuyFuelDialogue;
   import thelaststand.app.game.gui.dialogues.PromoCodeDialogue;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.payments.FacebookPayments;
   import thelaststand.app.network.payments.IPaymentSystem;
   import thelaststand.app.network.payments.KongregatePayments;
   import thelaststand.app.network.payments.PayPalPayments;
   import thelaststand.app.network.payments.PlayerIOPayments;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   
   public class PaymentSystem
   {
      
      private static var _instance:PaymentSystem;
      
      private var purchaseCache:Dictionary = new Dictionary(true);
      
      private var nextPurchaseId:int = 0;
      
      private var _lastPurchaseAmount:int;
      
      private var _system:IPaymentSystem;
      
      private var _network:Network;
      
      private var _lang:Language;
      
      public var transactionSuccess:Signal;
      
      public var transactionFailed:Signal;
      
      public function PaymentSystem(param1:PaymentSystemSingletonEnforcer)
      {
         super();
         if(!param1)
         {
            throw new Error("PaymentSystem is a Singleton and cannot be directly instantiated. Use PaymentSystem.getInstance().");
         }
         this._lang = Language.getInstance();
         this._network = Network.getInstance();
         Cc.log("PaymentSystem.service = " + this._network.service);
         switch(this._network.service)
         {
            case PlayerIOConnector.SERVICE_FACEBOOK:
               this._system = new FacebookPayments();
               break;
            case PlayerIOConnector.SERVICE_KONGREGATE:
               this._system = new KongregatePayments();
               break;
            case PlayerIOConnector.SERVICE_PLAYER_IO:
               this._system = new PlayerIOPayments();
               break;
            default:
               this._system = new PayPalPayments();
         }
         this.transactionSuccess = new Signal(String);
         this.transactionFailed = new Signal();
         this._system.transactionSuccess.add(this.onTransactionSuccess);
         this._system.transactionFailed.add(this.onTransactionFailed);
         if(ExternalInterface.available)
         {
            ExternalInterface.addCallback("handlePayment",this.JS_openHandlePayment);
            ExternalInterface.addCallback("openGetMore",this.JS_openGetMore);
            ExternalInterface.addCallback("openRedeemCode",this.JS_openRedeemCode);
         }
      }
      
      public static function getInstance() : PaymentSystem
      {
         return _instance || (_instance = new PaymentSystem(new PaymentSystemSingletonEnforcer()));
      }
      
      public function get lastPurchaseAmount() : int
      {
         return this._lastPurchaseAmount;
      }
      
      public function claimPromoCode(param1:String, param2:Function = null) : void
      {
         var msgBusy:BusyDialogue = null;
         var code:String = param1;
         var onComplete:Function = param2;
         msgBusy = new BusyDialogue(this._lang.getString("promocode_busy"),"promocode-busy");
         msgBusy.open();
         this._network.save({"code":code},SaveDataMethod.CLAIM_PROMO_CODE,function(param1:Object):void
         {
            var _loc2_:MessageBox = null;
            var _loc3_:String = null;
            msgBusy.close();
            if(param1 == null)
            {
               transactionFailed.dispatch();
               if(onComplete != null)
               {
                  onComplete(false);
               }
               return;
            }
            if(param1.success === false)
            {
               _loc3_ = param1.errorCode;
               switch(_loc3_)
               {
                  case "invalid":
                     _loc2_ = new MessageBox(_lang.getString("promocode_invalid_msg"));
                     _loc2_.addTitle(_lang.getString("promocode_invalid_title"),BaseDialogue.TITLE_COLOR_RUST);
                     _loc2_.addButton(_lang.getString("promocode_invalid_ok"));
                     break;
                  case "claimed":
                     _loc2_ = new MessageBox(_lang.getString("promocode_claimed_msg"));
                     _loc2_.addTitle(_lang.getString("promocode_claimed_title"),BaseDialogue.TITLE_COLOR_RUST);
                     _loc2_.addButton(_lang.getString("promocode_claimed_ok"));
                     break;
                  case "oneTime":
                     _loc2_ = new MessageBox(_lang.getString("promocode_oneTime_msg"));
                     _loc2_.addTitle(_lang.getString("promocode_oneTime_title"),BaseDialogue.TITLE_COLOR_RUST);
                     _loc2_.addButton(_lang.getString("promocode_oneTime_ok"));
                     break;
                  case "pending":
                     _loc2_ = new MessageBox(_lang.getString("promocode_pending_msg"));
                     _loc2_.addTitle(_lang.getString("promocode_pending_title"),BaseDialogue.TITLE_COLOR_RUST);
                     _loc2_.addButton(_lang.getString("promocode_pending_ok"));
                     break;
                  case "serverError":
                  default:
                     transactionFailed.dispatch();
               }
               if(_loc2_ != null)
               {
                  _loc2_.open();
               }
               if(onComplete != null)
               {
                  onComplete(false);
               }
               return;
            }
            handlePurchaseResponse(param1,onComplete);
         });
      }
      
      public function getPayPalCoinsURL(param1:int, param2:String, param3:int, param4:Function, param5:Function = null) : void
      {
         this._lastPurchaseAmount = param1;
         if(this._system is PayPalPayments)
         {
            PayPalPayments(this._system).getPayPalCoinsURL(param1,param2,param3,param4,param5);
         }
      }
      
      public function openBuyCoinsScreen(param1:Boolean = true) : void
      {
         var dlgBuy:BuyFuelDialogue = null;
         var lang:Language = null;
         var msg:MessageBox = null;
         var showNotEnoughDialogue:Boolean = param1;
         if(showNotEnoughDialogue)
         {
            lang = this._lang;
            msg = new MessageBox(this._lang.getString("buy_notenough_msg"),"not-enough-fuel",true);
            msg.addTitle(this._lang.getString("buy_notenough_title"),BaseDialogue.TITLE_COLOR_BUY);
            msg.addImage("images/items/fuel.jpg");
            msg.addButton(this._lang.getString("buy_notenough_ok"),true,{"backgroundColor":4226049}).clicked.addOnce(function(param1:MouseEvent):void
            {
               dlgBuy = new BuyFuelDialogue();
               dlgBuy.open();
            });
            msg.open();
            return;
         }
         if(DialogueManager.getInstance().getDialogueById("buy-fuel") != null)
         {
            return;
         }
         dlgBuy = new BuyFuelDialogue();
         dlgBuy.open();
      }
      
      public function openEarnCoinsScreen() : void
      {
         if(!Settings.getInstance().earnFuelEnabled)
         {
            this.transactionFailed.dispatch();
            return;
         }
         if(Global.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE)
         {
            Global.stage.displayState = StageDisplayState.NORMAL;
         }
         this._system.earnCoins();
      }
      
      public function getAndBuyStoreItem(param1:String, param2:Function = null) : void
      {
         var busy:BusyDialogue = null;
         var itemKey:String = param1;
         var onPurchased:Function = param2;
         busy = new BusyDialogue(this._lang.getString("store_loading_item"),"loading-store-item");
         busy.open();
         StoreManager.getInstance().loadItem(itemKey,function(param1:StoreItem):void
         {
            busy.close();
            if(param1 == null)
            {
               if(onPurchased != null)
               {
                  onPurchased(false);
               }
               transactionFailed.dispatch();
            }
            else
            {
               buyStoreItem(param1,onPurchased);
            }
         });
      }
      
      public function buyResource(param1:String, param2:String, param3:Function) : void
      {
         var msgBusy:BusyDialogue = null;
         var resource:String = param1;
         var optionKey:String = param2;
         var completeCallback:Function = param3;
         msgBusy = new BusyDialogue(this._lang.getString("store_res_purchasing"));
         msgBusy.open();
         this._network.startAsyncOp();
         this._network.save({
            "resource":resource,
            "option":optionKey
         },SaveDataMethod.RESOURCE_BUY,function(param1:Object):void
         {
            var _loc2_:MessageBox = null;
            _network.completeAsyncOp();
            msgBusy.close();
            if(param1 == null)
            {
               transactionFailed.dispatch();
               completeCallback(false);
               return;
            }
            if(param1.disabled === true || param1.success !== true)
            {
               switch(param1.error)
               {
                  case PlayerIOError.NotEnoughCoins.errorID:
                     openBuyCoinsScreen();
                     break;
                  case "storage_full":
                     _loc2_ = new MessageBox(Language.getInstance().getString("store_res_full_msg"));
                     _loc2_.addTitle(Language.getInstance().getString("store_res_full_title"));
                     _loc2_.addButton(Language.getInstance().getString("store_res_full_ok"));
                     _loc2_.open();
               }
               transactionFailed.dispatch();
               completeCallback(false);
               return;
            }
            transactionSuccess.dispatch("resource",resource,int(param1.amount));
            completeCallback(true);
         });
      }
      
      public function buyProtection(param1:String, param2:Function) : void
      {
         var msgLoading:BusyDialogue = null;
         var optionKey:String = param1;
         var completeCallback:Function = param2;
         msgLoading = new BusyDialogue(this._lang.getString("purachasing_protection"));
         msgLoading.open();
         this._network.startAsyncOp();
         this._network.save({"protection":optionKey},SaveDataMethod.PROTECTION_BUY,function(param1:Object):void
         {
            var _loc2_:ByteArray = null;
            var _loc3_:Effect = null;
            var _loc4_:Effect = null;
            _network.completeAsyncOp();
            msgLoading.close();
            if(param1 == null)
            {
               completeCallback(false);
               return;
            }
            if(param1.success !== true || param1.disabled === true)
            {
               if(param1.error == PlayerIOError.NotEnoughCoins.errorID)
               {
                  PaymentSystem.getInstance().openBuyCoinsScreen();
               }
               else
               {
                  transactionFailed.dispatch();
               }
               completeCallback(false);
               return;
            }
            if(param1.effect != null)
            {
               Tracking.trackEvent("Player","Purchase","proection_" + optionKey,int(param1.cost));
               _loc2_ = Base64.decodeToByteArray(param1.effect);
               _loc3_ = new Effect();
               _loc3_.readObject(_loc2_);
               _loc4_ = _network.playerData.compound.globalEffects.getEffectById(_loc3_.id);
               if(_loc4_ != null)
               {
                  _loc4_.readObject(_loc2_);
               }
               else
               {
                  _network.playerData.compound.globalEffects.addEffect(_loc3_);
               }
            }
            if(param1.cooldown != null)
            {
               _network.playerData.cooldowns.parse(Base64.decodeToByteArray(param1.cooldown));
            }
            completeCallback(true);
         });
      }
      
      public function buyCollection(param1:StoreCollection, param2:Function = null) : void
      {
         var dlgConfirm:MessageBox;
         var collectionName:String = null;
         var btnBuy:PurchasePushButton = null;
         var id:int = 0;
         var returnData:String = null;
         var collection:StoreCollection = param1;
         var onPurchased:Function = param2;
         if(collection.currency == Currency.FUEL)
         {
            if(collection.cost > this._network.playerData.compound.resources.getAmount(GameResources.CASH))
            {
               this.openBuyCoinsScreen(true);
               return;
            }
         }
         collectionName = this._lang.getString("itemcollection." + collection.key);
         dlgConfirm = new MessageBox(this._lang.getString("store_confirm_msg","<b>" + collectionName + "</b>"),"confirm-purchase");
         dlgConfirm.addTitle(this._lang.getString("store_confirm_title",collectionName),BaseDialogue.TITLE_COLOR_BUY);
         dlgConfirm.addButton(this._lang.getString("store_confirm_cancel"));
         btnBuy = PurchasePushButton(dlgConfirm.addButton(this._lang.getString("store_confirm_ok"),true,{
            "width":160,
            "buttonClass":PurchasePushButton,
            "iconAlign":PurchasePushButton.ICON_ALIGN_LABEL_RIGHT
         }));
         btnBuy.currency = collection.currency;
         btnBuy.cost = collection.cost;
         if(collection.currency != Currency.FUEL)
         {
            btnBuy.enabled = false;
            id = this.nextPurchaseId++;
            this.purchaseCache[id] = collection;
            returnData = escape(JSON.stringify({
               "type":"itemcollection",
               "id":id
            }));
            this.getBuyItemDirectData(collection.key,{
               "title":collectionName,
               "description":" ",
               "returnData":returnData
            },function(param1:Object):void
            {
               if(param1 != null)
               {
                  btnBuy.data = param1;
                  btnBuy.enabled = true;
               }
            });
         }
         btnBuy.clicked.addOnce(function(param1:MouseEvent):void
         {
            var msg:BusyDialogue = null;
            var e:MouseEvent = param1;
            if(btnBuy.data != null)
            {
               buyDirectItem(collection.key,btnBuy.data,_lang.getString("purchasing_item",collectionName),function(param1:Boolean):void
               {
                  if(onPurchased != null)
                  {
                     onPurchased(param1);
                  }
               });
            }
            else
            {
               msg = new BusyDialogue(_lang.getString("purchasing_item",collectionName),"item-purchasing");
               msg.open();
               _network.startAsyncOp();
               _network.save({"item":collection.key},SaveDataMethod.ITEM_BUY,function(param1:Object):void
               {
                  _network.completeAsyncOp();
                  msg.close();
                  handlePurchaseResponse(param1,onPurchased);
               });
            }
         });
         dlgConfirm.open();
      }
      
      public function buyStoreItem(param1:StoreItem, param2:Function = null) : void
      {
         var dlgConfirm:MessageBox;
         var itemName:String = null;
         var btnBuy:PurchasePushButton = null;
         var id:int = 0;
         var returnData:String = null;
         var storeItem:StoreItem = param1;
         var onPurchased:Function = param2;
         if(storeItem.currency == Currency.FUEL)
         {
            if(storeItem.cost > this._network.playerData.compound.resources.getAmount(GameResources.CASH))
            {
               this.openBuyCoinsScreen(true);
               return;
            }
         }
         itemName = storeItem.item.getName();
         if(storeItem.item.quantity > 1)
         {
            itemName += " x " + NumberFormatter.format(storeItem.item.quantity,0);
         }
         dlgConfirm = new MessageBox(this._lang.getString("store_confirm_msg","<b>" + itemName + "</b>"),"confirm-purchase");
         dlgConfirm.addTitle(this._lang.getString("store_confirm_title",itemName),BaseDialogue.TITLE_COLOR_BUY);
         dlgConfirm.addImage(storeItem.item.getImageURI());
         dlgConfirm.addButton(this._lang.getString("store_confirm_cancel"));
         btnBuy = PurchasePushButton(dlgConfirm.addButton(this._lang.getString("store_confirm_ok"),true,{
            "width":160,
            "buttonClass":PurchasePushButton,
            "iconAlign":PurchasePushButton.ICON_ALIGN_LABEL_RIGHT
         }));
         btnBuy.setFromStoreItem(storeItem);
         if(storeItem.currency != Currency.FUEL)
         {
            btnBuy.enabled = false;
            id = this.nextPurchaseId++;
            this.purchaseCache[id] = storeItem;
            returnData = escape(JSON.stringify({
               "type":"item",
               "id":id
            }));
            this.getBuyItemDirectData(storeItem.key,{
               "title":itemName,
               "description":" ",
               "image":Config.getPath("storage_url") + "game/data/" + storeItem.item.getImageURI(),
               "returnData":returnData
            },function(param1:Object):void
            {
               if(param1 != null)
               {
                  btnBuy.data = param1;
                  btnBuy.enabled = true;
               }
            });
         }
         btnBuy.clicked.addOnce(function(param1:MouseEvent):void
         {
            var msg:BusyDialogue = null;
            var e:MouseEvent = param1;
            if(btnBuy.data != null)
            {
               buyDirectItem(storeItem.key,btnBuy.data,_lang.getString("purchasing_item",itemName),function(param1:Boolean):void
               {
                  if(onPurchased != null)
                  {
                     onPurchased(param1);
                  }
               });
            }
            else
            {
               msg = new BusyDialogue(_lang.getString("purchasing_item",itemName),"item-purchasing");
               msg.open();
               _network.startAsyncOp();
               _network.save({"item":storeItem.key},SaveDataMethod.ITEM_BUY,function(param1:Object):void
               {
                  _network.completeAsyncOp();
                  msg.close();
                  handlePurchaseResponse(param1,onPurchased);
               });
            }
         });
         dlgConfirm.open();
      }
      
      public function buyCoins(param1:int, param2:String, param3:int, param4:Function = null) : void
      {
         var msg:BusyDialogue = null;
         var amount:int = param1;
         var currency:String = param2;
         var currencyAmount:int = param3;
         var onComplete:Function = param4;
         if(Global.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE)
         {
            Global.stage.displayState = StageDisplayState.NORMAL;
         }
         msg = new BusyDialogue(this._lang.getString("purchasing_fuel"));
         msg.open();
         this._lastPurchaseAmount = amount;
         this._system.buyCoins(amount,currency,currencyAmount,function(param1:Boolean):void
         {
            msg.close();
            if(onComplete != null)
            {
               onComplete(param1);
            }
         });
      }
      
      public function getBuyItemDirectData(param1:String, param2:Object = null, param3:Function = null, param4:Function = null) : void
      {
         this._system.getBuyItemDirectData(param1,param2,param3,param4);
      }
      
      public function buyDirectItem(param1:String, param2:Object, param3:String = null, param4:Function = null) : void
      {
         var buyCompleteHandler:Function = null;
         var msg:BusyDialogue = null;
         var itemKey:String = param1;
         var buyInfo:Object = param2;
         var busyMessage:String = param3;
         var onComplete:Function = param4;
         if(busyMessage != null)
         {
            msg = new BusyDialogue(busyMessage);
            msg.open();
         }
         buyCompleteHandler = function(param1:Boolean):void
         {
            if(msg != null)
            {
               msg.close();
            }
            if(onComplete != null)
            {
               onComplete(param1);
            }
         };
         this._network.data.costTable.getOrLoadItemByKey(itemKey,function(param1:Object):void
         {
            var item:Object = param1;
            if(item == null)
            {
               if(msg != null)
               {
                  msg.close();
               }
               transactionFailed.dispatch();
               return;
            }
            if(item.oneTimeOnly === true)
            {
               _network.save({"key":itemKey},SaveDataMethod.HAS_PAYVAULT_ITEM,function(param1:Object):void
               {
                  if(param1 == null || param1.error != null || param1.has === true)
                  {
                     buyCompleteHandler(false);
                     transactionFailed.dispatch();
                  }
                  else
                  {
                     _system.buyDirectItem(itemKey,buyInfo,buyCompleteHandler);
                  }
               });
            }
            else
            {
               _system.buyDirectItem(itemKey,buyInfo,buyCompleteHandler);
            }
         });
      }
      
      public function buyPackage(param1:Object, param2:Function = null) : void
      {
         var buyInfo:Object;
         var msg:BusyDialogue = null;
         var data:Object = param1;
         var onComplete:Function = param2;
         if("PriceCoins" in data)
         {
            this.buyFuelPurchasePackage(data,onComplete);
            return;
         }
         msg = new BusyDialogue(this._lang.getString("purchasing_package",this._lang.getString("offers." + data.key)),"item-purchasing");
         msg.open();
         buyInfo = this._network.service == PlayerIOConnector.SERVICE_KONGREGATE ? data.key : data.buyInfo;
         this._system.buyDirectItem(data.key,buyInfo,function(param1:Boolean):void
         {
            msg.close();
            if(onComplete != null)
            {
               onComplete(param1);
            }
         });
      }
      
      public function buyPayVaultItem(param1:String, param2:Boolean = false, param3:Function = null) : void
      {
         var cost:int = 0;
         var itemKey:String = param1;
         var oneOnly:Boolean = param2;
         var onComplete:Function = param3;
         var data:Object = this._network.data.costTable.getItemByKey(itemKey);
         if(data != null)
         {
            cost = int(data.PriceCoins);
            if(cost > this._network.playerData.compound.resources.getAmount(GameResources.CASH))
            {
               this.openBuyCoinsScreen(true);
               if(onComplete != null)
               {
                  onComplete(false);
               }
               return;
            }
         }
         this._network.save({
            "item":itemKey,
            "oneOnly":oneOnly
         },SaveDataMethod.PAYVAULT_BUY,function(param1:Object):void
         {
            if(param1 == null)
            {
               transactionFailed.dispatch();
               if(onComplete != null)
               {
                  onComplete(false);
               }
               return;
            }
            if(param1.success === false)
            {
               switch(param1.error)
               {
                  case PlayerIOError.NotEnoughCoins.errorID:
                     openBuyCoinsScreen(true);
                     break;
                  default:
                     transactionFailed.dispatch();
               }
            }
            else if(param1.disabled === true)
            {
               transactionFailed.dispatch();
            }
            else
            {
               transactionSuccess.dispatch(itemKey);
            }
            if(onComplete != null)
            {
               onComplete(param1.success);
            }
         });
      }
      
      private function buyFuelPurchasePackage(param1:Object, param2:Function = null) : void
      {
         var cost:int;
         var doPurchase:Function;
         var packageName:String = null;
         var dlgConfirm:MessageBox = null;
         var data:Object = param1;
         var onComplete:Function = param2;
         if(data.PriceCoins == null)
         {
            if(onComplete != null)
            {
               onComplete(false);
            }
            return;
         }
         cost = int(data.PriceCoins);
         if(cost > this._network.playerData.compound.resources.getAmount(GameResources.CASH))
         {
            this.openBuyCoinsScreen(true);
            return;
         }
         packageName = this._lang.getString("offers." + data.key);
         doPurchase = function():void
         {
            var msg:BusyDialogue = null;
            msg = new BusyDialogue(_lang.getString("purchasing_package",packageName),"item-purchasing");
            msg.open();
            _network.save({"pack":data.key},SaveDataMethod.BUY_PACKAGE,function(param1:Object):void
            {
               msg.close();
               handlePurchaseResponse(param1,onComplete);
            });
         };
         if(cost > 0)
         {
            dlgConfirm = new MessageBox(this._lang.getString("store_confirm_msg","<b>" + packageName + "</b>"),"confirm-purchase");
            dlgConfirm.addTitle(this._lang.getString("store_confirm_title",packageName),BaseDialogue.TITLE_COLOR_BUY);
            dlgConfirm.addButton(this._lang.getString("store_confirm_cancel"));
            dlgConfirm.addButton(this._lang.getString("store_confirm_ok"),true,{
               "width":120,
               "buttonClass":PurchasePushButton,
               "cost":cost
            }).clicked.addOnce(function(param1:MouseEvent):void
            {
               doPurchase();
            });
            dlgConfirm.open();
         }
         else
         {
            doPurchase();
         }
      }
      
      private function handlePackage(param1:Object) : void
      {
         var dbItem:Object;
         var items:Array;
         var removeIfOffer:Boolean;
         var i:int = 0;
         var itemData:Object = null;
         var item:Item = null;
         var cooldownBytes:ByteArray = null;
         var data:Object = param1;
         if(data.success !== true)
         {
            return;
         }
         dbItem = data.dbItem;
         items = data.items as Array;
         if(items != null)
         {
            i = 0;
            while(i < items.length)
            {
               itemData = items[i];
               if(itemData != null)
               {
                  item = ItemFactory.createItemFromObject(itemData);
                  if(item != null)
                  {
                     this._network.playerData.giveItem(item);
                  }
               }
               i++;
            }
         }
         removeIfOffer = false;
         if(data.cooldown != null)
         {
            try
            {
               cooldownBytes = Base64.decodeToByteArray(data.cooldown);
               this._network.playerData.cooldowns.parse(cooldownBytes);
               removeIfOffer = true;
            }
            catch(e:Error)
            {
            }
         }
         if(data.oneTime)
         {
            this._network.playerData.oneTimePurchases.push(data.oneTime);
            removeIfOffer = true;
         }
         if(dbItem.type == "package" && removeIfOffer)
         {
            OfferSystem.getInstance().removeOffer(dbItem.key);
         }
         this.transactionSuccess.dispatch(dbItem.type,dbItem);
      }
      
      private function handlePurchaseResponse(param1:Object, param2:Function = null) : void
      {
         var _loc3_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:Item = null;
         var _loc8_:EffectItem = null;
         if(param1 == null || param1.disabled === true)
         {
            this.transactionFailed.dispatch();
            if(param2 != null)
            {
               param2(false);
            }
            return;
         }
         if(param1.success === false)
         {
            switch(param1.error)
            {
               case PlayerIOError.NotEnoughCoins.errorID:
                  this.openBuyCoinsScreen(true);
                  break;
               default:
                  this.transactionFailed.dispatch();
            }
            if(param2 != null)
            {
               param2(false);
            }
            return;
         }
         var _loc4_:Array = param1.items as Array;
         if(_loc4_ != null)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc4_.length)
            {
               _loc6_ = _loc4_[_loc3_];
               if(_loc6_ != null)
               {
                  _loc7_ = ItemFactory.createItemFromObject(_loc6_);
                  if(_loc7_ != null)
                  {
                     this._network.playerData.giveItem(_loc7_);
                     if(_loc6_.storeId != null)
                     {
                        try
                        {
                           if(_loc7_ is EffectItem)
                           {
                              _loc8_ = EffectItem(_loc7_);
                              Tracking.trackEvent("Player","Purchase",_loc8_.type + "_" + _loc8_.effect.type,Number(param1.cost));
                           }
                           else
                           {
                              Tracking.trackEvent("Player","Purchase",_loc6_.storeId,Number(param1.cost));
                           }
                        }
                        catch(error:Error)
                        {
                        }
                     }
                     this.transactionSuccess.dispatch("item",_loc7_);
                  }
               }
               _loc3_++;
            }
         }
         var _loc5_:Array = param1.packs as Array;
         if(_loc5_ != null)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc5_.length)
            {
               this.handlePackage(_loc5_[_loc3_]);
               _loc3_++;
            }
         }
         if(param2 != null)
         {
            param2(true);
         }
      }
      
      private function onTransactionSuccess(param1:String, ... rest) : void
      {
         var busyMsg:BusyDialogue = null;
         var data:Object = null;
         var storeItem:StoreItem = null;
         var storeCollection:StoreCollection = null;
         var collectionName:String = null;
         var transactionType:String = param1;
         var args:Array = rest;
         Tracking.trackEvent("Player","Purchase",transactionType);
         this._network.save(new Object(),SaveDataMethod.INCREMENT_PURCHASE_COUNT,function(param1:Object):void
         {
            if(param1["isFirst"] === true)
            {
               Tracking.trackEvent("Player","FirstPurchaseItem",transactionType);
               Tracking.trackEvent("Player","FirstPurchaseLevel",Network.getInstance().playerData.getPlayerSurvivor().level.toString());
               Tracking.trackEvent("Player","FirstPurchaseDays",String(Math.floor(param1["days"])));
            }
         });
         if(transactionType == "package")
         {
            data = args.length > 0 ? args[0] : "";
         }
         else if(transactionType.toLowerCase().indexOf("package") == 0)
         {
            data = transactionType;
            transactionType = "package";
         }
         else if(transactionType.toLowerCase().indexOf("inventoryupgrade") == 0)
         {
            data = transactionType;
            transactionType = "inventoryUpgrade";
         }
         else if(args.length > 0 && args[0] is String)
         {
            try
            {
               data = JSON.parse(unescape(args[0]));
               transactionType = data.type != null ? data.type : null;
            }
            catch(error:Error)
            {
            }
         }
         switch(transactionType)
         {
            case "item":
               if(data == null)
               {
                  return;
               }
               storeItem = this.purchaseCache[data.id];
               if(storeItem != null)
               {
                  busyMsg = new BusyDialogue(this._lang.getString("purchasing_item",storeItem.item.getName()),"item-purchasing");
                  this._network.startAsyncOp();
                  this._network.save(null,SaveDataMethod.CHECK_APPLY_DIRECT_PURCHASE,function(param1:Object):void
                  {
                     _network.completeAsyncOp();
                     busyMsg.close();
                     handlePurchaseResponse(param1);
                     delete purchaseCache[data.id];
                  });
               }
               break;
            case "itemcollection":
               if(data == null)
               {
                  return;
               }
               storeCollection = this.purchaseCache[data.id];
               if(storeCollection != null)
               {
                  collectionName = "Collection";
                  busyMsg = new BusyDialogue(this._lang.getString("purchasing_item",storeCollection),"item-purchasing");
                  this._network.startAsyncOp();
                  this._network.save(null,SaveDataMethod.CHECK_APPLY_DIRECT_PURCHASE,function(param1:Object):void
                  {
                     _network.completeAsyncOp();
                     busyMsg.close();
                     handlePurchaseResponse(param1);
                     delete purchaseCache[data.id];
                  });
               }
               break;
            case "fuel":
               if(args.length > 0)
               {
                  this._lastPurchaseAmount = int(args[0]);
               }
               busyMsg = new BusyDialogue(this._lang.getString("purchasing_fuel"),"item-purchasing");
               this._network.send(NetworkMessage.PURCHASE_COINS,null,function(param1:Object):void
               {
                  busyMsg.close();
                  if(param1 != null && param1.coins != null)
                  {
                     _network.playerData.compound.resources.setAmount(GameResources.CASH,uint(param1.coins));
                  }
                  transactionSuccess.dispatch(transactionType);
               });
               break;
            case "package":
            case "codepackage":
               busyMsg = new BusyDialogue(this._lang.getString("purchasing_package",this._lang.getString("offers." + data)),"item-purchasing");
               this._network.startAsyncOp();
               this._network.save(null,SaveDataMethod.CHECK_APPLY_DIRECT_PURCHASE,function(param1:Object):void
               {
                  _network.completeAsyncOp();
                  busyMsg.close();
                  handlePurchaseResponse(param1);
               });
               break;
            case PlayerUpgrades.getName(PlayerUpgrades.DeathMobileUpgrade):
               busyMsg = new BusyDialogue(this._lang.getString("appyling_upgrade"),"item-purchasing");
               this._network.startAsyncOp();
               this._network.save({"upgrade":transactionType},SaveDataMethod.CHECK_APPLY_DIRECT_PURCHASE,function(param1:Object):void
               {
                  _network.completeAsyncOp();
                  busyMsg.close();
                  if(param1.success !== true)
                  {
                     transactionFailed.dispatch();
                     return;
                  }
                  transactionSuccess.dispatch(transactionType);
               });
               Tracking.trackEvent("Player","Purchase",transactionType + "_Level" + Network.getInstance().playerData.getPlayerSurvivor().level);
               break;
            case "inventoryUpgrade":
               busyMsg = new BusyDialogue(this._lang.getString("appyling_upgrade"),"item-purchasing");
               this._network.startAsyncOp();
               this._network.save({"upgrade":transactionType},SaveDataMethod.CHECK_APPLY_DIRECT_PURCHASE,function(param1:Object):void
               {
                  _network.completeAsyncOp();
                  busyMsg.close();
                  if(param1.success !== true)
                  {
                     transactionFailed.dispatch();
                     return;
                  }
                  _network.playerData.setInventoryBaseSize(int(param1.size));
                  transactionSuccess.dispatch(transactionType);
               });
               break;
            default:
               this.transactionSuccess.dispatch(transactionType);
         }
         if(busyMsg != null)
         {
            busyMsg.open();
         }
      }
      
      private function onTransactionFailed() : void
      {
         this.transactionFailed.dispatch();
      }
      
      private function JS_openGetMore() : Boolean
      {
         if(this._network.costTableReady)
         {
            this.openBuyCoinsScreen(false);
            return true;
         }
         return false;
      }
      
      private function JS_openRedeemCode() : void
      {
         var _loc1_:PromoCodeDialogue = new PromoCodeDialogue();
         _loc1_.open();
      }
      
      private function JS_openHandlePayment(param1:Boolean, param2:String = "") : void
      {
         if(!param1)
         {
            return;
         }
         DialogueManager.getInstance().closeDialogue("reload-msg");
         this.onTransactionSuccess(param2);
      }
   }
}

class PaymentSystemSingletonEnforcer
{
   
   public function PaymentSystemSingletonEnforcer()
   {
      super();
   }
}
