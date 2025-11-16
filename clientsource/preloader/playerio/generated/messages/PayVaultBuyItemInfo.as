package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class PayVaultBuyItemInfo extends Message
   {
      
      public var itemKey:String;
      
      public var payload:Array = [];
      
      public var payloadDummy:ObjectProperty = null;
      
      public function PayVaultBuyItemInfo()
      {
         super();
         registerField("itemKey","",9,1,1);
         registerField("payload","playerio.generated.messages.ObjectProperty",11,3,2);
      }
   }
}

