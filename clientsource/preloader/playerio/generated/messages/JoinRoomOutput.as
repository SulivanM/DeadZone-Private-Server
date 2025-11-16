package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class JoinRoomOutput extends Message
   {
      
      public var joinKey:String;
      
      public var endpoints:Array = [];
      
      public var endpointsDummy:ServerEndpoint = null;
      
      public function JoinRoomOutput()
      {
         super();
         registerField("joinKey","",9,1,1);
         registerField("endpoints","playerio.generated.messages.ServerEndpoint",11,3,2);
      }
   }
}

