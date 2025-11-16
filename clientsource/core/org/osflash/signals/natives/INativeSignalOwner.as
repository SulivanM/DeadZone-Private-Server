package org.osflash.signals.natives
{
   import org.osflash.signals.IPrioritySignal;
   
   public interface INativeSignalOwner extends IPrioritySignal, INativeDispatcher
   {
      
      function removeAll() : void;
   }
}

