package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class PayVaultItem extends Message
   {
      
      public var id:String;
      
      public var itemKey:String;
      
      public var purchaseDate:Number;
      
      public var properties:Array = [];
      
      public var propertiesDummy:ObjectProperty = null;
      
      public function PayVaultItem()
      {
         super();
         registerField("id","",9,1,1);
         registerField("itemKey","",9,1,2);
         registerField("purchaseDate","",3,1,3);
         registerField("properties","playerio.generated.messages.ObjectProperty",11,3,4);
      }
   }
}

