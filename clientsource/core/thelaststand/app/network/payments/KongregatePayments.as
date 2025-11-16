package thelaststand.app.network.payments
{
   import org.osflash.signals.Signal;
   import thelaststand.app.core.SharedResources;
   import thelaststand.app.network.Network;
   
   public class KongregatePayments implements IPaymentSystem
   {
      
      private var _transactionSuccess:Signal = new Signal(String);
      
      private var _transactionFailed:Signal = new Signal();
      
      public function KongregatePayments()
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
         try
         {
            SharedResources.kongregateAPI.mtx.purchaseItems(["coins" + amount],function(param1:Object):void
            {
               if(param1.success === true)
               {
                  transactionSuccess.dispatch("fuel",amount);
                  if(onComplete != null)
                  {
                     onComplete(true);
                  }
               }
               else
               {
                  transactionFailed.dispatch();
                  if(onComplete != null)
                  {
                     onComplete(false);
                  }
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
      }
      
      public function buyDirectItem(param1:String, param2:Object, param3:Function = null) : void
      {
         var itemKey:String = param1;
         var buyInfo:Object = param2;
         var onComplete:Function = param3;
         try
         {
            SharedResources.kongregateAPI.mtx.purchaseItems(["item" + itemKey.toLowerCase()],function(param1:Object):void
            {
               if(param1.success === false)
               {
                  transactionFailed.dispatch();
               }
               else
               {
                  transactionSuccess.dispatch(itemKey,buyInfo.returnData);
               }
               if(onComplete != null)
               {
                  onComplete(param1.success);
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
      }
      
      public function earnCoins() : void
      {
         throw new Error("Not implemented.");
      }
      
      public function getBuyItemDirectData(param1:String, param2:Object = null, param3:Function = null, param4:Function = null) : void
      {
         if(param3 != null)
         {
            param3({
               "key":param1,
               "returnData":(param2 != null ? param2.returnData : null)
            });
         }
      }
   }
}

