package org.osflash.signals
{
   import flash.errors.IllegalOperationError;
   import org.osflash.signals.events.IBubbleEventHandler;
   import org.osflash.signals.events.IEvent;
   
   public class DeluxeSignal implements ISignalOwner, IPrioritySignal
   {
      
      protected var _target:Object;
      
      protected var _valueClasses:Array;
      
      protected var listenerBoxes:Array;
      
      protected var listenersNeedCloning:Boolean = false;
      
      public function DeluxeSignal(param1:Object = null, ... rest)
      {
         super();
         this._target = param1;
         this.listenerBoxes = [];
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
               throw new ArgumentError("Invalid valueClasses argument: item at index " + _loc2_ + " should be a Class but was:<" + this._valueClasses[_loc2_] + ">.");
            }
         }
      }
      
      public function get numListeners() : uint
      {
         return this.listenerBoxes.length;
      }
      
      public function get target() : Object
      {
         return this._target;
      }
      
      public function set target(param1:Object) : void
      {
         if(param1 == this._target)
         {
            return;
         }
         this.removeAll();
         this._target = param1;
      }
      
      public function add(param1:Function) : Function
      {
         return this.addWithPriority(param1);
      }
      
      public function addWithPriority(param1:Function, param2:int = 0) : Function
      {
         this.registerListener(param1,false,param2);
         return param1;
      }
      
      public function addOnce(param1:Function) : Function
      {
         return this.addOnceWithPriority(param1);
      }
      
      public function addOnceWithPriority(param1:Function, param2:int = 0) : Function
      {
         this.registerListener(param1,true,param2);
         return param1;
      }
      
      public function remove(param1:Function) : Function
      {
         if(this.indexOfListener(param1) == -1)
         {
            return param1;
         }
         if(this.listenersNeedCloning)
         {
            this.listenerBoxes = this.listenerBoxes.slice();
            this.listenersNeedCloning = false;
         }
         this.listenerBoxes.splice(this.indexOfListener(param1),1);
         return param1;
      }
      
      public function removeAll() : void
      {
         var _loc1_:uint = this.listenerBoxes.length;
         while(_loc1_--)
         {
            this.remove(this.listenerBoxes[_loc1_].listener as Function);
         }
      }
      
      public function dispatch(... rest) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Class = null;
         var _loc7_:Function = null;
         var _loc9_:Object = null;
         var _loc4_:int = int(this._valueClasses.length);
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
         var _loc6_:IEvent = rest[0] as IEvent;
         if(_loc6_)
         {
            if(_loc6_.target)
            {
               rest[0] = _loc6_ = _loc6_.clone();
            }
            _loc6_.target = this.target;
            _loc6_.currentTarget = this.target;
            _loc6_.signal = this;
         }
         this.listenersNeedCloning = true;
         if(this.listenerBoxes.length)
         {
            for each(_loc9_ in this.listenerBoxes)
            {
               _loc7_ = _loc9_.listener;
               if(_loc9_.once)
               {
                  this.remove(_loc7_);
               }
               _loc7_.apply(null,rest);
            }
         }
         this.listenersNeedCloning = false;
         if(!_loc6_ || !_loc6_.bubbles)
         {
            return;
         }
         var _loc8_:Object = this.target;
         while(true)
         {
            _loc8_ = _loc8_.parent;
            if(!(_loc8_ && _loc8_.hasOwnProperty("parent") && (Boolean(_loc8_))))
            {
               break;
            }
            if(_loc8_ is IBubbleEventHandler)
            {
               if(!IBubbleEventHandler(_loc6_.currentTarget = _loc8_).onEventBubbled(_loc6_))
               {
                  break;
               }
            }
         }
      }
      
      protected function indexOfListener(param1:Function) : int
      {
         var _loc2_:int = int(this.listenerBoxes.length);
         while(_loc2_--)
         {
            if(this.listenerBoxes[_loc2_].listener == param1)
            {
               return _loc2_;
            }
         }
         return -1;
      }
      
      protected function registerListener(param1:Function, param2:Boolean = false, param3:int = 0) : void
      {
         var _loc8_:String = null;
         var _loc9_:Object = null;
         if(param1.length < this._valueClasses.length)
         {
            _loc8_ = param1.length == 1 ? "argument" : "arguments";
            throw new ArgumentError("Listener has " + param1.length + " " + _loc8_ + " but it needs at least " + this._valueClasses.length + " to match the given value classes.");
         }
         var _loc4_:Object = {
            "listener":param1,
            "once":param2,
            "priority":param3
         };
         if(!this.listenerBoxes.length)
         {
            this.listenerBoxes[0] = _loc4_;
            return;
         }
         var _loc5_:int = this.indexOfListener(param1);
         if(_loc5_ >= 0)
         {
            _loc9_ = this.listenerBoxes[_loc5_];
            if(Boolean(_loc9_.once) && !param2)
            {
               throw new IllegalOperationError("You cannot addOnce() then add() the same listener without removing the relationship first.");
            }
            if(!_loc9_.once && param2)
            {
               throw new IllegalOperationError("You cannot add() then addOnce() the same listener without removing the relationship first.");
            }
            return;
         }
         if(this.listenersNeedCloning)
         {
            this.listenerBoxes = this.listenerBoxes.slice();
            this.listenersNeedCloning = false;
         }
         var _loc6_:int = int(this.listenerBoxes.length);
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            if(param3 > this.listenerBoxes[_loc7_].priority)
            {
               this.listenerBoxes.splice(_loc7_,0,_loc4_);
               return;
            }
            _loc7_++;
         }
         this.listenerBoxes[this.listenerBoxes.length] = _loc4_;
      }
   }
}

