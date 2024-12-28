package playerio
{
   import playerio.generated.PlayerIOError;
   import playerio.utils.Converter;
   
   internal class PublishingNetworkPayments
   {
      private var _client:Client;
      
      public function PublishingNetworkPayments(param1:Client)
      {
         super();
         this._client = param1;
      }
      
      public function showBuyCoinsDialog(param1:int, param2:Object, param3:Function, param4:Function) : void
      {
         var cointamount:int = param1;
         var purchaseArguments:Object = param2;
         var callback:Function = param3;
         var errorCallback:Function = param4;
         if(purchaseArguments == null)
         {
            purchaseArguments = {};
         }
         purchaseArguments["coinamount"] = cointamount.toString();
         _client.payVault.getBuyCoinsInfo("publishingnetwork",purchaseArguments,function(param1:Object):void
         {
            var info:Object = param1;
            PublishingNetwork._internal_showDialog("buy",info,_client.channel,function(param1:Object):void
            {
               if(param1["error"] != undefined && errorCallback != null)
               {
                  errorCallback(new playerio.generated.PlayerIOError(param1["error"],playerio.PlayerIOError.GeneralError.errorID));
               }
               else if(callback != null)
               {
                  callback(param1);
               }
            });
         },errorCallback);
      }
      
      public function showBuyItemsDialog(param1:Array, param2:Object, param3:Function, param4:Function) : void
      {
         var items:Array = param1;
         var purchaseArguments:Object = param2;
         var callback:Function = param3;
         var errorCallback:Function = param4;
         _client.payVault.getBuyDirectInfo("publishingnetwork",purchaseArguments,Converter.toBuyItemInfoArray(items),function(param1:Object):void
         {
            var info:Object = param1;
            PublishingNetwork._internal_showDialog("buy",info,_client.channel,function(param1:Object):void
            {
               if(param1["error"] != undefined && errorCallback != null)
               {
                  errorCallback(new playerio.generated.PlayerIOError(param1["error"],playerio.PlayerIOError.GeneralError.errorID));
               }
               else if(callback != null)
               {
                  callback(param1);
               }
            });
         },errorCallback);
      }
   }
}

