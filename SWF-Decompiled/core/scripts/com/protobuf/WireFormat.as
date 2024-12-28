package com.protobuf
{
   public final class WireFormat
   {
      public static const WIRETYPE_VARINT:int = 0;
      
      public static const WIRETYPE_FIXED64:int = 1;
      
      public static const WIRETYPE_LENGTH_DELIMITED:int = 2;
      
      public static const WIRETYPE_START_GROUP:int = 3;
      
      public static const WIRETYPE_END_GROUP:int = 4;
      
      public static const WIRETYPE_FIXED32:int = 5;
      
      public static const TAG_TYPE_BITS:int = 3;
      
      public static const TAG_TYPE_MASK:int = 7;
      
      public static const MESSAGE_SET_ITEM:int = 1;
      
      public static const MESSAGE_SET_TYPE_ID:int = 2;
      
      public static const MESSAGE_SET_MESSAGE:int = 3;
      
      public static const MESSAGE_SET_ITEM_TAG:int = makeTag(1,3);
      
      public static const MESSAGE_SET_ITEM_END_TAG:int = makeTag(1,4);
      
      public static const MESSAGE_SET_TYPE_ID_TAG:int = makeTag(2,0);
      
      public static const MESSAGE_SET_MESSAGE_TAG:int = makeTag(3,2);
      
      public function WireFormat()
      {
         super();
      }
      
      public static function getTagWireType(param1:int) : int
      {
         return param1 & 7;
      }
      
      public static function getTagFieldNumber(param1:int) : int
      {
         return param1 >>> 3;
      }
      
      public static function makeTag(param1:int, param2:int) : int
      {
         return param1 << 3 | param2;
      }
   }
}

