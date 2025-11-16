package thelaststand.app.game.logic.ai
{
   public class AIAgentFlags
   {
      
      public static const NONE:uint = 0;
      
      public static const LOCKED:uint = 1;
      
      public static const HEALING:uint = 2;
      
      public static const BEING_HEALED:uint = 4;
      
      public static const IS_HEALING_TARGET:uint = 8;
      
      public static const MOUNTED:uint = 16;
      
      public static const IMMOVEABLE:uint = 32;
      
      public static const TARGETING_DISABLED:uint = 64;
      
      public static const RELOAD_DISABLED:uint = 128;
      
      public function AIAgentFlags()
      {
         super();
         throw new Error("AIAgentFlags cannot be directly instantiated.");
      }
   }
}

