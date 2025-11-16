package com.exileetiquette.utils
{
   public class StringUtils
   {
      
      public function StringUtils()
      {
         super();
         throw new Error("StringUtils cannot be directly instantiated.");
      }
      
      public static function validateEmail(param1:String) : Boolean
      {
         var _loc2_:RegExp = /^([0-9a-zA-Z]+[-._+&])*[0-9a-zA-Z-_]+@([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,6}/;
         return _loc2_.test(param1);
      }
      
      public static function strRepeat(param1:String, param2:int) : String
      {
         var _loc3_:String = "";
         var _loc4_:int = 0;
         while(_loc4_ < param2)
         {
            _loc3_ += param1;
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function strRepeatRandom(param1:Array, param2:int) : String
      {
         var _loc3_:String = "";
         var _loc4_:int = 0;
         var _loc5_:int = int(param1.length);
         while(_loc4_ < param2)
         {
            _loc3_ += param1[int(Math.random() * _loc5_)];
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function trimWhiteSpace(param1:String, param2:String = "") : String
      {
         return param1.replace(/[ \\s]+$|^[ \\s]+/gi,param2);
      }
      
      public static function stripHTMLTags(param1:String) : String
      {
         return param1.replace(/<.*?>/ig,"");
      }
   }
}

