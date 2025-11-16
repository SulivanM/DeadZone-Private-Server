package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class RoomInfo extends Message
   {
      
      public var id:String;
      
      public var roomType:String;
      
      public var onlineUsers:int;
      
      public var roomData:Array = [];
      
      public var roomDataDummy:KeyValuePair = null;
      
      public function RoomInfo()
      {
         super();
         registerField("id","",9,1,1);
         registerField("roomType","",9,1,2);
         registerField("onlineUsers","",5,1,3);
         registerField("roomData","playerio.generated.messages.KeyValuePair",11,3,4);
      }
   }
}

