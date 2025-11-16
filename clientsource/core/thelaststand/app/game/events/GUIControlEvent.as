package thelaststand.app.game.events
{
   import flash.events.Event;
   
   public class GUIControlEvent extends Event
   {
      
      public static const CAMERA_CONTROL:String = "guiCameraControl";
      
      private var _controlData:*;
      
      public function GUIControlEvent(param1:String, param2:Boolean = false, param3:Boolean = false, param4:* = null)
      {
         super(param1,param2,param3);
         this._controlData = param4;
      }
      
      public function get controlData() : *
      {
         return this._controlData;
      }
   }
}

