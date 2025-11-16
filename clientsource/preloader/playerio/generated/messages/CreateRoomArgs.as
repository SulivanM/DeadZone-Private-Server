package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class CreateRoomArgs extends Message
   {
      
      public var roomId:String;
      
      public var roomType:String;
      
      public var visible:Boolean;
      
      public var roomData:Array = [];
      
      public var roomDataDummy:KeyValuePair = null;
      
      public var isDevRoom:Boolean;
      
      public function CreateRoomArgs(param1:String, param2:String, param3:Boolean, param4:Array, param5:Boolean)
      {
         super();
         registerField("roomId","",9,1,1);
         registerField("roomType","",9,1,2);
         registerField("visible","",8,1,3);
         registerField("roomData","playerio.generated.messages.KeyValuePair",11,3,4);
         registerField("isDevRoom","",8,1,5);
         this.roomId = param1;
         this.roomType = param2;
         this.visible = param3;
         this.roomData = param4;
         this.isDevRoom = param5;
      }
   }
}

