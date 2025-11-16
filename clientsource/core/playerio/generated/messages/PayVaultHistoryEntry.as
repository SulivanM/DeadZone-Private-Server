package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class PayVaultHistoryEntry extends Message
   {
      
      public var amount:int;
      
      public var type:String;
      
      public var timestamp:Number;
      
      public var itemKeys:Array = [];
      
      public var reason:String;
      
      public var providerTransactionId:String;
      
      public var providerPrice:String;
      
      public function PayVaultHistoryEntry()
      {
         super();
         registerField("amount","",5,1,1);
         registerField("type","",9,1,2);
         registerField("timestamp","",3,1,3);
         registerField("itemKeys","",9,3,4);
         registerField("reason","",9,1,5);
         registerField("providerTransactionId","",9,1,6);
         registerField("providerPrice","",9,1,7);
      }
   }
}

