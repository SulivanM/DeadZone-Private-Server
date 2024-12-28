package playerio.generated
{
   import flash.events.EventDispatcher;
   import playerio.Client;
   import playerio.generated.messages.CreateJoinRoomArgs;
   import playerio.generated.messages.CreateJoinRoomError;
   import playerio.generated.messages.CreateJoinRoomOutput;
   import playerio.generated.messages.CreateRoomArgs;
   import playerio.generated.messages.CreateRoomError;
   import playerio.generated.messages.CreateRoomOutput;
   import playerio.generated.messages.JoinRoomArgs;
   import playerio.generated.messages.JoinRoomError;
   import playerio.generated.messages.JoinRoomOutput;
   import playerio.generated.messages.ListRoomsArgs;
   import playerio.generated.messages.ListRoomsError;
   import playerio.generated.messages.ListRoomsOutput;
   import playerio.utils.Converter;
   import playerio.utils.HTTPChannel;
   
   public class Multiplayer extends EventDispatcher
   {
      protected var channel:HTTPChannel;
      
      protected var client:Client;
      
      public function Multiplayer(param1:HTTPChannel, param2:Client)
      {
         super();
         this.channel = param1;
         this.client = param2;
      }
      
      protected function _createRoom(param1:String, param2:String, param3:Boolean, param4:Object, param5:Boolean, param6:Function = null, param7:Function = null) : void
      {
         var roomId:String = param1;
         var roomType:String = param2;
         var visible:Boolean = param3;
         var roomData:Object = param4;
         var isDevRoom:Boolean = param5;
         var callback:Function = param6;
         var errorHandler:Function = param7;
         var input:CreateRoomArgs = new CreateRoomArgs(roomId,roomType,visible,Converter.toKeyValueArray(roomData),isDevRoom);
         var output:CreateRoomOutput = new CreateRoomOutput();
         channel.Request(21,input,output,new CreateRoomError(),function(param1:CreateRoomOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.roomId);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("Multiplayer.createRoom",e);
                  throw e;
               }
            }
         },function(param1:CreateRoomError):void
         {
            var _loc2_:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
            if(errorHandler != null)
            {
               errorHandler(_loc2_);
               return;
            }
            throw _loc2_;
         });
      }
      
      protected function _joinRoom(param1:String, param2:Object, param3:Boolean, param4:Function = null, param5:Function = null) : void
      {
         var roomId:String = param1;
         var joinData:Object = param2;
         var isDevRoom:Boolean = param3;
         var callback:Function = param4;
         var errorHandler:Function = param5;
         var input:JoinRoomArgs = new JoinRoomArgs(roomId,Converter.toKeyValueArray(joinData),isDevRoom);
         var output:JoinRoomOutput = new JoinRoomOutput();
         channel.Request(24,input,output,new JoinRoomError(),function(param1:JoinRoomOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.joinKey,param1.endpoints);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("Multiplayer.joinRoom",e);
                  throw e;
               }
            }
         },function(param1:JoinRoomError):void
         {
            var _loc2_:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
            if(errorHandler != null)
            {
               errorHandler(_loc2_);
               return;
            }
            throw _loc2_;
         });
      }
      
      protected function _listRooms(param1:String, param2:Object, param3:int, param4:int, param5:Boolean, param6:Function = null, param7:Function = null) : void
      {
         var roomType:String = param1;
         var searchCriteria:Object = param2;
         var resultLimit:int = param3;
         var resultOffset:int = param4;
         var onlyDevRooms:Boolean = param5;
         var callback:Function = param6;
         var errorHandler:Function = param7;
         var input:ListRoomsArgs = new ListRoomsArgs(roomType,Converter.toKeyValueArray(searchCriteria),resultLimit,resultOffset,onlyDevRooms);
         var output:ListRoomsOutput = new ListRoomsOutput();
         channel.Request(30,input,output,new ListRoomsError(),function(param1:ListRoomsOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(Converter.toRoomInfoArray(param1.rooms));
               }
               catch(e:Error)
               {
                  client.handleCallbackError("Multiplayer.listRooms",e);
                  throw e;
               }
            }
         },function(param1:ListRoomsError):void
         {
            var _loc2_:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
            if(errorHandler != null)
            {
               errorHandler(_loc2_);
               return;
            }
            throw _loc2_;
         });
      }
      
      protected function _createJoinRoom(param1:String, param2:String, param3:Boolean, param4:Object, param5:Object, param6:Boolean, param7:Function = null, param8:Function = null) : void
      {
         var roomId:String = param1;
         var roomType:String = param2;
         var visible:Boolean = param3;
         var roomData:Object = param4;
         var joinData:Object = param5;
         var isDevRoom:Boolean = param6;
         var callback:Function = param7;
         var errorHandler:Function = param8;
         var input:CreateJoinRoomArgs = new CreateJoinRoomArgs(roomId,roomType,visible,Converter.toKeyValueArray(roomData),Converter.toKeyValueArray(joinData),isDevRoom);
         var output:CreateJoinRoomOutput = new CreateJoinRoomOutput();
         channel.Request(27,input,output,new CreateJoinRoomError(),function(param1:CreateJoinRoomOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.roomId,param1.joinKey,param1.endpoints);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("Multiplayer.createJoinRoom",e);
                  throw e;
               }
            }
         },function(param1:CreateJoinRoomError):void
         {
            var _loc2_:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
            if(errorHandler != null)
            {
               errorHandler(_loc2_);
               return;
            }
            throw _loc2_;
         });
      }
   }
}

