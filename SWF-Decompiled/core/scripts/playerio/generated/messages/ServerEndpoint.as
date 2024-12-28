package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class ServerEndpoint extends Message
   {
      public var address:String;
      
      public var port:int;
      
      public function ServerEndpoint()
      {
         super();
         registerField("address","",9,1,1);
         registerField("port","",5,1,2);
      }
   }
}

