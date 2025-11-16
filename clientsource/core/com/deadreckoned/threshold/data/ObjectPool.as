package com.deadreckoned.threshold.data
{
   import com.deadreckoned.threshold.core.IDisposable;
   
   public class ObjectPool implements IDisposable
   {
      
      private var _pool:Vector.<Object>;
      
      private var _size:int;
      
      private var _initSize:int;
      
      private var _growthSize:int;
      
      private var _lazy:Boolean;
      
      private var _objectType:Class;
      
      private var _index:int;
      
      public function ObjectPool(param1:Class, param2:int, param3:int = 0, param4:Boolean = false)
      {
         var _loc5_:int = 0;
         super();
         this._objectType = param1;
         this._size = this._initSize = param2;
         this._growthSize = param3;
         this._lazy = param4;
         this._index = this._size;
         this._pool = new Vector.<Object>(param2);
         if(!this._lazy)
         {
            _loc5_ = 0;
            while(_loc5_ < this._size)
            {
               this._pool[_loc5_] = new this._objectType();
               _loc5_++;
            }
         }
      }
      
      public function get size() : int
      {
         return this._size;
      }
      
      public function get lazy() : Boolean
      {
         return this._lazy;
      }
      
      public function get type() : Class
      {
         return this._objectType;
      }
      
      public function dispose() : void
      {
         if(this._pool == null)
         {
            return;
         }
         this._pool = null;
         this._objectType = null;
      }
      
      public function reset() : void
      {
         var _loc1_:int = 0;
         this._size = this._initSize;
         this._index = this._size;
         this._pool.length = this._size;
         if(this._lazy)
         {
            _loc1_ = 0;
            while(_loc1_ < this._size)
            {
               this._pool[_loc1_] = null;
               _loc1_++;
            }
         }
      }
      
      public function get() : Object
      {
         if(this._index > 0)
         {
            --this._index;
            if(this._lazy && this._pool[this._index] == null)
            {
               this._pool[this._index] = new this._objectType();
            }
            return this._pool[this._index];
         }
         if(this._growthSize == 0)
         {
            return null;
         }
         var _loc1_:int = this._growthSize;
         while(--_loc1_ >= 0)
         {
            this._pool.unshift(this._lazy ? null : new this._objectType());
         }
         this._index = this._growthSize;
         this._size = this._pool.length;
         return this.get();
      }
      
      public function put(param1:Object) : void
      {
         this._pool[this._index++] = param1;
      }
   }
}

