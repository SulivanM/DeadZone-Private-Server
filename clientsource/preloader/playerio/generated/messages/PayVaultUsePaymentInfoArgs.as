package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class PayVaultUsePaymentInfoArgs extends Message
   {
      
      public var provider:String;
      
      public var providerArguments:Array = [];
      
      public var providerArgumentsDummy:KeyValuePair = null;
      
      public function PayVaultUsePaymentInfoArgs(param1:String, param2:Array)
      {
         super();
         registerField("provider","",9,1,1);
         registerField("providerArguments","playerio.generated.messages.KeyValuePair",11,3,2);
         this.provider = param1;
         this.providerArguments = param2;
      }
   }
}

