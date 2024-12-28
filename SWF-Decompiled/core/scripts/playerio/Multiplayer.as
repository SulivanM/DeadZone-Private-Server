package playerio
{
   import playerio.generated.Multiplayer;
   import playerio.utils.HTTPChannel;
   
   public class Multiplayer extends playerio.generated.Multiplayer
   {
      private var _developmentServer:String = null;
      
      private var _client:Client;
      
      public function Multiplayer(param1:HTTPChannel, param2:Client)
      {
         super(param1,param2);
      }
      
      public function createRoom(param1:String, param2:String, param3:Boolean, param4:Object, param5:Function = null, param6:Function = null) : void
      {
         _createRoom(param1,param2,param3,param4,_developmentServer != null,param5,param6);
      }
      
      public function joinRoom(param1:String, param2:Object, param3:Function = null, param4:Function = null) : void
      {
         var roomId:String = param1;
         var joinData:Object = param2;
         var callback:Function = param3;
         var errorHandler:Function = param4;
         _joinRoom(roomId,joinData,_developmentServer != null,function(param1:String, param2:Array):void
         {
            doConnect(roomId,param1,param2,joinData,callback,errorHandler);
         },errorHandler);
      }
      
      public function createJoinRoom(param1:String, param2:String, param3:Boolean, param4:Object, param5:Object, param6:Function = null, param7:Function = null) : void
      {
         var roomId:String = param1;
         var roomType:String = param2;
         var visible:Boolean = param3;
         var roomData:Object = param4;
         var joinData:Object = param5;
         var callback:Function = param6;
         var errorHandler:Function = param7;
         _createJoinRoom(roomId,roomType,visible,roomData,joinData,_developmentServer != null,function(param1:String, param2:String, param3:Array):void
         {
            doConnect(param1,param2,param3,joinData,callback,errorHandler);
         },errorHandler);
      }
      
      public function listRooms(param1:String, param2:Object, param3:int, param4:int, param5:Function = null, param6:Function = null) : void
      {
         _listRooms(param1,param2,param3,param4,_developmentServer != null,param5,param6);
      }
      
      public function set developmentServer(param1:String) : void
      {
         this._developmentServer = param1;
      }
      
      public function get developmentServer() : String
      {
         return this._developmentServer;
      }
      
      private function doConnect(param1:String, param2:String, param3:Array, param4:Object, param5:Function, param6:Function) : void
      {
         new Connection(client,param1,param2,param3,param4,param5,param6,_developmentServer);
      }
   }
}

