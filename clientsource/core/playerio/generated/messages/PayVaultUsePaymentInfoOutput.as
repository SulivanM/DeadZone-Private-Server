package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class PayVaultUsePaymentInfoOutput extends Message
   {
      
      public var providerResults:Array = [];
      
      public var providerResultsDummy:KeyValuePair = null;
      
      public var vaultContents:PayVaultContents;
      
      public var vaultContentsDummy:PayVaultContents = null;
      
      public function PayVaultUsePaymentInfoOutput()
      {
         super();
         registerField("providerResults","playerio.generated.messages.KeyValuePair",11,3,1);
         registerField("vaultContents","playerio.generated.messages.PayVaultContents",11,1,2);
      }
   }
}

