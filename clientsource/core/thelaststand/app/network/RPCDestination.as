package thelaststand.app.network
{
   public class RPCDestination
   {
      
      public static const Client:uint = 0;
      
      public static const GameServer:uint = 1;
      
      public static const AllianceServer:uint = 2;
      
      public static const ChatRoom:uint = 3;
      
      public static const TradeRoom:uint = 4;
      
      public function RPCDestination()
      {
         super();
         throw new Error("RPCDestination cannot be directly instantiated.");
      }
   }
}

