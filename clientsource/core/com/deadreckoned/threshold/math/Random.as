package com.deadreckoned.threshold.math
{
   public class Random
   {
      
      private static var _instance:Random;
      
      private var _seed:uint = 0;
      
      private var _currentSeed:uint = 0;
      
      public function Random(param1:uint = 1)
      {
         super();
         this._seed = this._currentSeed = param1;
      }
      
      private static function get instance() : Random
      {
         return _instance || (_instance = new Random());
      }
      
      public static function get seed() : uint
      {
         return instance.seed;
      }
      
      public static function set seed(param1:uint) : void
      {
         instance.seed = param1;
      }
      
      public static function next() : Number
      {
         return instance.next();
      }
      
      public static function integer(param1:Number = NaN, param2:Number = NaN) : int
      {
         return instance.integer(param1,param2);
      }
      
      public static function float(param1:Number = NaN, param2:Number = NaN) : Number
      {
         return instance.float(param1,param2);
      }
      
      public static function bool(param1:Number = 0.5) : Boolean
      {
         return instance.bool(param1);
      }
      
      public static function bit(param1:Number = 0.5) : int
      {
         return instance.bit(param1);
      }
      
      public static function sign(param1:Number = 0.5) : int
      {
         return instance.sign(param1);
      }
      
      public static function reset() : void
      {
         instance.reset();
      }
      
      public function get seed() : uint
      {
         return this._seed;
      }
      
      public function set seed(param1:uint) : void
      {
         this._seed = this._currentSeed = param1;
      }
      
      public function next() : Number
      {
         return (this._currentSeed = this._currentSeed * 16807 % 2147483647) / 2147483647 + 2.33e-10;
      }
      
      public function integer(param1:Number = NaN, param2:Number = NaN) : int
      {
         if(isNaN(param1))
         {
            return int(this.next() * int.MAX_VALUE);
         }
         if(isNaN(param2))
         {
            param2 = param1;
            param1 = 0;
         }
         return Math.floor(this.next() * (param2 - param1) + param1);
      }
      
      public function float(param1:Number = NaN, param2:Number = NaN) : Number
      {
         if(isNaN(param1))
         {
            return this.next() * Number.MAX_VALUE;
         }
         if(isNaN(param2))
         {
            param2 = param1;
            param1 = 0;
         }
         return this.next() * (param2 - param1) + param1;
      }
      
      public function bool(param1:Number = 0.5) : Boolean
      {
         return this.next() < param1;
      }
      
      public function bit(param1:Number = 0.5) : int
      {
         return this.next() < param1 ? 1 : 0;
      }
      
      public function sign(param1:Number = 0.5) : int
      {
         return this.next() < param1 ? 1 : -1;
      }
      
      public function reset() : void
      {
         this._currentSeed = this._seed;
      }
   }
}

