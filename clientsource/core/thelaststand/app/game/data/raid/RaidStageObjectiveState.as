package thelaststand.app.game.data.raid
{
   public class RaidStageObjectiveState
   {
      
      public static const INCOMPLETE:uint = 0;
      
      public static const COMPLETE:uint = 1;
      
      public static const FAILED:uint = 2;
      
      public function RaidStageObjectiveState()
      {
         super();
         throw new Error("RaidStageObjectiveState cannot be directly instantiated.");
      }
   }
}

