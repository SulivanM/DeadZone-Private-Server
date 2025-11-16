package thelaststand.app.utils
{
   public class DateTimeUtils
   {
      
      public function DateTimeUtils()
      {
         super();
         throw new Error("DateTimeUtils cannot be directly instantiated.");
      }
      
      public static function secondsToTime(param1:Number) : Object
      {
         var _loc2_:int = param1 / 86400;
         var _loc3_:int = param1 / 3600 - _loc2_ * 24;
         var _loc4_:int = param1 / 60 - _loc2_ * 1440 - _loc3_ * 60;
         var _loc5_:int = param1 % 60;
         return {
            "days":_loc2_,
            "hours":_loc3_,
            "minutes":_loc4_,
            "seconds":_loc5_
         };
      }
      
      public static function dateToString(param1:Date) : String
      {
         var _loc2_:String = null;
         var _loc3_:int = param1.hours;
         var _loc4_:String = param1.hours > 12 ? "PM" : "AM";
         return param1.month + 1 + "/" + param1.date + "/" + param1.fullYear + " " + _loc3_ + ":" + param1.minutes + ":" + param1.seconds + " " + _loc4_;
      }
      
      public static function timeDataToString(param1:Object, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false) : String
      {
         var _loc5_:String = "";
         if(param1.days > 0)
         {
            _loc5_ += param1.days + (param2 ? "d" : " day" + (param1.days != 1 ? "s" : "")) + " ";
         }
         if(param1.hours > 0)
         {
            _loc5_ += param1.hours + (param2 ? "h" : " hr" + (param1.hours != 1 ? "s" : "")) + " ";
         }
         if(param4 == false)
         {
            if(param1.minutes > 0)
            {
               _loc5_ += param1.minutes + (param2 ? "m" : " min" + (param1.minutes != 1 ? "s" : "")) + " ";
            }
            if(param1.seconds > 0 || param3)
            {
               _loc5_ += param1.seconds + (param2 ? "s" : " sec");
            }
         }
         else
         {
            if(param1.hours > 0 && param1.minutes > 0)
            {
               ++param1.hours;
            }
            if(param1.days <= 0 && param1.hours < 1)
            {
               return "< 1" + (param2 ? "h" : " hr");
            }
         }
         return _loc5_.substr(_loc5_.length - 1,1) == " " ? _loc5_.substr(0,_loc5_.length - 1) : _loc5_;
      }
      
      public static function secondsToString(param1:int, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false) : String
      {
         return timeDataToString(secondsToTime(param1),param2,param3,param4);
      }
      
      public static function convertToUTCDate(param1:String, param2:String = "-") : Date
      {
         var _loc3_:Array = param1.split(param2);
         return new Date(Date.UTC(int(_loc3_[0]),int(_loc3_[1]) - 1,int(_loc3_[2])));
      }
      
      private function parseUTCDateTime(param1:String) : Date
      {
         var _loc2_:Array = param1.match(/(\d{4})\-(\d{1,2})\-(\d{1,2}) (\d{2})\:(\d{2})\:(\d{2})/);
         var _loc3_:Date = new Date();
         _loc3_.setUTCFullYear(int(_loc2_[1]),int(_loc2_[2]) - 1,int(_loc2_[3]));
         _loc3_.setUTCHours(int(_loc2_[4]),int(_loc2_[5]),int(_loc2_[6]),0);
         return _loc3_;
      }
      
      private function parseUTCDate(param1:String) : Date
      {
         var _loc2_:Array = param1.match(/(\d{4})\-(\d{1,2})\-(\d{1,2})/);
         var _loc3_:Date = new Date();
         _loc3_.setUTCFullYear(int(_loc2_[1]),int(_loc2_[2]) - 1,int(_loc2_[3]));
         _loc3_.setUTCHours(0,0,0,0);
         return _loc3_;
      }
   }
}

