package thelaststand.app.network.payments
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.junkbyte.console.Cc;
   import org.osflash.signals.Signal;
   import playerio.PlayerIOError;
   import thelaststand.app.core.Config;
   import thelaststand.app.data.Currency;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PlayerIOConnector;
   import thelaststand.common.lang.Language;
   
   public class PlayerIOPayments implements IPaymentSystem
   {
      
      private var _transactionSuccess:Signal = new Signal(String);
      
      private var _transactionFailed:Signal = new Signal();
      
      public function PlayerIOPayments()
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
         var formattedAmount:String;
         var options:Object = null;
         var amount:int = param1;
         var currency:String = param2;
         var currencyAmount:int = param3;
         var onComplete:Function = param4;
         Cc.log("PlayerIOPayments.buyCoins");
         Cc.log(amount);
         Cc.log(currency);
         Cc.log(currencyAmount);
         formattedAmount = NumberFormatter.format(amount,0);
         try
         {
            options = {
               "name":Language.getInstance().getString("fb_buy_fuel_title",formattedAmount),
               "description":Language.getInstance().getString("fb_buy_fuel_desc",formattedAmount),
               "icon":Config.getPath("storage_url") + Config.getPath("pio.images.buy_fuel"),
               "currency":currency.toUpperCase() || Currency.US_DOLLARS.toUpperCase(),
               "coinamount":amount
            };
         }
         catch(error:Error)
         {
            Network.getInstance().client.errorLog.writeError(error.name,error.message,error.getStackTrace(),{});
            transactionFailed.dispatch();
            if(onComplete != null)
            {
               onComplete(false);
            }
            return;
         }
         Cc.explode(options,-1);
         PlayerIOConnector.getInstance().client.publishingnetwork.payments.showBuyCoinsDialog(amount,options,function(param1:Object):void
         {
            Cc.explode(param1,-1);
            if(param1.error != null)
            {
               transactionFailed.dispatch();
               if(onComplete != null)
               {
                  onComplete(false);
               }
               return;
            }
            transactionSuccess.dispatch("fuel",amount);
            if(onComplete != null)
            {
               onComplete(true);
            }
         },function(param1:PlayerIOError):void
         {
            Cc.error(param1);
            if(param1.message == "cancelled")
            {
               if(onComplete != null)
               {
                  onComplete(false);
               }
               return;
            }
            Network.getInstance().client.errorLog.writeError(param1.name,param1.message,param1.getStackTrace(),{});
            transactionFailed.dispatch();
            if(onComplete != null)
            {
               onComplete(false);
            }
         });
      }
      
      public function buyDirectItem(param1:String, param2:Object, param3:Function = null) : void
      {
         var itemKey:String = param1;
         var buyInfo:Object = param2;
         var onComplete:Function = param3;
         var isPackage:Boolean = itemKey.toLowerCase().indexOf("package") > -1;
         var options:Object = {
            "name":(buyInfo != null && "title" in buyInfo ? buyInfo.title : Language.getInstance().getString("offers." + itemKey)),
            "description":(buyInfo != null && "description" in buyInfo ? buyInfo.description : Language.getInstance().getString("offers." + itemKey + "_desc")),
            "icon":(buyInfo != null && "image" in buyInfo ? buyInfo.image : Config.getPath("storage_url") + Config.getPath("pio.images." + (isPackage ? "buy_package" : itemKey))),
            "currency":(buyInfo != null && "currency" in buyInfo ? buyInfo.currency.toLowerCase() : Currency.US_DOLLARS.toLowerCase())
         };
         PlayerIOConnector.getInstance().client.publishingnetwork.payments.showBuyItemsDialog([{"itemKey":itemKey}],options,function(param1:Object):void
         {
            Cc.explode(param1,-1);
            if(param1.error != null)
            {
               transactionFailed.dispatch();
               if(onComplete != null)
               {
                  onComplete(false);
               }
               return;
            }
            transactionSuccess.dispatch(itemKey,buyInfo.returnData);
            if(onComplete != null)
            {
               onComplete(true);
            }
         },function(param1:PlayerIOError):void
         {
            Cc.error(param1);
            if(param1.message == "cancelled")
            {
               if(onComplete != null)
               {
                  onComplete(false);
               }
               return;
            }
            Network.getInstance().client.errorLog.writeError(param1.name,param1.message,param1.getStackTrace(),{});
            transactionFailed.dispatch();
            if(onComplete != null)
            {
               onComplete(false);
            }
         });
      }
      
      public function getBuyItemDirectData(param1:String, param2:Object = null, param3:Function = null, param4:Function = null) : void
      {
         var _loc6_:String = null;
         var _loc5_:Object = {"key":param1};
         for(_loc6_ in param2)
         {
            _loc5_[_loc6_] = param2[_loc6_];
         }
         param3(_loc5_);
      }
      
      public function earnCoins() : void
      {
      }
   }
}

