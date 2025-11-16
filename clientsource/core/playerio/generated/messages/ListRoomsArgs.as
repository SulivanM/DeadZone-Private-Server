package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class ListRoomsArgs extends Message
   {
      
      public var roomType:String;
      
      public var searchCriteria:Array = [];
      
      public var searchCriteriaDummy:KeyValuePair = null;
      
      public var resultLimit:int;
      
      public var resultOffset:int;
      
      public var onlyDevRooms:Boolean;
      
      public function ListRoomsArgs(param1:String, param2:Array, param3:int, param4:int, param5:Boolean)
      {
         super();
         registerField("roomType","",9,1,1);
         registerField("searchCriteria","playerio.generated.messages.KeyValuePair",11,3,2);
         registerField("resultLimit","",5,1,3);
         registerField("resultOffset","",5,1,4);
         registerField("onlyDevRooms","",8,1,5);
         this.roomType = param1;
         this.searchCriteria = param2;
         this.resultLimit = param3;
         this.resultOffset = param4;
         this.onlyDevRooms = param5;
      }
   }
}

