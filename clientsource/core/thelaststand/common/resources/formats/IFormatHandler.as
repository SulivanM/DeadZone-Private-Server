package thelaststand.common.resources.formats
{
   import flash.utils.ByteArray;
   import org.osflash.signals.DeluxeSignal;
   
   public interface IFormatHandler
   {
      
      function dispose() : void;
      
      function get extensions() : Array;
      
      function getContent() : *;
      
      function getContentAsByteArray() : ByteArray;
      
      function get id() : String;
      
      function load(param1:String, param2:* = null) : void;
      
      function get loadCompleted() : DeluxeSignal;
      
      function get loaded() : Boolean;
      
      function get loadFailed() : DeluxeSignal;
      
      function loadFromByteArray(param1:ByteArray, param2:* = null) : void;
      
      function get loading() : Boolean;
      
      function get loadProgress() : DeluxeSignal;
      
      function pauseLoad() : void;
   }
}

