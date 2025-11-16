package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class BigDBObjectId extends Message
   {
      
      public var table:String;
      
      public var keys:Array = [];
      
      public function BigDBObjectId()
      {
         super();
         registerField("table","",9,1,1);
         registerField("keys","",9,3,2);
      }
   }
}

