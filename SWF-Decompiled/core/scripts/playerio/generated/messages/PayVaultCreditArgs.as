package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class PayVaultCreditArgs extends Message
   {
      public var amount:uint;
      
      public var reason:String;
      
      public var targetUserId:String;
      
      public function PayVaultCreditArgs(param1:uint, param2:String, param3:String)
      {
         super();
         registerField("amount","",13,1,1);
         registerField("reason","",9,1,2);
         registerField("targetUserId","",9,1,3);
         this.amount = param1;
         this.reason = param2;
         this.targetUserId = param3;
      }
   }
}

