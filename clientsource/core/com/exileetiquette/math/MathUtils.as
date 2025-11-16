package com.exileetiquette.math
{
   import flash.errors.IllegalOperationError;
   import flash.geom.Point;
   
   public final class MathUtils
   {
      
      public static const DEGREES:Number = 180 / Math.PI;
      
      public static const RADIANS:Number = Math.PI / 180;
      
      public static const PI:Number = Math.PI;
      
      public static const TWO_PI:Number = PI + PI;
      
      public static const NEG_PI:Number = -PI;
      
      public static const QUARTER_PI:Number = 4 / PI;
      
      public static const HALF_PI:Number = PI * 0.5;
      
      public static const SIN_ADJUST:Number = 0.225;
      
      public function MathUtils()
      {
         super();
         throw new Error("MathUtils cannot be directly instantiated.");
      }
      
      public static function abs(param1:Number) : Number
      {
         return param1 < 0 ? -param1 : param1;
      }
      
      public static function sign(param1:Number) : int
      {
         return param1 < 0 ? -1 : (param1 > 0 ? 1 : 0);
      }
      
      public static function clamp(param1:Number, param2:Number = 4.9e-324, param3:Number = 1.79e+308) : Number
      {
         if(param2 > param3)
         {
            throw new IllegalOperationError("lowerBound must be less than upperBound.");
         }
         if(param1 < param2)
         {
            return param2;
         }
         if(param1 > param3)
         {
            return param3;
         }
         return param1;
      }
      
      public static function clamp01(param1:Number) : Number
      {
         return clamp(param1,0,1);
      }
      
      public static function correctAngle(param1:Number) : Number
      {
         while(param1 > 2 * Math.PI)
         {
            param1 -= 2 * Math.PI;
         }
         while(param1 < 0)
         {
            param1 += 2 * Math.PI;
         }
         return param1;
      }
      
      public static function getOctantFromAngle(param1:Number) : int
      {
         if(param1 >= 0 && param1 < Math.PI * 0.25)
         {
            return 0;
         }
         if(param1 >= Math.PI * 0.25 && param1 < Math.PI * 0.5)
         {
            return 1;
         }
         if(param1 >= Math.PI * 0.5 && param1 < Math.PI * 0.75)
         {
            return 2;
         }
         if(param1 >= Math.PI * 0.75 && param1 < Math.PI)
         {
            return 3;
         }
         if(param1 >= Math.PI && param1 < Math.PI * 1.25)
         {
            return 4;
         }
         if(param1 >= Math.PI * 1.25 && param1 < Math.PI * 1.5)
         {
            return 5;
         }
         if(param1 >= Math.PI * 1.5 && param1 < Math.PI * 1.75)
         {
            return 6;
         }
         if(param1 >= Math.PI * 1.75 && param1 <= Math.PI * 2)
         {
            return 7;
         }
         return 0;
      }
      
      public static function getShortestAngle(param1:Number, param2:Number) : Number
      {
         return wrap(param2 - param1,-Math.PI,Math.PI);
      }
      
      public static function getShortestAngleDegrees(param1:Number, param2:Number) : Number
      {
         return wrap(param2 - param1,-180,180);
      }
      
      public static function getShortestAngle2(param1:Number, param2:Number) : Number
      {
         return Math.atan2(Math.sin(param2 - param1),Math.cos(param2 - param1));
      }
      
      public static function isAngleBetween(param1:Number, param2:Number, param3:Number, param4:Boolean = false) : Boolean
      {
         var _loc5_:Number = NaN;
         if(param4)
         {
            _loc5_ = param2;
            param2 = param3;
            param3 = _loc5_;
         }
         if(param2 >= param3 - 1e-12)
         {
            if(param1 >= param2 - 1e-12 || param1 <= param3 + 1e-12)
            {
               return true;
            }
         }
         else if(param1 >= param2 - 1e-12 && param1 <= param3 + 1e-12)
         {
            return true;
         }
         return false;
      }
      
      public static function isBetween(param1:Number, param2:Number, param3:Number) : Boolean
      {
         return param1 >= param2 && param1 <= param3;
      }
      
      public static function isMovingClockwise(param1:Number, param2:Number) : Boolean
      {
         var _loc3_:Number = 2 * Math.PI;
         if(param1 < 0)
         {
            param1 += _loc3_;
         }
         if(param2 < 0)
         {
            param2 += _loc3_;
         }
         var _loc4_:Number = param2 - param1;
         if(_loc4_ > Math.PI)
         {
            _loc4_ -= _loc3_;
         }
         if(_loc4_ < -Math.PI)
         {
            _loc4_ += _loc3_;
         }
         if(_loc4_ >= 0)
         {
            return true;
         }
         return false;
      }
      
      public static function randomBetween(param1:Number, param2:Number, param3:Boolean = true) : Number
      {
         var _loc4_:Number = Math.random() * (param2 - param1);
         if(param3)
         {
            return int(param1 + _loc4_);
         }
         return param1 + _loc4_;
      }
      
      public static function roundToNearest(param1:Number, param2:Number) : Number
      {
         return Math.round(param1 / param2) * param2;
      }
      
      public static function roundUpToNearest(param1:Number, param2:Number) : Number
      {
         return Math.ceil(param1 / param2) * param2;
      }
      
      public static function roundDownToNearest(param1:Number, param2:Number) : Number
      {
         return Math.floor(param1 / param2) * param2;
      }
      
      public static function roundToPrecision(param1:Number, param2:int = 0) : Number
      {
         var _loc3_:Number = Math.pow(10,param2);
         return Math.round(_loc3_ * param1) / _loc3_;
      }
      
      public static function wrap(param1:Number, param2:Number, param3:Number) : Number
      {
         if(param3 <= param2)
         {
            throw new Error("Wrapping bounds are negative or zero in size.");
         }
         var _loc4_:Number = param3 - param2;
         var _loc5_:Number = Math.floor((param1 - param2) / _loc4_);
         return param1 - _loc5_ * _loc4_;
      }
      
      public static function fastInvSqrt(param1:Number) : Number
      {
         var _loc2_:Number = 0.5 * param1;
         var _loc3_:int = int(param1);
         _loc3_ = 99841437 - (_loc3_ >> 1);
         param1 = Number(_loc3_);
         return param1 * (1.5 - _loc2_ * param1 * param1);
      }
      
      public static function isEven(param1:Number) : Boolean
      {
         return Boolean((param1 & 1) == 0);
      }
      
      public static function findPointOn3PointBezier(param1:Number, param2:Point, param3:Point, param4:Point) : Point
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Point = new Point();
         _loc7_ = param1 * param1;
         _loc5_ = 1 - param1;
         _loc6_ = _loc5_ * _loc5_;
         _loc8_.x = param2.x * _loc6_ + 2 * param3.x * _loc5_ * param1 + param4.x * _loc7_;
         _loc8_.y = param2.y * _loc6_ + 2 * param3.y * _loc5_ * param1 + param4.y * _loc7_;
         return _loc8_;
      }
      
      public static function findPointOn4PointBezier(param1:Number, param2:Point, param3:Point, param4:Point, param5:Point) : Point
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Point = new Point();
         _loc6_ = 1 - param1;
         _loc7_ = _loc6_ * _loc6_ * _loc6_;
         _loc8_ = param1 * param1 * param1;
         _loc9_.x = _loc7_ * param2.x + 3 * param1 * _loc6_ * _loc6_ * param3.x + 3 * param1 * param1 * _loc6_ * param4.x + _loc8_ * param5.x;
         _loc9_.y = _loc7_ * param2.y + 3 * param1 * _loc6_ * _loc6_ * param3.y + 3 * param1 * param1 * _loc6_ * param4.y + _loc8_ * param5.y;
         return _loc9_;
      }
      
      public static function fastSine_beta(param1:Number) : Number
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(param1 < NEG_PI)
         {
            param1 += TWO_PI;
         }
         else if(param1 > PI)
         {
            param1 -= TWO_PI;
         }
         if(param1 < 0)
         {
            _loc2_ = -param1;
         }
         else
         {
            _loc2_ = param1;
         }
         _loc4_ = (param1 - param1 * _loc2_ / PI) * QUARTER_PI;
         if(_loc4_ < 0)
         {
            _loc3_ = -_loc4_;
         }
         else
         {
            _loc3_ = _loc4_;
         }
         return _loc4_ + SIN_ADJUST * (_loc4_ * _loc3_ - _loc4_);
      }
      
      public static function sin(param1:Number) : Number
      {
         var _loc2_:Number = NaN;
         if(param1 < -3.14159265)
         {
            param1 += 6.28318531;
         }
         else if(param1 > 3.14159265)
         {
            param1 -= 6.28318531;
         }
         if(param1 < 0)
         {
            _loc2_ = 1.27323954 * param1 + 0.405284735 * param1 * param1;
         }
         else
         {
            _loc2_ = 1.27323954 * param1 - 0.405284735 * param1 * param1;
         }
         return _loc2_;
      }
      
      public static function cos(param1:Number) : Number
      {
         var _loc2_:Number = NaN;
         if(param1 < -3.14159265)
         {
            param1 += 6.28318531;
         }
         else if(param1 > 3.14159265)
         {
            param1 -= 6.28318531;
         }
         param1 += 1.57079632;
         if(param1 > 3.14159265)
         {
            param1 -= 6.28318531;
         }
         if(param1 < 0)
         {
            _loc2_ = 1.27323954 * param1 + 0.405284735 * param1 * param1;
         }
         else
         {
            _loc2_ = 1.27323954 * param1 - 0.405284735 * param1 * param1;
         }
         return _loc2_;
      }
      
      public static function pow(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = param1;
         var _loc4_:int = 0;
         var _loc5_:int = param2 - 1;
         while(_loc4_ < _loc5_)
         {
            _loc3_ *= param1;
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function spline(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number) : Number
      {
         var _loc6_:Number = (param3 - param1) * 0.5;
         var _loc7_:Number = (param4 - param2) * 0.5;
         var _loc8_:Number = param5 * param5;
         var _loc9_:Number = _loc8_ * param5;
         return (2 * param2 - 2 * param3 + _loc6_ + _loc7_) * _loc9_ + (-3 * param2 + 3 * param3 - 2 * _loc6_ - _loc7_) * _loc8_ + _loc6_ * param5 + param2;
      }
   }
}

