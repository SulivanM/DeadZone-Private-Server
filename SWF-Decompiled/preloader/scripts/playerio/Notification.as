package playerio
{
   public class Notification
   {
      private var _recipientUserId:String;
      
      private var _endpointType:String;
      
      private var _data:Object;
      
      public function Notification(param1:String, param2:String)
      {
         super();
         this._recipientUserId = param1;
         this._endpointType = param2;
         this._data = {};
      }
      
      public function get recipientUserId() : String
      {
         return _recipientUserId;
      }
      
      public function get endpointType() : String
      {
         return _endpointType;
      }
      
      public function get data() : Object
      {
         return _data;
      }
      
      public function set(param1:String, param2:String) : Notification
      {
         this._data[param1] = param2;
         return this;
      }
   }
}

