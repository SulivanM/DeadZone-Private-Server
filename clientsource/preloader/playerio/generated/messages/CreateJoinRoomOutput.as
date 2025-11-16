package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class CreateJoinRoomOutput extends Message
   {
      
      public var roomId:String;
      
      public var joinKey:String;
      
      public var endpoints:Array = [];
      
      public var endpointsDummy:ServerEndpoint = null;
      
      public function CreateJoinRoomOutput()
      {
         super();
         registerField("roomId","",9,1,1);
         registerField("joinKey","",9,1,2);
         registerField("endpoints","playerio.generated.messages.ServerEndpoint",11,3,3);
      }
   }
}

