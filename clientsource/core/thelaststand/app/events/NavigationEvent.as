package thelaststand.app.events
{
   import flash.events.Event;
   
   public class NavigationEvent extends Event
   {
      
      public static const REQUEST:String = "navigationRequest";
      
      public static const EXTERNAL:String = "navigationExternal";
      
      public static const START:String = "navigationStart";
      
      private var _data:Object;
      
      private var _location:String;
      
      private var _bypassFadeOut:Boolean;
      
      public function NavigationEvent(param1:String, param2:String, param3:* = null, param4:Boolean = false)
      {
         super(param1,true,true);
         this._data = param3;
         this._location = param2;
         this._bypassFadeOut = param4;
      }
      
      public function get data() : *
      {
         return this._data;
      }
      
      public function get location() : String
      {
         return this._location;
      }
      
      public function get bypassFadeOut() : Boolean
      {
         return this._bypassFadeOut;
      }
   }
}

