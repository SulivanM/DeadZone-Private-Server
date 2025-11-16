package com.probertson.utils
{
   import flash.utils.ByteArray;
   
   public class CRC32Generator
   {
      
      private static var _crcTable:Array;
      
      private static var _tableComputed:Boolean = false;
      
      public function CRC32Generator()
      {
         super();
      }
      
      private static function makeCRCTable() : void
      {
         var _loc1_:uint = 0;
         var _loc3_:int = 0;
         _crcTable = new Array(256);
         var _loc2_:int = 0;
         while(_loc2_ < 256)
         {
            _loc1_ = uint(_loc2_);
            _loc3_ = 0;
            while(_loc3_ < 8)
            {
               if((_loc1_ & 1) != 0)
               {
                  _loc1_ = uint(0xEDB88320 ^ _loc1_ >>> 1);
               }
               else
               {
                  _loc1_ >>>= 1;
               }
               _loc3_++;
            }
            _crcTable[_loc2_] = _loc1_;
            _loc2_++;
         }
         _tableComputed = true;
      }
      
      public function generateCRC32(param1:ByteArray) : uint
      {
         if(!_tableComputed)
         {
            makeCRCTable();
         }
         var _loc2_:uint = uint(~0);
         var _loc3_:int = int(param1.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = uint(_crcTable[(_loc2_ ^ param1[_loc4_]) & 0xFF] ^ _loc2_ >>> 8);
            _loc4_++;
         }
         _loc2_ = uint(~_loc2_);
         return _loc2_ & 0xFFFFFFFF;
      }
   }
}

