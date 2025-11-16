package thelaststand.app.game.data
{
   public class SurvivorState
   {
      
      public static const AVAILABLE:uint = 0;
      
      public static const ON_MISSION:uint = 1;
      
      public static const ON_TASK:uint = 2;
      
      public static const REASSIGNING:uint = 4;
      
      public static const ON_ASSIGNMENT:uint = 8;
      
      public function SurvivorState()
      {
         super();
         throw new Error("SurvivorState cannot be directly instantiated.");
      }
   }
}

