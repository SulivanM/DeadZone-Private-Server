package com.protobuf
{
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   
   public class CodedInputStream
   {
      private static const DEFAULT_RECURSION_LIMIT:int = 64;
      
      private static const DEFAULT_SIZE_LIMIT:int = 67108864;
      
      private var bufferSize:int;
      
      private var bufferSizeAfterLimit:int = 0;
      
      private var bufferPos:int = 0;
      
      private var input:IDataInput;
      
      private var lastTag:int = 0;
      
      private var sizeLimit:int = 67108864;
      
      public function CodedInputStream(param1:IDataInput)
      {
         super();
         this.bufferSize = 0;
         this.input = param1;
      }
      
      public static function newInstance(param1:IDataInput) : CodedInputStream
      {
         return new CodedInputStream(param1);
      }
      
      public static function decodeZigZag32(param1:int) : int
      {
         return param1 >>> 1 ^ -(param1 & 1);
      }
      
      public function readTag() : int
      {
         if(input.bytesAvailable != 0)
         {
            lastTag = readRawVarint32();
         }
         else
         {
            lastTag = 0;
         }
         return lastTag;
      }
      
      public function checkLastTagWas(param1:int) : void
      {
         if(lastTag != param1)
         {
            throw InvalidProtocolBufferException.invalidEndTag();
         }
      }
      
      public function skipField(param1:int) : Boolean
      {
         switch(WireFormat.getTagWireType(param1))
         {
            case 0:
               while(input.readUnsignedByte() >= 128)
               {
               }
               return true;
            case 2:
               skipRawBytes(readRawVarint32());
               return true;
            case 3:
               skipMessage();
               checkLastTagWas(WireFormat.makeTag(WireFormat.getTagFieldNumber(param1),4));
               return true;
            case 4:
               return false;
            case 5:
               readRawLittleEndian32();
               return true;
            default:
               throw InvalidProtocolBufferException.invalidWireType();
         }
      }
      
      public function skipMessage() : void
      {
         var _loc1_:int = 0;
         do
         {
            _loc1_ = readTag();
         }
         while(!(_loc1_ == 0 || !skipField(_loc1_)));
         
      }
      
      public function readDouble() : Number
      {
         var _loc2_:int = readRawByte();
         var _loc4_:int = readRawByte();
         var _loc3_:int = readRawByte();
         var _loc6_:int = readRawByte();
         var _loc5_:int = readRawByte();
         var _loc8_:int = readRawByte();
         var _loc7_:int = readRawByte();
         var _loc9_:int = readRawByte();
         var _loc1_:ByteArray = new ByteArray();
         _loc1_.writeByte(_loc9_);
         _loc1_.writeByte(_loc7_);
         _loc1_.writeByte(_loc8_);
         _loc1_.writeByte(_loc5_);
         _loc1_.writeByte(_loc6_);
         _loc1_.writeByte(_loc3_);
         _loc1_.writeByte(_loc4_);
         _loc1_.writeByte(_loc2_);
         _loc1_.position = 0;
         return _loc1_.readDouble();
      }
      
      public function readFloat() : Number
      {
         var _loc2_:int = readRawByte();
         var _loc4_:int = readRawByte();
         var _loc3_:int = readRawByte();
         var _loc5_:int = readRawByte();
         var _loc1_:ByteArray = new ByteArray();
         _loc1_.writeByte(_loc5_);
         _loc1_.writeByte(_loc3_);
         _loc1_.writeByte(_loc4_);
         _loc1_.writeByte(_loc2_);
         _loc1_.position = 0;
         return _loc1_.readFloat();
      }
      
      public function readInt32() : int
      {
         return readRawVarint32();
      }
      
      public function readFixed32() : int
      {
         return readRawLittleEndian32();
      }
      
      public function readBool() : Boolean
      {
         return readRawVarint32() != 0;
      }
      
      public function readString() : String
      {
         var _loc1_:int = readRawVarint32();
         return new String(readRawBytes(_loc1_));
      }
      
      public function readBytes() : ByteArray
      {
         var _loc1_:int = readRawVarint32();
         return readRawBytes(_loc1_);
      }
      
      public function readUInt32() : int
      {
         return readRawVarint32();
      }
      
      public function readEnum() : int
      {
         return readRawVarint32();
      }
      
      public function readSFixed32() : int
      {
         return readRawLittleEndian32();
      }
      
      public function readSInt32() : int
      {
         return decodeZigZag32(readRawVarint32());
      }
      
      public function readPrimitiveField(param1:int) : Object
      {
         switch(param1 - 1)
         {
            case 0:
               return readDouble();
            case 1:
               return readFloat();
            case 2:
               return readInt64();
            case 4:
               return readInt32();
            case 6:
               return readFixed32();
            case 7:
               return readBool();
            case 8:
               return readString();
            case 11:
               return readBytes();
            case 12:
               return readUInt32();
            case 13:
               return readEnum();
            case 14:
               return readSFixed32();
            case 16:
               return readSInt32();
            default:
               trace("Unknown primative field type: " + param1);
               return null;
         }
      }
      
      public function readInt64() : Number
      {
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         var _loc7_:int = 0;
         var _loc6_:Number = Number(input.readUnsignedByte());
         var _loc9_:int = 0;
         var _loc8_:Array = [];
         while(_loc6_ >= 128)
         {
            _loc8_[_loc9_++] = _loc6_ & 0x7F;
            _loc6_ = Number(input.readUnsignedByte());
         }
         _loc8_[_loc9_++] = _loc6_;
         var _loc5_:Boolean = false;
         if(_loc8_.length == 10)
         {
            _loc5_ = true;
            _loc8_.pop();
            _loc8_[0]--;
            _loc2_ = 0;
            while(_loc8_[_loc2_] < 0)
            {
               _loc8_[_loc2_] = 127;
               _loc8_[_loc2_ + 1]--;
            }
            _loc4_ = 0;
            while(_loc4_ < _loc8_.length)
            {
               _loc8_[_loc4_] = 0x7F ^ _loc8_[_loc4_];
               _loc4_++;
            }
         }
         var _loc1_:Number = 0;
         var _loc3_:Number = 1;
         _loc7_ = 0;
         while(_loc7_ < _loc8_.length)
         {
            _loc1_ += _loc8_[_loc7_] * _loc3_;
            _loc3_ *= 128;
            _loc7_++;
         }
         return _loc5_ ? -_loc1_ : _loc1_;
      }
      
      public function readRawVarint32() : int
      {
         var _loc3_:int = 0;
         var _loc2_:int = readRawByte();
         if(_loc2_ >= 0)
         {
            return _loc2_;
         }
         var _loc1_:* = _loc2_ & 0x7F;
         _loc2_ = readRawByte();
         if(_loc2_ >= 0)
         {
            _loc1_ |= _loc2_ << 7;
         }
         else
         {
            _loc1_ |= (_loc2_ & 0x7F) << 7;
            _loc2_ = readRawByte();
            if(_loc2_ >= 0)
            {
               _loc1_ |= _loc2_ << 14;
            }
            else
            {
               _loc1_ |= (_loc2_ & 0x7F) << 14;
               _loc2_ = readRawByte();
               if(_loc2_ >= 0)
               {
                  _loc1_ |= _loc2_ << 21;
               }
               else
               {
                  _loc1_ |= (_loc2_ & 0x7F) << 21;
                  _loc1_ |= (_loc2_ = readRawByte()) << 28;
                  if(_loc2_ < 0)
                  {
                     _loc3_ = 0;
                     while(_loc3_ < 5)
                     {
                        if(readRawByte() >= 0)
                        {
                           return _loc1_;
                        }
                        _loc3_++;
                     }
                     throw InvalidProtocolBufferException.malformedVarint();
                  }
               }
            }
         }
         return _loc1_;
      }
      
      public function readRawLittleEndian32() : int
      {
         var _loc1_:int = readRawByte();
         var _loc3_:int = readRawByte();
         var _loc2_:int = readRawByte();
         var _loc4_:int = readRawByte();
         return _loc1_ & 0xFF | (_loc3_ & 0xFF) << 8 | (_loc2_ & 0xFF) << 16 | (_loc4_ & 0xFF) << 24;
      }
      
      public function readRawByte() : int
      {
         return input.readByte();
      }
      
      public function readRawBytes(param1:int) : ByteArray
      {
         if(param1 < 0)
         {
            throw InvalidProtocolBufferException.negativeSize();
         }
         var _loc2_:ByteArray = new ByteArray();
         if(param1 != 0)
         {
            input.readBytes(_loc2_,0,param1);
         }
         return _loc2_;
      }
      
      public function skipRawBytes(param1:int) : void
      {
         readRawBytes(param1);
      }
   }
}

