package com.adobe.protocols.dict.events
{
   import com.adobe.protocols.dict.Definition;
   import com.adobe.protocols.dict.Dict;
   import flash.events.Event;
   
   public class DefinitionEvent extends Event
   {
      
      private var _definition:Definition;
      
      public function DefinitionEvent()
      {
         super(Dict.DEFINITION);
      }
      
      public function set definition(param1:Definition) : void
      {
         this._definition = param1;
      }
      
      public function get definition() : Definition
      {
         return this._definition;
      }
   }
}

