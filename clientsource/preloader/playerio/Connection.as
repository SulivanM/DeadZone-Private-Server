package playerio
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.Socket;
   import flash.utils.ByteArray;
   import playerio.generated.PlayerIOError;
   import playerio.generated.messages.ServerEndpoint;
   import playerio.utils.BinarySerializer;
   
   public class Connection
   {
      
      private static var connections:Array = [];
      
      private static const encodeChars:Array = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9","+","/"];
      
      private static const decodeChars:Array = [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,62,-1,-1,-1,63,52,53,54,55,56,57,58,59,60,61,-1,-1,-1,-1,-1,-1,-1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,-1,-1,-1,-1,-1,-1,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,-1,-1,-1,-1,-1];
      
      private var socket:Socket;
      
      private var serializer:BinarySerializer;
      
      private var messageHandlers:Array = [];
      
      private var disconnectHandlers:Array = [];
      
      private var errorHandler:Function;
      
      private var client:Client;
      
      private var devserver:String;
      
      private var callback:Function;
      
      public var roomId:String;
      
      private var debugArr:ByteArray = new ByteArray();
      
      private var sendDebugInfo:Boolean = true;
      
      private var messagesReceived:int = 0;
      
      public function Connection(param1:Client, param2:String, param3:String, param4:Array, param5:Object, param6:Function, param7:Function, param8:String)
      {
         super();
         connections.push(this);
         this.client = param1;
         this.roomId = param2;
         this.errorHandler = param7;
         this.devserver = param8;
         this.callback = param6;
         serializer = new BinarySerializer();
         serializer.addEventListener("onMessage",handleMessage);
         if(param4.length > 1 && param4[0].port == 80)
         {
            param4.push(param4.shift());
         }
         doConnect(param3,param5,param4);
      }
      
      public static function encode(param1:ByteArray) : String
      {
         var _loc2_:* = 0;
         var _loc7_:Array = [];
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:int = param1.length % 3;
         var _loc4_:int = param1.length - _loc3_;
         while(_loc6_ < _loc4_)
         {
            _loc2_ = param1[_loc6_++] << 16 | param1[_loc6_++] << 8 | param1[_loc6_++];
            _loc7_[_loc5_++] = encodeChars[_loc2_ >> 18] + encodeChars[_loc2_ >> 12 & 0x3F] + encodeChars[_loc2_ >> 6 & 0x3F] + encodeChars[_loc2_ & 0x3F];
         }
         if(_loc3_ == 1)
         {
            _loc2_ = int(param1[_loc6_++]);
            _loc7_[_loc5_++] = encodeChars[_loc2_ >> 2] + encodeChars[(_loc2_ & 3) << 4] + "==";
         }
         else if(_loc3_ == 2)
         {
            _loc2_ = param1[_loc6_++] << 8 | param1[_loc6_++];
            _loc7_[_loc5_++] = encodeChars[_loc2_ >> 10] + encodeChars[_loc2_ >> 4 & 0x3F] + encodeChars[(_loc2_ & 0x0F) << 2] + "=";
         }
         return _loc7_.join("");
      }
      
      private function doConnect(param1:String, param2:Object, param3:Array) : void
      {
         var tempSS:Socket;
         var serverInfo:Array;
         var key:String = param1;
         var joinData:Object = param2;
         var endpoints:Array = param3;
         var endpoint:ServerEndpoint = endpoints.shift() as ServerEndpoint;
         var hadConnection:Boolean = false;
         var disposed:Boolean = false;
         if(devserver != null)
         {
            serverInfo = devserver.split(":");
            tempSS = new Socket(serverInfo[0],serverInfo[1]);
         }
         else
         {
            tempSS = new Socket(endpoint.address,endpoint.port);
         }
         tempSS.addEventListener("close",function():void
         {
            if(disposed)
            {
               return;
            }
            for each(var _loc1_ in disconnectHandlers)
            {
               try
               {
                  _loc1_();
               }
               catch(e:Error)
               {
                  client.handleCallbackError("Connection.addDisconnectHandler",e);
                  throw e;
               }
            }
         });
         tempSS.addEventListener("connect",function(param1:Event):void
         {
            if(disposed)
            {
               try
               {
                  tempSS.close();
               }
               catch(e:Error)
               {
               }
               return;
            }
            socket = tempSS;
            hadConnection = true;
            tempSS.writeByte(0);
            tempSS.flush();
            var _loc3_:Message = createMessage("join",key);
            for(var _loc2_ in joinData)
            {
               _loc3_.add(_loc2_.toString());
               _loc3_.add(joinData[_loc2_].toString());
            }
            sendMessage(_loc3_);
         });
         tempSS.addEventListener("ioError",function(param1:IOErrorEvent):void
         {
            disposed = true;
            try
            {
               tempSS.close();
            }
            catch(e:Error)
            {
            }
            if(devserver)
            {
               throwError("Unable to connect to development server on " + devserver + ". Is the development server running?",1);
            }
            else if(endpoints.length != 0 && !hadConnection)
            {
               doConnect(key,joinData,endpoints);
            }
            else
            {
               throwError("Unable to connect to player.io multiplayer server due to IO Error [" + param1.text + "]",1);
            }
         });
         tempSS.addEventListener("securityError",function(param1:SecurityErrorEvent):void
         {
            disposed = true;
            try
            {
               tempSS.close();
            }
            catch(e:Error)
            {
            }
            if(!hadConnection)
            {
               if(endpoints.length != 0 && !hadConnection)
               {
                  doConnect(key,joinData,endpoints);
               }
               else
               {
                  throwError("Unable to connect to player.io multiplayer server due to Security Error [" + param1.text + "]",1);
               }
            }
         });
         tempSS.addEventListener("socketData",function():void
         {
            var _loc2_:int = 0;
            var _loc1_:int = 0;
            if(disposed)
            {
               try
               {
                  tempSS.close();
               }
               catch(e:Error)
               {
               }
               return;
            }
            var _loc3_:int = int(tempSS.bytesAvailable);
            _loc2_ = 0;
            while(_loc2_ < _loc3_)
            {
               _loc1_ = int(tempSS.readUnsignedByte());
               if(debugArr.length < 102400)
               {
                  debugArr.writeByte(_loc1_);
               }
               else
               {
                  sendDebugInfo = false;
               }
               try
               {
                  serializer.AddByte(_loc1_);
               }
               catch(e:Error)
               {
                  if(sendDebugInfo)
                  {
                     client.handleSystemError("Unable to deserialize multiplayer message",e,{"binary":encode(debugArr)});
                  }
                  throw e;
               }
               _loc2_++;
            }
         });
      }
      
      public function addMessageHandler(param1:String, param2:Function) : void
      {
         messageHandlers.push(new MessageHandler(param1,param2));
      }
      
      public function removeMessageHandler(param1:String, param2:Function) : void
      {
         var _loc3_:int = 0;
         var _loc4_:MessageHandler = null;
         _loc3_ = 0;
         while(_loc3_ < messageHandlers.length)
         {
            _loc4_ = messageHandlers[_loc3_] as MessageHandler;
            if(_loc4_.type == param1 && _loc4_.handler == param2)
            {
               messageHandlers.splice(_loc3_,1);
               return;
            }
            _loc3_++;
         }
      }
      
      public function disconnect() : void
      {
         if(socket && socket.connected)
         {
            socket.close();
         }
      }
      
      public function addDisconnectHandler(param1:Function) : void
      {
         disconnectHandlers.push(param1);
      }
      
      public function removeDisconnectHandler(param1:Function) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < disconnectHandlers.length)
         {
            if(disconnectHandlers[_loc2_] == param1)
            {
               disconnectHandlers.splice(_loc2_,1);
               return;
            }
            _loc2_++;
         }
      }
      
      public function get connected() : Boolean
      {
         return socket.connected;
      }
      
      public function createMessage(param1:String, ... rest) : Message
      {
         var _loc3_:int = 0;
         var _loc4_:Message = new Message(param1);
         _loc3_ = 0;
         while(_loc3_ < rest.length)
         {
            _loc4_.add(rest[_loc3_]);
            _loc3_++;
         }
         return _loc4_;
      }
      
      public function send(param1:String, ... rest) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Message = new Message(param1);
         _loc3_ = 0;
         while(_loc3_ < rest.length)
         {
            _loc4_.add(rest[_loc3_]);
            _loc3_++;
         }
         sendMessage(_loc4_);
      }
      
      public function sendMessage(param1:Message) : void
      {
         var _loc2_:ByteArray = null;
         if(socket && socket.connected)
         {
            _loc2_ = serializer.SerializeMessage(param1 as Message);
            _loc2_.position = 0;
            socket.writeBytes(_loc2_,0,_loc2_.length);
            socket.flush();
         }
         else
         {
            throwError("Unable to send data to server when disconnected from server",2);
         }
      }
      
      private function handleMessage(param1:MessageEvent) : void
      {
         var _loc5_:playerio.generated.PlayerIOError = null;
         var _loc4_:int = 0;
         var _loc6_:MessageHandler = null;
         var _loc3_:Array = null;
         var _loc2_:int = 0;
         messagesReceived = messagesReceived + 1;
         if(param1.message.type == "playerio.joinresult")
         {
            if(param1.message.getBoolean(0))
            {
               try
               {
                  callback(this);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("Connection.connect",e);
                  throw e;
               }
            }
            else
            {
               _loc5_ = new playerio.generated.PlayerIOError(param1.message.getString(2),param1.message.getInt(1));
               if(errorHandler == null)
               {
                  throw _loc5_;
               }
               errorHandler(_loc5_);
            }
         }
         else
         {
            _loc4_ = 0;
            while(_loc4_ < messageHandlers.length)
            {
               _loc6_ = messageHandlers[_loc4_] as MessageHandler;
               if(_loc6_.type == param1.message.type || _loc6_.type == null || _loc6_.type == "*")
               {
                  _loc3_ = [param1.message];
                  _loc2_ = 0;
                  while(_loc2_ < param1.message.length && _loc2_ < _loc6_.handler.length - 1)
                  {
                     _loc3_.push(param1.message.getObject(_loc2_));
                     _loc2_++;
                  }
                  try
                  {
                     _loc6_.handler.apply(_loc6_.handler,_loc3_);
                  }
                  catch(e:Error)
                  {
                     client.handleCallbackError("Connection.addMessageHandler(\"" + _loc6_.type + "\")",e);
                     throw e;
                  }
               }
               _loc4_++;
            }
         }
      }
      
      private function throwError(param1:String, param2:int) : void
      {
         var _loc3_:playerio.generated.PlayerIOError = new playerio.generated.PlayerIOError(param1,param2);
         if(errorHandler != null)
         {
            errorHandler(_loc3_);
            return;
         }
         client.handleCallbackErrorVerbose("Error occurred while talking to player.io multiplayer servers.",_loc3_);
         throw _loc3_;
      }
   }
}

class MessageHandler
{
   
   public var type:String;
   
   public var handler:Function;
   
   public function MessageHandler(param1:String, param2:Function)
   {
      super();
      this.type = param1;
      this.handler = param2;
   }
}
