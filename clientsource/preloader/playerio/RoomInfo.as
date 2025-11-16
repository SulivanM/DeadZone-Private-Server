package playerio
{
   public class RoomInfo
   {
      
      private var _id:String;
      
      private var _roomType:String;
      
      private var _onlineUsers:int;
      
      private var _roomData:Object;
      
      public function RoomInfo(param1:String, param2:String, param3:int, param4:Object)
      {
         super();
         _id = param1;
         _roomType = param2;
         _onlineUsers = param3;
         _roomData = param4;
      }
      
      public function get id() : String
      {
         return _id;
      }
      
      public function get serverType() : String
      {
         trace("serverType is deprecated, please use roomType.");
         return _roomType;
      }
      
      public function get roomType() : String
      {
         return _roomType;
      }
      
      public function get onlineUsers() : int
      {
         return _onlineUsers;
      }
      
      public function get initData() : Object
      {
         trace("initData is deprecated, please use data.");
         return _roomData;
      }
      
      public function get data() : Object
      {
         return _roomData;
      }
      
      public function toString() : String
      {
         var _loc1_:* = "[playerio.RoomInfo]\n";
         _loc1_ += "id:\t\t\t\t" + id + "\n";
         _loc1_ += "roomType:\t\t" + roomType + "\n";
         _loc1_ += "onlineUsers:\t" + onlineUsers + "\n";
         _loc1_ += "initData:\t\tId\t\t\t\t\t\tValue\n";
         _loc1_ += "\t\t\t\t-------------------------------------------\n";
         for(var _loc2_ in initData)
         {
            _loc1_ += "\t\t\t\t" + _loc2_ + "\t\t\t\t\t".substring(_loc2_.length / 4) + "\t" + initData[_loc2_] + "\n";
         }
         return _loc1_;
      }
   }
}

