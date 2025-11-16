package thelaststand.app.network
{
   import playerio.Message;
   
   public class RPC
   {
      
      private var _id:int;
      
      private var _type:String;
      
      private var _data:Object;
      
      protected var _to:uint;
      
      protected var _from:uint;
      
      public function RPC(param1:int, param2:String, param3:Object = null)
      {
         super();
         this._id = param1;
         this._type = param2;
         this._data = param3;
      }
      
      public static function parse(param1:Message) : RPC
      {
         var rpc:RPC;
         var msg:Message = param1;
         var i:uint = 0;
         var from:uint = uint(msg.getInt(i++));
         var to:uint = uint(msg.getInt(i++));
         var id:int = msg.getInt(i++);
         var type:String = msg.getString(i++);
         var data:Object = null;
         if(msg.length > i)
         {
            try
            {
               data = JSON.parse(msg.getString(i++));
            }
            catch(error:Error)
            {
               return null;
            }
         }
         rpc = new RPC(id,type,data);
         rpc._to = to;
         rpc._from = from;
         return rpc;
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function get to() : uint
      {
         return this._to;
      }
      
      public function get from() : uint
      {
         return this._from;
      }
   }
}

