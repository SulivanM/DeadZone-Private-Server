package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class JoinRoomArgs extends Message
   {
      
      public var roomId:String;
      
      public var joinData:Array = [];
      
      public var joinDataDummy:KeyValuePair = null;
      
      public var isDevRoom:Boolean;
      
      public function JoinRoomArgs(param1:String, param2:Array, param3:Boolean)
      {
         super();
         registerField("roomId","",9,1,1);
         registerField("joinData","playerio.generated.messages.KeyValuePair",11,3,2);
         registerField("isDevRoom","",8,1,3);
         this.roomId = param1;
         this.joinData = param2;
         this.isDevRoom = param3;
      }
   }
}

