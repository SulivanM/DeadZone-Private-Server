package mx.messaging.messages
{
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   import mx.utils.RPCUIDUtil;
   
   public class AsyncMessage extends AbstractMessage implements ISmallMessage
   {
      
      public static const SUBTOPIC_HEADER:String = "DSSubtopic";
      
      private static const CORRELATION_ID_FLAG:uint = 1;
      
      private static const CORRELATION_ID_BYTES_FLAG:uint = 2;
      
      private var _correlationId:String;
      
      private var correlationIdBytes:ByteArray;
      
      public function AsyncMessage(param1:Object = null, param2:Object = null)
      {
         super();
         this.correlationId = "";
         if(param1 != null)
         {
            this.body = param1;
         }
         if(param2 != null)
         {
            this.headers = param2;
         }
      }
      
      public function get correlationId() : String
      {
         return this._correlationId;
      }
      
      public function set correlationId(param1:String) : void
      {
         this._correlationId = param1;
         this.correlationIdBytes = null;
      }
      
      public function getSmallMessage() : IMessage
      {
         var _loc1_:Object = this;
         if(_loc1_.constructor == AsyncMessage)
         {
            return new AsyncMessageExt(this);
         }
         return null;
      }
      
      override public function readExternal(param1:IDataInput) : void
      {
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         super.readExternal(param1);
         var _loc2_:Array = readFlags(param1);
         var _loc3_:uint = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = _loc2_[_loc3_] as uint;
            _loc5_ = 0;
            if(_loc3_ == 0)
            {
               if((_loc4_ & CORRELATION_ID_FLAG) != 0)
               {
                  this.correlationId = param1.readObject() as String;
               }
               if((_loc4_ & CORRELATION_ID_BYTES_FLAG) != 0)
               {
                  this.correlationIdBytes = param1.readObject() as ByteArray;
                  this.correlationId = RPCUIDUtil.fromByteArray(this.correlationIdBytes);
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
      
      override public function writeExternal(param1:IDataOutput) : void
      {
         super.writeExternal(param1);
         if(this.correlationIdBytes == null)
         {
            this.correlationIdBytes = RPCUIDUtil.toByteArray(this._correlationId);
         }
         var _loc2_:uint = 0;
         if(this.correlationId != null && this.correlationIdBytes == null)
         {
            _loc2_ |= CORRELATION_ID_FLAG;
         }
         if(this.correlationIdBytes != null)
         {
            _loc2_ |= CORRELATION_ID_BYTES_FLAG;
         }
         param1.writeByte(_loc2_);
         if(this.correlationId != null && this.correlationIdBytes == null)
         {
            param1.writeObject(this.correlationId);
         }
         if(this.correlationIdBytes != null)
         {
            param1.writeObject(this.correlationIdBytes);
         }
      }
      
      override protected function addDebugAttributes(param1:Object) : void
      {
         super.addDebugAttributes(param1);
         param1["correlationId"] = this.correlationId;
      }
   }
}

