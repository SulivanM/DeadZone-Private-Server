package com.adobe.images
{
   import flash.display.BitmapData;
   import flash.geom.*;
   import flash.utils.ByteArray;
   
   public class PNGEncoder
   {
      
      private static var crcTable:Array;
      
      private static var crcTableComputed:Boolean = false;
      
      public function PNGEncoder()
      {
         super();
      }
      
      public static function encode(param1:BitmapData) : ByteArray
      {
         var _loc6_:uint = 0;
         var _loc7_:int = 0;
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUnsignedInt(2303741511);
         _loc2_.writeUnsignedInt(218765834);
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeInt(param1.width);
         _loc3_.writeInt(param1.height);
         _loc3_.writeUnsignedInt(134610944);
         _loc3_.writeByte(0);
         writeChunk(_loc2_,1229472850,_loc3_);
         var _loc4_:ByteArray = new ByteArray();
         var _loc5_:int = 0;
         while(_loc5_ < param1.height)
         {
            _loc4_.writeByte(0);
            if(!param1.transparent)
            {
               _loc7_ = 0;
               while(_loc7_ < param1.width)
               {
                  _loc6_ = param1.getPixel(_loc7_,_loc5_);
                  _loc4_.writeUnsignedInt(uint((_loc6_ & 0xFFFFFF) << 8 | 0xFF));
                  _loc7_++;
               }
            }
            else
            {
               _loc7_ = 0;
               while(_loc7_ < param1.width)
               {
                  _loc6_ = param1.getPixel32(_loc7_,_loc5_);
                  _loc4_.writeUnsignedInt(uint((_loc6_ & 0xFFFFFF) << 8 | _loc6_ >>> 24));
                  _loc7_++;
               }
            }
            _loc5_++;
         }
         _loc4_.compress();
         writeChunk(_loc2_,1229209940,_loc4_);
         writeChunk(_loc2_,1229278788,null);
         return _loc2_;
      }
      
      private static function writeChunk(param1:ByteArray, param2:uint, param3:ByteArray) : void
      {
         var _loc8_:uint = 0;
         var _loc9_:uint = 0;
         var _loc10_:uint = 0;
         if(!crcTableComputed)
         {
            crcTableComputed = true;
            crcTable = [];
            _loc9_ = 0;
            while(_loc9_ < 256)
            {
               _loc8_ = _loc9_;
               _loc10_ = 0;
               while(_loc10_ < 8)
               {
                  if(_loc8_ & 1)
                  {
                     _loc8_ = uint(uint(3988292384) ^ uint(_loc8_ >>> 1));
                  }
                  else
                  {
                     _loc8_ = uint(_loc8_ >>> 1);
                  }
                  _loc10_++;
               }
               crcTable[_loc9_] = _loc8_;
               _loc9_++;
            }
         }
         var _loc4_:uint = 0;
         if(param3 != null)
         {
            _loc4_ = param3.length;
         }
         param1.writeUnsignedInt(_loc4_);
         var _loc5_:uint = param1.position;
         param1.writeUnsignedInt(param2);
         if(param3 != null)
         {
            param1.writeBytes(param3);
         }
         var _loc6_:uint = param1.position;
         param1.position = _loc5_;
         _loc8_ = 4294967295;
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_ - _loc5_)
         {
            _loc8_ = uint(crcTable[(_loc8_ ^ param1.readUnsignedByte()) & uint(255)] ^ uint(_loc8_ >>> 8));
            _loc7_++;
         }
         _loc8_ = uint(_loc8_ ^ uint(4294967295));
         param1.position = _loc6_;
         param1.writeUnsignedInt(_loc8_);
      }
   }
}

