package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class ConnectError extends Message
   {
      public var errorCode:int;
      
      public var message:String;
      
      public function ConnectError()
      {
         super();
         registerField("errorCode","",5,1,1);
         registerField("message","",9,1,2);
      }
   }
}

