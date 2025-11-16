package org.osflash.signals.events
{
   import org.osflash.signals.IPrioritySignal;
   
   public interface IEvent
   {
      
      function get target() : Object;
      
      function set target(param1:Object) : void;
      
      function get currentTarget() : Object;
      
      function set currentTarget(param1:Object) : void;
      
      function get signal() : IPrioritySignal;
      
      function set signal(param1:IPrioritySignal) : void;
      
      function get bubbles() : Boolean;
      
      function set bubbles(param1:Boolean) : void;
      
      function clone() : IEvent;
   }
}

