package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class ArrayProperty extends Message
   {
      public var index:int;
      
      public var value:ValueObject;
      
      public var valueDummy:ValueObject = null;
      
      public function ArrayProperty()
      {
         super();
         registerField("index","",5,1,1);
         registerField("value","playerio.generated.messages.ValueObject",11,1,2);
      }
   }
}

