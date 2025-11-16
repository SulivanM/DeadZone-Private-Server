package org.osflash.signals.natives
{
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   
   public interface INativeDispatcher
   {
      
      function get eventType() : String;
      
      function get eventClass() : Class;
      
      function get target() : IEventDispatcher;
      
      function dispatch(param1:Event) : Boolean;
   }
}

