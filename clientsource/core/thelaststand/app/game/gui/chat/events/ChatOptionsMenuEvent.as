package thelaststand.app.game.gui.chat.events
{
   import flash.events.Event;
   
   public class ChatOptionsMenuEvent extends Event
   {
      
      public static const MENU_ITEM_CLICK:String = "chatOptionsMenu_itemClick";
      
      public static const CMD_HELP:String = "help";
      
      public static const CMD_CONTACTS:String = "contacts";
      
      public static const CMD_BLOCKED:String = "blocked";
      
      public static const CMD_INSERT_WAR_STATS:String = "insertWarStats";
      
      public static const CMD_LISTROOMS:String = "listrooms";
      
      public var command:String;
      
      public var data:Array;
      
      public function ChatOptionsMenuEvent(param1:String, param2:String, param3:Array = null)
      {
         super(param1,true,false);
         this.command = param2;
         this.data = param3;
      }
   }
}

