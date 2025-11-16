package thelaststand.app.network.payments
{
   import com.exileetiquette.utils.NumberFormatter;
   import org.osflash.signals.Signal;
   import playerio.PlayerIOError;
   import playerio.facebook.FB;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class FacebookPayments implements IPaymentSystem
   {
      
      private var _transactionSuccess:Signal = new Signal(String);
      
      private var _transactionFailed:Signal = new Signal();
      
      public function FacebookPayments()
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
         var formattedAmount:String = NumberFormatter.format(amount,0);
         Network.getInstance().client.payVault.getBuyCoinsInfo("facebookv2",{
            "coinamount":amount.toString(),
            "currencies":"USD",
            "title":Language.getInstance().getString("fb_buy_fuel_title",formattedAmount),
            "description":Language.getInstance().getString("fb_buy_fuel_desc",formattedAmount),
            "image":Config.getPath("storage_url") + Config.getPath("fb.images.buy_fuel"),
            "product_url":Config.getPath("fb.canvas_url")
         },function(param1:Object):void
         {
            var info:Object = param1;
            try
            {
               FB.ui(info,function(param1:Object):void
               {
                  if(param1 != null && param1.status == "completed")
                  {
                     Tracking.trackCoinPurchaseFB(param1.order_id,amount,currencyAmount);
                     transactionSuccess.dispatch("fuel",amount);
                     if(onComplete != null)
                     {
                        onComplete(true);
                     }
                  }
                  else if(onComplete != null)
                  {
                     onComplete(false);
                  }
               });
            }
            catch(err:Error)
            {
               transactionFailed.dispatch();
               if(onComplete != null)
               {
                  onComplete(false);
               }
               Network.getInstance().client.errorLog.writeError(err.name,err.message,err.getStackTrace(),{});
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
         var lang:Language = Language.getInstance();
         Network.getInstance().client.payVault.getBuyCoinsInfo("facebook",{
            "action":"earn_currency",
            "title":lang.getString("fb_earn_fuel_title"),
            "description":lang.getString("fb_earn_fuel_desc"),
            "image":Config.getPath("storage_url") + Config.getPath("fb.images.earn_fuel")
         },function(param1:Object):void
         {
            var info:Object = param1;
            try
            {
               FB.ui(info,function(param1:Object):void
               {
                  if(param1 == null)
                  {
                     return;
                  }
                  Tracking.trackPageview("offers");
                  Tracking.trackEvent("Offers","opened");
               });
            }
            catch(err:Error)
            {
               transactionFailed.dispatch();
               Network.getInstance().client.errorLog.writeError(err.name,err.message,err.getStackTrace(),{});
            }
         },function(param1:PlayerIOError):void
         {
            transactionFailed.dispatch();
            Network.getInstance().client.errorLog.writeError(param1.name,param1.message,param1.getStackTrace(),{});
         });
      }
      
      public function buyDirectItem(param1:String, param2:Object, param3:Function = null) : void
      {
         var returnData:String = null;
         var itemKey:String = param1;
         var buyInfo:Object = param2;
         var onComplete:Function = param3;
         try
         {
            returnData = buyInfo.returnData;
            delete buyInfo.returnData;
            FB.ui(buyInfo,function(param1:Object):void
            {
               if(param1 != null && param1.status == "completed")
               {
                  transactionSuccess.dispatch(itemKey,returnData);
                  if(onComplete != null)
                  {
                     onComplete(true);
                  }
               }
               else
               {
                  if(onComplete != null)
                  {
                     onComplete(false);
                  }
                  transactionFailed.dispatch();
               }
            });
         }
         catch(err:Error)
         {
            if(onComplete != null)
            {
               onComplete(false);
            }
            transactionFailed.dispatch();
         }
      }
      
      public function getBuyItemDirectData(param1:String, param2:Object = null, param3:Function = null, param4:Function = null) : void
      {
         var item:String = param1;
         var options:Object = param2;
         var onComplete:Function = param3;
         var onFail:Function = param4;
         var lang:Language = Language.getInstance();
         var provider:String = "facebookv2";
         var isPackage:Boolean = item.toLowerCase().indexOf("package") > -1;
         var paymentData:Object = {
            "currencies":"USD",
            "title":(options != null && "title" in options ? options.title : lang.getString("offers." + item)),
            "description":(options != null && "description" in options ? options.description : lang.getString("offers." + item + "_desc")),
            "image":(options != null && "image" in options ? options.image : Config.getPath("storage_url") + Config.getPath("armor.images." + (isPackage ? "buy_package" : item))),
            "product_url":Config.getPath("fb.app_url")
         };
         Network.getInstance().client.payVault.getBuyDirectInfo(provider,paymentData,[{"itemKey":item}],function(param1:Object):void
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
   }
}

