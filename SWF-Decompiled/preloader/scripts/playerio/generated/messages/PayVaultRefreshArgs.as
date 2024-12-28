package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class PayVaultRefreshArgs extends Message
   {
      public var lastVersion:String;
      
      public var targetUserId:String;
      
      public function PayVaultRefreshArgs(param1:String, param2:String)
      {
         super();
         registerField("lastVersion","",9,1,1);
         registerField("targetUserId","",9,1,2);
         this.lastVersion = param1;
         this.targetUserId = param2;
      }
   }
}

