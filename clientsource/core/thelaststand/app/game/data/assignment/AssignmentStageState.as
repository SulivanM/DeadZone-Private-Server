package thelaststand.app.game.data.assignment
{
   public class AssignmentStageState
   {
      
      public static const LOCKED:uint = 0;
      
      public static const ACTIVE:uint = 1;
      
      public static const COMPLETE:uint = 2;
      
      public function AssignmentStageState()
      {
         super();
         throw new Error("AssignmentStageState cannot be directly instantiated.");
      }
   }
}

