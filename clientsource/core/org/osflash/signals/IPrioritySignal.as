package org.osflash.signals
{
   public interface IPrioritySignal extends ISignal
   {
      
      function addWithPriority(param1:Function, param2:int = 0) : Function;
      
      function addOnceWithPriority(param1:Function, param2:int = 0) : Function;
   }
}

