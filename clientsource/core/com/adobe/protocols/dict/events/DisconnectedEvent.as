package com.adobe.protocols.dict.events
{
   import com.adobe.protocols.dict.Dict;
   import flash.events.Event;
   
   public class DisconnectedEvent extends Event
   {
      
      public function DisconnectedEvent()
      {
         super(Dict.DISCONNECTED);
      }
   }
}

