package thelaststand.app.game.gui.task
{
   public class TaskItemPriority
   {
      
      public static const General:int = 0;
      
      public static const BuildingRepair:int = 49;
      
      public static const BuildingConstruction:int = 50;
      
      public static const RaidMission:int = 90;
      
      public static const MissionReturn:int = 100;
      
      public static const RecycleJob:int = 30;
      
      public static const Research:int = 20;
      
      public function TaskItemPriority()
      {
         super();
         throw new Error("TaskItemPriority cannot be directly instantiated.");
      }
   }
}

