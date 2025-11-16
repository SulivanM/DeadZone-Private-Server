package org.as3commons.zip
{
   import flash.events.Event;
   
   public class ZipEvent extends Event
   {
      
      public static const FILE_LOADED:String = "fileLoaded";
      
      public var file:ZipFile;
      
      public function ZipEvent(param1:String, param2:ZipFile = null, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this.file = param2;
      }
      
      override public function clone() : Event
      {
         return new ZipEvent(type,this.file,bubbles,cancelable);
      }
      
      override public function toString() : String
      {
         return "[ZipEvent type=\"" + type + "\" filename=\"" + this.file.filename + "\" bubbles=" + bubbles + " cancelable=" + cancelable + " eventPhase=" + eventPhase + "]";
      }
   }
}

