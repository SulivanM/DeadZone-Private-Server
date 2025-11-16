package thelaststand.app.network
{
   import playerio.Message;
   
   public class RPCResponse extends RPC
   {
      
      private var _success:Boolean;
      
      public function RPCResponse(param1:int, param2:String, param3:Boolean, param4:Object = null)
      {
         super(param1,param2,param4);
         this._success = param3;
      }
      
      public static function parse(param1:Message) : RPCResponse
      {
         var response:RPCResponse;
         var msg:Message = param1;
         var i:int = 0;
         var from:int = msg.getInt(i++);
         var to:int = msg.getInt(i++);
         var id:int = msg.getInt(i++);
         var type:String = msg.getString(i++);
         var success:Boolean = msg.getBoolean(i++);
         var data:Object = null;
         if(msg.length > i)
         {
            try
            {
               data = JSON.parse(msg.getString(i++));
            }
            catch(error:Error)
            {
               success = false;
            }
         }
         response = new RPCResponse(id,type,success,data);
         response._to = to;
         response._from = from;
         return response;
      }
      
      public static function create(param1:RPC, param2:Boolean = true, param3:Object = null) : RPCResponse
      {
         var _loc4_:RPCResponse = new RPCResponse(param1.id,param1.type,param2,param3);
         _loc4_._to = param1.from;
         _loc4_._from = param1.to;
         return _loc4_;
      }
      
      public function get success() : Boolean
      {
         return this._success;
      }
   }
}

