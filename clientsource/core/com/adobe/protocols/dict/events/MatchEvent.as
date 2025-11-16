package com.adobe.protocols.dict.events
{
   import com.adobe.protocols.dict.Dict;
   import flash.events.Event;
   
   public class MatchEvent extends Event
   {
      
      private var _matches:Array;
      
      public function MatchEvent()
      {
         super(Dict.MATCH);
      }
      
      public function set matches(param1:Array) : void
      {
         this._matches = param1;
      }
      
      public function get matches() : Array
      {
         return this._matches;
      }
   }
}

