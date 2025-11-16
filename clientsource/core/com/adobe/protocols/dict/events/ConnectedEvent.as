package com.adobe.protocols.dict.events
{
   import com.adobe.protocols.dict.Dict;
   import flash.events.Event;
   
   public class ConnectedEvent extends Event
   {
      
      public function ConnectedEvent()
      {
         super(Dict.CONNECTED);
      }
   }
}

