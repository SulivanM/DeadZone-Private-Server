package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class BigDBObject extends Message
   {
      
      public var key:String;
      
      public var version:String;
      
      public var properties:Array = [];
      
      public var propertiesDummy:ObjectProperty = null;
      
      public var creator:uint;
      
      public function BigDBObject()
      {
         super();
         registerField("key","",9,1,1);
         registerField("version","",9,1,2);
         registerField("properties","playerio.generated.messages.ObjectProperty",11,3,3);
         registerField("creator","",13,1,4);
      }
   }
}

