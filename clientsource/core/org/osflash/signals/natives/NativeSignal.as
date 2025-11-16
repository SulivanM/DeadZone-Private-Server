package org.osflash.signals.natives
{
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   
   public class NativeSignal implements INativeSignalOwner
   {
      
      protected var _target:IEventDispatcher;
      
      protected var _eventType:String;
      
      protected var _eventClass:Class;
      
      protected var listenerBoxes:Array;
      
      public function NativeSignal(param1:IEventDispatcher = null, param2:String = "", param3:Class = null)
      {
         super();
         this.listenerBoxes = [];
         this.target = param1;
         this.eventType = param2;
         this.eventClass = param3;
      }
      
      public function get eventType() : String
      {
         return this._eventType;
      }
      
      public function set eventType(param1:String) : void
      {
         this._eventType = param1;
      }
      
      public function get eventClass() : Class
      {
         return this._eventClass;
      }
      
      public function set eventClass(param1:Class) : void
      {
         this._eventClass = param1 || Event;
      }
      
      public function get valueClasses() : Array
      {
         return [this._eventClass];
      }
      
      public function set valueClasses(param1:Array) : void
      {
         this.eventClass = param1 ? param1[0] : null;
      }
      
      public function get numListeners() : uint
      {
         return this.listenerBoxes.length;
      }
      
      public function get target() : IEventDispatcher
      {
         return this._target;
      }
      
      public function set target(param1:IEventDispatcher) : void
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
         var _loc2_:int = this.indexOfListener(param1);
         if(_loc2_ == -1)
         {
            return param1;
         }
         var _loc3_:Object = this.listenerBoxes.splice(_loc2_,1)[0];
         this._target.removeEventListener(this._eventType,_loc3_.execute);
         return param1;
      }
      
      public function removeAll() : void
      {
         var _loc1_:int = int(this.listenerBoxes.length);
         while(_loc1_--)
         {
            this.remove(this.listenerBoxes[_loc1_].listener as Function);
         }
      }
      
      public function dispatch(param1:Event) : Boolean
      {
         if(!(param1 is this._eventClass))
         {
            throw new ArgumentError("Event object " + param1 + " is not an instance of " + this._eventClass + ".");
         }
         if(param1.type != this._eventType)
         {
            throw new ArgumentError("Event object has incorrect type. Expected <" + this._eventType + "> but was <" + param1.type + ">.");
         }
         return this._target.dispatchEvent(param1);
      }
      
      protected function registerListener(param1:Function, param2:Boolean = false, param3:int = 0) : void
      {
         var prevListenerIndex:int;
         var listenerBox:Object;
         var prevlistenerBox:Object = null;
         var signal:NativeSignal = null;
         var listener:Function = param1;
         var once:Boolean = param2;
         var priority:int = param3;
         if(listener.length != 1)
         {
            throw new ArgumentError("Listener for native event must declare exactly 1 argument.");
         }
         prevListenerIndex = this.indexOfListener(listener);
         if(prevListenerIndex >= 0)
         {
            prevlistenerBox = this.listenerBoxes[prevListenerIndex];
            if(Boolean(prevlistenerBox.once) && !once)
            {
               throw new IllegalOperationError("You cannot addOnce() then add() the same listener without removing the relationship first.");
            }
            if(!prevlistenerBox.once && once)
            {
               throw new IllegalOperationError("You cannot add() then addOnce() the same listener without removing the relationship first.");
            }
            return;
         }
         listenerBox = {
            "listener":listener,
            "once":once,
            "execute":listener
         };
         if(once)
         {
            signal = this;
            listenerBox.execute = function(param1:Event):void
            {
               signal.remove(listener);
               listener(param1);
            };
         }
         this.listenerBoxes[this.listenerBoxes.length] = listenerBox;
         this._target.addEventListener(this._eventType,listenerBox.execute,false,priority);
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
   }
}

