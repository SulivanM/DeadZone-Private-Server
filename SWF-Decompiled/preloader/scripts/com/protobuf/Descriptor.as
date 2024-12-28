package com.protobuf
{
   public class Descriptor
   {
      public static const DOUBLE:int = 1;
      
      public static const FLOAT:int = 2;
      
      public static const LONG:int = 3;
      
      public static const UINT64:int = 4;
      
      public static const INT32:int = 5;
      
      public static const FIXED64:int = 6;
      
      public static const FIXED32:int = 7;
      
      public static const BOOL:int = 8;
      
      public static const STRING:int = 9;
      
      public static const GROUP:int = 10;
      
      public static const MESSAGE:int = 11;
      
      public static const BYTEARRAY:int = 12;
      
      public static const UINT:int = 13;
      
      public static const ENUM:int = 14;
      
      public static const SFIXED32:int = 15;
      
      public static const SFIXED64:int = 16;
      
      public static const SINT32:int = 17;
      
      public static const SINT64:int = 18;
      
      public static const MAX_TYPE:int = 18;
      
      public static const LABEL_OPTIONAL:int = 1;
      
      public static const LABEL_REQUIRED:int = 2;
      
      public static const LABEL_REPEATED:int = 3;
      
      public static const MAX_LABEL:int = 3;
      
      public var fieldName:String;
      
      public var label:int;
      
      public var fieldNumber:int;
      
      public var type:int;
      
      public var messageClass:String;
      
      public function Descriptor(param1:String, param2:String, param3:int, param4:int, param5:int)
      {
         super();
         this.fieldName = param1;
         this.messageClass = param2;
         this.type = param3;
         this.label = param4;
         this.fieldNumber = param5;
      }
      
      public function isOptional() : Boolean
      {
         return label == 1;
      }
      
      public function isRequired() : Boolean
      {
         return label == 2;
      }
      
      public function isRepeated() : Boolean
      {
         return label == 3;
      }
      
      public function isMessage() : Boolean
      {
         return type == 11;
      }
   }
}

