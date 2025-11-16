package mx.utils
{
   import flash.utils.ByteArray;
   
   public class Base64Encoder
   {
      
      public static const CHARSET_UTF_8:String = "UTF-8";
      
      public static var newLine:int = 10;
      
      public static const MAX_BUFFER_SIZE:uint = 32767;
      
      private static const ESCAPE_CHAR_CODE:Number = 61;
      
      private static const ALPHABET_CHAR_CODES:Array = [65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,48,49,50,51,52,53,54,55,56,57,43,47];
      
      public var insertNewLines:Boolean = true;
      
      private var _buffers:Array;
      
      private var _count:uint;
      
      private var _line:uint;
      
      private var _work:Array = [0,0,0];
      
      public function Base64Encoder()
      {
         super();
         this.reset();
      }
      
      public function drain() : String
      {
         var _loc3_:Array = null;
         var _loc1_:String = "";
         var _loc2_:uint = 0;
         while(_loc2_ < this._buffers.length)
         {
            _loc3_ = this._buffers[_loc2_] as Array;
            _loc1_ += String.fromCharCode.apply(null,_loc3_);
            _loc2_++;
         }
         this._buffers = [];
         this._buffers.push([]);
         return _loc1_;
      }
      
      public function encode(param1:String, param2:uint = 0, param3:uint = 0) : void
      {
         if(param3 == 0)
         {
            param3 = uint(param1.length);
         }
         var _loc4_:uint = param2;
         var _loc5_:uint = param2 + param3;
         if(_loc5_ > param1.length)
         {
            _loc5_ = uint(param1.length);
         }
         while(_loc4_ < _loc5_)
         {
            this._work[this._count] = param1.charCodeAt(_loc4_);
            ++this._count;
            if(this._count == this._work.length || _loc5_ - _loc4_ == 1)
            {
               this.encodeBlock();
               this._count = 0;
               this._work[0] = 0;
               this._work[1] = 0;
               this._work[2] = 0;
            }
            _loc4_++;
         }
      }
      
      public function encodeUTFBytes(param1:String) : void
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUTFBytes(param1);
         _loc2_.position = 0;
         this.encodeBytes(_loc2_);
      }
      
      public function encodeBytes(param1:ByteArray, param2:uint = 0, param3:uint = 0) : void
      {
         if(param3 == 0)
         {
            param3 = param1.length;
         }
         var _loc4_:uint = param1.position;
         param1.position = param2;
         var _loc5_:uint = param2;
         var _loc6_:uint = param2 + param3;
         if(_loc6_ > param1.length)
         {
            _loc6_ = param1.length;
         }
         while(_loc5_ < _loc6_)
         {
            this._work[this._count] = param1[_loc5_];
            ++this._count;
            if(this._count == this._work.length || _loc6_ - _loc5_ == 1)
            {
               this.encodeBlock();
               this._count = 0;
               this._work[0] = 0;
               this._work[1] = 0;
               this._work[2] = 0;
            }
            _loc5_++;
         }
         param1.position = _loc4_;
      }
      
      public function flush() : String
      {
         if(this._count > 0)
         {
            this.encodeBlock();
         }
         var _loc1_:String = this.drain();
         this.reset();
         return _loc1_;
      }
      
      public function reset() : void
      {
         this._buffers = [];
         this._buffers.push([]);
         this._count = 0;
         this._line = 0;
         this._work[0] = 0;
         this._work[1] = 0;
         this._work[2] = 0;
      }
      
      public function toString() : String
      {
         return this.flush();
      }
      
      private function encodeBlock() : void
      {
         var _loc1_:Array = this._buffers[this._buffers.length - 1] as Array;
         if(_loc1_.length >= MAX_BUFFER_SIZE)
         {
            _loc1_ = [];
            this._buffers.push(_loc1_);
         }
         _loc1_.push(ALPHABET_CHAR_CODES[(this._work[0] & 0xFF) >> 2]);
         _loc1_.push(ALPHABET_CHAR_CODES[(this._work[0] & 3) << 4 | (this._work[1] & 0xF0) >> 4]);
         if(this._count > 1)
         {
            _loc1_.push(ALPHABET_CHAR_CODES[(this._work[1] & 0x0F) << 2 | (this._work[2] & 0xC0) >> 6]);
         }
         else
         {
            _loc1_.push(ESCAPE_CHAR_CODE);
         }
         if(this._count > 2)
         {
            _loc1_.push(ALPHABET_CHAR_CODES[this._work[2] & 0x3F]);
         }
         else
         {
            _loc1_.push(ESCAPE_CHAR_CODE);
         }
         if(this.insertNewLines)
         {
            if((this._line = this._line + 4) == 76)
            {
               _loc1_.push(newLine);
               this._line = 0;
            }
         }
      }
   }
}

