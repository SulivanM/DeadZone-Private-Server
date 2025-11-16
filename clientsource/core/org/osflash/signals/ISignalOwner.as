package org.osflash.signals
{
   public interface ISignalOwner extends ISignal, IDispatcher
   {
      
      function removeAll() : void;
   }
}

