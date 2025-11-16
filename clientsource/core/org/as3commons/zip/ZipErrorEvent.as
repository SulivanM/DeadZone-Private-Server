package org.as3commons.zip
{
   import flash.events.Event;
   
   public class ZipErrorEvent extends Event
   {
      
      public static const PARSE_ERROR:String = "parseError";
      
      public var text:String;
      
      public function ZipErrorEvent(param1:String, param2:String = "", param3:Boolean = false, param4:Boolean = false)
      {
         this.text = param2;
         super(param1,param3,param4);
      }
      
      override public function clone() : Event
      {
         return new ZipErrorEvent(type,this.text,bubbles,cancelable);
      }
   }
}

