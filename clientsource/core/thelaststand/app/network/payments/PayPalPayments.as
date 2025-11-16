package thelaststand.app.network.payments
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import org.osflash.signals.Signal;
   import playerio.PlayerIOError;
   import thelaststand.app.core.Config;
   import thelaststand.app.data.Currency;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.users.AbstractUser;
   import thelaststand.common.lang.Language;
   
   public class PayPalPayments implements IPaymentSystem
   {
      
      private var _transactionSuccess:Signal = new Signal(String);
      
      private var _transactionFailed:Signal = new Signal();
      
      public function PayPalPayments()
      {
         super();
      }
      
      public function get transactionSuccess() : Signal
      {
         return this._transactionSuccess;
      }
      
      public function get transactionFailed() : Signal
      {
         return this._transactionFailed;
      }
      
      public function buyCoins(param1:int, param2:String, param3:int, param4:Function = null) : void
      {
         var amount:int = param1;
         var currency:String = param2;
         var currencyAmount:int = param3;
         var onComplete:Function = param4;
         this.getPayPalCoinsURL(amount,currency,currencyAmount,function(param1:String):void
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("openWindow",param1);
            }
            else
            {
               navigateToURL(new URLRequest(param1),"_blank");
            }
            if(onComplete != null)
            {
               onComplete(true);
            }
         },function(param1:PlayerIOError):void
         {
            transactionFailed.dispatch();
            if(onComplete != null)
            {
               onComplete(false);
            }
            Network.getInstance().client.errorLog.writeError(param1.name,param1.message,param1.getStackTrace(),{});
         });
      }
      
      public function earnCoins() : void
      {
         var _loc1_:String = Config.xml.playerio.game_id.toString();
         var _loc2_:String = Config.xml.playerio.conn_id.toString();
         var _loc3_:String = Network.getInstance().client.connectUserId;
         var _loc4_:String = "http://api.playerio.com/payvault/trialpay/coinsredirect?gameid=" + _loc1_ + "&connectuserid=" + _loc3_ + "&connection=" + _loc2_;
         if(ExternalInterface.available)
         {
            ExternalInterface.call("openWindow",_loc4_);
         }
         else
         {
            navigateToURL(new URLRequest(_loc4_),"_blank");
         }
      }
      
      public function buyDirectItem(param1:String, param2:Object, param3:Function = null) : void
      {
         navigateToURL(new URLRequest(param2.paypalurl),"_blank");
         if(param3 != null)
         {
            param3(true);
         }
         var _loc4_:MessageBox = new MessageBox(Language.getInstance().getString("server_purchase_refresh_msg"),"reload-msg",true);
         _loc4_.addTitle(Language.getInstance().getString("server_purchase_refresh_title"));
         _loc4_.addButton(Language.getInstance().getString("server_purchase_refresh_ok"));
         _loc4_.open();
      }
      
      public function getBuyItemDirectData(param1:String, param2:Object = null, param3:Function = null, param4:Function = null) : void
      {
         var user:AbstractUser;
         var item:String = param1;
         var options:Object = param2;
         var onComplete:Function = param3;
         var onFail:Function = param4;
         var isPackage:Boolean = item.toLowerCase().indexOf("package") > -1;
         var lang:Language = Language.getInstance();
         var paymentData:Object = {
            "currency":Currency.US_DOLLARS,
            "item_name":(options != null && "title" in options ? options.title : lang.getString("offers." + item)),
            "image_url":(options != null && "image" in options ? options.image : Config.getPath("storage_url") + Config.getPath("armor.images." + (isPackage ? "buy_package" : item))),
            "no_shipping":"1",
            "cpp_header_image":Config.getPath("storage_url") + Config.getPath("armor.images.pp_header")
         };
         var returnData:String = options != null && "returnData" in options ? options.returnData : item;
         paymentData["return"] = Config.getPath("armor.payment_return_url") + "&item=" + returnData;
         paymentData["cancel_return"] = Config.getPath("armor.payment_cancel_return_url") + "&item=" + returnData;
         user = Network.getInstance().user;
         if(user.data != null && Boolean(user.data.email))
         {
            paymentData.email = user.data.email;
         }
         Network.getInstance().client.payVault.getBuyDirectInfo("paypal",paymentData,[{"itemKey":item}],function(param1:Object):void
         {
            if(onComplete != null)
            {
               param1.returnData = options != null ? options.returnData : null;
               onComplete(param1);
            }
         },function(param1:PlayerIOError):void
         {
            if(onFail != null)
            {
               onFail(param1);
            }
         });
      }
      
      public function getPayPalCoinsURL(param1:int, param2:String, param3:int, param4:Function, param5:Function = null) : void
      {
         var user:AbstractUser;
         var amount:int = param1;
         var currency:String = param2;
         var currencyAmount:int = param3;
         var onComplete:Function = param4;
         var onFail:Function = param5;
         var lang:Language = Language.getInstance();
         var formattedAmount:String = NumberFormatter.format(amount,0);
         var paymentData:Object = {
            "coinamount":amount.toString(),
            "currency":currency,
            "item_name":lang.getString("fb_buy_fuel_title",formattedAmount),
            "image_url":Config.getPath("storage_url") + Config.getPath("armor.images.buy_fuel"),
            "no_shipping":"1",
            "cpp_header_image":Config.getPath("storage_url") + Config.getPath("armor.images.pp_header")
         };
         var service:String = Network.getInstance().service;
         paymentData["return"] = Config.getPath(service + ".payment_return_url") + "&item=fuel";
         paymentData["cancel_return"] = Config.getPath(service + ".payment_cancel_return_url") + "&item=fuel";
         user = Network.getInstance().user;
         if(user.data != null && Boolean(user.data.email))
         {
            paymentData.email = user.data.email;
         }
         Network.getInstance().client.payVault.getBuyCoinsInfo("paypal",paymentData,function(param1:Object):void
         {
            onComplete(param1.paypalurl);
         },function(param1:PlayerIOError):void
         {
            if(onFail != null)
            {
               onFail(param1);
            }
         });
      }
   }
}

