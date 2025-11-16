package com.adobe.protocols.dict.events
{
   import com.adobe.protocols.dict.Dict;
   import flash.events.Event;
   
   public class ErrorEvent extends Event
   {
      
      private var _code:uint;
      
      private var _message:String;
      
      public function ErrorEvent()
      {
         super(Dict.ERROR);
      }
      
      public function set code(param1:uint) : void
      {
         this._code = param1;
      }
      
      public function set message(param1:String) : void
      {
         this._message = param1;
      }
      
      public function get code() : uint
      {
         return this._code;
      }
      
      public function get message() : String
      {
         return this._message;
      }
   }
}

