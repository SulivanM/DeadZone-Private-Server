package com.adobe.protocols.dict.events
{
   import com.adobe.protocols.dict.Dict;
   import flash.events.Event;
   
   public class DictionaryServerEvent extends Event
   {
      
      private var _servers:Array;
      
      public function DictionaryServerEvent()
      {
         super(Dict.SERVERS);
      }
      
      public function set servers(param1:Array) : void
      {
         this._servers = param1;
      }
      
      public function get servers() : Array
      {
         return this._servers;
      }
   }
}

