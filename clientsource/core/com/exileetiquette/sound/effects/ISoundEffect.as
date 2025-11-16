package com.exileetiquette.sound.effects
{
   import flash.utils.ByteArray;
   
   public interface ISoundEffect
   {
      
      function destroy() : void;
      
      function process(param1:ByteArray, param2:ByteArray, param3:Number) : Number;
      
      function get propertyName() : String;
      
      function get settings() : Object;
      
      function set settings(param1:Object) : void;
   }
}

