package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class KeyValuePair extends Message
   {
      public var key:String;
      
      public var value:String;
      
      public function KeyValuePair()
      {
         super();
         registerField("key","",9,1,1);
         registerField("value","",9,1,2);
      }
   }
}

