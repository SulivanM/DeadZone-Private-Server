package thelaststand.app.utils
{
   import flash.utils.ByteArray;
   
   public class BinaryUtils
   {
      
      public function BinaryUtils()
      {
         super();
         throw new Error("BinaryUtils cannot be directly instantiated.");
      }
      
      public static function booleanArrayFromByteArray(param1:ByteArray) : Vector.<Boolean>
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc2_:Vector.<Boolean> = new Vector.<Boolean>(param1.length * 8,false);
         var _loc3_:int = 0;
         var _loc4_:int = int(param1.length);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = param1.readByte();
            _loc6_ = 0;
            while(_loc6_ < 8)
            {
               _loc2_[_loc3_ * 8 + _loc6_] = (_loc5_ >> _loc6_ & 1) == 1;
               _loc6_++;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function toArray(param1:String) : ByteArray
      {
         param1 = param1.replace(/[^a-f0-9]/ig,"");
         var _loc2_:ByteArray = new ByteArray();
         if(param1.length & 1 == 1)
         {
            param1 = "0" + param1;
         }
         var _loc3_:uint = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_[_loc3_ / 2] = parseInt(param1.substr(_loc3_,2),16);
            _loc3_ += 2;
         }
         return _loc2_;
      }
      
      public static function fromArray(param1:ByteArray, param2:Boolean = false) : String
      {
         var _loc3_:* = "";
         var _loc4_:uint = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_ += ("0" + param1[_loc4_].toString(16)).substr(-2,2);
            if(param2)
            {
               if(_loc4_ < param1.length - 1)
               {
                  _loc3_ += ":";
               }
            }
            _loc4_++;
         }
         return _loc3_;
      }
   }
}

