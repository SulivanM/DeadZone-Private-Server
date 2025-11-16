package thelaststand.common.utils
{
   import flash.display.BitmapData;
   import flash.geom.Matrix;
   
   public class BitmapUtils
   {
      
      public function BitmapUtils()
      {
         super();
         throw new Error("BitmapUtils cannot be directly instantiated.");
      }
      
      public static function makeIsometric(param1:BitmapData, param2:Boolean = false) : BitmapData
      {
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc3_:Number = 45 * Math.PI / 180;
         var _loc4_:int = param1.width * Math.sin(_loc3_) + param1.height * Math.cos(_loc3_);
         var _loc5_:int = (param1.width * Math.cos(_loc3_) + param1.height * Math.sin(_loc3_)) * 0.5;
         var _loc6_:Number = 1;
         var _loc7_:Number = 1;
         if(param2)
         {
            _loc10_ = _loc4_;
            _loc11_ = _loc5_;
            _loc4_ = int(roundToNextHighestPowerOf2(_loc4_));
            _loc5_ = int(roundToNextHighestPowerOf2(_loc5_));
            _loc6_ = _loc4_ / _loc10_;
            _loc7_ = _loc5_ / _loc11_;
         }
         var _loc8_:Matrix = new Matrix();
         _loc8_.translate(-param1.width * 0.5,-param1.height * 0.5);
         _loc8_.rotate(_loc3_);
         _loc8_.scale(1 * _loc6_,0.5 * _loc7_);
         _loc8_.translate(_loc4_ * 0.5,_loc5_ * 0.5);
         var _loc9_:BitmapData = new BitmapData(_loc4_,_loc5_,true,0);
         _loc9_.draw(param1,_loc8_);
         return _loc9_;
      }
      
      public static function resizeToPowerOf2(param1:BitmapData) : BitmapData
      {
         var _loc2_:int = int(roundToNextHighestPowerOf2(param1.width));
         var _loc3_:int = int(roundToNextHighestPowerOf2(param1.height));
         var _loc4_:Matrix = new Matrix();
         _loc4_.scale(_loc2_ / param1.width,_loc3_ / param1.height);
         var _loc5_:BitmapData = new BitmapData(_loc2_,_loc3_,param1.transparent,0);
         _loc5_.draw(param1,_loc4_);
         return _loc5_;
      }
      
      private static function roundToNextHighestPowerOf2(param1:uint) : uint
      {
         param1--;
         param1 |= param1 >> 1;
         param1 |= param1 >> 2;
         param1 |= param1 >> 4;
         param1 |= param1 >> 8;
         param1 |= param1 >> 16;
         param1++;
         return param1;
      }
   }
}

