package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class ObjectProperty extends Message
   {
      public var name:String;
      
      public var value:ValueObject;
      
      public var valueDummy:ValueObject = null;
      
      public function ObjectProperty()
      {
         super();
         registerField("name","",9,1,1);
         registerField("value","playerio.generated.messages.ValueObject",11,1,2);
      }
   }
}

