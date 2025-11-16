package com.junkbyte.console.vos
{
   import flash.utils.Proxy;
   import flash.utils.flash_proxy;
   
   use namespace flash_proxy;
   
   public dynamic class WeakObject extends Proxy
   {
      
      private var _item:Array;
      
      private var _dir:Object;
      
      public function WeakObject()
      {
         super();
         this._dir = new Object();
      }
      
      public function set(param1:String, param2:Object, param3:Boolean = false) : void
      {
         if(param2 == null)
         {
            delete this._dir[param1];
         }
         else
         {
            this._dir[param1] = new WeakRef(param2,param3);
         }
      }
      
      public function get(param1:String) : *
      {
         var _loc2_:WeakRef = this.getWeakRef(param1);
         return _loc2_ ? _loc2_.reference : undefined;
      }
      
      public function getWeakRef(param1:String) : WeakRef
      {
         return this._dir[param1] as WeakRef;
      }
      
      override flash_proxy function getProperty(param1:*) : *
      {
         return this.get(param1);
      }
      
      override flash_proxy function callProperty(param1:*, ... rest) : *
      {
         var _loc3_:Object = this.get(param1);
         return _loc3_.apply(this,rest);
      }
      
      override flash_proxy function setProperty(param1:*, param2:*) : void
      {
         this.set(param1,param2);
      }
      
      override flash_proxy function nextName(param1:int) : String
      {
         return this._item[param1 - 1];
      }
      
      override flash_proxy function nextValue(param1:int) : *
      {
         return this[this.flash_proxy::nextName(param1)];
      }
      
      override flash_proxy function nextNameIndex(param1:int) : int
      {
         var _loc2_:* = undefined;
         if(param1 == 0)
         {
            this._item = new Array();
            for(_loc2_ in this._dir)
            {
               this._item.push(_loc2_);
            }
         }
         if(param1 < this._item.length)
         {
            return param1 + 1;
         }
         return 0;
      }
      
      override flash_proxy function deleteProperty(param1:*) : Boolean
      {
         return delete this._dir[param1];
      }
      
      public function toString() : String
      {
         return "[WeakObject]";
      }
   }
}

