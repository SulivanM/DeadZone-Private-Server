package thelaststand.app.game.gui.chat.events
{
   import flash.events.Event;
   
   public class ChatGUIEvent extends Event
   {
      
      public static const UNDOCKED:String = "chatGUIUndocked";
      
      private var _data:*;
      
      public function ChatGUIEvent(param1:String, param2:* = null)
      {
         super(param1,true);
         this._data = param2;
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}

