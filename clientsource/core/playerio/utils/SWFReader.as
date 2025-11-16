package playerio.utils
{
   import flash.geom.*;
   import flash.utils.ByteArray;
   
   public class SWFReader
   {
      
      public var compressed:Boolean;
      
      public var version:uint;
      
      public var fileSize:uint;
      
      private var _dimensions:Rectangle = new Rectangle();
      
      private var _tagCallbackBytesIncludesHeader:Boolean = false;
      
      public var frameRate:uint;
      
      public var totalFrames:uint;
      
      public var asVersion:uint;
      
      public var usesNetwork:Boolean;
      
      public var backgroundColor:uint;
      
      public var protectedFromImport:Boolean;
      
      public var debuggerEnabled:Boolean;
      
      public var metadata:XML;
      
      public var recursionLimit:uint;
      
      public var scriptTimeoutLimit:uint;
      
      public var hardwareAcceleration:uint;
      
      public var tagCallback:Function;
      
      public var parsed:Boolean;
      
      public var errorText:String = "";
      
      private var bytes:ByteArray;
      
      private var currentByte:int;
      
      private var bitPosition:int;
      
      private var currentTag:uint;
      
      private var bgColorFound:Boolean;
      
      private const GET_DATA_SIZE:int = 5;
      
      private const TWIPS_TO_PIXELS:Number = 0.05;
      
      private const TAG_HEADER_ID_BITS:int = 6;
      
      private const TAG_HEADER_MAX_SHORT:int = 63;
      
      private const SWF_C:uint = 67;
      
      private const SWF_F:uint = 70;
      
      private const SWF_W:uint = 87;
      
      private const SWF_S:uint = 83;
      
      private const TAG_ID_EOF:uint = 0;
      
      private const TAG_ID_BG_COLOR:uint = 9;
      
      private const TAG_ID_PROTECTED:uint = 24;
      
      private const TAG_ID_DEBUGGER1:uint = 58;
      
      private const TAG_ID_DEBUGGER2:uint = 64;
      
      private const TAG_ID_SCRIPT_LIMITS:uint = 65;
      
      private const TAG_ID_FILE_ATTS:uint = 69;
      
      private const TAG_ID_META:uint = 77;
      
      private const TAG_ID_SHAPE_1:uint = 2;
      
      private const TAG_ID_SHAPE_2:uint = 22;
      
      private const TAG_ID_SHAPE_3:uint = 32;
      
      private const TAG_ID_SHAPE_4:uint = 83;
      
      public function SWFReader(param1:ByteArray = null)
      {
         super();
         parse(param1);
      }
      
      public function get dimensions() : Rectangle
      {
         return _dimensions;
      }
      
      public function get width() : uint
      {
         return uint(_dimensions.width);
      }
      
      public function get height() : uint
      {
         return uint(_dimensions.height);
      }
      
      public function get tagCallbackBytesIncludesHeader() : Boolean
      {
         return _tagCallbackBytesIncludesHeader;
      }
      
      public function set tagCallbackBytesIncludesHeader(param1:Boolean) : void
      {
         _tagCallbackBytesIncludesHeader = param1;
      }
      
      public function toString() : String
      {
         var _loc2_:String = null;
         var _loc1_:String = null;
         if(parsed)
         {
            _loc2_ = compressed ? "compressed" : "uncompressed";
            _loc1_ = totalFrames > 1 ? "frames" : "frame";
            return "[SWF" + version + " AS" + asVersion + ".0: " + totalFrames + " " + _loc1_ + " @ " + frameRate + " fps " + _dimensions.width + "x" + _dimensions.height + " " + _loc2_ + "]";
         }
         return Object.prototype.toString.call(this);
      }
      
      public function parse(param1:ByteArray) : void
      {
         var _loc4_:* = 0;
         var _loc2_:* = 0;
         var _loc3_:* = 0;
         var _loc5_:ByteArray = null;
         parseDefaults();
         if(param1 == null)
         {
            parseError("Error: Cannot parse a null value.");
            return;
         }
         parsed = true;
         try
         {
            bytes = param1;
            bytes.endian = "littleEndian";
            bytes.position = 0;
            _loc4_ = bytes.readUnsignedByte();
            _loc2_ = bytes.readUnsignedByte();
            _loc3_ = bytes.readUnsignedByte();
            if(_loc4_ != 70 && _loc4_ != 67 || _loc2_ != 87 || _loc3_ != 83)
            {
               parseError("Error: Invalid SWF header.");
               return;
            }
            compressed = _loc4_ == 67;
            version = bytes.readUnsignedByte();
            fileSize = bytes.readUnsignedInt();
            if(compressed)
            {
               _loc5_ = new ByteArray();
               bytes.readBytes(_loc5_);
               bytes = _loc5_;
               bytes.endian = "littleEndian";
               bytes.position = 0;
               _loc5_ = null;
               bytes.uncompress();
            }
            _dimensions = readRect();
            bytes.position++;
            frameRate = bytes.readUnsignedByte();
            totalFrames = bytes.readUnsignedShort();
         }
         catch(error:Error)
         {
            parseError(error.message);
            return;
         }
         try
         {
            while(readTag())
            {
            }
         }
         catch(error:Error)
         {
            parseError(error.message);
            return;
         }
         bytes = null;
      }
      
      private function parseDefaults() : void
      {
         compressed = false;
         version = 1;
         fileSize = 0;
         _dimensions = new Rectangle();
         frameRate = 12;
         totalFrames = 1;
         metadata = null;
         asVersion = 2;
         usesNetwork = false;
         backgroundColor = 16777215;
         protectedFromImport = false;
         debuggerEnabled = true;
         scriptTimeoutLimit = 256;
         recursionLimit = 15;
         hardwareAcceleration = 0;
         errorText = "";
         bgColorFound = false;
      }
      
      private function parseError(param1:String = "Unkown error.") : void
      {
         compressed = false;
         version = 0;
         fileSize = 0;
         _dimensions = new Rectangle();
         frameRate = 0;
         totalFrames = 0;
         metadata = null;
         asVersion = 0;
         usesNetwork = false;
         backgroundColor = 0;
         protectedFromImport = false;
         debuggerEnabled = false;
         scriptTimeoutLimit = 0;
         recursionLimit = 0;
         hardwareAcceleration = 0;
         parsed = false;
         bytes = null;
         errorText = param1;
      }
      
      private function paddedHex(param1:uint, param2:int = 6) : String
      {
         var _loc3_:String = param1.toString(16);
         while(_loc3_.length < param2)
         {
            _loc3_ = "0" + _loc3_;
         }
         return "0x" + _loc3_;
      }
      
      private function readString() : String
      {
         var _loc1_:uint = bytes.position;
         try
         {
            while(bytes[_loc1_] != 0)
            {
               _loc1_++;
            }
         }
         catch(error:Error)
         {
            return "";
         }
         return bytes.readUTFBytes(_loc1_ - bytes.position);
      }
      
      private function readRect() : Rectangle
      {
         nextBitByte();
         var _loc2_:Rectangle = new Rectangle();
         var _loc1_:uint = readBits(5);
         _loc2_.left = readBits(_loc1_,true) * 0.05;
         _loc2_.right = readBits(_loc1_,true) * 0.05;
         _loc2_.top = readBits(_loc1_,true) * 0.05;
         _loc2_.bottom = readBits(_loc1_,true) * 0.05;
         return _loc2_;
      }
      
      private function readMatrix() : Matrix
      {
         var _loc1_:* = 0;
         nextBitByte();
         var _loc2_:Matrix = new Matrix();
         if(readBits(1))
         {
            _loc1_ = readBits(5);
            _loc2_.a = readBits(_loc1_,true);
            _loc2_.d = readBits(_loc1_,true);
         }
         if(readBits(1))
         {
            _loc1_ = readBits(5);
            _loc2_.b = readBits(_loc1_,true);
            _loc2_.c = readBits(_loc1_,true);
         }
         _loc1_ = readBits(5);
         _loc2_.tx = readBits(_loc1_,true) * 0.05;
         _loc2_.ty = readBits(_loc1_,true) * 0.05;
         return _loc2_;
      }
      
      private function readBits(param1:uint, param2:Boolean = false) : Number
      {
         var _loc7_:* = 0;
         var _loc5_:* = 0;
         var _loc3_:* = 0;
         var _loc6_:Number = 0;
         var _loc4_:uint = uint(8 - bitPosition);
         if(param1 <= _loc4_)
         {
            _loc7_ = uint((1 << param1) - 1);
            _loc6_ = currentByte >> _loc4_ - param1 & _loc7_;
            if(param1 == _loc4_)
            {
               nextBitByte();
            }
            else
            {
               bitPosition += param1;
            }
         }
         else
         {
            _loc7_ = uint((1 << _loc4_) - 1);
            _loc5_ = uint(currentByte & _loc7_);
            _loc3_ = uint(param1 - _loc4_);
            nextBitByte();
            _loc6_ = _loc5_ << _loc3_ | readBits(_loc3_);
         }
         if(param2 && _loc6_ >> param1 - 1 == 1)
         {
            _loc4_ = uint(32 - param1);
            _loc7_ = uint((1 << _loc4_) - 1);
            return _loc7_ << param1 | _loc6_;
         }
         return uint(_loc6_);
      }
      
      private function nextBitByte() : void
      {
         currentByte = bytes.readByte();
         bitPosition = 0;
      }
      
      private function readTag() : Boolean
      {
         var _loc5_:uint = bytes.position;
         var _loc3_:int = int(bytes.readUnsignedShort());
         currentTag = _loc3_ >> 6;
         var _loc2_:uint = uint(_loc3_ & 0x3F);
         if(_loc2_ == 63)
         {
            _loc2_ = bytes.readUnsignedInt();
         }
         var _loc4_:uint = bytes.position + _loc2_;
         var _loc1_:Boolean = readTagData(_loc2_,_loc5_,_loc4_);
         if(!_loc1_)
         {
            return false;
         }
         bytes.position = _loc4_;
         return true;
      }
      
      private function readTagData(param1:uint, param2:uint, param3:uint) : Boolean
      {
         var _loc4_:ByteArray = null;
         if(tagCallback != null)
         {
            _loc4_ = new ByteArray();
            if(_tagCallbackBytesIncludesHeader)
            {
               _loc4_.writeBytes(bytes,param2,param3 - param2);
            }
            else if(param1)
            {
               _loc4_.writeBytes(bytes,bytes.position,param1);
            }
            _loc4_.position = 0;
            tagCallback(currentTag,_loc4_);
         }
         switch(currentTag)
         {
            case 69:
               nextBitByte();
               readBits(1);
               hardwareAcceleration = readBits(2);
               readBits(1);
               asVersion = readBits(1) && version >= 9 ? 3 : 2;
               readBits(2);
               usesNetwork = readBits(1) == 1;
               break;
            case 77:
               try
               {
                  metadata = new XML(readString());
                  break;
               }
               catch(error:Error)
               {
                  break;
               }
               break;
            case 9:
               if(!bgColorFound)
               {
                  bgColorFound = true;
                  backgroundColor = readRGB();
               }
               break;
            case 24:
               protectedFromImport = bytes.readUnsignedByte() != 0;
               break;
            case 58:
               if(version == 5)
               {
                  debuggerEnabled = true;
               }
               break;
            case 64:
               if(version > 5)
               {
                  debuggerEnabled = true;
               }
               break;
            case 65:
               recursionLimit = bytes.readUnsignedShort();
               scriptTimeoutLimit = bytes.readUnsignedShort();
               break;
            case 0:
               return false;
         }
         return true;
      }
      
      private function readRGB() : uint
      {
         return bytes.readUnsignedByte() << 16 | bytes.readUnsignedByte() << 8 | bytes.readUnsignedByte();
      }
      
      private function readARGB() : uint
      {
         return bytes.readUnsignedByte() << 24 | bytes.readUnsignedByte() << 16 | bytes.readUnsignedByte() << 8 | bytes.readUnsignedByte();
      }
      
      private function readRGBA() : uint
      {
         var _loc3_:uint = bytes.readUnsignedByte();
         var _loc2_:uint = bytes.readUnsignedByte();
         var _loc4_:uint = bytes.readUnsignedByte();
         var _loc1_:uint = bytes.readUnsignedByte();
         return _loc1_ << 24 | _loc3_ << 16 | _loc2_ << 8 | _loc4_;
      }
   }
}

