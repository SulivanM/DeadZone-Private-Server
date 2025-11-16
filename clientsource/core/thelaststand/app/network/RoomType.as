package thelaststand.app.network
{
   public class RoomType
   {
      
      public static const GAME:String = "TLS-DeadZone-Game-28";
      
      public static const CHAT:String = "ChatRoom-14";
      
      public static const TRADE:String = "TradeRoom-10";
      
      public static const ALLIANCE:String = "Alliance-6";
      
      public function RoomType()
      {
         super();
         throw new Error("RoomType cannot be directly instantiated.");
      }
   }
}

