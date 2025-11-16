package thelaststand.app.network.payments
{
   import org.osflash.signals.Signal;
   
   public interface IPaymentSystem
   {
      
      function get transactionSuccess() : Signal;
      
      function get transactionFailed() : Signal;
      
      function buyCoins(param1:int, param2:String, param3:int, param4:Function = null) : void;
      
      function buyDirectItem(param1:String, param2:Object, param3:Function = null) : void;
      
      function getBuyItemDirectData(param1:String, param2:Object = null, param3:Function = null, param4:Function = null) : void;
      
      function earnCoins() : void;
   }
}

