package com.exileetiquette.utils
{
   public class NumberFormatter
   {
      
      public function NumberFormatter()
      {
         super();
         throw new Error("The NumberFormatter class cannot be directly instantiated.");
      }
      
      public static function addLeadingZero(param1:Number, param2:int = 2) : String
      {
         var _loc3_:String = Number(param1 < 0 ? -param1 : param1).toString();
         while(_loc3_.length < param2)
         {
            _loc3_ = "0" + _loc3_;
         }
         return (param1 < 0 ? "-" : "") + _loc3_;
      }
      
      public static function format(param1:Number, param2:int = 2, param3:String = ",", param4:Boolean = true) : String
      {
         var _loc8_:Number = NaN;
         var _loc5_:String = String(param2 > 0 ? param1.toFixed(param2) : int(param1));
         var _loc6_:Array = _loc5_.split(".");
         var _loc7_:Array = [];
         var _loc9_:Number = Number(_loc6_[0].length);
         while(_loc9_ > 0)
         {
            _loc8_ = Math.max(_loc9_ - 3,0);
            _loc7_.unshift(_loc6_[0].slice(_loc8_,_loc9_));
            _loc9_ = _loc8_;
         }
         _loc6_[0] = _loc7_.join(param3);
         if(!param4 && Number(_loc6_[1]) == 0)
         {
            _loc6_.length = 1;
         }
         return _loc6_.join(".");
      }
      
      public static function HTMLColorToDecimal(param1:String) : uint
      {
         return parseInt(param1.substr(1,6),16);
      }
      
      public static function currency(param1:Number, param2:int = 2, param3:String = "$", param4:String = ",") : String
      {
         return param3 + format(param1,param2,param4);
      }
   }
}

