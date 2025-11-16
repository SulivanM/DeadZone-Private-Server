package thelaststand.app.game.gui.chat.events
{
   import flash.events.Event;
   
   public class ChatLinkEvent extends Event
   {
      
      public static const LINK_CLICK:String = "chatLinkClick";
      
      public static const ADD_TO_CHAT:String = "chatLinkAddToChat";
      
      public static const LT_ITEM:String = "item";
      
      public static const LT_USERMENU:String = "userMenu";
      
      public static const LT_JOIN:String = "join";
      
      public static const LT_JOINBALANCED:String = "joinBalanced";
      
      public static const LT_ALLIANCE_SHOW:String = "alliance_show";
      
      public static const LT_HYPERLINK:String = "link";
      
      public static const LT_PASTE:String = "paste";
      
      public static const LT_WARSTATS:String = "warstats";
      
      public var linkType:String;
      
      public var data:*;
      
      public function ChatLinkEvent(param1:String, param2:String, param3:* = null)
      {
         super(param1,true,false);
         this.linkType = param2;
         this.data = param3;
      }
   }
}

