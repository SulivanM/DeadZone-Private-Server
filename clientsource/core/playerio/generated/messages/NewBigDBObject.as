package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class NewBigDBObject extends Message
   {
      
      public var table:String;
      
      public var key:String;
      
      public var properties:Array = [];
      
      public var propertiesDummy:ObjectProperty = null;
      
      public function NewBigDBObject()
      {
         super();
         registerField("table","",9,1,1);
         registerField("key","",9,1,2);
         registerField("properties","playerio.generated.messages.ObjectProperty",11,3,3);
      }
   }
}

