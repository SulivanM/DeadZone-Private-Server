package com.adobe.protocols.dict.events
{
   import com.adobe.protocols.dict.Dict;
   import flash.events.Event;
   
   public class NoMatchEvent extends Event
   {
      
      public function NoMatchEvent()
      {
         super(Dict.NO_MATCH);
      }
   }
}

