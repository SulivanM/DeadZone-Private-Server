package thelaststand.app.game.data
{
   public class TaskStatus
   {
      
      public static const ACTIVE:String = "active";
      
      public static const INACTIVE:String = "inactive";
      
      public static const COMPLETE:String = "complete";
      
      public function TaskStatus()
      {
         super();
         throw new Error("TaskStatus cannot be directly instantiated.");
      }
   }
}

