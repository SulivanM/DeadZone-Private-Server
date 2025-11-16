package org.osflash.signals.events
{
   import org.osflash.signals.IPrioritySignal;
   
   public class GenericEvent implements IEvent
   {
      
      protected var _bubbles:Boolean;
      
      protected var _target:Object;
      
      protected var _currentTarget:Object;
      
      protected var _signal:IPrioritySignal;
      
      public function GenericEvent(param1:Boolean = false)
      {
         super();
         this._bubbles = param1;
      }
      
      public function get signal() : IPrioritySignal
      {
         return this._signal;
      }
      
      public function set signal(param1:IPrioritySignal) : void
      {
         this._signal = param1;
      }
      
      public function get target() : Object
      {
         return this._target;
      }
      
      public function set target(param1:Object) : void
      {
         this._target = param1;
      }
      
      public function get currentTarget() : Object
      {
         return this._currentTarget;
      }
      
      public function set currentTarget(param1:Object) : void
      {
         this._currentTarget = param1;
      }
      
      public function get bubbles() : Boolean
      {
         return this._bubbles;
      }
      
      public function set bubbles(param1:Boolean) : void
      {
         this._bubbles = param1;
      }
      
      public function clone() : IEvent
      {
         return new GenericEvent(this._bubbles);
      }
   }
}

