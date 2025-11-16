package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class PayVaultContents extends Message
   {
      
      public var version:String;
      
      public var coins:int;
      
      public var items:Array = [];
      
      public var itemsDummy:PayVaultItem = null;
      
      public function PayVaultContents()
      {
         super();
         registerField("version","",9,1,1);
         registerField("coins","",5,1,2);
         registerField("items","playerio.generated.messages.PayVaultItem",11,3,3);
      }
   }
}

