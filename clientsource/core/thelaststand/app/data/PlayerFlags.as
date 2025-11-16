package thelaststand.app.data
{
   public class PlayerFlags
   {
      
      public static const NicknameVerified:uint = 0;
      
      public static const RefreshNeighbors:uint = 1;
      
      public static const TutorialComplete:uint = 2;
      
      public static const InjurySustained:uint = 3;
      
      public static const InjuryHelpComplete:uint = 4;
      
      public static const AutoProtectionApplied:uint = 5;
      
      public static const TutorialCrateFound:uint = 6;
      
      public static const TutorialCrateUnlocked:uint = 7;
      
      public static const TutorialSchematicFound:uint = 8;
      
      public static const TutorialEffectFound:uint = 9;
      
      public static const TutorialPvPPractice:uint = 10;
      
      public function PlayerFlags()
      {
         super();
         throw new Error("PlayerFlags cannot be directly instantiated.");
      }
   }
}

