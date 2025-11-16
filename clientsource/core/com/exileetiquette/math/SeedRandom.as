package com.exileetiquette.math
{
   import flash.utils.getTimer;
   
   public class SeedRandom
   {
      
      public var seed:Number = 0;
      
      public function SeedRandom(param1:Number = NaN)
      {
         super();
         if(isNaN(param1))
         {
            param1 = getTimer();
         }
         this.seed = param1;
      }
      
      public function getRandom() : Number
      {
         this.seed = (this.seed * 9301 + 49297) % 233280;
         return Number(Number(this.seed / 233280).toFixed(15));
      }
      
      public function getNumInRange(param1:Number, param2:Number) : Number
      {
         return param1 + (param2 - param1) * this.getRandom();
      }
      
      public function getIntInRange(param1:Number, param2:Number) : int
      {
         return int(param1 + (param2 - param1) * this.getRandom());
      }
      
      public function getBoolean() : Boolean
      {
         return Boolean(this.getRandom() < 0.5);
      }
   }
}

