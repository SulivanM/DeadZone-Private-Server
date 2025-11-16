package org.osflash.signals
{
   public interface ISignal
   {
      
      function get valueClasses() : Array;
      
      function set valueClasses(param1:Array) : void;
      
      function get numListeners() : uint;
      
      function add(param1:Function) : Function;
      
      function addOnce(param1:Function) : Function;
      
      function remove(param1:Function) : Function;
   }
}

