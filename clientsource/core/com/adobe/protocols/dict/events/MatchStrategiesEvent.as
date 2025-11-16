package com.adobe.protocols.dict.events
{
   import com.adobe.protocols.dict.Dict;
   import flash.events.Event;
   
   public class MatchStrategiesEvent extends Event
   {
      
      private var _strategies:Array;
      
      public function MatchStrategiesEvent()
      {
         super(Dict.MATCH_STRATEGIES);
      }
      
      public function set strategies(param1:Array) : void
      {
         this._strategies = param1;
      }
      
      public function get strategies() : Array
      {
         return this._strategies;
      }
   }
}

