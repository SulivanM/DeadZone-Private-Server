package org.osflash.signals
{
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class Signal implements ISignalOwner, IDispatcher
   {
      
      protected var _valueClasses:Array;
      
      protected var listeners:Array;
      
      protected var onceListeners:Dictionary;
      
      protected var listenersNeedCloning:Boolean = false;
      
      public function Signal(... rest)
      {
         super();
         this.listeners = [];
         this.onceListeners = new Dictionary();
         if(rest.length == 1 && rest[0] is Array)
         {
            rest = rest[0];
         }
         this.valueClasses = rest;
      }
      
      public function get valueClasses() : Array
      {
         return this._valueClasses;
      }
      
      public function set valueClasses(param1:Array) : void
      {
         this._valueClasses = param1 ? param1.slice() : [];
         var _loc2_:int = int(this._valueClasses.length);
         while(_loc2_--)
         {
            if(!(this._valueClasses[_loc2_] is Class))
            {
               throw new ArgumentError("Invalid valueClasses argument: item at index " + _loc2_ + " should be a Class but was:<" + this._valueClasses[_loc2_] + ">." + getQualifiedClassName(this._valueClasses[_loc2_]));
            }
         }
      }
      
      public function get numListeners() : uint
      {
         return this.listeners.length;
      }
      
      public function add(param1:Function) : Function
      {
         this.registerListener(param1);
         return param1;
      }
      
      public function addOnce(param1:Function) : Function
      {
         this.registerListener(param1,true);
         return param1;
      }
      
      public function remove(param1:Function) : Function
      {
         var _loc2_:int = int(this.listeners.indexOf(param1));
         if(_loc2_ == -1)
         {
            return param1;
         }
         if(this.listenersNeedCloning)
         {
            this.listeners = this.listeners.slice();
            this.listenersNeedCloning = false;
         }
         this.listeners.splice(_loc2_,1);
         delete this.onceListeners[param1];
         return param1;
      }
      
      public function removeAll() : void
      {
         var _loc1_:uint = this.listeners.length;
         while(_loc1_--)
         {
            this.remove(this.listeners[_loc1_] as Function);
         }
      }
      
      public function dispatch(... rest) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Class = null;
         var _loc6_:Function = null;
         var _loc4_:int = int(this._valueClasses.length);
         if(rest.length < _loc4_)
         {
            throw new ArgumentError("Incorrect number of arguments. Expected at least " + _loc4_ + " but received " + rest.length + ".");
         }
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc2_ = rest[_loc5_];
            if(!(_loc2_ === null || _loc2_ is (_loc3_ = this._valueClasses[_loc5_])))
            {
               throw new ArgumentError("Value object <" + _loc2_ + "> is not an instance of <" + _loc3_ + ">.");
            }
            _loc5_++;
         }
         if(!this.listeners.length)
         {
            return;
         }
         this.listenersNeedCloning = true;
         switch(rest.length)
         {
            case 0:
               for each(_loc6_ in this.listeners)
               {
                  if(this.onceListeners[_loc6_])
                  {
                     this.remove(_loc6_);
                  }
                  _loc6_();
               }
               break;
            case 1:
               for each(_loc6_ in this.listeners)
               {
                  if(this.onceListeners[_loc6_])
                  {
                     this.remove(_loc6_);
                  }
                  _loc6_(rest[0]);
               }
               break;
            default:
               for each(_loc6_ in this.listeners)
               {
                  if(this.onceListeners[_loc6_])
                  {
                     this.remove(_loc6_);
                  }
                  _loc6_.apply(null,rest);
               }
         }
         this.listenersNeedCloning = false;
      }
      
      protected function registerListener(param1:Function, param2:Boolean = false) : void
      {
         var _loc3_:String = null;
         if(param1.length < this._valueClasses.length)
         {
            _loc3_ = param1.length == 1 ? "argument" : "arguments";
            throw new ArgumentError("Listener has " + param1.length + " " + _loc3_ + " but it needs at least " + this._valueClasses.length + " to match the given value classes.");
         }
         if(!this.listeners.length)
         {
            this.listeners[0] = param1;
            if(param2)
            {
               this.onceListeners[param1] = true;
            }
            return;
         }
         if(this.listeners.indexOf(param1) >= 0)
         {
            if(Boolean(this.onceListeners[param1]) && !param2)
            {
               throw new IllegalOperationError("You cannot addOnce() then add() the same listener without removing the relationship first.");
            }
            if(!this.onceListeners[param1] && param2)
            {
               throw new IllegalOperationError("You cannot add() then addOnce() the same listener without removing the relationship first.");
            }
            return;
         }
         if(this.listenersNeedCloning)
         {
            this.listeners = this.listeners.slice();
            this.listenersNeedCloning = false;
         }
         this.listeners[this.listeners.length] = param1;
         if(param2)
         {
            this.onceListeners[param1] = true;
         }
      }
   }
}

