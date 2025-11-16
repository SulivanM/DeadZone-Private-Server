package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class ListRoomsOutput extends Message
   {
      
      public var rooms:Array = [];
      
      public var roomsDummy:RoomInfo = null;
      
      public function ListRoomsOutput()
      {
         super();
         registerField("rooms","playerio.generated.messages.RoomInfo",11,3,1);
      }
   }
}

