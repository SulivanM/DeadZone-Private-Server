package com.adobe.protocols.dict.events
{
   import com.adobe.protocols.dict.Dict;
   import flash.events.Event;
   
   public class DefinitionHeaderEvent extends Event
   {
      
      private var _definitionCount:uint;
      
      public function DefinitionHeaderEvent()
      {
         super(Dict.DEFINITION_HEADER);
      }
      
      public function set definitionCount(param1:uint) : void
      {
         this._definitionCount = param1;
      }
      
      public function get definitionCount() : uint
      {
         return this._definitionCount;
      }
   }
}

