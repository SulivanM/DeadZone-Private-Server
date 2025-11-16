package mx.messaging.messages
{
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   import flash.utils.getQualifiedClassName;
   import mx.core.mx_internal;
   import mx.utils.RPCObjectUtil;
   import mx.utils.RPCStringUtil;
   import mx.utils.RPCUIDUtil;
   
   use namespace mx_internal;
   
   public class AbstractMessage implements IMessage
   {
      
      public static const DESTINATION_CLIENT_ID_HEADER:String = "DSDstClientId";
      
      public static const ENDPOINT_HEADER:String = "DSEndpoint";
      
      public static const FLEX_CLIENT_ID_HEADER:String = "DSId";
      
      public static const PRIORITY_HEADER:String = "DSPriority";
      
      public static const REMOTE_CREDENTIALS_HEADER:String = "DSRemoteCredentials";
      
      public static const REMOTE_CREDENTIALS_CHARSET_HEADER:String = "DSRemoteCredentialsCharset";
      
      public static const REQUEST_TIMEOUT_HEADER:String = "DSRequestTimeout";
      
      public static const STATUS_CODE_HEADER:String = "DSStatusCode";
      
      private static const HAS_NEXT_FLAG:uint = 128;
      
      private static const BODY_FLAG:uint = 1;
      
      private static const CLIENT_ID_FLAG:uint = 2;
      
      private static const DESTINATION_FLAG:uint = 4;
      
      private static const HEADERS_FLAG:uint = 8;
      
      private static const MESSAGE_ID_FLAG:uint = 16;
      
      private static const TIMESTAMP_FLAG:uint = 32;
      
      private static const TIME_TO_LIVE_FLAG:uint = 64;
      
      private static const CLIENT_ID_BYTES_FLAG:uint = 1;
      
      private static const MESSAGE_ID_BYTES_FLAG:uint = 2;
      
      private var _body:Object = {};
      
      private var _clientId:String;
      
      private var clientIdBytes:ByteArray;
      
      private var _destination:String = "";
      
      private var _headers:Object;
      
      private var _messageId:String;
      
      private var messageIdBytes:ByteArray;
      
      private var _timestamp:Number = 0;
      
      private var _timeToLive:Number = 0;
      
      public function AbstractMessage()
      {
         super();
      }
      
      public function get body() : Object
      {
         return this._body;
      }
      
      public function set body(param1:Object) : void
      {
         this._body = param1;
      }
      
      public function get clientId() : String
      {
         return this._clientId;
      }
      
      public function set clientId(param1:String) : void
      {
         this._clientId = param1;
         this.clientIdBytes = null;
      }
      
      public function get destination() : String
      {
         return this._destination;
      }
      
      public function set destination(param1:String) : void
      {
         this._destination = param1;
      }
      
      public function get headers() : Object
      {
         if(this._headers == null)
         {
            this._headers = {};
         }
         return this._headers;
      }
      
      public function set headers(param1:Object) : void
      {
         this._headers = param1;
      }
      
      public function get messageId() : String
      {
         if(this._messageId == null)
         {
            this._messageId = RPCUIDUtil.createUID();
         }
         return this._messageId;
      }
      
      public function set messageId(param1:String) : void
      {
         this._messageId = param1;
         this.messageIdBytes = null;
      }
      
      public function get timestamp() : Number
      {
         return this._timestamp;
      }
      
      public function set timestamp(param1:Number) : void
      {
         this._timestamp = param1;
      }
      
      public function get timeToLive() : Number
      {
         return this._timeToLive;
      }
      
      public function set timeToLive(param1:Number) : void
      {
         this._timeToLive = param1;
      }
      
      public function readExternal(param1:IDataInput) : void
      {
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc2_:Array = this.readFlags(param1);
         var _loc3_:uint = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = _loc2_[_loc3_] as uint;
            _loc5_ = 0;
            if(_loc3_ == 0)
            {
               if((_loc4_ & BODY_FLAG) != 0)
               {
                  this.readExternalBody(param1);
               }
               else
               {
                  this.body = null;
               }
               if((_loc4_ & CLIENT_ID_FLAG) != 0)
               {
                  this.clientId = param1.readObject();
               }
               if((_loc4_ & DESTINATION_FLAG) != 0)
               {
                  this.destination = param1.readObject() as String;
               }
               if((_loc4_ & HEADERS_FLAG) != 0)
               {
                  this.headers = param1.readObject();
               }
               if((_loc4_ & MESSAGE_ID_FLAG) != 0)
               {
                  this.messageId = param1.readObject() as String;
               }
               if((_loc4_ & TIMESTAMP_FLAG) != 0)
               {
                  this.timestamp = param1.readObject() as Number;
               }
               if((_loc4_ & TIME_TO_LIVE_FLAG) != 0)
               {
                  this.timeToLive = param1.readObject() as Number;
               }
               _loc5_ = 7;
            }
            else if(_loc3_ == 1)
            {
               if((_loc4_ & CLIENT_ID_BYTES_FLAG) != 0)
               {
                  this.clientIdBytes = param1.readObject() as ByteArray;
                  this.clientId = RPCUIDUtil.fromByteArray(this.clientIdBytes);
               }
               if((_loc4_ & MESSAGE_ID_BYTES_FLAG) != 0)
               {
                  this.messageIdBytes = param1.readObject() as ByteArray;
                  this.messageId = RPCUIDUtil.fromByteArray(this.messageIdBytes);
               }
               _loc5_ = 2;
            }
            if(_loc4_ >> _loc5_ != 0)
            {
               _loc6_ = _loc5_;
               while(_loc6_ < 6)
               {
                  if((_loc4_ >> _loc6_ & 1) != 0)
                  {
                     param1.readObject();
                  }
                  _loc6_++;
               }
            }
            _loc3_++;
         }
      }
      
      public function toString() : String
      {
         return RPCObjectUtil.toString(this);
      }
      
      public function writeExternal(param1:IDataOutput) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:String = this.messageId;
         if(this.clientIdBytes == null)
         {
            this.clientIdBytes = RPCUIDUtil.toByteArray(this._clientId);
         }
         if(this.messageIdBytes == null)
         {
            this.messageIdBytes = RPCUIDUtil.toByteArray(this._messageId);
         }
         if(this.body != null)
         {
            _loc2_ |= BODY_FLAG;
         }
         if(this.clientId != null && this.clientIdBytes == null)
         {
            _loc2_ |= CLIENT_ID_FLAG;
         }
         if(this.destination != null)
         {
            _loc2_ |= DESTINATION_FLAG;
         }
         if(this.headers != null)
         {
            _loc2_ |= HEADERS_FLAG;
         }
         if(this.messageId != null && this.messageIdBytes == null)
         {
            _loc2_ |= MESSAGE_ID_FLAG;
         }
         if(this.timestamp != 0)
         {
            _loc2_ |= TIMESTAMP_FLAG;
         }
         if(this.timeToLive != 0)
         {
            _loc2_ |= TIME_TO_LIVE_FLAG;
         }
         if(this.clientIdBytes != null || this.messageIdBytes != null)
         {
            _loc2_ |= HAS_NEXT_FLAG;
         }
         param1.writeByte(_loc2_);
         _loc2_ = 0;
         if(this.clientIdBytes != null)
         {
            _loc2_ |= CLIENT_ID_BYTES_FLAG;
         }
         if(this.messageIdBytes != null)
         {
            _loc2_ |= MESSAGE_ID_BYTES_FLAG;
         }
         if(_loc2_ != 0)
         {
            param1.writeByte(_loc2_);
         }
         if(this.body != null)
         {
            this.writeExternalBody(param1);
         }
         if(this.clientId != null && this.clientIdBytes == null)
         {
            param1.writeObject(this.clientId);
         }
         if(this.destination != null)
         {
            param1.writeObject(this.destination);
         }
         if(this.headers != null)
         {
            param1.writeObject(this.headers);
         }
         if(this.messageId != null && this.messageIdBytes == null)
         {
            param1.writeObject(this.messageId);
         }
         if(this.timestamp != 0)
         {
            param1.writeObject(this.timestamp);
         }
         if(this.timeToLive != 0)
         {
            param1.writeObject(this.timeToLive);
         }
         if(this.clientIdBytes != null)
         {
            param1.writeObject(this.clientIdBytes);
         }
         if(this.messageIdBytes != null)
         {
            param1.writeObject(this.messageIdBytes);
         }
      }
      
      protected function addDebugAttributes(param1:Object) : void
      {
         param1["body"] = this.body;
         param1["clientId"] = this.clientId;
         param1["destination"] = this.destination;
         param1["headers"] = this.headers;
         param1["messageId"] = this.messageId;
         param1["timestamp"] = this.timestamp;
         param1["timeToLive"] = this.timeToLive;
      }
      
      final protected function getDebugString() : String
      {
         var _loc4_:String = null;
         var _loc5_:uint = 0;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc1_:* = "(" + getQualifiedClassName(this) + ")";
         var _loc2_:Object = {};
         this.addDebugAttributes(_loc2_);
         var _loc3_:Array = [];
         for(_loc4_ in _loc2_)
         {
            _loc3_.push(_loc4_);
         }
         _loc3_.sort();
         _loc5_ = 0;
         while(_loc5_ < _loc3_.length)
         {
            _loc6_ = String(_loc3_[_loc5_]);
            _loc7_ = RPCObjectUtil.toString(_loc2_[_loc6_]);
            _loc1_ += RPCStringUtil.substitute("\n  {0}={1}",_loc6_,_loc7_);
            _loc5_++;
         }
         return _loc1_;
      }
      
      protected function readExternalBody(param1:IDataInput) : void
      {
         this.body = param1.readObject();
      }
      
      protected function readFlags(param1:IDataInput) : Array
      {
         var _loc4_:uint = 0;
         var _loc2_:Boolean = true;
         var _loc3_:Array = [];
         while(_loc2_ && param1.bytesAvailable > 0)
         {
            _loc4_ = uint(param1.readUnsignedByte());
            _loc3_.push(_loc4_);
            if((_loc4_ & HAS_NEXT_FLAG) != 0)
            {
               _loc2_ = true;
            }
            else
            {
               _loc2_ = false;
            }
         }
         return _loc3_;
      }
      
      protected function writeExternalBody(param1:IDataOutput) : void
      {
         param1.writeObject(this.body);
      }
   }
}

