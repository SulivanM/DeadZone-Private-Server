package playerio.utils
{
   import flash.system.Capabilities;
   
   public class Utilities
   {
      public static var clientAPI:String = "as3";
      
      public function Utilities()
      {
         super();
      }
      
      public static function getSystemInfo() : Object
      {
         var _loc2_:int = 0;
         var _loc3_:Array = ["cpuArchitecture","isDebugger","language","manufacturer","os","pixelAspectRatio","playerType","screenDPI","screenResolutionX","screenResolutionY","touchscreenType","version"];
         var _loc1_:Object = {};
         _loc2_ = 0;
         while(_loc2_ < _loc3_.length)
         {
            if(Capabilities[_loc3_[_loc2_]])
            {
               _loc1_[_loc3_[_loc2_]] = Capabilities[_loc3_[_loc2_]].toString();
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public static function getSystemInfoString() : String
      {
         var _loc3_:Object = getSystemInfo();
         var _loc1_:Array = [];
         for(var _loc2_ in _loc3_)
         {
            _loc1_.push(_loc2_ + ":" + _loc3_[_loc2_]);
         }
         return _loc1_.join("@|@");
      }
      
      public static function countKeys(param1:Object) : int
      {
         var _loc2_:int = 0;
         for(var _loc3_ in param1)
         {
            _loc2_++;
         }
         return _loc2_;
      }
      
      public static function find(param1:Array, param2:Function) : Object
      {
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            if(param2(param1[_loc3_]))
            {
               return param1[_loc3_];
            }
            _loc3_++;
         }
         return null;
      }
      
      public static function converter(param1:Array, param2:Function) : Array
      {
         var _loc4_:int = 0;
         var _loc3_:Array = [];
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_.push(param2(param1[_loc4_]));
            _loc4_++;
         }
         return _loc3_;
      }
   }
}

