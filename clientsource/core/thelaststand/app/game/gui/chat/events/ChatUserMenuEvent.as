package thelaststand.app.game.gui.chat.events
{
   import flash.events.Event;
   
   public class ChatUserMenuEvent extends Event
   {
      
      public static const MENU_ITEM_CLICK:String = "chatUserMenu_itemClick";
      
      public static const CMD_MESSAGE:String = "message";
      
      public static const CMD_MUTE:String = "mute";
      
      public static const CMD_UNMUTE:String = "unmute";
      
      public static const CMD_BLOCK:String = "block";
      
      public static const CMD_UNBLOCK:String = "unblock";
      
      public static const CMD_ADD_CONTACT:String = "addContact";
      
      public static const CMD_REMOVE_CONTACT:String = "removeContact";
      
      public static const CMD_TRADE:String = "trade";
      
      public static const CMD_INVITE:String = "invite";
      
      public static const CMD_REPORT:String = "report";
      
      public static const CMD_PASTE:String = "paste";
      
      public static const CMD_PAYVAULT:String = "payvault";
      
      public static const CMD_HISTORY:String = "history";
      
      public static const CMD_SILENCE:String = "silence";
      
      public static const CMD_KICK:String = "kick";
      
      public static const CMD_KICKSILENT:String = "kicksilent";
      
      public static const CMD_TRADEBAN:String = "tradeBan";
      
      public static const CMD_RECAP:String = "recap";
      
      public static const CMD_PUSHPULL:String = "pushpull";
      
      public static const CMD_STRIKE:String = "strike";
      
      public var command:String;
      
      public var data:Array;
      
      public function ChatUserMenuEvent(param1:String, param2:String, param3:Array = null)
      {
         super(param1,true,false);
         this.command = param2;
         this.data = param3;
      }
   }
}

