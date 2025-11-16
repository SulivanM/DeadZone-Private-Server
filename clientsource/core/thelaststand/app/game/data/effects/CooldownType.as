package thelaststand.app.game.data.effects
{
   public class CooldownType
   {
      
      public static const Unknown:uint = 0;
      
      public static const DisablePvP:uint = 1;
      
      public static const Purchase:uint = 2;
      
      public static const ResetLeaderAttributes:uint = 3;
      
      public static const Raid:uint = 4;
      
      public static const Arena:uint = 5;
      
      public function CooldownType()
      {
         super();
         throw new Error("CooldownType cannot be directly instantiated.");
      }
   }
}

