package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class PayVaultPaymentInfoArgs extends Message
   {
      
      public var provider:String;
      
      public var purchaseArguments:Array = [];
      
      public var purchaseArgumentsDummy:KeyValuePair = null;
      
      public var items:Array = [];
      
      public var itemsDummy:PayVaultBuyItemInfo = null;
      
      public function PayVaultPaymentInfoArgs(param1:String, param2:Array, param3:Array)
      {
         super();
         registerField("provider","",9,1,1);
         registerField("purchaseArguments","playerio.generated.messages.KeyValuePair",11,3,2);
         registerField("items","playerio.generated.messages.PayVaultBuyItemInfo",11,3,3);
         this.provider = param1;
         this.purchaseArguments = param2;
         this.items = param3;
      }
   }
}

