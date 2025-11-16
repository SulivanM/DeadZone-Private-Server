package com.junkbyte.console.vos
{
   import flash.utils.Dictionary;
   
   public class WeakRef
   {
      
      private var _val:*;
      
      private var _strong:Boolean;
      
      public function WeakRef(param1:*, param2:Boolean = false)
      {
         super();
         this._strong = param2;
         this.reference = param1;
      }
      
      public function get reference() : *
      {
         var _loc1_:* = undefined;
         if(this._strong)
         {
            return this._val;
         }
         var _loc2_:int = 0;
         var _loc3_:* = this._val;
         for(_loc1_ in _loc3_)
         {
            return _loc1_;
         }
         return null;
      }
      
      public function set reference(param1:*) : void
      {
         if(this._strong)
         {
            this._val = param1;
         }
         else
         {
            this._val = new Dictionary(true);
            this._val[param1] = null;
         }
      }
      
      public function get strong() : Boolean
      {
         return this._strong;
      }
   }
}

