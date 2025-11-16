package thelaststand.app.game.data
{
   public class TaskType
   {
      
      public static const JUNK_REMOVAL:String = "junk_removal";
      
      public static const ITEM_CRAFTING:String = "item_crafting";
      
      public function TaskType()
      {
         super();
         throw new Error("TaskType cannot be directly instantiated.");
      }
   }
}

